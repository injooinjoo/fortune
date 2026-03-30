package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import java.util.*

/**
 * Time Slot Fortune Widget
 * Displays fortune based on current time of day (morning/afternoon/evening)
 */
class TimeSlotAppWidget : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        // Time slot configuration
        private enum class TimeSlot(val key: String, val displayName: String, val icon: String) {
            MORNING("morning", "오전 운세", "🌅"),
            AFTERNOON("afternoon", "오후 운세", "☀️"),
            EVENING("evening", "저녁 운세", "🌙")
        }

        private fun getCurrentTimeSlot(): TimeSlot {
            val calendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul"))
            val hour = calendar.get(Calendar.HOUR_OF_DAY)

            return when {
                hour in 6..11 -> TimeSlot.MORNING
                hour in 12..17 -> TimeSlot.AFTERNOON
                else -> TimeSlot.EVENING
            }
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences = context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

            val currentSlot = getCurrentTimeSlot()

            // Get widget data from SharedPreferences
            val slotName = prefs.getString("flutter.timeslot_name", currentSlot.displayName)
                ?: currentSlot.displayName
            val score = prefs.getLong("flutter.timeslot_score", 75L).toInt()
            val message = prefs.getString("flutter.timeslot_message", "이 시간대에 좋은 일이 있을 예정입니다.")
                ?: "이 시간대에 좋은 일이 있을 예정입니다."
            val icon = prefs.getString("flutter.timeslot_icon", currentSlot.icon)
                ?: currentSlot.icon
            val lastUpdated = prefs.getString("flutter.last_updated", "--:--") ?: "--:--"

            // Create RemoteViews
            val views = RemoteViews(context.packageName, R.layout.timeslot_widget)

            views.setTextViewText(R.id.timeslot_icon, icon)
            views.setTextViewText(R.id.timeslot_name, slotName)
            views.setTextViewText(R.id.timeslot_score, score.toString())
            views.setTextViewText(R.id.timeslot_message, message)
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
