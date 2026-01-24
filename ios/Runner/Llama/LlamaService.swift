import Flutter
import Foundation

class LlamaService: NSObject, FlutterPlugin {
    private var llamaContext: LlamaContext?
    private var resultChannel: FlutterMethodChannel?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.vertex.cortex/llama", binaryMessenger: registrar.messenger())
        let instance = LlamaService()
        instance.resultChannel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "cacheModel":
            guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Path is required", details: nil))
                return
            }
            
            // Extract dynamic parameters from Dart
            let nCtx = args["nCtx"] as? Int32 ?? 2048
            let nThreads = args["nThreads"] as? Int32 ?? 4

            Task {
                do {
                    if let context = self.llamaContext {
                        await context.stop()
                        self.llamaContext = nil
                    }

                    // Pass dynamic parameters to context creation
                    self.llamaContext = try LlamaContext.create_context(path: path, nCtx: nCtx, nThreads: nThreads)

                    DispatchQueue.main.async {
                        self.resultChannel?.invokeMethod("onModelLoaded", arguments: nil)
                        result(nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.resultChannel?.invokeMethod("onModelLoadFailed", arguments: error.localizedDescription)
                        result(FlutterError(code: "LOAD_FAILED", message: "Failed to load model", details: nil))
                    }
                }
            }

        case "sendMessage":
            guard let args = call.arguments as? [String: Any],
            let message = args["message"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Message is required", details: nil))
                return
            }

            let photoPath = args["photoPath"] as? String
            
            // Extract sampler parameters from Dart (use defaults if not provided)
            let temp = args["temp"] as? Float ?? 0.7
            let topP = args["topP"] as? Float ?? 0.9
            let topK = args["topK"] as? Int32 ?? 40

            guard let context = self.llamaContext else {
                result(FlutterError(code: "NO_MODEL", message: "Model not loaded", details: nil))
                return
            }

            result(nil)

            Task {
                await context.clear()
                
                // Update sampler with Dart-provided parameters
                await context.updateSampler(temp: temp, topP: topP, topK: topK)

                if let photo = photoPath, !photo.isEmpty {
                     print("[LlamaService] Warning: Photo provided but iOS Vision support is currently implementation-pending.")
                }

                await context.completion_init(text: message)

                while await !context.is_done {
                    if let token = await context.completion_loop() {
                        if !token.isEmpty {
                            DispatchQueue.main.async {
                                self.resultChannel?.invokeMethod("onMessageResponse", arguments: token)
                            }
                        }
                    } else {
                        break
                    }
                }

                await context.clear()

                DispatchQueue.main.async {
                    self.resultChannel?.invokeMethod("onMessageComplete", arguments: nil)
                }
            }

        case "stopGeneration":
            Task {
                await self.llamaContext?.stop()
                result(nil)
            }

        case "releaseModel":
            Task {
                self.llamaContext = nil
                result(nil)
            }

        case "resetKv":
            Task {
                await self.llamaContext?.clear()
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}