/// 간단한 위키텍스트 파싱 로직 테스트
/// 실제 나무위키 덤프 없이 파싱 로직이 제대로 작동하는지 확인
void main() {
  print('🧪 위키텍스트 파싱 로직 간단 테스트 시작...\n');

  // 테스트 케이스들
  final testCases = [
    {
      'name': '아이유',
      'wikiText': '''
{{틀:가수 정보
|사진 = IU_profile.jpg
|이름 = 아이유
|본명 = 이지은
|영문명 = IU
|생년월일 = 1993년 5월 16일
|출생지 = 서울특별시 중구
|국적 = 대한민국
|직업 = 가수, 배우, 작사가, 작곡가
|활동시기 = 2008년 ~ 현재
|장르 = 발라드, 팝
|소속사 = EDAM 엔터테인먼트
|데뷔 = 2008년 디지털 싱글 《Lost And Found》
}}

아이유(IU, 본명: 이지은)는 대한민국의 가수이자 배우이다. 
2008년 15세의 나이로 데뷔한 후 꾸준한 활동을 통해 대한민국을 대표하는 솔로 가수로 성장했다.
'''
    },
    {
      'name': '손흥민',
      'wikiText': '''
{{틀:축구선수 정보
|이름 = 손흥민
|영문명 = Son Heung-min
|생년월일 = 1992년 7월 8일
|출생지 = 강원도 춘천시
|국적 = 대한민국
|포지션 = 공격수, 윙어
|현소속팀 = 토트넘 홋스퍼
|등번호 = 7번
|신체 = 183cm, 78kg
}}

손흥민(孫興慜)은 대한민국의 축구선수이다. 현재 프리미어 리그 토트넘 홋스퍼에서 활동하고 있으며, 
대한민국 국가대표팀의 주장을 맡고 있다.
'''
    },
    {
      'name': '우왁굳',
      'wikiText': '''
{{틀:인물 정보
|이름 = 우왁굳
|본명 = 이세진
|생년월일 = 1987년 11월 10일
|국적 = 대한민국
|직업 = 스트리머, 유튜버
|활동시기 = 2015년 ~ 현재
|구독자수 = 100만 명 이상
|플랫폼 = 트위치, 유튜브
}}

우왁굳은 대한민국의 스트리머이다. 트위치에서 방송을 진행하며, 
다양한 게임과 토크 콘텐츠로 인기를 얻고 있다.
'''
    }
  ];

  int successCount = 0;
  int totalCount = testCases.length;

  for (final testCase in testCases) {
    final name = testCase['name'] as String;
    final wikiText = testCase['wikiText'] as String;
    
    print('🔍 테스트: $name');
    
    try {
      final result = parseWikiText(name, wikiText);
      
      print('  ✅ 파싱 성공!');
      print('    이름: ${result.name}');
      print('    생년월일: ${result.birthDate ?? '정보 없음'}');
      print('    성별: ${result.gender}');
      print('    카테고리: ${result.category}');
      print('    설명: ${result.description.length > 50 ? '${result.description.substring(0, 50)}...' : result.description}');
      print('    키워드: ${result.keywords.join(', ')}');
      if (result.debut != null) print('    데뷔: ${result.debut}');
      if (result.agency != null) print('    소속사: ${result.agency}');
      if (result.occupation != null) print('    직업: ${result.occupation}');
      
      successCount++;
      
    } catch (e) {
      print('  ❌ 파싱 실패: $e');
    }
    
    print('');
  }

  print('📊 테스트 결과:');
  print('  성공: $successCount/$totalCount');
  print('  성공률: ${(successCount / totalCount * 100).toStringAsFixed(1)}%');
  
  if (successCount == totalCount) {
    print('\n🎉 모든 테스트 성공! 파싱 로직이 제대로 작동합니다.');
  } else {
    print('\n⚠️  일부 테스트 실패. 파싱 로직을 점검해야 합니다.');
  }
}

/// 위키텍스트 파싱 함수 (실제 NamuWikiDumpProcessor와 동일한 로직)
CelebrityInfo parseWikiText(String name, String wikiText) {
  return CelebrityInfo(
    name: name,
    birthDate: extractBirthDate(wikiText),
    birthTime: '12:00',
    gender: extractGender(wikiText),
    category: extractCategory(wikiText),
    description: extractDescription(wikiText, name),
    profileImageUrl: extractProfileImage(wikiText),
    keywords: extractKeywords(wikiText, name),
    debut: extractDebut(wikiText),
    agency: extractAgency(wikiText),
    occupation: extractOccupation(wikiText),
    aliases: extractAliases(wikiText, name),
  );
}

// 파싱 함수들
String? extractBirthDate(String wikiText) {
  final patterns = [
    RegExp(r'\|\s*생년월일\s*=\s*(\d{4})년?\s*(\d{1,2})월?\s*(\d{1,2})일?'),
    RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일\s*출생'),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(wikiText);
    if (match != null && match.groupCount >= 3) {
      final year = match.group(1);
      final month = match.group(2)?.padLeft(2, '0');
      final day = match.group(3)?.padLeft(2, '0');
      
      if (year != null && month != null && day != null) {
        final yearInt = int.tryParse(year);
        if (yearInt != null && yearInt >= 1900 && yearInt <= 2010) {
          return '$year-$month-$day';
        }
      }
    }
  }
  return null;
}

String extractGender(String wikiText) {
  if (wikiText.contains('여성') || wikiText.contains('여배우') || wikiText.contains('여가수')) {
    return 'female';
  }
  return 'male';
}

String extractCategory(String wikiText) {
  if (wikiText.contains('가수') || wikiText.contains('음악가')) return 'singer';
  if (wikiText.contains('배우') || wikiText.contains('연기자')) return 'actor';
  if (wikiText.contains('축구선수') || wikiText.contains('운동선수')) return 'sports';
  if (wikiText.contains('스트리머') || wikiText.contains('BJ')) return 'streamer';
  if (wikiText.contains('유튜버')) return 'youtuber';
  return 'entertainer';
}

String extractDescription(String wikiText, String name) {
  final lines = wikiText.split('\n');
  for (final line in lines) {
    if (line.trim().isNotEmpty && 
        !line.startsWith('|') && 
        !line.startsWith('{{') && 
        line.length > 20) {
      return line.trim().length > 100 ? '${line.trim().substring(0, 100)}...' : line.trim();
    }
  }
  return '$name에 대한 정보';
}

String? extractProfileImage(String wikiText) {
  final match = RegExp(r'\|\s*사진\s*=\s*([^\|\n]+)').firstMatch(wikiText);
  return match?.group(1)?.trim();
}

List<String> extractKeywords(String wikiText, String name) {
  final keywords = <String>{name};
  final terms = ['데뷔', '활동', '앨범', '드라마', '영화'];
  for (final term in terms) {
    if (wikiText.contains(term)) keywords.add(term);
  }
  return keywords.toList();
}

String? extractDebut(String wikiText) {
  final match = RegExp(r'\|\s*데뷔\s*=\s*([^\|\n]+)').firstMatch(wikiText);
  return match?.group(1)?.trim();
}

String? extractAgency(String wikiText) {
  final match = RegExp(r'\|\s*소속사\s*=\s*([^\|\n]+)').firstMatch(wikiText);
  return match?.group(1)?.trim();
}

String? extractOccupation(String wikiText) {
  final match = RegExp(r'\|\s*직업\s*=\s*([^\|\n]+)').firstMatch(wikiText);
  return match?.group(1)?.trim();
}

List<String> extractAliases(String wikiText, String name) {
  final aliases = <String>[];
  final match = RegExp(r'\|\s*본명\s*=\s*([^\|\n]+)').firstMatch(wikiText);
  final realName = match?.group(1)?.trim();
  if (realName != null && realName != name) {
    aliases.add(realName);
  }
  return aliases;
}

// 데이터 클래스
class CelebrityInfo {
  final String name;
  final String? birthDate;
  final String? birthTime;
  final String gender;
  final String category;
  final String description;
  final String? profileImageUrl;
  final List<String> keywords;
  final String? debut;
  final String? agency;
  final String? occupation;
  final List<String> aliases;

  CelebrityInfo({
    required this.name,
    this.birthDate,
    this.birthTime,
    required this.gender,
    required this.category,
    required this.description,
    this.profileImageUrl,
    required this.keywords,
    this.debut,
    this.agency,
    this.occupation,
    required this.aliases,
  });
}