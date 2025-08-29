import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

class ExistingCelebritySajuProcessor {
  // 기존 migration SQL에서 추출한 유명인사 데이터
  static final List<Map<String, dynamic>> existingCelebrities = [
    // Politicians
    {'id': 'pol_001', 'name': '윤석열', 'name_en': 'Yoon Suk-yeol', 'category': 'politician', 'gender': 'male', 'birth_date': '1960-12-18', 'birth_time': '14:00'},
    {'id': 'pol_002', 'name': '이재명', 'name_en': 'Lee Jae-myung', 'category': 'politician', 'gender': 'male', 'birth_date': '1964-12-22', 'birth_time': '10:30'},
    {'id': 'pol_003', 'name': '한동훈', 'name_en': 'Han Dong-hoon', 'category': 'politician', 'gender': 'male', 'birth_date': '1973-04-15', 'birth_time': '09:00'},
    
    // Actors  
    {'id': 'act_001', 'name': '송중기', 'name_en': 'Song Joong-ki', 'category': 'actor', 'gender': 'male', 'birth_date': '1985-09-19', 'birth_time': '15:30'},
    {'id': 'act_002', 'name': '손예진', 'name_en': 'Son Ye-jin', 'category': 'actor', 'gender': 'female', 'birth_date': '1982-01-11', 'birth_time': '11:20'},
    {'id': 'act_003', 'name': '박서준', 'name_en': 'Park Seo-joon', 'category': 'actor', 'gender': 'male', 'birth_date': '1988-12-16', 'birth_time': '14:45'},
    {'id': 'act_004', 'name': '김태희', 'name_en': 'Kim Tae-hee', 'category': 'actor', 'gender': 'female', 'birth_date': '1980-03-29', 'birth_time': '09:15'},
    {'id': 'act_005', 'name': '현빈', 'name_en': 'Hyun Bin', 'category': 'actor', 'gender': 'male', 'birth_date': '1982-09-25', 'birth_time': '16:00'},
    
    // Singers
    {'id': 'sing_001', 'name': 'IU', 'name_en': 'IU', 'category': 'singer', 'gender': 'female', 'birth_date': '1993-05-16', 'birth_time': '12:30'},
    {'id': 'sing_002', 'name': 'G-Dragon', 'name_en': 'G-Dragon', 'category': 'singer', 'gender': 'male', 'birth_date': '1988-08-18', 'birth_time': '13:45'},
    {'id': 'sing_003', 'name': '태연', 'name_en': 'Taeyeon', 'category': 'singer', 'gender': 'female', 'birth_date': '1989-03-09', 'birth_time': '10:15'},
    {'id': 'sing_004', 'name': 'BTS', 'name_en': 'BTS', 'category': 'singer', 'gender': 'male', 'birth_date': '2013-06-13', 'birth_time': '00:00'},
    {'id': 'sing_005', 'name': 'NewJeans', 'name_en': 'NewJeans', 'category': 'singer', 'gender': 'female', 'birth_date': '2022-07-22', 'birth_time': '00:00'},
    
    // Athletes
    {'id': 'ath_001', 'name': '손흥민', 'name_en': 'Son Heung-min', 'category': 'athlete', 'gender': 'male', 'birth_date': '1992-07-08', 'birth_time': '14:30'},
    {'id': 'ath_002', 'name': '김연아', 'name_en': 'Kim Yuna', 'category': 'athlete', 'gender': 'female', 'birth_date': '1990-09-05', 'birth_time': '11:45'},
    {'id': 'ath_003', 'name': '박지성', 'name_en': 'Park Ji-sung', 'category': 'athlete', 'gender': 'male', 'birth_date': '1981-02-25', 'birth_time': '16:20'},
    {'id': 'ath_004', 'name': '류현진', 'name_en': 'Ryu Hyun-jin', 'category': 'athlete', 'gender': 'male', 'birth_date': '1987-03-25', 'birth_time': '13:15'},
    
    // Entertainers
    {'id': 'ent_001', 'name': '유재석', 'name_en': 'Yoo Jae-suk', 'category': 'entertainer', 'gender': 'male', 'birth_date': '1972-08-14', 'birth_time': '15:00'},
    {'id': 'ent_002', 'name': '강호동', 'name_en': 'Kang Ho-dong', 'category': 'entertainer', 'gender': 'male', 'birth_date': '1970-06-11', 'birth_time': '12:30'},
    {'id': 'ent_003', 'name': '박나래', 'name_en': 'Park Na-rae', 'category': 'entertainer', 'gender': 'female', 'birth_date': '1985-10-25', 'birth_time': '14:45'},
    
    // YouTubers/Streamers
    {'id': 'you_001', 'name': '쯔양', 'name_en': 'Tzuyang', 'category': 'youtuber', 'gender': 'female', 'birth_date': '1992-01-01', 'birth_time': '12:00'},
    {'id': 'you_002', 'name': '침착맨', 'name_en': 'ChimChakMan', 'category': 'youtuber', 'gender': 'male', 'birth_date': '1990-01-01', 'birth_time': '15:30'},
    {'id': 'str_001', 'name': '풍월량', 'name_en': 'Poongwolryang', 'category': 'streamer', 'gender': 'male', 'birth_date': '1985-01-01', 'birth_time': '20:00'},
    
    // Pro Gamers
    {'id': 'pro_001', 'name': 'Faker', 'name_en': 'Faker', 'category': 'pro_gamer', 'gender': 'male', 'birth_date': '1996-05-07', 'birth_time': '16:45'},
    {'id': 'pro_002', 'name': '임요환', 'name_en': 'Lim Yo-hwan', 'category': 'pro_gamer', 'gender': 'male', 'birth_date': '1980-09-04', 'birth_time': '14:20'},
    
    // Business Leaders
    {'id': 'bus_001', 'name': '이재용', 'name_en': 'Lee Jae-yong', 'category': 'business_leader', 'gender': 'male', 'birth_date': '1968-06-23', 'birth_time': '11:30'},
    {'id': 'bus_002', 'name': '정의선', 'name_en': 'Chung Euisun', 'category': 'business_leader', 'gender': 'male', 'birth_date': '1970-10-18', 'birth_time': '09:45'},
  ];

  static Future<void> processAllCelebrities() async {
    print('🚀 기존 유명인사 사주 계산 시작...');
    print('📊 총 ${existingCelebrities.length}명 처리 예정');
    
    final List<CelebritySaju> processedCelebrities = [];
    final List<String> sqlStatements = [];
    
    int successCount = 0;
    int failCount = 0;

    for (final celebrityData in existingCelebrities) {
      try {
        final celebrity = await _processSingleCelebrity(celebrityData);
        
        if (celebrity != null) {
          processedCelebrities.add(celebrity);
          sqlStatements.add(_generateUpdateSQL(celebrity));
          successCount++;
          
          print('✅ ${celebrity.name} 완료: ${celebrity.sajuString}');
        } else {
          failCount++;
        }
      } catch (e) {
        print('❌ 오류 (${celebrityData['name']}): $e');
        failCount++;
      }
    }

    // 결과 저장
    await _saveResults(processedCelebrities, sqlStatements);
    
    print('\n🎉 처리 완료!');
    print('📊 총 처리: ${existingCelebrities.length}명');
    print('✅ 성공: $successCount명');
    print('❌ 실패: $failCount명');
    print('📈 성공률: ${(successCount / existingCelebrities.length * 100).toStringAsFixed(1)}%');
  }

  static Future<CelebritySaju?> _processSingleCelebrity(Map<String, dynamic> data) async {
    try {
      final birthDate = data['birth_date'] as String;
      final birthTime = data['birth_time'] as String;
      
      // 생년월일 파싱
      final dateParts = birthDate.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      // 생시 파싱
      final timeParts = birthTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length >= 2 ? int.parse(timeParts[1]) : 0;

      final birthDateTime = DateTime(year, month, day, hour, minute);
      
      // 사주 계산
      final sajuResult = SajuCalculationService.calculateSaju(
        birthDate: birthDateTime,
        birthTime: birthTime,
        isLunar: false,
      );

      // 사주 각 기둥 추출
      final yearPillar = _extractPillar(sajuResult, 'year');
      final monthPillar = _extractPillar(sajuResult, 'month');
      final dayPillar = _extractPillar(sajuResult, 'day');
      final hourPillar = _extractPillar(sajuResult, 'hour');

      return CelebritySaju(
        id: data['id'] as String,
        name: data['name'] as String,
        nameEn: data['name_en'] as String,
        birthDate: birthDate,
        birthTime: birthTime,
        gender: data['gender'] as String,
        birthPlace: '',
        category: data['category'] as String,
        agency: '',
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
        dataSource: 'existing_celebrity_calculated',
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

  static String _generateUpdateSQL(CelebritySaju celebrity) {
    final escapedSajuString = celebrity.sajuString.replaceAll("'", "''");
    final fullSajuDataJson = json.encode(celebrity.fullSajuData).replaceAll("'", "''");

    return """UPDATE public.celebrities 
SET 
  year_pillar = '${celebrity.yearPillar}',
  month_pillar = '${celebrity.monthPillar}', 
  day_pillar = '${celebrity.dayPillar}',
  hour_pillar = '${celebrity.hourPillar}',
  saju_string = '$escapedSajuString',
  wood_count = ${celebrity.woodCount},
  fire_count = ${celebrity.fireCount},
  earth_count = ${celebrity.earthCount},
  metal_count = ${celebrity.metalCount},
  water_count = ${celebrity.waterCount},
  full_saju_data = '$fullSajuDataJson'::jsonb,
  data_source = '${celebrity.dataSource}',
  updated_at = NOW()
WHERE id = '${celebrity.id}';""";
  }

  static Future<void> _saveResults(
    List<CelebritySaju> celebrities, 
    List<String> sqlStatements,
  ) async {
    try {
      // JSON 파일로 결과 저장
      final jsonFile = File('celebrity_saju_results_existing.json');
      final jsonData = celebrities.map((c) => c.toJson()).toList();
      await jsonFile.writeAsString(json.encode(jsonData));
      print('✅ JSON 파일 저장: ${jsonFile.path}');

      // SQL 파일로 결과 저장
      final sqlFile = File('celebrity_saju_update_existing.sql');
      final sqlContent = [
        '-- 기존 유명인사 사주 데이터 업데이트 SQL',
        '-- 총 ${celebrities.length}명의 데이터',
        '',
        ...sqlStatements,
      ].join('\n');
      
      await sqlFile.writeAsString(sqlContent);
      print('✅ SQL 파일 저장: ${sqlFile.path}');

    } catch (e) {
      print('❌ 파일 저장 오류: $e');
    }
  }
}

// 실행 스크립트
void main() async {
  await ExistingCelebritySajuProcessor.processAllCelebrities();
}