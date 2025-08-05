import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _userProfileKey = 'userProfile';
  static const String _recentFortunesKey = 'recentFortunes';
  static const String _lastUpdateDateKey = 'fortune_last_update_date';
  static const String _guestModeKey = 'isGuestMode';
  static const String _userStatisticsKey = 'userStatistics';
  static const String _dailyFortuneRefreshKey = 'dailyFortuneRefresh';

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
    final prefs = await SharedPreferences.getInstance();
    final fortunesString = prefs.getString(_recentFortunesKey);
    
    if (fortunesString != null) {
      try {
        final List<dynamic> fortunes = json.decode(fortunesString);
        return fortunes.cast<Map<String, dynamic>>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Future<void> addRecentFortune(String path, String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> fortunes = await getRecentFortunes();
    
    // 기존에 같은 path가 있으면 제거
    fortunes.removeWhere((f) => f['path'] == path);
    
    // 새로운 항목을 맨 앞에 추가
    fortunes.insert(0, {
      'path': path,
      'title': title,
      'visitedAt': null});
    
    // 최대 10개까지만 저장
    if (fortunes.length > 10) {
      fortunes = fortunes.sublist(0, 10);
    }
    
    await prefs.setString(_recentFortunesKey, json.encode(fortunes));
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
}