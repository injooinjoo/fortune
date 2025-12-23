package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

/**
 * Overall Fortune Widget
 * Displays total fortune score, grade, and message
 * Supports engagement states: today, yesterday, empty
 */
class OverallAppWidget : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        // Display state constants
        private const val STATE_TODAY = "today"
        private const val STATE_YESTERDAY = "yesterday"
        private const val STATE_EMPTY = "empty"

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

            // Get engagement state (saved by Flutter's HomeWidget)
            val displayState = prefs.getString("flutter.display_state", STATE_TODAY) ?: STATE_TODAY
            val engagementMessage = prefs.getString("flutter.engagement_message", "오늘의 운세 미리보기 🔮")
                ?: "오늘의 운세 미리보기 🔮"

            // Create RemoteViews
            val views = RemoteViews(context.packageName, R.layout.overall_widget)

            // Handle different display states
            when (displayState) {
                STATE_TODAY -> {
                    // Normal state - show today's data
                    views.setTextViewText(R.id.overall_score, score.toString())
                    views.setTextViewText(R.id.overall_grade, grade)
                    views.setTextViewText(R.id.overall_message, message)
                    views.setViewVisibility(R.id.engagement_badge, View.GONE)
                    // Full opacity
                    views.setInt(R.id.overall_score, "setAlpha", 255)
                }
                STATE_YESTERDAY -> {
                    // Yesterday data - show with reduced opacity + engagement badge
                    views.setTextViewText(R.id.overall_score, score.toString())
                    views.setTextViewText(R.id.overall_grade, "어제")
                    views.setTextViewText(R.id.overall_message, message)
                    views.setTextViewText(R.id.engagement_badge, engagementMessage)
                    views.setViewVisibility(R.id.engagement_badge, View.VISIBLE)
                    // 50% opacity for score (128/255)
                    views.setInt(R.id.overall_score, "setAlpha", 128)
                }
                STATE_EMPTY -> {
                    // Empty state - show placeholder
                    views.setTextViewText(R.id.overall_score, "?")
                    views.setTextViewText(R.id.overall_grade, "-")
                    views.setTextViewText(R.id.overall_message, "운세를 받아보세요")
                    views.setTextViewText(R.id.engagement_badge, "터치해서 오늘 운세 확인 ✨")
                    views.setViewVisibility(R.id.engagement_badge, View.VISIBLE)
                    views.setInt(R.id.overall_score, "setAlpha", 255)
                }
                else -> {
                    // Default to today state
                    views.setTextViewText(R.id.overall_score, score.toString())
                    views.setTextViewText(R.id.overall_grade, grade)
                    views.setTextViewText(R.id.overall_message, message)
                    views.setViewVisibility(R.id.engagement_badge, View.GONE)
                    views.setInt(R.id.overall_score, "setAlpha", 255)
                }
            }

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
