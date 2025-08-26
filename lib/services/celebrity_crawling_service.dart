import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity.dart';

class CelebrityCrawlingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 나무위키에서 유명인 정보를 크롤링합니다
  Future<CrawlingResult> crawlCelebrityInfo({
    required String name,
    bool forceUpdate = false,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'crawl-celebrity-info',
        body: {
          'name': name,
          'forceUpdate': forceUpdate,
        },
      );

      if (response.status != 200) {
        throw Exception('크롤링 요청 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      return CrawlingResult(
        success: true,
        message: data['message'] ?? '성공',
        celebrity: data['data'] != null 
          ? Celebrity.fromJson(data['data'])
          : null,
        updated: data['updated'] ?? false,
      );
    } catch (e) {
      return CrawlingResult(
        success: false,
        message: '크롤링 실패: ${e.toString()}',
        celebrity: null,
        updated: false,
      );
    }
  }

  /// 여러 유명인을 일괄 크롤링합니다
  Future<BatchCrawlingResult> crawlMultipleCelebrities({
    required List<String> names,
    bool forceUpdate = false,
    Function(int current, int total, String currentName)? onProgress,
  }) async {
    final results = <CrawlingResult>[];
    int successCount = 0;
    int failureCount = 0;

    for (int i = 0; i < names.length; i++) {
      final name = names[i];
      
      // 진행 상황 알림
      onProgress?.call(i + 1, names.length, name);
      
      try {
        final result = await crawlCelebrityInfo(
          name: name,
          forceUpdate: forceUpdate,
        );
        
        results.add(result);
        
        if (result.success) {
          successCount++;
        } else {
          failureCount++;
        }
        
        // 서버 부하 방지를 위한 딜레이
        await Future.delayed(const Duration(seconds: 1));
        
      } catch (e) {
        results.add(CrawlingResult(
          success: false,
          message: '오류: ${e.toString()}',
          celebrity: null,
          updated: false,
        ));
        failureCount++;
      }
    }

    return BatchCrawlingResult(
      results: results,
      totalCount: names.length,
      successCount: successCount,
      failureCount: failureCount,
    );
  }

  /// 크롤링된 데이터의 품질을 검증합니다
  Future<ValidationResult> validateCrawledData(String celebrityId) async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select('*')
          .eq('id', celebrityId)
          .single();

      final celebrity = Celebrity.fromJson(response);
      final issues = <String>[];

      // 필수 정보 확인
      if (celebrity.name.isEmpty) {
        issues.add('이름이 비어있습니다');
      }
      
      if (celebrity.birthDate == null) {
        issues.add('생년월일 정보가 없습니다');
      }
      
      if (celebrity.description?.isEmpty ?? true) {
        issues.add('설명이 비어있습니다');
      }
      
      if (celebrity.keywords?.isEmpty ?? true) {
        issues.add('키워드가 없습니다');
      }

      // 이미지 URL 유효성 확인
      if (celebrity.profileImageUrl?.contains('placeholder') ?? false) {
        issues.add('기본 이미지를 사용하고 있습니다');
      }

      return ValidationResult(
        isValid: issues.isEmpty,
        issues: issues,
        celebrity: celebrity,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        issues: ['데이터 조회 실패: ${e.toString()}'],
        celebrity: null,
      );
    }
  }

  /// 크롤링 통계를 가져옵니다
  Future<CrawlingStats> getCrawlingStats() async {
    try {
      final response = await _supabase
          .from('celebrities')
          .select('crawled_at, source_url, last_updated')
          .not('crawled_at', 'is', null);

      final crawledCount = response.length;
      final totalResponse = await _supabase
          .from('celebrities')
          .select('id')
          .count(CountOption.exact);

      final totalCount = totalResponse.count ?? 0;

      // 최근 업데이트 시간
      DateTime? lastCrawledAt;
      if (response.isNotEmpty) {
        final sortedData = List<Map<String, dynamic>>.from(response)
          ..sort((a, b) => DateTime.parse(b['crawled_at'])
              .compareTo(DateTime.parse(a['crawled_at'])));
        
        lastCrawledAt = DateTime.parse(sortedData.first['crawled_at']);
      }

      return CrawlingStats(
        totalCelebrities: totalCount,
        crawledCelebrities: crawledCount,
        lastCrawledAt: lastCrawledAt,
        crawlingPercentage: totalCount > 0 ? (crawledCount / totalCount) * 100 : 0,
      );
    } catch (e) {
      throw Exception('통계 조회 실패: ${e.toString()}');
    }
  }
}

/// 크롤링 결과 클래스
class CrawlingResult {
  final bool success;
  final String message;
  final Celebrity? celebrity;
  final bool updated;

  CrawlingResult({
    required this.success,
    required this.message,
    this.celebrity,
    required this.updated,
  });
}

/// 일괄 크롤링 결과 클래스
class BatchCrawlingResult {
  final List<CrawlingResult> results;
  final int totalCount;
  final int successCount;
  final int failureCount;

  BatchCrawlingResult({
    required this.results,
    required this.totalCount,
    required this.successCount,
    required this.failureCount,
  });

  double get successRate => totalCount > 0 ? (successCount / totalCount) * 100 : 0;
}

/// 데이터 검증 결과 클래스
class ValidationResult {
  final bool isValid;
  final List<String> issues;
  final Celebrity? celebrity;

  ValidationResult({
    required this.isValid,
    required this.issues,
    this.celebrity,
  });
}

/// 크롤링 통계 클래스
class CrawlingStats {
  final int totalCelebrities;
  final int crawledCelebrities;
  final DateTime? lastCrawledAt;
  final double crawlingPercentage;

  CrawlingStats({
    required this.totalCelebrities,
    required this.crawledCelebrities,
    this.lastCrawledAt,
    required this.crawlingPercentage,
  });
}