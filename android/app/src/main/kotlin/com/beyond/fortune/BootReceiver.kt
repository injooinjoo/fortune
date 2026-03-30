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

        // Legacy widgets
        refreshWidget(context, appWidgetManager, FortuneDailyWidget::class.java, "daily")
        refreshWidget(context, appWidgetManager, FortuneLoveWidget::class.java, "love")
        refreshWidget(context, appWidgetManager, FavoritesAppWidget::class.java, "favorites")

        // New unified widgets (4 types based on fortune-daily data)
        refreshWidget(context, appWidgetManager, OverallAppWidget::class.java, "overall")
        refreshWidget(context, appWidgetManager, CategoryAppWidget::class.java, "category")
        refreshWidget(context, appWidgetManager, TimeSlotAppWidget::class.java, "timeslot")
        refreshWidget(context, appWidgetManager, LottoAppWidget::class.java, "lotto")
    }

    private fun <T> refreshWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetClass: Class<T>,
        name: String
    ) {
        try {
            val provider = ComponentName(context, widgetClass)
            val widgetIds = appWidgetManager.getAppWidgetIds(provider)

            if (widgetIds.isNotEmpty()) {
                val updateIntent = Intent(context, widgetClass).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
                }
                context.sendBroadcast(updateIntent)
                Log.d(TAG, "Refreshed ${widgetIds.size} $name widgets")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to refresh $name widgets: ${e.message}")
        }
    }
}
