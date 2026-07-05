// LLamaAndroid.kt

package android.llama.cpp

import android.util.Log
import android.util.Base64
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.withContext
import java.util.concurrent.Executors
import java.io.File
import kotlin.concurrent.thread

/**
 * Manages the legacy llama.cpp JNI interface using modern Kotlin features.
 * Now supports configurable context size, GPU offloading, and standard sampling parameters.
 */
class LLamaAndroid {
    private val tag: String? = this::class.simpleName

    private val runLoop: CoroutineDispatcher = Executors.newSingleThreadExecutor {
        thread(start = false, name = "Llm-RunLoop") {
            Log.d(tag, "Dedicated thread for native code: ${Thread.currentThread().name}")
            System.loadLibrary("llama-android")
            log_to_android()
            backend_init()
            Log.d(tag, system_info())
            it.run()
        }.apply {
            uncaughtExceptionHandler = Thread.UncaughtExceptionHandler { _, exception: Throwable ->
                Log.e(tag, "Unhandled exception on native thread!", exception)
            }
        }
    }.asCoroutineDispatcher()

    private val threadLocalState: ThreadLocal<State> = ThreadLocal.withInitial { State.Idle }

    // Using the legacy JNI function declarations you provided
    private external fun log_to_android()

    // UPDATED: Now accepts nGpuLayers for GPU offloading
    private external fun load_model(filename: String, nGpuLayers: Int): Long
    private external fun free_model(model: Long)
    // UPDATED: Now accepts nCtx and nThreads for dynamic configuration
    private external fun new_context(model: Long, nCtx: Int, nThreads: Int): Long
    private external fun free_context(context: Long)
    private external fun backend_init()
    private external fun backend_free()
    private external fun system_info(): String
    private external fun completion_init(context: Long, batch: Long, text: String, formatChat: Boolean, nLen: Int): Int
    private external fun completion_loop(context: Long, batch: Long, sampler: Long, nLen: Int, ncur: IntVar): String?
    private external fun kv_cache_clear(context: Long)
    private external fun new_batch(nTokens: Int, embd: Int, nSeqMax: Int): Long
    private external fun free_batch(batch: Long)
    private external fun new_sampler(temp: Float, topP: Float, topK: Int, repeatPenalty: Float, frequencyPenalty: Float, presencePenalty: Float, mirostatMode: Int, mirostatTau: Float, mirostatEta: Float): Long
    private external fun free_sampler(sampler: Long)
    private external fun request_stop()
    private external fun set_image(bytes: ByteArray)

    // NEW: Load with explicit configuration
    suspend fun load(
        pathToModel: String, 
        nCtx: Int = 2048, 
        nGpuLayers: Int = 0,
        nThreads: Int = 4
    ) {
        withContext(runLoop) {
            when (threadLocalState.get()) {
                is State.Idle -> {
                    Log.i(tag, "Loading model: $pathToModel with ctx=$nCtx, gpu=$nGpuLayers, threads=$nThreads")
                    
                    // NOW PASSING nGpuLayers to enable GPU offloading!
                    val model = load_model(pathToModel, nGpuLayers)
                    if (model == 0L) throw IllegalStateException("load_model() failed")

                    // NOW PASSING nCtx and nThreads for dynamic configuration!
                    val context = new_context(model, nCtx, nThreads)
                    if (context == 0L) throw IllegalStateException("new_context() failed")

                    // Batch size matches context size for full context processing
                    val batch = new_batch(nCtx, 0, 1)
                    if (batch == 0L) throw IllegalStateException("new_batch() failed")

                    // Default sampler placeholder (will be overwritten per-message)
                    val sampler = new_sampler(0.7f, 0.95f, 40, 1.0f, 0.0f, 0.0f, 0, 0.0f, 0.0f)
                    if (sampler == 0L) throw IllegalStateException("new_sampler() failed")

                    threadLocalState.set(State.Loaded(model, context, batch, sampler, nCtx))
                }
                else -> Log.w(tag, "Model already loaded.")
            }
        }
    }

    fun setImage(base64: String) {
        if (base64.isBlank()) return
        val bytes = Base64.decode(base64, Base64.DEFAULT)
        set_image(bytes)
    }

    fun requestStop() {
        request_stop()
    }

    fun clearKv() {
        val state = threadLocalState.get()
        if (state is State.Loaded) {
            kv_cache_clear(state.context)
            Log.d(tag, "KV cache cleared.")
        }
    }

    // NEW: Send with explicit Sampler params (with repetition penalty + mirostat support)
    fun send(
        message: String,
        temp: Float,
        topP: Float,
        topK: Int,
        repeatPenalty: Float = 1.0f,
        frequencyPenalty: Float = 0.0f,
        presencePenalty: Float = 0.0f,
        mirostatMode: Int = 0,
        mirostatTau: Float = 5.0f,
        mirostatEta: Float = 0.1f
    ): Flow<String> = flow {
        when (val state = threadLocalState.get()) {
            is State.Loaded -> {
                try {
                    // Re-create sampler with request params
                    free_sampler(state.sampler)
                    val newSampler = new_sampler(temp, topP, topK, repeatPenalty, frequencyPenalty, presencePenalty, mirostatMode, mirostatTau, mirostatEta)
                    val updatedState = state.copy(sampler = newSampler)
                    threadLocalState.set(updatedState)

                    val nlen = state.nCtx

                    val ncur = IntVar(
                        completion_init(
                            state.context,
                            state.batch,
                            message,
                            true,
                            nlen
                        )
                    )

                    while (ncur.value < nlen) {
                        val str = completion_loop(
                            state.context,
                            state.batch,
                            newSampler,
                            nlen,
                            ncur
                        )
                        if (str == null) break
                        if (str.isNotEmpty()) emit(str)
                    }
                } finally {
                    // Don't clear KV cache on exit — keep context between messages
                    // for prompt caching benefits. Only explicit resetKv() clears it.
                }
            }
            else -> Log.e(tag, "send() called but model is not loaded.")
        }
    }.flowOn(runLoop)

    suspend fun unload() {
        withContext(runLoop) {
            when (val state = threadLocalState.get()) {
                is State.Loaded -> {
                    free_context(state.context)
                    free_model(state.model)
                    free_batch(state.batch)
                    free_sampler(state.sampler);
                    threadLocalState.set(State.Idle)
                }
                else -> {}
            }
        }
    }

    companion object {
        class IntVar(value: Int) {
            @Volatile
            var value: Int = value
                private set
            fun inc() { synchronized(this) { value += 1 } }
        }

        private sealed interface State {
            object Idle: State
            data class Loaded(
                val model: Long, 
                val context: Long, 
                val batch: Long, 
                val sampler: Long,
                val nCtx: Int
            ): State
        }

        @get:JvmStatic
        val instance: LLamaAndroid = LLamaAndroid()
    }
}