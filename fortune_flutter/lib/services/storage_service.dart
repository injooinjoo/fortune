import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _userProfileKey = 'userProfile';
  static const String _recentFortunesKey = 'recentFortunes';
  static const String _lastUpdateDateKey = 'fortune_last_update_date';

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
      'visitedAt': DateTime.now().millisecondsSinceEpoch,
    });
    
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
}