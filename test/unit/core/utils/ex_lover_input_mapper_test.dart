import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/utils/ex_lover_input_mapper.dart';

void main() {
  group('ExLoverInputMapper', () {
    test('normalizes reunion strategy survey answers for API payloads', () {
      final normalized = ExLoverInputMapper.normalize({
        'primaryGoal': 'reunion_strategy',
        'breakupTime': '6to12months',
        'breakupInitiator': 'them',
        'contactStatus': 'occasional',
        'coreReason': 'family',
        'detailedStory': '  가족 반대로 헤어졌어요.  ',
        'reunionDeep': 'they_changed',
        'exPartnerName': 'ㅇㅇ',
        'exPartnerMbti': 'ISTP',
        'exPartnerBirthYear': '1990s',
        'currentState': ['miss_them', 'confused'],
      });

      expect(normalized['time_since_breakup'], '6to12months');
      expect(normalized['breakup_initiator'], 'them');
      expect(normalized['contact_status'], 'occasional');
      expect(normalized['breakup_reason'], 'family');
      expect(normalized['breakup_detail'], '가족 반대로 헤어졌어요.');
      expect(normalized['ex_name'], 'ㅇㅇ');
      expect(normalized['ex_mbti'], 'ISTP');
      expect(normalized['ex_birth_date'], '1990s');
      expect(normalized['currentState'], ['miss_them', 'confused']);
      expect(
        normalized['goalSpecific'],
        containsPair('whatWillChange', '상대가 변했을 것 같아'),
      );
    });

    test('uses partner mbti as read-their-mind goalSpecific fallback', () {
      final normalized = ExLoverInputMapper.normalize({
        'primaryGoal': 'read_their_mind',
        'exPartnerMbti': 'ISTP',
      });

      expect(
        normalized['goalSpecific'],
        containsPair('exCharacteristics', 'ISTP'),
      );
    });

    test('preserves existing goalSpecific while filling missing aliases', () {
      final normalized = ExLoverInputMapper.normalize({
        'primaryGoal': 'new_start',
        'goalSpecific': {
          'newRelationshipPriority': '감정적 안정',
        },
        'breakup_detail': '정리 중이에요.',
      });

      expect(
        normalized['goalSpecific'],
        containsPair('newRelationshipPriority', '감정적 안정'),
      );
      expect(normalized['detailedStory'], '정리 중이에요.');
    });
  });
}
