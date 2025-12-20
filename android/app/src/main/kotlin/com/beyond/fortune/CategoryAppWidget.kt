package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

/**
 * Category Fortune Widget
 * Displays fortune for a specific category (love/money/work/study/health)
 */
class CategoryAppWidget : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        // Category icons mapping
        private val categoryIcons = mapOf(
            "love" to "💕",
            "money" to "💰",
            "work" to "💼",
            "study" to "📚",
            "health" to "🏃"
        )

        // Category names mapping
        private val categoryNames = mapOf(
            "love" to "연애운",
            "money" to "금전운",
            "work" to "직장운",
            "study" to "학업운",
            "health" to "건강운"
        )

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences = context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

            // Get selected category or default to "love"
            val categoryKey = prefs.getString("flutter.category_key", "love") ?: "love"
            val categoryName = prefs.getString("flutter.category_name", categoryNames[categoryKey])
                ?: categoryNames[categoryKey] ?: "연애운"
            val score = prefs.getLong("flutter.category_score", 75L).toInt()
            val message = prefs.getString("flutter.category_message", "좋은 인연을 만날 수 있는 날입니다.")
                ?: "좋은 인연을 만날 수 있는 날입니다."
            val icon = prefs.getString("flutter.category_icon", categoryIcons[categoryKey])
                ?: categoryIcons[categoryKey] ?: "💕"

            // Create RemoteViews
            val views = RemoteViews(context.packageName, R.layout.category_widget)

            views.setTextViewText(R.id.category_icon, icon)
            views.setTextViewText(R.id.category_name, categoryName)
            views.setTextViewText(R.id.category_score, score.toString())
            views.setTextViewText(R.id.category_message, message)

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
