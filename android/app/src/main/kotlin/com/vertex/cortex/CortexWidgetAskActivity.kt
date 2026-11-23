package com.vertex.cortex

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.os.Bundle
import android.speech.RecognizerIntent
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withTimeout
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.Locale
import java.util.UUID

class CortexWidgetAskActivity : ComponentActivity() {

    companion object {
        const val EXTRA_WIDGET_PROMPT = "extra_widget_prompt"
        const val EXTRA_WIDGET_ANSWER = "extra_widget_answer"
        private const val PROXY_URL = "https://sendmessage-o5h7dmtija-ew.a.run.app"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            FirebaseApp.initializeApp(this)
            FirebaseAppCheck.getInstance().installAppCheckProviderFactory(
                if ((applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
                    DebugAppCheckProviderFactory.getInstance()
                } else {
                    PlayIntegrityAppCheckProviderFactory.getInstance()
                }
            )
        } catch (_: Exception) {
        }

        val startVoice = intent?.getBooleanExtra(
            CortexAppWidgetProvider.EXTRA_START_VOICE,
            false
        ) ?: false

        setContent {
            MaterialTheme(
                colorScheme = darkColorScheme(
                    primary = Color.White,
                    background = Color.Transparent,
                    surface = Color(0xFF161618),
                    onSurface = Color.White
                )
            ) {
                QuickAskOverlayScreen(
                    initialStartVoice = startVoice,
                    onDismiss = { finish() },
                    onOpenInApp = { question, answer ->
                        val launchIntent = Intent(this, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                            putExtra(EXTRA_WIDGET_PROMPT, question)
                            putExtra(EXTRA_WIDGET_ANSWER, answer)
                        }
                        startActivity(launchIntent)
                        finish()
                    }
                )
            }
        }
    }

    @Composable
    private fun QuickAskOverlayScreen(
        initialStartVoice: Boolean,
        onDismiss: () -> Unit,
        onOpenInApp: (String, String) -> Unit
    ) {
        val context = LocalContext.current
        val prefs = remember {
            context.getSharedPreferences(
                CortexAppWidgetProvider.PREFS_NAME,
                Context.MODE_PRIVATE
            )
        }
        val isTurkish = remember {
            val savedLang = prefs.getString("flutter.language_code", null)
            (savedLang ?: Locale.getDefault().language).startsWith("tr", ignoreCase = true)
        }

        var promptText by remember { mutableStateOf("") }
        var askedQuestion by remember {
            mutableStateOf(prefs.getString(CortexAppWidgetProvider.KEY_LAST_QUESTION, "") ?: "")
        }
        var answerText by remember {
            mutableStateOf(prefs.getString(CortexAppWidgetProvider.KEY_LAST_ANSWER, "") ?: "")
        }
        var isStreaming by remember { mutableStateOf(false) }
        var errorMessage by remember { mutableStateOf<String?>(null) }

        val scope = rememberCoroutineScope()
        var activeJob by remember { mutableStateOf<Job?>(null) }
        val focusRequester = remember { FocusRequester() }
        val answerScrollState = rememberScrollState()

        val strThinking = if (isTurkish) "D\u00FC\u015F\u00FCn\u00FCyor..." else "Thinking..."
        val strClear = if (isTurkish) "Temizle" else "Clear"
        val strHint = if (isTurkish) "Uygulamay\u0131 a\u00E7madan sor..." else "Ask without opening app..."
        val strVoiceInput = if (isTurkish) "Sesli sor" else "Voice input"
        val strVoiceUnavailable = if (isTurkish) "Ses tan\u0131ma kullan\u0131lam\u0131yor" else "Speech recognition unavailable"
        val strCopy = if (isTurkish) "Kopyala" else "Copy"
        val strCopied = if (isTurkish) "Kopyaland\u0131" else "Copied"
        val strContinueInApp = if (isTurkish) "Uygulamada Devam Et" else "Continue in App"
        val strConnError = if (isTurkish) "Ba\u011Flant\u0131 hatas\u0131 olu\u015Ftu." else "A connection error occurred."

        fun submitQuestion(question: String) {
            val trimmed = question.trim()
            if (trimmed.isEmpty() || isStreaming) return

            activeJob?.cancel()
            askedQuestion = trimmed
            promptText = ""
            answerText = ""
            errorMessage = null
            isStreaming = true

            activeJob = scope.launch {
                try {
                    val savedModel = prefs.getString("flutter.cortex", "cortex/auto") ?: "cortex/auto"
                    val modelId = if (savedModel in setOf("trash", "recycle", "delete", "bin")) {
                        "cortex/auto"
                    } else {
                        savedModel
                    }
                    val langCode = prefs.getString("flutter.language_code", null)
                        ?: Locale.getDefault().language

                    streamAnswerFromFulcrum(
                        question = trimmed,
                        modelId = modelId,
                        langCode = langCode,
                        isTurkish = isTurkish,
                        onChunk = { chunk ->
                            answerText += chunk
                        }
                    )

                    if (answerText.isNotBlank()) {
                        prefs.edit()
                            .putString(CortexAppWidgetProvider.KEY_LAST_QUESTION, trimmed)
                            .putString(CortexAppWidgetProvider.KEY_LAST_ANSWER, answerText.trim())
                            .apply()
                        CortexAppWidgetProvider.updateAllWidgets(context)
                    }
                } catch (ce: CancellationException) {
                    throw ce
                } catch (e: Exception) {
                    errorMessage = e.localizedMessage ?: strConnError
                } finally {
                    isStreaming = false
                }
            }
        }

        val voiceLauncher = rememberLauncherForActivityResult(
            contract = ActivityResultContracts.StartActivityForResult()
        ) { result ->
            if (result.resultCode == Activity.RESULT_OK) {
                val matches = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
                val spoken = matches?.firstOrNull()
                if (!spoken.isNullOrBlank()) {
                    promptText = spoken
                    submitQuestion(spoken)
                }
            }
        }

        fun launchVoiceInput() {
            try {
                val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                    putExtra(
                        RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                        RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
                    )
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
                    putExtra(
                        RecognizerIntent.EXTRA_PROMPT,
                        if (isTurkish) "Cortex'e sor..." else "Ask Cortex..."
                    )
                }
                voiceLauncher.launch(intent)
            } catch (_: Exception) {
                Toast.makeText(
                    context,
                    strVoiceUnavailable,
                    Toast.LENGTH_SHORT
                ).show()
            }
        }

        LaunchedEffect(Unit) {
            if (initialStartVoice) {
                launchVoiceInput()
            } else {
                focusRequester.requestFocus()
            }
        }

        LaunchedEffect(answerText.length) {
            if (isStreaming) {
                answerScrollState.animateScrollTo(answerScrollState.maxValue)
            }
        }

        Box(
            modifier = Modifier
                .fillMaxSize()
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = {
                        activeJob?.cancel()
                        onDismiss()
                    }
                )
                .imePadding()
                .padding(horizontal = 16.dp, vertical = 24.dp),
            contentAlignment = Alignment.Center
        ) {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = {} // Consume clicks inside the card
                    )
                    .border(
                        width = 1.dp,
                        color = Color.White.copy(alpha = 0.16f),
                        shape = RoundedCornerShape(26.dp)
                    ),
                shape = RoundedCornerShape(26.dp),
                color = Color(0xF5161618),
                tonalElevation = 12.dp,
                shadowElevation = 24.dp
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    // Header row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                painter = painterResource(id = R.drawable.ic_widget_sparkle),
                                contentDescription = "Cortex",
                                tint = Color.White,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "Cortex AI",
                                color = Color.White,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        }

                        Row(verticalAlignment = Alignment.CenterVertically) {
                            if (askedQuestion.isNotBlank() || answerText.isNotBlank()) {
                                TextButton(
                                    onClick = {
                                        activeJob?.cancel()
                                        isStreaming = false
                                        askedQuestion = ""
                                        answerText = ""
                                        errorMessage = null
                                        prefs.edit()
                                            .remove(CortexAppWidgetProvider.KEY_LAST_QUESTION)
                                            .remove(CortexAppWidgetProvider.KEY_LAST_ANSWER)
                                            .apply()
                                        CortexAppWidgetProvider.updateAllWidgets(context)
                                    }
                                ) {
                                    Text(
                                        text = strClear,
                                        color = Color.White.copy(alpha = 0.65f),
                                        fontSize = 12.sp
                                    )
                                }
                            }

                            IconButton(
                                onClick = {
                                    activeJob?.cancel()
                                    onDismiss()
                                },
                                modifier = Modifier.size(28.dp)
                            ) {
                                Icon(
                                    painter = painterResource(id = R.drawable.ic_widget_close),
                                    contentDescription = "Close",
                                    tint = Color.White.copy(alpha = 0.65f),
                                    modifier = Modifier.size(18.dp)
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    // Input Pill Bar
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(20.dp))
                            .background(Color.White.copy(alpha = 0.08f))
                            .border(
                                width = 1.dp,
                                color = Color.White.copy(alpha = 0.12f),
                                shape = RoundedCornerShape(20.dp)
                            )
                            .padding(horizontal = 14.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier.weight(1f),
                            contentAlignment = Alignment.CenterStart
                        ) {
                            if (promptText.isEmpty()) {
                                Text(
                                    text = strHint,
                                    color = Color.White.copy(alpha = 0.45f),
                                    fontSize = 14.sp
                                )
                            }
                            BasicTextField(
                                value = promptText,
                                onValueChange = { promptText = it },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .focusRequester(focusRequester),
                                textStyle = TextStyle(
                                    color = Color.White,
                                    fontSize = 14.sp
                                ),
                                cursorBrush = SolidColor(Color.White),
                                maxLines = 3,
                                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
                                keyboardActions = KeyboardActions(
                                    onSend = { submitQuestion(promptText) }
                                )
                            )
                        }

                        Spacer(modifier = Modifier.width(6.dp))

                        // Microphone button
                        IconButton(
                            onClick = { launchVoiceInput() },
                            modifier = Modifier.size(32.dp)
                        ) {
                            Icon(
                                painter = painterResource(id = R.drawable.ic_widget_mic),
                                contentDescription = strVoiceInput,
                                tint = Color.White.copy(alpha = 0.8f),
                                modifier = Modifier.size(18.dp)
                            )
                        }

                        Spacer(modifier = Modifier.width(4.dp))

                        // Send or Stop button
                        Box(
                            modifier = Modifier
                                .size(32.dp)
                                .clip(CircleShape)
                                .background(
                                    if (isStreaming || promptText.isNotBlank()) Color.White
                                    else Color.White.copy(alpha = 0.2f)
                                )
                                .clickable(enabled = isStreaming || promptText.isNotBlank()) {
                                    if (isStreaming) {
                                        activeJob?.cancel()
                                        isStreaming = false
                                    } else {
                                        submitQuestion(promptText)
                                    }
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                painter = painterResource(
                                    id = if (isStreaming) R.drawable.ic_widget_stop
                                    else R.drawable.ic_widget_send
                                ),
                                contentDescription = if (isStreaming) "Stop" else "Send",
                                tint = Color.Black,
                                modifier = Modifier.size(if (isStreaming) 14.dp else 18.dp)
                            )
                        }
                    }

                    // Answer Area
                    AnimatedVisibility(
                        visible = askedQuestion.isNotBlank() || isStreaming || errorMessage != null,
                        enter = fadeIn() + expandVertically(),
                        exit = fadeOut() + shrinkVertically()
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 14.dp)
                        ) {
                            if (askedQuestion.isNotBlank()) {
                                Text(
                                    text = askedQuestion,
                                    color = Color.White.copy(alpha = 0.65f),
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Medium,
                                    maxLines = 2,
                                    overflow = TextOverflow.Ellipsis
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                            }

                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .heightIn(min = 48.dp, max = 260.dp)
                                    .clip(RoundedCornerShape(16.dp))
                                    .background(Color.White.copy(alpha = 0.05f))
                                    .padding(12.dp)
                                    .verticalScroll(answerScrollState)
                            ) {
                                when {
                                    errorMessage != null -> {
                                        Text(
                                            text = errorMessage ?: "",
                                            color = Color(0xFFFF6B6B),
                                            fontSize = 13.sp
                                        )
                                    }
                                    answerText.isEmpty() && isStreaming -> {
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            CircularProgressIndicator(
                                                color = Color.White,
                                                strokeWidth = 2.dp,
                                                modifier = Modifier.size(16.dp)
                                            )
                                            Spacer(modifier = Modifier.width(10.dp))
                                            Text(
                                                text = strThinking,
                                                color = Color.White.copy(alpha = 0.7f),
                                                fontSize = 13.sp
                                            )
                                        }
                                    }
                                    else -> {
                                        Text(
                                            text = answerText,
                                            color = Color.White.copy(alpha = 0.92f),
                                            fontSize = 14.sp,
                                            lineHeight = 20.sp
                                        )
                                    }
                                }
                            }

                            // Bottom Action Buttons (Copy & Continue in App)
                            if (answerText.isNotBlank() || errorMessage != null) {
                                Spacer(modifier = Modifier.height(10.dp))
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    TextButton(
                                        onClick = {
                                            val clipboard = context.getSystemService(
                                                Context.CLIPBOARD_SERVICE
                                            ) as ClipboardManager
                                            clipboard.setPrimaryClip(
                                                ClipData.newPlainText("Cortex AI", answerText)
                                            )
                                            Toast.makeText(
                                                context,
                                                strCopied,
                                                Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                    ) {
                                        Text(
                                            text = strCopy,
                                            color = Color.White.copy(alpha = 0.8f),
                                            fontSize = 13.sp
                                        )
                                    }

                                    TextButton(
                                        onClick = {
                                            onOpenInApp(askedQuestion, answerText)
                                        }
                                    ) {
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            Text(
                                                text = strContinueInApp,
                                                color = Color.White,
                                                fontSize = 13.sp,
                                                fontWeight = FontWeight.SemiBold
                                            )
                                            Spacer(modifier = Modifier.width(6.dp))
                                            Icon(
                                                painter = painterResource(id = R.drawable.ic_widget_arrow_right),
                                                contentDescription = null,
                                                tint = Color.White,
                                                modifier = Modifier.size(16.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private suspend fun streamAnswerFromFulcrum(
        question: String,
        modelId: String,
        langCode: String,
        isTurkish: Boolean,
        onChunk: (String) -> Unit
    ) {
        val auth = FirebaseAuth.getInstance()
        var user = auth.currentUser
        if (user == null) {
            try {
                user = auth.signInAnonymously().await().user
            } catch (_: Exception) {
            }
        }
        val currentUser = user ?: throw IllegalStateException(
            if (isTurkish) "L\u00FCtfen \u00F6nce Cortex uygulamas\u0131n\u0131 bir kez a\u00E7\u0131n."
            else "Please open the Cortex app once to initialize your session."
        )

        val tokenResult = currentUser.getIdToken(false).await()
        val idToken = tokenResult.token ?: throw IllegalStateException(
            if (isTurkish) "Oturum do\u011Frulanamad\u0131." else "Authentication failed."
        )

        val appCheckToken = try {
            withContext(Dispatchers.IO) {
                withTimeout(1_500) {
                    FirebaseAppCheck.getInstance().getAppCheckToken(false).await().token
                }
            }
        } catch (_: Exception) {
            null
        }

        withContext(Dispatchers.IO) {
            val url = URL(PROXY_URL)
            val conn = (url.openConnection() as HttpURLConnection).apply {
                requestMethod = "POST"
                connectTimeout = 20_000
                readTimeout = 120_000
                doOutput = true
                doInput = true
                setRequestProperty("Authorization", "Bearer $idToken")
                if (!appCheckToken.isNullOrBlank()) {
                    setRequestProperty("X-Firebase-AppCheck", appCheckToken)
                }
                setRequestProperty("Content-Type", "application/json; charset=UTF-8")
                setRequestProperty("Accept", "text/event-stream")
                setRequestProperty("Cache-Control", "no-cache")
            }

            try {
                val payload = JSONObject().apply {
                    put("generationId", UUID.randomUUID().toString())
                    put("model", modelId)
                    put("stream", true)
                    put("langCode", langCode)
                    put(
                        "messages",
                        JSONArray().put(
                            JSONObject().apply {
                                put("role", "user")
                                put("content", question)
                            }
                        )
                    )
                }

                conn.outputStream.use { os ->
                    os.write(payload.toString().toByteArray(Charsets.UTF_8))
                    os.flush()
                }

                val code = conn.responseCode
                if (code !in 200..299) {
                    throw IllegalStateException(
                        if (isTurkish) "Sunucu yan\u0131t vermedi ($code)."
                        else "Server returned status $code."
                    )
                }

                var currentEvent = ""
                BufferedReader(InputStreamReader(conn.inputStream, Charsets.UTF_8)).use { reader ->
                    var line: String?
                    while (reader.readLine().also { line = it } != null) {
                        val rawLine = line ?: continue
                        if (rawLine.startsWith("event: ")) {
                            currentEvent = rawLine.substring(7).trim()
                            continue
                        }
                        if (rawLine.startsWith("data: ")) {
                            val dataStr = rawLine.substring(6).trim()
                            if (dataStr.isEmpty() || dataStr == "[DONE]") continue

                            try {
                                val json = JSONObject(dataStr)
                                if (currentEvent == "error") {
                                    val errMsg = json.optString("message").ifBlank {
                                        if (isTurkish) "\u0130stek tamamlanamad\u0131."
                                        else "Request could not be completed."
                                    }
                                    throw IllegalStateException(errMsg)
                                }

                                if (currentEvent in setOf("text_chunk", "text_delta", "message_delta", "")) {
                                    val chunk = extractTextFromEvent(json)
                                    if (!chunk.isNullOrEmpty()) {
                                        withContext(Dispatchers.Main) {
                                            onChunk(chunk)
                                        }
                                    }
                                }
                            } catch (ie: IllegalStateException) {
                                throw ie
                            } catch (_: Exception) {
                                // Ignore non-text JSON lines
                            }
                        }
                    }
                }
            } finally {
                conn.disconnect()
            }
        }
    }

    private fun extractTextFromEvent(json: JSONObject): String? {
        for (key in listOf("text", "content", "delta", "output_text", "message")) {
            val value = json.opt(key)
            if (value is String && value.isNotEmpty()) return value
            if (value is JSONObject) {
                val nested = extractTextFromEvent(value)
                if (!nested.isNullOrEmpty()) return nested
            }
        }
        val choices = json.optJSONArray("choices")
        if (choices != null && choices.length() > 0) {
            val first = choices.optJSONObject(0)
            if (first != null) {
                val nested = extractTextFromEvent(first)
                if (!nested.isNullOrEmpty()) return nested
            }
        }
        return null
    }
}
