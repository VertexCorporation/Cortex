import Dispatch
import Flutter
import Foundation

class LlamaService: NSObject, FlutterPlugin {
    private var llamaContext: LlamaContext?
    private var loadedModelPath: String?
    private var resultChannel: FlutterMethodChannel?
    private var generationTask: Task<Void, Never>?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.vertex.cortex/llama",
            binaryMessenger: registrar.messenger()
        )
        let instance = LlamaService()
        instance.resultChannel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "cacheModel":
            cacheModel(call, result: result)
        case "sendMessage":
            sendMessage(call, result: result)
        case "stopGeneration":
            generationTask?.cancel()
            let pending = generationTask
            Task {
                await self.llamaContext?.stop()
                await pending?.value
                DispatchQueue.main.async { result(nil) }
            }
        case "releaseModel":
            Task {
                await self.llamaContext?.stop()
                self.llamaContext = nil
                self.loadedModelPath = nil
                DispatchQueue.main.async { result(nil) }
            }
        case "resetKv":
            Task {
                await self.llamaContext?.clear()
                DispatchQueue.main.async { result(nil) }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func cacheModel(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              !path.isEmpty else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Path is required",
                details: nil
            ))
            return
        }

        let nCtx = int32Argument(args, "nCtx", default: 2048)
        let nGpu = int32Argument(args, "nGpu", default: 99)
        let nThreads = int32Argument(args, "nThreads", default: 4)
        let nThreadsBatch = int32Argument(
            args,
            "nThreadsBatch",
            default: nThreads
        )
        let nBatch = int32Argument(args, "nBatch", default: 512)
        let nUbatch = int32Argument(args, "nUbatch", default: 128)
        let debugPerformance = boolArgument(args, "debugPerf", default: false)

        // Match Android's asynchronous contract. Completion is delivered through
        // onModelLoaded/onModelLoadFailed while disk/model work stays off Flutter's
        // method call path.
        result(nil)

        Task(priority: .userInitiated) {
            let loadStart = DispatchTime.now().uptimeNanoseconds
            do {
                let info: LlamaRuntimeInfo
                let reusedModel: Bool
                let capacitySatisfied: Bool

                if let context = self.llamaContext,
                   self.loadedModelPath == path {
                    let capacity = await context.ensureCapacity(
                        nCtx: nCtx,
                        nThreads: nThreads,
                        nThreadsBatch: nThreadsBatch,
                        nBatch: nBatch,
                        nUbatch: nUbatch,
                        debugPerformance: debugPerformance
                    )
                    info = capacity.info
                    reusedModel = true
                    capacitySatisfied = capacity.capacitySatisfied
                } else {
                    if let previous = self.llamaContext {
                        await previous.stop()
                        self.llamaContext = nil
                        self.loadedModelPath = nil
                    }

                    let context = try LlamaContext.createContext(
                        path: path,
                        nCtx: nCtx,
                        nGpu: nGpu,
                        nThreads: nThreads,
                        nThreadsBatch: nThreadsBatch,
                        nBatch: nBatch,
                        nUbatch: nUbatch,
                        debugPerformance: debugPerformance
                    )
                    self.llamaContext = context
                    self.loadedModelPath = path
                    info = await context.runtimeInfo()
                    reusedModel = false
                    capacitySatisfied = true
                }

                let loadMilliseconds = self.millisecondsSince(loadStart)
                self.debugPerformanceLog(
                    enabled: debugPerformance,
                    "[LlamaService][perf] modelLoadMs=\(loadMilliseconds) ctx=\(info.nCtx) threads=\(info.nThreads)/\(info.nThreadsBatch) gpu=\(info.nGpuLayers) batch=\(info.nBatch)/\(info.nUbatch) reused=\(reusedModel)"
                )
                let details = self.modelDetails(
                    path: path,
                    info: info,
                    reusedModel: reusedModel,
                    capacitySatisfied: capacitySatisfied
                )
                DispatchQueue.main.async {
                    self.resultChannel?.invokeMethod(
                        "onModelLoaded",
                        arguments: details
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.resultChannel?.invokeMethod(
                        "onModelLoadFailed",
                        arguments: error.localizedDescription
                    )
                }
            }
        }
    }

    private func sendMessage(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
              let message = args["message"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Message is required",
                details: nil
            ))
            return
        }
        guard let context = llamaContext else {
            result(FlutterError(
                code: "NO_MODEL",
                message: "Model not loaded",
                details: nil
            ))
            return
        }

        let photoPath = args["photoPath"] as? String
        let requestId = args["requestId"] as? String ?? ""
        let temp = floatArgument(args, "temp", default: 0.7)
        let topP = floatArgument(args, "topP", default: 0.95)
        let topK = int32Argument(args, "topK", default: 40)
        let repeatPenalty = floatArgument(
            args,
            "repeatPenalty",
            default: 1.0
        )
        let frequencyPenalty = floatArgument(
            args,
            "frequencyPenalty",
            default: 0.0
        )
        let presencePenalty = floatArgument(
            args,
            "presencePenalty",
            default: 0.0
        )
        let mirostatMode = int32Argument(args, "mirostatMode", default: 0)
        let mirostatTau = floatArgument(args, "mirostatTau", default: 5.0)
        let mirostatEta = floatArgument(args, "mirostatEta", default: 0.1)
        let debugPerformance = boolArgument(args, "debugPerf", default: false)

        result(nil)

        let previous = generationTask
        previous?.cancel()
        generationTask = Task(priority: .userInitiated) {
            await previous?.value
            guard !Task.isCancelled else { return }
            let requestStart = DispatchTime.now().uptimeNanoseconds
            var generationError: String?
            let photoData: Data?
            if let photoPath = photoPath, !photoPath.isEmpty {
                photoData = try? Data(contentsOf: URL(fileURLWithPath: photoPath))
            } else {
                photoData = nil
            }

            await context.updateSampler(
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

            do {
                try Task.checkCancellation()
                let promptStats = try await context.completion_init(
                    text: message,
                    imageData: photoData
                )
                let prefillDone = DispatchTime.now().uptimeNanoseconds
                var firstTokenTime: UInt64?
                var generatedTokens = 0

                while !(await context.is_done) {
                    try Task.checkCancellation()
                    guard let token = try await context.completion_loop() else {
                        break
                    }
                    generatedTokens += 1
                    if firstTokenTime == nil {
                        firstTokenTime = DispatchTime.now().uptimeNanoseconds
                    }
                    if !token.isEmpty {
                        DispatchQueue.main.async {
                            self.resultChannel?.invokeMethod(
                                "onMessageResponse",
                                arguments: ["requestId": requestId, "token": token]
                            )
                        }
                    }
                }

                let end = DispatchTime.now().uptimeNanoseconds
                let timeToFirstToken = firstTokenTime.map {
                    Double($0 - requestStart) / 1_000_000.0
                } ?? -1.0
                let generationSeconds = max(
                    Double(end - prefillDone) / 1_000_000_000.0,
                    0.000_001
                )
                let tokensPerSecond = Double(generatedTokens) / generationSeconds
                let cacheStatus = promptStats.cacheHitTokens > 0 ? "hit" : "miss"
                let info = await context.runtimeInfo()
                self.debugPerformanceLog(
                    enabled: debugPerformance,
                    "[LlamaService][perf] ctx=\(info.nCtx) threads=\(info.nThreads)/\(info.nThreadsBatch) gpu=\(info.nGpuLayers) batch=\(info.nBatch)/\(info.nUbatch) promptTokens=\(promptStats.promptTokens) prefillMs=\(promptStats.prefillMilliseconds) ttftMs=\(timeToFirstToken) generationTps=\(tokensPerSecond) cache=\(cacheStatus) cacheTokens=\(promptStats.cacheHitTokens)"
                )
            } catch is CancellationError {
                await context.stop()
            } catch {
                generationError = "generation_failed"
                self.debugPerformanceLog(
                    enabled: debugPerformance,
                    "[LlamaService] Generation failed: \(error.localizedDescription)"
                )
            }

            let completion: [String: Any] = [
                "requestId": requestId,
                "error": generationError.map { $0 as Any } ?? NSNull()
            ]
            DispatchQueue.main.async {
                self.resultChannel?.invokeMethod(
                    "onMessageComplete",
                    arguments: completion
                )
            }
        }
    }

    private func int32Argument(
        _ args: [String: Any],
        _ key: String,
        default defaultValue: Int32
    ) -> Int32 {
        if let number = args[key] as? NSNumber {
            return number.int32Value
        }
        if let value = args[key] as? Int {
            return Int32(clamping: value)
        }
        return defaultValue
    }

    private func floatArgument(
        _ args: [String: Any],
        _ key: String,
        default defaultValue: Float
    ) -> Float {
        (args[key] as? NSNumber)?.floatValue ?? defaultValue
    }

    private func boolArgument(
        _ args: [String: Any],
        _ key: String,
        default defaultValue: Bool
    ) -> Bool {
        if let value = args[key] as? Bool {
            return value
        }
        return (args[key] as? NSNumber)?.boolValue ?? defaultValue
    }

    private func modelDetails(
        path: String,
        info: LlamaRuntimeInfo,
        reusedModel: Bool,
        capacitySatisfied: Bool
    ) -> [String: Any] {
        [
            "path": path,
            "nCtx": Int(info.nCtx),
            "nThreads": Int(info.nThreads),
            "nThreadsBatch": Int(info.nThreadsBatch),
            "nBatch": Int(info.nBatch),
            "nUbatch": Int(info.nUbatch),
            "nGpu": Int(info.nGpuLayers),
            "reusedModel": reusedModel,
            "capacitySatisfied": capacitySatisfied,
        ]
    }

    private func millisecondsSince(_ start: UInt64) -> Double {
        Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000.0
    }

    private func debugPerformanceLog(
        enabled: Bool,
        _ message: @autoclosure () -> String
    ) {
        #if DEBUG
        if enabled {
            print(message())
        }
        #endif
    }
}
