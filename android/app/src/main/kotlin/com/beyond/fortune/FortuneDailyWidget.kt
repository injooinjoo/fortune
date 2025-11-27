package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.util.Log

/**
 * Daily Fortune Widget Provider
 *
 * Displays daily fortune data from Flutter app via SharedPreferences
 * Data is saved by home_widget package with "flutter." prefix
 */
class FortuneDailyWidget : AppWidgetProvider() {

    companion object {
        private const val TAG = "FortuneDailyWidget"
        private const val PREFS_NAME = "FlutterSharedPreferences"

        // Keys match Flutter HomeWidget.saveWidgetData keys (with flutter. prefix)
        private const val KEY_SCORE = "flutter.score"
        private const val KEY_MESSAGE = "flutter.message"
        private const val KEY_LAST_UPDATED = "flutter.lastUpdated"
        private const val KEY_LUCKY_COLOR = "flutter.luckyColor"
        private const val KEY_LUCKY_NUMBER = "flutter.luckyNumber"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")

        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        Log.d(TAG, "Widget enabled")
    }

    override fun onDisabled(context: Context) {
        Log.d(TAG, "Widget disabled")
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Read data from SharedPreferences (saved by Flutter)
        val score = prefs.getString(KEY_SCORE, "0") ?: "0"
        val message = prefs.getString(KEY_MESSAGE, "운세를 불러오는 중...") ?: "운세를 불러오는 중..."
        val lastUpdated = prefs.getString(KEY_LAST_UPDATED, "--:--") ?: "--:--"
        val luckyColor = prefs.getString(KEY_LUCKY_COLOR, "-") ?: "-"
        val luckyNumber = prefs.getString(KEY_LUCKY_NUMBER, "-") ?: "-"

        Log.d(TAG, "Widget data - score: $score, message: $message, lastUpdated: $lastUpdated")

        // Create RemoteViews
        val views = RemoteViews(context.packageName, R.layout.fortune_daily_widget)

        // Bind data to views
        views.setTextViewText(R.id.fortune_score, score)
        views.setTextViewText(R.id.fortune_message, message)
        views.setTextViewText(R.id.last_updated, lastUpdated)
        views.setTextViewText(R.id.lucky_color, luckyColor)
        views.setTextViewText(R.id.lucky_number, luckyNumber)

        // Set click intent to open app
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("source", "widget_daily")
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        // Update widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d(TAG, "Widget $appWidgetId updated successfully")
    }
}
