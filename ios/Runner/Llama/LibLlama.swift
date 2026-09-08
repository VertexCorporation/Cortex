import Dispatch
import Foundation
import llama

private let llamaBackendInitialization: Void = {
    llama_backend_init()
}()

func llama_batch_clear(_ batch: inout llama_batch) {
    batch.n_tokens = 0
}

func llama_batch_add(
    _ batch: inout llama_batch,
    _ id: llama_token,
    _ pos: llama_pos,
    _ seqIDs: [llama_seq_id],
    _ logits: Bool
) {
    let index = Int(batch.n_tokens)
    batch.token[index] = id
    batch.pos[index] = pos
    batch.n_seq_id[index] = Int32(seqIDs.count)

    if let seqIDPointer = batch.seq_id[index] {
        for (sequenceIndex, sequenceID) in seqIDs.enumerated() {
            seqIDPointer[sequenceIndex] = sequenceID
        }
    }

    batch.logits[index] = logits ? 1 : 0
    batch.n_tokens += 1
}

enum LlamaError: LocalizedError {
    case couldNotInitializeContext
    case couldNotInitializeBatch
    case modelNotFound(String)
    case promptTooLong(tokens: Int, context: Int)
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .couldNotInitializeContext:
            return "Could not initialize llama.cpp context"
        case .couldNotInitializeBatch:
            return "Could not initialize llama.cpp batch"
        case .modelNotFound(let path):
            return "Could not load model at \(path)"
        case .promptTooLong(let tokens, let context):
            return "Prompt has \(tokens) tokens but context is \(context)"
        case .decodeFailed:
            return "llama.cpp decode failed"
        }
    }
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

struct LlamaRuntimeInfo: Sendable {
    let nCtx: Int32
    let nThreads: Int32
    let nThreadsBatch: Int32
    let nBatch: Int32
    let nUbatch: Int32
    let nGpuLayers: Int32
}

struct LlamaCapacityResult: Sendable {
    let info: LlamaRuntimeInfo
    let capacitySatisfied: Bool
}

struct LlamaPromptStats: Sendable {
    let promptTokens: Int
    let cacheHitTokens: Int
    let prefillMilliseconds: Double
}

actor LlamaContext {
    private var model: OpaquePointer
    private var context: OpaquePointer
    private var vocab: OpaquePointer
    private var sampling: UnsafeMutablePointer<llama_sampler>
    private var batch: llama_batch
    private var info: LlamaRuntimeInfo
    private var debugPerformance: Bool
    private var cachedTokens: [llama_token] = []
    private var temporaryInvalidCChars: [CChar] = []

    var is_done = false
    var is_interrupted = false
    var n_len: Int32
    var n_cur: Int32 = 0
    var n_decode: Int32 = 0

    private init(
        model: OpaquePointer,
        context: OpaquePointer,
        batch: llama_batch,
        sampling: UnsafeMutablePointer<llama_sampler>,
        info: LlamaRuntimeInfo,
        debugPerformance: Bool
    ) {
        self.model = model
        self.context = context
        self.vocab = llama_model_get_vocab(model)
        self.batch = batch
        self.sampling = sampling
        self.info = info
        self.debugPerformance = debugPerformance
        self.n_len = info.nCtx
    }

    deinit {
        llama_sampler_free(sampling)
        llama_batch_free(batch)
        llama_free(context)
        llama_model_free(model)
    }

    static func createContext(
        path: String,
        nCtx: Int32 = 2048,
        nGpu: Int32 = 99,
        nThreads: Int32 = 4,
        nThreadsBatch: Int32 = 4,
        nBatch: Int32 = 512,
        nUbatch: Int32 = 128,
        debugPerformance: Bool = false
    ) throws -> LlamaContext {
        _ = llamaBackendInitialization

        var modelParams = llama_model_default_params()
        modelParams.use_mmap = llama_supports_mmap()

        let gpuLayers: Int32
        #if targetEnvironment(simulator)
        gpuLayers = 0
        #else
        gpuLayers = nGpu > 0 && llama_supports_gpu_offload() ? nGpu : 0
        #endif
        modelParams.n_gpu_layers = gpuLayers

        guard let model = llama_model_load_from_file(path, modelParams) else {
            throw LlamaError.modelNotFound(path)
        }

        let configuration = makeContextConfiguration(
            model: model,
            nCtx: nCtx,
            nThreads: nThreads,
            nThreadsBatch: nThreadsBatch,
            nBatch: nBatch,
            nUbatch: nUbatch,
            nGpuLayers: gpuLayers
        )
        guard let context = llama_init_from_model(
            model,
            makeContextParams(configuration)
        ) else {
            llama_model_free(model)
            throw LlamaError.couldNotInitializeContext
        }

        let resolved = LlamaRuntimeInfo(
            nCtx: Int32(llama_n_ctx(context)),
            nThreads: configuration.nThreads,
            nThreadsBatch: configuration.nThreadsBatch,
            nBatch: Int32(llama_n_batch(context)),
            nUbatch: Int32(llama_n_ubatch(context)),
            nGpuLayers: configuration.nGpuLayers
        )
        let batch = llama_batch_init(resolved.nBatch, 0, 1)
        guard batch.token != nil else {
            llama_batch_free(batch)
            llama_free(context)
            llama_model_free(model)
            throw LlamaError.couldNotInitializeBatch
        }

        let defaultSampler = SamplerParams(
            temp: 0.7,
            topP: 0.95,
            topK: 40,
            repeatPenalty: 1.0,
            frequencyPenalty: 0.0,
            presencePenalty: 0.0,
            mirostatMode: 0,
            mirostatTau: 5.0,
            mirostatEta: 0.1
        )
        return LlamaContext(
            model: model,
            context: context,
            batch: batch,
            sampling: makeSampler(defaultSampler),
            info: resolved,
            debugPerformance: debugPerformance
        )
    }

    func runtimeInfo() -> LlamaRuntimeInfo {
        info
    }

    func ensureCapacity(
        nCtx: Int32,
        nThreads: Int32,
        nThreadsBatch: Int32,
        nBatch: Int32,
        nUbatch: Int32,
        debugPerformance: Bool
    ) -> LlamaCapacityResult {
        let target = Self.makeContextConfiguration(
            model: model,
            nCtx: nCtx,
            nThreads: nThreads,
            nThreadsBatch: nThreadsBatch,
            nBatch: nBatch,
            nUbatch: nUbatch,
            nGpuLayers: info.nGpuLayers
        )
        self.debugPerformance = debugPerformance

        if info.nCtx >= target.nCtx {
            return LlamaCapacityResult(info: info, capacitySatisfied: true)
        }

        guard let replacementContext = llama_init_from_model(
            model,
            Self.makeContextParams(target)
        ) else {
            debugLog("[LlamaContext] Context growth failed; retaining \(info.nCtx) tokens")
            return LlamaCapacityResult(info: info, capacitySatisfied: false)
        }

        let resolved = LlamaRuntimeInfo(
            nCtx: Int32(llama_n_ctx(replacementContext)),
            nThreads: target.nThreads,
            nThreadsBatch: target.nThreadsBatch,
            nBatch: Int32(llama_n_batch(replacementContext)),
            nUbatch: Int32(llama_n_ubatch(replacementContext)),
            nGpuLayers: target.nGpuLayers
        )
        let replacementBatch = llama_batch_init(resolved.nBatch, 0, 1)
        guard replacementBatch.token != nil else {
            llama_batch_free(replacementBatch)
            llama_free(replacementContext)
            debugLog("[LlamaContext] Batch growth failed; retaining \(info.nCtx) tokens")
            return LlamaCapacityResult(info: info, capacitySatisfied: false)
        }

        let previousContext = context
        let previousBatch = batch
        context = replacementContext
        batch = replacementBatch
        info = resolved
        n_len = resolved.nCtx
        cachedTokens.removeAll(keepingCapacity: false)
        llama_batch_free(previousBatch)
        llama_free(previousContext)

        return LlamaCapacityResult(info: resolved, capacitySatisfied: true)
    }

    func stop() {
        is_interrupted = true
    }

    func updateSampler(
        temp: Float,
        topP: Float,
        topK: Int32,
        repeatPenalty: Float = 1.0,
        frequencyPenalty: Float = 0.0,
        presencePenalty: Float = 0.0,
        mirostatMode: Int32 = 0,
        mirostatTau: Float = 5.0,
        mirostatEta: Float = 0.1
    ) {
        let params = SamplerParams(
            temp: temp,
            topP: topP,
            topK: topK,
            repeatPenalty: repeatPenalty,
            frequencyPenalty: frequencyPenalty,
            presencePenalty: presencePenalty,
            mirostatMode: mirostatMode,
            mirostatTau: mirostatTau,
            mirostatEta: mirostatEta
        )
        let replacement = Self.makeSampler(params)
        llama_sampler_free(sampling)
        sampling = replacement
    }

    func clear() {
        temporaryInvalidCChars.removeAll(keepingCapacity: true)
        cachedTokens.removeAll(keepingCapacity: true)
        n_cur = 0
        n_decode = 0
        llama_kv_self_clear(context)
        debugLog("[LlamaContext][perf] KV cache cleared")
    }

    func completion_init(text: String, imageData: Data?) throws -> LlamaPromptStats {
        if let data = imageData {
            debugLog("[LlamaContext] Image data received (\(data.count) bytes); vision bridge is unavailable")
        }

        let prefillStart = DispatchTime.now().uptimeNanoseconds
        is_interrupted = false
        is_done = false
        temporaryInvalidCChars.removeAll(keepingCapacity: true)
        n_cur = 0
        n_decode = 0

        let promptTokens = tokenize(text: text, addBOS: true, parseSpecial: true)
        let contextSize = Int(llama_n_ctx(context))
        guard !promptTokens.isEmpty, promptTokens.count < contextSize else {
            throw LlamaError.promptTooLong(
                tokens: promptTokens.count,
                context: contextSize
            )
        }

        var commonPrefix = 0
        let comparableCount = min(promptTokens.count, cachedTokens.count)
        while commonPrefix < comparableCount &&
            promptTokens[commonPrefix] == cachedTokens[commonPrefix] {
            commonPrefix += 1
        }

        if commonPrefix == promptTokens.count && commonPrefix > 0 {
            commonPrefix -= 1
        }

        if commonPrefix < cachedTokens.count {
            let removed = llama_kv_self_seq_rm(
                context,
                0,
                Int32(commonPrefix),
                -1
            )
            if !removed {
                llama_kv_self_clear(context)
                commonPrefix = 0
            }
        }

        let logicalBatch = max(1, Int(llama_n_batch(context)))
        var offset = commonPrefix
        while offset < promptTokens.count {
            let chunkSize = min(logicalBatch, promptTokens.count - offset)
            llama_batch_clear(&batch)

            for index in 0..<chunkSize {
                let absolutePosition = offset + index
                llama_batch_add(
                    &batch,
                    promptTokens[absolutePosition],
                    Int32(absolutePosition),
                    [0],
                    false
                )
            }

            if offset + chunkSize == promptTokens.count {
                batch.logits[Int(batch.n_tokens) - 1] = 1
            }

            guard llama_decode(context, batch) == 0 else {
                llama_kv_self_clear(context)
                cachedTokens.removeAll(keepingCapacity: true)
                is_done = true
                throw LlamaError.decodeFailed
            }
            llama_synchronize(context)
            offset += chunkSize
        }

        n_cur = Int32(promptTokens.count)
        cachedTokens = promptTokens
        let elapsed = DispatchTime.now().uptimeNanoseconds - prefillStart
        return LlamaPromptStats(
            promptTokens: promptTokens.count,
            cacheHitTokens: commonPrefix,
            prefillMilliseconds: Double(elapsed) / 1_000_000.0
        )
    }

    func completion_loop() -> String? {
        if is_interrupted {
            is_done = true
            return nil
        }

        guard batch.n_tokens > 0 else {
            is_done = true
            return nil
        }

        let newTokenID = llama_sampler_sample(sampling, context, -1)
        if llama_vocab_is_eog(vocab, newTokenID) || n_cur >= n_len {
            is_done = true
            if !temporaryInvalidCChars.isEmpty {
                let bytes = temporaryInvalidCChars.map { UInt8(bitPattern: $0) }
                temporaryInvalidCChars.removeAll(keepingCapacity: true)
                return String(decoding: bytes, as: UTF8.self)
            }
            return nil
        }

        temporaryInvalidCChars.append(contentsOf: tokenToPiece(token: newTokenID))
        let newTokenString: String
        if let string = String(validatingUTF8: temporaryInvalidCChars + [0]) {
            temporaryInvalidCChars.removeAll(keepingCapacity: true)
            newTokenString = string
        } else {
            newTokenString = ""
        }

        llama_batch_clear(&batch)
        llama_batch_add(&batch, newTokenID, n_cur, [0], true)

        guard llama_decode(context, batch) == 0 else {
            llama_kv_self_clear(context)
            cachedTokens.removeAll(keepingCapacity: true)
            is_done = true
            return nil
        }
        llama_synchronize(context)

        cachedTokens.append(newTokenID)
        n_decode += 1
        n_cur += 1
        return newTokenString
    }

    private static func makeContextConfiguration(
        model: OpaquePointer,
        nCtx: Int32,
        nThreads: Int32,
        nThreadsBatch: Int32,
        nBatch: Int32,
        nUbatch: Int32,
        nGpuLayers: Int32
    ) -> LlamaRuntimeInfo {
        let modelLimit = max(128, llama_model_n_ctx_train(model))
        let modelLayers = max(0, llama_model_n_layer(model))
        let contextSize = min(max(128, nCtx), modelLimit)
        let generationThreads = max(1, nThreads)
        let batchThreads = max(1, nThreadsBatch)
        let batchSize = min(max(32, nBatch), contextSize)
        let microBatchSize = min(max(32, nUbatch), batchSize)
        return LlamaRuntimeInfo(
            nCtx: contextSize,
            nThreads: generationThreads,
            nThreadsBatch: batchThreads,
            nBatch: batchSize,
            nUbatch: microBatchSize,
            nGpuLayers: min(max(0, nGpuLayers), modelLayers)
        )
    }

    private static func makeContextParams(
        _ configuration: LlamaRuntimeInfo
    ) -> llama_context_params {
        var params = llama_context_default_params()
        params.n_ctx = UInt32(configuration.nCtx)
        params.n_batch = UInt32(configuration.nBatch)
        params.n_ubatch = UInt32(configuration.nUbatch)
        params.n_threads = configuration.nThreads
        params.n_threads_batch = configuration.nThreadsBatch
        return params
    }

    private static func makeSampler(
        _ params: SamplerParams
    ) -> UnsafeMutablePointer<llama_sampler> {
        var chainParams = llama_sampler_chain_default_params()
        chainParams.no_perf = true
        let sampler = llama_sampler_chain_init(chainParams)

        if params.temp <= 0.0 {
            llama_sampler_chain_add(sampler, llama_sampler_init_greedy())
            return sampler
        }
        if params.repeatPenalty != 1.0 ||
            params.frequencyPenalty != 0.0 ||
            params.presencePenalty != 0.0 {
            llama_sampler_chain_add(
                sampler,
                llama_sampler_init_penalties(
                    64,
                    params.repeatPenalty,
                    params.frequencyPenalty,
                    params.presencePenalty
                )
            )
        }
        if params.topK > 0 {
            llama_sampler_chain_add(sampler, llama_sampler_init_top_k(params.topK))
        }
        if params.topP > 0.0 && params.topP < 1.0 {
            llama_sampler_chain_add(sampler, llama_sampler_init_top_p(params.topP, 1))
        }
        llama_sampler_chain_add(sampler, llama_sampler_init_temp(params.temp))
        if params.mirostatMode == 2 {
            llama_sampler_chain_add(
                sampler,
                llama_sampler_init_mirostat_v2(
                    LLAMA_DEFAULT_SEED,
                    params.mirostatTau,
                    params.mirostatEta
                )
            )
        }
        llama_sampler_chain_add(sampler, llama_sampler_init_dist(LLAMA_DEFAULT_SEED))
        return sampler
    }

    private func tokenize(
        text: String,
        addBOS: Bool,
        parseSpecial: Bool
    ) -> [llama_token] {
        let utf8Count = text.utf8.count
        let capacity = utf8Count + (addBOS ? 1 : 0) + 256
        let tokens = UnsafeMutablePointer<llama_token>.allocate(capacity: capacity)
        defer { tokens.deallocate() }

        let tokenCount = llama_tokenize(
            vocab,
            text,
            Int32(utf8Count),
            tokens,
            Int32(capacity),
            addBOS,
            parseSpecial
        )
        guard tokenCount > 0 else { return [] }
        return (0..<Int(tokenCount)).map { tokens[$0] }
    }

    private func tokenToPiece(token: llama_token) -> [CChar] {
        var buffer = [CChar](repeating: 0, count: 8)
        let count = llama_token_to_piece(vocab, token, &buffer, 8, 0, false)
        if count >= 0 {
            return Array(buffer.prefix(Int(count)))
        }

        let requiredSize = Int(-count)
        var expanded = [CChar](repeating: 0, count: requiredSize)
        let expandedCount = llama_token_to_piece(
            vocab,
            token,
            &expanded,
            Int32(requiredSize),
            0,
            false
        )
        guard expandedCount > 0 else { return [] }
        return Array(expanded.prefix(Int(expandedCount)))
    }

    private func debugLog(_ message: @autoclosure () -> String) {
        #if DEBUG
        if debugPerformance {
            print(message())
        }
        #endif
    }
}
