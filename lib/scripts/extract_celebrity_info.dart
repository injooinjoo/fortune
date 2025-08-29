import 'dart:convert';
import 'dart:io';

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

/// 나무위키 텍스트에서 생년월일 추출
String extractBirthDate(String wikiText) {
  // 다양한 생년월일 패턴 매칭
  final patterns = [
    r'생년월일\s*=\s*([^\n\|]+)',
    r'출생\s*=\s*([^\n\|]+)',
    r'태어난 날\s*=\s*([^\n\|]+)',
    r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일',
  ];

  for (final pattern in patterns) {
    final regex = RegExp(pattern, multiLine: true);
    final match = regex.firstMatch(wikiText);
    if (match != null) {
      String extracted = match.group(1) ?? match.group(0) ?? '';
      
      // 날짜 형식 정규화
      final dateRegex = RegExp(r'(\d{4})년?\s*(\d{1,2})월?\s*(\d{1,2})일?');
      final dateMatch = dateRegex.firstMatch(extracted);
      if (dateMatch != null) {
        final year = dateMatch.group(1)!;
        final month = dateMatch.group(2)!.padLeft(2, '0');
        final day = dateMatch.group(3)!.padLeft(2, '0');
        return '$year-$month-$day';
      }
    }
  }
  return '';
}

/// 성별 추출
String extractGender(String wikiText) {
  final patterns = [
    r'성별\s*=\s*([^\n\|]+)',
    r'젠더\s*=\s*([^\n\|]+)',
  ];

  for (final pattern in patterns) {
    final regex = RegExp(pattern, multiLine: true);
    final match = regex.firstMatch(wikiText);
    if (match != null) {
      String gender = match.group(1)!.trim();
      if (gender.contains('남') || gender.contains('Male')) return 'M';
      if (gender.contains('여') || gender.contains('Female')) return 'F';
    }
  }
  
  // 추가 패턴으로 성별 추론 (이름 패턴 등)
  return '';
}

/// 출생지 추출
String extractBirthPlace(String wikiText) {
  final patterns = [
    r'출생지\s*=\s*([^\n\|]+)',
    r'출생 장소\s*=\s*([^\n\|]+)',
    r'태어난 곳\s*=\s*([^\n\|]+)',
  ];

  for (final pattern in patterns) {
    final regex = RegExp(pattern, multiLine: true);
    final match = regex.firstMatch(wikiText);
    if (match != null) {
      return match.group(1)!.trim();
    }
  }
  return '';
}

/// 소속사 추출  
String extractAgency(String wikiText) {
  final patterns = [
    r'소속사\s*=\s*([^\n\|]+)',
    r'소속\s*=\s*([^\n\|]+)',
    r'레이블\s*=\s*([^\n\|]+)',
  ];

  for (final pattern in patterns) {
    final regex = RegExp(pattern, multiLine: true);
    final match = regex.firstMatch(wikiText);
    if (match != null) {
      return match.group(1)!.trim();
    }
  }
  return '';
}

/// 전체 위키 텍스트 파싱
CelebrityInfo parseWikiText(String name, String wikiText) {
  return CelebrityInfo(
    name: name,
    birthDate: extractBirthDate(wikiText),
    birthTime: '12:00', // 기본값, 실제 데이터가 있으면 추출
    gender: extractGender(wikiText),
    birthPlace: extractBirthPlace(wikiText),
    agency: extractAgency(wikiText),
    rawData: {'wiki_text_length': wikiText.length},
  );
}

/// 샘플 데이터로 테스트
void main() async {
  // 대표적인 유명인사들의 샘플 위키 텍스트 (실제로는 덤프에서 추출)
  final sampleData = {
    '이재용': '''
{{틀:인물 정보
|이름 = 이재용
|생년월일 = 1968년 6월 23일 (55세)
|성별 = 남성
|출생지 = 서울특별시
|소속 = 삼성전자
|직업 = 기업인
}}
''',
    '임영웅': '''
{{틀:인물 정보
|이름 = 임영웅
|생년월일 = 1991년 6월 16일 (32세)
|성별 = 남성
|출생지 = 경상북도 포항시
|소속 = 물고기뮤직
|직업 = 가수
}}
''',
    '이정재': '''
{{틀:인물 정보
|이름 = 이정재
|생년월일 = 1973년 3월 15일 (50세)
|성별 = 남성
|출생지 = 서울특별시
|소속 = 아티스트컴퍼니
|직업 = 배우
}}
''',
    '유재석': '''
{{틀:인물 정보
|이름 = 유재석
|생년월일 = 1972년 8월 14일 (51세)
|성별 = 남성
|출생지 = 서울특별시 강북구
|소속 = FNC엔터테인먼트
|직업 = 개그맨
}}
'''
  };

  print('🔍 유명인사 정보 추출 테스트 시작...\n');

  final extractedData = <Map<String, dynamic>>[];

  for (final entry in sampleData.entries) {
    final name = entry.key;
    final wikiText = entry.value;
    
    print('📝 처리 중: $name');
    final info = parseWikiText(name, wikiText);
    
    print('  - 생년월일: ${info.birthDate}');
    print('  - 성별: ${info.gender}');
    print('  - 출생지: ${info.birthPlace}');
    print('  - 소속: ${info.agency}');
    
    extractedData.add(info.toJson());
    print('  ✅ 추출 완료\n');
  }

  // JSON 파일로 저장
  final outputFile = File('extracted_celebrity_data.json');
  await outputFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(extractedData)
  );
  
  print('💾 추출된 데이터가 extracted_celebrity_data.json 파일로 저장되었습니다.');
  print('📊 총 ${extractedData.length}명의 유명인사 정보를 추출했습니다.');
  
  // 추출 성공률 계산
  int successCount = extractedData.where((data) => 
    data['birth_date'].isNotEmpty && data['gender'].isNotEmpty
  ).length;
  
  print('🎯 추출 성공률: ${(successCount / extractedData.length * 100).toStringAsFixed(1)}%');
}