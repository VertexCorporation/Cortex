package com.vertex.cortex

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Environment
import android.os.StatFs
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    /* ────────────────  CONSTANTS  ──────────────── */
    private val STORAGE_CH = "com.vertex.cortex/storage"
    private val LLAMA_CH   = "com.vertex.cortex/llama"
    private val MEMORY_CH  = "com.vertex.cortex/memory"
    private val TAG        = "CortexMainActivity"

    /* ───────────    FLUTTER BRIDGE   ─────────── */
    @SuppressLint("ObsoleteSdkInt")   // Environment.getExternalStorageDirectory() is still OK for API < 30
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        /* ---- MEMORY CHANNEL ---- */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEMORY_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceMemory" -> result.success(getTotalRamMB())
                    "getUsedMemory"   -> result.success(getUsedRamMB())
                    else              -> result.notImplemented()
                }
            }

        /* ---- STORAGE CHANNEL ---- */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getFreeStorage"  -> result.success(getFreeStorageMB())
                    "getTotalStorage" -> result.success(getTotalStorageMB())
                    else              -> result.notImplemented()
                }
            }

        /* ---- LLAMA CHANNEL ---- */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LLAMA_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "cacheModel"    -> {
                        val path = call.argument<String>("path")
                        if (path.isNullOrBlank()) {
                            result.error("INVALID_PATH", "Model path is null or empty", null)
                            return@setMethodCallHandler
                        }
                        startLlamaService("cacheModel", "modelPath" to path)
                        result.success("Model loading started: $path")
                    }

                    "sendMessage"  -> {
                        val msg = call.argument<String>("message")

                        val photoPath = call.argument<String>("photoPath")

                        if (msg.isNullOrBlank()) {
                            result.error("INVALID_MSG", "Message is null or empty", null)
                            return@setMethodCallHandler
                        }

                        // Servisi başlatırken artık "photoPath" gönderiyoruz
                        startLlamaService("sendMessage", "message" to msg, "photoPath" to (photoPath ?: ""))
                        result.success("Message sent: $msg")
                    }

                    "stopGeneration" -> {
                        startLlamaService("stopGeneration")
                        result.success("Stop generation request sent.")
                    }

                    "releaseModel" -> {
                        startLlamaService("releaseModel")
                        result.success("Unload model request sent.")
                    }

                    "resetKv" -> {
                        startLlamaService("resetKv")
                        result.success("KV reset request sent.")
                    }

                    else -> result.notImplemented()
                }
            }
    }

    /* ─────────────   NATIVE HELPERS   ───────────── */

    /** Total RAM in **MB**. */
    private fun getTotalRamMB(): Long {
        val am       = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info     = ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        val totalMB  = info.totalMem / (1024L * 1024L)
        Log.d(TAG, "Total RAM  : $totalMB MB")
        return totalMB
    }

    /** Used RAM in **MB** (total - available). */
    private fun getUsedRamMB(): Long {
        val am       = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info     = ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        val usedMB   = (info.totalMem - info.availMem) / (1024L * 1024L)
        Log.d(TAG, "Used  RAM   : $usedMB MB")
        return usedMB
    }

    /** Free internal storage in **MB**. */
    private fun getFreeStorageMB(): Long {
        val stat     = StatFs(Environment.getExternalStorageDirectory().path)
        val freeMB   = stat.blockSizeLong * stat.availableBlocksLong / (1024L * 1024L)
        Log.d(TAG, "Free storage: $freeMB MB")
        return freeMB
    }

    /** Total internal storage in **MB**. */
    private fun getTotalStorageMB(): Long {
        val stat     = StatFs(Environment.getExternalStorageDirectory().path)
        val totalMB  = stat.blockSizeLong * stat.blockCountLong / (1024L * 1024L)
        Log.d(TAG, "Total storage: $totalMB MB")
        return totalMB
    }

    /** Helper to start / communicate with the background service. */
    private fun startLlamaService(action: String, vararg extras: Pair<String, String>) {
        val intent = Intent(this, LlamaService::class.java).apply {
            putExtra("action", action)
            extras.forEach { (k, v) -> putExtra(k, v) }
        }

        // This ensures the service can communicate back to Flutter. The previous implementation
        // created a new, unused service instance, which was a bug.
        LlamaService.setMethodChannel(
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, LLAMA_CH)
        )

        startService(intent)

        Log.d(TAG, "LlamaService started, action=$action extras=${extras.toMap()}")
    }
}