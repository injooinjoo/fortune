package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import androidx.work.*
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit

/**
 * WorkManager Worker for background widget data refresh
 * Runs daily at dawn (around 3 AM) to fetch new fortune data
 */
class WidgetRefreshWorker(
    context: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(context, workerParams) {

    companion object {
        private const val TAG = "WidgetRefreshWorker"
        private const val WORK_NAME = "fortune_widget_refresh"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val VALID_DATE_KEY = "flutter.valid_date"

        /**
         * Schedule periodic widget refresh work
         * Runs once per day with network connectivity requirement
         */
        fun schedulePeriodicRefresh(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()

            // Calculate initial delay to target 3 AM
            val initialDelay = calculateDelayTo3AM()

            val workRequest = PeriodicWorkRequestBuilder<WidgetRefreshWorker>(
                24, TimeUnit.HOURS  // Repeat daily
            )
                .setConstraints(constraints)
                .setInitialDelay(initialDelay, TimeUnit.MILLISECONDS)
                .addTag(WORK_NAME)
                .build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    WORK_NAME,
                    ExistingPeriodicWorkPolicy.KEEP,
                    workRequest
                )

            Log.i(TAG, "Widget refresh scheduled with initial delay: ${initialDelay / 1000 / 60} minutes")
        }

        /**
         * Cancel scheduled refresh work
         */
        fun cancelPeriodicRefresh(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
            Log.i(TAG, "Widget refresh cancelled")
        }

        /**
         * Run immediate one-time refresh
         */
        fun runImmediateRefresh(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build()

            val workRequest = OneTimeWorkRequestBuilder<WidgetRefreshWorker>()
                .setConstraints(constraints)
                .build()

            WorkManager.getInstance(context).enqueue(workRequest)
            Log.i(TAG, "Immediate widget refresh requested")
        }

        /**
         * Calculate delay in milliseconds to reach 3 AM
         */
        private fun calculateDelayTo3AM(): Long {
            val now = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul"))
            val target = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul")).apply {
                set(Calendar.HOUR_OF_DAY, 3)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            // If we're past 3 AM, schedule for tomorrow
            if (now.after(target)) {
                target.add(Calendar.DAY_OF_MONTH, 1)
            }

            return target.timeInMillis - now.timeInMillis
        }
    }

    override suspend fun doWork(): Result {
        Log.i(TAG, "Widget refresh work started")

        return try {
            // Check if data is already valid for today
            if (isDataValidForToday()) {
                Log.i(TAG, "Widget data already valid for today, refreshing widgets only")
                refreshAllWidgets()
                return Result.success()
            }

            // Data needs refresh - this will be handled by Flutter
            // We trigger widget refresh here to show any cached data
            Log.i(TAG, "Widget data needs refresh, triggering widget update")
            refreshAllWidgets()

            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Widget refresh failed: ${e.message}")
            Result.retry()
        }
    }

    /**
     * Check if stored widget data is valid for today
     */
    private fun isDataValidForToday(): Boolean {
        val prefs: SharedPreferences = applicationContext.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        )

        val validDate = prefs.getString(VALID_DATE_KEY, null) ?: return false
        val todayStr = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())

        return validDate == todayStr
    }

    /**
     * Refresh all fortune widgets
     */
    private fun refreshAllWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(applicationContext)

        // Legacy widgets
        refreshWidgetByClass(appWidgetManager, FortuneDailyWidget::class.java)

        // New unified widgets (4 types based on fortune-daily data)
        refreshWidgetByClass(appWidgetManager, OverallAppWidget::class.java)
        refreshWidgetByClass(appWidgetManager, CategoryAppWidget::class.java)
        refreshWidgetByClass(appWidgetManager, TimeSlotAppWidget::class.java)
        refreshWidgetByClass(appWidgetManager, LottoAppWidget::class.java)

        Log.i(TAG, "All widgets refreshed")
    }

    /**
     * Refresh a specific widget type
     */
    private fun <T> refreshWidgetByClass(
        appWidgetManager: AppWidgetManager,
        widgetClass: Class<T>
    ) {
        try {
            val componentName = ComponentName(applicationContext, widgetClass)
            val widgetIds = appWidgetManager.getAppWidgetIds(componentName)

            if (widgetIds.isNotEmpty()) {
                // Send broadcast to update widgets
                val intent = android.content.Intent(applicationContext, widgetClass).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
                }
                applicationContext.sendBroadcast(intent)
                Log.d(TAG, "Refreshed ${widgetClass.simpleName}: ${widgetIds.size} widgets")
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to refresh ${widgetClass.simpleName}: ${e.message}")
        }
    }
}
