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
  return '';
}

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

CelebrityInfo parseWikiText(String name, String wikiText, String category) {
  return CelebrityInfo(
    name: name,
    birthDate: extractBirthDate(wikiText),
    birthTime: '12:00',
    gender: extractGender(wikiText),
    birthPlace: extractBirthPlace(wikiText),
    agency: extractAgency(wikiText),
    category: category,
    rawData: {'wiki_text_length': wikiText.length},
  );
}

/// 확장된 샘플 데이터로 테스트 (750명 중 대표 인물들)
void main() async {
  // 각 카테고리에서 대표 인물들의 샘플 데이터
  final sampleData = {
    // 가수 (150명 중 상위 10명)
    '이효리': '''
{{틀:인물 정보
|이름 = 이효리
|생년월일 = 1979년 5월 10일 (44세)
|성별 = 여성
|출생지 = 경기도 성남시
|소속 = 핀네이션
|직업 = 가수, 배우
}}
''',
    '박진영': '''
{{틀:인물 정보
|이름 = 박진영
|생년월일 = 1972년 12월 13일 (51세)
|성별 = 남성
|출생지 = 서울특별시 강서구
|소속 = JYP엔터테인먼트
|직업 = 가수, 프로듀서
}}
''',
    '방탄소년단 RM': '''
{{틀:인물 정보
|이름 = 김남준
|예명 = RM
|생년월일 = 1994년 9월 12일 (29세)
|성별 = 남성
|출생지 = 경기도 고양시
|소속 = 빅히트뮤직
|직업 = 래퍼, 가수
}}
''',
    
    // 배우 (150명 중 상위)
    '송혜교': '''
{{틀:인물 정보
|이름 = 송혜교
|생년월일 = 1981년 11월 22일 (42세)
|성별 = 여성
|출생지 = 대구광역시
|소속 = UAA
|직업 = 배우
}}
''',
    '현빈': '''
{{틀:인물 정보
|이름 = 김태평
|예명 = 현빈
|생년월일 = 1982년 9월 25일 (41세)
|성별 = 남성
|출생지 = 서울특별시
|소속 = VAST엔터테인먼트
|직업 = 배우
}}
''',
    
    // 기업인 (100명 중 상위)
    '최태원': '''
{{틀:인물 정보
|이름 = 최태원
|생년월일 = 1960년 12월 3일 (63세)
|성별 = 남성
|출생지 = 서울특별시
|소속 = SK그룹
|직업 = 기업인
}}
''',
    '구광모': '''
{{틀:인물 정보
|이름 = 구광모
|생년월일 = 1969년 7월 6일 (54세)
|성별 = 남성
|출생지 = 서울특별시
|소속 = LG그룹
|직업 = 기업인
}}
''',
    
    // 정치인 (100명 중 상위)
    '이재명': '''
{{틀:인물 정보
|이름 = 이재명
|생년월일 = 1964년 12월 22일 (59세)
|성별 = 남성
|출생지 = 경기도 안동시
|소속 = 더불어민주당
|직업 = 정치인
}}
''',
    
    // 스트리머/유튜버 (150명 중 상위)
    '침착맨': '''
{{틀:인물 정보
|이름 = 정현수
|예명 = 침착맨
|생년월일 = 1995년 4월 15일 (28세)
|성별 = 남성
|출생지 = 경기도 안산시
|소속 = 샌드박스 네트워크
|직업 = 유튜버
}}
''',
    
    // 코미디언&운동선수 (100명 중 상위)
    '손흥민': '''
{{틀:인물 정보
|이름 = 손흥민
|생년월일 = 1992년 7월 8일 (31세)
|성별 = 남성
|출생지 = 강원도 춘천시
|소속 = 토트넘 홋스퍼
|직업 = 축구선수
}}
'''
  };

  print('🚀 확장된 유명인사 정보 추출 테스트 시작...\n');
  print('📋 처리 대상: 750명 중 대표 ${sampleData.length}명\n');

  final extractedData = <Map<String, dynamic>>[];
  int successCount = 0;

  for (final entry in sampleData.entries) {
    final name = entry.key;
    final wikiText = entry.value;
    
    String category = '';
    if (name.contains('RM') || name.contains('이효리') || name.contains('박진영')) {
      category = '가수';
    } else if (name.contains('송혜교') || name.contains('현빈')) {
      category = '배우';
    } else if (name.contains('최태원') || name.contains('구광모')) {
      category = '기업인';
    } else if (name.contains('이재명')) {
      category = '정치인';
    } else if (name.contains('침착맨')) {
      category = '스트리머/유튜버';
    } else if (name.contains('손흥민')) {
      category = '운동선수';
    }
    
    print('📝 처리 중: $name ($category)');
    final info = parseWikiText(name, wikiText, category);
    
    print('  - 생년월일: ${info.birthDate}');
    print('  - 성별: ${info.gender}');
    print('  - 출생지: ${info.birthPlace}');
    print('  - 소속: ${info.agency}');
    
    if (info.birthDate.isNotEmpty && info.gender.isNotEmpty) {
      successCount++;
      print('  ✅ 추출 완료');
    } else {
      print('  ⚠️  일부 정보 누락');
    }
    print('');
    
    extractedData.add(info.toJson());
  }

  // JSON 파일로 저장
  final outputFile = File('expanded_celebrity_data.json');
  await outputFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(extractedData)
  );
  
  print('💾 추출된 데이터가 expanded_celebrity_data.json 파일로 저장되었습니다.');
  print('📊 총 ${extractedData.length}명의 유명인사 정보를 처리했습니다.');
  print('🎯 추출 성공률: ${(successCount / extractedData.length * 100).toStringAsFixed(1)}%');
  print('');
  print('🔮 이제 이 데이터로 사주 운세를 생성할 수 있습니다!');
  print('   - 생년월일 ✅');
  print('   - 성별 ✅');
  print('   - 출생지 정보 ✅');
  print('   - 직업/소속 정보 ✅');
}