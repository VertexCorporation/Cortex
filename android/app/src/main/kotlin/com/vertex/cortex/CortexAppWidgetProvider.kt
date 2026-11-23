package com.vertex.cortex

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

open class CortexAppWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "FlutterSharedPreferences"
        const val KEY_LAST_QUESTION = "flutter.widget_last_question"
        const val KEY_LAST_ANSWER = "flutter.widget_last_answer"

        const val EXTRA_START_VOICE = "extra_start_voice"

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, CortexQuickChatSchemaHomeWidgetReceiver::class.java)
            val ids = manager.getAppWidgetIds(componentName)
            if (ids.isNotEmpty()) {
                for (id in ids) {
                    updateAppWidget(context, manager, id)
                }
            }
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.cortex_widget)

            // Intent to open the floating Quick Ask overlay activity (keyboard mode)
            val askIntent = Intent(context, CortexWidgetAskActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra(EXTRA_START_VOICE, false)
            }
            val askPendingIntent = PendingIntent.getActivity(
                context,
                0,
                askIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Intent to open the floating Quick Ask overlay activity (voice recognition mode)
            val voiceIntent = Intent(context, CortexWidgetAskActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra(EXTRA_START_VOICE, true)
            }
            val voicePendingIntent = PendingIntent.getActivity(
                context,
                1,
                voiceIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.widget_root, askPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_search_bar, askPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_voice_btn, voicePendingIntent)

            // Load recent widget Q&A if available
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val lastQuestion = prefs.getString(KEY_LAST_QUESTION, null)
            val lastAnswer = prefs.getString(KEY_LAST_ANSWER, null)

            if (!lastQuestion.isNullOrBlank() && !lastAnswer.isNullOrBlank()) {
                views.setViewVisibility(R.id.widget_last_qa_container, View.VISIBLE)
                views.setTextViewText(R.id.widget_last_question, lastQuestion)
                views.setTextViewText(R.id.widget_last_answer, lastAnswer)
                views.setOnClickPendingIntent(R.id.widget_last_qa_container, askPendingIntent)
            } else {
                views.setViewVisibility(R.id.widget_last_qa_container, View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
}
