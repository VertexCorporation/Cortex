import Foundation
import llama

// MARK: - Helper Functions

/// Clears the llama_batch struct safely
func llama_batch_clear(_ batch: inout llama_batch) {
    batch.n_tokens = 0
}

/// Adds a token to the batch.
/// Note: This handles specific pointer arithmetic for the C-struct interaction.
func llama_batch_add(_ batch: inout llama_batch, _ id: llama_token, _ pos: llama_pos, _ seq_ids: [llama_seq_id], _ logits: Bool) {
    let i = Int(batch.n_tokens)

    batch.token[i] = id
    batch.pos[i] = pos
    batch.n_seq_id[i] = Int32(seq_ids.count)

    // batch.seq_id is a pointer to pointers (llama_seq_id**)
    // We need to safely access the array at index [i]
    if let seqIdPtr = batch.seq_id[i] {
        for (idx, seqId) in seq_ids.enumerated() {
            seqIdPtr[idx] = seqId
        }
    }

    batch.logits[i] = logits ? 1 : 0
    batch.n_tokens += 1
}

enum LlamaError: Error {
    case couldNotInitializeContext
    case modelNotFound(String)
    case decodeFailed
}

struct SamplerParams {
    let temp: Float
    let topP: Float
    let topK: Int32
    let repeatPenalty: Float
    let frequencyPenalty: Float
    let presencePenalty: Float
    let mirostatMode: Int32
    let mirostatTau: Float
    let mirostatEta: Float
}

// MARK: - LlamaContext Actor

actor LlamaContext {
    private var model: OpaquePointer
    private var context: OpaquePointer
    private var vocab: OpaquePointer
    private var sampling: UnsafeMutablePointer<llama_sampler>
    private var batch: llama_batch

    // State variables
    var is_done: Bool = false
    var is_interrupted: Bool = false

    // Buffer for handling incomplete UTF-8 byte sequences (e.g. split emojis)
    private var temporary_invalid_cchars: [CChar] = []

    var n_len: Int32 = 2048
    var n_cur: Int32 = 0
    var n_decode: Int32 = 0

    // MARK: - Initialization

    init(model: OpaquePointer, context: OpaquePointer, params: SamplerParams, nCtx: Int32) {
        self.model = model
        self.context = context
        self.vocab = llama_model_get_vocab(model)
        
        // Store n_len based on context size
        self.n_len = nCtx

        // Initialize Batch with dynamic context size (matching Android behavior)
        // Android: new_batch(nCtx, 0, 1)
        self.batch = llama_batch_init(nCtx, 0, 1)

        // Initialize Sampler Chain with proper ordering (matching Android)
        let sparams = llama_sampler_chain_default_params()
        self.sampling = llama_sampler_chain_init(sparams)

        // Add samplers in correct order (same as Android)
        // 0) Repetition / Frequency / Presence penalties
        if params.repeatPenalty != 1.0 || params.frequencyPenalty != 0.0 || params.presencePenalty != 0.0 {
            llama_sampler_chain_add(self.sampling, llama_sampler_init_penalties(64, params.repeatPenalty, params.frequencyPenalty, params.presencePenalty))
        }
        // 1) Top-K
        if params.topK > 0 {
            llama_sampler_chain_add(self.sampling, llama_sampler_init_top_k(params.topK))
        }
        // 2) Top-P
        if params.topP > 0.0 && params.topP < 1.0 {
            llama_sampler_chain_add(self.sampling, llama_sampler_init_top_p(params.topP, 1))
        }
        // 3) Temperature
        llama_sampler_chain_add(self.sampling, llama_sampler_init_temp(params.temp))
        // 4) Mirostat V2
        if params.mirostatMode == 2 {
            llama_sampler_chain_add(self.sampling, llama_sampler_init_mirostat_v2(LLAMA_DEFAULT_SEED, params.mirostatTau, params.mirostatEta))
        }
        // 5) Final distribution sampler
        llama_sampler_chain_add(self.sampling, llama_sampler_init_dist(UInt32(time(nil))))

        print("[LlamaContext] Initialized with nCtx=\(nCtx)")
    }

    deinit {
        // Free C resources safely
        llama_sampler_free(sampling)
        llama_batch_free(batch)
        llama_free(context)
        llama_model_free(model)
        print("[LlamaContext] Memory released.")
    }

    /// Static Factory to create and return an actor instance
    static func create_context(path: String, nCtx: Int32 = 2048, nGpu: Int32 = 99, nThreads: Int32 = 4) throws -> LlamaContext {
        llama_backend_init()

        var model_params = llama_model_default_params()

        #if targetEnvironment(simulator)
        model_params.n_gpu_layers = 0
        print("[LlamaContext] Simulator detected: GPU disabled.")
        #else
        // Use provided nGpu
        model_params.n_gpu_layers = nGpu
        print("[LlamaContext] Device detected: GPU (Metal) enabled with \(nGpu) layers.")
        #endif

        guard let model = llama_model_load_from_file(path, model_params) else {
            throw LlamaError.modelNotFound(path)
        }

        // Use provided thread count or auto-detect
        let threads = nThreads > 0 ? Int(nThreads) : max(1, min(8, ProcessInfo.processInfo.processorCount - 2))

        var ctx_params = llama_context_default_params()
        // DYNAMIC CONTEXT SIZE from Dart!
        ctx_params.n_ctx = UInt32(nCtx)
        ctx_params.n_threads = Int32(threads)
        ctx_params.n_threads_batch = Int32(threads)
        
        print("[LlamaContext] Creating context with n_ctx=\(nCtx), n_threads=\(threads)")

        guard let context = llama_init_from_model(model, ctx_params) else {
            llama_model_free(model)
            throw LlamaError.couldNotInitializeContext
        }

        // Use default params initially, will be updated per-message
        let params = SamplerParams(temp: 0.7, topP: 0.9, topK: 40, repeatPenalty: 1.0, frequencyPenalty: 0.0, presencePenalty: 0.0, mirostatMode: 0, mirostatTau: 5.0, mirostatEta: 0.1)
        // Pass nCtx to init so batch size matches context size
        return LlamaContext(model: model, context: context, params: params, nCtx: nCtx)
    }

    // MARK: - Control Methods

    func stop() {
        self.is_interrupted = true
    }
    
    /// Updates the sampler with new parameters from Dart (per-message)
    func updateSampler(temp: Float, topP: Float, topK: Int32, repeatPenalty: Float = 1.0, frequencyPenalty: Float = 0.0, presencePenalty: Float = 0.0, mirostatMode: Int32 = 0, mirostatTau: Float = 5.0, mirostatEta: Float = 0.1) {
        // Free old sampler
        llama_sampler_free(sampling)
        
        // Create new sampler chain with Dart-provided params
        let sparams = llama_sampler_chain_default_params()
        sampling = llama_sampler_chain_init(sparams)
        
        // Add samplers in correct order (same as Android)
        if repeatPenalty != 1.0 || frequencyPenalty != 0.0 || presencePenalty != 0.0 {
            llama_sampler_chain_add(sampling, llama_sampler_init_penalties(64, repeatPenalty, frequencyPenalty, presencePenalty))
        }
        if topK > 0 {
            llama_sampler_chain_add(sampling, llama_sampler_init_top_k(topK))
        }
        if topP > 0.0 && topP < 1.0 {
            llama_sampler_chain_add(sampling, llama_sampler_init_top_p(topP, 1))
        }
        llama_sampler_chain_add(sampling, llama_sampler_init_temp(temp))
        if mirostatMode == 2 {
            llama_sampler_chain_add(sampling, llama_sampler_init_mirostat_v2(LLAMA_DEFAULT_SEED, mirostatTau, mirostatEta))
        }
        llama_sampler_chain_add(sampling, llama_sampler_init_dist(UInt32(time(nil))))
        
        print("[LlamaContext] Sampler updated")
    }

    func clear() {
        temporary_invalid_cchars.removeAll()
        n_cur = 0
        n_decode = 0
        
        // CRITICAL FIX: Clear native KV cache to match Android behavior
        // Without this, old context bleeds into new generations causing gibberish
        // New llama.cpp API: llama_kv_self_clear(ctx)
        llama_kv_self_clear(context)
        
        print("[LlamaContext] Context and KV cache cleared.")
    }

    // MARK: - Generation Logic

    func completion_init(text: String, imageData: Data?) {
        if let data = imageData {
             print("[LlamaContext] Image data received (\(data.count) bytes). Vision processing not yet fully bridged.")
             // TODO: implement llava_eval_image_embed if bindings available
        }

        print("[LlamaContext] Processing prompt: \(text.prefix(100))...")

        // Reset state
        is_interrupted = false
        is_done = false
        temporary_invalid_cchars.removeAll()
        n_cur = 0
        n_decode = 0
        
        // CRITICAL: Clear KV cache before new generation (matching Android behavior)
        // New llama.cpp API: llama_kv_self_clear(ctx)
        llama_kv_self_clear(context)

        // Tokenize with special token parsing enabled (CRITICAL for chat formats!)
        // This ensures tokens like <|im_start|>, <|im_end|>, <|eot_id|> are parsed correctly
        let tokens_list = tokenize(text: text, add_bos: true, parseSpecial: true)
        
        print("[LlamaContext] Prompt tokenized: \(tokens_list.count) tokens")

        // Check context limits
        let n_ctx = llama_n_ctx(context)
        let n_kv_req = tokens_list.count + (Int(n_len) - tokens_list.count)

        if n_kv_req > n_ctx {
            print("[LlamaContext] Warning: Request exceeds context window (\(n_kv_req) > \(n_ctx))")
        }

        // Prepare Batch
        llama_batch_clear(&batch)

        for (i, token) in tokens_list.enumerated() {
            llama_batch_add(&batch, token, Int32(i), [0], false)
        }

        // Calculate logits only for the last token to predict the next one
        if batch.n_tokens > 0 {
            batch.logits[Int(batch.n_tokens) - 1] = 1
        }

        // Decode Prompt
        if llama_decode(context, batch) != 0 {
            print("[LlamaContext] Error: llama_decode failed during prompt processing.")
            is_done = true
        } else {
            n_cur = batch.n_tokens
        }

        llama_synchronize(context)
    }

    func completion_loop() -> String? {
        if is_interrupted { return nil }

        // 1. Sample the next token
        // Use the index of the last token in the batch
        let new_token_id = llama_sampler_sample(sampling, context, batch.n_tokens - 1)

        // 2. Check for End of Generation (EOG) or limit reached
        if llama_vocab_is_eog(vocab, new_token_id) || n_cur >= n_len {
            is_done = true
            // If we have leftover bytes (incomplete chars), return them now (though likely garbage if incomplete)
            if !temporary_invalid_cchars.isEmpty {
                let str = String(cString: temporary_invalid_cchars + [0])
                temporary_invalid_cchars.removeAll()
                return str
            }
            return nil
        }

        // 3. Convert Token to String (Handling split UTF-8)
        let new_token_cchars = token_to_piece(token: new_token_id)
        temporary_invalid_cchars.append(contentsOf: new_token_cchars)

        // Try to create a valid string from the buffer
        let new_token_str: String
        // Validating UTF8 creates a string only if the bytes are complete
        if let string = String(validatingUTF8: temporary_invalid_cchars + [0]) {
            temporary_invalid_cchars.removeAll() // Clear buffer on success
            new_token_str = string
        } else {
            // Buffer contains incomplete UTF-8 bytes, return empty and wait for next token to complete it
            new_token_str = ""
        }

        // 4. Prepare batch for next decoding step
        llama_batch_clear(&batch)
        llama_batch_add(&batch, new_token_id, n_cur, [0], true)

        n_decode += 1
        n_cur += 1

        // 5. Decode
        if llama_decode(context, batch) != 0 {
            print("[LlamaContext] Error: llama_decode failed during generation.")
            return nil
        }
        llama_synchronize(context)

        return new_token_str
    }

    // MARK: - Private Helpers

    /// Tokenizes the input text.
    /// - Parameters:
    ///   - text: The text to tokenize
    ///   - add_bos: Whether to add beginning-of-sequence token
    ///   - parseSpecial: If true, special tokens like <|im_start|> are parsed as control tokens.
    ///                   This is CRITICAL for chat formats to work correctly!
    private func tokenize(text: String, add_bos: Bool, parseSpecial: Bool = true) -> [llama_token] {
        let utf8Count = text.utf8.count
        // Allocate more space for potential token expansion
        let n_tokens = utf8Count + (add_bos ? 1 : 0) + 256

        let tokens = UnsafeMutablePointer<llama_token>.allocate(capacity: n_tokens)
        defer { tokens.deallocate() }

        // CRITICAL FIX: Pass parseSpecial=true to properly handle chat format tokens
        // like <|im_start|>, <|im_end|>, <|eot_id|>, etc.
        // Without this, these tokens are treated as literal text and break generation!
        let tokenCount = llama_tokenize(vocab, text, Int32(utf8Count), tokens, Int32(n_tokens), add_bos, parseSpecial)

        var swiftTokens: [llama_token] = []
        if tokenCount > 0 {
            for i in 0..<tokenCount {
                swiftTokens.append(tokens[Int(i)])
            }
        }
        
        if parseSpecial {
            print("[LlamaContext] Tokenized \(swiftTokens.count) tokens (special tokens parsed)")
        }
        
        return swiftTokens
    }

    private func token_to_piece(token: llama_token) -> [CChar] {
        // Try a small stack buffer first (most tokens are small)
        var buffer = [CChar](repeating: 0, count: 8)

        // Pass 0 as length first to get the required size (if it doesn't fit in 8)?
        // Actually llama_token_to_piece returns the negative of required size if it fails,
        // or the actual size if it succeeds.

        let nTokens = llama_token_to_piece(vocab, token, &buffer, 8, 0, false)

        if nTokens < 0 {
            // Buffer was too small, resize and try again
            let newSize = Int(-nTokens)
            var newBuffer = [CChar](repeating: 0, count: newSize)
            let check = llama_token_to_piece(vocab, token, &newBuffer, Int32(newSize), 0, false)
            return Array(newBuffer.prefix(Int(check)))
        } else {
            return Array(buffer.prefix(Int(nTokens)))
        }
    }
}