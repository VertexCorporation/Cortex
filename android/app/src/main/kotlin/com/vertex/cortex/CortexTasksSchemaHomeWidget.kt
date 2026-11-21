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
import androidx.glance.text.TextStyle
import androidx.glance.color.ColorProvider
import androidx.compose.ui.unit.sp
import androidx.glance.text.FontWeight
import androidx.glance.layout.height
import androidx.compose.ui.unit.dp
import androidx.glance.layout.Spacer
import androidx.glance.layout.padding
import androidx.glance.appwidget.cornerRadius
import androidx.core.os.ConfigurationCompat
import java.util.Locale
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
import android.net.Uri
import es.antonborri.home_widget.actionStartActivity

class CortexTasksSchemaHomeWidget : GlanceAppWidget() {
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
        CortexTasksSchemaData.fromPreferences(HomeWidgetPlugin.getData(context))
    return listOf(
      "93fd12a2",
      hwLocales.joinToString(","),
      hwPreviewData.toString(),
    ).joinToString("|")
  }

  @Composable
  private fun WidgetContent(context: Context, currentState: HomeWidgetGlanceState) {
    val prefs = currentState.preferences
    val widgetData = CortexTasksSchemaData.fromPreferences(prefs)
    GlanceTheme {
            Box(modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground).padding(16.dp).fillMaxSize().clickable(onClick = actionStartActivity<MainActivity>(context, Uri.parse("cortex://tasks?homeWidget"))), contentAlignment = Alignment.Center) {
                Box(
                    modifier = GlanceModifier.background(ColorProvider(day = Color(0xFF343540), night = Color(0xFF343540))).cornerRadius(24.0.dp).padding(1.0.dp)
                ) {
                    Box(
                        modifier = GlanceModifier.background(ColorProvider(day = Color(0xFF171820), night = Color(0xFF171820))).cornerRadius(23.0.dp)
                    ) {
                        Column(modifier = GlanceModifier.padding(start = 16.0.dp, top = 16.0.dp, end = 16.0.dp, bottom = 16.0.dp), horizontalAlignment = Alignment.Start) {
                            Text(text = "CORTEX  ·  TASKS", style = TextStyle(color = ColorProvider(day = Color(0xFFBDA7FF), night = Color(0xFFBDA7FF)), fontSize = 12.sp, fontWeight = FontWeight.Bold))
                            Spacer(modifier = GlanceModifier.height(10.0.dp))
                            Text(text = widgetData.nextTask ?: "", style = TextStyle(color = ColorProvider(day = Color(0xFFF5F3FA), night = Color(0xFFF5F3FA)), fontSize = 22.sp, fontWeight = FontWeight.Bold))
                            Spacer(modifier = GlanceModifier.height(6.0.dp))
                            Text(text = widgetData.taskCount ?: "", style = TextStyle(color = ColorProvider(day = Color(0xFFAAA9B4), night = Color(0xFFAAA9B4)), fontSize = 12.sp, fontWeight = FontWeight.Normal))
                        }
                    }
                }
            }
    }

  }
}

data class CortexTasksSchemaData(
    val nextTask: String? = null,
    val taskCount: String? = null,
) {
    companion object {
        private const val PREFERENCES_PREFIX = "home_widget.CortexTasksSchema"

        fun fromPreferences(prefs: android.content.SharedPreferences): CortexTasksSchemaData {
            return CortexTasksSchemaData(
                nextTask = prefs.getString("${PREFERENCES_PREFIX}.nextTask", "No tasks yet"),
                taskCount = prefs.getString("${PREFERENCES_PREFIX}.taskCount", "Open your Cortex tasks"),
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
