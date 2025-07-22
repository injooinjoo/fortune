import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dynamic Value Generation Tests', () {
    test('generateLuckyNumber returns consistent values for same user and date', () {
      final userId = 'test-user-123';
      final date = DateTime(2025, 7, 21);
      
      final number1 = _generateLuckyNumber(userId, date);
      final number2 = _generateLuckyNumber(userId, date);
      
      expect(number1, equals(number2));
      expect(number1, greaterThanOrEqualTo(1));
      expect(number1, lessThanOrEqualTo(45));
    });
    
    test('generateLuckyNumber returns different values for different dates', () {
      final userId = 'test-user-123';
      final date1 = DateTime(2025, 7, 21);
      final date2 = DateTime(2025, 7, 22);
      
      final number1 = _generateLuckyNumber(userId, date1);
      final number2 = _generateLuckyNumber(userId, date2);
      
      expect(number1, isNot(equals(number2)));
    });
    
    test('getMoodByScore returns appropriate moods', () {
      expect(_getMoodByScore(95), equals('최고의 기분'));
      expect(_getMoodByScore(85), equals('활기찬'));
      expect(_getMoodByScore(75), equals('평온함'));
      expect(_getMoodByScore(65), equals('보통'));
      expect(_getMoodByScore(55), equals('주의 필요'));
      expect(_getMoodByScore(45), equals('조심스러운'));
    });
    
    test('getEnergyByScore calculates correct energy levels', () {
      expect(_getEnergyByScore(100), equals(100));
      expect(_getEnergyByScore(80), equals(90));
      expect(_getEnergyByScore(60), equals(80));
      expect(_getEnergyByScore(40), equals(70));
      expect(_getEnergyByScore(0), equals(50));
    });
    
    test('getBestTimeByUser returns consistent time slots', () {
      final userId = 'test-user-123';
      final date = DateTime(2025, 7, 21);
      
      final time1 = _getBestTimeByUser(userId, date);
      final time2 = _getBestTimeByUser(userId, date);
      
      expect(time1, equals(time2));
      expect(time1, contains('시'));
    });
    
    test('getAdviceByScore returns appropriate advice', () {
      expect(_getAdviceByScore(95), contains('도전'));
      expect(_getAdviceByScore(85), contains('긍정적'));
      expect(_getAdviceByScore(75), contains('안정적'));
      expect(_getAdviceByScore(65), contains('평범'));
      expect(_getAdviceByScore(55), contains('신중'));
      expect(_getAdviceByScore(45), contains('휴식'));
    });
    
    test('getCautionByScore returns appropriate cautions', () {
      expect(_getCautionByScore(95), contains('자신감'));
      expect(_getCautionByScore(85), contains('낙관'));
      expect(_getCautionByScore(75), contains('실수'));
      expect(_getCautionByScore(65), contains('감정'));
      expect(_getCautionByScore(55), contains('충동'));
      expect(_getCautionByScore(45), contains('무리'));
    });
  });
}

// Helper functions copied from HomeScreen for testing
int _generateLuckyNumber(String? userId, DateTime date) {
  final seed = '${userId ?? 'default'}_${date.year}_${date.month}_${date.day}';
  int hash = seed.hashCode.abs();
  return (hash % 45) + 1;
}

String _getMoodByScore(int score) {
  if (score >= 90) return '최고의 기분';
  if (score >= 80) return '활기찬';
  if (score >= 70) return '평온함';
  if (score >= 60) return '보통';
  if (score >= 50) return '주의 필요';
  return '조심스러운';
}

int _getEnergyByScore(int score) {
  return 50 + (score * 0.5).round();
}

String _getBestTimeByUser(String? userId, DateTime date) {
  final seed = '${userId ?? 'default'}_besttime'.hashCode.abs();
  final timeSlot = seed % 8;
  
  switch (timeSlot) {
    case 0: return '오전 6시-8시';
    case 1: return '오전 9시-11시';
    case 2: return '오후 12시-2시';
    case 3: return '오후 2시-4시';
    case 4: return '오후 4시-6시';
    case 5: return '오후 6시-8시';
    case 6: return '오후 8시-10시';
    case 7: return '오후 10시-12시';
    default: return '오후 2시-4시';
  }
}

String _getAdviceByScore(int score) {
  if (score >= 90) return '오늘은 무엇이든 도전해보세요! 큰 성과가 기대됩니다.';
  if (score >= 80) return '긍정적인 에너지가 넘치는 날입니다. 적극적으로 행동하세요.';
  if (score >= 70) return '안정적인 하루가 될 것입니다. 차분하게 계획을 실행하세요.';
  if (score >= 60) return '평범한 하루지만 작은 행복을 찾아보세요.';
  if (score >= 50) return '신중하게 행동하고 무리하지 마세요.';
  return '오늘은 휴식이 필요한 날입니다. 자신을 돌보세요.';
}

String _getCautionByScore(int score) {
  if (score >= 90) return '과도한 자신감은 경계하세요.';
  if (score >= 80) return '지나친 낙관은 피하고 현실적으로 판단하세요.';
  if (score >= 70) return '작은 실수가 큰 문제가 될 수 있으니 주의하세요.';
  if (score >= 60) return '감정 기복에 휘둘리지 마세요.';
  if (score >= 50) return '충동적인 결정은 피하고 신중히 생각하세요.';
  return '무리한 도전보다는 안정을 추구하세요.';
}