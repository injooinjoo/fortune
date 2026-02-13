// 운세 텍스트 클리닝 유틸리티
//
// API 응답에서 받은 운세 텍스트의 마크다운 형식과 불필요한 문구를 제거합니다.
// 모든 운세 결과 페이지에서 공통으로 사용됩니다.
class FortuneTextCleaner {
  /// 마크다운 및 불필요한 텍스트 제거
  static String clean(String content) {
    if (content.isEmpty) return content;

    String cleaned = content;

    // 1. 마크다운 헤더 완전 제거 (# ~ ######)
    cleaned =
        cleaned.replaceAll(RegExp(r'^#{1,6}\s*[^\n]*\n?', multiLine: true), '');

    // 2. 볼드 마크다운 제거 (**text** → text)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (match) => match.group(1) ?? '',
    );

    // 3. 이탤릭 마크다운 제거 (*text* → text)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\*(.+?)\*'),
      (match) => match.group(1) ?? '',
    );

    // 4. 언더스코어 볼드/이탤릭 제거
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'__(.+?)__'),
      (match) => match.group(1) ?? '',
    );
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'_(.+?)_'),
      (match) => match.group(1) ?? '',
    );

    // 5. 리스트 마커 제거 (-, *, 1., 2. 등)
    cleaned =
        cleaned.replaceAll(RegExp(r'^[\s]*[-*•]\s+', multiLine: true), '');
    cleaned =
        cleaned.replaceAll(RegExp(r'^[\s]*\d+\.\s+', multiLine: true), '');

    // 6. 링크 마크다운 제거 ([텍스트](url) → 텍스트)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (match) => match.group(1) ?? '',
    );

    // 7. 이미지 마크다운 완전 제거
    cleaned = cleaned.replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), '');

    // 8. 코드 블록 제거
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');

    // 9. 인라인 코드 제거 (`code` → code)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => match.group(1) ?? '',
    );

    // 10. 인용구 마커 제거
    cleaned = cleaned.replaceAll(RegExp(r'^>\s*', multiLine: true), '');

    // 11. 수평선 제거
    cleaned =
        cleaned.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '');

    // 12. 불필요한 인사말/정형 문구 제거
    cleaned = cleaned.replaceAll(
        RegExp(r'안녕하세요[,.]?\s*당신의\s*앞날을\s*밝혀주는[^\n]*상담가입니다[.。]?\s*'), '');
    cleaned =
        cleaned.replaceAll(RegExp(r'오늘은\s*\d+점의[^\n]*기다리고\s*있네요[!！]?\s*'), '');
    cleaned = cleaned.replaceAll(
        RegExp(r'오늘\s*하루[,.]?\s*긍정적인\s*에너지를\s*듬뿍\s*담아[^\n]*만들어\s*보세요[.。]?\s*'),
        '');
    cleaned =
        cleaned.replaceAll(RegExp(r'오늘의\s*키워드는\s*바로[^\n]*덕목입니다[.。]?\s*'), '');

    // 13. 점수 관련 중복 문구 제거
    cleaned = cleaned.replaceAll(RegExp(r'\(점수:?\s*\d+점?\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'점수:?\s*\d+점'), '');

    // 14. 연속된 공백/줄바꿈 정리
    cleaned = cleaned.replaceAll(RegExp(r'\n{2,}'), '\n\n');
    cleaned = cleaned.replaceAll(RegExp(r'[ \t]{2,}'), ' ');

    return cleaned.trim();
  }

  /// 텍스트를 maxLength 글자로 제한 (마침표 단위로 자연스럽게 자름)
  static String truncate(String text, {int maxLength = 100}) {
    if (text.isEmpty) return text;
    if (text.length <= maxLength) return text;

    // maxLength 근처에서 마침표로 자연스럽게 자르기
    final truncated = text.substring(0, maxLength);
    final lastPeriod = truncated.lastIndexOf('.');
    final lastComma = truncated.lastIndexOf(',');
    final lastSpace = truncated.lastIndexOf(' ');

    // 마침표가 있으면 그 위치에서 자르기
    if (lastPeriod > maxLength * 0.6) {
      return text.substring(0, lastPeriod + 1);
    }
    // 쉼표가 있으면 그 위치에서 자르기
    if (lastComma > maxLength * 0.6) {
      return '${text.substring(0, lastComma)}...';
    }
    // 공백에서 자르기
    if (lastSpace > maxLength * 0.6) {
      return '${text.substring(0, lastSpace)}...';
    }

    return '$truncated...';
  }

  /// 클리닝 + 트런케이션 한번에
  static String cleanAndTruncate(String text, {int maxLength = 100}) {
    return truncate(clean(text), maxLength: maxLength);
  }

  /// Nullable 문자열 처리 (null이면 빈 문자열 반환)
  static String cleanNullable(String? text) {
    if (text == null || text.isEmpty) return '';
    return clean(text);
  }

  /// Nullable 문자열 클리닝 + 트런케이션
  static String cleanAndTruncateNullable(String? text, {int maxLength = 100}) {
    if (text == null || text.isEmpty) return '';
    return cleanAndTruncate(text, maxLength: maxLength);
  }
}
