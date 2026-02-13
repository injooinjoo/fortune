import 'package:flutter/foundation.dart';

/// 카카오톡 내보내기 텍스트를 파싱하여 구조화된 메시지 리스트로 변환
class KakaoParser {
  /// 카카오톡 내보내기 형식:
  /// "2026년 1월 15일 오후 3:42, 홍길동 : 안녕하세요"
  /// "2026년 1월 15일 오후 3:42, 홍길동 : 사진"  (미디어)
  static final _messagePattern = RegExp(
    r'^(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일\s*(오전|오후)\s*(\d{1,2}):(\d{2}),\s*(.+?)\s*:\s*(.+)$',
  );

  /// 시스템 메시지 패턴 (입장/퇴장/날짜 헤더)
  static final _systemPattern = RegExp(
    r'^-{3,}|^(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일\s*(월|화|수|목|금|토|일)요일|님이\s*(들어왔습니다|나갔습니다)|님을\s*초대했습니다',
  );

  /// 미디어/이모티콘 메시지 패턴
  static final _mediaPattern = RegExp(
    r'^(사진|동영상|파일|이모티콘|음성메시지|보이스톡|영상통화|삭제된\s*메시지)$',
  );

  /// 텍스트를 파싱하여 ParsedMessage 리스트 반환
  static ParseResult parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return const ParseResult(
        messages: [],
        error: ParseError.emptyInput,
      );
    }

    final lines = rawText.split('\n');

    if (lines.length > 100000) {
      return const ParseResult(
        messages: [],
        error: ParseError.tooManyLines,
      );
    }

    final messages = <ParsedMessage>[];
    final senders = <String>{};
    ParsedMessage? currentMessage;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // 시스템 메시지 스킵
      if (_systemPattern.hasMatch(trimmed)) {
        continue;
      }

      final match = _messagePattern.firstMatch(trimmed);
      if (match != null) {
        // 이전 메시지 저장
        if (currentMessage != null) {
          messages.add(currentMessage);
        }

        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        final amPm = match.group(4)!;
        var hour = int.parse(match.group(5)!);
        final minute = int.parse(match.group(6)!);
        final sender = match.group(7)!.trim();
        final text = match.group(8)!.trim();

        // 오전/오후 → 24시간제
        if (amPm == '오후' && hour != 12) {
          hour += 12;
        } else if (amPm == '오전' && hour == 12) {
          hour = 0;
        }

        final timestamp = DateTime(year, month, day, hour, minute);
        senders.add(sender);

        // 미디어 메시지 스킵
        if (_mediaPattern.hasMatch(text)) {
          currentMessage = null;
          continue;
        }

        currentMessage = ParsedMessage(
          sender: sender,
          text: text,
          timestamp: timestamp,
        );
      } else {
        // 멀티라인 메시지 (이전 메시지에 연결)
        if (currentMessage != null) {
          currentMessage = currentMessage.appendLine(trimmed);
        }
      }
    }

    // 마지막 메시지 저장
    if (currentMessage != null) {
      messages.add(currentMessage);
    }

    // 파싱 실패 판단
    if (messages.isEmpty && lines.length > 3) {
      return const ParseResult(
        messages: [],
        error: ParseError.formatMismatch,
      );
    }

    if (messages.length < 50) {
      return ParseResult(
        messages: messages,
        error: ParseError.tooFewMessages,
        senders: senders.toList(),
      );
    }

    // 3인 이상 대화방 체크
    if (senders.length > 2) {
      return ParseResult(
        messages: messages,
        error: ParseError.groupChat,
        senders: senders.toList(),
      );
    }

    return ParseResult(
      messages: messages,
      senders: senders.toList(),
    );
  }

  /// 디버그용: 파싱 통계
  static Map<String, int> getStats(List<ParsedMessage> messages) {
    final senderCounts = <String, int>{};
    for (final msg in messages) {
      senderCounts[msg.sender] = (senderCounts[msg.sender] ?? 0) + 1;
    }
    return senderCounts;
  }
}

/// 파싱된 메시지
@immutable
class ParsedMessage {
  final String sender;
  final String text;
  final DateTime timestamp;

  const ParsedMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  /// 멀티라인 메시지 연결
  ParsedMessage appendLine(String line) {
    return ParsedMessage(
      sender: sender,
      text: '$text\n$line',
      timestamp: timestamp,
    );
  }
}

/// 파싱 에러 타입
enum ParseError {
  emptyInput,
  formatMismatch,
  tooFewMessages,
  tooManyLines,
  groupChat,
}

/// 파싱 결과
@immutable
class ParseResult {
  final List<ParsedMessage> messages;
  final ParseError? error;
  final List<String> senders;

  const ParseResult({
    required this.messages,
    this.error,
    this.senders = const [],
  });

  bool get isSuccess => error == null;
  bool get hasWarning =>
      error == ParseError.tooFewMessages || error == ParseError.groupChat;

  String get errorMessage {
    switch (error) {
      case ParseError.emptyInput:
        return '대화 내용을 넣어주세요';
      case ParseError.formatMismatch:
        return '카카오톡 내보내기 형식이 아닌 것 같아요. 카카오톡 > 채팅방 > ≡ > 대화내용 내보내기를 사용해주세요.';
      case ParseError.tooFewMessages:
        return '분석에 충분한 대화가 필요해요 (최소 50개 메시지). 현재 ${messages.length}개입니다.';
      case ParseError.tooManyLines:
        return '대화가 너무 길어요 (최대 10만 줄). 최근 30일을 선택해서 내보내기 해주세요.';
      case ParseError.groupChat:
        return '${senders.length}명이 참여한 단체 대화방이에요. 1:1 대화방만 분석할 수 있어요.';
      case null:
        return '';
    }
  }
}
