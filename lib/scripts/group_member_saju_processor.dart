import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

class GroupMemberSajuProcessor {
  // 그룹 멤버들의 개별 데이터 (실제 생년월일 포함)
  static final List<Map<String, dynamic>> groupMembers = [
    // BTS 멤버들
    {'id': 'bts_rm', 'name': 'RM (김남준)', 'name_en': 'RM (Kim Namjoon)', 'category': 'singer', 'gender': 'male', 'birth_date': '1994-09-12', 'birth_time': '12:00', 'group': 'BTS'},
    {'id': 'bts_jin', 'name': '진 (김석진)', 'name_en': 'Jin (Kim Seokjin)', 'category': 'singer', 'gender': 'male', 'birth_date': '1992-12-04', 'birth_time': '12:00', 'group': 'BTS'},
    {'id': 'bts_suga', 'name': '슈가 (민윤기)', 'name_en': 'Suga (Min Yoongi)', 'category': 'singer', 'gender': 'male', 'birth_date': '1993-03-09', 'birth_time': '12:00', 'group': 'BTS'},
    {'id': 'bts_jhope', 'name': '제이홉 (정호석)', 'name_en': 'J-Hope (Jung Hoseok)', 'category': 'singer', 'gender': 'male', 'birth_date': '1994-02-18', 'birth_time': '12:00', 'group': 'BTS'},
    {'id': 'bts_jimin', 'name': '지민 (박지민)', 'name_en': 'Jimin (Park Jimin)', 'category': 'singer', 'gender': 'male', 'birth_date': '1995-10-13', 'birth_time': '12:00', 'group': 'BTS'},
    {'id': 'bts_v', 'name': '뷔 (김태형)', 'name_en': 'V (Kim Taehyung)', 'category': 'singer', 'gender': 'male', 'birth_date': '1995-12-30', 'birth_time': '12:00', 'group': 'BTS'},
    {'id': 'bts_jungkook', 'name': '정국 (전정국)', 'name_en': 'Jungkook (Jeon Jungkook)', 'category': 'singer', 'gender': 'male', 'birth_date': '1997-09-01', 'birth_time': '12:00', 'group': 'BTS'},

    // 블랙핑크 멤버들
    {'id': 'bp_jisoo', 'name': '지수 (김지수)', 'name_en': 'Jisoo (Kim Jisoo)', 'category': 'singer', 'gender': 'female', 'birth_date': '1995-01-03', 'birth_time': '12:00', 'group': 'BLACKPINK'},
    {'id': 'bp_jennie', 'name': '제니 (김제니)', 'name_en': 'Jennie (Kim Jennie)', 'category': 'singer', 'gender': 'female', 'birth_date': '1996-01-16', 'birth_time': '12:00', 'group': 'BLACKPINK'},
    {'id': 'bp_rose', 'name': '로제 (박채영)', 'name_en': 'Rosé (Park Chaeyoung)', 'category': 'singer', 'gender': 'female', 'birth_date': '1997-02-11', 'birth_time': '12:00', 'group': 'BLACKPINK'},
    {'id': 'bp_lisa', 'name': '리사 (라리사)', 'name_en': 'Lisa (Lalisa Manoban)', 'category': 'singer', 'gender': 'female', 'birth_date': '1997-03-27', 'birth_time': '12:00', 'group': 'BLACKPINK'},

    // 트와이스 멤버들 (대표적인 몇명)
    {'id': 'tw_nayeon', 'name': '나연 (임나연)', 'name_en': 'Nayeon (Im Nayeon)', 'category': 'singer', 'gender': 'female', 'birth_date': '1995-09-22', 'birth_time': '12:00', 'group': 'TWICE'},
    {'id': 'tw_sana', 'name': '사나 (미나토자키 사나)', 'name_en': 'Sana (Minatozaki Sana)', 'category': 'singer', 'gender': 'female', 'birth_date': '1996-12-29', 'birth_time': '12:00', 'group': 'TWICE'},
    {'id': 'tw_tzuyu', 'name': '쯔위 (저우쯔위)', 'name_en': 'Tzuyu (Chou Tzuyu)', 'category': 'singer', 'gender': 'female', 'birth_date': '1999-06-14', 'birth_time': '12:00', 'group': 'TWICE'},

    // 세븐틴 멤버들 (대표적인 몇명)
    {'id': 'svt_scoups', 'name': '에스쿱스 (최승철)', 'name_en': 'S.Coups (Choi Seungcheol)', 'category': 'singer', 'gender': 'male', 'birth_date': '1995-08-08', 'birth_time': '12:00', 'group': 'SEVENTEEN'},
    {'id': 'svt_jeonghan', 'name': '정한 (윤정한)', 'name_en': 'Jeonghan (Yoon Jeonghan)', 'category': 'singer', 'gender': 'male', 'birth_date': '1995-10-04', 'birth_time': '12:00', 'group': 'SEVENTEEN'},
    {'id': 'svt_mingyu', 'name': '민규 (김민규)', 'name_en': 'Mingyu (Kim Mingyu)', 'category': 'singer', 'gender': 'male', 'birth_date': '1997-04-06', 'birth_time': '12:00', 'group': 'SEVENTEEN'},

    // 아이브 멤버들
    {'id': 'ive_yujin', 'name': '유진 (안유진)', 'name_en': 'Yujin (An Yujin)', 'category': 'singer', 'gender': 'female', 'birth_date': '2003-09-01', 'birth_time': '12:00', 'group': 'IVE'},
    {'id': 'ive_wonyoung', 'name': '원영 (장원영)', 'name_en': 'Wonyoung (Jang Wonyoung)', 'category': 'singer', 'gender': 'female', 'birth_date': '2004-08-31', 'birth_time': '12:00', 'group': 'IVE'},

    // 뉴진스 멤버들
    {'id': 'nj_minji', 'name': '민지 (김민지)', 'name_en': 'Minji (Kim Minji)', 'category': 'singer', 'gender': 'female', 'birth_date': '2004-05-07', 'birth_time': '12:00', 'group': 'NewJeans'},
    {'id': 'nj_hanni', 'name': '하니 (팜하니)', 'name_en': 'Hanni (Pham Hanni)', 'category': 'singer', 'gender': 'female', 'birth_date': '2004-10-06', 'birth_time': '12:00', 'group': 'NewJeans'},
    {'id': 'nj_danielle', 'name': '다니엘 (모 다니엘)', 'name_en': 'Danielle (Mo Danielle)', 'category': 'singer', 'gender': 'female', 'birth_date': '2005-04-11', 'birth_time': '12:00', 'group': 'NewJeans'},

    // 레드벨벳 멤버들
    {'id': 'rv_irene', 'name': '아이린 (배주현)', 'name_en': 'Irene (Bae Joohyun)', 'category': 'singer', 'gender': 'female', 'birth_date': '1991-03-29', 'birth_time': '12:00', 'group': 'Red Velvet'},
    {'id': 'rv_seulgi', 'name': '슬기 (강슬기)', 'name_en': 'Seulgi (Kang Seulgi)', 'category': 'singer', 'gender': 'female', 'birth_date': '1994-02-10', 'birth_time': '12:00', 'group': 'Red Velvet'},
    {'id': 'rv_joy', 'name': '조이 (박수영)', 'name_en': 'Joy (Park Sooyoung)', 'category': 'singer', 'gender': 'female', 'birth_date': '1996-09-03', 'birth_time': '12:00', 'group': 'Red Velvet'},

    // 엑소 멤버들 (대표적인 몇명)
    {'id': 'exo_suho', 'name': '수호 (김준면)', 'name_en': 'Suho (Kim Junmyeon)', 'category': 'singer', 'gender': 'male', 'birth_date': '1991-05-22', 'birth_time': '12:00', 'group': 'EXO'},
    {'id': 'exo_baekhyun', 'name': '백현 (변백현)', 'name_en': 'Baekhyun (Byun Baekhyun)', 'category': 'singer', 'gender': 'male', 'birth_date': '1992-05-06', 'birth_time': '12:00', 'group': 'EXO'},
    {'id': 'exo_chanyeol', 'name': '찬열 (박찬열)', 'name_en': 'Chanyeol (Park Chanyeol)', 'category': 'singer', 'gender': 'male', 'birth_date': '1992-11-27', 'birth_time': '12:00', 'group': 'EXO'},
  ];

  static Future<void> processAllMembers() async {
    print('🚀 그룹 멤버 개별 사주 계산 시작...');
    print('📊 총 ${groupMembers.length}명의 그룹 멤버 처리 예정');
    
    final List<CelebritySaju> processedCelebrities = [];
    final List<String> sqlStatements = [];
    
    int successCount = 0;
    int failCount = 0;

    for (final memberData in groupMembers) {
      try {
        final celebrity = await _processSingleMember(memberData);
        
        if (celebrity != null) {
          processedCelebrities.add(celebrity);
          sqlStatements.add(_generateInsertSQL(celebrity));
          successCount++;
          
          print('✅ ${celebrity.name} (${memberData['group']}) 완료: ${celebrity.sajuString}');
        } else {
          failCount++;
        }
      } catch (e) {
        print('❌ 오류 (${memberData['name']}): $e');
        failCount++;
      }
    }

    // 결과 저장
    await _saveResults(processedCelebrities, sqlStatements);
    
    print('\n🎉 그룹 멤버 처리 완료!');
    print('📊 총 처리: ${groupMembers.length}명');
    print('✅ 성공: $successCount명');
    print('❌ 실패: $failCount명');
    print('📈 성공률: ${(successCount / groupMembers.length * 100).toStringAsFixed(1)}%');
  }

  static Future<CelebritySaju?> _processSingleMember(Map<String, dynamic> data) async {
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
        agency: data['group'] as String, // 그룹명을 agency에 저장
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
        dataSource: 'group_member_calculated',
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
    final escapedAgency = celebrity.agency.replaceAll("'", "''");
    final escapedSajuString = celebrity.sajuString.replaceAll("'", "''");
    final fullSajuDataJson = json.encode(celebrity.fullSajuData).replaceAll("'", "''");

    return """INSERT INTO public.celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  '${celebrity.id}', '$escapedName', '$escapedNameEn', '${celebrity.birthDate}', '${celebrity.birthTime}',
  '${celebrity.gender}', '${celebrity.birthPlace}', '${celebrity.category}', '$escapedAgency',
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
      final jsonFile = File('celebrity_group_members_saju.json');
      final jsonData = celebrities.map((c) => c.toJson()).toList();
      await jsonFile.writeAsString(json.encode(jsonData));
      print('✅ JSON 파일 저장: ${jsonFile.path}');

      // SQL 파일로 결과 저장
      final sqlFile = File('celebrity_group_members_insert.sql');
      final sqlContent = [
        '-- 그룹 멤버 개별 사주 데이터 삽입 SQL',
        '-- 총 ${celebrities.length}명의 그룹 멤버 데이터',
        '',
        ...sqlStatements,
      ].join('\n');
      
      await sqlFile.writeAsString(sqlContent);
      print('✅ SQL 파일 저장: ${sqlFile.path}');

      // 그룹별 통계
      final groupStats = <String, int>{};
      for (final celebrity in celebrities) {
        final group = celebrity.agency; // 그룹명이 agency에 저장됨
        groupStats[group] = (groupStats[group] ?? 0) + 1;
      }

      print('\n📊 그룹별 멤버 수:');
      groupStats.forEach((group, count) {
        print('   $group: $count명');
      });

    } catch (e) {
      print('❌ 파일 저장 오류: $e');
    }
  }
}

// 실행 스크립트
void main() async {
  await GroupMemberSajuProcessor.processAllMembers();
}