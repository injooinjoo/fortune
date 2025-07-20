package com.fortune.fortune

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONObject

class FortuneDailyWidget : AppWidgetProvider() {
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update each widget instance
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }
    
    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
    
    companion object {
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // Get stored widget data
            val prefs = context.getSharedPreferences("FortuneWidgetPrefs", Context.MODE_PRIVATE)
            val widgetDataJson = prefs.getString("widget_fortune_daily", null)
            
            // Parse widget data
            var fortuneScore = "?"
            var fortuneMessage = "운세를 확인하려면 앱을 열어주세요"
            var lastUpdated = ""
            
            if (widgetDataJson != null) {
                try {
                    val data = JSONObject(widgetDataJson)
                    fortuneScore = data.optString("score", "?")
                    fortuneMessage = data.optString("message", fortuneMessage)
                    lastUpdated = data.optString("lastUpdated", "")
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            
            // Construct the RemoteViews object
            val views = RemoteViews(context.packageName, R.layout.fortune_daily_widget)
            views.setTextViewText(R.id.fortune_score, fortuneScore)
            views.setTextViewText(R.id.fortune_message, fortuneMessage)
            views.setTextViewText(R.id.last_updated, lastUpdated)
            
            // Create an Intent to launch the app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                putExtra("widget_type", "daily_fortune")
            }
            
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            
            // Instruct the widget manager to update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}