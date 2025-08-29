import 'dart:convert';
import 'dart:io';
import '../services/saju_calculation_service.dart';

class CelebrityInfo {
  final String name;
  final String birthDate;
  final String birthTime;
  final String gender;
  final String birthPlace;
  final String agency;
  final String category;
  final Map<String, dynamic> rawData;

  CelebrityInfo({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.gender,
    this.birthPlace = '',
    this.agency = '',
    this.category = '',
    this.rawData = const {},
  });

  factory CelebrityInfo.fromJson(Map<String, dynamic> json) {
    return CelebrityInfo(
      name: json['name'] ?? '',
      birthDate: json['birth_date'] ?? '',
      birthTime: json['birth_time'] ?? '12:00',
      gender: json['gender'] ?? '',
      birthPlace: json['birth_place'] ?? '',
      agency: json['agency'] ?? '',
      category: json['category'] ?? '',
      rawData: json['raw_data'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'birth_date': birthDate,
    'birth_time': birthTime,
    'gender': gender,
    'birth_place': birthPlace,
    'agency': agency,
    'category': category,
    'raw_data': rawData,
  };
}

class CelebritySajuData {
  final CelebrityInfo info;
  final Map<String, dynamic> sajuData;
  final String sajuString;
  final Map<String, int> elementCounts;

  CelebritySajuData({
    required this.info,
    required this.sajuData,
    required this.sajuString,
    required this.elementCounts,
  });

  Map<String, dynamic> toSupabaseJson() {
    return {
      // 기본 정보
      'name': info.name,
      'name_en': _generateNameEn(info.name),
      'birth_date': info.birthDate,
      'birth_time': info.birthTime,
      'gender': info.gender,
      'birth_place': info.birthPlace,
      'category': info.category,
      'agency': info.agency,
      
      // 사주 데이터 (실제 구조에 맞게 수정)
      'year_pillar': _getPillarDisplay(sajuData['year']),
      'month_pillar': _getPillarDisplay(sajuData['month']),
      'day_pillar': _getPillarDisplay(sajuData['day']),
      'hour_pillar': _getPillarDisplay(sajuData['hour']),
      
      // 사주 문자열 (갑자, 을축 등)
      'saju_string': sajuString,
      
      // 오행 개수
      'wood_count': elementCounts['목'] ?? 0,
      'fire_count': elementCounts['화'] ?? 0,
      'earth_count': elementCounts['토'] ?? 0,
      'metal_count': elementCounts['금'] ?? 0,
      'water_count': elementCounts['수'] ?? 0,
      
      // 추가 메타데이터
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'data_source': 'namuwiki_extraction',
      
      // JSON 형태로 저장할 전체 사주 데이터
      'full_saju_data': sajuData,
    };
  }

  String _getPillarDisplay(Map<String, dynamic>? pillar) {
    if (pillar == null) return '';
    final stem = pillar['stem'] ?? '';
    final branch = pillar['branch'] ?? '';
    return '$stem$branch';
  }

  String _generateNameEn(String koreanName) {
    // 간단한 한글 -> 영어 변환 (실제로는 더 정교한 변환 필요)
    final nameMap = {
      '이효리': 'Lee Hyo-ri',
      '박진영': 'Park Jin-young',
      '송혜교': 'Song Hye-kyo',
      '현빈': 'Hyun Bin',
      '최태원': 'Choi Tae-won',
      '구광모': 'Koo Kwang-mo',
      '이재명': 'Lee Jae-myung',
      '침착맨': 'ChimChakMan',
      '손흥민': 'Son Heung-min',
      '이재용': 'Lee Jae-yong',
      '임영웅': 'Lim Young-woong',
      '이정재': 'Lee Jung-jae',
      '유재석': 'Yoo Jae-suk',
    };
    
    return nameMap[koreanName] ?? koreanName;
  }
}

/// 사주 계산 및 DB 저장 프로세서
class CelebritySajuProcessor {
  
  /// JSON 파일에서 유명인사 데이터 로드
  static Future<List<CelebrityInfo>> loadCelebrityData(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('파일을 찾을 수 없습니다: $filePath');
    }
    
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString) as List;
    
    return jsonData.map((json) => CelebrityInfo.fromJson(json)).toList();
  }

  /// 유명인사 사주 계산
  static CelebritySajuData calculateCelebritySaju(CelebrityInfo celebrity) {
    // 생년월일 파싱
    final birthDateParts = celebrity.birthDate.split('-');
    final year = int.parse(birthDateParts[0]);
    final month = int.parse(birthDateParts[1]);
    final day = int.parse(birthDateParts[2]);
    
    final birthDate = DateTime(year, month, day);
    
    // 사주 계산
    final sajuData = SajuCalculationService.calculateSaju(
      birthDate: birthDate,
      birthTime: celebrity.birthTime,
    );
    
    // 사주 문자열 생성 (갑자을축병인정묘 형태)
    final sajuString = _generateSajuString(sajuData);
    
    // 오행 개수 계산
    final elementCounts = _countElements(sajuData);
    
    return CelebritySajuData(
      info: celebrity,
      sajuData: sajuData,
      sajuString: sajuString,
      elementCounts: elementCounts,
    );
  }

  /// 사주를 문자열로 변환
  static String _generateSajuString(Map<String, dynamic> sajuData) {
    final parts = <String>[];
    
    // 실제 데이터 구조에 맞게 수정
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

  /// 오행 개수 계산
  static Map<String, int> _countElements(Map<String, dynamic> sajuData) {
    final counts = <String, int>{
      '목': 0, '화': 0, '토': 0, '금': 0, '수': 0
    };
    
    final pillars = ['year', 'month', 'day', 'hour'];
    
    for (final pillar in pillars) {
      final pillarData = sajuData[pillar];
      if (pillarData != null) {
        final stemElement = pillarData['element']; // 천간 오행
        final branchElement = pillarData['branchElement']; // 지지 오행
        
        if (stemElement != null && counts.containsKey(stemElement)) {
          counts[stemElement] = counts[stemElement]! + 1;
        }
        if (branchElement != null && counts.containsKey(branchElement)) {
          counts[branchElement] = counts[branchElement]! + 1;
        }
      }
    }
    
    return counts;
  }

  /// Supabase SQL 생성
  static String generateSupabaseInsertSQL(List<CelebritySajuData> celebrityData) {
    final buffer = StringBuffer();
    buffer.writeln('-- 유명인사 사주 데이터 삽입 SQL');
    buffer.writeln('-- 총 ${celebrityData.length}명의 데이터');
    buffer.writeln('');
    
    buffer.writeln('INSERT INTO celebrities (');
    buffer.writeln('  name, name_en, birth_date, birth_time, gender,');
    buffer.writeln('  birth_place, category, agency,');
    buffer.writeln('  year_pillar, month_pillar, day_pillar, hour_pillar,');
    buffer.writeln('  saju_string,');
    buffer.writeln('  wood_count, fire_count, earth_count, metal_count, water_count,');
    buffer.writeln('  full_saju_data, data_source, created_at, updated_at');
    buffer.writeln(') VALUES');
    
    for (int i = 0; i < celebrityData.length; i++) {
      final data = celebrityData[i].toSupabaseJson();
      buffer.write('  (');
      buffer.write("'${data['name']}'");
      buffer.write(", '${data['name_en']}'");
      buffer.write(", '${data['birth_date']}'");
      buffer.write(", '${data['birth_time']}'");
      buffer.write(", '${data['gender']}'");
      buffer.write(", '${data['birth_place']}'");
      buffer.write(", '${data['category']}'");
      buffer.write(", '${data['agency']}'");
      buffer.write(", '${data['year_pillar'] ?? ''}'");
      buffer.write(", '${data['month_pillar'] ?? ''}'");
      buffer.write(", '${data['day_pillar'] ?? ''}'");
      buffer.write(", '${data['hour_pillar'] ?? ''}'");
      buffer.write(", '${data['saju_string']}'");
      buffer.write(", ${data['wood_count']}");
      buffer.write(", ${data['fire_count']}");
      buffer.write(", ${data['earth_count']}");
      buffer.write(", ${data['metal_count']}");
      buffer.write(", ${data['water_count']}");
      buffer.write(", '${jsonEncode(data['full_saju_data'])}'::jsonb");
      buffer.write(", '${data['data_source']}'");
      buffer.write(", '${data['created_at']}'");
      buffer.write(", '${data['updated_at']}'");
      buffer.write(')');
      
      if (i < celebrityData.length - 1) {
        buffer.writeln(',');
      } else {
        buffer.writeln(';');
      }
    }
    
    return buffer.toString();
  }
}

/// 메인 실행 함수
void main() async {
  print('🔮 유명인사 사주 계산 및 DB 저장 시스템 시작...\n');

  try {
    // 1. 유명인사 데이터 로드
    print('📂 유명인사 데이터 로드 중...');
    final celebrities = await CelebritySajuProcessor.loadCelebrityData(
      'expanded_celebrity_data.json'
    );
    print('✅ ${celebrities.length}명의 유명인사 데이터 로드 완료\n');

    // 2. 각 유명인사의 사주 계산
    print('🧮 사주 계산 중...');
    final celebritySajuData = <CelebritySajuData>[];
    
    for (int i = 0; i < celebrities.length; i++) {
      final celebrity = celebrities[i];
      print('  처리 중 (${i + 1}/${celebrities.length}): ${celebrity.name}');
      
      if (celebrity.birthDate.isNotEmpty && celebrity.gender.isNotEmpty) {
        try {
          final sajuData = CelebritySajuProcessor.calculateCelebritySaju(celebrity);
          celebritySajuData.add(sajuData);
          print('    ✅ 사주 계산 완료: ${sajuData.sajuString}');
        } catch (e) {
          print('    ❌ 사주 계산 실패: $e');
        }
      } else {
        print('    ⚠️  필수 정보 부족 (생년월일 또는 성별)');
      }
    }

    print('\n💾 결과 저장 중...');
    
    // 3. JSON 결과 저장
    final resultFile = File('celebrity_saju_results.json');
    final results = celebritySajuData.map((data) => data.toSupabaseJson()).toList();
    await resultFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(results)
    );
    print('✅ JSON 결과 저장: celebrity_saju_results.json');

    // 4. Supabase SQL 생성
    final sqlFile = File('celebrity_saju_insert.sql');
    final sql = CelebritySajuProcessor.generateSupabaseInsertSQL(celebritySajuData);
    await sqlFile.writeAsString(sql);
    print('✅ SQL 파일 생성: celebrity_saju_insert.sql');

    // 5. 통계 출력
    print('\n📊 처리 결과:');
    print('  - 총 처리 대상: ${celebrities.length}명');
    print('  - 사주 계산 성공: ${celebritySajuData.length}명');
    print('  - 성공률: ${(celebritySajuData.length / celebrities.length * 100).toStringAsFixed(1)}%');
    
    if (celebritySajuData.isNotEmpty) {
      // 오행 통계
      final totalElements = <String, int>{'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};
      for (final data in celebritySajuData) {
        data.elementCounts.forEach((element, count) {
          totalElements[element] = totalElements[element]! + count;
        });
      }
      
      print('\n🌿 오행 분포:');
      totalElements.forEach((element, count) {
        print('  - $element: $count개');
      });
    }

    print('\n🎯 다음 단계:');
    print('  1. celebrity_saju_insert.sql 파일을 Supabase에서 실행');
    print('  2. 앱에서 유명인사 운세 서비스 테스트');
    print('  3. 나머지 740명의 데이터도 처리');

  } catch (e, stackTrace) {
    print('❌ 오류 발생: $e');
    print('스택 트레이스: $stackTrace');
  }
}