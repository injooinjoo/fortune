import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fortune_result.dart';

// Generator imports
import 'fortune_generators/tarot_generator.dart';
import 'fortune_generators/moving_generator.dart';
import 'fortune_generators/time_based_generator.dart';
import 'fortune_generators/compatibility_generator.dart';
import 'fortune_generators/avoid_people_generator.dart';
import 'fortune_generators/ex_lover_generator.dart';
import 'fortune_generators/blind_date_generator.dart';
import 'fortune_generators/career_generator.dart';
import 'fortune_generators/exam_generator.dart';
import 'fortune_generators/health_generator.dart';
import 'fortune_generators/fortune_cookie_generator.dart';
import 'fortune_generators/wish_generator.dart';
import 'fortune_generators/lucky_items_generator.dart';
import 'fortune_generators/love_generator.dart';
import 'fortune_generators/talent_generator.dart';
import 'fortune_generators/traditional_saju_generator.dart';
import 'fortune_generators/exercise_generator.dart';

// Conditions imports
import '../../features/fortune/domain/models/conditions/love_fortune_conditions.dart';
import '../../features/fortune/domain/models/conditions/health_fortune_conditions.dart';
import '../../features/fortune/domain/models/conditions/exercise_fortune_conditions.dart';

import '../utils/logger.dart';

/// Generator Factory - 운세 생성기 팩토리
///
/// UnifiedFortuneService의 40+ switch-case를 분리하여
/// 단일 책임 원칙(SRP)을 준수하고 유지보수성을 향상시킴
///
/// 사용법:
/// ```dart
/// final factory = GeneratorFactory(supabase);
/// final result = await factory.generate(
///   fortuneType: 'daily',
///   inputConditions: {...},
///   dataSource: FortuneDataSource.api,
/// );
/// ```
class GeneratorFactory {
  final SupabaseClient _supabase;

  GeneratorFactory(this._supabase);

  /// 운세 생성 (통합 진입점)
  Future<FortuneResult> generate({
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
    required GeneratorDataSource dataSource,
  }) async {
    final normalizedType = fortuneType.toLowerCase().replaceAll('-', '_');

    Logger.info('[GeneratorFactory] 🔮 $fortuneType ($dataSource)');

    switch (dataSource) {
      case GeneratorDataSource.api:
        return await _generateFromAPI(normalizedType, inputConditions);
      case GeneratorDataSource.local:
        return await _generateFromLocal(normalizedType, inputConditions);
    }
  }

  /// API 기반 운세 생성 (Edge Function 호출)
  Future<FortuneResult> _generateFromAPI(
    String fortuneType,
    Map<String, dynamic> input,
  ) async {
    final isPremium = input['isPremium'] as bool? ?? false;

    switch (fortuneType) {
      // ==================== 기존 Generator 클래스 사용 ====================
      case 'moving':
        return await MovingGenerator.generate(input, _supabase);

      case 'time_based':
      case 'daily':
      case 'daily_calendar':
        return await TimeBasedGenerator.generate(input, _supabase);

      case 'compatibility':
        return await CompatibilityGenerator.generate(input, _supabase);

      case 'love':
        return await LoveGenerator.generate(
          conditions: LoveFortuneConditions.fromInputData(input),
          supabase: _supabase,
          isPremium: isPremium,
        );

      case 'talent':
        return await TalentGenerator.generate(input, _supabase);

      case 'traditional_saju':
        return await TraditionalSajuGenerator.generate(input, _supabase);

      case 'avoid_people':
        return await AvoidPeopleGenerator.generate(input, _supabase);

      case 'ex_lover':
        return await ExLoverGenerator.generate(input, _supabase);

      case 'blind_date':
        return await BlindDateGenerator.generate(input, _supabase);

      case 'career':
      case 'career_future':
      case 'career_seeker':
      case 'career_change':
      case 'startup_career':
        return await CareerGenerator.generate(input, _supabase);

      case 'exam':
      case 'lucky_exam':
        return await ExamGenerator.generate(input, _supabase,
            isPremium: isPremium);

      case 'health':
        return await HealthGenerator.generate(
          conditions: HealthFortuneConditions.fromInputData(input),
          supabase: _supabase,
          isPremium: isPremium,
        );

      case 'exercise':
        return await ExerciseGenerator.generate(
          conditions: ExerciseFortuneConditions.fromInputData(input),
          supabase: _supabase,
          isPremium: isPremium,
        );

      case 'wish':
        return await WishGenerator.generate(input, _supabase);

      case 'lucky_items':
        return await LuckyItemsGenerator.generate(input, _supabase);

      // ==================== 직접 Edge Function 호출 ====================
      case 'career_coaching':
        return await _generateCareerCoaching(input, isPremium);

      case 'mbti':
        return await _generateMBTI(input, isPremium);

      case 'personality_dna':
        return await _generatePersonalityDNA(input);

      case 'face_reading':
        return await _generateFaceReading(input);

      case 'dream':
        return await _generateDream(input, isPremium);

      case 'biorhythm':
        return await _generateBiorhythm(input);

      case 'celebrity':
      case 'fortune_celebrity':
        return await _generateCelebrity(input, isPremium);

      case 'match_insight':
        return await _generateMatchInsight(input);

      case 'baby_nickname':
      case 'babynickname':
        return await _generateBabyNickname(input);

      case 'naming':
        return await _generateNaming(input, isPremium);

      case 'new_year':
        return await _generateNewYear(input, isPremium);

      // ==================== 가족 운세 (5가지) ====================
      case 'family_health':
      case 'family_wealth':
      case 'family_children':
      case 'family_relationship':
      case 'family_change':
        return await _generateFamily(fortuneType, input, isPremium);

      // ==================== 기본 (레거시) ====================
      default:
        return await _generateDefault(fortuneType, input);
    }
  }

  /// 로컬 기반 운세 생성
  Future<FortuneResult> _generateFromLocal(
    String fortuneType,
    Map<String, dynamic> input,
  ) async {
    switch (fortuneType) {
      case 'tarot':
        return await TarotGenerator.generate(input);

      case 'fortune_cookie':
        return await FortuneCookieGenerator.generate(input);

      default:
        throw UnimplementedError('로컬 생성 미구현: $fortuneType');
    }
  }

  // ==================== Edge Function 직접 호출 메서드 ====================

  Future<FortuneResult> _generateCareerCoaching(
    Map<String, dynamic> input,
    bool isPremium,
  ) async {
    final payload = {
      'currentRole': input['currentRole'],
      'experienceLevel': input['experienceLevel'],
      'industry': input['industry'],
      'primaryConcern': input['primaryConcern'],
      'shortTermGoal': input['shortTermGoal'],
      'skillsToImprove': input['skillsToImprove'],
      'coreValue': input['coreValue'],
      'isPremium': isPremium,
    };

    final response = await _supabase.functions.invoke(
      'fortune-career',
      body: payload,
    );

    if (response.data == null) {
      throw Exception('Career Coaching API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data.containsKey('fortune')) {
      final fortune = data['fortune'] as Map<String, dynamic>;
      return FortuneResult(
        type: 'career_coaching',
        title: '커리어 코칭',
        summary: {},
        data: fortune,
        score:
            (fortune['health_score']?['overall_score'] as num?)?.toInt() ?? 70,
        createdAt: DateTime.now(),
      );
    }
    throw Exception('Career Coaching API 응답 형식 오류');
  }

  Future<FortuneResult> _generateMBTI(
    Map<String, dynamic> input,
    bool isPremium,
  ) async {
    final user = _supabase.auth.currentUser;
    final userProfile = user != null
        ? await _supabase
            .from('user_profiles')
            .select('name')
            .eq('id', user.id)
            .maybeSingle()
        : null;

    final payload = {
      'mbti': input['mbti_type'] ?? input['mbti'],
      'name': userProfile?['name'] as String? ??
          user?.userMetadata?['name'] as String? ??
          input['name'] ??
          'Guest',
      'birthDate': input['birth_date'] ?? input['birthDate'],
      if (input['categories'] != null) 'categories': input['categories'],
      'userId': user?.id ?? input['userId'] ?? 'anonymous',
      'isPremium': isPremium,
    };

    final response = await _supabase.functions.invoke(
      'fortune-mbti',
      body: payload,
    );

    if (response.data == null) {
      throw Exception('MBTI API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data.containsKey('data')) {
      final fortune = data['data'] as Map<String, dynamic>;
      return FortuneResult(
        type: 'mbti',
        title: 'MBTI 운세 - ${payload['mbti']}',
        summary: {},
        data: fortune,
        score: (fortune['energyLevel'] as num?)?.toInt() ?? 75,
        createdAt: DateTime.now(),
      );
    }
    throw Exception('MBTI API 응답 형식 오류');
  }

  Future<FortuneResult> _generatePersonalityDNA(
    Map<String, dynamic> input,
  ) async {
    final user = _supabase.auth.currentUser;
    final userProfile = user != null
        ? await _supabase
            .from('user_profiles')
            .select('name')
            .eq('id', user.id)
            .maybeSingle()
        : null;

    final payload = {
      ...input,
      'userId': user?.id ?? 'anonymous',
      'name': userProfile?['name'] as String? ??
          user?.userMetadata?['name'] as String? ??
          'Guest',
    };

    final response = await _supabase.functions.invoke(
      'personality-dna',
      body: payload,
    );

    if (response.data == null) {
      throw Exception('Personality DNA API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    return FortuneResult(
      type: 'personality-dna',
      title: data['title'] as String? ?? '성격 DNA',
      summary: {},
      data: data,
      score: (data['socialRanking'] as num?)?.toInt(),
      createdAt: DateTime.now(),
    );
  }

  Future<FortuneResult> _generateFaceReading(
    Map<String, dynamic> input,
  ) async {
    final response = await _supabase.functions.invoke(
      'fortune-face-reading',
      body: input,
    );

    if (response.data == null) {
      throw Exception('Face Reading API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    return FortuneResult(
      type: 'face-reading',
      title: data['title'] as String? ?? 'Face AI',
      summary: data['summary'] as Map<String, dynamic>? ?? {'message': '분석 완료'},
      data: data,
      createdAt: DateTime.now(),
    );
  }

  Future<FortuneResult> _generateDream(
    Map<String, dynamic> input,
    bool isPremium,
  ) async {
    final response = await _supabase.functions.invoke(
      'fortune-dream',
      body: input,
    );

    if (response.data == null) {
      throw Exception('Dream API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Dream Fortune API 실패');
    }

    final fortune = data['data'] as Map<String, dynamic>;
    return FortuneResult(
      type: 'dream',
      title: fortune['interpretation'] as String? ?? '꿈 해몽',
      summary: {'message': fortune['interpretation'] as String? ?? '해몽 완료'},
      data: fortune,
      createdAt: DateTime.now(),
    );
  }

  Future<FortuneResult> _generateBiorhythm(
    Map<String, dynamic> input,
  ) async {
    final response = await _supabase.functions.invoke(
      'fortune-biorhythm',
      body: input,
    );

    if (response.data == null) {
      throw Exception('Biorhythm API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Biorhythm API 실패');
    }

    final fortune = data['data'] as Map<String, dynamic>;
    return FortuneResult(
      type: 'biorhythm',
      title: fortune['title'] as String? ?? '바이오리듬',
      summary: fortune['summary'] as Map<String, dynamic>? ?? {},
      data: fortune,
      createdAt: DateTime.now(),
    );
  }

  Future<FortuneResult> _generateMatchInsight(
    Map<String, dynamic> input,
  ) async {
    final user = _supabase.auth.currentUser;
    final match = _asStringKeyedMap(input['match']);

    final sport = _readRequiredString(
      [input['sport'], match['sport']],
      fieldName: 'sport',
    );
    final homeTeam = _readRequiredString(
      [input['homeTeam'], match['homeTeam']],
      fieldName: 'homeTeam',
    );
    final awayTeam = _readRequiredString(
      [input['awayTeam'], match['awayTeam']],
      fieldName: 'awayTeam',
    );
    final gameDate = _readRequiredString(
      [input['gameDate'], match['gameTime'], match['gameDate']],
      fieldName: 'gameDate',
    );
    final league = _readOptionalString(input['league']) ??
        _readOptionalString(match['league']);
    final favoriteTeam = _resolveMatchInsightFavoriteTeam(
      rawFavoriteTeam: input['favoriteTeam'],
      homeTeam: homeTeam,
      awayTeam: awayTeam,
    );
    final birthDate = _readOptionalString(input['birthDate']);

    final payload = <String, dynamic>{
      'userId': user?.id ?? input['userId'] ?? 'anonymous',
      'sport': sport,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'gameDate': gameDate,
      if (league != null) 'league': league,
      if (favoriteTeam != null) 'favoriteTeam': favoriteTeam,
      if (birthDate != null) 'birthDate': birthDate,
    };

    final response = await _supabase.functions
        .invoke('fortune-match-insight', body: payload)
        .timeout(
          const Duration(seconds: 90),
          onTimeout: () => throw Exception('Match Insight API 타임아웃 (90초)'),
        );

    if (response.status != 200) {
      throw Exception('Match Insight API 호출 실패: ${response.status}');
    }

    final responseData = response.data as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception('Match Insight API 응답 데이터가 없습니다');
    }

    final summaryText = _readOptionalString(responseData['summary']);
    final timestampRaw = _readOptionalString(responseData['timestamp']) ??
        _readOptionalString(responseData['created_at']);

    return FortuneResult(
      id: responseData['id'] as String?,
      type: 'match-insight',
      title: _readOptionalString(responseData['title']) ??
          '$homeTeam vs $awayTeam',
      summary: summaryText == null ? {} : {'message': summaryText},
      data: responseData,
      score: (responseData['score'] as num?)?.toInt(),
      createdAt: timestampRaw != null ? DateTime.tryParse(timestampRaw) : null,
      percentile: (responseData['percentile'] as num?)?.toInt(),
      isPercentileValid: responseData['percentile'] != null,
    );
  }

  Future<FortuneResult> _generateCelebrity(
    Map<String, dynamic> input,
    bool isPremium,
  ) async {
    final user = _supabase.auth.currentUser;
    final payload = {
      'userId': user?.id ?? input['userId'] ?? 'anonymous',
      'name': input['name'] ?? 'Guest',
      'birthDate': input['birthDate'],
      'celebrity_id': input['celebrity_id'],
      'celebrity_name': input['celebrity_name'],
      'celebrity_birth_date': input['celebrity_birth_date'],
      'connection_type': input['connection_type'] ?? 'ideal_match',
      'question_type': input['question_type'] ?? 'overall',
      'category': input['category'] ?? 'entertainment',
      'isPremium': isPremium,
    };

    final response = await _supabase.functions
        .invoke('fortune-celebrity', body: payload)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () => throw Exception('Celebrity API 타임아웃 (60초)'),
        );

    if (response.data == null) {
      throw Exception('Celebrity API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data.containsKey('data')) {
      final fortune = data['data'] as Map<String, dynamic>;
      return FortuneResult(
        type: 'celebrity',
        title: '${payload['celebrity_name']} 궁합',
        summary: {'message': fortune['main_message'] as String? ?? '궁합 분석 완료'},
        data: fortune,
        score: (fortune['overall_score'] as num?)?.toInt() ?? 75,
        createdAt: DateTime.now(),
      );
    }
    throw Exception('Celebrity API 응답 형식 오류');
  }

  Future<FortuneResult> _generateBabyNickname(
    Map<String, dynamic> input,
  ) async {
    final user = _supabase.auth.currentUser;
    final payload = {
      'userId': user?.id ?? 'anonymous',
      'nickname': input['nickname'],
      if (input['babyDream'] != null) 'babyDream': input['babyDream'],
    };

    final response = await _supabase.functions.invoke(
      'fortune-baby-nickname',
      body: payload,
    );

    if (response.data == null) {
      throw Exception('Baby Nickname API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data.containsKey('data')) {
      final fortune = data['data'] as Map<String, dynamic>;
      return FortuneResult(
        type: 'baby-nickname',
        title: '태명 이야기 - ${payload['nickname']}',
        summary: {
          'message': fortune['babyMessage'] as String? ?? '아기가 메시지를 전해요'
        },
        data: fortune,
        createdAt: DateTime.now(),
      );
    }
    throw Exception('Baby Nickname API 응답 형식 오류');
  }

  Future<FortuneResult> _generateNaming(
    Map<String, dynamic> input,
    bool isPremium,
  ) async {
    final user = _supabase.auth.currentUser;
    final payload = {
      'userId': user?.id ?? 'anonymous',
      'motherBirthDate': input['motherBirthDate'],
      'motherBirthTime': input['motherBirthTime'],
      'expectedBirthDate': input['expectedBirthDate'],
      'babyGender': input['babyGender'] ?? 'unknown',
      'familyName': input['familyName'] ?? '김',
      'nameStyle': input['nameStyle'] ?? 'modern',
      'isPremium': isPremium,
    };

    final response = await _supabase.functions.invoke(
      'fortune-naming',
      body: payload,
    );

    if (response.data == null) {
      throw Exception('Naming API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data.containsKey('data')) {
      final fortune = data['data'] as Map<String, dynamic>;
      return FortuneResult(
        type: 'naming',
        title: '작명 추천 - ${payload['familyName']}씨',
        summary: {},
        data: fortune,
        createdAt: DateTime.now(),
      );
    }
    throw Exception('Naming API 응답 형식 오류');
  }

  Future<FortuneResult> _generateNewYear(
    Map<String, dynamic> input,
    bool isPremium,
  ) async {
    final user = _supabase.auth.currentUser;
    final userProfile = user != null
        ? await _supabase
            .from('user_profiles')
            .select('name, birth_date, birth_time, gender, is_lunar')
            .eq('id', user.id)
            .maybeSingle()
        : null;

    final payload = {
      'userId': user?.id ?? 'anonymous',
      'name': userProfile?['name'] ?? input['name'] ?? '사용자',
      'birthDate': userProfile?['birth_date'] ?? input['birthDate'],
      'birthTime': userProfile?['birth_time'] ?? input['birthTime'],
      'gender': userProfile?['gender'] ?? input['gender'],
      'isLunar': userProfile?['is_lunar'] ?? input['isLunar'] ?? false,
      'zodiacSign': input['zodiacSign'],
      'zodiacAnimal': input['zodiacAnimal'],
      'goal': input['goal'],
      'goalLabel': input['goalLabel'],
      'isPremium': isPremium,
    };

    final response = await _supabase.functions.invoke(
      'fortune-new-year',
      body: payload,
    );

    if (response.data == null) {
      throw Exception('New Year Fortune API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    final fortune = data['fortune'] as Map<String, dynamic>? ?? data;

    return FortuneResult(
      type: 'new-year',
      title: fortune['greeting'] as String? ?? '새해 운세',
      summary: {'message': fortune['summary'] as String? ?? ''},
      data: fortune,
      score: (fortune['overallScore'] ?? fortune['score'] ?? 75) as int,
      createdAt: DateTime.now(),
    );
  }

  Future<FortuneResult> _generateFamily(
    String fortuneType,
    Map<String, dynamic> input,
    bool isPremium,
  ) async {
    // concern 추출 (family_health → health)
    final concern = fortuneType.split('_').last;
    final endpoint = 'fortune-family-$concern';

    final user = _supabase.auth.currentUser;
    final userProfile = user != null
        ? await _supabase
            .from('user_profiles')
            .select('name, birth_date, birth_time, gender')
            .eq('id', user.id)
            .maybeSingle()
        : null;

    final familyMemberData = input['familyMember'] as Map<String, dynamic>?;

    final payload = {
      ...input,
      'userId': user?.id ?? 'anonymous',
      'name': userProfile?['name'] ?? 'Guest',
      'birthDate': userProfile?['birth_date'],
      'birthTime': userProfile?['birth_time'],
      'gender': userProfile?['gender'],
      'isPremium': isPremium,
      if (familyMemberData != null) 'familyMember': familyMemberData,
    };

    final response = await _supabase.functions.invoke(
      endpoint,
      body: payload,
    );

    if (response.data == null) {
      throw Exception('Family Fortune API 응답 없음');
    }

    final data = response.data as Map<String, dynamic>;
    final fortune = data['fortune'] ?? data;

    return FortuneResult(
      type: fortuneType.replaceAll('_', '-'),
      title: '가족 ${input['concern_label'] ?? concern}',
      summary: {},
      data: fortune,
      score: (fortune['overallScore'] ?? fortune['score'] ?? 70) as int,
      createdAt: DateTime.now(),
    );
  }

  Future<FortuneResult> _generateDefault(
    String fortuneType,
    Map<String, dynamic> input,
  ) async {
    final response = await _supabase.functions.invoke(
      'generate-fortune',
      body: {
        'fortune_type': fortuneType,
        'input_conditions': input,
      },
    );

    if (response.data == null) {
      throw Exception('Default API 응답 없음');
    }

    Logger.info('[GeneratorFactory] ✅ Default API: $fortuneType');
    return FortuneResult.fromJson(response.data);
  }

  Map<String, dynamic> _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    return const <String, dynamic>{};
  }

  String? _readOptionalString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _readRequiredString(
    List<dynamic> candidates, {
    required String fieldName,
  }) {
    for (final candidate in candidates) {
      final text = _readOptionalString(candidate);
      if (text != null) {
        return text;
      }
    }
    throw Exception('Match Insight API 입력 누락: $fieldName');
  }

  String? _resolveMatchInsightFavoriteTeam({
    required dynamic rawFavoriteTeam,
    required String homeTeam,
    required String awayTeam,
  }) {
    final favoriteTeam = _readOptionalString(rawFavoriteTeam);
    if (favoriteTeam == null) {
      return null;
    }

    switch (favoriteTeam.toLowerCase()) {
      case 'home':
        return homeTeam;
      case 'away':
        return awayTeam;
      default:
        return favoriteTeam;
    }
  }
}

/// 운세 데이터 소스
enum GeneratorDataSource {
  /// API 방식 (Edge Function 호출)
  api,

  /// 로컬 방식 (계산 또는 로컬 데이터)
  local,
}
