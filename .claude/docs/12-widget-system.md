# 홈 화면 위젯 시스템 가이드

> 최종 업데이트: 2025.01.03

## 개요

Fortune 앱의 홈 화면 위젯 시스템은 iOS (WidgetKit)와 Android (AppWidgetProvider)를 지원합니다.

### 위젯 종류

| 위젯 | iOS | Android | 설명 |
|------|-----|---------|------|
| Daily Fortune | `FortuneWidget` | `FortuneDailyWidget` | 일일 운세 |
| Love Fortune | `LoveFortuneWidget` | `FortuneLoveWidget` | 연애운 |
| **Favorites** | `FavoritesFortuneWidget` | `FavoritesAppWidget` | 즐겨찾기 롤링 위젯 |
| Lock Screen | `LockScreenFortuneWidget` | - | iOS 잠금화면 (iOS 16.1+) |

---

## 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter Layer                            │
├─────────────────────────────────────────────────────────────────┤
│  FortuneOrderProvider  →  FavoritesWidgetDataManager            │
│         ↓                          ↓                             │
│  toggleFavorite()           cacheFortune()                       │
│  cacheFortuneForWidget()    syncToWidget()                       │
│         ↓                          ↓                             │
│              WidgetService (home_widget)                         │
│                      ↓                                           │
│         HomeWidget.saveWidgetData() / updateWidget()             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        Native Layer                              │
├────────────────────────┬────────────────────────────────────────┤
│          iOS           │              Android                    │
├────────────────────────┼────────────────────────────────────────┤
│ App Group:             │ SharedPreferences:                      │
│ group.com.beyond.fortune│ FlutterSharedPreferences               │
│                        │ (flutter. prefix)                       │
├────────────────────────┼────────────────────────────────────────┤
│ UserDefaults           │ SharedPreferences                       │
│ WidgetDataManager      │ FavoritesAppWidget                      │
│ FavoritesFortuneWidget │ AlarmManager (1분 롤링)                 │
└────────────────────────┴────────────────────────────────────────┘
```

---

## 데이터 키 규격

### 공통 키 (Flutter ↔ iOS ↔ Android)

| 키 | 타입 | 설명 |
|----|------|------|
| `fortune_favorites` | `List<String>` (JSON) | 즐겨찾기 운세 타입 목록 |
| `widget_rolling_index` | `int` | 현재 롤링 인덱스 |
| `widget_fortune_cache_[type]` | `Map<String, dynamic>` (JSON) | 운세 타입별 캐시 데이터 |

### Android 키 (flutter. prefix 필요)

```kotlin
// FavoritesAppWidget.kt
private const val KEY_FAVORITES = "flutter.fortune_favorites"
private const val KEY_ROLLING_INDEX = "flutter.widget_rolling_index"
private const val KEY_FORTUNE_CACHE_PREFIX = "flutter.widget_fortune_cache_"
```

### iOS 키 (App Group UserDefaults)

```swift
// WidgetDataManager.swift
private let favoritesKey = "fortune_favorites"
private let rollingIndexKey = "widget_rolling_index"
private let fortuneCachePrefix = "widget_fortune_cache_"
```

---

## 즐겨찾기 위젯 (FavoritesWidget)

### 기능

1. **1분 롤링**: 즐겨찾기한 운세가 1분마다 자동 전환
2. **21개 운세 타입 지원**: 타입별 맞춤 데이터 표시
3. **3가지 크기 지원**: Small, Medium, Large
4. **빈 상태 처리**: 즐겨찾기가 없을 때 안내 메시지

### 운세 타입별 표시 데이터

| 타입 | 표시 데이터 |
|------|------------|
| `daily` | 점수, 행운색, 행운숫자 |
| `investment` | 로또 번호 (5개), 추천 섹터 |
| `biorhythm` | 신체/감정/지성 수치 |
| `mbti` | MBTI 타입, 에너지 레벨 |
| `tarot` | 카드 이름, 해석 |
| `time` | 현재 시간대 |
| `moving` | 좋은 방향, 좋은 날 |
| 기타 | 점수, 메시지 |

### iOS 롤링 메커니즘

```swift
// FavoritesFortuneWidget.swift
func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesFortuneEntry>) -> ()) {
    // 1시간 동안의 60개 엔트리 생성 (1분 간격)
    for i in 0..<60 {
        let entryDate = now.addingTimeInterval(Double(i) * 60)
        let index = (currentIndex + i) % favorites.count
        // 엔트리 생성
    }

    // 1시간 후 새 타임라인 요청
    let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
}
```

### Android 롤링 메커니즘

```kotlin
// FavoritesAppWidget.kt
private fun scheduleRollingUpdate(context: Context) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    // 1분 후 알람 설정
    alarmManager.setExactAndAllowWhileIdle(
        AlarmManager.ELAPSED_REALTIME,
        SystemClock.elapsedRealtime() + 60000,
        pendingIntent
    )
}
```

---

## 파일 구조

### Flutter

```
lib/
├── services/
│   ├── widget_service.dart              # 위젯 서비스 (home_widget 래퍼)
│   └── favorites_widget_data_manager.dart # 즐겨찾기 위젯 데이터 관리
└── features/fortune/presentation/providers/
    └── fortune_order_provider.dart      # 즐겨찾기 상태 & 위젯 연동
```

### iOS

```
ios/FortuneWidgetExtension/
├── FortuneWidget.swift              # 위젯 번들 정의
├── FortuneWidgetProvider.swift      # Daily/Love 위젯 프로바이더
├── FavoritesFortuneWidget.swift     # 즐겨찾기 위젯 (~890 LOC)
└── WidgetDataManager.swift          # 데이터 관리자
```

### Android

```
android/app/src/main/
├── kotlin/com/beyond/fortune/
│   ├── FortuneDailyWidget.kt
│   ├── FortuneLoveWidget.kt
│   ├── FavoritesAppWidget.kt        # 즐겨찾기 위젯 (~380 LOC)
│   └── BootReceiver.kt              # 부팅 시 위젯 새로고침
└── res/
    ├── layout/favorites_widget.xml  # 위젯 레이아웃
    ├── xml/favorites_widget_info.xml # 위젯 메타데이터
    └── drawable/widget_preview_favorites.xml
```

---

## 설정 요소

### iOS App Group

**entitlements 파일에 정의:**
- `ios/Runner/Runner.entitlements`
- `ios/FortuneWidgetExtension/FortuneWidgetExtension.entitlements`

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.beyond.fortune</string>
</array>
```

### Android Manifest

```xml
<!-- FavoritesAppWidget 리시버 -->
<receiver android:name=".FavoritesAppWidget" android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        <action android:name="com.beyond.fortune.ACTION_FAVORITES_ROLLING_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/favorites_widget_info" />
</receiver>

<!-- BootReceiver for widget refresh -->
<receiver android:name=".BootReceiver" android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

---

## 데이터 흐름

### 즐겨찾기 토글 시

```
1. User toggles favorite in app
2. FortuneOrderProvider.toggleFavorite()
3. _syncWidgetFavorites()
4. FavoritesWidgetDataManager.syncToWidget()
5. HomeWidget.saveWidgetData() → SharedPreferences/UserDefaults
6. HomeWidget.updateWidget() → Native widget refresh
```

### 운세 데이터 로드 시

```
1. Fortune page loads fortune data
2. FortuneOrderProvider.cacheFortuneForWidget()
3. FavoritesWidgetDataManager.cacheFortune()
4. HomeWidget.saveWidgetData() with fortune data
5. Widget reads cached data on next refresh
```

### 롤링 업데이트 (자동)

**iOS:**
```
1. WidgetKit timeline expires (every 1 min)
2. FavoritesFortuneProvider.getTimeline()
3. Load next favorite from index
4. Create new timeline entries
```

**Android:**
```
1. AlarmManager triggers ACTION_FAVORITES_ROLLING_UPDATE
2. FavoritesAppWidget.onReceive()
3. rollToNextFavorite() → increment index
4. updateAppWidget() → refresh UI
5. scheduleRollingUpdate() → set next alarm
```

---

## 테스트 방법

### iOS 시뮬레이터

```bash
# 위젯 타임라인 새로고침 (Xcode 콘솔에서)
simctl push booted [bundle-id] widgetkit-refresh

# 또는 시뮬레이터에서 직접
# 1. 홈 화면 길게 누르기
# 2. + 버튼 탭
# 3. Fortune 위젯 추가
```

### Android 에뮬레이터

```bash
# 위젯 강제 업데이트
adb shell am broadcast -a android.appwidget.action.APPWIDGET_UPDATE \
  --es appwidget_ids "1,2,3" \
  -n com.beyond.fortune/.FavoritesAppWidget

# 롤링 트리거
adb shell am broadcast \
  -a com.beyond.fortune.ACTION_FAVORITES_ROLLING_UPDATE \
  -n com.beyond.fortune/.FavoritesAppWidget
```

### Flutter 디버깅

```dart
// 위젯 데이터 확인
final prefs = await SharedPreferences.getInstance();
print('Favorites: ${prefs.getStringList('fortune_favorites')}');
print('Rolling Index: ${prefs.getInt('widget_rolling_index')}');

// 수동 위젯 업데이트
await WidgetService.rollToNextFavorite();
```

---

## 트러블슈팅

### 위젯에 데이터가 표시되지 않음

1. **App Group ID 확인**
   - Flutter: `group.com.beyond.fortune`
   - iOS entitlements 동일한지 확인
   - iOS 위젯 코드에서 동일한 ID 사용하는지 확인

2. **키 이름 확인**
   - Flutter와 Native 코드의 키 이름 일치 확인
   - Android: `flutter.` prefix 포함 확인

3. **데이터 저장 확인**
   ```dart
   // Flutter에서 데이터 저장 후
   await HomeWidget.saveWidgetData<String>('test_key', 'test_value');

   // Native에서 읽기 확인
   ```

### iOS 위젯이 업데이트되지 않음

```swift
// WidgetDataManager.swift에서 강제 새로고침
WidgetCenter.shared.reloadTimelines(ofKind: "FavoritesFortuneWidget")
WidgetCenter.shared.reloadAllTimelines()
```

### Android 롤링이 작동하지 않음

1. **AlarmManager 권한 확인** (Android 12+)
   ```xml
   <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
   ```

2. **배터리 최적화 제외 확인**
   - 설정 → 앱 → Fortune → 배터리 → 제한 없음

3. **로그 확인**
   ```bash
   adb logcat -s FavoritesAppWidget
   ```

### 빈 상태만 표시됨

1. 즐겨찾기가 추가되어 있는지 확인
2. 운세 데이터가 캐시되어 있는지 확인
3. 앱에서 해당 운세를 한 번이라도 조회했는지 확인

---

## 성능 고려사항

### 배터리 소모

- iOS: WidgetKit이 자동으로 최적화
- Android: `setExactAndAllowWhileIdle` 사용으로 Doze 모드에서도 동작
- 권장: 프로덕션에서는 5분 이상의 롤링 간격 고려

### 메모리 사용

- 캐시 데이터는 JSON 문자열로 저장
- 이미지는 저장하지 않음 (이모지 아이콘 사용)
- 21개 타입 전체 캐시 시 약 50KB 미만

### 네트워크

- 위젯은 네트워크 호출하지 않음
- 앱에서 데이터 로드 후 캐시에서만 읽음

---

## 버전 호환성

| 플랫폼 | 최소 버전 | 권장 버전 |
|--------|----------|----------|
| iOS | 14.0 | 15.0+ |
| Android | API 21 | API 26+ |
| Flutter | 3.0 | 3.19+ |
| home_widget | 0.8.0 | 0.8.0 |

---

## 참고 자료

- [Apple WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [Android App Widgets Guide](https://developer.android.com/develop/ui/views/appwidgets)
- [home_widget Package](https://pub.dev/packages/home_widget)
- [Flutter WidgetKit Integration](https://flutter.dev/docs/development/platform-integration/platform-channels)