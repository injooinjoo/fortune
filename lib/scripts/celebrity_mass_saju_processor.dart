import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

class CelebrityMassSajuProcessor {
  static const List<String> celebrityFiles = [
    'data/celebrity_lists/singers.json',
    'data/celebrity_lists/actors.json', 
    'data/celebrity_lists/streamers_youtubers.json',
    'data/celebrity_lists/politicians.json',
    'data/celebrity_lists/business_leaders.json',
    'data/celebrity_lists/comedians_athletes.json',
  ];

  static const List<String> categoryMapping = [
    'singer',
    'actor',
    'streamer',
    'politician', 
    'business_leader',
    'entertainer',
  ];

  static Future<void> processAllCelebrities() async {
    print('🚀 대량 유명인사 사주 계산 시작...');
    
    final List<CelebritySaju> allCelebrities = [];
    final List<String> sqlStatements = [];
    
    int totalCount = 0;
    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < celebrityFiles.length; i++) {
      final filePath = celebrityFiles[i];
      final category = categoryMapping[i];
      
      print('\n📁 처리 중: $filePath');
      
      try {
        final file = File(filePath);
        if (!await file.exists()) {
          print('❌ 파일을 찾을 수 없음: $filePath');
          continue;
        }

        final jsonString = await file.readAsString();
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        final List<dynamic> celebrities = jsonData['celebrities'] as List<dynamic>;
        
        print('📊 ${celebrities.length}명의 ${category} 처리 시작...');

        for (final celebrityData in celebrities) {
          totalCount++;
          
          try {
            final celebrity = await _processSingleCelebrity(
              celebrityData as Map<String, dynamic>,
              category,
            );
            
            if (celebrity != null) {
              allCelebrities.add(celebrity);
              sqlStatements.add(_generateInsertSQL(celebrity));
              successCount++;
              
              // 10명마다 진행상황 출력
              if (successCount % 10 == 0) {
                print('✅ 진행: $successCount/$totalCount 완료');
              }
            } else {
              failCount++;
            }
          } catch (e) {
            print('❌ 오류 (${celebrityData['name'] ?? 'Unknown'}): $e');
            failCount++;
          }
        }
        
        print('✅ $category 완료: ${celebrities.length}명 중 ${successCount - (totalCount - celebrities.length - failCount)}명 성공');
        
      } catch (e) {
        print('❌ 파일 처리 오류: $filePath - $e');
      }
    }

    // 결과 저장
    await _saveResults(allCelebrities, sqlStatements);
    
    print('\n🎉 전체 처리 완료!');
    print('📊 총 처리: $totalCount명');
    print('✅ 성공: $successCount명');
    print('❌ 실패: $failCount명');
    print('📈 성공률: ${(successCount / totalCount * 100).toStringAsFixed(1)}%');
  }

  static Future<CelebritySaju?> _processSingleCelebrity(
    Map<String, dynamic> data,
    String category,
  ) async {
    try {
      final name = data['name'] as String;
      final nameEn = data['name_en'] as String?;
      final birthDate = data['birth_date'] as String?;
      final gender = data['gender'] as String?;
      
      if (birthDate == null || birthDate.isEmpty) {
        print('⚠️ 생년월일 없음: $name');
        return null;
      }

      // 기본 생시를 12:00으로 설정 (정확한 생시 정보가 없는 경우)
      final birthTime = data['birth_time'] as String? ?? '12:00';
      
      // 생년월일 파싱
      final dateParts = birthDate.split('-');
      if (dateParts.length != 3) {
        print('⚠️ 잘못된 날짜 형식: $name - $birthDate');
        return null;
      }

      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      // 생시 파싱
      final timeParts = birthTime.split(':');
      final hour = timeParts.length >= 1 ? int.parse(timeParts[0]) : 12;
      final minute = timeParts.length >= 2 ? int.parse(timeParts[1]) : 0;

      final birthDateTime = DateTime(year, month, day, hour, minute);
      
      // 사주 계산
      final sajuResult = SajuCalculationService.calculateSaju(
        birthDate: birthDateTime,
        birthTime: birthTime,
        isLunar: false, // 기본적으로 양력으로 처리
      );

      // 사주 각 기둥 추출
      final yearPillar = _extractPillar(sajuResult, 'year');
      final monthPillar = _extractPillar(sajuResult, 'month'); 
      final dayPillar = _extractPillar(sajuResult, 'day');
      final hourPillar = _extractPillar(sajuResult, 'hour');

      // CelebritySaju 객체 생성
      return CelebritySaju(
        id: '', // ID는 DB에서 자동 생성
        name: name,
        nameEn: nameEn ?? '',
        birthDate: birthDate,
        birthTime: birthTime,
        gender: gender ?? 'male',
        birthPlace: data['birth_place'] as String? ?? '',
        category: category,
        agency: data['agency'] as String? ?? '',
        yearPillar: yearPillar,
        monthPillar: monthPillar,
        dayPillar: dayPillar,
        hourPillar: hourPillar,
        sajuString: _generateSajuString(sajuResult),
        woodCount: _countElement(sajuResult, '목'),
        fireCount: _countElement(sajuResult, '화'),
        earthCount: _countElement(sajuResult, '토'),
        metalCount: _countElement(sajuResult, '금'),
        waterCount: _countElement(sajuResult, '수'),
        fullSajuData: sajuResult,
        dataSource: 'namuwiki_mass_calculated',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

    } catch (e) {
      print('❌ ${data['name']} 처리 중 오류: $e');
      return null;
    }
  }

  static String _extractPillar(Map<String, dynamic> sajuData, String pillarType) {
    final pillar = sajuData[pillarType];
    if (pillar == null) return '';
    return '${pillar['stem'] ?? ''}${pillar['branch'] ?? ''}';
  }

  static String _generateSajuString(Map<String, dynamic> sajuData) {
    final parts = <String>[];
    
    if (sajuData['year'] != null) {
      final year = sajuData['year'];
      parts.add('${year['stem'] ?? ''}${year['branch'] ?? ''}');
    }
    if (sajuData['month'] != null) {
      final month = sajuData['month'];
      parts.add('${month['stem'] ?? ''}${month['branch'] ?? ''}');
    }
    if (sajuData['day'] != null) {
      final day = sajuData['day'];
      parts.add('${day['stem'] ?? ''}${day['branch'] ?? ''}');
    }
    if (sajuData['hour'] != null) {
      final hour = sajuData['hour'];
      parts.add('${hour['stem'] ?? ''}${hour['branch'] ?? ''}');
    }
    
    return parts.join(' ');
  }

  static int _countElement(Map<String, dynamic> sajuData, String element) {
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    return elements?[element] as int? ?? 0;
  }

  static String _getDominantElement(Map<String, dynamic> sajuData) {
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    if (elements == null) return '토';

    String dominantElement = '토';
    int maxCount = 0;

    elements.forEach((element, count) {
      if (count is int && count > maxCount) {
        maxCount = count;
        dominantElement = element;
      }
    });

    return dominantElement;
  }

  static String _getDominantElementFromCounts(int wood, int fire, int earth, int metal, int water) {
    final counts = {'목': wood, '화': fire, '토': earth, '금': metal, '수': water};
    String dominant = '토';
    int maxCount = 0;
    
    counts.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = element;
      }
    });
    
    return dominant;
  }

  static String _generateInsertSQL(CelebritySaju celebrity) {
    final escapedName = celebrity.name.replaceAll("'", "''");
    final escapedNameEn = celebrity.nameEn.replaceAll("'", "''");
    final escapedBirthPlace = celebrity.birthPlace.replaceAll("'", "''");
    final escapedAgency = celebrity.agency.replaceAll("'", "''");
    final escapedSajuString = celebrity.sajuString.replaceAll("'", "''");
    final escapedDataSource = celebrity.dataSource.replaceAll("'", "''");
    
    // JSON 데이터를 SQL용 문자열로 변환
    final fullSajuDataJson = json.encode(celebrity.fullSajuData).replaceAll("'", "''");

    return """
INSERT INTO celebrities (
  name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  '$escapedName', '$escapedNameEn', '${celebrity.birthDate}', '${celebrity.birthTime}',
  '${celebrity.gender}', '$escapedBirthPlace', '${celebrity.category}', '$escapedAgency',
  '${celebrity.yearPillar}', '${celebrity.monthPillar}', '${celebrity.dayPillar}', '${celebrity.hourPillar}',
  '$escapedSajuString', ${celebrity.woodCount}, ${celebrity.fireCount}, ${celebrity.earthCount},
  ${celebrity.metalCount}, ${celebrity.waterCount},
  '$fullSajuDataJson'::jsonb, '$escapedDataSource', NOW(), NOW()
);""";
  }

  static Future<void> _saveResults(
    List<CelebritySaju> celebrities, 
    List<String> sqlStatements,
  ) async {
    try {
      // JSON 파일로 결과 저장
      final jsonFile = File('celebrity_saju_results_all.json');
      final jsonData = celebrities.map((c) => c.toJson()).toList();
      await jsonFile.writeAsString(json.encode(jsonData));
      print('✅ JSON 파일 저장: ${jsonFile.path}');

      // SQL 파일로 결과 저장
      final sqlFile = File('celebrity_saju_insert_all.sql');
      final sqlContent = [
        '-- 전체 유명인사 사주 데이터 삽입 SQL',
        '-- 총 ${celebrities.length}명의 데이터',
        '',
        ...sqlStatements,
      ].join('\n');
      
      await sqlFile.writeAsString(sqlContent);
      print('✅ SQL 파일 저장: ${sqlFile.path}');

      // 통계 파일 저장
      final statsFile = File('celebrity_saju_stats.json');
      final stats = _generateStats(celebrities);
      await statsFile.writeAsString(json.encode(stats));
      print('✅ 통계 파일 저장: ${statsFile.path}');

    } catch (e) {
      print('❌ 파일 저장 오류: $e');
    }
  }

  static Map<String, dynamic> _generateStats(List<CelebritySaju> celebrities) {
    final categoryStats = <String, int>{};
    final genderStats = <String, int>{};
    final elementStats = <String, int>{};

    for (final celebrity in celebrities) {
      // 카테고리별 통계
      categoryStats[celebrity.category] = (categoryStats[celebrity.category] ?? 0) + 1;
      
      // 성별 통계
      genderStats[celebrity.gender] = (genderStats[celebrity.gender] ?? 0) + 1;
      
      // 주요 오행별 통계 (목이 가장 많은 경우 '목'으로 처리)
      final dominantElement = _getDominantElementFromCounts(
        celebrity.woodCount, celebrity.fireCount, celebrity.earthCount, 
        celebrity.metalCount, celebrity.waterCount
      );
      elementStats[dominantElement] = (elementStats[dominantElement] ?? 0) + 1;
    }

    return {
      'total_count': celebrities.length,
      'category_breakdown': categoryStats,
      'gender_breakdown': genderStats,  
      'dominant_element_breakdown': elementStats,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }
}

// 실행 스크립트
void main() async {
  await CelebrityMassSajuProcessor.processAllCelebrities();
}