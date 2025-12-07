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
            llamaAndroid.requestStop()
        }
    }

    fun updateMessage(newMessage: String) {
        currentMessage = newMessage
    }

    fun send(photoBase64: String?) {
        val text = currentMessage
        currentMessage = "" // Tamponu temizle

        viewModelScope.launch {
            if (photoBase64 != null && photoBase64.isNotEmpty()) {
                llamaAndroid.setImage(photoBase64)
            }

            try {
                llamaAndroid.send(message = text)
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

    fun load(pathToModel: String) {
        viewModelScope.launch {
            try {
                llamaAndroid.load(pathToModel)
                Log.d(tag, "Loaded $pathToModel")
            } catch (exc: IllegalStateException) {
                Log.e(tag, "load() failed", exc)
            }
        }
    }
}