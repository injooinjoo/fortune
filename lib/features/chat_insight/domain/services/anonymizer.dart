import 'kakao_parser.dart';

/// PII(개인식별정보) 익명화 처리
/// 이름 → A/B, 전화번호/이메일/주소 마스킹
class Anonymizer {
  // 전화번호 패턴 (한국)
  static final _phonePattern = RegExp(
    r'01[0-9]-?\d{3,4}-?\d{4}|\d{2,3}-\d{3,4}-\d{4}',
  );

  // 이메일 패턴
  static final _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );

  // 주소 패턴 (한국 주소 키워드)
  static final _addressPattern = RegExp(
    r'(서울|부산|대구|인천|광주|대전|울산|세종|경기|강원|충북|충남|전북|전남|경북|경남|제주)'
    r'(특별시|광역시|특별자치시|도|특별자치도)?'
    r'\s*\S+[시군구]\s*\S+[읍면동로길]\s*\S*',
  );

  // 계좌번호 패턴
  static final _accountPattern = RegExp(
    r'\d{3,4}-\d{2,6}-\d{2,6}',
  );

  // 주민등록번호 패턴
  static final _ssnPattern = RegExp(
    r'\d{6}-?[1-4]\d{6}',
  );

  /// 발신자 이름 → A/B 매핑 생성
  /// userSender: 분석 요청자의 이름 (→ "A")
  static SenderMapping createSenderMapping(
    List<String> senders,
    String userSender,
  ) {
    final mapping = <String, String>{};
    mapping[userSender] = 'A';

    int labelIndex = 0; // B부터
    for (final sender in senders) {
      if (sender == userSender) continue;
      mapping[sender] = String.fromCharCode('B'.codeUnitAt(0) + labelIndex);
      labelIndex++;
    }

    return SenderMapping(
      mapping: mapping,
      userLabel: 'A',
    );
  }

  /// 메시지 리스트 익명화
  static AnonymizedResult anonymize(
    List<ParsedMessage> messages,
    SenderMapping senderMapping,
  ) {
    final anonymized = <AnonymizedMessage>[];

    for (final msg in messages) {
      final anonSender = senderMapping.mapping[msg.sender] ?? 'Unknown';
      var anonText = msg.text;

      // PII 마스킹 순서: SSN → 전화번호 → 이메일 → 주소 → 계좌 → 이름
      anonText = _maskSSN(anonText);
      anonText = _maskPhone(anonText);
      anonText = _maskEmail(anonText);
      anonText = _maskAddress(anonText);
      anonText = _maskAccount(anonText);
      anonText = _maskNames(anonText, senderMapping);

      anonymized.add(AnonymizedMessage(
        sender: anonSender,
        text: anonText,
        timestamp: msg.timestamp,
      ));
    }

    return AnonymizedResult(
      messages: anonymized,
      senderMapping: senderMapping,
      originalMessageCount: messages.length,
    );
  }

  static String _maskSSN(String text) {
    return text.replaceAll(_ssnPattern, '******-*******');
  }

  static String _maskPhone(String text) {
    return text.replaceAll(_phonePattern, '***-****-****');
  }

  static String _maskEmail(String text) {
    return text.replaceAll(_emailPattern, '***@***.***');
  }

  static String _maskAddress(String text) {
    return text.replaceAll(_addressPattern, '[주소 제거됨]');
  }

  static String _maskAccount(String text) {
    return text.replaceAll(_accountPattern, '****-******-******');
  }

  static String _maskNames(String text, SenderMapping mapping) {
    var result = text;
    for (final entry in mapping.mapping.entries) {
      final name = entry.key;
      final label = entry.value;
      // 이름이 2글자 이상일 때만 치환 (단일 글자는 오탐 가능)
      if (name.length >= 2) {
        result = result.replaceAll(name, label);
      }
    }
    return result;
  }
}

/// 발신자 매핑 정보
class SenderMapping {
  final Map<String, String> mapping; // 원본이름 → A/B/C
  final String userLabel; // 분석 요청자 라벨 (항상 "A")

  const SenderMapping({
    required this.mapping,
    required this.userLabel,
  });

  /// A/B 라벨로 원본 이름 역조회 (UI 표시용)
  String? getOriginalName(String label) {
    for (final entry in mapping.entries) {
      if (entry.value == label) return entry.key;
    }
    return null;
  }
}

/// 익명화된 메시지
class AnonymizedMessage {
  final String sender; // "A" 또는 "B"
  final String text;
  final DateTime timestamp;

  const AnonymizedMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 익명화 결과
class AnonymizedResult {
  final List<AnonymizedMessage> messages;
  final SenderMapping senderMapping;
  final int originalMessageCount;

  const AnonymizedResult({
    required this.messages,
    required this.senderMapping,
    required this.originalMessageCount,
  });
}
