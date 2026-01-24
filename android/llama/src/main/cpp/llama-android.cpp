#include <atomic>
#include <android/log.h>
#include <jni.h>
#include <iomanip>
#include <math.h>
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

jclass la_int_var;
jmethodID la_int_var_value;
jmethodID la_int_var_inc;

std::string cached_token_chars;

static std::atomic<bool> g_stop_requested(false);

static std::vector<uint8_t> g_image_bytes;

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

    // GPU OFFLOADING: Set the number of layers to offload to GPU
    // 99 = offload all layers (Vulkan/OpenCL if available)
    // 0 = CPU only
    model_params.n_gpu_layers = n_gpu_layers;

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

g_image_bytes.resize(static_cast<size_t>(length));
env->GetByteArrayRegion(
        imageBytes,
0,
length,
reinterpret_cast<jbyte *>(g_image_bytes.data())
);

LOGi("set_image() stored %d bytes in global image buffer", length);
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_free_1model(JNIEnv *, jobject, jlong model) {
llama_model_free(reinterpret_cast<llama_model *>(model));
}

extern "C"
JNIEXPORT jlong JNICALL
        Java_android_llama_cpp_LLamaAndroid_new_1context(JNIEnv *env, jobject, jlong jmodel, jint n_ctx, jint n_threads) {
auto model = reinterpret_cast<llama_model *>(jmodel);

if (!model) {
LOGe("new_context(): model cannot be null");
env->ThrowNew(env->FindClass("java/lang/IllegalArgumentException"), "Model cannot be null");
return 0;
}

// Use provided thread count, or fallback to auto-detection
int threads = n_threads > 0 ? n_threads : std::max(1, std::min(8, (int) sysconf(_SC_NPROCESSORS_ONLN) - 2));
LOGi("Creating context with n_ctx=%d, n_threads=%d", n_ctx, threads);

llama_context_params ctx_params = llama_context_default_params();

// DYNAMIC CONTEXT SIZE from Dart!
ctx_params.n_ctx           = n_ctx;
ctx_params.n_threads       = threads;
ctx_params.n_threads_batch = threads;

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
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_free_1context(JNIEnv *, jobject, jlong context) {
llama_free(reinterpret_cast<llama_context *>(context));
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
        jint top_k
) {
(void) env; // unused warning fix

auto sparams = llama_sampler_chain_default_params();
sparams.no_perf = true;

llama_sampler * smpl = llama_sampler_chain_init(sparams);

// --- Pure greedy path (deterministic) ---
if (temperature <= 0.0f) {
llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
return reinterpret_cast<jlong>(smpl);
}

// --- Stochastic path (temp / top-k / top-p + dist) ---

// 1) Top-K
if (top_k > 0) {
llama_sampler_chain_add(smpl, llama_sampler_init_top_k(top_k));
}

// 2) Top-P
if (top_p > 0.0f && top_p < 1.0f) {
// min_keep = 1
llama_sampler_chain_add(smpl, llama_sampler_init_top_p(top_p, 1));
}

// 3) Temperature
llama_sampler_chain_add(smpl, llama_sampler_init_temp(temperature));

// 4) Final sampler
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
JNIEXPORT jint JNICALL
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

const auto text = env->GetStringUTFChars(jtext, 0);
const auto context = reinterpret_cast<llama_context *>(context_pointer);
const auto batch = reinterpret_cast<llama_batch *>(batch_pointer);

bool parse_special = (format_chat == JNI_TRUE);
const auto tokens_list = common_tokenize(context, text, true, parse_special);

if (!g_image_bytes.empty()) {
LOGi("completion_init: %zu image bytes available for multimodal processing.",
     static_cast<size_t>(g_image_bytes.size()));
}

auto n_ctx = llama_n_ctx(context);
auto n_kv_req = tokens_list.size() + n_len;

LOGi("n_len = %d, n_ctx = %d, n_kv_req = %zu",
     n_len,
     n_ctx,
     (size_t) n_kv_req);

if (n_kv_req > n_ctx) {
LOGe("error: n_kv_req > n_ctx, the required KV cache size is not big enough");
}

for (auto id : tokens_list) {
LOGi("token: `%s`-> %d ", common_token_to_piece(context, id).c_str(), id);
}

common_batch_clear(*batch);

// evaluate the initial prompt
for (auto i = 0; i < tokens_list.size(); i++) {
common_batch_add(*batch, tokens_list[i], i, { 0 }, false);
}

// llama_decode will output logits only for the last token of the prompt
batch->logits[batch->n_tokens - 1] = true;

if (llama_decode(context, *batch) != 0) {
LOGe("llama_decode() failed");
}

env->ReleaseStringUTFChars(jtext, text);

return batch->n_tokens;
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

if (!la_int_var) la_int_var = env->GetObjectClass(intvar_ncur);
if (!la_int_var_value) la_int_var_value = env->GetMethodID(la_int_var, "getValue", "()I");
if (!la_int_var_inc) la_int_var_inc = env->GetMethodID(la_int_var, "inc", "()V");

// sample the most likely token
const auto new_token_id = llama_sampler_sample(sampler, context, -1);

const auto n_cur = env->CallIntMethod(intvar_ncur, la_int_var_value);
if (llama_vocab_is_eog(vocab, new_token_id) || n_cur == n_len) {
return nullptr;
}

auto new_token_chars = common_token_to_piece(context, new_token_id);
cached_token_chars += new_token_chars;

jstring new_token = nullptr;
if (is_valid_utf8(cached_token_chars.c_str())) {
new_token = env->NewStringUTF(cached_token_chars.c_str());
LOGi("cached: %s, new_token_chars: `%s`, id: %d", cached_token_chars.c_str(), new_token_chars.c_str(), new_token_id);
cached_token_chars.clear();
} else {
new_token = env->NewStringUTF("");
}

common_batch_clear(*batch);
common_batch_add(*batch, new_token_id, n_cur, { 0 }, true);

env->CallVoidMethod(intvar_ncur, la_int_var_inc);

if (llama_decode(context, *batch) != 0) {
LOGe("llama_decode() returned null");
}

return new_token;
}

extern "C"
JNIEXPORT void JNICALL
Java_android_llama_cpp_LLamaAndroid_kv_1cache_1clear(JNIEnv *, jobject, jlong context) {
if (context == 0) {
__android_log_print(ANDROID_LOG_WARN, "llama-android", "clearKv() received null context, retrying...");

int retries = 20;
while (context == 0 && retries-- > 0) {
usleep(10000);
}

if (context == 0) {
__android_log_print(ANDROID_LOG_ERROR, "llama-android", "clearKv() FAILED: context pointer still null.");
return;
}
}

auto ctx = reinterpret_cast<llama_context *>(context);
llama_memory_clear(llama_get_memory(ctx), true);
__android_log_print(ANDROID_LOG_INFO, "llama-android", "KV cache successfully cleared.");
}
