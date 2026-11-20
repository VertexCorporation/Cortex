import AVFoundation
import UIKit
import Flutter
import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var previousVoiceAudioConfiguration: (
        category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    )?

    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

        LlamaService.register(with: controller.pluginRegistry().registrar(forPlugin: "LlamaService")!)

        FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

        // MEMORY CHANNEL
        let memoryChannel = FlutterMethodChannel(name: "com.vertex.cortex/memory",
            binaryMessenger: controller.binaryMessenger)
        memoryChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "getDeviceMemory" {
                result(self.getTotalRAMInMB())
            } else if call.method == "getUsedMemory" {
                result(self.getUsedRAMInMB())
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // STORAGE CHANNEL
        let storageChannel = FlutterMethodChannel(name: "com.vertex.cortex/storage",
            binaryMessenger: controller.binaryMessenger)
        storageChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "getFreeStorage" {
                result(self.getFreeDiskSpaceInMB())
            } else if call.method == "getTotalStorage" {
                result(self.getTotalDiskSpaceInMB())
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        let voiceAudioChannel = FlutterMethodChannel(name: "com.vertex.cortex/voice_audio",
            binaryMessenger: controller.binaryMessenger)
        voiceAudioChannel.setMethodCallHandler { [weak self] call, result in
            self?.handleVoiceAudio(call, result: result)
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func handleVoiceAudio(_ call: FlutterMethodCall, result: FlutterResult) {
        let session = AVAudioSession.sharedInstance()
        do {
            switch call.method {
            case "activate":
                if previousVoiceAudioConfiguration == nil {
                    previousVoiceAudioConfiguration = (session.category, session.mode, session.categoryOptions)
                }
                let options: AVAudioSession.CategoryOptions = [
                    .mixWithOthers, .defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP
                ]
                if session.category != .playAndRecord || session.mode != .voiceChat
                    || session.categoryOptions != options {
                    try session.setCategory(.playAndRecord, mode: .voiceChat, options: options)
                }
                try session.setActive(true)
            case "deactivate":
                if let previous = previousVoiceAudioConfiguration {
                    var releaseError: Error?
                    do {
                        try session.setActive(false, options: .notifyOthersOnDeactivation)
                    } catch {
                        releaseError = error
                    }
                    do {
                        try session.setCategory(previous.category, mode: previous.mode, options: previous.options)
                    } catch {
                        if releaseError == nil {
                            releaseError = error
                        }
                    }
                    if let releaseError = releaseError {
                        throw releaseError
                    }
                    previousVoiceAudioConfiguration = nil
                }
            default:
                result(FlutterMethodNotImplemented)
                return
            }
            result(nil)
        } catch {
            result(FlutterError(code: "voice_audio_session", message: error.localizedDescription, details: nil))
        }
    }

    private func getTotalRAMInMB() -> Int {
        return Int(ProcessInfo.processInfo.physicalMemory / (1024 * 1024))
    }

    private func getUsedRAMInMB() -> Int {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Int(taskInfo.resident_size / (1024 * 1024))
        } else {
            return 0
        }
    }

    private func getTotalDiskSpaceInMB() -> Int {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            if let space = systemAttributes[FileAttributeKey.systemSize] as? NSNumber {
                return Int(space.int64Value / (1024 * 1024))
            }
        } catch {
            return 0
        }
        return 0
    }

    private func getFreeDiskSpaceInMB() -> Int {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            if let space = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                return Int(space.int64Value / (1024 * 1024))
            }
        } catch {
            return 0
        }
        return 0
    }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("vn.hunghd.flutterdownloader.FlutterDownloaderPlugin")) {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "vn.hunghd.flutterdownloader.FlutterDownloaderPlugin")!)
    }
}
