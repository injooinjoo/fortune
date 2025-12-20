package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

/**
 * Overall Fortune Widget
 * Displays total fortune score, grade, and message
 */
class OverallAppWidget : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences = context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

            // Get widget data from SharedPreferences
            val score = prefs.getLong("flutter.overall_score", 75L).toInt()
            val grade = prefs.getString("flutter.overall_grade", "B+") ?: "B+"
            val message = prefs.getString("flutter.overall_message", "오늘 하루도 좋은 기운이 함께합니다.")
                ?: "오늘 하루도 좋은 기운이 함께합니다."
            val lastUpdated = prefs.getString("flutter.last_updated", "--:--") ?: "--:--"

            // Create RemoteViews
            val views = RemoteViews(context.packageName, R.layout.overall_widget)

            views.setTextViewText(R.id.overall_score, score.toString())
            views.setTextViewText(R.id.overall_grade, grade)
            views.setTextViewText(R.id.overall_message, message)
            views.setTextViewText(R.id.last_updated, lastUpdated)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update all widget instances
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Called when the last widget is removed
    }
}
