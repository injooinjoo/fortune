import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../../domain/models/face_condition.dart';

/// 컨디션 트렌드 상태
class FaceConditionTrackerState {
  final bool isLoading;
  final ConditionTrend? trend;
  final List<DailyCondition> weeklyConditions;
  final String? errorMessage;

  const FaceConditionTrackerState({
    this.isLoading = false,
    this.trend,
    this.weeklyConditions = const [],
    this.errorMessage,
  });

  FaceConditionTrackerState copyWith({
    bool? isLoading,
    ConditionTrend? trend,
    List<DailyCondition>? weeklyConditions,
    String? errorMessage,
  }) {
    return FaceConditionTrackerState(
      isLoading: isLoading ?? this.isLoading,
      trend: trend ?? this.trend,
      weeklyConditions: weeklyConditions ?? this.weeklyConditions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 컨디션 트래커 Provider
final faceConditionTrackerProvider = StateNotifierProvider<
    FaceConditionTrackerNotifier, FaceConditionTrackerState>((ref) {
  return FaceConditionTrackerNotifier();
});

/// 컨디션 트래커 상태 관리 클래스
class FaceConditionTrackerNotifier
    extends StateNotifier<FaceConditionTrackerState> {
  FaceConditionTrackerNotifier() : super(const FaceConditionTrackerState()) {
    _loadData();
  }

  final _supabase = Supabase.instance.client;

  /// 데이터 로드
  Future<void> _loadData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      // 병렬로 데이터 로드
      final results = await Future.wait([
        _loadTrend(userId),
        _loadWeeklyConditions(userId),
      ]);

      state = state.copyWith(
        isLoading: false,
        trend: results[0] as ConditionTrend?,
        weeklyConditions: results[1] as List<DailyCondition>,
      );

      developer.log('✅ FaceConditionTracker: 데이터 로드 완료');
    } catch (e) {
      developer.log('❌ FaceConditionTracker 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 트렌드 로드
  Future<ConditionTrend?> _loadTrend(String userId) async {
    try {
      final response = await _supabase
          .rpc('get_face_condition_trend', params: {'p_user_id': userId});

      if (response == null || (response as List).isEmpty) {
        return null;
      }

      final data = response[0] as Map<String, dynamic>;
      return ConditionTrend(
        weeklyAverage: (data['weekly_average'] as num?)?.toDouble() ?? 0.0,
        weeklyChange: (data['weekly_change'] as num?)?.toDouble() ?? 0.0,
        trendDirection: data['trend_direction'] as String? ?? 'stable',
        trendInsight: data['trend_insight'] as String? ?? '',
        dailyConditions: [],
      );
    } catch (e) {
      developer.log('⚠️ FaceConditionTracker 트렌드 로드 실패: $e');
      return null;
    }
  }

  /// 주간 컨디션 로드
  Future<List<DailyCondition>> _loadWeeklyConditions(String userId) async {
    try {
      final response = await _supabase
          .rpc('get_weekly_face_condition', params: {'p_user_id': userId});

      if (response == null) return [];

      return (response as List).map((data) {
        final map = data as Map<String, dynamic>;
        return DailyCondition(
          date: DateTime.parse(map['analysis_date'] as String),
          overallScore: map['overall_score'] as int? ?? 0,
          complexionScore: map['complexion_score'] as int? ?? 0,
          puffinessLevel: map['puffiness_level'] as int? ?? 0,
          fatigueLevel: map['fatigue_level'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      developer.log('⚠️ FaceConditionTracker 주간 데이터 로드 실패: $e');
      return [];
    }
  }

  /// 오늘의 컨디션 저장
  Future<void> saveCondition(FaceCondition condition) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      developer.log('💾 FaceConditionTracker: 컨디션 저장');

      await _supabase.from('face_reading_conditions').upsert({
        'user_id': userId,
        'analysis_date': DateTime.now().toIso8601String().split('T')[0],
        'complexion_score': condition.complexionScore,
        'complexion_description': condition.complexionDescription,
        'puffiness_level': condition.puffinessLevel,
        'puffiness_description': condition.puffinessDescription,
        'fatigue_level': condition.fatigueLevel,
        'fatigue_description': condition.fatigueDescription,
        'overall_score': condition.overallScore,
        'today_summary': condition.todaySummary,
        'improvement_tips':
            condition.improvementTips.map((t) => t.toJson()).toList(),
      }, onConflict: 'user_id,analysis_date');

      // 데이터 새로고침
      await _loadData();

      developer.log('✅ FaceConditionTracker: 컨디션 저장 완료');
    } catch (e) {
      developer.log('❌ FaceConditionTracker 저장 실패: $e');
      rethrow;
    }
  }

  /// 두 날짜 비교
  Future<Map<String, dynamic>?> compareConditions(
      DateTime date1, DateTime date2) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase.rpc('compare_face_conditions', params: {
        'p_user_id': userId,
        'p_date1': date1.toIso8601String().split('T')[0],
        'p_date2': date2.toIso8601String().split('T')[0],
      });

      if (response == null || (response as List).isEmpty) {
        return null;
      }

      developer.log('📊 FaceConditionTracker: 비교 완료');
      return response[0] as Map<String, dynamic>;
    } catch (e) {
      developer.log('❌ FaceConditionTracker 비교 실패: $e');
      return null;
    }
  }

  /// 새로고침
  Future<void> refresh() => _loadData();
}

/// 오늘의 컨디션 Provider
final todayConditionProvider = Provider<DailyCondition?>((ref) {
  final tracker = ref.watch(faceConditionTrackerProvider);
  final today = DateTime.now();

  try {
    return tracker.weeklyConditions.firstWhere(
      (c) =>
          c.date.year == today.year &&
          c.date.month == today.month &&
          c.date.day == today.day,
    );
  } catch (_) {
    return null;
  }
});

/// 트렌드 방향 Provider
final conditionTrendDirectionProvider = Provider<String>((ref) {
  final tracker = ref.watch(faceConditionTrackerProvider);
  return tracker.trend?.trendDirection ?? 'stable';
});

/// 트렌드 인사이트 Provider
final conditionTrendInsightProvider = Provider<String>((ref) {
  final tracker = ref.watch(faceConditionTrackerProvider);
  return tracker.trend?.trendInsight ?? '아직 분석 데이터가 부족해요';
});
