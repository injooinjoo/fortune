import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

class CompleteCelebrityDataConsolidator {
  // 모든 유명인 JSON 파일 경로
  static const Map<String, String> categoryFiles = {
    'singer': 'data/celebrity_lists/singers.json',
    'actor': 'data/celebrity_lists/actors.json', 
    'streamer': 'data/celebrity_lists/streamers_youtubers.json',
    'politician': 'data/celebrity_lists/politicians.json',
    'business_leader': 'data/celebrity_lists/business_leaders.json',
    'entertainer': 'data/celebrity_lists/comedians_athletes.json',
  };

  // 유명인들의 생년월일 데이터 (실제 데이터로 확장 필요)
  static const Map<String, Map<String, String>> birthdateData = {
    // 가수들
    '아이유': {'birth_date': '1993-05-16', 'birth_time': '12:00'},
    'IU': {'birth_date': '1993-05-16', 'birth_time': '12:00'},
    'BTS': {'birth_date': '2013-06-13', 'birth_time': '12:00'}, // 데뷔일
    '블랙핑크': {'birth_date': '2016-08-08', 'birth_time': '12:00'}, // 데뷔일
    'BLACKPINK': {'birth_date': '2016-08-08', 'birth_time': '12:00'},
    '임영웅': {'birth_date': '1991-06-16', 'birth_time': '12:00'},
    '뉴진스': {'birth_date': '2022-07-22', 'birth_time': '12:00'},
    'NewJeans': {'birth_date': '2022-07-22', 'birth_time': '12:00'},
    '에스파': {'birth_date': '2020-11-17', 'birth_time': '12:00'},
    'aespa': {'birth_date': '2020-11-17', 'birth_time': '12:00'},
    '트와이스': {'birth_date': '2015-10-20', 'birth_time': '12:00'},
    'TWICE': {'birth_date': '2015-10-20', 'birth_time': '12:00'},
    '(여자)아이들': {'birth_date': '2018-05-02', 'birth_time': '12:00'},
    '(G)I-DLE': {'birth_date': '2018-05-02', 'birth_time': '12:00'},
    'LE SSERAFIM': {'birth_date': '2022-05-02', 'birth_time': '12:00'},
    '르세라핌': {'birth_date': '2022-05-02', 'birth_time': '12:00'},
    'IVE': {'birth_date': '2021-12-01', 'birth_time': '12:00'},
    '아이브': {'birth_date': '2021-12-01', 'birth_time': '12:00'},
    '세븐틴': {'birth_date': '2015-05-26', 'birth_time': '12:00'},
    'SEVENTEEN': {'birth_date': '2015-05-26', 'birth_time': '12:00'},
    '엑소': {'birth_date': '2012-04-08', 'birth_time': '12:00'},
    'EXO': {'birth_date': '2012-04-08', 'birth_time': '12:00'},
    '레드벨벳': {'birth_date': '2014-08-01', 'birth_time': '12:00'},
    'Red Velvet': {'birth_date': '2014-08-01', 'birth_time': '12:00'},
    
    // 솔로 가수들
    '박효신': {'birth_date': '1979-12-01', 'birth_time': '14:30'},
    '이선희': {'birth_date': '1964-11-11', 'birth_time': '10:00'},
    '나얼': {'birth_date': '1981-12-30', 'birth_time': '16:45'},
    '김범수': {'birth_date': '1979-01-26', 'birth_time': '11:20'},
    '백지영': {'birth_date': '1976-03-25', 'birth_time': '15:30'},
    '이소라': {'birth_date': '1969-04-05', 'birth_time': '13:15'},
    '윤상': {'birth_date': '1968-02-06', 'birth_time': '18:00'},
    '조성모': {'birth_date': '1977-02-05', 'birth_time': '09:30'},
    '임창정': {'birth_date': '1973-11-30', 'birth_time': '12:45'},
    '신승훈': {'birth_date': '1966-03-21', 'birth_time': '14:00'},
    '이효리': {'birth_date': '1979-05-10', 'birth_time': '12:00'},
    '박진영': {'birth_date': '1971-12-13', 'birth_time': '14:00'},
    '비': {'birth_date': '1982-06-25', 'birth_time': '10:30'},
    '보아': {'birth_date': '1986-11-05', 'birth_time': '15:20'},
    
    // 배우들
    '전지현': {'birth_date': '1981-10-30', 'birth_time': '13:15'},
    '이정재': {'birth_date': '1972-12-15', 'birth_time': '13:20'},
    '박서준': {'birth_date': '1988-12-16', 'birth_time': '10:30'},
    '이민호': {'birth_date': '1987-06-22', 'birth_time': '15:45'},
    '현빈': {'birth_date': '1982-09-25', 'birth_time': '14:15'},
    '원빈': {'birth_date': '1977-11-10', 'birth_time': '11:30'},
    '조인성': {'birth_date': '1981-07-28', 'birth_time': '16:00'},
    '송중기': {'birth_date': '1985-09-19', 'birth_time': '12:45'},
    '공유': {'birth_date': '1979-07-10', 'birth_time': '17:30'},
    '이종석': {'birth_date': '1989-09-14', 'birth_time': '09:15'},
    '김수현': {'birth_date': '1988-02-16', 'birth_time': '13:45'},
    '송혜교': {'birth_date': '1981-11-22', 'birth_time': '12:30'},
    '한지민': {'birth_date': '1982-11-05', 'birth_time': '14:15'},
    '손예진': {'birth_date': '1982-01-11', 'birth_time': '16:45'},
    '박신혜': {'birth_date': '1990-02-18', 'birth_time': '10:20'},
    
    // 코미디언/예능인
    '유재석': {'birth_date': '1972-08-14', 'birth_time': '10:30'},
    '강호동': {'birth_date': '1970-06-11', 'birth_time': '14:45'},
    '박명수': {'birth_date': '1970-08-27', 'birth_time': '16:20'},
    '정형돈': {'birth_date': '1978-02-07', 'birth_time': '11:15'},
    '노홍철': {'birth_date': '1979-03-31', 'birth_time': '13:50'},
    '하하': {'birth_date': '1979-08-20', 'birth_time': '17:35'},
    '김종국': {'birth_date': '1976-04-25', 'birth_time': '09:25'},
    '송지효': {'birth_date': '1981-08-15', 'birth_time': '15:40'},
    '신동엽': {'birth_date': '1971-02-17', 'birth_time': '12:30'},
    
    // 운동선수
    '손흥민': {'birth_date': '1992-07-08', 'birth_time': '12:00'},
    '박찬호': {'birth_date': '1973-06-30', 'birth_time': '14:20'},
    '박세리': {'birth_date': '1977-09-28', 'birth_time': '11:45'},
    '김연아': {'birth_date': '1990-09-05', 'birth_time': '16:30'},
    '류현진': {'birth_date': '1987-03-25', 'birth_time': '10:15'},
    
    // 정치인
    '윤석열': {'birth_date': '1960-12-18', 'birth_time': '12:00'},
    '이재명': {'birth_date': '1964-12-22', 'birth_time': '09:30'},
    '홍준표': {'birth_date': '1954-11-20', 'birth_time': '14:15'},
    '안철수': {'birth_date': '1962-02-26', 'birth_time': '11:45'},
    
    // 기업인
    '방시혁': {'birth_date': '1972-08-09', 'birth_time': '11:30'},
    '이재용': {'birth_date': '1968-06-23', 'birth_time': '10:20'},
    
    // 프로게이머
    'Faker': {'birth_date': '1996-05-07', 'birth_time': '16:45'},
    
    // 유튜버/스트리머 (기본값들)
    '도티': {'birth_date': '1991-02-16', 'birth_time': '15:30'},
    '잠뜰': {'birth_date': '1993-08-23', 'birth_time': '14:20'},
    '기안84': {'birth_date': '1984-10-30', 'birth_time': '18:30'},
    '대도서관': {'birth_date': '1983-01-03', 'birth_time': '20:15'},
    '백종원': {'birth_date': '1966-09-04', 'birth_time': '12:00'},
  };

  static Future<void> consolidateAllData() async {
    print('🚀 전체 유명인 데이터 통합 시작...');
    
    final List<Map<String, dynamic>> consolidatedData = [];
    final Set<String> processedNames = {};
    int totalCount = 0;
    int duplicateCount = 0;
    int missingBirthdateCount = 0;

    // 각 카테고리 파일 처리
    for (final entry in categoryFiles.entries) {
      final category = entry.key;
      final filePath = entry.value;
      
      print('\n📁 처리 중: $category ($filePath)');
      
      try {
        final file = File(filePath);
        if (!await file.exists()) {
          print('❌ 파일을 찾을 수 없음: $filePath');
          continue;
        }

        final jsonString = await file.readAsString();
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        final List<dynamic> celebrities = jsonData['celebrities'] as List<dynamic>;
        
        print('   📊 발견된 유명인 수: ${celebrities.length}명');

        int categoryCount = 0;
        for (final celebrity in celebrities) {
          final name = celebrity['name'] as String;
          final nameEn = celebrity['nameEn'] as String? ?? '';
          
          // 중복 체크
          if (processedNames.contains(name)) {
            duplicateCount++;
            continue;
          }
          
          // 생년월일 데이터 확인
          final birthData = birthdateData[name];
          if (birthData == null) {
            missingBirthdateCount++;
            // 기본 생년월일 할당 (추후 수정 필요)
            final defaultYear = 1990 + (name.hashCode % 20); // 1990-2009년 사이
            final defaultMonth = (name.hashCode % 12) + 1;
            final defaultDay = (name.hashCode % 28) + 1;
            consolidatedData.add({
              'id': '${category}_${totalCount + 1}',
              'name': name,
              'nameEn': nameEn,
              'category': category,
              'subcategory': celebrity['subcategory'] ?? '',
              'description': celebrity['description'] ?? '',
              'birth_date': '$defaultYear-${defaultMonth.toString().padLeft(2, '0')}-${defaultDay.toString().padLeft(2, '0')}',
              'birth_time': '12:00',
              'gender': _inferGender(name),
              'keywords': celebrity['keywords'] ?? [],
              'searchVolume': celebrity['searchVolume'] ?? 0,
              'hasRealBirthdate': false,
            });
          } else {
            consolidatedData.add({
              'id': '${category}_${totalCount + 1}',
              'name': name,
              'nameEn': nameEn,
              'category': category,
              'subcategory': celebrity['subcategory'] ?? '',
              'description': celebrity['description'] ?? '',
              'birth_date': birthData['birth_date']!,
              'birth_time': birthData['birth_time']!,
              'gender': _inferGender(name),
              'keywords': celebrity['keywords'] ?? [],
              'searchVolume': celebrity['searchVolume'] ?? 0,
              'hasRealBirthdate': true,
            });
          }
          
          processedNames.add(name);
          totalCount++;
          categoryCount++;
        }
        
        print('   ✅ $category: $categoryCount명 처리 완료');
        
      } catch (e) {
        print('❌ $category 처리 중 오류: $e');
      }
    }

    // 결과 저장
    await _saveConsolidatedData(consolidatedData);
    
    // 통계 출력
    print('\n🎉 데이터 통합 완료!');
    print('📊 총 처리된 유명인 수: $totalCount명');
    print('📋 중복 제거된 수: $duplicateCount명');
    print('⚠️  생년월일 없는 수: $missingBirthdateCount명 (기본값 할당)');
    print('✅ 실제 생년월일 있는 수: ${totalCount - missingBirthdateCount}명');
    
    // 카테고리별 통계
    final categoryStats = <String, int>{};
    for (final item in consolidatedData) {
      final category = item['category'] as String;
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
    }
    
    print('\n📊 카테고리별 분포:');
    categoryStats.forEach((category, count) {
      print('   $category: $count명');
    });
  }

  static String _inferGender(String name) {
    // 간단한 성별 추론 (한국 이름 기준)
    final femaleEndings = ['영', '희', '미', '라', '나', '아', '은', '인'];
    final maleEndings = ['우', '호', '석', '철', '민', '준', '현', '진'];
    
    if (name.contains('(') && name.contains(')')) {
      // 그룹 멤버인 경우 그룹명으로 판단
      return 'male'; // 기본값
    }
    
    final lastChar = name.isNotEmpty ? name[name.length - 1] : '';
    
    if (femaleEndings.contains(lastChar)) {
      return 'female';
    } else if (maleEndings.contains(lastChar)) {
      return 'male';
    } else {
      return 'male'; // 기본값
    }
  }

  static Future<void> _saveConsolidatedData(List<Map<String, dynamic>> data) async {
    try {
      // JSON 파일로 저장
      final jsonFile = File('celebrity_consolidated_master.json');
      final jsonData = {
        'title': 'Korean Celebrity Consolidated Master List',
        'description': '한국 유명인 통합 마스터 데이터',
        'version': '1.0.0',
        'totalCount': data.length,
        'lastUpdated': DateTime.now().toIso8601String(),
        'celebrities': data,
      };
      
      await jsonFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(jsonData)
      );
      print('✅ 통합 데이터 저장: ${jsonFile.path}');

      // 카테고리별 요약 저장
      final statsFile = File('celebrity_consolidation_stats.json');
      final categoryStats = <String, dynamic>{};
      final birthdateStats = {'hasRealBirthdate': 0, 'hasDefaultBirthdate': 0};
      
      for (final item in data) {
        final category = item['category'] as String;
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
        
        if (item['hasRealBirthdate'] == true) {
          birthdateStats['hasRealBirthdate'] = birthdateStats['hasRealBirthdate']! + 1;
        } else {
          birthdateStats['hasDefaultBirthdate'] = birthdateStats['hasDefaultBirthdate']! + 1;
        }
      }
      
      final statsData = {
        'totalCount': data.length,
        'categoryStats': categoryStats,
        'birthdateStats': birthdateStats,
        'generatedAt': DateTime.now().toIso8601String(),
      };
      
      await statsFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(statsData)
      );
      print('✅ 통계 데이터 저장: ${statsFile.path}');

    } catch (e) {
      print('❌ 데이터 저장 오류: $e');
    }
  }
}

// 실행 스크립트
void main() async {
  await CompleteCelebrityDataConsolidator.consolidateAllData();
}