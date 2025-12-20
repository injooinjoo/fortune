package com.beyond.fortune

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

/**
 * Lotto Fortune Widget
 * Displays 5 lucky numbers for today
 */
class LottoAppWidget : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences = context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

            // Get lotto numbers from SharedPreferences (stored as comma-separated string)
            val lottoNumbersStr = prefs.getString("flutter.lotto_numbers", "7, 14, 23, 31, 42")
                ?: "7, 14, 23, 31, 42"

            // Parse numbers
            val numbers = lottoNumbersStr.split(",")
                .map { it.trim() }
                .filter { it.isNotEmpty() }
                .take(5)

            // Ensure we have 5 numbers
            val paddedNumbers = numbers.toMutableList()
            while (paddedNumbers.size < 5) {
                paddedNumbers.add("?")
            }

            // Format date
            val dateFormat = SimpleDateFormat("M월 d일", Locale.KOREA)
            val dateStr = "${dateFormat.format(Date())} 행운 번호"

            // Create RemoteViews
            val views = RemoteViews(context.packageName, R.layout.lotto_widget)

            views.setTextViewText(R.id.lotto_num_1, paddedNumbers[0])
            views.setTextViewText(R.id.lotto_num_2, paddedNumbers[1])
            views.setTextViewText(R.id.lotto_num_3, paddedNumbers[2])
            views.setTextViewText(R.id.lotto_num_4, paddedNumbers[3])
            views.setTextViewText(R.id.lotto_num_5, paddedNumbers[4])
            views.setTextViewText(R.id.lotto_date, dateStr)

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
