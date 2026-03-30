package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.util.Log

/**
 * Love Fortune Widget Provider
 *
 * Displays love compatibility fortune data from Flutter app via SharedPreferences
 * Data is saved by home_widget package with "flutter." prefix
 */
class FortuneLoveWidget : AppWidgetProvider() {

    companion object {
        private const val TAG = "FortuneLoveWidget"
        private const val PREFS_NAME = "FlutterSharedPreferences"

        // Keys match Flutter HomeWidget.saveWidgetData keys (with flutter. prefix)
        private const val KEY_COMPATIBILITY_SCORE = "flutter.compatibilityScore"
        private const val KEY_PARTNER_NAME = "flutter.partnerName"
        private const val KEY_LOVE_MESSAGE = "flutter.loveMessage"
        private const val KEY_LAST_UPDATED = "flutter.lastUpdated"
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
        val compatibilityScore = prefs.getString(KEY_COMPATIBILITY_SCORE, "0") ?: "0"
        val partnerName = prefs.getString(KEY_PARTNER_NAME, "") ?: ""
        val loveMessage = prefs.getString(KEY_LOVE_MESSAGE, "궁합 정보를 불러오는 중...") ?: "궁합 정보를 불러오는 중..."
        val lastUpdated = prefs.getString(KEY_LAST_UPDATED, "--:--") ?: "--:--"

        Log.d(TAG, "Widget data - score: $compatibilityScore, partner: $partnerName")

        // Create RemoteViews
        val views = RemoteViews(context.packageName, R.layout.fortune_love_widget)

        // Bind data to views
        views.setTextViewText(R.id.compatibility_score, "${compatibilityScore}%")
        views.setTextViewText(R.id.last_updated, lastUpdated)
        views.setTextViewText(R.id.love_message, loveMessage)

        // Partner name display
        val partnerDisplay = if (partnerName.isNotEmpty()) {
            "${partnerName}님과의 궁합"
        } else {
            "연애운 궁합"
        }
        views.setTextViewText(R.id.partner_name, partnerDisplay)

        // Set progress bar
        try {
            val scoreInt = compatibilityScore.toIntOrNull() ?: 0
            views.setProgressBar(R.id.compatibility_progress, 100, scoreInt, false)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to set progress bar: ${e.message}")
        }

        // Set click intent to open app
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("source", "widget_love")
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            1, // Different request code from daily widget
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        // Update widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d(TAG, "Widget $appWidgetId updated successfully")
    }
}
