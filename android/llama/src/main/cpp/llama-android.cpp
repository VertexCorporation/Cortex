#include <atomic>
#include <algorithm>
#include <android/log.h>
#include <jni.h>
#include <iomanip>
#include <math.h>
#include <mutex>
#include <string>
#include <unistd.h>
#include "llama.h"
#include "common.h"
#include <vector>

// Write C++ code here.
//
// Do not forget to dynamically load the C++ library into your application.
//
// For instance,
//
// In MainActivity.java:
//    static {
//       System.loadLibrary("llama-android");
//    }
//
// Or, in MainActivity.kt:
//    companion object {
//      init {
//         System.loadLibrary("llama-android")
//      }
//    }

#define TAG "llama-android.cpp"
#define LOGi(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGe(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

jclass la_int_var = nullptr;
jmethodID la_int_var_value = nullptr;
jmethodID la_int_var_inc = nullptr;

std::string cached_token_chars;

static std::atomic<bool> g_stop_requested(false);

// The app owns a single native model instance. Keep the exact token sequence
// represented by its KV cache so a later prompt can reuse a verified prefix.
static llama_context * g_cached_context = nullptr;
static std::vector<llama_token> g_cached_sequence_tokens;

static std::vector<uint8_t> g_image_bytes;
static std::mutex g_image_mutex;

bool is_valid_utf8(const char * string) {
    if (!string) {
        return true;
    }

    const unsigned char * bytes = (const unsigned char *)string;
    int num;

    while (*bytes != 0x00) {
        if ((*bytes & 0x80) == 0x00) {
            // U+0000 to U+007F
            num = 1;
        } else if ((*bytes & 0xE0) == 0xC0) {
            // U+0080 to U+07FF
            num = 2;
        } else if ((*bytes & 0xF0) == 0xE0) {
            // U+0800 to U+FFFF
            num = 3;
        } else if ((*bytes & 0xF8) == 0xF0) {
            // U+10000 to U+10FFFF
            num = 4;
        } else {
            return false;
        }

        bytes += 1;
        for (int i = 1; i < num; ++i) {
            if ((*bytes & 0xC0) != 0x80) {
                return false;
            }
            bytes += 1;
        }
    }

    return true;
}

static void log_callback(ggml_log_level level, const char * fmt, void * data) {
    if (level == GGML_LOG_LEVEL_ERROR)     __android_log_print(ANDROID_LOG_ERROR, TAG, fmt, data);
    else if (level == GGML_LOG_LEVEL_INFO) __android_log_print(ANDROID_LOG_INFO, TAG, fmt, data);
    else if (level == GGML_LOG_LEVEL_WARN) __android_log_print(ANDROID_LOG_WARN, TAG, fmt, data);
    else __android_log_print(ANDROID_LOG_DEFAULT, TAG, fmt, data);
}

extern "C"
JNIEXPORT jlong JNICALL
Java_android_llama_cpp_LLamaAndroid_load_1model(JNIEnv *env, jobject, jstring filename, jint n_gpu_layers) {
    llama_model_params model_params = llama_model_default_params();

    // This Android target is currently built without GGML_VULKAN, so Dart
    // supplies zero. Keep the parameter wired for a future verified backend.
    model_params.n_gpu_layers = n_gpu_layers;
    // llama.cpp supports mmap for GGUF files on Android. Make the intended
    // default explicit so weights are not copied into an additional heap buffer.
    model_params.use_mmap = llama_supports_mmap();

    auto path_to_model = env->GetStringUTFChars(filename, 0);
    LOGi("Loading model from %s with n_gpu_layers=%d", path_to_model, n_gpu_layers);

    auto model = llama_model_load_from_file(path_to_model, model_params);
    env->ReleaseStringUTFChars(filename, path_to_model);

    if (!model) {
        LOGe("load_model() failed");
        env->ThrowNew(env->FindClass("java/lang/IllegalStateException"), "load_model() failed");
        return 0;
    }

    return reinterpret_cast<jlong>(model);
}

extern "C"
JNIEXPORT jint JNICALL
Java_android_llama_cpp_LLamaAndroid_model_1n_1ctx_1train(
        JNIEnv *, jobject, jlong model_pointer) {
    const auto model = reinterpret_cast<llama_model *>(model_pointer);
    return model ? llama_model_n_ctx_train(model) : 0;
}

// This is the NEW JNI function to set the stop flag from Kotlin.
extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_request_1stop(JNIEnv *, jobject) {
LOGi("Stop request received in C++ layer.");
g_stop_requested = true;
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_set_1image(
        JNIEnv *env,
jobject /* this */,
jbyteArray imageBytes
) {
if (imageBytes == nullptr) {
LOGe("set_image() called with null imageBytes");
return;
}

const jsize length = env->GetArrayLength(imageBytes);
if (length <= 0) {
LOGe("set_image() called with empty imageBytes");
return;
}

{
    std::lock_guard<std::mutex> lock(g_image_mutex);
    g_image_bytes.resize(static_cast<size_t>(length));
    env->GetByteArrayRegion(
            imageBytes,
    0,
    length,
    reinterpret_cast<jbyte *>(g_image_bytes.data())
    );
}

LOGi("set_image() stored %d bytes in global image buffer", length);
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_free_1model(JNIEnv *, jobject, jlong model) {
llama_model_free(reinterpret_cast<llama_model *>(model));
}

extern "C"
JNIEXPORT jlong JNICALL
Java_android_llama_cpp_LLamaAndroid_new_1context(
        JNIEnv *env,
        jobject,
        jlong jmodel,
        jint n_ctx,
        jint n_threads,
        jint n_threads_batch,
        jint n_batch,
        jint n_ubatch) {
auto model = reinterpret_cast<llama_model *>(jmodel);

if (!model) {
LOGe("new_context(): model cannot be null");
env->ThrowNew(env->FindClass("java/lang/IllegalArgumentException"), "Model cannot be null");
return 0;
}

// Use provided thread count, or fallback to auto-detection
const int detected_cores = std::max(1L, sysconf(_SC_NPROCESSORS_ONLN));
const int threads = n_threads > 0
        ? n_threads
        : std::max(1, std::min(8, detected_cores - 1));
const int batch_threads = n_threads_batch > 0 ? n_threads_batch : threads;
const int model_context = llama_model_n_ctx_train(model);
const int context_size = model_context > 0
        ? std::clamp(static_cast<int>(n_ctx), 128, model_context)
        : std::max(128, static_cast<int>(n_ctx));
const int batch_size = std::clamp(static_cast<int>(n_batch), 32, context_size);
const int ubatch_size = std::clamp(static_cast<int>(n_ubatch), 32, batch_size);

LOGi("Creating context ctx=%d threads=%d/%d batch=%d/%d",
     context_size, threads, batch_threads, batch_size, ubatch_size);

llama_context_params ctx_params = llama_context_default_params();

// DYNAMIC CONTEXT SIZE from Dart!
ctx_params.n_ctx           = context_size;
ctx_params.n_batch         = batch_size;
ctx_params.n_ubatch        = ubatch_size;
ctx_params.n_threads       = threads;
ctx_params.n_threads_batch = batch_threads;

llama_context * context = llama_init_from_model(model, ctx_params);

if (!context) {
LOGe("llama_new_context_with_model() returned null)");
env->ThrowNew(env->FindClass("java/lang/IllegalStateException"),
"llama_new_context_with_model() returned null)");
return 0;
}

return reinterpret_cast<jlong>(context);
}

extern "C"
JNIEXPORT jint JNICALL
Java_android_llama_cpp_LLamaAndroid_context_1n_1ctx(
        JNIEnv *, jobject, jlong context_pointer) {
    const auto context = reinterpret_cast<llama_context *>(context_pointer);
    return context ? static_cast<jint>(llama_n_ctx(context)) : 0;
}

extern "C"
JNIEXPORT jint JNICALL
Java_android_llama_cpp_LLamaAndroid_context_1n_1batch(
        JNIEnv *, jobject, jlong context_pointer) {
    const auto context = reinterpret_cast<llama_context *>(context_pointer);
    return context ? static_cast<jint>(llama_n_batch(context)) : 0;
}

extern "C"
JNIEXPORT jint JNICALL
Java_android_llama_cpp_LLamaAndroid_context_1n_1ubatch(
        JNIEnv *, jobject, jlong context_pointer) {
    const auto context = reinterpret_cast<llama_context *>(context_pointer);
    return context ? static_cast<jint>(llama_n_ubatch(context)) : 0;
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_free_1context(JNIEnv *, jobject, jlong context) {
auto ctx = reinterpret_cast<llama_context *>(context);
if (g_cached_context == ctx) {
    g_cached_context = nullptr;
    g_cached_sequence_tokens.clear();
}
llama_free(ctx);
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_backend_1free(JNIEnv *, jobject) {
llama_backend_free();
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_log_1to_1android(JNIEnv *, jobject) {
llama_log_set(log_callback, NULL);
}

extern "C"
JNIEXPORT jstring JNICALL
        Java_android_llama_cpp_LLamaAndroid_bench_1model(
        JNIEnv *env,
        jobject,
        jlong context_pointer,
jlong model_pointer,
        jlong batch_pointer,
jint pp,
        jint tg,
jint pl,
        jint nr
) {
if (!context_pointer || !model_pointer || !batch_pointer) {
    LOGe("bench_model() called with null pointer(s)");
    return env->NewStringUTF("");
}

auto pp_avg = 0.0;
auto tg_avg = 0.0;
auto pp_std = 0.0;
auto tg_std = 0.0;

const auto context = reinterpret_cast<llama_context *>(context_pointer);
const auto model = reinterpret_cast<llama_model *>(model_pointer);
const auto batch = reinterpret_cast<llama_batch *>(batch_pointer);

const int n_ctx = llama_n_ctx(context);

LOGi("n_ctx = %d", n_ctx);

int i, j;
int nri;
for (nri = 0; nri < nr; nri++) {
LOGi("Benchmark prompt processing (pp)");

common_batch_clear(*batch);

const int n_tokens = pp;
for (i = 0; i < n_tokens; i++) {
common_batch_add(*batch, 0, i, { 0 }, false);
}

batch->logits[batch->n_tokens - 1] = true;
llama_memory_clear(llama_get_memory(context), false);

const auto t_pp_start = ggml_time_us();
if (llama_decode(context, *batch) != 0) {
LOGi("llama_decode() failed during prompt processing");
}
const auto t_pp_end = ggml_time_us();

// bench text generation

LOGi("Benchmark text generation (tg)");

llama_memory_clear(llama_get_memory(context), false);
const auto t_tg_start = ggml_time_us();
for (i = 0; i < tg; i++) {

common_batch_clear(*batch);
for (j = 0; j < pl; j++) {
common_batch_add(*batch, 0, i, { j }, true);
}

LOGi("llama_decode() text generation: %d", i);
if (llama_decode(context, *batch) != 0) {
LOGi("llama_decode() failed during text generation");
}
}

const auto t_tg_end = ggml_time_us();

llama_memory_clear(llama_get_memory(context), false);

const auto t_pp = double(t_pp_end - t_pp_start) / 1000000.0;
const auto t_tg = double(t_tg_end - t_tg_start) / 1000000.0;

const auto speed_pp = double(pp) / t_pp;
const auto speed_tg = double(pl * tg) / t_tg;

pp_avg += speed_pp;
tg_avg += speed_tg;

pp_std += speed_pp * speed_pp;
tg_std += speed_tg * speed_tg;

LOGi("pp %f t/s, tg %f t/s", speed_pp, speed_tg);
}

pp_avg /= double(nr);
tg_avg /= double(nr);

if (nr > 1) {
pp_std = sqrt(pp_std / double(nr - 1) - pp_avg * pp_avg * double(nr) / double(nr - 1));
tg_std = sqrt(tg_std / double(nr - 1) - tg_avg * tg_avg * double(nr) / double(nr - 1));
} else {
pp_std = 0;
tg_std = 0;
}

char model_desc[128];
llama_model_desc(model, model_desc, sizeof(model_desc));

const auto model_size     = double(llama_model_size(model)) / 1024.0 / 1024.0 / 1024.0;
const auto model_n_params = double(llama_model_n_params(model)) / 1e9;

const auto backend = "Android / CPU";

std::stringstream result;
result << std::setprecision(2);
result << "| model | size | params | backend | test | t/s |\n";
result << "| --- | --- | --- | --- | --- | --- |\n";
result << "| " << model_desc << " | " << model_size << "GiB | " << model_n_params << "B | " << backend << " | pp " << pp << " | " << pp_avg << " ± " << pp_std << " |\n";
result << "| " << model_desc << " | " << model_size << "GiB | " << model_n_params << "B | " << backend << " | tg " << tg << " | " << tg_avg << " ± " << tg_std << " |\n";

return env->NewStringUTF(result.str().c_str());
}

extern "C"
JNIEXPORT jlong JNICALL
        Java_android_llama_cpp_LLamaAndroid_new_1batch(
        JNIEnv *, jobject, jint n_tokens, jint embd, jint n_seq_max) {
llama_batch * batch = new llama_batch(llama_batch_init(n_tokens, embd, n_seq_max));
return reinterpret_cast<jlong>(batch);
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_free_1batch(JNIEnv *, jobject, jlong p) {
auto batch = reinterpret_cast<llama_batch *>(p);
llama_batch_free(*batch);
delete batch;
}

extern "C"
JNIEXPORT jlong JNICALL
        Java_android_llama_cpp_LLamaAndroid_new_1sampler(
        JNIEnv * env,
        jobject /* thiz */,
        jfloat temperature,
        jfloat top_p,
        jint top_k,
        jfloat repeat_penalty,
        jfloat frequency_penalty,
        jfloat presence_penalty,
        jint mirostat_mode,
        jfloat mirostat_tau,
        jfloat mirostat_eta
) {
(void) env;

auto sparams = llama_sampler_chain_default_params();
sparams.no_perf = true;

llama_sampler * smpl = llama_sampler_chain_init(sparams);

// --- Pure greedy path (deterministic) ---
if (temperature <= 0.0f) {
llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
return reinterpret_cast<jlong>(smpl);
}

// 0) Repetition / Frequency / Presence penalties
if (repeat_penalty != 1.0f || frequency_penalty != 0.0f || presence_penalty != 0.0f) {
llama_sampler_chain_add(smpl, llama_sampler_init_penalties(
    64,  // penalty_last_n (64 = check last 64 tokens, -1 = all = slow, 0 = off)
    repeat_penalty,
    frequency_penalty,
    presence_penalty
));
}

// 1) Top-K
if (top_k > 0) {
llama_sampler_chain_add(smpl, llama_sampler_init_top_k(top_k));
}

// 2) Top-P
if (top_p > 0.0f && top_p < 1.0f) {
llama_sampler_chain_add(smpl, llama_sampler_init_top_p(top_p, 1));
}

// 3) Temperature
llama_sampler_chain_add(smpl, llama_sampler_init_temp(temperature));

// 4) Mirostat V2 (adaptive entropy control, great for small models)
if (mirostat_mode == 2) {
llama_sampler_chain_add(smpl, llama_sampler_init_mirostat_v2(LLAMA_DEFAULT_SEED, mirostat_tau, mirostat_eta));
}

// 5) Final distribution sampler
llama_sampler_chain_add(smpl, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));

return reinterpret_cast<jlong>(smpl);
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_free_1sampler(JNIEnv *, jobject, jlong sampler_pointer) {
llama_sampler_free(reinterpret_cast<llama_sampler *>(sampler_pointer));
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_backend_1init(JNIEnv *, jobject) {
llama_backend_init();
}

extern "C"
JNIEXPORT jstring JNICALL
Java_android_llama_cpp_LLamaAndroid_system_1info(JNIEnv *env, jobject) {
    return env->NewStringUTF(llama_print_system_info());
}

extern "C"
JNIEXPORT jlongArray JNICALL
        Java_android_llama_cpp_LLamaAndroid_completion_1init(
        JNIEnv *env,
        jobject,
        jlong context_pointer,
jlong batch_pointer,
        jstring jtext,
jboolean format_chat,
        jint n_len
) {
g_stop_requested = false;
cached_token_chars.clear();
(void) n_len;
const auto context = reinterpret_cast<llama_context *>(context_pointer);
const auto batch = reinterpret_cast<llama_batch *>(batch_pointer);

auto make_result = [env](jlong n_cur, jlong prompt_tokens,
                         jlong cache_hit_tokens, jlong prefill_us) {
    const jlong values[] = {n_cur, prompt_tokens, cache_hit_tokens, prefill_us};
    auto result = env->NewLongArray(4);
    if (result != nullptr) env->SetLongArrayRegion(result, 0, 4, values);
    return result;
};

if (context == nullptr || batch == nullptr || jtext == nullptr) {
    LOGe("completion_init() called with null input");
    return make_result(-1, 0, 0, 0);
}

const auto prefill_start = ggml_time_us();
const auto text = env->GetStringUTFChars(jtext, nullptr);
if (text == nullptr) return make_result(-1, 0, 0, 0);

bool parse_special = (format_chat == JNI_TRUE);
const auto tokens_list = common_tokenize(context, text, true, parse_special);
env->ReleaseStringUTFChars(jtext, text);

if (!g_image_bytes.empty()) {
LOGi("completion_init: %zu image bytes available for multimodal processing.",
     static_cast<size_t>(g_image_bytes.size()));
}

const auto n_ctx = llama_n_ctx(context);
if (tokens_list.empty() || tokens_list.size() >= n_ctx) {
    LOGe("Prompt token count %zu does not fit context %u",
         tokens_list.size(), n_ctx);
    return make_result(-1, tokens_list.size(), 0,
                       ggml_time_us() - prefill_start);
}

auto memory = llama_get_memory(context);
size_t common_prefix = 0;
if (g_cached_context == context) {
    const size_t compare_count = std::min(
            tokens_list.size(), g_cached_sequence_tokens.size());
    while (common_prefix < compare_count &&
           tokens_list[common_prefix] == g_cached_sequence_tokens[common_prefix]) {
        ++common_prefix;
    }
} else {
    llama_memory_clear(memory, false);
    g_cached_context = context;
    g_cached_sequence_tokens.clear();
}

// A decode call is still required to produce fresh logits when the incoming
// prompt is byte-for-byte identical to the cached sequence.
if (common_prefix == tokens_list.size() && common_prefix > 0) {
    --common_prefix;
}

if (common_prefix < g_cached_sequence_tokens.size()) {
    const bool removed = llama_memory_seq_rm(
            memory, 0, static_cast<llama_pos>(common_prefix), -1);
    if (!removed) {
        // Some recurrent architectures cannot drop a partial sequence. A full
        // clear is always safe and preserves compatibility with those models.
        llama_memory_clear(memory, false);
        common_prefix = 0;
    }
}

const size_t logical_batch = std::max<size_t>(32, llama_n_batch(context));
size_t offset = common_prefix;
while (offset < tokens_list.size()) {
    const size_t chunk_size = std::min(
            logical_batch, tokens_list.size() - offset);
    common_batch_clear(*batch);

    for (size_t i = 0; i < chunk_size; ++i) {
        common_batch_add(
                *batch,
                tokens_list[offset + i],
                static_cast<llama_pos>(offset + i),
                {0},
                false);
    }

    if (offset + chunk_size == tokens_list.size()) {
        batch->logits[batch->n_tokens - 1] = true;
    }

    if (llama_decode(context, *batch) != 0) {
        LOGe("llama_decode() failed during prompt prefill at offset %zu", offset);
        llama_memory_clear(memory, false);
        g_cached_sequence_tokens.clear();
        return make_result(-1, tokens_list.size(), common_prefix,
                           ggml_time_us() - prefill_start);
    }
    offset += chunk_size;
}

g_cached_context = context;
g_cached_sequence_tokens.assign(tokens_list.begin(), tokens_list.end());
const auto prefill_us = ggml_time_us() - prefill_start;
return make_result(tokens_list.size(), tokens_list.size(), common_prefix, prefill_us);
}

extern "C"
JNIEXPORT jstring JNICALL
        Java_android_llama_cpp_LLamaAndroid_completion_1loop(
        JNIEnv * env,
        jobject,
        jlong context_pointer,
jlong batch_pointer,
        jlong sampler_pointer,
jint n_len,
        jobject intvar_ncur
) {
if (g_stop_requested) {
LOGi("Stop flag detected. Terminating completion_loop.");
g_stop_requested = false; // Reset flag for the next run.
return nullptr; // Signal completion to the Kotlin Flow.
}

const auto context = reinterpret_cast<llama_context *>(context_pointer);
const auto batch   = reinterpret_cast<llama_batch   *>(batch_pointer);
const auto sampler = reinterpret_cast<llama_sampler *>(sampler_pointer);
const auto model = llama_get_model(context);
const auto vocab = llama_model_get_vocab(model);

if (!la_int_var) {
    jclass localClass = env->GetObjectClass(intvar_ncur);
    la_int_var = static_cast<jclass>(env->NewGlobalRef(localClass));
    env->DeleteLocalRef(localClass);
}
if (!la_int_var_value) la_int_var_value = env->GetMethodID(la_int_var, "getValue", "()I");
if (!la_int_var_inc) la_int_var_inc = env->GetMethodID(la_int_var, "inc", "()V");

// check that batch has tokens before sampling
if (batch->n_tokens == 0) {
    LOGe("completion_loop() called with empty batch");
    env->ThrowNew(env->FindClass("java/lang/IllegalStateException"), "Empty decode batch");
    return nullptr;
}

// sample the most likely token
const auto new_token_id = llama_sampler_sample(sampler, context, -1);

const auto n_cur = env->CallIntMethod(intvar_ncur, la_int_var_value);
if (llama_vocab_is_eog(vocab, new_token_id) || n_cur == n_len) {
return nullptr;
}

auto new_token_chars = common_token_to_piece(context, new_token_id);
cached_token_chars += new_token_chars;

// Check for common stop sequences in the accumulated output
const auto has_stop =
cached_token_chars.find("<|im_end|>") != std::string::npos ||
cached_token_chars.find("<end_of_turn>") != std::string::npos ||
cached_token_chars.find("<|endoftext|>") != std::string::npos ||
cached_token_chars.find("<|eot_id|>") != std::string::npos ||
cached_token_chars.find("</s>") != std::string::npos;
if (has_stop) {
cached_token_chars.clear();
return nullptr;
}

jstring new_token = nullptr;
if (is_valid_utf8(cached_token_chars.c_str())) {
    new_token = env->NewStringUTF(cached_token_chars.c_str());
    cached_token_chars.clear();
} else {
    new_token = env->NewStringUTF("");
}

common_batch_clear(*batch);
common_batch_add(*batch, new_token_id, n_cur, { 0 }, true);

env->CallVoidMethod(intvar_ncur, la_int_var_inc);

if (env->ExceptionCheck()) {
    LOGe("JNI exception after CallVoidMethod, cleaning up");
    if (new_token) env->DeleteLocalRef(new_token);
    env->ExceptionClear();
    return nullptr;
}

if (llama_decode(context, *batch) != 0) {
    LOGe("llama_decode() returned null");
    if (new_token) env->DeleteLocalRef(new_token);
    llama_kv_self_clear(context);
    g_cached_sequence_tokens.clear();
    env->ThrowNew(env->FindClass("java/lang/IllegalStateException"), "Token decode failed");
    return nullptr;
}

if (g_cached_context == context) {
    g_cached_sequence_tokens.push_back(new_token_id);
}

return new_token;
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_clear_1image(JNIEnv *, jobject) {
    std::lock_guard<std::mutex> lock(g_image_mutex);
    g_image_bytes.clear();
    g_image_bytes.shrink_to_fit();
    LOGi("clear_image() released image buffer");
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_kv_1cache_1clear(JNIEnv *, jobject, jlong context) {
if (context == 0) {
__android_log_print(ANDROID_LOG_ERROR, "llama-android", "clearKv() FAILED: context pointer is null.");
return;
}

auto ctx = reinterpret_cast<llama_context *>(context);
llama_memory_clear(llama_get_memory(ctx), true);
if (g_cached_context == ctx) {
    g_cached_sequence_tokens.clear();
}
__android_log_print(ANDROID_LOG_INFO, "llama-android", "KV cache successfully cleared.");
}
