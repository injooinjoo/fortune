import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/services/native_platform_service.dart';

/// Service for managing iOS Live Activities and Dynamic Island
class LiveActivityService {
  static final Map<String, String> _activeActivities = {};
  
  /// Check if Live Activities are supported
  static bool get isSupported {
    return defaultTargetPlatform == TargetPlatform.iOS && 
           Platform.isIOS && 
           int.parse(Platform.operatingSystemVersion.split('.')[0]) >= 16;
  }
  
  /// Start a fortune live activity
  static Future<String?> startFortuneActivity({
    required String fortuneType,
    required Map<String, dynamic> initialData}) async {
    if (!isSupported) {
      Logger.warning('Live Activities not supported on this device');
      return null;
    }
    
    try {
      final activityId = await NativePlatformService.ios.startLiveActivity(
        attributes: {
          'fortuneType': fortuneType,
          'startedAt': DateTime.now().toIso8601String()},
        contentState: initialData);
      
      if (activityId != null) {
        _activeActivities[fortuneType] = activityId;
        Logger.info('Started live activity for $fortuneType: $activityId');
      }
      
      return activityId;
    } catch (e) {
      Logger.warning('[LiveActivityService] Live Activity 시작 실패 (선택적 기능, 무시): $e');
      return null;
    }
  }
  
  /// Update an existing live activity
  static Future<void> updateFortuneActivity({
    required String fortuneType,
    required Map<String, dynamic> updatedData}) async {
    if (!isSupported) return;
    
    final activityId = _activeActivities[fortuneType];
    if (activityId == null) {
      Logger.warning('No active live activity found for fortune type: $fortuneType');
      return;
    }
    
    try {
      await NativePlatformService.ios.updateDynamicIsland(
        activityId: activityId,
        content: updatedData);
      Logger.info('Live Activity updated successfully');
    } catch (e) {
      Logger.warning('[LiveActivityService] Live Activity 업데이트 실패 (선택적 기능, 무시): $e');
    }
  }
  
  /// End a live activity
  static Future<void> endFortuneActivity(String fortuneType) async {
    if (!isSupported) return;
    
    final activityId = _activeActivities[fortuneType];
    if (activityId == null) {
      Logger.warning('No active live activity found for fortune type: $fortuneType');
      return;
    }
    
    try {
      await NativePlatformService.ios.endLiveActivity(activityId);
      _activeActivities.remove(fortuneType);
      Logger.info('Live Activity ended successfully');
    } catch (e) {
      Logger.warning('[LiveActivityService] Live Activity 종료 실패 (선택적 기능, 무시): $e');
    }
  }
  
  /// End all active live activities
  static Future<void> endAllActivities() async {
    if (!isSupported) return;
    
    for (final entry in _activeActivities.entries) {
      await endFortuneActivity(entry.key);
    }
  }
  
  /// Start a daily fortune live activity
  static Future<String?> startDailyFortune({
    required String score,
    required String message,
    required String luckyColor,
    required String luckyNumber}) async {
    return startFortuneActivity(
      fortuneType: 'daily',
      initialData: {
        'score': score,
        'message': message,
        'luckyColor': luckyColor,
        'luckyNumber': luckyNumber,
        'updatedAt': DateTime.now().toIso8601String()});
  }
  
  /// Start a compatibility check live activity
  static Future<String?> startCompatibilityCheck({
    required String userName,
    required String partnerName,
    required String status}) async {
    return startFortuneActivity(
      fortuneType: 'compatibility',
      initialData: {
        'userName': userName,
        'partnerName': partnerName,
        'status': status,
        'progress': 0,
        'updatedAt': DateTime.now().toIso8601String()});
  }
  
  /// Update compatibility check progress
  static Future<void> updateCompatibilityProgress({
    required int progress,
    required String status,
    String? score,
    String? message}) async {
    await updateFortuneActivity(
      fortuneType: 'compatibility',
      updatedData: {
        'progress': progress,
        'status': status,
        'score': score,
        'message': message,
        'updatedAt': DateTime.now().toIso8601String()});
  }
}