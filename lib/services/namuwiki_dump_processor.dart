import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';
import '../data/models/celebrity_master_list.dart';
import '../data/models/celebrity.dart';

/// 나무위키 덤프 파일을 처리하여 연예인 정보를 추출하는 서비스
/// 
/// 사용 방법:
/// 1. 나무위키 덤프 다운로드: https://dumps.namu.wiki/
/// 2. 덤프 파일을 지정된 경로에 저장
/// 3. 이 서비스로 파싱 및 데이터 추출
class NamuWikiDumpProcessor {
  final String dumpFilePath;
  
  NamuWikiDumpProcessor({
    required this.dumpFilePath,
  });

  /// 덤프 파일에서 특정 연예인의 정보를 추출합니다
  Future<CelebrityInfo?> extractCelebrityInfo(String celebrityName) async {
    try {
      debugPrint('🔍 덤프에서 검색 중: $celebrityName');

      // XML 덤프 파일 읽기 (스트림 방식으로 메모리 효율적으로)
      final file = File(dumpFilePath);
      if (!await file.exists()) {
        throw Exception('덤프 파일을 찾을 수 없습니다: $dumpFilePath');
      }

      final stream = file.openRead();
      String? pageContent;
      bool foundPage = false;

      await for (String chunk in stream.transform(utf8.decoder)) {
        // XML 파싱하여 해당 페이지 찾기
        if (chunk.contains('<title>$celebrityName</title>')) {
          foundPage = true;
          // 해당 페이지의 내용 추출
          pageContent = await _extractPageContent(celebrityName, stream);
          break;
        }
      }

      if (!foundPage || pageContent == null) {
        debugPrint('❌ 덤프에서 찾을 수 없음: $celebrityName');
        return null;
      }

      // 위키텍스트에서 정보 추출
      final info = _parseWikiText(celebrityName, pageContent);
      debugPrint('✅ 덤프에서 추출 완료: $celebrityName');
      
      return info;

    } catch (e) {
      debugPrint('❌ 덤프 처리 오류 ($celebrityName): $e');
      return null;
    }
  }

  /// 여러 연예인의 정보를 배치로 추출합니다
  Future<Map<String, CelebrityInfo>> extractMultipleCelebrities(
    List<String> celebrityNames,
  ) async {
    debugPrint('📋 배치 추출 시작: ${celebrityNames.length}명');

    final results = <String, CelebrityInfo>{};
    
    try {
      // 전체 덤프 파일을 한 번만 읽어서 모든 연예인 정보 추출
      final celebrityPages = await _extractMultiplePages(celebrityNames);

      for (final entry in celebrityPages.entries) {
        final name = entry.key;
        final content = entry.value;
        
        final info = _parseWikiText(name, content);
        if (info != null) {
          results[name] = info;
        }
      }

      debugPrint('📊 배치 추출 완료: ${results.length}/${celebrityNames.length}명 성공');
      
    } catch (e) {
      debugPrint('❌ 배치 추출 오류: $e');
    }

    return results;
  }

  /// 덤프 파일에서 여러 페이지를 한 번에 추출
  Future<Map<String, String>> _extractMultiplePages(List<String> names) async {
    final results = <String, String>{};
    final nameSet = names.toSet();
    
    final file = File(dumpFilePath);
    final stream = file.openRead();
    
    String buffer = '';
    String? currentTitle;
    bool inPage = false;
    bool inText = false;
    StringBuffer contentBuffer = StringBuffer();

    await for (String chunk in stream.transform(utf8.decoder).transform(LineSplitter())) {
      buffer = chunk;

      if (buffer.contains('<page>')) {
        inPage = true;
        currentTitle = null;
        contentBuffer.clear();
      } else if (buffer.contains('</page>')) {
        inPage = false;
        
        if (currentTitle != null && nameSet.contains(currentTitle)) {
          results[currentTitle] = contentBuffer.toString();
        }
        
        currentTitle = null;
        contentBuffer.clear();
      } else if (inPage && buffer.contains('<title>')) {
        final titleMatch = RegExp(r'<title>(.*?)</title>').firstMatch(buffer);
        if (titleMatch != null) {
          currentTitle = titleMatch.group(1);
        }
      } else if (inPage && buffer.contains('<text')) {
        inText = true;
        final textStart = buffer.indexOf('>');
        if (textStart != -1 && textStart < buffer.length - 1) {
          contentBuffer.write(buffer.substring(textStart + 1));
        }
      } else if (inText && buffer.contains('</text>')) {
        inText = false;
        final textEnd = buffer.indexOf('</text>');
        if (textEnd != -1) {
          contentBuffer.write(buffer.substring(0, textEnd));
        }
      } else if (inText) {
        contentBuffer.writeln(buffer);
      }

      // 모든 연예인을 찾았으면 조기 종료
      if (results.length >= nameSet.length) {
        break;
      }
    }

    return results;
  }

  /// 단일 페이지 내용 추출
  Future<String?> _extractPageContent(String name, Stream<List<int>> stream) async {
    // 실제 구현에서는 XML 스트림 파싱을 통해 해당 페이지의 내용만 추출
    // 여기서는 간단한 버전으로 구현
    return null; // 실제로는 위키텍스트 내용 반환
  }

  /// 위키텍스트에서 연예인 정보를 파싱합니다
  CelebrityInfo? _parseWikiText(String name, String wikiText) {
    try {
      return CelebrityInfo(
        name: name,
        birthDate: _extractBirthDate(wikiText),
        birthTime: '12:00',
        gender: _extractGender(wikiText),
        category: _extractCategory(wikiText),
        description: _extractDescription(wikiText, name),
        profileImageUrl: _extractProfileImage(wikiText),
        keywords: _extractKeywords(wikiText, name),
        debut: _extractDebut(wikiText),
        agency: _extractAgency(wikiText),
        occupation: _extractOccupation(wikiText),
        aliases: _extractAliases(wikiText, name),
      );
    } catch (e) {
      debugPrint('위키텍스트 파싱 오류 ($name): $e');
      return null;
    }
  }

  /// 위키텍스트에서 생년월일 추출
  String? _extractBirthDate(String wikiText) {
    final patterns = [
      RegExp(r'\|\s*생년월일\s*=\s*(\d{4})년?\s*(\d{1,2})월?\s*(\d{1,2})일?'),
      RegExp(r'\|\s*출생일\s*=\s*(\d{4})년?\s*(\d{1,2})월?\s*(\d{1,2})일?'),
      RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일\s*출생'),
      RegExp(r'(\d{4})\.\s*(\d{1,2})\.\s*(\d{1,2})\s*출생'),
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

  /// 위키텍스트에서 성별 추출
  String _extractGender(String wikiText) {
    if (wikiText.contains('여성') || wikiText.contains('여배우') || wikiText.contains('여가수') ||
        wikiText.contains('걸그룹') || wikiText.contains('그녀는')) {
      return 'female';
    }
    return 'male';
  }

  /// 위키텍스트에서 카테고리 추출
  String _extractCategory(String wikiText) {
    if (wikiText.contains('배우') || wikiText.contains('연기자')) return 'actor';
    if (wikiText.contains('가수') || wikiText.contains('음악가') || wikiText.contains('보컬')) return 'singer';
    if (wikiText.contains('정치인') || wikiText.contains('국회의원') || wikiText.contains('대통령')) return 'politician';
    if (wikiText.contains('운동선수') || wikiText.contains('축구선수') || wikiText.contains('야구선수')) return 'sports';
    if (wikiText.contains('스트리머') || wikiText.contains('BJ')) return 'streamer';
    if (wikiText.contains('유튜버') || wikiText.contains('크리에이터')) return 'youtuber';
    if (wikiText.contains('개그맨') || wikiText.contains('코미디언')) return 'entertainer';
    if (wikiText.contains('프로게이머')) return 'pro_gamer';
    if (wikiText.contains('기업인') || wikiText.contains('CEO') || wikiText.contains('회장')) return 'business_leader';
    
    return 'entertainer';
  }

  /// 위키텍스트에서 설명 추출
  String _extractDescription(String wikiText, String name) {
    // 첫 번째 문단이나 개요 부분에서 설명 추출
    final lines = wikiText.split('\n');
    for (final line in lines) {
      if (line.trim().isNotEmpty && 
          !line.startsWith('|') && 
          !line.startsWith('{{') && 
          !line.startsWith('[[') &&
          line.length > 20) {
        return line.trim().length > 200 ? '${line.trim().substring(0, 200)}...' : line.trim();
      }
    }
    return '$name에 대한 정보';
  }

  /// 프로필 이미지 추출
  String? _extractProfileImage(String wikiText) {
    final imagePatterns = [
      RegExp(r'\|\s*사진\s*=\s*([^\|\n]+)'),
      RegExp(r'\|\s*이미지\s*=\s*([^\|\n]+)'),
      RegExp(r'\[\[파일:([^\]]+)\]\]'),
    ];

    for (final pattern in imagePatterns) {
      final match = pattern.firstMatch(wikiText);
      if (match != null && match.group(1) != null) {
        final imageFile = match.group(1)!.trim();
        if (imageFile.isNotEmpty) {
          // 나무위키 이미지 URL 생성 (실제로는 더 복잡한 변환이 필요)
          return 'https://w.namu.la/s/${Uri.encodeComponent(imageFile)}';
        }
      }
    }
    
    return null;
  }

  /// 키워드 추출
  List<String> _extractKeywords(String wikiText, String name) {
    final keywords = <String>{name};
    
    // 자주 나오는 키워드들 추출
    final commonTerms = ['데뷔', '활동', '앨범', '드라마', '영화', '출연', '소속', '그룹'];
    for (final term in commonTerms) {
      if (wikiText.contains(term)) {
        keywords.add(term);
      }
    }
    
    return keywords.toList();
  }

  /// 데뷔 정보 추출
  String? _extractDebut(String wikiText) {
    final patterns = [
      RegExp(r'\|\s*데뷔\s*=\s*([^\|\n]+)'),
      RegExp(r'\|\s*데뷔작\s*=\s*([^\|\n]+)'),
      RegExp(r'(\d{4}년)\s*데뷔'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(wikiText);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    
    return null;
  }

  /// 소속사 추출
  String? _extractAgency(String wikiText) {
    final patterns = [
      RegExp(r'\|\s*소속사\s*=\s*([^\|\n]+)'),
      RegExp(r'\|\s*소속\s*=\s*([^\|\n]+)'),
      RegExp(r'\|\s*레이블\s*=\s*([^\|\n]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(wikiText);
      if (match != null && match.group(1) != null) {
        final agency = match.group(1)!.trim();
        if (agency.isNotEmpty && agency.length < 50) {
          return agency;
        }
      }
    }
    
    return null;
  }

  /// 직업 추출
  String? _extractOccupation(String wikiText) {
    final patterns = [
      RegExp(r'\|\s*직업\s*=\s*([^\|\n]+)'),
      RegExp(r'\|\s*활동분야\s*=\s*([^\|\n]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(wikiText);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    
    return null;
  }

  /// 별명/예명 추출
  List<String> _extractAliases(String wikiText, String name) {
    final aliases = <String>[];
    
    final patterns = [
      RegExp(r'\|\s*별명\s*=\s*([^\|\n]+)'),
      RegExp(r'\|\s*예명\s*=\s*([^\|\n]+)'),
      RegExp(r'\|\s*본명\s*=\s*([^\|\n]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(wikiText);
      if (match != null && match.group(1) != null) {
        final alias = match.group(1)!.trim();
        if (alias.isNotEmpty && alias != name && alias.length < 20) {
          aliases.add(alias);
        }
      }
    }
    
    return aliases;
  }

  /// 덤프 파일 정보 확인
  Future<DumpFileInfo> getDumpFileInfo() async {
    final file = File(dumpFilePath);
    
    if (!await file.exists()) {
      throw Exception('덤프 파일이 존재하지 않습니다: $dumpFilePath');
    }

    final stat = await file.stat();
    
    return DumpFileInfo(
      filePath: dumpFilePath,
      fileSize: stat.size,
      lastModified: stat.modified,
      exists: true,
    );
  }
}

/// 연예인 정보 데이터 클래스
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'birth_date': birthDate,
    'birth_time': birthTime,
    'gender': gender,
    'category': category,
    'description': description,
    'profile_image_url': profileImageUrl,
    'keywords': keywords,
    'debut': debut,
    'agency': agency,
    'occupation': occupation,
    'aliases': aliases,
  };
}

/// 덤프 파일 정보 클래스
class DumpFileInfo {
  final String filePath;
  final int fileSize;
  final DateTime lastModified;
  final bool exists;

  DumpFileInfo({
    required this.filePath,
    required this.fileSize,
    required this.lastModified,
    required this.exists,
  });

  String get fileSizeFormatted => '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
}