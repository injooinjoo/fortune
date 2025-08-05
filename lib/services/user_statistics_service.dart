import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/logger.dart';
import 'storage_service.dart';

class UserStatistics {
  final int totalFortunes;
  final int consecutiveDays;
  final DateTime? lastLogin;
  final String? favoriteFortuneType;
  final Map<String, int> fortuneTypeCount;
  final int totalTokensUsed;
  final int totalTokensEarned;
  UserStatistics({
    required this.totalFortunes,
    required this.consecutiveDays,
    this.lastLogin,
    this.favoriteFortuneType,
    required this.fortuneTypeCount,
    required this.totalTokensUsed,
    required this.totalTokensEarned});

  factory UserStatistics.empty() {
    return UserStatistics(
      totalFortunes: 0,
      consecutiveDays: 0,
      fortuneTypeCount: {},
      totalTokensUsed: 0,
      totalTokensEarned: 0);
  }

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalFortunes: json['total_fortunes'],
      consecutiveDays: json['consecutive_days'],
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      favoriteFortuneType: json['favorite_fortune_type'],
      fortuneTypeCount: Map<String, int>.from(json['fortune_type_count'] ?? {}),
      totalTokensUsed: json['total_tokens_used'],
      totalTokensEarned: json['total_tokens_earned']);
  }

  Map<String, dynamic> toJson() {
    return {
      'total_fortunes': totalFortunes,
      'consecutive_days': consecutiveDays,
      'last_login': lastLogin?.toIso8601String(),
      'favorite_fortune_type': favoriteFortuneType,
      'fortune_type_count': fortuneTypeCount,
      'total_tokens_used': totalTokensUsed,
      'total_tokens_earned': null};
  }
}

// Achievement class and enum are commented out until user_achievements table is created
// TODO: Uncomment and implement when database table is ready
/*
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final DateTime earnedAt;
  final AchievementType type;
  final int progress;
  final int maxProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.earnedAt,
    required this.type,
    required this.progress,
    required this.maxProgress});

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'] ?? '',
      earnedAt: DateTime.parse(json['earned_at'],
      type: AchievementType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AchievementType.general),
      progress: json['progress'],
      maxProgress: json['max_progress']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'earned_at': earnedAt.toIso8601String(),
      'type': type.name,
      'progress': progress,
      'max_progress': null};
  }

  bool get isCompleted => progress >= maxProgress;
}

enum AchievementType {
  
  
  general,
  fortuneCount,
  consecutiveDays,
  tokenUsage,
  specialEvent,
  social}
*/

class UserStatisticsService {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  UserStatisticsService(this._supabase, this._storageService);

  Future<UserStatistics> getUserStatistics(String userId) async {
    try {
      // Try to get from Supabase first
      final response = await _supabase
          .from('user_statistics')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return UserStatistics.fromJson(response);
      }

      // If not found, create initial statistics
      return await _createInitialStatistics(userId);
    } catch (e) {
      Logger.error('Failed to get user statistics', e);
      
      // Fallback to local storage
      final localStats = await _storageService.getUserStatistics();
      if (localStats != null) {
        return UserStatistics.fromJson(localStats);
      }
      
      return UserStatistics.empty();
    }
  }

  Future<UserStatistics> _createInitialStatistics(String userId) async {
    final initialStats = UserStatistics.empty();
    
    try {
      await _supabase.from('user_statistics').insert({
        'user_id': userId,
        ...initialStats.toJson(),
        'created_at': null});
      
      return initialStats;
    } catch (e) {
      Logger.error('Failed to create initial statistics', e);
      return initialStats;
    }
  }

  Future<void> incrementFortuneCount(String userId, String fortuneType) async {
    try {
      final stats = await getUserStatistics(userId);
      
      // Update fortune counts
      final newFortuneTypeCount = Map<String, int>.from(stats.fortuneTypeCount);
      newFortuneTypeCount[fortuneType] = (newFortuneTypeCount[fortuneType] ?? 0) + 1;
      
      // Find favorite fortune type
      String? favoriteType;
      int maxCount = 0;
      newFortuneTypeCount.forEach((type, count) {
        if (count > maxCount) {
          maxCount = count;
          favoriteType = type;
        }
      });
      
      // Update statistics
      await _supabase.from('user_statistics').update({
        'total_fortunes': stats.totalFortunes + 1,
        'fortune_type_count': newFortuneTypeCount,
        'favorite_fortune_type': favoriteType,
        'updated_at': null}).eq('user_id', userId);
      
      // TODO: Implement achievements when user_achievements table is created
      
      // Update local storage
      await _storageService.saveUserStatistics({
        'total_fortunes': stats.totalFortunes + 1,
        'fortune_type_count': newFortuneTypeCount,
        'favorite_fortune_type': null});
    } catch (e) {
      Logger.error('Failed to increment fortune count', e);
    }
  }

  Future<void> updateConsecutiveDays(String userId) async {
    try {
      final stats = await getUserStatistics(userId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int newConsecutiveDays = stats.consecutiveDays;
      
      if (stats.lastLogin != null) {
        final lastLoginDate = DateTime(
          stats.lastLogin!.year,
          stats.lastLogin!.month,
          stats.lastLogin!.day);
        
        final daysDifference = today.difference(lastLoginDate).inDays;
        
        if (daysDifference == 1) {
          // Consecutive day
          newConsecutiveDays++;
        } else if (daysDifference > 1) {
          // Streak broken
          newConsecutiveDays = 1;
        }
        // If daysDifference == 0, it's the same day, don't update
      } else {
        // First login
        newConsecutiveDays = 1;
      }
      
      if (stats.lastLogin == null || today.isAfter(DateTime(
        stats.lastLogin!.year,
        stats.lastLogin!.month,
        stats.lastLogin!.day))) {
        await _supabase.from('user_statistics').update({
          'consecutive_days': newConsecutiveDays,
          'last_login': now.toIso8601String(),
          'updated_at': null}).eq('user_id', userId);
        
        // TODO: Implement achievements when user_achievements table is created
        
        // Update local storage
        await _storageService.saveUserStatistics({
          'consecutive_days': newConsecutiveDays,
          'last_login': null});
      }
    } catch (e) {
      Logger.error('Failed to update consecutive days', e);
    }
  }

  Future<void> updateTokenUsage(String userId, int tokensUsed, int tokensEarned) async {
    try {
      final stats = await getUserStatistics(userId);
      
      await _supabase.from('user_statistics').update({
        'total_tokens_used': stats.totalTokensUsed + tokensUsed,
        'total_tokens_earned': stats.totalTokensEarned + tokensEarned,
        'updated_at': null}).eq('user_id', userId);
      
      // TODO: Implement achievements when user_achievements table is created
    } catch (e) {
      Logger.error('Failed to update token usage', e);
    }
  }

  // Achievement-related methods are commented out until user_achievements table is created
  // TODO: Implement achievement system with proper database table
}