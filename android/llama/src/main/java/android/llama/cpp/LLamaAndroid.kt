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
 * This class is designed to work with the completion_init/completion_loop architecture.
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
    private external fun load_model(filename: String): Long
    private external fun free_model(model: Long)
    private external fun new_context(model: Long): Long
    private external fun free_context(context: Long)
    private external fun backend_init()
    private external fun backend_free()
    private external fun system_info(): String
    private external fun completion_init(context: Long, batch: Long, text: String, formatChat: Boolean, nLen: Int): Int
    private external fun completion_loop(context: Long, batch: Long, sampler: Long, nLen: Int, ncur: IntVar): String?
    private external fun kv_cache_clear(context: Long)
    // Benchmarking and other functions from your code
    private external fun new_batch(nTokens: Int, embd: Int, nSeqMax: Int): Long
    private external fun free_batch(batch: Long)
    private external fun new_sampler(temp: Float, topP: Float, topK: Int): Long
    private external fun free_sampler(sampler: Long)
    private external fun request_stop()
    private external fun set_image(bytes: ByteArray)

    private fun computeSamplerParams(pathToModel: String): Triple<Float, Float, Int> {
        return try {
            val file = File(pathToModel)
            if (!file.exists()) {
                Log.w(tag, "Model file does not exist for sampler computation. Falling back to greedy.")
                Triple(0.0f, 0.0f, 0)
            } else {
                val sizeMb = (file.length() / (1024L * 1024L)).toInt()
                Log.d(tag, "Model size for sampler ≈ $sizeMb MB")

                when {
                    sizeMb <= 1000 -> {
                        Triple(0.3f, 0.85f, 30)
                    }
                    sizeMb <= 5000 -> {
                        Triple(0.5f, 0.90f, 40)
                    }
                    sizeMb <= 9000 -> {
                        Triple(0.7f, 0.92f, 50)
                    }
                    else -> {
                        Triple(0.9f, 0.95f, 60)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(tag, "Failed to compute sampler params. Falling back to greedy.", e)
            Triple(0.0f, 0.0f, 0)
        }
    }

    suspend fun load(pathToModel: String) {
        withContext(runLoop) {
            when (threadLocalState.get()) {
                is State.Idle -> {
                    val model = load_model(pathToModel)
                    if (model == 0L) throw IllegalStateException("load_model() failed")

                    val context = new_context(model)
                    if (context == 0L) throw IllegalStateException("new_context() failed")

                    val batch = new_batch(2048, 0, 1)
                    if (batch == 0L) throw IllegalStateException("new_batch() failed")

                    val (temp, topP, topK) = computeSamplerParams(pathToModel)

                    val sampler = new_sampler(
                        temp,
                        topP,
                        topK
                    )
                    if (sampler == 0L) throw IllegalStateException("new_sampler() failed")

                    Log.i(tag, "Loaded model $pathToModel with sampler: temp=$temp, topP=$topP, topK=$topK")
                    threadLocalState.set(State.Loaded(model, context, batch, sampler))
                }
                else -> Log.w(tag, "Model already loaded.")
            }
        }
    }

    fun setImage(base64: String) {
        if (base64.isBlank()) {
            Log.w(tag, "setImage() called with blank base64, ignoring.")
            return
        }
        val bytes = Base64.decode(base64, Base64.DEFAULT)
        set_image(bytes)
        Log.d(tag, "setImage() successfully forwarded ${bytes.size} bytes to native side.")
    }

    // This is NOT a suspend function and does not need the runLoop
    // as it calls a simple, thread-safe native method.
    fun requestStop() {
        Log.d(tag, "Requesting stop on native layer.")
        request_stop()
    }

    fun clearKv() {
        val state = threadLocalState.get()
        if (state is State.Loaded) {
            kv_cache_clear(state.context)
            Log.d(tag, "KV cache cleared (manual).")
        } else {
            Log.w(tag, "clearKv() ignored: model is not loaded.")
        }
    }

    fun send(message: String): Flow<String> = flow {
        when (val state = threadLocalState.get()) {
            is State.Loaded -> {
                try {
                    val fullPrompt = message

                    kv_cache_clear(state.context)

                    val nlen = 1024

                    val ncur = IntVar(
                        completion_init(
                            state.context,
                            state.batch,
                            fullPrompt,
                            true,
                            nlen
                        )
                    )

                    while (ncur.value < nlen) {
                        val str = completion_loop(
                            state.context,
                            state.batch,
                            state.sampler,
                            nlen,
                            ncur
                        )
                        if (str == null) break
                        if (str.isNotEmpty()) emit(str)
                    }
                } finally {
                    kv_cache_clear(state.context)
                }
            }
            else -> Log.e("LLamaAndroid", "send() called but model is not loaded.")
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
        // This helper class is required by your C++ code
        class IntVar(value: Int) {
            @Volatile
            var value: Int = value
                private set

            fun inc() {
                synchronized(this) {
                    value += 1
                }
            }
        }

        private sealed interface State {
            data object Idle: State
            data class Loaded(val model: Long, val context: Long, val batch: Long, val sampler: Long): State
        }

        @get:JvmStatic
        val instance: LLamaAndroid = LLamaAndroid()
    }
}