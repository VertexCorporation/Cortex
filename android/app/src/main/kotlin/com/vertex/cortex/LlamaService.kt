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

        // OPTIMIZATION: Created a single Handler instance.
        // Previously, a new Handler was created for every single token, causing GC Trashing.
        private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

        // Static function to be called by ViewModel
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
                    path?.let { p -> cacheModel(p) }
                }
                "sendMessage" -> {
                    val message = it.getStringExtra("message") ?: ""
                    val photoPath = it.getStringExtra("photoPath")
                    sendMessage(message, photoPath)
                }
                "stopGeneration" -> stopGeneration()
                "releaseModel" -> releaseModel()
                "resetKv" -> resetKv()
                else -> Log.w("LlamaService", "Unknown action received: $action")
            }
        }
        return START_STICKY
    }

    private fun cacheModel(path: String) {
        serviceScope.launch {
            withContext(Dispatchers.IO) {
                viewModel.load(path)
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

    private fun sendMessage(message: String?, photoPath: String?) {
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
            viewModel.send(photoBase64)
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