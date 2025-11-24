package com.vertex.cortex

import android.app.Service
import android.content.Intent
import android.os.IBinder
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

        // Static function to be called by JNI
        @JvmStatic
        fun sendTokenToFlutter(token: String) {
            if (isChannelInitialized) {
                val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
                mainHandler.post {
                    resultChannel.invokeMethod("onMessageResponse", token)
                }
            } else {
                Log.e("LlamaService", "MethodChannel not initialized.")
            }
        }

        // This allows MainActivity to set the channel correctly on the service's static properties
        // before the service instance, which will use these properties, is started.
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
        intent?.let { val action = it.getStringExtra("action")
            when (action) {
                "cacheModel" -> {
                    val path = it.getStringExtra("modelPath")
                    path?.let { cacheModel(it) }
                }
                "sendMessage" -> {
                    val message = it.getStringExtra("message") ?: ""
                    val photoPath = it.getStringExtra("photoPath")
                    sendMessage(message, photoPath)
                }
                "stopGeneration" -> {
                    stopGeneration()
                }
                "releaseModel" -> {
                    releaseModel()
                }
                "resetKv" -> {
                    resetKv()
                }
                else -> {
                    Log.w("LlamaService", "Unknown action received: $action")
                }
            }
        }
        return START_STICKY
    }

    fun cacheModel(path: String) {
        serviceScope.launch {
            withContext(Dispatchers.IO) {
                viewModel.load(path)
            }
            if (isChannelInitialized) {
                resultChannel.invokeMethod("onModelLoaded", "Model loaded successfully: $path")
            } else {
                Log.e("LlamaService", "MethodChannel not initialized.")
            }
        }
    }

    private fun stopGeneration() {
        Log.d("LlamaService", "Executing stopGeneration.")
        viewModel.stop()
    }

    private fun releaseModel() {
        Log.d("LlamaService", "Executing unloadModel.")
        serviceScope.launch {
            viewModel.unload()
        }
    }

    private fun resetKv() {
        Log.d("LlamaService", "Executing resetKv (clear KV cache).")
        serviceScope.launch {
            try {
                viewModel.clearKv()
            } catch (e: Exception) {
                Log.e("LlamaService", "resetKv failed", e)
            }
        }
    }

    fun sendMessage(message: String?, photoPath: String?) {
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