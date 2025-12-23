package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews

/**
 * Category Fortune Widget
 * Displays fortune for a specific category (love/money/work/study/health)
 * Supports engagement states: today, yesterday, empty
 */
class CategoryAppWidget : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        // Display state constants
        private const val STATE_TODAY = "today"
        private const val STATE_YESTERDAY = "yesterday"
        private const val STATE_EMPTY = "empty"

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

        // Category engagement messages
        private val categoryEngagementMessages = mapOf(
            "love" to "오늘의 연애운 확인 💕",
            "money" to "오늘의 금전운 확인 💰",
            "work" to "오늘의 직장운 확인 💼",
            "study" to "오늘의 학업운 확인 📚",
            "health" to "오늘의 건강운 확인 🏃"
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

            // Get engagement state (saved by Flutter's HomeWidget)
            val displayState = prefs.getString("flutter.display_state", STATE_TODAY) ?: STATE_TODAY
            val engagementMessage = categoryEngagementMessages[categoryKey] ?: "오늘의 운세 확인 ✨"

            // Create RemoteViews
            val views = RemoteViews(context.packageName, R.layout.category_widget)

            views.setTextViewText(R.id.category_icon, icon)
            views.setTextViewText(R.id.category_name, categoryName)

            // Handle different display states
            when (displayState) {
                STATE_TODAY -> {
                    // Normal state - show today's data
                    views.setTextViewText(R.id.category_score, score.toString())
                    views.setTextViewText(R.id.category_message, message)
                    views.setViewVisibility(R.id.engagement_badge, View.GONE)
                    views.setInt(R.id.category_score, "setAlpha", 255)
                }
                STATE_YESTERDAY -> {
                    // Yesterday data - show with reduced opacity + engagement badge
                    views.setTextViewText(R.id.category_score, score.toString())
                    views.setTextViewText(R.id.category_message, message)
                    views.setTextViewText(R.id.engagement_badge, engagementMessage)
                    views.setViewVisibility(R.id.engagement_badge, View.VISIBLE)
                    // 50% opacity for score (128/255)
                    views.setInt(R.id.category_score, "setAlpha", 128)
                }
                STATE_EMPTY -> {
                    // Empty state - show placeholder
                    views.setTextViewText(R.id.category_score, "?")
                    views.setTextViewText(R.id.category_message, "${categoryName}을 받아보세요")
                    views.setTextViewText(R.id.engagement_badge, "터치해서 운세 확인 ✨")
                    views.setViewVisibility(R.id.engagement_badge, View.VISIBLE)
                    views.setInt(R.id.category_score, "setAlpha", 255)
                }
                else -> {
                    // Default to today state
                    views.setTextViewText(R.id.category_score, score.toString())
                    views.setTextViewText(R.id.category_message, message)
                    views.setViewVisibility(R.id.engagement_badge, View.GONE)
                    views.setInt(R.id.category_score, "setAlpha", 255)
                }
            }

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
