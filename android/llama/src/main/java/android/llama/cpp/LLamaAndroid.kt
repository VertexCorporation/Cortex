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

    private external fun load_model(filename: String, nGpuLayers: Int): Long
    private external fun free_model(model: Long)
    private external fun model_n_ctx_train(model: Long): Int
    private external fun new_context(
        model: Long,
        nCtx: Int,
        nThreads: Int,
        nThreadsBatch: Int,
        nBatch: Int,
        nUbatch: Int
    ): Long
    private external fun context_n_ctx(context: Long): Int
    private external fun context_n_batch(context: Long): Int
    private external fun context_n_ubatch(context: Long): Int
    private external fun free_context(context: Long)
    private external fun backend_init()
    private external fun backend_free()
    private external fun system_info(): String
    private external fun completion_init(
        context: Long,
        batch: Long,
        text: String,
        formatChat: Boolean,
        nLen: Int
    ): LongArray
    private external fun completion_loop(context: Long, batch: Long, sampler: Long, nLen: Int, ncur: IntVar): String?
    private external fun kv_cache_clear(context: Long)
    private external fun new_batch(nTokens: Int, embd: Int, nSeqMax: Int): Long
    private external fun free_batch(batch: Long)
    private external fun new_sampler(temp: Float, topP: Float, topK: Int, repeatPenalty: Float, frequencyPenalty: Float, presencePenalty: Float, mirostatMode: Int, mirostatTau: Float, mirostatEta: Float): Long
    private external fun free_sampler(sampler: Long)
    private external fun request_stop()
    private external fun set_image(bytes: ByteArray)

    data class LoadResult(
        val path: String,
        val nCtx: Int,
        val nThreads: Int,
        val nThreadsBatch: Int,
        val nBatch: Int,
        val nUbatch: Int,
        val nGpuLayers: Int,
        val reusedModel: Boolean,
        val capacitySatisfied: Boolean = true
    )

    suspend fun load(
        pathToModel: String,
        nCtx: Int = 2048,
        nGpuLayers: Int = 0,
        nThreads: Int = 4,
        nThreadsBatch: Int = nThreads,
        nBatch: Int = 512,
        nUbatch: Int = 128,
        debugPerf: Boolean = false
    ): LoadResult {
        return withContext(runLoop) {
            when (val state = threadLocalState.get()) {
                is State.Idle -> {
                    return@withContext loadFresh(
                        pathToModel,
                        nCtx,
                        nGpuLayers,
                        nThreads,
                        nThreadsBatch,
                        nBatch,
                        nUbatch,
                        debugPerf
                    )
                }
                is State.Loaded -> {
                    if (state.path != pathToModel) {
                        freeLoadedState(state)
                        threadLocalState.set(State.Idle)
                        return@withContext loadFresh(
                            pathToModel,
                            nCtx,
                            nGpuLayers,
                            nThreads,
                            nThreadsBatch,
                            nBatch,
                            nUbatch,
                            debugPerf
                        )
                    }

                    val targetContext = clampContextToModel(state.model, nCtx)
                    if (state.nCtx >= targetContext) {
                        return@withContext state.toLoadResult(reusedModel = true)
                    }

                    return@withContext growContext(
                        state,
                        targetContext,
                        nThreads,
                        nThreadsBatch,
                        nBatch,
                        nUbatch,
                        debugPerf
                    )
                }
            }
        }
    }

    private fun loadFresh(
        path: String,
        requestedContext: Int,
        nGpuLayers: Int,
        nThreads: Int,
        nThreadsBatch: Int,
        nBatch: Int,
        nUbatch: Int,
        debugPerf: Boolean
    ): LoadResult {
        val model = load_model(path, nGpuLayers)
        if (model == 0L) throw IllegalStateException("load_model() failed")

        try {
            val targetContext = clampContextToModel(model, requestedContext)
            val context = createNativeContext(
                model, targetContext, nThreads, nThreadsBatch, nBatch, nUbatch
            )
            val actualBatch = context_n_batch(context)
            val batch = new_batch(actualBatch, 0, 1)
            if (batch == 0L) {
                free_context(context)
                throw IllegalStateException("new_batch() failed")
            }

            val sampler = new_sampler(
                0.7f, 0.95f, 40, 1.0f, 0.0f, 0.0f, 0, 5.0f, 0.1f
            )
            if (sampler == 0L) {
                free_batch(batch)
                free_context(context)
                throw IllegalStateException("new_sampler() failed")
            }

            val loaded = State.Loaded(
                path = path,
                model = model,
                context = context,
                batch = batch,
                sampler = sampler,
                nCtx = context_n_ctx(context),
                nThreads = nThreads,
                nThreadsBatch = nThreadsBatch,
                nBatch = actualBatch,
                nUbatch = context_n_ubatch(context),
                nGpuLayers = nGpuLayers,
                debugPerf = debugPerf
            )
            threadLocalState.set(loaded)
            return loaded.toLoadResult(reusedModel = false)
        } catch (error: Throwable) {
            free_model(model)
            throw error
        }
    }

    private fun growContext(
        current: State.Loaded,
        targetContext: Int,
        nThreads: Int,
        nThreadsBatch: Int,
        nBatch: Int,
        nUbatch: Int,
        debugPerf: Boolean
    ): LoadResult {
        var newContext = 0L
        var newBatch = 0L
        try {
            // Create the replacement before releasing the working context. If
            // allocation fails, the existing model/context remains usable.
            newContext = createNativeContext(
                current.model,
                targetContext,
                nThreads,
                nThreadsBatch,
                nBatch,
                nUbatch
            )
            val actualBatch = context_n_batch(newContext)
            newBatch = new_batch(actualBatch, 0, 1)
            if (newBatch == 0L) throw IllegalStateException("new_batch() failed")

            free_batch(current.batch)
            free_context(current.context)
            val grown = current.copy(
                context = newContext,
                batch = newBatch,
                nCtx = context_n_ctx(newContext),
                nThreads = nThreads,
                nThreadsBatch = nThreadsBatch,
                nBatch = actualBatch,
                nUbatch = context_n_ubatch(newContext),
                debugPerf = debugPerf
            )
            threadLocalState.set(grown)
            return grown.toLoadResult(reusedModel = true)
        } catch (error: Throwable) {
            if (newBatch != 0L) free_batch(newBatch)
            if (newContext != 0L) free_context(newContext)
            Log.w(tag, "Context growth failed; retaining ${current.nCtx} tokens", error)
            return current.toLoadResult(
                reusedModel = true,
                capacitySatisfied = false
            )
        }
    }

    private fun createNativeContext(
        model: Long,
        nCtx: Int,
        nThreads: Int,
        nThreadsBatch: Int,
        nBatch: Int,
        nUbatch: Int
    ): Long {
        val context = new_context(
            model, nCtx, nThreads, nThreadsBatch, nBatch, nUbatch
        )
        if (context == 0L) throw IllegalStateException("new_context() failed")
        return context
    }

    private fun clampContextToModel(model: Long, requested: Int): Int {
        val modelLimit = model_n_ctx_train(model)
        return if (modelLimit > 0) {
            requested.coerceIn(128, modelLimit)
        } else {
            requested.coerceAtLeast(128)
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

    suspend fun clearKv() {
        withContext(runLoop) {
            val state = threadLocalState.get()
            if (state is State.Loaded) {
                kv_cache_clear(state.context)
                if (state.debugPerf) Log.d(tag, "KV cache cleared.")
            }
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
        mirostatEta: Float = 0.1f,
        debugPerf: Boolean = false
    ): Flow<String> = flow {
        when (val state = threadLocalState.get()) {
            is State.Loaded -> {
                val requestStartNs = System.nanoTime()
                var prefillDoneNs = requestStartNs
                var firstTokenNs = 0L
                var generatedTokens = 0
                var promptTokens = 0L
                var cacheHitTokens = 0L
                var prefillMicros = 0L
                try {
                    val newSampler = new_sampler(temp, topP, topK, repeatPenalty, frequencyPenalty, presencePenalty, mirostatMode, mirostatTau, mirostatEta)
                    if (newSampler == 0L) throw IllegalStateException("new_sampler() failed")
                    free_sampler(state.sampler)
                    val updatedState = state.copy(sampler = newSampler)
                    threadLocalState.set(updatedState)

                    val nlen = updatedState.nCtx

                    val promptStats = completion_init(
                            updatedState.context,
                            updatedState.batch,
                            message,
                            true,
                            nlen
                        )
                    val initialPosition = promptStats.getOrElse(0) { -1L }.toInt()
                    if (initialPosition < 0) {
                        throw IllegalStateException("Prompt does not fit in the active context")
                    }
                    promptTokens = promptStats.getOrElse(1) { 0L }
                    cacheHitTokens = promptStats.getOrElse(2) { 0L }
                    prefillMicros = promptStats.getOrElse(3) { 0L }
                    prefillDoneNs = System.nanoTime()
                    val ncur = IntVar(initialPosition)

                    while (ncur.value < nlen) {
                        val str = completion_loop(
                            updatedState.context,
                            updatedState.batch,
                            newSampler,
                            nlen,
                            ncur
                        )
                        if (str == null) break
                        generatedTokens++
                        if (firstTokenNs == 0L) firstTokenNs = System.nanoTime()
                        if (str.isNotEmpty()) emit(str)
                    }
                } finally {
                    if (debugPerf || state.debugPerf) {
                        val endNs = System.nanoTime()
                        val ttftMs = if (firstTokenNs == 0L) -1.0 else
                            (firstTokenNs - requestStartNs) / 1_000_000.0
                        val generationSeconds =
                            (endNs - prefillDoneNs).coerceAtLeast(1L) / 1_000_000_000.0
                        val tokensPerSecond = generatedTokens / generationSeconds
                        val cacheStatus = if (cacheHitTokens > 0) "hit" else "miss"
                        Log.d(
                            tag,
                            "[perf] ctx=${state.nCtx} threads=${state.nThreads}/${state.nThreadsBatch} " +
                                "gpu=${state.nGpuLayers} batch=${state.nBatch}/${state.nUbatch} " +
                                "promptTokens=$promptTokens prefillMs=${prefillMicros / 1000.0} " +
                                "ttftMs=$ttftMs generationTps=$tokensPerSecond " +
                                "cache=$cacheStatus cacheTokens=$cacheHitTokens"
                        )
                    }
                }
            }
            else -> Log.e(tag, "send() called but model is not loaded.")
        }
    }.flowOn(runLoop)

    suspend fun unload() {
        withContext(runLoop) {
            when (val state = threadLocalState.get()) {
                is State.Loaded -> {
                    freeLoadedState(state)
                    threadLocalState.set(State.Idle)
                }
                else -> {}
            }
        }
    }

    private fun freeLoadedState(state: State.Loaded) {
        free_sampler(state.sampler)
        free_batch(state.batch)
        free_context(state.context)
        free_model(state.model)
    }

    private fun State.Loaded.toLoadResult(
        reusedModel: Boolean,
        capacitySatisfied: Boolean = true
    ) = LoadResult(
        path = path,
        nCtx = nCtx,
        nThreads = nThreads,
        nThreadsBatch = nThreadsBatch,
        nBatch = nBatch,
        nUbatch = nUbatch,
        nGpuLayers = nGpuLayers,
        reusedModel = reusedModel,
        capacitySatisfied = capacitySatisfied
    )

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
                val path: String,
                val model: Long,
                val context: Long,
                val batch: Long,
                val sampler: Long,
                val nCtx: Int,
                val nThreads: Int,
                val nThreadsBatch: Int,
                val nBatch: Int,
                val nUbatch: Int,
                val nGpuLayers: Int,
                val debugPerf: Boolean
            ): State
        }

        @get:JvmStatic
        val instance: LLamaAndroid = LLamaAndroid()
    }
}
