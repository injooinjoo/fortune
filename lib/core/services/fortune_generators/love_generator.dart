import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../../features/fortune/domain/models/conditions/love_fortune_conditions.dart';
import '../../../features/fortune/data/datasources/love_fortune_data_source.dart';
import '../../utils/logger.dart';

/// 연애운 생성기
///
/// LoveFortuneDataSource를 사용하여 연애운을 생성
class LoveGenerator {
  /// 연애운 생성
  ///
  /// [conditions]: 연애운 조건
  /// [supabase]: Supabase 클라이언트
  /// [isPremium]: 프리미엄 사용자 여부
  static Future<FortuneResult> generate({
    required LoveFortuneConditions conditions,
    required SupabaseClient supabase,
    required bool isPremium,
  }) async {
    Logger.info('[LoveGenerator] 연애운 생성 시작');
    Logger.info('   - isPremium: $isPremium');

    // DataSource 생성
    final dataSource = LoveFortuneDataSource(supabase);

    // 사용자 ID 가져오기 (Supabase에서 직접)
    final userId = supabase.auth.currentUser?.id ?? 'anonymous';

    // API 호출
    final result = await dataSource.getLoveFortune(
      userId: userId,
      conditions: conditions,
      isPremium: isPremium,
    );

    Logger.info('[LoveGenerator] 연애운 생성 완료');
    Logger.info('   - fortuneId: ${result.id}');
    Logger.info('   - isBlurred: ${result.isBlurred}');

    return result;
  }
}
