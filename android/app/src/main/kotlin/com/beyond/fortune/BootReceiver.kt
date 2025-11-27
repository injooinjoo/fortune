package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Boot Receiver for Fortune Widgets
 *
 * Refreshes all widgets when the device boots up.
 * This ensures widgets display the latest cached data after a restart.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Boot completed - refreshing widgets")
            refreshAllWidgets(context)
        }
    }

    private fun refreshAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)

        // Refresh Daily Fortune Widgets
        try {
            val dailyWidgetProvider = ComponentName(context, FortuneDailyWidget::class.java)
            val dailyWidgetIds = appWidgetManager.getAppWidgetIds(dailyWidgetProvider)

            if (dailyWidgetIds.isNotEmpty()) {
                val updateIntent = Intent(context, FortuneDailyWidget::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, dailyWidgetIds)
                }
                context.sendBroadcast(updateIntent)
                Log.d(TAG, "Refreshed ${dailyWidgetIds.size} daily widgets")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to refresh daily widgets: ${e.message}")
        }

        // Refresh Love Fortune Widgets
        try {
            val loveWidgetProvider = ComponentName(context, FortuneLoveWidget::class.java)
            val loveWidgetIds = appWidgetManager.getAppWidgetIds(loveWidgetProvider)

            if (loveWidgetIds.isNotEmpty()) {
                val updateIntent = Intent(context, FortuneLoveWidget::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, loveWidgetIds)
                }
                context.sendBroadcast(updateIntent)
                Log.d(TAG, "Refreshed ${loveWidgetIds.size} love widgets")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to refresh love widgets: ${e.message}")
        }

        // Refresh Favorites Fortune Widgets
        try {
            val favoritesWidgetProvider = ComponentName(context, FavoritesAppWidget::class.java)
            val favoritesWidgetIds = appWidgetManager.getAppWidgetIds(favoritesWidgetProvider)

            if (favoritesWidgetIds.isNotEmpty()) {
                val updateIntent = Intent(context, FavoritesAppWidget::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, favoritesWidgetIds)
                }
                context.sendBroadcast(updateIntent)
                Log.d(TAG, "Refreshed ${favoritesWidgetIds.size} favorites widgets")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to refresh favorites widgets: ${e.message}")
        }
    }
}
