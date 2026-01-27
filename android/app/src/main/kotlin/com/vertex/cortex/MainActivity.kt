package com.vertex.cortex

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Environment
import android.os.StatFs
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.os.Bundle
import androidx.core.view.WindowCompat

import androidx.activity.enableEdgeToEdge // [NEW]

class MainActivity : FlutterFragmentActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge() // [NEW] - Android 15 standard
        super.onCreate(savedInstanceState)
    }

    /* ────────────────  CONSTANTS  ──────────────── */
    private val STORAGE_CH = "com.vertex.cortex/storage"
    private val LLAMA_CH   = "com.vertex.cortex/llama"
    private val MEMORY_CH  = "com.vertex.cortex/memory"
    private val TAG        = "CortexMainActivity"

    /* ───────────    FLUTTER BRIDGE   ─────────── */
    @SuppressLint("ObsoleteSdkInt")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        LlamaService.setMethodChannel(MethodChannel(messenger, LLAMA_CH))

        /* ---- MEMORY CHANNEL ---- */
        MethodChannel(messenger, MEMORY_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceMemory" -> result.success(getTotalRamMB())
                    "getUsedMemory"   -> result.success(getUsedRamMB())
                    else              -> result.notImplemented()
                }
            }

        /* ---- STORAGE CHANNEL ---- */
        MethodChannel(messenger, STORAGE_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getFreeStorage"  -> result.success(getFreeStorageMB())
                    "getTotalStorage" -> result.success(getTotalStorageMB())
                    else              -> result.notImplemented()
                }
            }

        /* ---- LLAMA CHANNEL ---- */
        MethodChannel(messenger, LLAMA_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "cacheModel"    -> {
                        val path = call.argument<String>("path")
                        val nCtx = call.argument<Int>("nCtx") ?: 2048
                        val nGpu = call.argument<Int>("nGpu") ?: 0
                        val nThreads = call.argument<Int>("nThreads") ?: 4

                        if (path.isNullOrBlank()) {
                            result.error("INVALID_PATH", "Model path is null or empty", null)
                            return@setMethodCallHandler
                        }
                        
                        val intent = Intent(this, LlamaService::class.java).apply {
                            putExtra("action", "cacheModel")
                            putExtra("modelPath", path)
                            putExtra("nCtx", nCtx)
                            putExtra("nGpu", nGpu)
                            putExtra("nThreads", nThreads)
                        }
                        startServiceSafe(intent)
                        
                        result.success("Model loading started: $path")
                    }

                    "sendMessage"  -> {
                        val msg = call.argument<String>("message")
                        val photoPath = call.argument<String>("photoPath")
                        // Flutter passes doubles for floats
                        val temp = call.argument<Double>("temp")?.toFloat() ?: 0.7f
                        val topP = call.argument<Double>("topP")?.toFloat() ?: 0.95f
                        val topK = call.argument<Int>("topK") ?: 40

                        if (msg.isNullOrBlank()) {
                            result.error("INVALID_MSG", "Message is null or empty", null)
                            return@setMethodCallHandler
                        }

                        val intent = Intent(this, LlamaService::class.java).apply {
                            putExtra("action", "sendMessage")
                            putExtra("message", msg)
                            putExtra("photoPath", photoPath ?: "")
                            putExtra("temp", temp)
                            putExtra("topP", topP)
                            putExtra("topK", topK)
                        }
                        startServiceSafe(intent)
                        
                        result.success("Message sent: $msg")
                    }

                    "stopGeneration" -> {
                        startServiceSafe(Intent(this, LlamaService::class.java).apply {
                            putExtra("action", "stopGeneration")
                        })
                        result.success("Stop generation request sent.")
                    }

                    "releaseModel" -> {
                        startServiceSafe(Intent(this, LlamaService::class.java).apply {
                            putExtra("action", "releaseModel")
                        })
                        result.success("Unload model request sent.")
                    }

                    "resetKv" -> {
                         startServiceSafe(Intent(this, LlamaService::class.java).apply {
                            putExtra("action", "resetKv")
                        })
                        result.success("KV reset request sent.")
                    }

                    else -> result.notImplemented()
                }
            }
    }

    /* ─────────────   AIRBAG   ───────────── */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        try {
            super.onActivityResult(requestCode, resultCode, data)
        } catch (e: Exception) {
            Log.e(TAG, "FATAL ERROR CAUGHT IN onActivityResult: ${e.message}")
        }
    }

    /* ─────────────   NATIVE HELPERS   ───────────── */

    /** Total RAM in **MB**. */
    private fun getTotalRamMB(): Long {
        val am       = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info     = ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        return info.totalMem / (1024L * 1024L)
    }

    /** Used RAM in **MB** (total - available). */
    private fun getUsedRamMB(): Long {
        val am       = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val info     = ActivityManager.MemoryInfo()
        am.getMemoryInfo(info)
        return (info.totalMem - info.availMem) / (1024L * 1024L)
    }

    /** Free internal storage in **MB**. */
    private fun getFreeStorageMB(): Long {
        val stat     = StatFs(Environment.getExternalStorageDirectory().path)
        return stat.blockSizeLong * stat.availableBlocksLong / (1024L * 1024L)
    }

    /** Total internal storage in **MB**. */
    private fun getTotalStorageMB(): Long {
        val stat     = StatFs(Environment.getExternalStorageDirectory().path)
        return stat.blockSizeLong * stat.blockCountLong / (1024L * 1024L)
    }

    /** Helper to start the background service safely. */
    private fun startServiceSafe(intent: Intent) {
        try {
            startService(intent)
        } catch (e: IllegalStateException) {
            Log.w(TAG, "⚠️ App is in background, service start ignored.")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start LlamaService: ${e.message}")
        }
    }
}