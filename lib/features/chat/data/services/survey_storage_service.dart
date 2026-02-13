import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 건강 설문 데이터 모델
class HealthSurveyData {
  final String? id;
  final String userId;
  final String? currentCondition;
  final List<String> concernedBodyParts;
  final int sleepQuality;
  final int exerciseFrequency;
  final int stressLevel;
  final int mealRegularity;
  final bool hasChronicCondition;
  final String? chronicCondition;
  final DateTime? createdAt;

  HealthSurveyData({
    this.id,
    required this.userId,
    this.currentCondition,
    this.concernedBodyParts = const [],
    required this.sleepQuality,
    required this.exerciseFrequency,
    required this.stressLevel,
    required this.mealRegularity,
    this.hasChronicCondition = false,
    this.chronicCondition,
    this.createdAt,
  });

  factory HealthSurveyData.fromJson(Map<String, dynamic> json) {
    return HealthSurveyData(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      currentCondition: json['current_condition'] as String?,
      concernedBodyParts: json['concerned_body_parts'] != null
          ? List<String>.from(json['concerned_body_parts'] as List)
          : [],
      sleepQuality: json['sleep_quality'] as int? ?? 3,
      exerciseFrequency: json['exercise_frequency'] as int? ?? 3,
      stressLevel: json['stress_level'] as int? ?? 3,
      mealRegularity: json['meal_regularity'] as int? ?? 3,
      hasChronicCondition: json['has_chronic_condition'] as bool? ?? false,
      chronicCondition: json['chronic_condition'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_condition': currentCondition,
      'concerned_body_parts': concernedBodyParts,
      'sleep_quality': sleepQuality,
      'exercise_frequency': exerciseFrequency,
      'stress_level': stressLevel,
      'meal_regularity': mealRegularity,
      'has_chronic_condition': hasChronicCondition,
      'chronic_condition': chronicCondition,
    };
  }

  /// API 전송용 (이전 설문 비교용)
  Map<String, dynamic> toApiPayload() {
    return {
      'sleep_quality': sleepQuality,
      'exercise_frequency': exerciseFrequency,
      'stress_level': stressLevel,
      'meal_regularity': mealRegularity,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// 사주 오행 데이터 모델
class SajuElementData {
  final Map<String, num>? elementBalance;
  final String? lackingElement;
  final String? dominantElement;

  SajuElementData({
    this.elementBalance,
    this.lackingElement,
    this.dominantElement,
  });

  factory SajuElementData.fromJson(Map<String, dynamic> json) {
    Map<String, num>? balance;

    // element_balance가 있으면 사용
    if (json['element_balance'] != null) {
      final rawBalance = json['element_balance'] as Map<String, dynamic>;
      balance = rawBalance.map((k, v) => MapEntry(k, (v as num?) ?? 0));
    } else {
      // 개별 필드에서 조합
      balance = {
        '목': (json['element_wood'] as num?) ?? 0,
        '화': (json['element_fire'] as num?) ?? 0,
        '토': (json['element_earth'] as num?) ?? 0,
        '금': (json['element_metal'] as num?) ?? 0,
        '수': (json['element_water'] as num?) ?? 0,
      };
    }

    return SajuElementData(
      elementBalance: balance,
      lackingElement:
          json['lacking_element'] as String? ?? json['weak_element'] as String?,
      dominantElement: json['dominant_element'] as String? ??
          json['strong_element'] as String?,
    );
  }

  /// API 전송용
  Map<String, dynamic> toApiPayload() {
    return {
      'element_balance': elementBalance,
      'lacking_element': lackingElement,
      'dominant_element': dominantElement,
    };
  }

  bool get hasData =>
      lackingElement != null ||
      dominantElement != null ||
      (elementBalance != null && elementBalance!.isNotEmpty);
}

/// 건강 설문 저장/조회 서비스
///
/// 기능:
/// - 건강 설문 저장 (user_health_surveys 테이블)
/// - 이전 설문 조회 (비교 분석용)
/// - 사주 오행 데이터 조회 (user_saju 테이블)
/// - 생년월일 조회 (user_profiles 테이블)
class SurveyStorageService {
  final SupabaseClient _supabase;

  SurveyStorageService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 현재 사용자 ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// 건강 설문 저장
  ///
  /// [survey]: 저장할 설문 데이터
  /// Returns: 저장된 설문 ID
  Future<String?> saveSurvey(HealthSurveyData survey) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        debugPrint('⚠️ [SurveyStorageService] 로그인 필요');
        return null;
      }

      final data = survey.toJson();
      data['user_id'] = userId; // 현재 사용자 ID로 덮어쓰기

      final response = await _supabase
          .from('user_health_surveys')
          .insert(data)
          .select('id')
          .single();

      final id = response['id'] as String?;
      debugPrint('✅ [SurveyStorageService] 설문 저장 완료: $id');
      return id;
    } catch (e) {
      debugPrint('❌ [SurveyStorageService] 설문 저장 실패: $e');
      return null;
    }
  }

  /// 가장 최근 설문 조회 (이전 설문 비교용)
  ///
  /// [excludeToday]: true면 오늘 저장된 설문 제외 (현재 설문과 비교 시)
  Future<HealthSurveyData?> getLatestSurvey({bool excludeToday = true}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return null;

      var query = _supabase
          .from('user_health_surveys')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1);

      if (excludeToday) {
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        query = _supabase
            .from('user_health_surveys')
            .select()
            .eq('user_id', userId)
            .lt('created_at', todayStart.toIso8601String())
            .order('created_at', ascending: false)
            .limit(1);
      }

      final response = await query;

      if (response.isEmpty) {
        debugPrint('ℹ️ [SurveyStorageService] 이전 설문 없음');
        return null;
      }

      final survey = HealthSurveyData.fromJson(response.first);
      debugPrint('✅ [SurveyStorageService] 이전 설문 조회: ${survey.createdAt}');
      return survey;
    } catch (e) {
      debugPrint('❌ [SurveyStorageService] 이전 설문 조회 실패: $e');
      return null;
    }
  }

  /// 사주 오행 데이터 조회
  Future<SajuElementData?> getSajuElementData() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_saju')
          .select('''
            element_balance,
            lacking_element,
            dominant_element,
            weak_element,
            strong_element,
            element_wood,
            element_fire,
            element_earth,
            element_metal,
            element_water
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('ℹ️ [SurveyStorageService] 사주 데이터 없음');
        return null;
      }

      final sajuData = SajuElementData.fromJson(response);
      debugPrint(
          '✅ [SurveyStorageService] 사주 오행: 부족=${sajuData.lackingElement}, 강함=${sajuData.dominantElement}');
      return sajuData;
    } catch (e) {
      debugPrint('❌ [SurveyStorageService] 사주 데이터 조회 실패: $e');
      return null;
    }
  }

  /// 생년월일 조회 (user_profiles 테이블)
  Future<Map<String, String?>?> getBirthInfo() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select('birth_date, birth_time')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('ℹ️ [SurveyStorageService] 생년월일 정보 없음');
        return null;
      }

      final birthDate = response['birth_date'] as String?;
      final birthTime = response['birth_time'] as String?;

      debugPrint('✅ [SurveyStorageService] 생년월일: $birthDate, 시간: $birthTime');
      return {
        'birthDate': birthDate,
        'birthTime': birthTime,
      };
    } catch (e) {
      debugPrint('❌ [SurveyStorageService] 생년월일 조회 실패: $e');
      return null;
    }
  }

  /// 건강운 API 호출을 위한 통합 데이터 조회
  ///
  /// Returns: birthDate, sajuData, previousSurvey 포함 Map
  Future<Map<String, dynamic>> getHealthFortuneContext() async {
    final results = await Future.wait([
      getBirthInfo(),
      getSajuElementData(),
      getLatestSurvey(excludeToday: true),
    ]);

    final birthInfo = results[0] as Map<String, String?>?;
    final sajuData = results[1] as SajuElementData?;
    final previousSurvey = results[2] as HealthSurveyData?;

    return {
      'birthDate': birthInfo?['birthDate'],
      'birthTime': birthInfo?['birthTime'],
      'sajuData': sajuData?.hasData == true ? sajuData!.toApiPayload() : null,
      'previousSurvey': previousSurvey?.toApiPayload(),
    };
  }
}
