/// 가짜 나무위키 덤프를 만들고 전체 플로우를 테스트하는 스크립트
/// 실제 덤프 없이도 전체 시스템이 작동하는지 확인
void main() async {
  print('🧪 가짜 덤프 생성 및 전체 플로우 테스트 시작...\n');
  
  // 1. 가짜 덤프 데이터 생성
  await createFakeDumpData();
  
  // 2. 덤프 처리 로직 테스트  
  await testDumpProcessing();
  
  // 3. 데이터 변환 및 저장 시뮬레이션
  await simulateDataSaveProcess();
  
  print('\n🎉 전체 플로우 테스트 완료!');
}

/// 가짜 나무위키 덤프 데이터 생성
Future<void> createFakeDumpData() async {
  print('📝 가짜 덤프 데이터 생성 중...');
  
  // 연예인 목록에서 상위 10명 선택
  final topCelebrities = [
    {'name': '아이유', 'category': 'singer'},
    {'name': 'BTS', 'category': 'singer'},
    {'name': '손흥민', 'category': 'sports'},
    {'name': '우왁굳', 'category': 'streamer'},
    {'name': '박서준', 'category': 'actor'},
    {'name': '쯔양', 'category': 'youtuber'},
    {'name': '윤석열', 'category': 'politician'},
    {'name': '이재용', 'category': 'business'},
    {'name': '유재석', 'category': 'comedian'},
    {'name': '김연경', 'category': 'sports'},
  ];
  
  final fakeWikiTexts = <String, String>{};
  
  for (final celebrity in topCelebrities) {
    final name = celebrity['name']!;
    final category = celebrity['category']!;
    
    fakeWikiTexts[name] = generateFakeWikiText(name, category);
  }
  
  print('  ✅ ${fakeWikiTexts.length}명의 가짜 덤프 데이터 생성 완료');
  
  // 전역 변수로 저장 (실제로는 파일로 저장)
  _fakeWikiTexts = fakeWikiTexts;
}

/// 가짜 위키텍스트 생성
String generateFakeWikiText(String name, String category) {
  final birthDate = _generateRandomBirthDate();
  final gender = _getRandomGender();
  final occupation = _getCategoryOccupation(category);
  final debut = _generateRandomDebut();
  final agency = _generateRandomAgency(category);
  
  return '''
{{틀:인물 정보
|사진 = ${name}_profile.jpg
|이름 = $name
|본명 = ${name}의 본명
|영문명 = ${name.toUpperCase()}
|생년월일 = ${birthDate['formatted']}
|출생지 = 서울특별시
|국적 = 대한민국
|직업 = $occupation
|활동시기 = $debut ~ 현재
|장르 = 다양함
|소속사 = $agency
|데뷔 = $debut
}}

$name는 대한민국의 ${occupation}이다. ${birthDate['formatted']}에 태어났으며, 
$debut에 데뷔하여 현재까지 활발한 활동을 이어가고 있다. 
대표적인 작품과 활동으로 많은 사랑을 받고 있으며, 특히 젊은 층에게 인기가 높다.
''';
}

Map<String, String> _generateRandomBirthDate() {
  final years = [1985, 1987, 1990, 1992, 1993, 1995, 1998];
  final months = [1, 3, 5, 7, 8, 10, 12];
  final days = [5, 10, 15, 16, 20, 25];
  
  final year = (years..shuffle()).first;
  final month = (months..shuffle()).first;
  final day = (days..shuffle()).first;
  
  return {
    'formatted': '${year}년 ${month}월 ${day}일',
    'iso': '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'
  };
}

String _getRandomGender() {
  return ['male', 'female'][DateTime.now().millisecondsSinceEpoch % 2];
}

String _getCategoryOccupation(String category) {
  switch (category) {
    case 'singer': return '가수, 음악가';
    case 'actor': return '배우, 연기자';
    case 'sports': return '운동선수';
    case 'streamer': return '스트리머, BJ';
    case 'youtuber': return '유튜버, 크리에이터';
    case 'politician': return '정치인';
    case 'business': return '기업인, CEO';
    case 'comedian': return '코미디언, 개그맨';
    default: return '연예인';
  }
}

String _generateRandomDebut() {
  final years = [2005, 2008, 2010, 2012, 2015, 2018, 2020];
  final year = (years..shuffle()).first;
  return '${year}년';
}

String _generateRandomAgency(String category) {
  final agencies = {
    'singer': ['SM엔터테인먼트', 'YG엔터테인먼트', 'JYP엔터테인먼트', 'EDAM엔터테인먼트'],
    'actor': ['넷마블', '킹콩 by 스타십', '매니지먼트 숲', 'BH엔터테인먼트'],
    'sports': ['대한축구협회', '프로배구연맹', '토트넘 홋스퍼', 'FC서울'],
    'streamer': ['샌드박스 네트워크', 'DIA TV', '아프리카TV', '트위치'],
    'youtuber': ['샌드박스 네트워크', 'CJ ENM', '1인 크리에이터', '독립'],
    'politician': ['더불어민주당', '국민의힘', '정의당', '무소속'],
    'business': ['삼성', 'LG', 'SK', '네이버'],
    'comedian': ['SM C&C', 'FNC엔터테인먼트', 'YG케이플러스', '무소속'],
  };
  
  final categoryAgencies = agencies[category] ?? ['소속사 미상'];
  return (categoryAgencies..shuffle()).first;
}

/// 덤프 처리 로직 테스트
Future<void> testDumpProcessing() async {
  print('\n🔄 덤프 처리 로직 테스트 중...');
  
  if (_fakeWikiTexts == null || _fakeWikiTexts!.isEmpty) {
    print('  ❌ 가짜 덤프 데이터가 없습니다.');
    return;
  }
  
  final results = <String, CelebrityInfo>{};
  
  for (final entry in _fakeWikiTexts!.entries) {
    final name = entry.key;
    final wikiText = entry.value;
    
    try {
      final info = parseWikiText(name, wikiText);
      results[name] = info;
      print('  ✅ $name: 파싱 성공');
    } catch (e) {
      print('  ❌ $name: 파싱 실패 - $e');
    }
  }
  
  print('  📊 파싱 결과: ${results.length}/${_fakeWikiTexts!.length} 성공');
  _parsedResults = results;
}

/// 데이터 저장 프로세스 시뮬레이션
Future<void> simulateDataSaveProcess() async {
  print('\n💾 데이터 저장 프로세스 시뮬레이션...');
  
  if (_parsedResults == null || _parsedResults!.isEmpty) {
    print('  ❌ 파싱된 데이터가 없습니다.');
    return;
  }
  
  print('  📝 celebrities 테이블에 저장될 데이터:');
  
  for (final entry in _parsedResults!.entries) {
    final name = entry.key;
    final info = entry.value;
    
    final dbRecord = {
      'name': info.name,
      'birth_date': info.birthDate,
      'birth_time': info.birthTime,
      'gender': info.gender,
      'category': info.category,
      'description': info.description,
      'keywords': info.keywords,
      'additional_info': {
        'debut': info.debut,
        'agency': info.agency,
        'occupation': info.occupation,
        'aliases': info.aliases,
        'processed_from_dump': true,
        'processed_at': DateTime.now().toIso8601String(),
      }
    };
    
    print('    ✅ $name:');
    print('      - 생년월일: ${info.birthDate ?? '정보없음'}');
    print('      - 카테고리: ${info.category}');
    print('      - 데뷔: ${info.debut ?? '정보없음'}');
    print('      - 소속사: ${info.agency ?? '정보없음'}');
  }
  
  print('  🎯 결과: ${_parsedResults!.length}명의 연예인 정보를 데이터베이스에 저장할 준비 완료');
}

// 전역 변수 (실제로는 클래스나 파일로 관리)
Map<String, String>? _fakeWikiTexts;
Map<String, CelebrityInfo>? _parsedResults;

/// 위키텍스트 파싱 함수 (이전 테스트와 동일)
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

// 파싱 함수들 (이전과 동일)
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
  if (wikiText.contains('정치인')) return 'politician';
  if (wikiText.contains('기업인') || wikiText.contains('CEO')) return 'business_leader';
  if (wikiText.contains('코미디언') || wikiText.contains('개그맨')) return 'entertainer';
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
  if (realName != null && realName != name && !realName.contains('본명')) {
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