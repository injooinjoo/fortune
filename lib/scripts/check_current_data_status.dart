import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 현재 데이터베이스 상태를 체크하는 스크립트
/// celebrity_master_list와 celebrities 테이블의 현재 상태를 확인합니다
class DataStatusChecker {
  static Future<void> main() async {
    debugPrint('📊 데이터베이스 현재 상태 체크를 시작합니다...\n');

    try {
      // Supabase 초기화
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        debugPrint('❌ SUPABASE_URL과 SUPABASE_ANON_KEY 환경변수를 설정해주세요.');
        debugPrint('사용법: flutter run lib/scripts/check_current_data_status.dart --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...');
        return;
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      final supabase = Supabase.instance.client;
      debugPrint('✅ Supabase 연결 완료\n');

      // 1. celebrity_master_list 테이블 상태 확인
      await _checkMasterListStatus(supabase);
      
      // 2. celebrities 테이블 상태 확인  
      await _checkCelebritiesStatus(supabase);
      
      // 3. 샘플 데이터 확인
      await _checkSampleData(supabase);

    } catch (e, stackTrace) {
      debugPrint('❌ 오류 발생: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// celebrity_master_list 테이블 상태 확인
  static Future<void> _checkMasterListStatus(SupabaseClient supabase) async {
    debugPrint('📋 celebrity_master_list 테이블 상태 확인...');

    try {
      // 전체 개수
      final totalResponse = await supabase
          .from('celebrity_master_list')
          .select('id', count: CountOption.exact);
      final totalCount = totalResponse.count ?? 0;

      // 크롤링 완료된 개수
      final crawledResponse = await supabase
          .from('celebrity_master_list')
          .select('id', count: CountOption.exact)
          .eq('is_crawled', true);
      final crawledCount = crawledResponse.count ?? 0;

      // 카테고리별 통계
      final categoryResponse = await supabase
          .from('celebrity_master_list')
          .select('category, is_crawled');

      final categoryStats = <String, Map<String, int>>{};
      for (final item in categoryResponse) {
        final category = item['category'] as String;
        final isCrawled = item['is_crawled'] as bool;
        
        if (!categoryStats.containsKey(category)) {
          categoryStats[category] = {'total': 0, 'crawled': 0};
        }
        
        categoryStats[category]!['total'] = categoryStats[category]!['total']! + 1;
        if (isCrawled) {
          categoryStats[category]!['crawled'] = categoryStats[category]!['crawled']! + 1;
        }
      }

      debugPrint('  전체 연예인: $totalCount명');
      debugPrint('  크롤링 완료: $crawledCount명');
      debugPrint('  크롤링 진행률: ${totalCount > 0 ? (crawledCount / totalCount * 100).toStringAsFixed(1) : 0}%\n');
      
      debugPrint('  📊 카테고리별 현황:');
      categoryStats.forEach((category, stats) {
        final total = stats['total']!;
        final crawled = stats['crawled']!;
        final percentage = total > 0 ? (crawled / total * 100).toStringAsFixed(1) : '0';
        debugPrint('    $category: $crawled/$total명 ($percentage%)');
      });

      if (totalCount == 0) {
        debugPrint('\n⚠️  celebrity_master_list에 데이터가 없습니다!');
        debugPrint('    먼저 연예인 목록을 업로드해야 합니다:');
        debugPrint('    flutter run lib/scripts/upload_celebrity_lists.dart');
      }

    } catch (e) {
      debugPrint('  ❌ celebrity_master_list 테이블 조회 실패: $e');
    }
    debugPrint('');
  }

  /// celebrities 테이블 상태 확인
  static Future<void> _checkCelebritiesStatus(SupabaseClient supabase) async {
    debugPrint('🎭 celebrities 테이블 상태 확인...');

    try {
      // 전체 개수
      final totalResponse = await supabase
          .from('celebrities')
          .select('id', count: CountOption.exact);
      final totalCount = totalResponse.count ?? 0;

      // 덤프에서 처리된 개수 확인
      final dumpProcessedResponse = await supabase
          .from('celebrities')
          .select('id', count: CountOption.exact)
          .not('additional_info->processed_from_dump', 'is', null);
      final dumpProcessedCount = dumpProcessedResponse.count ?? 0;

      // 카테고리별 통계
      final categoryResponse = await supabase
          .from('celebrities')
          .select('category');

      final categoryStats = <String, int>{};
      for (final item in categoryResponse) {
        final category = item['category'] as String;
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }

      debugPrint('  전체 연예인: $totalCount명');
      debugPrint('  덤프에서 처리된 연예인: $dumpProcessedCount명\n');
      
      if (categoryStats.isNotEmpty) {
        debugPrint('  📊 카테고리별 현황:');
        categoryStats.forEach((category, count) {
          debugPrint('    $category: $count명');
        });
      }

      if (totalCount == 0) {
        debugPrint('\n⚠️  celebrities 테이블에 데이터가 없습니다!');
        debugPrint('    덤프 처리를 통해 연예인 정보를 추가해야 합니다.');
      }

    } catch (e) {
      debugPrint('  ❌ celebrities 테이블 조회 실패: $e');
    }
    debugPrint('');
  }

  /// 샘플 데이터 확인
  static Future<void> _checkSampleData(SupabaseClient supabase) async {
    debugPrint('🔍 샘플 데이터 확인...');

    try {
      // celebrity_master_list에서 상위 5명
      final masterListSample = await supabase
          .from('celebrity_master_list')
          .select('name, category, popularity_rank, is_crawled')
          .order('popularity_rank')
          .limit(5);

      debugPrint('  📋 celebrity_master_list 상위 5명:');
      for (final item in masterListSample) {
        final name = item['name'];
        final category = item['category'];
        final rank = item['popularity_rank'];
        final isCrawled = item['is_crawled'] ? '✅' : '❌';
        debugPrint('    $rank위. $name ($category) $isCrawled');
      }

      // celebrities에서 샘플
      final celebritiesSample = await supabase
          .from('celebrities')
          .select('name, category, birth_date')
          .limit(5);

      if (celebritiesSample.isNotEmpty) {
        debugPrint('\n  🎭 celebrities 테이블 샘플:');
        for (final item in celebritiesSample) {
          final name = item['name'];
          final category = item['category'];
          final birthDate = item['birth_date'] ?? '정보없음';
          debugPrint('    $name ($category) - 생년월일: $birthDate');
        }
      }

    } catch (e) {
      debugPrint('  ❌ 샘플 데이터 조회 실패: $e');
    }
    debugPrint('');
  }
}

/// 스크립트 실행 진입점
void main() async {
  await DataStatusChecker.main();
}