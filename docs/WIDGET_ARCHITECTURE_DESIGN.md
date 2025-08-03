# Widget Architecture Design Guide

## Overview

This document outlines the architecture for implementing cross-platform widgets in the Fortune Flutter app, ensuring consistent functionality and design across iOS and Android platforms.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Data Flow Architecture](#data-flow-architecture)
3. [Widget Types & Designs](#widget-types--designs)
4. [Shared Business Logic](#shared-business-logic)
5. [Platform-Specific Implementation](#platform-specific-implementation)
6. [Design System](#design-system)
7. [Update Strategies](#update-strategies)
8. [Performance Guidelines](#performance-guidelines)

## Architecture Overview

### Core Principles

1. **Single Source of Truth**: Fortune data managed by Flutter app
2. **Platform Channels**: Bidirectional communication between Flutter and native
3. **Reactive Updates**: Widget updates triggered by data changes
4. **Offline Support**: Cached data for offline widget functionality
5. **Battery Efficiency**: Smart update scheduling and batching

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Fortune Service  │  Widget Manager  │  Cache Manager        │
├─────────────────────────────────────────────────────────────┤
│                    Platform Channels                         │
├──────────────────────────┬──────────────────────────────────┤
│         iOS Native       │         Android Native           │
├──────────────────────────┼──────────────────────────────────┤
│  WidgetKit │ Live Acts   │  Glance API │ Wear OS           │
│  Watch OS  │ Siri        │  Material You│ Notifications    │
└──────────────────────────┴──────────────────────────────────┘
```

## Data Flow Architecture

### 1. Data Model Definition

```dart
// Shared data model for all platforms
class FortuneWidgetData {
  final String id;
  final int score;
  final String message;
  final List<int> luckyNumbers;
  final String luckyColor;
  final String element;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'score': score,
    'message': message,
    'luckyNumbers': luckyNumbers,
    'luckyColor': luckyColor,
    'element': element,
    'lastUpdated': lastUpdated.toIso8601String(),
    'metadata': metadata,
  };
  
  // Platform-specific serialization
  Map<String, dynamic> toIOSFormat() => {
    ...toJson(),
    'displayName': metadata['displayName'] ?? 'Fortune',
    'widgetFamily': metadata['widgetFamily'] ?? 'medium',
  };
  
  Map<String, dynamic> toAndroidFormat() => {
    ...toJson(),
    'widgetType': metadata['widgetType'] ?? 'medium',
    'updateFrequency': metadata['updateFrequency'] ?? 3600,
  };
}
```

### 2. Widget Update Flow

```dart
class WidgetUpdateManager {
  static const _iosChannel = MethodChannel('com.fortune.ios/widgets');
  static const _androidChannel = MethodChannel('com.fortune.android/widgets');
  
  // Unified update method
  static Future<void> updateWidgets(FortuneWidgetData data) async {
    // Update local cache first
    await WidgetCacheManager.save(data);
    
    // Platform-specific updates
    if (Platform.isIOS) {
      await _updateIOSWidgets(data);
    } else if (Platform.isAndroid) {
      await _updateAndroidWidgets(data);
    }
  }
  
  static Future<void> _updateIOSWidgets(FortuneWidgetData data) async {
    try {
      await _iosChannel.invokeMethod('updateWidgets', data.toIOSFormat());
      
      // Update complications if watch is connected
      final isWatchConnected = await _iosChannel.invokeMethod('isWatchConnected');
      if (isWatchConnected) {
        await _iosChannel.invokeMethod('updateComplications', data.toIOSFormat());
      }
    } catch (e) {
      print('iOS widget update failed: $e');
    }
  }
  
  static Future<void> _updateAndroidWidgets(FortuneWidgetData data) async {
    try {
      // Get all active widget IDs
      final List<int> widgetIds = await _androidChannel.invokeMethod('getActiveWidgetIds');
      
      // Update each widget
      for (final widgetId in widgetIds) {
        await _androidChannel.invokeMethod('updateWidget', {
          'widgetId': widgetId,
          'data': data.toAndroidFormat(),
        });
      }
      
      // Update Wear OS if connected
      final isWearConnected = await _androidChannel.invokeMethod('isWearConnected');
      if (isWearConnected) {
        await _androidChannel.invokeMethod('updateWearTiles', data.toAndroidFormat());
      }
    } catch (e) {
      print('Android widget update failed: $e');
    }
  }
}
```

### 3. Cache Management

```dart
class WidgetCacheManager {
  static const String _cacheKey = 'fortune_widget_cache';
  static const Duration _cacheExpiration = Duration(hours: 1);
  
  static Future<void> save(FortuneWidgetData data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_cacheKey, json.encode(cacheData));
  }
  
  static Future<FortuneWidgetData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(_cacheKey);
    
    if (cacheString == null) return null;
    
    try {
      final cacheData = json.decode(cacheString);
      final timestamp = DateTime.parse(cacheData['timestamp']);
      
      // Check if cache is expired
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        return null;
      }
      
      return FortuneWidgetData.fromJson(cacheData['data']);
    } catch (e) {
      print('Cache load failed: $e');
      return null;
    }
  }
  
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
```

## Widget Types & Designs

### 1. Small Widget (2x2)

**Purpose**: Quick fortune score glance

```
┌─────────────┐
│  ✨  88/100 │
│    Today    │
└─────────────┘
```

**Data Requirements**:
- Fortune score
- Update timestamp

### 2. Medium Widget (4x2)

**Purpose**: Score + lucky numbers

```
┌─────────────────────────┐
│ Today's Fortune     88  │
│ Lucky: 7, 14, 21       │
└─────────────────────────┘
```

**Data Requirements**:
- Fortune score
- Lucky numbers (max 3)
- Date

### 3. Large Widget (4x4)

**Purpose**: Complete fortune overview

```
┌─────────────────────────┐
│ Today's Fortune     88  │
│ ─────────────────────── │
│ "Great opportunities    │
│  await you today"       │
│                         │
│ Lucky: 7, 14, 21       │
│ Color: 🟡  Element: 🔥  │
└─────────────────────────┘
```

**Data Requirements**:
- All fortune data
- Message (truncated to 2 lines)
- Visual indicators

### 4. Lock Screen Widget (iOS)

**Purpose**: Minimal fortune info

```
┌──────────┐
│ ✨ 88    │
└──────────┘
```

### 5. Dynamic Island (iOS)

**Compact View**:
```
[✨ 88]
```

**Expanded View**:
```
┌─────────────────────────┐
│ Fortune Active      88  │
│ Next update in 45 min   │
└─────────────────────────┘
```

### 6. Complication Designs (Watch)

**Circular Small**:
```
 ╭─╮
 │88│
 ╰─╯
```

**Modular Large**:
```
┌───────────┐
│Fortune 88 │
│Lucky: 7   │
└───────────┘
```

## Shared Business Logic

### 1. Fortune Calculation Service

```dart
class FortuneCalculationService {
  // Shared calculation logic used by both app and widgets
  static FortuneData calculateDailyFortune({
    required DateTime birthDate,
    required DateTime currentDate,
    required String zodiacSign,
  }) {
    // Core calculation logic
    final daysSinceBirth = currentDate.difference(birthDate).inDays;
    final biorhythm = _calculateBiorhythm(daysSinceBirth);
    final zodiacInfluence = _getZodiacInfluence(zodiacSign, currentDate);
    
    final score = _combineInfluences(biorhythm, zodiacInfluence);
    final luckyNumbers = _generateLuckyNumbers(birthDate, currentDate);
    final element = _determineElement(birthDate);
    
    return FortuneData(
      score: score,
      luckyNumbers: luckyNumbers,
      element: element,
      message: _generateMessage(score, zodiacSign),
    );
  }
  
  // Simplified version for widgets (faster, less battery intensive)
  static FortuneData calculateQuickFortune({
    required StoredUserProfile profile,
    DateTime? currentDate,
  }) {
    currentDate ??= DateTime.now();
    
    // Use cached calculations when possible
    final cacheKey = '${profile.id}_${currentDate.day}';
    final cached = _fortuneCache[cacheKey];
    if (cached != null) return cached;
    
    // Quick calculation
    final fortune = calculateDailyFortune(
      birthDate: profile.birthDate,
      currentDate: currentDate,
      zodiacSign: profile.zodiacSign,
    );
    
    _fortuneCache[cacheKey] = fortune;
    return fortune;
  }
  
  static final Map<String, FortuneData> _fortuneCache = {};
}
```

### 2. Update Scheduling Logic

```dart
class WidgetUpdateScheduler {
  static const Duration _minimumUpdateInterval = Duration(minutes: 30);
  static Timer? _updateTimer;
  
  static void initialize() {
    // Schedule updates based on user preferences and battery status
    _scheduleNextUpdate();
    
    // Listen for significant time changes
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        await _checkAndUpdate();
      }
      return null;
    });
  }
  
  static void _scheduleNextUpdate() {
    _updateTimer?.cancel();
    
    final now = DateTime.now();
    final nextUpdate = _calculateNextUpdateTime(now);
    final duration = nextUpdate.difference(now);
    
    _updateTimer = Timer(duration, () async {
      await _performUpdate();
      _scheduleNextUpdate();
    });
  }
  
  static DateTime _calculateNextUpdateTime(DateTime now) {
    // Update at specific times for better battery life
    final updateHours = [0, 6, 12, 18]; // Midnight, 6am, noon, 6pm
    
    for (final hour in updateHours) {
      final updateTime = DateTime(now.year, now.month, now.day, hour);
      if (updateTime.isAfter(now)) {
        return updateTime;
      }
    }
    
    // Next day midnight
    return DateTime(now.year, now.month, now.day + 1, 0);
  }
  
  static Future<void> _performUpdate() async {
    try {
      // Get latest fortune
      final userProfile = await UserProfileService.getCurrentProfile();
      if (userProfile == null) return;
      
      final fortune = FortuneCalculationService.calculateQuickFortune(
        profile: userProfile,
      );
      
      // Convert to widget data
      final widgetData = FortuneWidgetData(
        id: Uuid().v4(),
        score: fortune.score,
        message: fortune.message,
        luckyNumbers: fortune.luckyNumbers,
        luckyColor: fortune.luckyColor,
        element: fortune.element,
        lastUpdated: DateTime.now(),
        metadata: {
          'userId': userProfile.id,
          'zodiacSign': userProfile.zodiacSign,
        },
      );
      
      // Update all widgets
      await WidgetUpdateManager.updateWidgets(widgetData);
    } catch (e) {
      print('Widget update failed: $e');
    }
  }
}
```

## Platform-Specific Implementation

### iOS Implementation Strategy

```swift
// Shared Container
class FortuneSharedContainer {
    static let suiteName = "group.com.fortune.shared"
    
    static func save(_ data: FortuneWidgetData) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            defaults.set(encoded, forKey: "latestFortune")
        }
    }
    
    static func load() -> FortuneWidgetData? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: "latestFortune") else { return nil }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(FortuneWidgetData.self, from: data)
    }
}

// Widget Timeline Provider
struct FortuneTimelineProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<FortuneEntry>) -> Void) {
        let currentDate = Date()
        let fortune = FortuneSharedContainer.load() ?? FortuneWidgetData.placeholder()
        
        // Create timeline entries for the next 6 hours
        var entries: [FortuneEntry] = []
        for hourOffset in 0..<6 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            entries.append(FortuneEntry(date: entryDate, fortune: fortune))
        }
        
        let timeline = Timeline(entries: entries, policy: .after(entries.last!.date))
        completion(timeline)
    }
}
```

### Android Implementation Strategy

```kotlin
// Shared Preferences Helper
object FortuneWidgetStorage {
    private const val PREFS_NAME = "fortune_widget_prefs"
    private const val KEY_LATEST_FORTUNE = "latest_fortune"
    
    fun save(context: Context, data: FortuneWidgetData) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = Gson().toJson(data)
        prefs.edit().putString(KEY_LATEST_FORTUNE, json).apply()
    }
    
    fun load(context: Context): FortuneWidgetData? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(KEY_LATEST_FORTUNE, null) ?: return null
        
        return try {
            Gson().fromJson(json, FortuneWidgetData::class.java)
        } catch (e: Exception) {
            null
        }
    }
}

// Glance State Definition
object FortuneWidgetStateDefinition : GlanceStateDefinition<FortuneWidgetData> {
    override suspend fun getDataStore(context: Context, fileKey: String): DataStore<FortuneWidgetData> {
        return DataStoreFactory.create(
            serializer = FortuneWidgetSerializer,
            scope = CoroutineScope(Dispatchers.IO + SupervisorJob()),
            migrations = emptyList(),
            produceFile = { context.dataStoreFile(fileKey) }
        )
    }
    
    override fun getLocation(context: Context, fileKey: String): File {
        return context.dataStoreFile(fileKey)
    }
}
```

## Design System

### 1. Color Palette

```dart
class FortuneWidgetColors {
  // Score-based colors
  static Color getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFFC107); // Amber
    if (score >= 40) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
  
  // Element colors
  static const Map<String, Color> elementColors = {
    'Wood': Color(0xFF4CAF50),
    'Fire': Color(0xFFF44336),
    'Earth': Color(0xFF795548),
    'Metal': Color(0xFF9E9E9E),
    'Water': Color(0xFF2196F3),
  };
  
  // Lucky colors
  static const Map<String, Color> luckyColors = {
    'Gold': Color(0xFFFFD700),
    'Silver': Color(0xFFC0C0C0),
    'Red': Color(0xFFFF0000),
    'Blue': Color(0xFF0000FF),
    'Green': Color(0xFF00FF00),
    'Purple': Color(0xFF800080),
    'Orange': Color(0xFFFFA500),
    'Pink': Color(0xFFFFC0CB),
  };
}
```

### 2. Typography

```dart
class FortuneWidgetTypography {
  // iOS Typography
  static const iosSmallScore = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: '.SF Pro Display',
  );
  
  static const iosMediumTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.medium,
    fontFamily: '.SF Pro Text',
  );
  
  // Android Typography
  static const androidSmallScore = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: 'Roboto',
  );
  
  static const androidMediumTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
  );
}
```

### 3. Icon System

```dart
class FortuneWidgetIcons {
  static const Map<String, IconData> elements = {
    'Wood': Icons.park,
    'Fire': Icons.local_fire_department,
    'Earth': Icons.terrain,
    'Metal': Icons.hardware,
    'Water': Icons.water_drop,
  };
  
  static const Map<String, String> customIcons = {
    'fortune': 'assets/icons/fortune.svg',
    'lucky_star': 'assets/icons/lucky_star.svg',
    'zodiac': 'assets/icons/zodiac.svg',
  };
}
```

## Update Strategies

### 1. Smart Update Scheduling

```dart
class SmartUpdateScheduler {
  static Future<void> scheduleUpdates(BuildContext context) async {
    final batteryLevel = await _getBatteryLevel();
    final isCharging = await _isCharging();
    final connectivity = await _getConnectivity();
    
    UpdateFrequency frequency;
    
    if (batteryLevel < 20 && !isCharging) {
      frequency = UpdateFrequency.minimal; // Once per day
    } else if (batteryLevel < 50 && !isCharging) {
      frequency = UpdateFrequency.conservative; // Twice per day
    } else if (connectivity == ConnectivityResult.wifi || isCharging) {
      frequency = UpdateFrequency.frequent; // Every hour
    } else {
      frequency = UpdateFrequency.normal; // Every 3 hours
    }
    
    await _applyUpdateFrequency(frequency);
  }
  
  static Future<void> _applyUpdateFrequency(UpdateFrequency frequency) async {
    switch (frequency) {
      case UpdateFrequency.minimal:
        // Update at midnight only
        await _scheduleDaily(hour: 0);
        break;
      case UpdateFrequency.conservative:
        // Update at midnight and noon
        await _scheduleDaily(hour: 0);
        await _scheduleDaily(hour: 12);
        break;
      case UpdateFrequency.normal:
        // Update every 3 hours
        await _schedulePeriodic(Duration(hours: 3));
        break;
      case UpdateFrequency.frequent:
        // Update every hour
        await _schedulePeriodic(Duration(hours: 1));
        break;
    }
  }
}
```

### 2. Batch Update Strategy

```dart
class BatchUpdateManager {
  static final Queue<WidgetUpdate> _updateQueue = Queue();
  static Timer? _batchTimer;
  static const Duration _batchInterval = Duration(seconds: 5);
  
  static void queueUpdate(WidgetUpdate update) {
    _updateQueue.add(update);
    
    // Start batch timer if not running
    _batchTimer ??= Timer(_batchInterval, _processBatch);
  }
  
  static Future<void> _processBatch() async {
    if (_updateQueue.isEmpty) {
      _batchTimer = null;
      return;
    }
    
    // Group updates by type
    final Map<String, List<WidgetUpdate>> groupedUpdates = {};
    
    while (_updateQueue.isNotEmpty) {
      final update = _updateQueue.removeFirst();
      groupedUpdates.putIfAbsent(update.type, () => []).add(update);
    }
    
    // Process each group
    for (final entry in groupedUpdates.entries) {
      await _processUpdateGroup(entry.key, entry.value);
    }
    
    _batchTimer = null;
  }
  
  static Future<void> _processUpdateGroup(String type, List<WidgetUpdate> updates) async {
    // Combine data for batch update
    final combinedData = updates.map((u) => u.data).toList();
    
    // Send batch update to platform
    if (Platform.isIOS) {
      await _iosChannel.invokeMethod('batchUpdate', {
        'type': type,
        'updates': combinedData,
      });
    } else if (Platform.isAndroid) {
      await _androidChannel.invokeMethod('batchUpdate', {
        'type': type,
        'updates': combinedData,
      });
    }
  }
}
```

## Performance Guidelines

### 1. Memory Management

```dart
class WidgetMemoryManager {
  static const int maxCacheSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 500 * 1024; // 500KB per image
  
  static Future<Uint8List> optimizeImage(Uint8List imageData) async {
    if (imageData.length <= maxImageSize) return imageData;
    
    // Compress image
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;
    
    // Resize if needed
    final resized = img.copyResize(
      image,
      width: 200,
      height: 200,
      interpolation: img.Interpolation.linear,
    );
    
    // Encode with quality adjustment
    return Uint8List.fromList(
      img.encodeJpg(resized, quality: 80),
    );
  }
  
  static Future<void> cleanupCache() async {
    final cacheDir = await getTemporaryDirectory();
    final widgetCacheDir = Directory('${cacheDir.path}/widgets');
    
    if (!await widgetCacheDir.exists()) return;
    
    // Calculate cache size
    int totalSize = 0;
    final files = widgetCacheDir.listSync();
    
    for (final file in files) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    
    // Clean if over limit
    if (totalSize > maxCacheSize) {
      // Sort by last modified
      files.sort((a, b) {
        final aTime = a.statSync().modified;
        final bTime = b.statSync().modified;
        return aTime.compareTo(bTime);
      });
      
      // Delete oldest files until under limit
      for (final file in files) {
        if (totalSize <= maxCacheSize) break;
        
        if (file is File) {
          final size = await file.length();
          await file.delete();
          totalSize -= size;
        }
      }
    }
  }
}
```

### 2. Battery Optimization

```dart
class WidgetBatteryOptimizer {
  static Future<UpdateStrategy> determineUpdateStrategy() async {
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;
    final batteryState = await battery.batteryState;
    
    // Check if device is in power saving mode
    final isPowerSaving = await _isPowerSavingMode();
    
    if (isPowerSaving) {
      return UpdateStrategy.minimal;
    }
    
    if (batteryState == BatteryState.charging) {
      return UpdateStrategy.aggressive;
    }
    
    if (batteryLevel < 15) {
      return UpdateStrategy.minimal;
    } else if (batteryLevel < 30) {
      return UpdateStrategy.conservative;
    } else {
      return UpdateStrategy.normal;
    }
  }
  
  static Future<bool> _isPowerSavingMode() async {
    if (Platform.isAndroid) {
      try {
        final bool isPowerSaving = await _androidChannel.invokeMethod('isPowerSavingMode');
        return isPowerSaving;
      } catch (e) {
        return false;
      }
    }
    // iOS doesn't expose power saving mode to apps
    return false;
  }
}

enum UpdateStrategy {
  minimal,      // Update once per day
  conservative, // Update 2-3 times per day
  normal,       // Update every few hours
  aggressive,   // Update hourly or more
}
```

### 3. Network Optimization

```dart
class WidgetNetworkOptimizer {
  static Future<bool> shouldUpdateNow() async {
    final connectivity = await Connectivity().checkConnectivity();
    
    // Always update on WiFi
    if (connectivity == ConnectivityResult.wifi) {
      return true;
    }
    
    // Check cellular data settings
    if (connectivity == ConnectivityResult.mobile) {
      final prefs = await SharedPreferences.getInstance();
      final allowCellular = prefs.getBool('widget_cellular_updates') ?? false;
      
      if (!allowCellular) return false;
      
      // Check data usage for the day
      final todayUsage = await _getDataUsageToday();
      const maxDailyUsage = 5 * 1024 * 1024; // 5MB
      
      return todayUsage < maxDailyUsage;
    }
    
    return false;
  }
  
  static Future<void> downloadFortuneData() async {
    final shouldCompress = await _shouldCompressData();
    
    final headers = <String, String>{};
    if (shouldCompress) {
      headers['Accept-Encoding'] = 'gzip';
    }
    
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/widget/fortune'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _processFortuneData(data);
    }
  }
  
  static Future<bool> _shouldCompressData() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity == ConnectivityResult.mobile;
  }
}
```

## Testing Strategies

### 1. Widget Testing Framework

```dart
class WidgetTestFramework {
  static Future<void> testWidgetUpdate() async {
    // Test data
    final testFortune = FortuneWidgetData(
      id: 'test_001',
      score: 88,
      message: 'Test fortune message',
      luckyNumbers: [7, 14, 21],
      luckyColor: '#FFD700',
      element: 'Fire',
      lastUpdated: DateTime.now(),
      metadata: {'test': true},
    );
    
    // Test iOS update
    if (Platform.isIOS) {
      await testIOSWidgetUpdate(testFortune);
    }
    
    // Test Android update
    if (Platform.isAndroid) {
      await testAndroidWidgetUpdate(testFortune);
    }
  }
  
  static Future<void> testIOSWidgetUpdate(FortuneWidgetData data) async {
    try {
      // Update widget
      await WidgetUpdateManager.updateWidgets(data);
      
      // Verify update
      final updated = await _iosChannel.invokeMethod('getWidgetData');
      assert(updated['score'] == data.score);
      
      print('iOS widget test passed');
    } catch (e) {
      print('iOS widget test failed: $e');
    }
  }
  
  static Future<void> testAndroidWidgetUpdate(FortuneWidgetData data) async {
    try {
      // Get widget IDs
      final widgetIds = await _androidChannel.invokeMethod('getActiveWidgetIds');
      
      // Update first widget
      if (widgetIds.isNotEmpty) {
        await _androidChannel.invokeMethod('updateWidget', {
          'widgetId': widgetIds.first,
          'data': data.toAndroidFormat(),
        });
        
        // Verify update
        final updated = await _androidChannel.invokeMethod('getWidgetData', {
          'widgetId': widgetIds.first,
        });
        assert(updated['score'] == data.score);
        
        print('Android widget test passed');
      }
    } catch (e) {
      print('Android widget test failed: $e');
    }
  }
}
```

## Security Considerations

### 1. Data Encryption

```dart
class WidgetDataSecurity {
  static Future<String> encryptSensitiveData(Map<String, dynamic> data) async {
    final key = await _getOrGenerateKey();
    final iv = _generateIV();
    
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(
      json.encode(data),
      iv: iv,
    );
    
    return base64.encode(encrypted.bytes + iv.bytes);
  }
  
  static Future<Map<String, dynamic>> decryptSensitiveData(String encryptedData) async {
    final key = await _getOrGenerateKey();
    final bytes = base64.decode(encryptedData);
    
    final encryptedBytes = bytes.sublist(0, bytes.length - 16);
    final ivBytes = bytes.sublist(bytes.length - 16);
    
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(
      Encrypted(encryptedBytes),
      iv: IV(ivBytes),
    );
    
    return json.decode(decrypted);
  }
  
  static Future<Key> _getOrGenerateKey() async {
    const storage = FlutterSecureStorage();
    String? keyString = await storage.read(key: 'widget_encryption_key');
    
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      await storage.write(
        key: 'widget_encryption_key',
        value: base64.encode(key.bytes),
      );
      return key;
    }
    
    return Key(base64.decode(keyString));
  }
  
  static IV _generateIV() {
    return IV.fromSecureRandom(16);
  }
}
```

## Conclusion

This architecture provides a robust foundation for implementing cross-platform widgets in the Fortune Flutter app. Key benefits include:

1. **Unified Data Model**: Single source of truth for all platforms
2. **Efficient Updates**: Smart scheduling and batching
3. **Performance Optimization**: Memory and battery conscious
4. **Consistent Design**: Shared design system across platforms
5. **Testability**: Comprehensive testing framework

Follow the platform-specific implementation guides for detailed instructions on implementing widgets for iOS and Android.