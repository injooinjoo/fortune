import 'dart:convert';
import 'dart:math';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 포춘 쿠키 운세 생성기
///
/// 로컬 데이터 소스로 포춘 쿠키 메시지를 생성합니다.
/// - 5가지 쿠키 타입: love, wealth, health, wisdom, luck
class FortuneCookieGenerator {
  static final Random _random = Random();

  /// 포춘 쿠키 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   "cookie_type": "love"  // love, wealth, health, wisdom, luck
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
  ) async {
    final cookieType = inputConditions['cookie_type'] as String? ?? 'luck';

    // 📤 로컬 생성 시작
    Logger.info('[FortuneCookieGenerator] 🍪 포춘쿠키 생성 시작');
    Logger.info('[FortuneCookieGenerator]   🎲 cookie_type: $cookieType');

    // 쿠키 타입별 메시지 풀
    final messages = _getMessagesByType(cookieType);
    Logger.info('[FortuneCookieGenerator]   📚 메시지 풀 크기: ${messages.length}개');

    final message = _generateMessage(cookieType);
    final luckyNumber = _generateLuckyNumber();
    final luckyColor = _generateLuckyColor();
    final score = _random.nextInt(30) + 70;

    Logger.info('[FortuneCookieGenerator] ✅ 포춘쿠키 생성 완료');
    Logger.info('[FortuneCookieGenerator]   💬 메시지: $message');
    Logger.info('[FortuneCookieGenerator]   🎯 행운의 숫자: $luckyNumber');
    Logger.info('[FortuneCookieGenerator]   🎨 행운의 색상: $luckyColor');
    Logger.info('[FortuneCookieGenerator]   ⭐ 점수: $score');

    return FortuneResult(
      type: 'fortune_cookie',
      title: '포춘 쿠키',
      summary: {
        'message': message,
        'cookie_type': cookieType,
        'lucky_number': luckyNumber,
        'lucky_color': luckyColor,
      },
      data: {
        'message': message,
        'cookie_type': cookieType,
        'lucky_number': luckyNumber,
        'lucky_color': luckyColor,
        'emoji': _getCookieEmoji(cookieType),
      },
      score: score,
      createdAt: DateTime.now(),
    );
  }

  /// 쿠키 타입별 메시지 생성
  static String _generateMessage(String cookieType) {
    final messages = _getMessagesByType(cookieType);
    return messages[_random.nextInt(messages.length)];
  }

  /// 쿠키 타입별 메시지 풀
  static List<String> _getMessagesByType(String cookieType) {
    switch (cookieType) {
      case 'love':
        return [
          '사랑은 기다리는 자에게 찾아옵니다',
          '진실한 마음은 언제나 통합니다',
          '오늘 만나는 사람이 특별한 인연일 수 있습니다',
          '사랑은 가까운 곳에 있습니다',
          '마음을 열면 새로운 만남이 찾아옵니다',
          '진심은 시간이 지나도 변하지 않습니다',
          '사랑은 용기에서 시작됩니다',
        ];
      case 'wealth':
        return [
          '작은 절약이 큰 부를 만듭니다',
          '기회는 준비된 자에게 찾아옵니다',
          '오늘의 투자가 미래의 재산입니다',
          '지혜로운 소비가 부를 부릅니다',
          '노력은 반드시 결실을 맺습니다',
          '좋은 인연이 재물을 부릅니다',
          '나눔이 더 큰 풍요를 가져옵니다',
        ];
      case 'health':
        return [
          '건강은 가장 큰 재산입니다',
          '규칙적인 생활이 건강을 지킵니다',
          '마음의 평화가 몸의 건강을 만듭니다',
          '오늘의 운동이 내일의 활력입니다',
          '충분한 휴식이 최고의 보약입니다',
          '긍정적인 마음이 건강을 부릅니다',
          '자연과 함께하면 건강해집니다',
        ];
      case 'wisdom':
        return [
          '경험은 가장 훌륭한 스승입니다',
          '배움에는 끝이 없습니다',
          '실수는 성장의 기회입니다',
          '겸손이 진정한 지혜입니다',
          '경청은 지혜의 시작입니다',
          '책 속에 길이 있습니다',
          '질문이 답을 만듭니다',
        ];
      case 'luck':
      default:
        return [
          '행운은 준비된 자에게 찾아옵니다',
          '오늘은 특별한 날이 될 것입니다',
          '긍정적인 태도가 행운을 부릅니다',
          '작은 행운이 큰 기쁨을 줍니다',
          '미소가 행운을 부릅니다',
          '오늘의 선택이 내일의 행운입니다',
          '좋은 일은 항상 연속됩니다',
        ];
    }
  }

  /// 행운의 숫자 생성
  static int _generateLuckyNumber() {
    return _random.nextInt(100) + 1;
  }

  /// 행운의 색상 생성
  static String _generateLuckyColor() {
    final colors = [
      '빨강',
      '주황',
      '노랑',
      '초록',
      '파랑',
      '남색',
      '보라',
      '분홍',
      '흰색',
      '검정',
    ];
    return colors[_random.nextInt(colors.length)];
  }

  /// 쿠키 타입별 이모지
  static String _getCookieEmoji(String cookieType) {
    switch (cookieType) {
      case 'love':
        return '💕';
      case 'wealth':
        return '💰';
      case 'health':
        return '🌿';
      case 'wisdom':
        return '🔮';
      case 'luck':
      default:
        return '🍀';
    }
  }
}
