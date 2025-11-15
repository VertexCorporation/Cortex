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
                    val photoBase64 = it.getStringExtra("photoBase64")
                    sendMessage(message, photoBase64)
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
            viewModel.load(path)
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

    fun sendMessage(message: String?, photoBase64: String?) {
        val safeMessage = message ?: ""
        serviceScope.launch {
            viewModel.updateMessage(safeMessage)
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