import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/models/celebrity_master_list.dart';

/// 연예인 목록 데이터를 테스트하는 스크립트
/// JSON 파일을 읽고 데이터 구조를 검증합니다.
class CelebrityDataTest {
  static Future<void> main() async {
    print('🧪 연예인 목록 데이터 테스트 시작...\n');
    
    final categories = [
      'singer',
      'actor', 
      'streamer_youtuber',
      'politician',
      'business',
      'comedian_athlete',
    ];
    
    int totalCelebrities = 0;
    
    for (final categoryCode in categories) {
      try {
        print('📁 카테고리: $categoryCode');
        
        // JSON 파일 로드
        final fileName = _getCategoryFileName(categoryCode);
        final jsonString = await rootBundle.loadString('data/celebrity_lists/$fileName');
        final jsonData = json.decode(jsonString);
        
        print('  📊 총 ${jsonData['totalCount']}명');
        print('  📅 마지막 업데이트: ${jsonData['lastUpdated']}');
        
        // 연예인 리스트 파싱 테스트
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
        
        print('  ✅ ${celebrities.length}명 파싱 성공');
        
        // 상위 3명 출력
        print('  🌟 상위 3명:');
        for (int i = 0; i < 3 && i < celebrities.length; i++) {
          final celebrity = celebrities[i];
          print('    ${i + 1}. ${celebrity.name} (${celebrity.subcategory?.displayName ?? '미분류'}) - 우선순위: ${celebrity.crawlPriority}');
        }
        
        totalCelebrities += celebrities.length;
        print('');
        
      } catch (e) {
        print('  ❌ 오류: $e');
      }
    }
    
    print('📈 전체 통계:');
    print('  총 연예인 수: $totalCelebrities명');
    print('  카테고리 수: ${categories.length}개');
    print('');
    
    // 마스터 목록 테스트
    try {
      print('📋 마스터 목록 테스트...');
      final masterJsonString = await rootBundle.loadString('data/celebrity_lists/master_list.json');
      final masterData = json.decode(masterJsonString);
      
      print('  버전: ${masterData['version']}');
      print('  총 연예인 수: ${masterData['totalCelebrities']}명');
      print('  마지막 업데이트: ${masterData['lastUpdated']}');
      print('  ✅ 마스터 목록 파싱 성공');
      
    } catch (e) {
      print('  ❌ 마스터 목록 오류: $e');
    }
    
    print('\n🎉 데이터 테스트 완료!');
  }
  
  static String _getCategoryFileName(String categoryCode) {
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
  
  static CelebrityMasterCategory _getCategoryEnum(String categoryCode) {
    return CelebrityMasterCategory.fromCode(categoryCode);
  }
  
  static CelebritySubcategory? _getSubcategoryEnum(String? subcategoryName) {
    if (subcategoryName == null) return null;
    
    for (final subcategory in CelebritySubcategory.values) {
      if (subcategory.displayName == subcategoryName) {
        return subcategory;
      }
    }
    
    return CelebritySubcategory.none;
  }
  
  static int _calculatePriority(Map<String, dynamic> item) {
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

/// 스크립트 실행 진입점
void main() async {
  await CelebrityDataTest.main();
}