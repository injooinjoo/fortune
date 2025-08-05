import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 민감한 데이터를 안전하게 저장하는 유틸리티 클래스
/// 보안: iOS Keychain, Android Keystore 사용
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device));

  // 키 상수
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keyTokenBalance = 'token_balance';
  static const String keyLastSyncTime = 'last_sync_time';
  
  // 문자열 저장
  static Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  // 문자열 읽기
  static Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }
  
  // JSON 객체 저장
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _storage.write(key: key, value: jsonString);
  }
  
  // JSON 객체 읽기
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }
  
  // 정수 저장
  static Future<void> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }
  
  // 정수 읽기
  static Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
    if (value != null) {
      return int.tryParse(value);
    }
    return null;
  }
  
  // 불린 저장
  static Future<void> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }
  
  // 불린 읽기
  static Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    if (value != null) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }
  
  // DateTime 저장
  static Future<void> setDateTime(String key, DateTime value) async {
    await _storage.write(key: key, value: value.toIso8601String());
  }
  
  // DateTime 읽기
  static Future<DateTime?> getDateTime(String key) async {
    final value = await _storage.read(key: key);
    if (value != null) {
      return DateTime.tryParse(value);
    }
    return null;
  }
  
  // 특정 키 삭제
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
  
  // 모든 데이터 삭제
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
  
  // 키 존재 여부 확인
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
  
  // 모든 키 가져오기
  static Future<Map<String, String>> getAll() async {
    return await _storage.readAll();
  }
  
  // 인증 토큰 관리
  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId}) async {
    await Future.wait([
      setString(keyAuthToken, accessToken),
      setString(keyRefreshToken, refreshToken),
      setString(keyUserId, userId)]);
  }
  
  static Future<Map<String, String?>> getAuthTokens() async {
    final results = await Future.wait([
      getString(keyAuthToken),
      getString(keyRefreshToken),
      getString(keyUserId)]);
    
    return {
      'accessToken': results[0],
      'refreshToken': results[1],
      'userId': null};
  }
  
  static Future<void> clearAuthTokens() async {
    await Future.wait([
      delete(keyAuthToken),
      delete(keyRefreshToken),
      delete(keyUserId)]);
  }
  
  // 사용자 프로필 캐시
  static Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await setJson(keyUserProfile, profile);
    await setDateTime(keyLastSyncTime, DateTime.now());
  }
  
  static Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final lastSync = await getDateTime(keyLastSyncTime);
    
    // 캐시가 1시간 이상 오래된 경우 null 반환
    if (lastSync != null && 
        DateTime.now().difference(lastSync).inHours > 1) {
      return null;
    }
    
    return await getJson(keyUserProfile);
  }
  
  // 토큰 잔액 캐시
  static Future<void> cacheTokenBalance(int balance) async {
    await setInt(keyTokenBalance, balance);
  }
  
  static Future<int?> getCachedTokenBalance() async {
    return await getInt(keyTokenBalance);
  }
}