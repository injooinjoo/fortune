import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity_master_list.dart';
import '../data/models/celebrity.dart';
import 'celebrity_list_service.dart';
import 'celebrity_crawling_service.dart';

/// 나무위키 크롤링을 오케스트레이션하는 서비스
/// celebrity_master_list에서 우선순위에 따라 연예인을 선택하고
/// 크롤링 후 상태를 업데이트합니다.
class CelebrityCrawlingOrchestrator {
  final SupabaseClient _supabase = Supabase.instance.client;
  final CelebrityListService _listService = CelebrityListService();
  final CelebrityCrawlingService _crawlingService = CelebrityCrawlingService();

  /// 다음 크롤링 대상 배치를 가져옵니다
  Future<List<CelebrityMasterListItem>> getNextBatchToCrawl({
    int batchSize = 10,
    String? category,
  }) async {
    try {
      return await _listService.getNextCelebritiesToCrawl(
        limit: batchSize,
        category: category,
      );
    } catch (e) {
      throw Exception('다음 크롤링 대상 조회 실패: $e');
    }
  }

  /// 단일 연예인 크롤링 및 저장
  Future<CrawlingOperationResult> crawlAndSaveSingle(
    CelebrityMasterListItem masterItem,
  ) async {
    try {
      print('🔄 크롤링 시작: ${masterItem.name} (${masterItem.category.displayName})');

      // 1. 나무위키에서 정보 크롤링 (masterItemId 포함)
      final crawlingResult = await _crawlingService.crawlCelebrityInfo(
        name: masterItem.name,
        forceUpdate: true,
        masterItemId: masterItem.id,
      );

      if (!crawlingResult.success) {
        return CrawlingOperationResult(
          masterItem: masterItem,
          success: false,
          error: crawlingResult.message,
          celebrity: null,
        );
      }

      // 2. 크롤링 성공 시 마스터 리스트 상태 업데이트
      await _listService.markCelebrityAsCrawled(masterItem.id);

      print('✅ 크롤링 완료: ${masterItem.name}');

      return CrawlingOperationResult(
        masterItem: masterItem,
        success: true,
        error: null,
        celebrity: crawlingResult.celebrity,
      );

    } catch (e) {
      print('❌ 크롤링 오류: ${masterItem.name} - $e');
      
      return CrawlingOperationResult(
        masterItem: masterItem,
        success: false,
        error: e.toString(),
        celebrity: null,
      );
    }
  }

  /// 배치 크롤링 실행
  Future<BatchCrawlingOperationResult> crawlBatch({
    int batchSize = 10,
    String? category,
    Duration delayBetweenCrawls = const Duration(seconds: 1),
    Function(CrawlingOperationResult result)? onItemComplete,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      // 1. 다음 크롤링 대상들 가져오기
      final targetItems = await getNextBatchToCrawl(
        batchSize: batchSize,
        category: category,
      );

      if (targetItems.isEmpty) {
        return BatchCrawlingOperationResult(
          results: [],
          totalCount: 0,
          successCount: 0,
          failureCount: 0,
          skippedCount: 0,
        );
      }

      print('📋 배치 크롤링 시작: ${targetItems.length}명');

      final results = <CrawlingOperationResult>[];
      int successCount = 0;
      int failureCount = 0;

      // 2. 각 연예인에 대해 순차 크롤링
      for (int i = 0; i < targetItems.length; i++) {
        final item = targetItems[i];
        
        // 진행 상황 알림
        onProgress?.call(i + 1, targetItems.length);

        // 크롤링 실행
        final result = await crawlAndSaveSingle(item);
        results.add(result);

        if (result.success) {
          successCount++;
        } else {
          failureCount++;
        }

        // 완료 콜백 호출
        onItemComplete?.call(result);

        // 서버 부하 방지를 위한 딜레이
        if (i < targetItems.length - 1) {
          await Future.delayed(delayBetweenCrawls);
        }
      }

      print('📊 배치 크롤링 완료 - 성공: $successCount, 실패: $failureCount');

      return BatchCrawlingOperationResult(
        results: results,
        totalCount: targetItems.length,
        successCount: successCount,
        failureCount: failureCount,
        skippedCount: 0,
      );

    } catch (e) {
      throw Exception('배치 크롤링 실패: $e');
    }
  }

  /// 전체 크롤링 상태 확인
  Future<OverallCrawlingStatus> getOverallStatus() async {
    try {
      // 마스터 리스트 통계
      final masterStats = await _listService.getCrawlingStats();
      
      // 카테고리별 통계
      final categoryStats = await _listService.getCategoryStats();

      // 실제 저장된 celebrities 통계
      final celebritiesStats = await _crawlingService.getCrawlingStats();

      return OverallCrawlingStatus(
        totalCelebrities: masterStats.totalCelebrities,
        crawledCelebrities: masterStats.crawledCelebrities,
        crawlingPercentage: masterStats.crawlingPercentage,
        lastCrawledAt: masterStats.lastCrawledAt,
        categoryStats: categoryStats,
        actualStoredCount: celebritiesStats.crawledCelebrities,
      );

    } catch (e) {
      throw Exception('전체 크롤링 상태 조회 실패: $e');
    }
  }

  /// 카테고리별 크롤링 실행
  Future<BatchCrawlingOperationResult> crawlByCategory(
    String categoryCode, {
    int batchSize = 10,
    Duration delayBetweenCrawls = const Duration(seconds: 1),
    Function(CrawlingOperationResult result)? onItemComplete,
    Function(int current, int total)? onProgress,
  }) async {
    return await crawlBatch(
      batchSize: batchSize,
      category: categoryCode,
      delayBetweenCrawls: delayBetweenCrawls,
      onItemComplete: onItemComplete,
      onProgress: onProgress,
    );
  }

  /// 실패한 크롤링 재시도
  Future<BatchCrawlingOperationResult> retryFailedCrawls({
    int batchSize = 5,
    Duration delayBetweenCrawls = const Duration(seconds: 2),
  }) async {
    try {
      // is_crawled = false인 아이템들 중에서 우선순위가 높은 것들을 재시도 대상으로 선택
      final failedItems = await _listService.getNextCelebritiesToCrawl(
        limit: batchSize,
      );

      if (failedItems.isEmpty) {
        return BatchCrawlingOperationResult(
          results: [],
          totalCount: 0,
          successCount: 0,
          failureCount: 0,
          skippedCount: 0,
        );
      }

      print('🔄 실패한 크롤링 재시도: ${failedItems.length}명');

      return await crawlBatch(
        batchSize: batchSize,
        delayBetweenCrawls: delayBetweenCrawls,
        onItemComplete: (result) {
          if (result.success) {
            print('✅ 재시도 성공: ${result.masterItem.name}');
          } else {
            print('❌ 재시도 실패: ${result.masterItem.name} - ${result.error}');
          }
        },
      );

    } catch (e) {
      throw Exception('실패한 크롤링 재시도 실패: $e');
    }
  }

  /// 특정 연예인 강제 재크롤링
  Future<CrawlingOperationResult> forceCrawl(String celebrityName) async {
    try {
      // 마스터 리스트에서 해당 연예인 찾기
      final allCelebrities = await _supabase
          .from('celebrity_master_list')
          .select('*')
          .eq('name', celebrityName)
          .limit(1);

      if (allCelebrities.isEmpty) {
        throw Exception('해당 연예인을 마스터 리스트에서 찾을 수 없습니다: $celebrityName');
      }

      final masterItem = CelebrityMasterListItem.fromJson(allCelebrities.first);

      // 크롤링 실행 (기존 상태와 관계없이 강제 실행)
      return await crawlAndSaveSingle(masterItem);

    } catch (e) {
      throw Exception('강제 크롤링 실패: $e');
    }
  }
}

/// 개별 크롤링 작업 결과
class CrawlingOperationResult {
  final CelebrityMasterListItem masterItem;
  final bool success;
  final String? error;
  final Celebrity? celebrity;

  CrawlingOperationResult({
    required this.masterItem,
    required this.success,
    this.error,
    this.celebrity,
  });
}

/// 배치 크롤링 작업 결과
class BatchCrawlingOperationResult {
  final List<CrawlingOperationResult> results;
  final int totalCount;
  final int successCount;
  final int failureCount;
  final int skippedCount;

  BatchCrawlingOperationResult({
    required this.results,
    required this.totalCount,
    required this.successCount,
    required this.failureCount,
    required this.skippedCount,
  });

  double get successRate => totalCount > 0 ? (successCount / totalCount) * 100 : 0;

  List<CrawlingOperationResult> get successfulResults =>
      results.where((r) => r.success).toList();

  List<CrawlingOperationResult> get failedResults =>
      results.where((r) => !r.success).toList();
}

/// 전체 크롤링 상태
class OverallCrawlingStatus {
  final int totalCelebrities;
  final int crawledCelebrities;
  final double crawlingPercentage;
  final DateTime? lastCrawledAt;
  final Map<String, CategoryStats> categoryStats;
  final int actualStoredCount;

  OverallCrawlingStatus({
    required this.totalCelebrities,
    required this.crawledCelebrities,
    required this.crawlingPercentage,
    this.lastCrawledAt,
    required this.categoryStats,
    required this.actualStoredCount,
  });

  int get remainingCount => totalCelebrities - crawledCelebrities;
  
  bool get isComplete => crawledCelebrities >= totalCelebrities;

  /// 데이터 일관성 확인 (마스터 리스트 vs 실제 저장된 데이터)
  bool get isDataConsistent => crawledCelebrities == actualStoredCount;
}