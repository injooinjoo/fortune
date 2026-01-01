import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/fortune.dart';

/// API 호출 최적화를 위한 의사결정 서비스
///
/// 전략:
/// 1. 사용자 등급별 차등 (40%)
/// 2. 운세 중요도별 차등 (30%)
/// 3. 시간대별 차등 (20%)
/// 4. 랜덤 요소 (10%)
class FortuneApiDecisionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Random _random = Random();

  /// API 호출 여부 결정
  Future<bool> shouldCallApi({
    required String userId,
    required String fortuneType,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      // 각 전략별 점수 계산 (0.0 ~ 1.0)
      final userGradeScore = await _calculateUserGradeScore(userId);
      final importanceScore = _calculateImportanceScore(fortuneType);
      final timeScore = _calculateTimeScore();
      final randomScore = _random.nextDouble();

      // 가중치 적용하여 최종 확률 계산
      final finalProbability = (userGradeScore * 0.4) +
          (importanceScore * 0.3) +
          (timeScore * 0.2) +
          (randomScore * 0.1);

      final shouldCall = _random.nextDouble() < finalProbability;

      Logger.info('🎲 [API Decision] Should call API: $shouldCall', {
        'userId': userId,
        'fortuneType': fortuneType,
        'userGradeScore': userGradeScore.toStringAsFixed(2),
        'importanceScore': importanceScore.toStringAsFixed(2),
        'timeScore': timeScore.toStringAsFixed(2),
        'randomScore': randomScore.toStringAsFixed(2),
        'finalProbability': finalProbability.toStringAsFixed(2),
      });

      return shouldCall;
    } catch (e, stackTrace) {
      Logger.error('Error in shouldCallApi', e, stackTrace);
      // 에러 시 안전하게 API 호출
      return true;
    }
  }

  /// 전략 A: 사용자 등급별 점수 (VIP/신규/일반/휴면)
  Future<double> _calculateUserGradeScore(String userId) async {
    try {
      // 사용자의 운세 이력 조회
      final history = await _supabase
          .from('fortune_history')
          .select('created_at, view_count')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      if (history.isEmpty) {
        // 신규 사용자: 높은 확률 (80%)
        return 0.8;
      }

      // final totalFortunes = history.length; // 필요시 사용
      final firstFortuneDate =
          DateTime.parse(history.last['created_at'] as String);
      final daysSinceFirst = DateTime.now().difference(firstFortuneDate).inDays;
      final lastFortuneDate =
          DateTime.parse(history.first['created_at'] as String);
      final daysSinceLast = DateTime.now().difference(lastFortuneDate).inDays;

      // VIP 사용자 판단 (7일 이내 5회 이상 사용)
      final recentUse = history.where((h) {
        final date = DateTime.parse(h['created_at'] as String);
        return DateTime.now().difference(date).inDays <= 7;
      }).length;

      if (recentUse >= 5) {
        // VIP: 매우 높은 확률 (100%)
        return 1.0;
      }

      // 신규 사용자 (7일 이내 가입)
      if (daysSinceFirst <= 7) {
        return 0.8;
      }

      // 휴면 사용자 (30일 이상 미사용)
      if (daysSinceLast >= 30) {
        return 0.1;
      }

      // 일반 사용자: 중간 확률 (30%)
      return 0.3;
    } catch (e, stackTrace) {
      Logger.error('Error calculating user grade score', e, stackTrace);
      return 0.5; // 기본값
    }
  }

  /// 전략 B: 운세 타입별 중요도 점수
  double _calculateImportanceScore(String fortuneType) {
    // 중요 운세 (연애, 건강, 투자, 시험): 50%
    const highImportance = ['love', 'health', 'investment', 'exam'];
    if (highImportance.contains(fortuneType)) {
      return 0.5;
    }

    // 일반 운세 (꿈해몽, 전통사주, 가족): 30%
    const mediumImportance = [
      'dream',
      'traditional_saju',
      'family',
      'moving',
      'wish'
    ];
    if (mediumImportance.contains(fortuneType)) {
      return 0.3;
    }

    // 엔터테인먼트 (포춘쿠키, 부적, 바이오리듬): 10%
    const lowImportance = [
      'fortune_cookie',
      'talisman',
      'biorhythm',
      'person_to_avoid',
      'ex_fortune',
      'blind_date'
    ];
    if (lowImportance.contains(fortuneType)) {
      return 0.1;
    }

    // 기타: 20%
    return 0.2;
  }

  /// 전략 C: 시간대별 점수 (피크타임 절약)
  double _calculateTimeScore() {
    final hour = DateTime.now().hour;

    // 피크타임 (12-14시, 19-22시): 낮은 확률 (20%)
    if ((hour >= 12 && hour < 14) || (hour >= 19 && hour < 22)) {
      return 0.2;
    }

    // 오프피크: 높은 확률 (50%)
    return 0.5;
  }

  /// 기존 운세 중 유사한 것 찾기
  Future<Fortune?> getSimilarFortune({
    required String fortuneType,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      Logger.info('🔍 [Similar Fortune] Searching...', {
        'fortuneType': fortuneType,
        'userProfile': userProfile,
      });

      // 1순위: 동일 속성 매칭 (성별 + 나이대 + MBTI)
      var result = await _findByExactMatch(fortuneType, userProfile);
      if (result != null) {
        Logger.info('✅ [Similar Fortune] Found exact match');
        return result;
      }

      // 2순위: 완화된 조건 (성별 + 나이대만)
      result = await _findByRelaxedMatch(fortuneType, userProfile);
      if (result != null) {
        Logger.info('✅ [Similar Fortune] Found relaxed match');
        return result;
      }

      // 3순위: 운세 타입만 일치
      result = await _findByTypeOnly(fortuneType);
      if (result != null) {
        Logger.info('✅ [Similar Fortune] Found type-only match');
        return result;
      }

      Logger.info('❌ [Similar Fortune] No match found');
      return null;
    } catch (e, stackTrace) {
      Logger.error('Error finding similar fortune', e, stackTrace);
      return null;
    }
  }

  /// 1순위: 정확한 매칭
  Future<Fortune?> _findByExactMatch(
    String fortuneType,
    Map<String, dynamic> userProfile,
  ) async {
    final gender = userProfile['gender'] as String?;
    final birthDate = userProfile['birth_date'] as String?;
    final mbti = userProfile['mbti'] as String?;

    if (gender == null || birthDate == null) return null;

    final ageGroup = _calculateAgeGroup(birthDate);

    final result = await _supabase
        .from('fortune_history')
        .select('fortune_data')
        .eq('fortune_type', fortuneType)
        .eq('metadata->>gender', gender)
        .eq('metadata->>age_group', ageGroup)
        .eq('metadata->>mbti', mbti ?? '')
        .gte('created_at', DateTime.now().subtract(const Duration(days: 30)))
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (result == null) return null;

    return _convertToFortune(result['fortune_data'] as Map<String, dynamic>);
  }

  /// 2순위: 완화된 매칭
  Future<Fortune?> _findByRelaxedMatch(
    String fortuneType,
    Map<String, dynamic> userProfile,
  ) async {
    final gender = userProfile['gender'] as String?;
    final birthDate = userProfile['birth_date'] as String?;

    if (gender == null || birthDate == null) return null;

    final ageGroup = _calculateAgeGroup(birthDate);

    final result = await _supabase
        .from('fortune_history')
        .select('fortune_data')
        .eq('fortune_type', fortuneType)
        .eq('metadata->>gender', gender)
        .eq('metadata->>age_group', ageGroup)
        .gte('created_at', DateTime.now().subtract(const Duration(days: 60)))
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (result == null) return null;

    return _convertToFortune(result['fortune_data'] as Map<String, dynamic>);
  }

  /// 3순위: 타입만 매칭
  Future<Fortune?> _findByTypeOnly(String fortuneType) async {
    final result = await _supabase
        .from('fortune_history')
        .select('fortune_data')
        .eq('fortune_type', fortuneType)
        .gte('created_at', DateTime.now().subtract(const Duration(days: 90)))
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (result == null) return null;

    return _convertToFortune(result['fortune_data'] as Map<String, dynamic>);
  }

  /// 나이대 계산 (10세 단위)
  String _calculateAgeGroup(String birthDate) {
    final birth = DateTime.parse(birthDate);
    final age = DateTime.now().year - birth.year;
    final ageGroup = (age ~/ 10) * 10;
    return '${ageGroup}s'; // "20s", "30s", etc.
  }

  /// Fortune 엔티티로 변환
  Fortune _convertToFortune(Map<String, dynamic> data) {
    return Fortune(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      type: data['fortune_type'] as String,
      content: data['content'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      description: data['description'] as String?,
      overallScore: data['overall_score'] as int?,
      recommendations: (data['recommendations'] as List?)?.cast<String>(),
      warnings: (data['warnings'] as List?)?.cast<String>(),
      luckyItems: data['lucky_items'] as Map<String, dynamic>?,
      additionalInfo: data['additional_info'] as Map<String, dynamic>?,
    );
  }

  /// 개인화된 운세로 변환 (이름, 날짜 등 교체)
  Fortune personalizeFortune(Fortune fortune, String userId, String userName) {
    // 기존 운세 내용에서 이름/날짜만 교체
    final personalizedContent = fortune.content
        .replaceAll(RegExp(r'\b\w+님\b'), '$userName님')
        .replaceAll(
            RegExp(r'\d{4}년 \d{1,2}월 \d{1,2}일'),
            '${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일');

    return Fortune(
      id: fortune.id,
      userId: userId,
      type: fortune.type,
      content: personalizedContent,
      createdAt: DateTime.now(),
      description: fortune.description,
      overallScore: fortune.overallScore,
      recommendations: fortune.recommendations,
      warnings: fortune.warnings,
      luckyItems: fortune.luckyItems,
      additionalInfo: fortune.additionalInfo,
    );
  }
}
