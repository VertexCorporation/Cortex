// GENERATED CODE - DO NOT MODIFY BY HAND
package com.vertex.cortex

import android.content.Context
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class CortexTasksSchemaHomeWidgetReceiver : HomeWidgetGlanceWidgetReceiver<CortexTasksSchemaHomeWidget>() {
  override val glanceAppWidget = CortexTasksSchemaHomeWidget()

  override fun previewFingerprint(context: Context): String =
      glanceAppWidget.previewFingerprint(context)
}
