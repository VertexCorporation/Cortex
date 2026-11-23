// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This is a placeholder Glance (Jetpack Compose) widget.
package com.vertex.cortex

import androidx.compose.runtime.Composable
import android.content.Context
import androidx.compose.ui.graphics.Color
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.text.Text
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetPlugin
import androidx.glance.layout.Column
import androidx.glance.layout.Alignment
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.text.TextStyle
import androidx.glance.color.ColorProvider
import androidx.compose.ui.unit.sp
import androidx.glance.text.FontWeight
import androidx.glance.layout.height
import androidx.compose.ui.unit.dp
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.appwidget.cornerRadius
import androidx.core.os.ConfigurationCompat
import java.util.Locale
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
import android.net.Uri
import es.antonborri.home_widget.actionStartActivity

class CortexQuickChatSchemaHomeWidget : GlanceAppWidget() {
  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { WidgetContent(context, currentState()) }
  }

  override suspend fun providePreview(context: Context, widgetCategory: Int) {
    provideContent { WidgetContent(context, HomeWidgetGlanceState(HomeWidgetPlugin.getData(context))) }
  }

  fun previewFingerprint(context: Context): String {
    val hwLocales = hwCurrentLocales(context)
    val hwPreviewData =
        CortexQuickChatSchemaData.fromPreferences(HomeWidgetPlugin.getData(context))
    return listOf(
      "9b768c17",
      hwLocales.joinToString(","),
      hwPreviewData.toString(),
    ).joinToString("|")
  }

  @Composable
  private fun WidgetContent(context: Context, currentState: HomeWidgetGlanceState) {
    val prefs = currentState.preferences
    val widgetData = CortexQuickChatSchemaData.fromPreferences(prefs)
    GlanceTheme {
            Box(modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground).fillMaxSize().clickable(onClick = actionStartActivity<MainActivity>(context, Uri.parse("cortex://chat?homeWidget"))), contentAlignment = Alignment.Center) {
                Box(
                    modifier = GlanceModifier.fillMaxSize().background(ColorProvider(day = Color(0xFFE2E5EC), night = Color(0xFF30333D))).cornerRadius(22.0.dp).padding(1.0.dp)
                ) {
                    Box(
                        modifier = GlanceModifier.fillMaxSize().background(ColorProvider(day = Color(0xFFFFFFFF), night = Color(0xFF101116))).cornerRadius(21.0.dp)
                    ) {
                        Column(modifier = GlanceModifier.fillMaxSize().padding(start = 14.0.dp, top = 12.0.dp, end = 14.0.dp, bottom = 12.0.dp), horizontalAlignment = Alignment.Start) {
                            Spacer(modifier = GlanceModifier.defaultWeight())
                            Text(text = "CORTEX AI", style = TextStyle(color = ColorProvider(day = Color(0xFF3366E8), night = Color(0xFF91A9FF)), fontSize = 11.sp, fontWeight = FontWeight.Bold))
                            Spacer(modifier = GlanceModifier.height(9.0.dp))
                            Row(modifier = GlanceModifier.background(ColorProvider(day = Color(0xFFF3F5F9), night = Color(0xFF1B1E26))).cornerRadius(16.0.dp).padding(start = 12.0.dp, top = 10.0.dp, end = 12.0.dp, bottom = 10.0.dp).fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                                Text(text = widgetData.messageHint ?: "", style = TextStyle(color = ColorProvider(day = Color(0xFF737985), night = Color(0xFFADB3C0)), fontSize = 14.sp))
                                Spacer(modifier = GlanceModifier.defaultWeight())
                                Text(text = "↗", style = TextStyle(color = ColorProvider(day = Color(0xFF3366E8), night = Color(0xFF91A9FF)), fontSize = 18.sp, fontWeight = FontWeight.Bold))
                            }
                            Spacer(modifier = GlanceModifier.defaultWeight())
                        }
                    }
                }
            }
    }

  }
}

data class CortexQuickChatSchemaData(
    val messageHint: String? = null,
) {
    companion object {
        private const val PREFERENCES_PREFIX = "home_widget.CortexQuickChatSchema"

        fun fromPreferences(prefs: android.content.SharedPreferences): CortexQuickChatSchemaData {
            return CortexQuickChatSchemaData(
                messageHint = prefs.getString("${PREFERENCES_PREFIX}.messageHint", "Ask anything"),
            )
        }
    }
}


private fun hwCurrentLocales(context: Context): List<String> {
    val configured = ConfigurationCompat
        .getLocales(context.resources.configuration)
    val tags = mutableListOf<String>()
    for (index in 0 until configured.size()) {
        val locale = configured[index] ?: continue
        val tag = locale.toLanguageTag()
        if (tag.isNotEmpty() && tag != "und") tags.add(tag)
    }
    if (tags.isEmpty()) {
        val fallback = Locale.getDefault().toLanguageTag()
        if (fallback.isNotEmpty() && fallback != "und") tags.add(fallback)
    }
    return tags
}
