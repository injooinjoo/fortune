import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../utils/cohort_helpers.dart';
import '../models/fortune_result.dart';

/// Cohort 기반 운세 서비스
///
/// API 비용 90% 절감을 위한 사전 생성 결과 활용:
/// 1. 사용자 입력 → Cohort 추출 (나잇대, 띠, 오행 등)
/// 2. cohort_fortune_pool에서 랜덤 결과 선택
/// 3. 플레이스홀더를 개인 정보로 치환 (후처리)
/// 4. Pool 부족 시에만 실시간 LLM 호출
class CohortFortuneService {
  final SupabaseClient _supabase;

  CohortFortuneService({required SupabaseClient supabase})
      : _supabase = supabase;

  /// Cohort Pool에서 결과 조회 시도
  ///
  /// 성공 시: 개인화된 FortuneResult 반환
  /// 실패 시: null 반환 (호출자가 LLM API 호출해야 함)
  Future<FortuneResult?> getFromCohortPool({
    required String fortuneType,
    required Map<String, dynamic> input,
  }) async {
    try {
      // 1. Cohort 추출
      final cohortData = CohortHelpers.extractCohort(
        fortuneType: fortuneType,
        input: input,
      );

      if (cohortData.isEmpty) {
        Logger.info('[CohortFortune] No cohort data for $fortuneType');
        return null;
      }

      final cohortHash = CohortHelpers.generateCohortHash(cohortData);

      Logger.info(
          '[CohortFortune] Looking for $fortuneType with hash: $cohortHash');
      Logger.info('[CohortFortune] Cohort data: $cohortData');

      // 2. DB에서 랜덤 결과 조회
      final response = await _supabase.rpc(
        'get_random_cohort_result',
        params: {
          'p_fortune_type': fortuneType,
          'p_cohort_hash': cohortHash,
        },
      );

      if (response == null) {
        Logger.info('[CohortFortune] No result in pool for $cohortHash');
        return null;
      }

      final template = response as Map<String, dynamic>;

      // 3. 개인화 후처리
      final personalized = _personalize(template, input);

      Logger.info('[CohortFortune] Successfully retrieved from pool');

      return FortuneResult.fromJson(personalized);
    } catch (e, stack) {
      Logger.error('[CohortFortune] Error getting from pool: $e', e, stack);
      return null;
    }
  }

  /// Pool 크기 확인
  Future<int> getPoolSize({
    required String fortuneType,
    required Map<String, dynamic> input,
  }) async {
    try {
      final cohortData = CohortHelpers.extractCohort(
        fortuneType: fortuneType,
        input: input,
      );

      if (cohortData.isEmpty) return 0;

      final cohortHash = CohortHelpers.generateCohortHash(cohortData);

      final response = await _supabase.rpc(
        'get_cohort_pool_size',
        params: {
          'p_fortune_type': fortuneType,
          'p_cohort_hash': cohortHash,
        },
      );

      return response as int? ?? 0;
    } catch (e) {
      Logger.error('[CohortFortune] Error getting pool size: $e');
      return 0;
    }
  }

  /// 새 결과를 Pool에 저장
  Future<bool> saveToPool({
    required String fortuneType,
    required Map<String, dynamic> input,
    required Map<String, dynamic> result,
  }) async {
    try {
      final cohortData = CohortHelpers.extractCohort(
        fortuneType: fortuneType,
        input: input,
      );

      if (cohortData.isEmpty) return false;

      final cohortHash = CohortHelpers.generateCohortHash(cohortData);

      // 결과를 템플릿으로 변환 (플레이스홀더 삽입)
      final template = _createTemplate(result, input);

      await _supabase.from('cohort_fortune_pool').insert({
        'fortune_type': fortuneType,
        'cohort_hash': cohortHash,
        'cohort_data': cohortData,
        'result_template': template,
        'quality_score': 1.0,
      });

      Logger.info('[CohortFortune] Saved new result to pool');
      return true;
    } catch (e) {
      Logger.error('[CohortFortune] Error saving to pool: $e');
      return false;
    }
  }

  /// 결과 템플릿에 개인 정보 삽입
  Map<String, dynamic> _personalize(
    Map<String, dynamic> template,
    Map<String, dynamic> input,
  ) {
    // JSON을 문자열로 변환
    var jsonStr = jsonEncode(template);

    // 플레이스홀더 치환
    jsonStr = jsonStr
        .replaceAll('{{userName}}', input['userName'] as String? ?? '회원님')
        .replaceAll('{{age}}', '${input['age'] ?? 20}')
        .replaceAll('{{birthYear}}', '${_extractBirthYear(input)}')
        .replaceAll(
            '{{person1_name}}', input['person1_name'] as String? ?? '본인')
        .replaceAll(
            '{{person2_name}}', input['person2_name'] as String? ?? '상대방')
        .replaceAll(
            '{{person1_birth}}', input['person1_birth_date'] as String? ?? '')
        .replaceAll(
            '{{person2_birth}}', input['person2_birth_date'] as String? ?? '')
        .replaceAll('{{skills}}', _formatList(input['skills']))
        .replaceAll('{{primaryConcern}}',
            input['primaryConcern'] as String? ?? input['concern'] as String? ?? '')
        .replaceAll('{{concernedParts}}', _formatList(input['concernedParts']))
        .replaceAll('{{healthScore}}', '${input['healthScore'] ?? 70}')
        .replaceAll('{{question}}', input['question'] as String? ?? '')
        .replaceAll('{{sajuPillars}}', _formatSajuPillars(input['sajuData']))
        .replaceAll(
            '{{dreamContent}}', input['dream_content'] as String? ?? '')
        .replaceAll('{{specificSymbols}}', _extractDreamSymbols(input))
        .replaceAll('{{faceFeatures}}', _formatFaceFeatures(input))
        .replaceAll('{{datingStyles}}', _formatList(input['datingStyles']))
        .replaceAll('{{charmPoints}}', _formatList(input['charmPoints']))
        .replaceAll('{{concerns}}', _formatList(input['concerns']))
        .replaceAll('{{interests}}', _formatList(input['interests']))
        .replaceAll(
            '{{investmentGoal}}', input['investmentGoal'] as String? ?? '')
        .replaceAll('{{exName}}', input['exName'] as String? ?? '그분')
        .replaceAll('{{preferences}}', _formatList(input['preferences']));

    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  /// 결과에서 개인 정보를 플레이스홀더로 변환
  Map<String, dynamic> _createTemplate(
    Map<String, dynamic> result,
    Map<String, dynamic> input,
  ) {
    var jsonStr = jsonEncode(result);

    // 개인 정보를 플레이스홀더로 치환
    final userName = input['userName'] as String?;
    if (userName != null && userName.isNotEmpty) {
      jsonStr = jsonStr.replaceAll(userName, '{{userName}}');
    }

    final person1Name = input['person1_name'] as String?;
    if (person1Name != null && person1Name.isNotEmpty) {
      jsonStr = jsonStr.replaceAll(person1Name, '{{person1_name}}');
    }

    final person2Name = input['person2_name'] as String?;
    if (person2Name != null && person2Name.isNotEmpty) {
      jsonStr = jsonStr.replaceAll(person2Name, '{{person2_name}}');
    }

    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  int _extractBirthYear(Map<String, dynamic> input) {
    final birthDate = input['birthDate'];
    if (birthDate is DateTime) return birthDate.year;
    if (birthDate is String) {
      final parsed = DateTime.tryParse(birthDate);
      return parsed?.year ?? 2000;
    }
    return 2000;
  }

  String _formatList(dynamic list) {
    if (list == null) return '';
    if (list is List) {
      return list.map((e) => e.toString()).join(', ');
    }
    return list.toString();
  }

  String _formatSajuPillars(dynamic sajuData) {
    if (sajuData == null || sajuData is! Map) return '';

    final pillars = <String>[];
    final pillarNames = ['yearPillar', 'monthPillar', 'dayPillar', 'timePillar'];

    for (final name in pillarNames) {
      final pillar = sajuData[name] as Map?;
      if (pillar != null) {
        final gan = pillar['gan'] ?? '';
        final ji = pillar['ji'] ?? '';
        pillars.add('$gan$ji');
      }
    }

    return pillars.join(' ');
  }

  String _extractDreamSymbols(Map<String, dynamic> input) {
    final dreamContent = input['dream_content'] as String? ?? '';
    final symbols = <String>[];

    // 주요 상징 키워드 추출
    final symbolPatterns = {
      '물': RegExp(r'바다|강|호수|비|물'),
      '하늘': RegExp(r'하늘|구름|날다|비행'),
      '동물': RegExp(r'개|고양이|뱀|호랑이|새'),
      '사람': RegExp(r'가족|친구|부모|연인'),
      '돈': RegExp(r'돈|금|보물|복권'),
    };

    for (final entry in symbolPatterns.entries) {
      if (entry.value.hasMatch(dreamContent)) {
        symbols.add(entry.key);
      }
    }

    return symbols.isEmpty ? '일상' : symbols.join(', ');
  }

  String _formatFaceFeatures(Map<String, dynamic> input) {
    final features = input['faceFeatures'] as Map?;
    if (features == null) return '';

    return features.entries
        .map((e) => '${e.key}: ${e.value}')
        .take(3)
        .join(', ');
  }

  /// Cohort 설정 조회
  Future<Map<String, dynamic>?> getCohortSettings(String fortuneType) async {
    try {
      final response = await _supabase
          .from('cohort_pool_settings')
          .select()
          .eq('fortune_type', fortuneType)
          .eq('is_active', true)
          .maybeSingle();

      return response;
    } catch (e) {
      Logger.error('[CohortFortune] Error getting settings: $e');
      return null;
    }
  }

  /// 부족한 Cohort 목록 조회
  Future<List<Map<String, dynamic>>> getUnderfilledCohorts({
    required String fortuneType,
    int threshold = 25,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_underfilled_cohorts',
        params: {
          'p_fortune_type': fortuneType,
          'p_threshold': threshold,
        },
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      Logger.error('[CohortFortune] Error getting underfilled cohorts: $e');
      return [];
    }
  }

  /// Pool 통계 조회
  Future<List<Map<String, dynamic>>> getPoolStats({
    String? fortuneType,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_cohort_pool_stats',
        params: {'p_fortune_type': fortuneType},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      Logger.error('[CohortFortune] Error getting pool stats: $e');
      return [];
    }
  }
}
