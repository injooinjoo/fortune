import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _userProfileKey = 'userProfile';
  static const String _recentFortunesKey = 'recentFortunes';
  static const String _lastUpdateDateKey = 'fortune_last_update_date';
  static const String _guestModeKey = 'isGuestMode';
  static const String _userStatisticsKey = 'userStatistics';
  static const String _dailyFortuneRefreshKey = 'dailyFortuneRefresh';
  static const String _loveFortuneInputKey = 'loveFortuneInput';
  static const String _dreamResultKey = 'dreamInterpretationResult';
  static const String _fortuneGaugeKey = 'fortune_gauge_progress';

  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_userProfileKey);
    
    if (profileString != null) {
      try {
        return json.decode(profileString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, json.encode(profile));
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }

  Future<List<Map<String, dynamic>>> getRecentFortunes() async {
    debugPrint('📦 [StorageService.getRecentFortunes] START');
    final prefs = await SharedPreferences.getInstance();
    final fortunesString = prefs.getString(_recentFortunesKey);
    debugPrint('📦 [StorageService.getRecentFortunes] Raw string from prefs: $fortunesString');
    
    if (fortunesString != null) {
      try {
        debugPrint('📦 [StorageService.getRecentFortunes] Decoding JSON...');
        final List<dynamic> fortunes = json.decode(fortunesString);
        debugPrint('📦 [StorageService.getRecentFortunes] Decoded ${fortunes.length} fortunes');
        // 각 fortune 항목의 visitedAt 형식을 확인하고 정리
        final cleanedFortunes = <Map<String, dynamic>>[];
        
        for (var fortune in fortunes) {
          debugPrint('📦 [StorageService.getRecentFortunes] Processing fortune: $fortune');
          if (fortune is Map<String, dynamic>) {
            final visitedAt = fortune['visitedAt'];
            debugPrint('📦 [StorageService.getRecentFortunes] visitedAt value: $visitedAt');
            debugPrint('📦 [StorageService.getRecentFortunes] visitedAt type: ${visitedAt.runtimeType}');
            
            // visitedAt이 숫자인 경우 ISO 문자열로 변환
            if (visitedAt is int) {
              debugPrint('📦 [StorageService.getRecentFortunes] Converting int to ISO string...');
              fortune['visitedAt'] = DateTime.fromMillisecondsSinceEpoch(visitedAt).toIso8601String();
              debugPrint('📦 [StorageService.getRecentFortunes] Converted to: ${fortune['visitedAt']}');
            } else if (visitedAt is String) {
              // 이미 문자열인 경우 유효성 검사
              try {
                debugPrint('📦 [StorageService.getRecentFortunes] Validating string date...');
                DateTime.parse(visitedAt);
                debugPrint('📦 [StorageService.getRecentFortunes] Valid date string');
              } catch (e) {
                // 파싱할 수 없는 문자열인 경우 현재 시간으로 대체
                debugPrint('❌ [StorageService.getRecentFortunes] Date parsing failed: $e');
                fortune['visitedAt'] = DateTime.now().toIso8601String();
                debugPrint('📦 [StorageService.getRecentFortunes] Replaced with current time');
              }
            } else {
              // visitedAt이 없거나 다른 타입인 경우 현재 시간으로 설정
              debugPrint('⚠️ [StorageService.getRecentFortunes] Unknown type for visitedAt, using current time');
              fortune['visitedAt'] = DateTime.now().toIso8601String();
            }
            
            cleanedFortunes.add(fortune);
            debugPrint('📦 [StorageService.getRecentFortunes] Added cleaned fortune');
          }
        }
        
        // 정리된 데이터를 다시 저장
        if (cleanedFortunes.isNotEmpty) {
          debugPrint('📦 [StorageService.getRecentFortunes] Saving cleaned fortunes back to prefs...');
          await prefs.setString(_recentFortunesKey, json.encode(cleanedFortunes));
        }
        
        debugPrint('📦 [StorageService.getRecentFortunes] Returning ${cleanedFortunes.length} cleaned fortunes');
        debugPrint('📦 [StorageService.getRecentFortunes] END - SUCCESS');
        return cleanedFortunes;
      } catch (e, stackTrace) {
        // 복구 불가능한 경우 초기화
        debugPrint('❌ [StorageService.getRecentFortunes] JSON parsing error: $e');
        debugPrint('❌ [StorageService.getRecentFortunes] Stack trace: $stackTrace');
        await prefs.remove(_recentFortunesKey);
        debugPrint('📦 [StorageService.getRecentFortunes] END - ERROR');
        return [];
      }
    }
    debugPrint('📦 [StorageService.getRecentFortunes] No fortunes found in storage');
    debugPrint('📦 [StorageService.getRecentFortunes] END - EMPTY');
    return [];
  }

  Future<void> addRecentFortune(String path, String title) async {
    debugPrint('📝 [StorageService.addRecentFortune] START - path: $path, title: $title');
    final prefs = await SharedPreferences.getInstance();
    debugPrint('📝 [StorageService.addRecentFortune] Getting existing fortunes...');
    List<Map<String, dynamic>> fortunes = await getRecentFortunes();
    debugPrint('📝 [StorageService.addRecentFortune] Current fortunes count: ${fortunes.length}');
    
    // 기존에 같은 path가 있으면 제거
    final beforeRemove = fortunes.length;
    fortunes.removeWhere((f) => f['path'] == path);
    debugPrint('📝 [StorageService.addRecentFortune] Removed ${beforeRemove - fortunes.length} duplicate(s)');
    
    // 새로운 항목을 맨 앞에 추가
    final newFortune = {
      'path': path,
      'title': title,
      'visitedAt': DateTime.now().toIso8601String(),
    };
    debugPrint('📝 [StorageService.addRecentFortune] Adding new fortune: $newFortune');
    fortunes.insert(0, newFortune);
    
    // 최대 10개까지만 저장
    if (fortunes.length > 10) {
      fortunes = fortunes.sublist(0, 10);
      debugPrint('📝 [StorageService.addRecentFortune] Trimmed to 10 items');
    }
    
    final jsonString = json.encode(fortunes);
    debugPrint('📝 [StorageService.addRecentFortune] Saving JSON: $jsonString');
    await prefs.setString(_recentFortunesKey, jsonString);
    debugPrint('📝 [StorageService.addRecentFortune] END - Saved ${fortunes.length} fortunes');
  }

  Future<String?> getLastUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateDateKey);
  }

  Future<void> setLastUpdateDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateDateKey, date);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // 문제가 있는 캐시 데이터 정리
  Future<void> cleanupCorruptedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // recentFortunes 데이터 검사 및 정리
    final fortunesString = prefs.getString(_recentFortunesKey);
    if (fortunesString != null) {
      try {
        final fortunes = json.decode(fortunesString);
        if (fortunes is List) {
          bool needsCleanup = false;
          
          for (var fortune in fortunes) {
            if (fortune is Map) {
              final visitedAt = fortune['visitedAt'];
              // visitedAt이 int 타입이거나 유효하지 않은 문자열인 경우
              if (visitedAt is int || (visitedAt is String && visitedAt.contains('"'))) {
                needsCleanup = true;
                break;
              }
            }
          }
          
          if (needsCleanup) {
            await prefs.remove(_recentFortunesKey);
            debugPrint('🗑️ Cleaned up corrupted fortune data');
          }
        }
      } catch (e) {
        // 파싱 실패 시 데이터 제거
        await prefs.remove(_recentFortunesKey);
        debugPrint('🗑️ Removed unparseable fortune data');
      }
    }
  }
  
  // Guest mode management
  Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }
  
  Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, isGuest);
  }
  
  Future<void> clearGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestModeKey);
  }
  
  // User statistics management
  Future<Map<String, dynamic>?> getUserStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsString = prefs.getString(_userStatisticsKey);
    
    if (statsString != null) {
      try {
        return json.decode(statsString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<void> saveUserStatistics(Map<String, dynamic> statistics) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Merge with existing statistics
    final existingStats = await getUserStatistics() ?? {};
    existingStats.addAll(statistics);
    
    await prefs.setString(_userStatisticsKey, json.encode(existingStats));
  }
  
  Future<void> clearUserStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userStatisticsKey);
  }
  
  // Daily fortune refresh management
  Future<Map<String, dynamic>> getDailyFortuneRefreshData() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshString = prefs.getString(_dailyFortuneRefreshKey);
    
    if (refreshString != null) {
      try {
        final data = json.decode(refreshString) as Map<String, dynamic>;
        final date = data['date'] as String;
        
        // 날짜가 오늘이 아니면 리셋
        final today = DateTime.now().toIso8601String().split('T')[0];
        if (date != today) {
          return {'date': today, 'count': 0};
        }
        
        return data;
      } catch (e) {
        return {'date': DateTime.now().toIso8601String().split('T')[0], 'count': 0};
      }
    }
    
    return {'date': DateTime.now().toIso8601String().split('T')[0], 'count': 0};
  }
  
  Future<void> saveDailyFortuneRefreshData(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final data = {'date': today, 'count': count};
    await prefs.setString(_dailyFortuneRefreshKey, json.encode(data));
  }
  
  Future<int> getDailyFortuneRefreshCount() async {
    final data = await getDailyFortuneRefreshData();
    return data['count'] as int;
  }
  
  Future<void> incrementDailyFortuneRefreshCount() async {
    final currentCount = await getDailyFortuneRefreshCount();
    await saveDailyFortuneRefreshData(currentCount + 1);
  }

  // Love fortune input persistence
  Future<Map<String, dynamic>?> getLoveFortuneInput() async {
    final prefs = await SharedPreferences.getInstance();
    final inputString = prefs.getString(_loveFortuneInputKey);

    if (inputString != null) {
      try {
        return json.decode(inputString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('[StorageService] Failed to parse love fortune input: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveLoveFortuneInput(Map<String, dynamic> input) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loveFortuneInputKey, json.encode(input));
    debugPrint('[StorageService] Love fortune input saved');
  }

  Future<void> clearLoveFortuneInput() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loveFortuneInputKey);
  }

  // Dream interpretation result persistence (F15: 결과 저장, 다음날까지 표시)
  Future<Map<String, dynamic>?> getDreamResult() async {
    final prefs = await SharedPreferences.getInstance();
    final resultString = prefs.getString(_dreamResultKey);

    if (resultString != null) {
      try {
        final data = json.decode(resultString) as Map<String, dynamic>;
        final savedDate = data['savedDate'] as String?;

        // 날짜가 오늘이 아니면 null 반환 (다음날에는 새로 해몽 가능)
        final today = DateTime.now().toIso8601String().split('T')[0];
        if (savedDate != today) {
          debugPrint('[StorageService] Dream result expired (saved: $savedDate, today: $today)');
          await clearDreamResult();
          return null;
        }

        debugPrint('[StorageService] Dream result loaded for today');
        return data;
      } catch (e) {
        debugPrint('[StorageService] Failed to parse dream result: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveDreamResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // 저장 날짜와 함께 결과 저장
    final dataToSave = {
      ...result,
      'savedDate': today,
    };

    await prefs.setString(_dreamResultKey, json.encode(dataToSave));
    debugPrint('[StorageService] Dream result saved for $today');
  }

  Future<void> clearDreamResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dreamResultKey);
    debugPrint('[StorageService] Dream result cleared');
  }

  // Fortune gauge data management
  Future<Map<String, dynamic>?> getFortuneGaugeData() async {
    final prefs = await SharedPreferences.getInstance();
    final gaugeString = prefs.getString(_fortuneGaugeKey);

    if (gaugeString != null) {
      try {
        return json.decode(gaugeString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('[StorageService] Failed to parse fortune gauge data: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveFortuneGaugeData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fortuneGaugeKey, json.encode(data));
    debugPrint('[StorageService] Fortune gauge data saved');
  }

  Future<void> clearFortuneGaugeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fortuneGaugeKey);
    debugPrint('[StorageService] Fortune gauge data cleared');
  }
}