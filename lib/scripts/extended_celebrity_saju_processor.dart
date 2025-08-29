import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

class ExtendedCelebritySajuProcessor {
  // 추가 유명인사 데이터 (생년월일 포함)
  static final List<Map<String, dynamic>> extendedCelebrities = [
    // 더 많은 가수들
    {'id': 'sing_006', 'name': '이효리', 'name_en': 'Lee Hyo-ri', 'category': 'singer', 'gender': 'female', 'birth_date': '1979-05-10', 'birth_time': '12:00'},
    {'id': 'sing_007', 'name': '박진영', 'name_en': 'Park Jin-young', 'category': 'singer', 'gender': 'male', 'birth_date': '1971-12-13', 'birth_time': '14:00'},
    {'id': 'sing_008', 'name': '비', 'name_en': 'Rain', 'category': 'singer', 'gender': 'male', 'birth_date': '1982-06-25', 'birth_time': '10:30'},
    {'id': 'sing_009', 'name': '보아', 'name_en': 'BoA', 'category': 'singer', 'gender': 'female', 'birth_date': '1986-11-05', 'birth_time': '15:20'},
    {'id': 'sing_010', 'name': '세븐틴', 'name_en': 'SEVENTEEN', 'category': 'singer', 'gender': 'male', 'birth_date': '2015-05-26', 'birth_time': '00:00'},
    {'id': 'sing_011', 'name': '블랙핑크', 'name_en': 'BLACKPINK', 'category': 'singer', 'gender': 'female', 'birth_date': '2016-08-08', 'birth_time': '00:00'},
    {'id': 'sing_012', 'name': '아이브', 'name_en': 'IVE', 'category': 'singer', 'gender': 'female', 'birth_date': '2021-12-01', 'birth_time': '00:00'},
    {'id': 'sing_013', 'name': '트와이스', 'name_en': 'TWICE', 'category': 'singer', 'gender': 'female', 'birth_date': '2015-10-20', 'birth_time': '00:00'},
    {'id': 'sing_014', 'name': '레드벨벳', 'name_en': 'Red Velvet', 'category': 'singer', 'gender': 'female', 'birth_date': '2014-08-01', 'birth_time': '00:00'},
    {'id': 'sing_015', 'name': '엑소', 'name_en': 'EXO', 'category': 'singer', 'gender': 'male', 'birth_date': '2012-04-08', 'birth_time': '00:00'},

    // 더 많은 배우들
    {'id': 'act_006', 'name': '전지현', 'name_en': 'Jun Ji-hyun', 'category': 'actor', 'gender': 'female', 'birth_date': '1981-10-30', 'birth_time': '13:15'},
    {'id': 'act_007', 'name': '이민호', 'name_en': 'Lee Min-ho', 'category': 'actor', 'gender': 'male', 'birth_date': '1987-06-22', 'birth_time': '16:30'},
    {'id': 'act_008', 'name': '송혜교', 'name_en': 'Song Hye-kyo', 'category': 'actor', 'gender': 'female', 'birth_date': '1981-11-22', 'birth_time': '09:45'},
    {'id': 'act_009', 'name': '김수현', 'name_en': 'Kim Soo-hyun', 'category': 'actor', 'gender': 'male', 'birth_date': '1988-02-16', 'birth_time': '11:20'},
    {'id': 'act_010', 'name': '박민영', 'name_en': 'Park Min-young', 'category': 'actor', 'gender': 'female', 'birth_date': '1986-03-04', 'birth_time': '14:10'},
    {'id': 'act_011', 'name': '이종석', 'name_en': 'Lee Jong-suk', 'category': 'actor', 'gender': 'male', 'birth_date': '1989-09-14', 'birth_time': '15:40'},
    {'id': 'act_012', 'name': '수지', 'name_en': 'Suzy', 'category': 'actor', 'gender': 'female', 'birth_date': '1994-10-10', 'birth_time': '12:30'},
    {'id': 'act_013', 'name': '차은우', 'name_en': 'Cha Eun-woo', 'category': 'actor', 'gender': 'male', 'birth_date': '1997-03-30', 'birth_time': '10:15'},
    {'id': 'act_014', 'name': '김고은', 'name_en': 'Kim Go-eun', 'category': 'actor', 'gender': 'female', 'birth_date': '1991-07-02', 'birth_time': '16:50'},
    {'id': 'act_015', 'name': '박보검', 'name_en': 'Park Bo-gum', 'category': 'actor', 'gender': 'male', 'birth_date': '1993-06-16', 'birth_time': '13:25'},

    // 더 많은 스포츠 선수들
    {'id': 'ath_005', 'name': '이강인', 'name_en': 'Lee Kang-in', 'category': 'athlete', 'gender': 'male', 'birth_date': '2001-02-19', 'birth_time': '14:30'},
    {'id': 'ath_006', 'name': '김민재', 'name_en': 'Kim Min-jae', 'category': 'athlete', 'gender': 'male', 'birth_date': '1996-11-15', 'birth_time': '11:45'},
    {'id': 'ath_007', 'name': '황희찬', 'name_en': 'Hwang Hee-chan', 'category': 'athlete', 'gender': 'male', 'birth_date': '1996-01-26', 'birth_time': '16:20'},
    {'id': 'ath_008', 'name': '김유진', 'name_en': 'Kim Yu-jin', 'category': 'athlete', 'gender': 'female', 'birth_date': '1992-09-21', 'birth_time': '13:15'},
    {'id': 'ath_009', 'name': '안세영', 'name_en': 'An Se-young', 'category': 'athlete', 'gender': 'female', 'birth_date': '2002-02-05', 'birth_time': '10:30'},
    {'id': 'ath_010', 'name': '이승우', 'name_en': 'Lee Seung-woo', 'category': 'athlete', 'gender': 'male', 'birth_date': '1998-01-06', 'birth_time': '15:45'},

    // 더 많은 예능인들
    {'id': 'ent_004', 'name': '신동엽', 'name_en': 'Shin Dong-yup', 'category': 'entertainer', 'gender': 'male', 'birth_date': '1971-02-17', 'birth_time': '12:30'},
    {'id': 'ent_005', 'name': '김희철', 'name_en': 'Kim Hee-chul', 'category': 'entertainer', 'gender': 'male', 'birth_date': '1983-07-10', 'birth_time': '14:45'},
    {'id': 'ent_006', 'name': '이승기', 'name_en': 'Lee Seung-gi', 'category': 'entertainer', 'gender': 'male', 'birth_date': '1987-01-13', 'birth_time': '16:20'},
    {'id': 'ent_007', 'name': '박나영', 'name_en': 'Park Na-young', 'category': 'entertainer', 'gender': 'female', 'birth_date': '1993-05-25', 'birth_time': '11:30'},
    {'id': 'ent_008', 'name': '전현무', 'name_en': 'Jun Hyun-moo', 'category': 'entertainer', 'gender': 'male', 'birth_date': '1977-11-15', 'birth_time': '13:40'},

    // 더 많은 유튜버/스트리머들  
    {'id': 'you_003', 'name': '백종원', 'name_en': 'Paik Jong-won', 'category': 'youtuber', 'gender': 'male', 'birth_date': '1966-09-04', 'birth_time': '12:00'},
    {'id': 'you_004', 'name': '도티', 'name_en': 'Doty', 'category': 'youtuber', 'gender': 'male', 'birth_date': '1991-02-16', 'birth_time': '15:30'},
    {'id': 'you_005', 'name': '잠뜰', 'name_en': 'Jamttul', 'category': 'youtuber', 'gender': 'male', 'birth_date': '1993-08-23', 'birth_time': '14:20'},
    {'id': 'str_002', 'name': '기안84', 'name_en': 'Gian84', 'category': 'streamer', 'gender': 'male', 'birth_date': '1984-10-30', 'birth_time': '18:30'},
    {'id': 'str_003', 'name': '대도서관', 'name_en': 'Daedoseogwan', 'category': 'streamer', 'gender': 'male', 'birth_date': '1983-01-03', 'birth_time': '20:15'},

    // 더 많은 프로게이머들
    {'id': 'pro_003', 'name': '제우스', 'name_en': 'Zeus', 'category': 'pro_gamer', 'gender': 'male', 'birth_date': '2004-01-31', 'birth_time': '16:45'},
    {'id': 'pro_004', 'name': '카리아', 'name_en': 'Keria', 'category': 'pro_gamer', 'gender': 'male', 'birth_date': '2002-10-14', 'birth_time': '14:20'},
    {'id': 'pro_005', 'name': '구마유시', 'name_en': 'Gumayusi', 'category': 'pro_gamer', 'gender': 'male', 'birth_date': '2002-02-06', 'birth_time': '13:30'},

    // 더 많은 기업인들
    {'id': 'bus_003', 'name': '방시혁', 'name_en': 'Bang Si-hyuk', 'category': 'business_leader', 'gender': 'male', 'birth_date': '1972-08-09', 'birth_time': '11:30'},
    {'id': 'bus_004', 'name': '김범수', 'name_en': 'Kim Beom-su', 'category': 'business_leader', 'gender': 'male', 'birth_date': '1966-03-23', 'birth_time': '09:45'},
    {'id': 'bus_005', 'name': '이해진', 'name_en': 'Lee Hae-jin', 'category': 'business_leader', 'gender': 'male', 'birth_date': '1967-06-22', 'birth_time': '14:20'},
    {'id': 'bus_006', 'name': '민희진', 'name_en': 'Min Hee-jin', 'category': 'business_leader', 'gender': 'female', 'birth_date': '1979-12-16', 'birth_time': '16:30'},
    {'id': 'bus_007', 'name': '윤종용', 'name_en': 'Yoon Jong-yong', 'category': 'business_leader', 'gender': 'male', 'birth_date': '1944-12-15', 'birth_time': '10:15'},

    // 추가 정치인들
    {'id': 'pol_004', 'name': '이낙연', 'name_en': 'Lee Nak-yon', 'category': 'politician', 'gender': 'male', 'birth_date': '1952-12-20', 'birth_time': '13:00'},
    {'id': 'pol_005', 'name': '안철수', 'name_en': 'Ahn Cheol-soo', 'category': 'politician', 'gender': 'male', 'birth_date': '1962-02-26', 'birth_time': '11:45'},
    {'id': 'pol_006', 'name': '홍준표', 'name_en': 'Hong Joon-pyo', 'category': 'politician', 'gender': 'male', 'birth_date': '1954-12-18', 'birth_time': '15:20'},
    {'id': 'pol_007', 'name': '심상정', 'name_en': 'Sim Sang-jeung', 'category': 'politician', 'gender': 'female', 'birth_date': '1959-09-13', 'birth_time': '12:30'},
    {'id': 'pol_008', 'name': '오세훈', 'name_en': 'Oh Se-hoon', 'category': 'politician', 'gender': 'male', 'birth_date': '1961-01-04', 'birth_time': '09:15'},
  ];

  static Future<void> processAllCelebrities() async {
    print('🚀 추가 유명인사 사주 계산 시작...');
    print('📊 총 ${extendedCelebrities.length}명 처리 예정');
    
    final List<CelebritySaju> processedCelebrities = [];
    final List<String> sqlStatements = [];
    
    int successCount = 0;
    int failCount = 0;

    for (final celebrityData in extendedCelebrities) {
      try {
        final celebrity = await _processSingleCelebrity(celebrityData);
        
        if (celebrity != null) {
          processedCelebrities.add(celebrity);
          sqlStatements.add(_generateInsertSQL(celebrity));
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
    print('📊 총 처리: ${extendedCelebrities.length}명');
    print('✅ 성공: $successCount명');
    print('❌ 실패: $failCount명');
    print('📈 성공률: ${(successCount / extendedCelebrities.length * 100).toStringAsFixed(1)}%');
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
        dataSource: 'extended_celebrity_calculated',
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

  static String _generateInsertSQL(CelebritySaju celebrity) {
    final escapedName = celebrity.name.replaceAll("'", "''");
    final escapedNameEn = celebrity.nameEn.replaceAll("'", "''");
    final escapedSajuString = celebrity.sajuString.replaceAll("'", "''");
    final fullSajuDataJson = json.encode(celebrity.fullSajuData).replaceAll("'", "''");

    return """INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  '${celebrity.id}', '$escapedName', '$escapedNameEn', '${celebrity.birthDate}', '${celebrity.birthTime}',
  '${celebrity.gender}', '${celebrity.birthPlace}', '${celebrity.category}', '${celebrity.agency}',
  '${celebrity.yearPillar}', '${celebrity.monthPillar}', '${celebrity.dayPillar}', '${celebrity.hourPillar}',
  '$escapedSajuString', ${celebrity.woodCount}, ${celebrity.fireCount}, ${celebrity.earthCount},
  ${celebrity.metalCount}, ${celebrity.waterCount},
  '$fullSajuDataJson'::jsonb, '${celebrity.dataSource}', NOW(), NOW()
);""";
  }

  static Future<void> _saveResults(
    List<CelebritySaju> celebrities, 
    List<String> sqlStatements,
  ) async {
    try {
      // JSON 파일로 결과 저장
      final jsonFile = File('celebrity_saju_results_extended.json');
      final jsonData = celebrities.map((c) => c.toJson()).toList();
      await jsonFile.writeAsString(json.encode(jsonData));
      print('✅ JSON 파일 저장: ${jsonFile.path}');

      // SQL 파일로 결과 저장
      final sqlFile = File('celebrity_saju_insert_extended.sql');
      final sqlContent = [
        '-- 추가 유명인사 사주 데이터 삽입 SQL',
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
  await ExtendedCelebritySajuProcessor.processAllCelebrities();
}