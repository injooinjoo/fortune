import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/celebrity_master_list.dart';

class CelebrityListService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// JSON 파일에서 카테고리별 목록을 로드합니다
  Future<CelebrityCategoryList> loadCategoryFromAssets(String categoryCode) async {
    try {
      final fileName = _getCategoryFileName(categoryCode);
      final jsonString = await rootBundle.loadString('data/celebrity_lists/$fileName');
      final jsonData = json.decode(jsonString);
      
      final celebrities = (jsonData['celebrities'] as List)
          .map((item) => CelebrityMasterListItem.fromJson({
            'id': '${categoryCode}_${item['rank']}',
            'name': item['name'],
            'name_en': item['nameEn'],
            'category': _getCategoryEnum(categoryCode),
            'subcategory': _getSubcategoryEnum(item['subcategory']),
            'popularity_rank': item['rank'],
            'search_volume': item['searchVolume'],
            'last_active': item['lastActive'],
            'is_crawled': false,
            'crawl_priority': _calculatePriority(item),
            'description': item['description'],
            'keywords': List<String>.from(item['keywords']),
            'platform': item['platform'],
            'created_at': DateTime.now(),
            'updated_at': DateTime.now(),
          }))
          .toList();

      return CelebrityCategoryList(
        category: _getCategoryEnum(categoryCode),
        categoryDisplayName: jsonData['category'],
        totalCount: jsonData['totalCount'],
        lastUpdated: DateTime.parse(jsonData['lastUpdated']),
        celebrities: celebrities,
      );
    } catch (e) {
      throw Exception('Failed to load category $categoryCode: $e');
    }
  }

  /// 마스터 목록을 로드합니다
  Future<Map<String, dynamic>> loadMasterList() async {
    try {
      final jsonString = await rootBundle.loadString('data/celebrity_lists/master_list.json');
      return json.decode(jsonString);
    } catch (e) {
      throw Exception('Failed to load master list: $e');
    }
  }

  /// 모든 카테고리 목록을 Supabase에 업로드합니다
  Future<void> uploadAllCategoriesToSupabase() async {
    final categories = [
      'singer',
      'actor',
      'streamer_youtuber',
      'politician',
      'business',
      'comedian_athlete',
    ];

    int totalUploaded = 0;
    int totalErrors = 0;

    for (final categoryCode in categories) {
      try {
        final categoryList = await loadCategoryFromAssets(categoryCode);
        final result = await uploadCategoryToSupabase(categoryList);
        
        totalUploaded += result.successCount;
        totalErrors += result.errorCount;
        
        debugPrint('✅ Uploaded $categoryCode: ${result.successCount} success, ${result.errorCount} errors');
      } catch (e) {
        debugPrint('❌ Failed to upload $categoryCode: $e');
        totalErrors++;
      }
    }

    debugPrint('📊 Total uploaded: $totalUploaded, Total errors: $totalErrors');
  }

  /// 특정 카테고리를 Supabase에 업로드합니다
  Future<UploadResult> uploadCategoryToSupabase(CelebrityCategoryList categoryList) async {
    int successCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    for (final celebrity in categoryList.celebrities) {
      try {
        await _supabase
            .from('celebrity_master_list')
            .upsert({
              'id': celebrity.id,
              'name': celebrity.name,
              'name_en': celebrity.nameEn,
              'category': celebrity.category.code,
              'subcategory': celebrity.subcategory?.code,
              'popularity_rank': celebrity.popularityRank,
              'search_volume': celebrity.searchVolume,
              'last_active': celebrity.lastActive,
              'is_crawled': celebrity.isCrawled,
              'crawl_priority': celebrity.crawlPriority,
              'description': celebrity.description,
              'keywords': celebrity.keywords,
              'platform': celebrity.platform,
              'created_at': celebrity.createdAt.toIso8601String(),
              'updated_at': celebrity.updatedAt.toIso8601String(),
            })
            .eq('name', celebrity.name)
            .eq('category', celebrity.category.code);
        
        successCount++;
      } catch (e) {
        errorCount++;
        errors.add('${celebrity.name}: $e');
        debugPrint('❌ Error uploading ${celebrity.name}: $e');
      }
    }

    return UploadResult(
      successCount: successCount,
      errorCount: errorCount,
      errors: errors,
    );
  }

  /// Supabase에서 크롤링할 다음 연예인들을 가져옵니다
  Future<List<CelebrityMasterListItem>> getNextCelebritiesToCrawl({
    int limit = 10,
    String? category,
  }) async {
    try {
      var query = _supabase
          .from('celebrity_master_list')
          .select('*')
          .eq('is_crawled', false);

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query
          .order('crawl_priority', ascending: false)
          .order('popularity_rank', ascending: true)
          .limit(limit);

      return response.map<CelebrityMasterListItem>((item) => 
          CelebrityMasterListItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get celebrities to crawl: $e');
    }
  }

  /// 연예인을 크롤링 완료로 마크합니다
  Future<void> markCelebrityAsCrawled(String celebrityId) async {
    try {
      await _supabase
          .from('celebrity_master_list')
          .update({
            'is_crawled': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', celebrityId);
    } catch (e) {
      throw Exception('Failed to mark celebrity as crawled: $e');
    }
  }

  /// 크롤링 통계를 가져옵니다
  Future<CrawlingStats> getCrawlingStats() async {
    try {
      final totalResponse = await _supabase
          .from('celebrity_master_list')
          .select('id')
          .count(CountOption.exact);

      final crawledResponse = await _supabase
          .from('celebrity_master_list')
          .select('id')
          .eq('is_crawled', true)
          .count(CountOption.exact);

      final lastCrawledResponse = await _supabase
          .from('celebrity_master_list')
          .select('updated_at')
          .eq('is_crawled', true)
          .order('updated_at', ascending: false)
          .limit(1);

      final totalCount = totalResponse.count ?? 0;
      final crawledCount = crawledResponse.count ?? 0;
      
      DateTime? lastCrawledAt;
      if (lastCrawledResponse.isNotEmpty) {
        lastCrawledAt = DateTime.parse(lastCrawledResponse.first['updated_at']);
      }

      return CrawlingStats(
        totalCelebrities: totalCount,
        crawledCelebrities: crawledCount,
        lastCrawledAt: lastCrawledAt,
        crawlingPercentage: totalCount > 0 ? (crawledCount / totalCount) * 100 : 0,
      );
    } catch (e) {
      throw Exception('Failed to get crawling stats: $e');
    }
  }

  /// 카테고리별 통계를 가져옵니다
  Future<Map<String, CategoryStats>> getCategoryStats() async {
    try {
      final response = await _supabase
          .from('celebrity_master_list')
          .select('category, is_crawled, crawl_priority');

      final Map<String, CategoryStats> stats = {};

      for (final item in response) {
        final category = item['category'] as String;
        final isCrawled = item['is_crawled'] as bool;
        final priority = item['crawl_priority'] as int;

        if (!stats.containsKey(category)) {
          stats[category] = CategoryStats(
            categoryCode: category,
            total: 0,
            crawled: 0,
            avgPriority: 0,
          );
        }

        final categoryStat = stats[category]!;
        stats[category] = CategoryStats(
          categoryCode: category,
          total: categoryStat.total + 1,
          crawled: isCrawled ? categoryStat.crawled + 1 : categoryStat.crawled,
          avgPriority: ((categoryStat.avgPriority * categoryStat.total) + priority) / (categoryStat.total + 1),
        );
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get category stats: $e');
    }
  }

  /// 우선순위를 업데이트합니다
  Future<void> updateCrawlingPriorities() async {
    try {
      final celebrities = await _supabase
          .from('celebrity_master_list')
          .select('*');

      for (final item in celebrities) {
        final celebrity = CelebrityMasterListItem.fromJson(item);
        final newPriority = CrawlPriorityCalculator.calculatePriority(celebrity);
        
        if (newPriority != celebrity.crawlPriority) {
          await _supabase
              .from('celebrity_master_list')
              .update({
                'crawl_priority': newPriority,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', celebrity.id);
        }
      }
    } catch (e) {
      throw Exception('Failed to update crawling priorities: $e');
    }
  }

  // Helper methods
  String _getCategoryFileName(String categoryCode) {
    switch (categoryCode) {
      case 'singer':
        return 'singers.json';
      case 'actor':
        return 'actors.json';
      case 'streamer_youtuber':
        return 'streamers_youtubers.json';
      case 'politician':
        return 'politicians.json';
      case 'business':
        return 'business_leaders.json';
      case 'comedian_athlete':
        return 'comedians_athletes.json';
      default:
        throw Exception('Unknown category: $categoryCode');
    }
  }

  CelebrityMasterCategory _getCategoryEnum(String categoryCode) {
    return CelebrityMasterCategory.fromCode(categoryCode);
  }

  CelebritySubcategory? _getSubcategoryEnum(String? subcategoryName) {
    if (subcategoryName == null) return null;
    
    for (final subcategory in CelebritySubcategory.values) {
      if (subcategory.displayName == subcategoryName) {
        return subcategory;
      }
    }
    
    return CelebritySubcategory.none;
  }

  int _calculatePriority(Map<String, dynamic> item) {
    final rank = item['rank'] as int;
    final searchVolume = item['searchVolume'] as int?;
    
    // 기본 순위 점수 (1위=100점, 100위=1점)
    int priority = (101 - rank) * 10;
    
    // 검색량 보너스
    if (searchVolume != null) {
      if (searchVolume > 1000000) priority += 100;
      else if (searchVolume > 500000) priority += 50;
      else if (searchVolume > 100000) priority += 20;
    }
    
    return priority;
  }
}

/// 업로드 결과 클래스
class UploadResult {
  final int successCount;
  final int errorCount;
  final List<String> errors;

  UploadResult({
    required this.successCount,
    required this.errorCount,
    required this.errors,
  });
}

/// 카테고리 통계 클래스
class CategoryStats {
  final String categoryCode;
  final int total;
  final int crawled;
  final double avgPriority;

  CategoryStats({
    required this.categoryCode,
    required this.total,
    required this.crawled,
    required this.avgPriority,
  });

  double get crawledPercentage => total > 0 ? (crawled / total) * 100 : 0;
}

/// 크롤링 통계 클래스 (기존 것과 중복이므로 별도 정의)
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