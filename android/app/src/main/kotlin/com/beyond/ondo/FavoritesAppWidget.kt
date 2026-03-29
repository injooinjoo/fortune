package com.beyond.ondo

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.SystemClock
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

/**
 * Favorites Fortune Widget Provider
 *
 * Displays favorited fortunes with 1-minute rolling rotation.
 * Reads favorites list and cached fortune data from SharedPreferences.
 */
class FavoritesAppWidget : AppWidgetProvider() {

    companion object {
        private const val TAG = "FavoritesAppWidget"
        private const val PREFS_NAME = "FlutterSharedPreferences"

        // Keys for widget data (with flutter. prefix from home_widget)
        private const val KEY_FAVORITES = "flutter.fortune_favorites"
        private const val KEY_ROLLING_INDEX = "flutter.widget_rolling_index"
        private const val KEY_FORTUNE_CACHE_PREFIX = "flutter.widget_fortune_cache_"

        // Action for rolling update
        const val ACTION_ROLLING_UPDATE = "com.beyond.ondo.ACTION_FAVORITES_ROLLING_UPDATE"

        // Rolling interval: 1 minute in milliseconds
        private const val ROLLING_INTERVAL_MS = 60 * 1000L

        // Icon mapping
        private val ICONS = mapOf(
            "daily" to "✨",
            "love" to "💖",
            "career" to "💼",
            "investment" to "📈",
            "mbti" to "🧠",
            "tarot" to "🃏",
            "biorhythm" to "📊",
            "compatibility" to "💑",
            "health" to "🏥",
            "dream" to "🌙",
            "lucky-items" to "🍀",
            "traditional-saju" to "🔮",
            "face-reading" to "👤",
            "talent" to "⭐",
            "blind-date" to "💘",
            "ex-lover" to "💔",
            "moving" to "🏠",
            "pet-compatibility" to "🐾",
            "family-harmony" to "👨‍👩‍👧‍👦",
            "time" to "⏰",
            "avoid-people" to "🚫"
        )

        // Title mapping
        private val TITLES = mapOf(
            "daily" to "일일운세",
            "love" to "연애운",
            "career" to "직업운",
            "investment" to "투자운",
            "mbti" to "MBTI 운세",
            "tarot" to "타로",
            "biorhythm" to "바이오리듬",
            "compatibility" to "궁합",
            "health" to "건강운",
            "dream" to "꿈해몽",
            "lucky-items" to "행운 아이템",
            "traditional-saju" to "전통 사주",
            "face-reading" to "관상",
            "talent" to "재능운",
            "blind-date" to "소개팅운",
            "ex-lover" to "재회운",
            "moving" to "이사운",
            "pet-compatibility" to "반려동물 궁합",
            "family-harmony" to "가족 화목",
            "time" to "시간대별 운세",
            "avoid-people" to "피해야 할 사람"
        )

        /**
         * Request widget update from external source
         */
        fun requestUpdate(context: Context) {
            val intent = Intent(context, FavoritesAppWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val ids = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, FavoritesAppWidget::class.java))
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        }
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

        // Schedule rolling updates
        scheduleRollingUpdate(context)
    }

    override fun onEnabled(context: Context) {
        Log.d(TAG, "Widget enabled")
        scheduleRollingUpdate(context)
    }

    override fun onDisabled(context: Context) {
        Log.d(TAG, "Widget disabled")
        cancelRollingUpdate(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_ROLLING_UPDATE -> {
                Log.d(TAG, "Rolling update triggered")
                rollToNextFavorite(context)
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    ComponentName(context, FavoritesAppWidget::class.java)
                )
                for (appWidgetId in appWidgetIds) {
                    updateAppWidget(context, appWidgetManager, appWidgetId)
                }
                // Re-schedule for next update
                scheduleRollingUpdate(context)
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val favorites = getFavorites(prefs)

        val views = RemoteViews(context.packageName, R.layout.favorites_widget)

        if (favorites.isEmpty()) {
            // Show empty state
            showEmptyState(views)
        } else {
            // Show current favorite
            val currentIndex = prefs.getInt(KEY_ROLLING_INDEX, 0) % favorites.size
            val currentType = favorites[currentIndex]
            val fortuneData = getCachedFortune(prefs, currentType)

            showFortuneData(views, currentType, fortuneData, currentIndex, favorites.size)
        }

        // Set click intent to open app
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("source", "widget_favorites")
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d(TAG, "Widget $appWidgetId updated")
    }

    private fun showEmptyState(views: RemoteViews) {
        views.setTextViewText(R.id.widget_icon, "⭐")
        views.setTextViewText(R.id.widget_title, "즐겨찾기")
        views.setTextViewText(R.id.widget_score, "--")
        views.setTextViewText(R.id.widget_message, "즐겨찾기한 운세가 없습니다\n운세를 즐겨찾기에 추가해보세요")
        views.setViewVisibility(R.id.widget_extra_info, View.GONE)
        views.setViewVisibility(R.id.rolling_indicator, View.GONE)
    }

    private fun showFortuneData(
        views: RemoteViews,
        fortuneType: String,
        data: JSONObject?,
        currentIndex: Int,
        totalFavorites: Int
    ) {
        val icon = data?.optString("icon") ?: ICONS[fortuneType] ?: "🔮"
        val title = data?.optString("title") ?: TITLES[fortuneType] ?: fortuneType
        val score = data?.optString("score") ?: "--"
        val message = data?.optString("message") ?: "운세 데이터를 불러오는 중..."

        views.setTextViewText(R.id.widget_icon, icon)
        views.setTextViewText(R.id.widget_title, title)
        views.setTextViewText(R.id.widget_score, score)
        views.setTextViewText(R.id.widget_message, message)

        // Show extra info based on fortune type
        showExtraInfo(views, fortuneType, data)

        // Show rolling indicator if multiple favorites
        if (totalFavorites > 1) {
            views.setViewVisibility(R.id.rolling_indicator, View.VISIBLE)
            views.setTextViewText(R.id.rolling_indicator, "${currentIndex + 1}/$totalFavorites")
        } else {
            views.setViewVisibility(R.id.rolling_indicator, View.GONE)
        }
    }

    private fun showExtraInfo(views: RemoteViews, fortuneType: String, data: JSONObject?) {
        if (data == null) {
            views.setViewVisibility(R.id.widget_extra_info, View.GONE)
            return
        }

        val extraInfo = when (fortuneType) {
            "daily" -> {
                val luckyColor = data.optString("luckyColor", "")
                val luckyNumber = data.optString("luckyNumber", "")
                if (luckyColor.isNotEmpty() || luckyNumber.isNotEmpty()) {
                    buildString {
                        if (luckyColor.isNotEmpty()) append("🎨 $luckyColor")
                        if (luckyColor.isNotEmpty() && luckyNumber.isNotEmpty()) append("  ")
                        if (luckyNumber.isNotEmpty()) append("🔢 $luckyNumber")
                    }
                } else null
            }
            "investment" -> {
                val lottoNumbers = data.optString("lottoNumbers", "")
                if (lottoNumbers.isNotEmpty()) "🎰 $lottoNumbers" else null
            }
            "biorhythm" -> {
                val physical = data.optString("physical", "")
                val emotional = data.optString("emotional", "")
                val intellectual = data.optString("intellectual", "")
                if (physical.isNotEmpty() || emotional.isNotEmpty() || intellectual.isNotEmpty()) {
                    "💪$physical  💙$emotional  🧠$intellectual"
                } else null
            }
            "mbti" -> {
                val mbtiType = data.optString("mbtiType", "")
                if (mbtiType.isNotEmpty()) "🔤 $mbtiType" else null
            }
            "tarot" -> {
                val cardName = data.optString("cardName", "")
                if (cardName.isNotEmpty()) "🃏 $cardName" else null
            }
            "time" -> {
                val period = data.optString("currentPeriod", "")
                if (period.isNotEmpty()) "⏰ $period" else null
            }
            "moving" -> {
                val direction = data.optString("bestDirection", "")
                val bestDate = data.optString("bestDate", "")
                if (direction.isNotEmpty() || bestDate.isNotEmpty()) {
                    buildString {
                        if (direction.isNotEmpty()) append("🧭 $direction")
                        if (direction.isNotEmpty() && bestDate.isNotEmpty()) append("  ")
                        if (bestDate.isNotEmpty()) append("📅 $bestDate")
                    }
                } else null
            }
            else -> null
        }

        if (extraInfo != null) {
            views.setViewVisibility(R.id.widget_extra_info, View.VISIBLE)
            views.setTextViewText(R.id.widget_extra_info, extraInfo)
        } else {
            views.setViewVisibility(R.id.widget_extra_info, View.GONE)
        }
    }

    private fun getFavorites(prefs: SharedPreferences): List<String> {
        return try {
            val jsonString = prefs.getString(KEY_FAVORITES, "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)
            (0 until jsonArray.length()).map { jsonArray.getString(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing favorites: ${e.message}")
            emptyList()
        }
    }

    private fun getCachedFortune(prefs: SharedPreferences, fortuneType: String): JSONObject? {
        return try {
            val jsonString = prefs.getString("$KEY_FORTUNE_CACHE_PREFIX$fortuneType", null)
            if (jsonString != null) JSONObject(jsonString) else null
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing cached fortune for $fortuneType: ${e.message}")
            null
        }
    }

    private fun rollToNextFavorite(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val favorites = getFavorites(prefs)

        if (favorites.isNotEmpty()) {
            val currentIndex = prefs.getInt(KEY_ROLLING_INDEX, 0)
            val nextIndex = (currentIndex + 1) % favorites.size

            prefs.edit()
                .putInt(KEY_ROLLING_INDEX, nextIndex)
                .apply()

            Log.d(TAG, "Rolled to index $nextIndex (${favorites[nextIndex]})")
        }
    }

    private fun scheduleRollingUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, FavoritesAppWidget::class.java).apply {
            action = ACTION_ROLLING_UPDATE
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Cancel any existing alarm
        alarmManager.cancel(pendingIntent)

        // Schedule repeating alarm every 1 minute
        val triggerTime = SystemClock.elapsedRealtime() + ROLLING_INTERVAL_MS

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME,
                triggerTime,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.ELAPSED_REALTIME,
                triggerTime,
                pendingIntent
            )
        }

        Log.d(TAG, "Scheduled rolling update in ${ROLLING_INTERVAL_MS / 1000} seconds")
    }

    private fun cancelRollingUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, FavoritesAppWidget::class.java).apply {
            action = ACTION_ROLLING_UPDATE
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        Log.d(TAG, "Cancelled rolling updates")
    }
}
