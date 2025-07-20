package com.fortune.fortune

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import android.content.Intent

class WidgetUpdateWorker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {
    
    override fun doWork(): Result {
        try {
            // Update all widgets
            updateAllWidgets()
            return Result.success()
        } catch (e: Exception) {
            e.printStackTrace()
            return Result.retry()
        }
    }
    
    private fun updateAllWidgets() {
        val context = applicationContext
        val appWidgetManager = AppWidgetManager.getInstance(context)
        
        // Update daily fortune widgets
        val dailyWidgetProvider = ComponentName(context, FortuneDailyWidget::class.java)
        val dailyWidgetIds = appWidgetManager.getAppWidgetIds(dailyWidgetProvider)
        if (dailyWidgetIds.isNotEmpty()) {
            val updateIntent = Intent(context, FortuneDailyWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, dailyWidgetIds)
            }
            context.sendBroadcast(updateIntent)
        }
        
        // Update love fortune widgets
        val loveWidgetProvider = ComponentName(context, FortuneLoveWidget::class.java)
        val loveWidgetIds = appWidgetManager.getAppWidgetIds(loveWidgetProvider)
        if (loveWidgetIds.isNotEmpty()) {
            val updateIntent = Intent(context, FortuneLoveWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, loveWidgetIds)
            }
            context.sendBroadcast(updateIntent)
        }
    }
}