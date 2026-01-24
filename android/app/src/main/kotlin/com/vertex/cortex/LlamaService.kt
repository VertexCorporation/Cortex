package com.vertex.cortex

import android.app.Service
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class LlamaService : Service() {

    companion object {
        lateinit var resultChannel: MethodChannel
        var isChannelInitialized = false

        private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

        @JvmStatic
        fun sendTokenToFlutter(token: String) {
            if (isChannelInitialized) {
                mainHandler.post {
                    try {
                        resultChannel.invokeMethod("onMessageResponse", token)
                    } catch (e: Exception) {
                        Log.e("LlamaService", "Error sending token to Flutter: ${e.message}")
                    }
                }
            }
        }

        @JvmStatic
        fun sendCompletionToFlutter() {
            if (isChannelInitialized) {
                mainHandler.post {
                    try {
                        resultChannel.invokeMethod("onMessageComplete", null)
                    } catch (e: Exception) {
                        Log.e("LlamaService", "Error sending completion to Flutter: ${e.message}")
                    }
                }
            }
        }

        @JvmStatic
        fun sendModelLoadedToFlutter(path: String) {
            if (isChannelInitialized) {
                mainHandler.post {
                    resultChannel.invokeMethod("onModelLoaded", "Model loaded: $path")
                }
            }
        }

        @JvmStatic
        fun sendModelLoadFailedToFlutter(error: String) {
            if (isChannelInitialized) {
                mainHandler.post {
                    resultChannel.invokeMethod("onModelLoadFailed", error)
                }
            }
        }

        fun setMethodChannel(channel: MethodChannel) {
            resultChannel = channel
            isChannelInitialized = true
            Log.d("LlamaService", "MethodChannel initialized")
        }
    }

    private lateinit var viewModel: MainViewModel
    private val serviceScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onCreate() {
        super.onCreate()
        viewModel = MainViewModel()
        Log.d("LlamaService", "Service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            val action = it.getStringExtra("action")
            when (action) {
                "cacheModel" -> {
                    val path = it.getStringExtra("modelPath")
                    val nCtx = it.getIntExtra("nCtx", 2048)
                    val nGpu = it.getIntExtra("nGpu", 0)
                    val nThreads = it.getIntExtra("nThreads", 4)
                    
                    path?.let { p -> cacheModel(p, nCtx, nGpu, nThreads) }
                }
                "sendMessage" -> {
                    val message = it.getStringExtra("message") ?: ""
                    val photoPath = it.getStringExtra("photoPath")
                    
                    val temp = it.getFloatExtra("temp", 0.7f)
                    val topP = it.getFloatExtra("topP", 0.95f)
                    val topK = it.getIntExtra("topK", 40)
                    
                    sendMessage(message, photoPath, temp, topP, topK)
                }
                "stopGeneration" -> stopGeneration()
                "releaseModel" -> releaseModel()
                "resetKv" -> resetKv()
                else -> Log.w("LlamaService", "Unknown action received: $action")
            }
        }
        return START_STICKY
    }

    private fun cacheModel(path: String, nCtx: Int, nGpu: Int, nThreads: Int) {
        serviceScope.launch {
            withContext(Dispatchers.IO) {
                viewModel.load(path, nCtx, nGpu, nThreads)
            }
            sendModelLoadedToFlutter(path)
        }
    }

    private fun stopGeneration() {
        viewModel.stop()
    }

    private fun releaseModel() {
        serviceScope.launch {
            viewModel.unload()
        }
    }

    private fun resetKv() {
        serviceScope.launch {
            try {
                viewModel.clearKv()
            } catch (e: Exception) {
                Log.e("LlamaService", "resetKv failed", e)
            }
        }
    }

    private fun sendMessage(
        message: String?, 
        photoPath: String?,
        temp: Float,
        topP: Float,
        topK: Int
    ) {
        val safeMessage = message ?: ""
        serviceScope.launch {
            viewModel.updateMessage(safeMessage)

            var photoBase64: String? = null

            if (!photoPath.isNullOrBlank()) {
                photoBase64 = withContext(Dispatchers.IO) {
                    try {
                        val file = java.io.File(photoPath)
                        if (file.exists()) {
                            val bytes = file.readBytes()
                            android.util.Base64.encodeToString(bytes, android.util.Base64.NO_WRAP)
                        } else {
                            null
                        }
                    } catch (e: Exception) {
                        Log.e("LlamaService", "Error reading image file: $e")
                        null
                    }
                }
            }
            // Trigger the generation
            viewModel.send(photoBase64, temp, topP, topK)
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
    }
}