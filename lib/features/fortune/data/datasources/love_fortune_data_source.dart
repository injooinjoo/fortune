import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/conditions/love_fortune_conditions.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/utils/logger.dart';

/// 연애운 데이터 소스
///
/// Supabase Edge Function (fortune-love)를 호출하여 연애운을 가져옴
class LoveFortuneDataSource {
  final SupabaseClient _supabase;

  LoveFortuneDataSource(this._supabase);

  /// 연애운 API 호출
  ///
  /// [userId]: 사용자 ID
  /// [conditions]: 연애운 조건 (4단계 입력 데이터)
  /// [isPremium]: 프리미엄 사용자 여부
  ///
  /// Returns: FortuneResult 객체
  Future<FortuneResult> getLoveFortune({
    required String userId,
    required LoveFortuneConditions conditions,
    required bool isPremium,
  }) async {
    try {
      Logger.info('[LoveFortuneDataSource] API 호출 시작');
      Logger.info('   - userId: $userId');
      Logger.info('   - isPremium: $isPremium');
      Logger.info('   - conditions: $conditions');

      // Supabase Edge Function 호출
      final response = await _supabase.functions.invoke(
        'fortune-love',
        body: {
          'userId': userId,
          ...conditions.toJson(),
          'isPremium': isPremium,
        },
      );

      // 응답 검증
      if (response.data == null) {
        throw Exception('API 응답 데이터가 없습니다');
      }

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] != true) {
        final error = responseData['error'] ?? 'Unknown error';
        throw Exception('API 오류: $error');
      }

      final data = responseData['data'] as Map<String, dynamic>;

      Logger.info('[LoveFortuneDataSource] API 응답 성공');
      Logger.info('   - loveScore: ${data['loveScore']}');

      // FortuneResult 객체 생성
      return FortuneResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'love',
        title: '연애운',
        createdAt: DateTime.now(),
        data: data,
        score: data['loveScore'] as int? ?? 70,
        summary: {
          'mainMessage': data['mainMessage'] ?? '',
          'loveScore': data['loveScore'] ?? 70,
          'relationshipStatus':
              data['personalInfo']?['relationshipStatus'] ?? '',
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[LoveFortuneDataSource] API 호출 실패', e, stackTrace);
      rethrow;
    }
  }
}
