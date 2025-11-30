import Foundation
import llama

// MARK: - Helper Functions
func llama_batch_clear(_ batch: inout llama_batch) {
    batch.n_tokens = 0
}

func llama_batch_add(_ batch: inout llama_batch, _ id: llama_token, _ pos: llama_pos, _ seq_ids: [llama_seq_id], _ logits: Bool) {
    batch.token   [Int(batch.n_tokens)] = id
    batch.pos     [Int(batch.n_tokens)] = pos
    batch.n_seq_id[Int(batch.n_tokens)] = Int32(seq_ids.count)
    for i in 0..<seq_ids.count {
        batch.seq_id[Int(batch.n_tokens)]![Int(i)] = seq_ids[i]
    }
    batch.logits  [Int(batch.n_tokens)] = logits ? 1 : 0
    batch.n_tokens += 1
}

enum LlamaError: Error {
    case couldNotInitializeContext
}

// Struct to hold calculated sampler settings
struct SamplerParams {
    let temp: Float
    let topP: Float
    let topK: Int32
}

// MARK: - LlamaContext Actor

actor LlamaContext {
    private var model: OpaquePointer
    private var context: OpaquePointer
    private var vocab: OpaquePointer
    private var sampling: UnsafeMutablePointer<llama_sampler>
    private var batch: llama_batch
    private var tokens_list: [llama_token]

    var is_done: Bool = false
    var is_interrupted: Bool = false
    private var temporary_invalid_cchars: [CChar]

    var n_len: Int32 = 2048
    var n_cur: Int32 = 0
    var n_decode: Int32 = 0

    // Init now accepts calculated params
    init(model: OpaquePointer, context: OpaquePointer, params: SamplerParams) {
        self.model = model
        self.context = context
        self.tokens_list = []
        self.batch = llama_batch_init(2048, 0, 1)
        self.temporary_invalid_cchars = []

        // --- DYNAMIC SAMPLER CONFIGURATION ---
        let sparams = llama_sampler_chain_default_params()
        self.sampling = llama_sampler_chain_init(sparams)

        // Apply calculated parameters
        llama_sampler_chain_add(self.sampling, llama_sampler_init_top_k(params.topK))
        llama_sampler_chain_add(self.sampling, llama_sampler_init_top_p(params.topP, 1))
        llama_sampler_chain_add(self.sampling, llama_sampler_init_temp(params.temp))
        llama_sampler_chain_add(self.sampling, llama_sampler_init_dist(1234)) // Random seed

        print("[LlamaContext] Sampler initialized with: Temp=\(params.temp), TopP=\(params.topP), TopK=\(params.topK)")

        vocab = llama_model_get_vocab(model)
    }

    deinit {
        llama_sampler_free(sampling)
        llama_batch_free(batch)
        llama_model_free(model)
        llama_free(context)
        llama_backend_free()
        print("[LlamaContext] Memory released.")
    }

    // Logic ported from Dart/Android to determine params based on file size (MB)
    private static func calculateParams(path: String) -> SamplerParams {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            let fileSize = attr[FileAttributeKey.size] as? UInt64 ?? 0
            let sizeMB = fileSize / (1024 * 1024)

            print("[LlamaContext] Detected model size: \(sizeMB) MB")

            if sizeMB <= 300 {
                return SamplerParams(temp: 0.1, topP: 1.0, topK: 1)       // Micro
            } else if sizeMB <= 700 {
                return SamplerParams(temp: 0.25, topP: 0.98, topK: 5)     // Mini
            } else if sizeMB <= 1400 {
                return SamplerParams(temp: 0.40, topP: 0.92, topK: 20)    // Small
            } else if sizeMB <= 3000 {
                return SamplerParams(temp: 0.55, topP: 0.90, topK: 40)    // Medium
            } else if sizeMB <= 5000 {
                return SamplerParams(temp: 0.70, topP: 0.92, topK: 60)    // Large
            } else if sizeMB <= 8000 {
                return SamplerParams(temp: 0.80, topP: 0.94, topK: 80)    // XL
            } else if sizeMB <= 12000 {
                return SamplerParams(temp: 0.90, topP: 0.95, topK: 100)   // XXL
            } else {
                return SamplerParams(temp: 1.00, topP: 0.97, topK: 120)   // Ultra
            }
        } catch {
            print("[LlamaContext] Warning: Could not determine file size. Using default params.")
            return SamplerParams(temp: 0.7, topP: 0.9, topK: 40)
        }
    }

    static func create_context(path: String) throws -> LlamaContext {
        llama_backend_init()
        var model_params = llama_model_default_params()

        #if targetEnvironment(simulator)
        model_params.n_gpu_layers = 0
        print("[LlamaContext] Running on simulator, forcing n_gpu_layers = 0")
        #else
        model_params.n_gpu_layers = 99 // Metal API enabled
        #endif

        let model = llama_model_load_from_file(path, model_params)
        guard let model else {
            print("[LlamaContext] Could not load model at \(path)")
            throw LlamaError.couldNotInitializeContext
        }

        let n_threads = max(1, min(8, ProcessInfo.processInfo.processorCount - 2))
        var ctx_params = llama_context_default_params()
        ctx_params.n_ctx = 2048
        ctx_params.n_threads = Int32(n_threads)
        ctx_params.n_threads_batch = Int32(n_threads)

        let context = llama_init_from_model(model, ctx_params)
        guard let context else {
            print("[LlamaContext] Could not load context!")
            throw LlamaError.couldNotInitializeContext
        }

        // Calculate params before init
        let params = calculateParams(path: path)

        return LlamaContext(model: model, context: context, params: params)
    }

    func stop() {
        self.is_interrupted = true
    }

    func completion_init(text: String) {
        print("[LlamaContext] Initializing completion for: \"\(text)\"")
        is_interrupted = false
        is_done = false

        tokens_list = tokenize(text: text, add_bos: true)
        temporary_invalid_cchars = []

        let n_ctx = llama_n_ctx(context)
        let n_kv_req = tokens_list.count + (Int(n_len) - tokens_list.count)

        if n_kv_req > n_ctx {
            print("[LlamaContext] Error: n_kv_req > n_ctx")
        }

        llama_batch_clear(&batch)
        for i1 in 0..<tokens_list.count {
            let i = Int(i1)
            llama_batch_add(&batch, tokens_list[i], Int32(i), [0], false)
        }
        batch.logits[Int(batch.n_tokens) - 1] = 1

        if llama_decode(context, batch) != 0 {
            print("[LlamaContext] llama_decode() failed during init")
        }

        n_cur = batch.n_tokens
    }

    func completion_loop() -> String? {
        if is_interrupted { return nil }

        var new_token_id: llama_token = 0
        new_token_id = llama_sampler_sample(sampling, context, batch.n_tokens - 1)

        if llama_vocab_is_eog(vocab, new_token_id) || n_cur == n_len {
            is_done = true
            let new_token_str = String(cString: temporary_invalid_cchars + [0])
            temporary_invalid_cchars.removeAll()
            return new_token_str
        }

        let new_token_cchars = token_to_piece(token: new_token_id)
        temporary_invalid_cchars.append(contentsOf: new_token_cchars)

        let new_token_str: String
        if let string = String(validatingUTF8: temporary_invalid_cchars + [0]) {
            temporary_invalid_cchars.removeAll()
            new_token_str = string
        } else {
            return ""
        }

        llama_batch_clear(&batch)
        llama_batch_add(&batch, new_token_id, n_cur, [0], true)

        n_decode += 1
        n_cur += 1

        if llama_decode(context, batch) != 0 {
            print("[LlamaContext] Failed to evaluate llama!")
            return nil
        }

        return new_token_str
    }

    func clear() {
        tokens_list.removeAll()
        temporary_invalid_cchars.removeAll()
        llama_kv_cache_clear(context)
        print("[LlamaContext] KV Cache Cleared")
    }

    private func tokenize(text: String, add_bos: Bool) -> [llama_token] {
        let utf8Count = text.utf8.count
        let n_tokens = utf8Count + (add_bos ? 1 : 0) + 1
        let tokens = UnsafeMutablePointer<llama_token>.allocate(capacity: n_tokens)
        let tokenCount = llama_tokenize(vocab, text, Int32(utf8Count), tokens, Int32(n_tokens), add_bos, false)
        var swiftTokens: [llama_token] = []
        for i in 0..<tokenCount { swiftTokens.append(tokens[Int(i)]) }
        tokens.deallocate()
        return swiftTokens
    }

    private func token_to_piece(token: llama_token) -> [CChar] {
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: 8)
        result.initialize(repeating: Int8(0), count: 8)
        defer { result.deallocate() }
        let nTokens = llama_token_to_piece(vocab, token, result, 8, 0, false)
        if nTokens < 0 {
            let newSize = Int(-nTokens)
            let newResult = UnsafeMutablePointer<Int8>.allocate(capacity: newSize)
            newResult.initialize(repeating: Int8(0), count: newSize)
            defer { newResult.deallocate() }
            let _ = llama_token_to_piece(vocab, token, newResult, Int32(newSize), 0, false)
            let bufferPointer = UnsafeBufferPointer(start: newResult, count: newSize)
            return Array(bufferPointer)
        } else {
            let bufferPointer = UnsafeBufferPointer(start: result, count: Int(nTokens))
            return Array(bufferPointer)
        }
    }
}