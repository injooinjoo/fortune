import 'dart:convert';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/data/models/fortune_response_model.dart';
import 'package:fortune/services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages data synchronization between Flutter app and native widgets
class WidgetDataManager {
  static const String _dailyFortuneKey = 'widget_daily_fortune_data';
  static const String _loveFortuneKey = 'widget_love_fortune_data';
  static const String _lastUpdateKey = 'widget_last_update';
  
  /// Initialize widget data manager
  static Future<void> initialize() async {
    try {
      await WidgetService.initialize();
      await _checkAndUpdateWidgets();
      Logger.info('Widget data manager initialized');
    } catch (e) {
      Logger.warning('[WidgetDataManager] 위젯 데이터 매니저 초기화 실패 (선택적 기능, 위젯 데이터 비활성화): $e');
    }
  }
  
  /// Update daily fortune widget with new data
  static Future<void> updateDailyFortune(FortuneResponseModel fortune) async {
    try {
      // Calculate fortune score (0-100,
      final score = _calculateFortuneScore(fortune);
      
      // Get lucky items
      final luckyColor = fortune.data?.luckyColor ?? '파란색';
      final luckyNumber = fortune.data?.luckyNumber?.toString() ?? '7';
      
      // Update widget
      await WidgetService.updateDailyFortuneWidget(
        score: score.toString(),
        message: fortune.data?.content ?? '',
        detailedFortune: fortune.data?.summary ?? '',
        additionalData: {
          'luckyColor': luckyColor,
          'luckyNumber': luckyNumber,
          'fortuneType': fortune.data?.type ?? 'daily',
          'createdAt': DateTime.now().toIso8601String()});

      // Save to local storage
      await _saveFortuneData(_dailyFortuneKey, fortune);
      
      Logger.info('Daily fortune widget updated');
    } catch (e) {
      Logger.warning('[WidgetDataManager] 일일 운세 위젯 업데이트 실패 (선택적 기능, 위젯 비활성화): $e');
    }
  }
  
  /// Update love fortune widget with compatibility data
  static Future<void> updateLoveFortune({
    required String partnerName,
    required int compatibilityScore,
    required String message,
    Map<String, dynamic>? additionalData}) async {
    try {
      await WidgetService.updateLoveFortuneWidget(
        compatibilityScore: compatibilityScore.toString(),
        partnerName: partnerName,
        message: message,
        additionalData: additionalData);
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_loveFortuneKey, jsonEncode({
        'partnerName': partnerName,
        'compatibilityScore': compatibilityScore,
        'message': message,
        'additionalData': additionalData,
        'updatedAt': null}));
      
      Logger.info('Love fortune widget updated');
    } catch (e) {
      Logger.warning('[WidgetDataManager] 사랑 운세 위젯 업데이트 실패 (선택적 기능, 위젯 비활성화): $e');
    }
  }
  
  /// Clear all widget data
  static Future<void> clearAllWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dailyFortuneKey);
      await prefs.remove(_loveFortuneKey);
      await prefs.remove(_lastUpdateKey);
      
      // End all live activities
      // await LiveActivityService.endAllActivities();
      
      Logger.info('All widget data cleared');
    } catch (e) {
      Logger.warning('[WidgetDataManager] 위젯 데이터 삭제 실패 (선택적 기능, 일부 데이터 유지됨): $e');
    }
  }
  
  /// Check if widgets need updating
  static Future<void> _checkAndUpdateWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString(_lastUpdateKey);
      
      if (lastUpdateString != null) {
        final lastUpdate = DateTime.parse(lastUpdateString);
        final now = DateTime.now();
        
        // Update if last update was more than 1 hour ago
        if (now.difference(lastUpdate).inHours >= 1) {
          await _loadAndUpdateWidgets();
        }
      }
    } catch (e) {
      Logger.warning('[WidgetDataManager] 위젯 업데이트 확인 실패 (선택적 기능, 자동 업데이트 비활성화): $e');
    }
  }
  
  /// Load saved data and update widgets
  static Future<void> _loadAndUpdateWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update daily fortune widget
      final dailyFortuneString = prefs.getString(_dailyFortuneKey);
      if (dailyFortuneString != null) {
        final fortuneData = jsonDecode(dailyFortuneString);
        final fortune = FortuneResponseModel.fromJson(fortuneData);
        await updateDailyFortune(fortune);
      }
      
      // Update love fortune widget
      final loveFortuneString = prefs.getString(_loveFortuneKey);
      if (loveFortuneString != null) {
        final loveData = jsonDecode(loveFortuneString);
        await updateLoveFortune(
          partnerName: loveData['partnerName'],
          compatibilityScore: loveData['compatibilityScore'],
          message: loveData['message'],
          additionalData: loveData['additionalData']);
      }
      
      // Update last update time
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      Logger.warning('[WidgetDataManager] 위젯 데이터 로드 및 업데이트 실패 (선택적 기능, 위젯 비활성화): $e');
    }
  }
  
  /// Save fortune data to local storage
  static Future<void> _saveFortuneData(String key, FortuneResponseModel fortune) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode({
        'success': fortune.success,
        'message': fortune.message,
        'data': fortune.data != null ? {
          'type': fortune.data!.type,
          'content': fortune.data!.content,
          'createdAt': fortune.data!.createdAt?.toIso8601String(),
          'luckyColor': fortune.data!.luckyColor,
          'luckyNumber': fortune.data!.luckyNumber,
          'summary': null} : null}));
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      Logger.warning('[WidgetDataManager] 운세 데이터 저장 실패 (선택적 기능, 위젯 업데이트 안됨): $e');
    }
  }
  
  /// Calculate fortune score from fortune response
  static int _calculateFortuneScore(FortuneResponseModel fortune) {
    // Extract score from fortune message or additional info
    // This is a simplified implementation - adjust based on your actual data
    final data = fortune.data;
    if (data != null && data.score != null) {
      return data.score!;
    }
    
    // Default scoring based on fortune type
    switch (fortune.data?.type) {
      case 'daily':
        return 75 + DateTime.now().day % 25; // Dynamic daily score
      case 'love':
        return 60 + DateTime.now().day % 40;
      case 'career':
        return 70 + DateTime.now().day % 30;
      default:
        return 50 + DateTime.now().day % 50;
    }
  }
  
  /// Handle widget click from native side
  static Future<void> handleWidgetClick(Map<String, dynamic> params) async {
    try {
      Logger.info('Supabase initialized successfully');

      // Navigate to appropriate screen based on widget type
      // This should be implemented based on your navigation structure
    } catch (e) {
      Logger.warning('[WidgetDataManager] 위젯 클릭 처리 실패 (선택적 기능, 앱 직접 실행 필요): $e');
    }
  }
}