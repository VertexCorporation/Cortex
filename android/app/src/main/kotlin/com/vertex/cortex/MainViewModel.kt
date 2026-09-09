package com.vertex.cortex

import android.llama.cpp.LLamaAndroid
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.launch

class MainViewModel(private val llamaAndroid: LLamaAndroid = LLamaAndroid.instance) : ViewModel() {

    private val tag: String? = this::class.simpleName

    private var generationJob: Job? = null

    override fun onCleared() {
        super.onCleared()
        viewModelScope.launch { unload() }
    }

    suspend fun unload() {
        Log.d(tag, "ViewModel received unload command.")
        try {
            llamaAndroid.unload()
            Log.d(tag, "Model removed from memory.")
        } catch (exc: IllegalStateException) {
            Log.e(tag, "unload() was unsuccessful", exc)
        }
    }

    suspend fun clearKv() {
        try {
            llamaAndroid.clearKv()
            Log.d(tag, "KV cache cleared.")
        } catch (e: Exception) {
            Log.e(tag, "clearKv() failed", e)
        }
    }

    fun stop() {
        Log.d(tag, "ViewModel received stop command.")
        llamaAndroid.requestStop()
        generationJob?.cancel()
    }

    fun send(
        requestId: String,
        text: String,
        photoBase64: String?,
        temp: Float,
        topP: Float,
        topK: Int,
        repeatPenalty: Float = 1.0f,
        frequencyPenalty: Float = 0.0f,
        presencePenalty: Float = 0.0f,
        mirostatMode: Int = 0,
        mirostatTau: Float = 5.0f,
        mirostatEta: Float = 0.1f,
        debugPerf: Boolean = false
    ) {
        val previous = generationJob
        llamaAndroid.requestStop()
        generationJob = viewModelScope.launch {
            var error: String? = null
            try {
                previous?.cancelAndJoin()
                if (!photoBase64.isNullOrEmpty()) llamaAndroid.setImage(photoBase64)
                llamaAndroid.send(
                    message = text,
                    temp = temp,
                    topP = topP,
                    topK = topK,
                    repeatPenalty = repeatPenalty,
                    frequencyPenalty = frequencyPenalty,
                    presencePenalty = presencePenalty,
                    mirostatMode = mirostatMode,
                    mirostatTau = mirostatTau,
                    mirostatEta = mirostatEta,
                    debugPerf = debugPerf
                )
                    .collect { token ->
                        LlamaService.sendTokenToFlutter(requestId, token)
                    }
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                Log.e(tag, "General error in send() coroutine", e)
                error = "generation_failed"
            } finally {
                LlamaService.sendCompletionToFlutter(requestId, error)
            }
        }
    }

    suspend fun load(
        pathToModel: String,
        nCtx: Int,
        nGpuLayers: Int,
        nThreads: Int,
        nThreadsBatch: Int,
        nBatch: Int,
        nUbatch: Int,
        debugPerf: Boolean
    ): LLamaAndroid.LoadResult {
        try {
            return llamaAndroid.load(
                pathToModel,
                nCtx,
                nGpuLayers,
                nThreads,
                nThreadsBatch,
                nBatch,
                nUbatch,
                debugPerf
            )
        } catch (exc: IllegalStateException) {
            Log.e(tag, "load() failed", exc)
            throw exc
        }
    }
}
