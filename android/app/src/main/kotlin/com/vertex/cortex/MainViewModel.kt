package com.vertex.cortex

import android.llama.cpp.LLamaAndroid
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.launch

class MainViewModel(private val llamaAndroid: LLamaAndroid = LLamaAndroid.instance) : ViewModel() {

    private val tag: String? = this::class.simpleName

    private var currentMessage: String = ""

    override fun onCleared() {
        super.onCleared()
        unload()
    }

    fun unload() {
        Log.d(tag, "ViewModel received unload command.")
        viewModelScope.launch {
            try {
                llamaAndroid.unload()
                Log.d(tag, "Model removed from memory.")
            } catch (exc: IllegalStateException) {
                Log.e(tag, "unload() was unsuccessful", exc)
            }
        }
    }

    fun clearKv() {
        viewModelScope.launch {
            try {
                llamaAndroid.clearKv()
                Log.d(tag, "KV cache cleared.")
            } catch (e: Exception) {
                Log.e(tag, "clearKv() failed", e)
            }
        }
    }

    fun stop() {
        Log.d(tag, "ViewModel received stop command.")
        viewModelScope.launch {
            try {
                llamaAndroid.requestStop()
            } catch (e: Throwable) {
                Log.e(tag, "Error stopping llama: ${e.message}")
            }
        }
    }

    fun updateMessage(newMessage: String) {
        currentMessage = newMessage
    }

    fun send(photoBase64: String?, temp: Float, topP: Float, topK: Int) {
        val text = currentMessage
        currentMessage = "" // Clear buffer

        viewModelScope.launch {
            if (photoBase64 != null && photoBase64.isNotEmpty()) {
                llamaAndroid.setImage(photoBase64)
            }

            try {
                
                llamaAndroid.send(
                    message = text,
                    temp = temp,
                    topP = topP,
                    topK = topK
                )
                    .catch { exception ->
                        Log.e(tag, "send() failed via Flow", exception)
                        LlamaService.sendCompletionToFlutter()
                    }
                    .collect { token ->
                        LlamaService.sendTokenToFlutter(token)
                    }

                LlamaService.sendCompletionToFlutter()

            } catch (e: Exception) {
                Log.e(tag, "General error in send() coroutine", e)
                LlamaService.sendCompletionToFlutter()
            }
        }
    }

    suspend fun load(pathToModel: String, nCtx: Int, nGpuLayers: Int, nThreads: Int) {
        try {
            llamaAndroid.load(pathToModel, nCtx, nGpuLayers, nThreads)
            Log.d(tag, "Loaded $pathToModel with nCtx=$nCtx")
        } catch (exc: IllegalStateException) {
            Log.e(tag, "load() failed", exc)
            throw exc
        }
    }
}