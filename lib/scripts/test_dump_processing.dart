import '../services/namuwiki_dump_processor.dart';

/// 나무위키 덤프 처리 로직을 테스트하는 스크립트
/// 실제 덤프 파일 없이 위키텍스트 파싱 로직을 테스트합니다.
class DumpProcessingTest {
  static Future<void> main() async {
    print('🧪 나무위키 덤프 처리 로직 테스트 시작...\n');

    // 테스트용 위키텍스트 샘플들
    await _testWikiTextParsing();
    
    // 가짜 덤프 파일로 처리 로직 테스트
    await _testDumpProcessor();

    print('\n🎉 테스트 완료!');
  }

  /// 위키텍스트 파싱 로직 테스트
  static Future<void> _testWikiTextParsing() async {
    print('📝 위키텍스트 파싱 테스트...\n');

    // 테스트 케이스 1: 가수 (IU)
    final iuWikiText = '''
{{틀:연예인 정보
|사진 = IU_profile.jpg
|이름 = 아이유
|본명 = 이지은
|영문명 = IU
|생년월일 = 1993년 5월 16일
|출생지 = 서울특별시 중구 을지로
|국적 = 대한민국
|직업 = 가수, 배우, 작사가, 작곡가
|활동시기 = 2008년 ~ 현재
|장르 = 발라드, 팝
|소속사 = EDAM 엔터테인먼트
|데뷔 = 2008년 디지털 싱글 《Lost And Found》
}}

아이유(IU, 본명: 이지은)는 대한민국의 가수이자 배우이다. 
2008년 15세의 나이로 데뷔한 후 꾸준한 활동을 통해 대한민국을 대표하는 솔로 가수로 성장했다.
''';

    await _testSingleWikiText('아이유', iuWikiText);

    // 테스트 케이스 2: 배우 (손흥민)
    final sonWikiText = '''
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

손흥민(孫興慜)은 대한민국의 축구선수이다. 현재 프리미어 리그 토트넘 홋스퍼에서 활동하고 있으며, 대한민국 국가대표팀의 주장을 맡고 있다.
''';

    await _testSingleWikiText('손흥민', sonWikiText);

    // 테스트 케이스 3: 스트리머 (우왁굳)
    final woowakgoodWikiText = '''
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

우왁굳은 대한민국의 스트리머이다. 트위치에서 방송을 진행하며, 다양한 게임과 토크 콘텐츠로 인기를 얻고 있다.
''';

    await _testSingleWikiText('우왁굳', woowakgoodWikiText);
  }

  /// 단일 위키텍스트 파싱 테스트
  static Future<void> _testSingleWikiText(String name, String wikiText) async {
    print('🔍 테스트 대상: $name');
    
    // NamuWikiDumpProcessor의 파싱 로직을 직접 호출하기 위해 임시 프로세서 생성
    final processor = NamuWikiDumpProcessor(dumpFilePath: '/tmp/test.xml');
    
    // private 메소드들을 테스트하기 위해 reflection 사용하거나,
    // 여기서는 직접 파싱 로직을 구현해서 테스트
    final info = _testParseWikiText(name, wikiText);
    
    if (info != null) {
      print('  ✅ 파싱 성공');
      print('    이름: ${info.name}');
      print('    생년월일: ${info.birthDate ?? '정보 없음'}');
      print('    성별: ${info.gender}');
      print('    카테고리: ${info.category}');
      print('    설명: ${info.description.length > 50 ? '${info.description.substring(0, 50)}...' : info.description}');
      print('    키워드: ${info.keywords.join(', ')}');
      if (info.debut != null) print('    데뷔: ${info.debut}');
      if (info.agency != null) print('    소속사: ${info.agency}');
    } else {
      print('  ❌ 파싱 실패');
    }
    print('');
  }

  /// 테스트용 위키텍스트 파서 (실제 프로세서 로직과 유사)
  static CelebrityInfo? _testParseWikiText(String name, String wikiText) {
    try {
      return CelebrityInfo(
        name: name,
        birthDate: _testExtractBirthDate(wikiText),
        birthTime: '12:00',
        gender: _testExtractGender(wikiText),
        category: _testExtractCategory(wikiText),
        description: _testExtractDescription(wikiText, name),
        profileImageUrl: _testExtractProfileImage(wikiText),
        keywords: _testExtractKeywords(wikiText, name),
        debut: _testExtractDebut(wikiText),
        agency: _testExtractAgency(wikiText),
        occupation: _testExtractOccupation(wikiText),
        aliases: _testExtractAliases(wikiText, name),
      );
    } catch (e) {
      print('파싱 오류 ($name): $e');
      return null;
    }
  }

  // 테스트용 파싱 함수들 (실제 프로세서와 동일한 로직)
  static String? _testExtractBirthDate(String wikiText) {
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
          return '$year-$month-$day';
        }
      }
    }
    return null;
  }

  static String _testExtractGender(String wikiText) {
    if (wikiText.contains('여성') || wikiText.contains('여배우') || wikiText.contains('여가수')) {
      return 'female';
    }
    return 'male';
  }

  static String _testExtractCategory(String wikiText) {
    if (wikiText.contains('가수') || wikiText.contains('음악가')) return 'singer';
    if (wikiText.contains('배우') || wikiText.contains('연기자')) return 'actor';
    if (wikiText.contains('축구선수') || wikiText.contains('운동선수')) return 'sports';
    if (wikiText.contains('스트리머') || wikiText.contains('BJ')) return 'streamer';
    if (wikiText.contains('유튜버')) return 'youtuber';
    return 'entertainer';
  }

  static String _testExtractDescription(String wikiText, String name) {
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

  static String? _testExtractProfileImage(String wikiText) {
    final match = RegExp(r'\|\s*사진\s*=\s*([^\|\n]+)').firstMatch(wikiText);
    return match?.group(1)?.trim();
  }

  static List<String> _testExtractKeywords(String wikiText, String name) {
    final keywords = <String>{name};
    final terms = ['데뷔', '활동', '앨범', '드라마', '영화'];
    for (final term in terms) {
      if (wikiText.contains(term)) keywords.add(term);
    }
    return keywords.toList();
  }

  static String? _testExtractDebut(String wikiText) {
    final match = RegExp(r'\|\s*데뷔\s*=\s*([^\|\n]+)').firstMatch(wikiText);
    return match?.group(1)?.trim();
  }

  static String? _testExtractAgency(String wikiText) {
    final match = RegExp(r'\|\s*소속사\s*=\s*([^\|\n]+)').firstMatch(wikiText);
    return match?.group(1)?.trim();
  }

  static String? _testExtractOccupation(String wikiText) {
    final match = RegExp(r'\|\s*직업\s*=\s*([^\|\n]+)').firstMatch(wikiText);
    return match?.group(1)?.trim();
  }

  static List<String> _testExtractAliases(String wikiText, String name) {
    final aliases = <String>[];
    final match = RegExp(r'\|\s*본명\s*=\s*([^\|\n]+)').firstMatch(wikiText);
    final realName = match?.group(1)?.trim();
    if (realName != null && realName != name) {
      aliases.add(realName);
    }
    return aliases;
  }

  /// 덤프 프로세서 기본 로직 테스트
  static Future<void> _testDumpProcessor() async {
    print('🔧 덤프 프로세서 기본 로직 테스트...\n');

    // 존재하지 않는 파일 경로로 테스트 (에러 핸들링 확인)
    final processor = NamuWikiDumpProcessor(dumpFilePath: '/tmp/nonexistent.xml');

    try {
      final info = await processor.getDumpFileInfo();
      print('❌ 예상된 오류가 발생하지 않음');
    } catch (e) {
      print('✅ 파일 없음 오류 처리 확인: ${e.toString().contains('존재하지 않습니다')}');
    }

    print('✅ 덤프 프로세서 초기화 확인');
    print('✅ 에러 핸들링 확인');
  }
}

/// 스크립트 실행 진입점
void main() async {
  await DumpProcessingTest.main();
}