package com.vertex.cortex

import android.llama.cpp.LLamaAndroid
import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.launch

class MainViewModel(private val llamaAndroid: LLamaAndroid = LLamaAndroid.instance) : ViewModel() {

    companion object {
        @JvmStatic
        private val NanosPerSecond = 1_000_000_000.0
    }

    private val tag: String? = this::class.simpleName

    var messages by mutableStateOf(listOf("Initializing..."))
        private set

    var message by mutableStateOf("")
        private set

    override fun onCleared() {
        super.onCleared()
        unload()
    }

    fun unload() {
        Log.d(tag, "ViewModel received unload command.")
        viewModelScope.launch {
            try {
                llamaAndroid.unload()
                log("Model removed from the memory.")
            } catch (exc: IllegalStateException) {
                messages += exc.message!!
                Log.e(tag, "unload() was unsuccessful", exc)
            }
        }
    }

    fun clearKv() {
        viewModelScope.launch {
            try {
                llamaAndroid.clearKv()
                log("KV cache cleared.")
            } catch (e: Exception) {
                Log.e(tag, "clearKv() failed", e)
            }
        }
    }

    fun stop() {
        Log.d(tag, "ViewModel received stop command.")
        viewModelScope.launch {
            llamaAndroid.requestStop()
        }
    }

    fun send(photoBase64: String?) {
        val text = message
        message = ""

        messages += text
        messages += ""

        viewModelScope.launch {
            if (photoBase64 != null && photoBase64.isNotEmpty()) {
                llamaAndroid.setImage(photoBase64)
            }
            try {
                llamaAndroid.send(message = text)
                    .catch { exception ->
                        Log.e(tag, "send() failed", exception)
                        if (LlamaService.isChannelInitialized) {
                            val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
                            mainHandler.post {
                                LlamaService.resultChannel.invokeMethod("onMessageComplete", null)
                            }
                        }
                        messages += exception.message!!
                    }
                    .collect { token ->
                        if (LlamaService.isChannelInitialized) {
                            val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
                            mainHandler.post {
                                LlamaService.resultChannel.invokeMethod("onMessageResponse", token)
                            }
                        }
                        messages = messages.dropLast(1) + (messages.last() + token)
                    }

                if (LlamaService.isChannelInitialized) {
                    val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
                    mainHandler.post {
                        LlamaService.resultChannel.invokeMethod("onMessageComplete", null)
                    }
                }

            } catch (e: Exception) {
                Log.e(tag, "send coroutine içinde hata", e)
                if (LlamaService.isChannelInitialized) {
                    val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
                    mainHandler.post {
                        LlamaService.resultChannel.invokeMethod("onMessageComplete", null)
                    }
                }
            }
        }
    }

    /*
    fun bench(pp: Int, tg: Int, pl: Int, nr: Int = 1) {
        viewModelScope.launch {
            try {
                val start = System.nanoTime()
                val warmupResult = llamaAndroid.bench(pp, tg, pl, nr)
                val end = System.nanoTime()

                messages += warmupResult

                val warmup = (end - start).toDouble() / NanosPerSecond
                messages += "Warm up time: $warmup seconds, please wait..."

                if (warmup > 5.0) {
                    messages += "Warm up took too long, aborting benchmark"
                    return@launch
                }

                messages += llamaAndroid.bench(512, 128, 1, 3)
            } catch (exc: IllegalStateException) {
                Log.e(tag, "bench() failed", exc)
                messages += exc.message!!
            }
        }
    }
    */

    fun load(pathToModel: String) {
        viewModelScope.launch {
            try {
                llamaAndroid.load(pathToModel)
                messages += "Loaded $pathToModel"
            } catch (exc: IllegalStateException) {
                Log.e(tag, "load() failed", exc)
                messages += exc.message!!
            }
        }
    }

    fun updateMessage(newMessage: String) {
        message = newMessage
    }

    fun clear() {
        messages = listOf()
    }

    fun log(message: String) {
        messages += message
    }
}