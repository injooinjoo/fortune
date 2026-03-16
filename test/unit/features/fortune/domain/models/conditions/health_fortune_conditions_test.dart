import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/fortune/domain/models/conditions/health_fortune_conditions.dart';

void main() {
  group('HealthFortuneConditions', () {
    test('accepts chat survey aliases and parses numeric strings', () {
      final conditions = HealthFortuneConditions.fromInputData({
        'currentCondition': 'good',
        'concern': 'stress',
        'sleepQuality': '2',
        'exerciseFrequency': '3',
        'stressLevel': '4',
        'mealRegularity': '5',
      });

      expect(conditions.healthConcern, 'good');
      expect(conditions.symptoms, ['stress']);
      expect(conditions.sleepQuality, 2);
      expect(conditions.exerciseFrequency, 3);
      expect(conditions.stressLevel, 4);
      expect(conditions.mealRegularity, 5);

      final payload = conditions.buildAPIPayload();
      expect(payload['current_condition'], 'good');
      expect(payload['concerned_body_parts'], ['stress']);
      expect(payload['sleepQuality'], 2);
      expect(payload['exerciseFrequency'], 3);
      expect(payload['stressLevel'], 4);
      expect(payload['mealRegularity'], 5);
    });

    test('keeps canonical payload values when already typed', () {
      final conditions = HealthFortuneConditions.fromInputData({
        'current_condition': 'tired',
        'concerned_body_parts': ['fatigue', 'mental'],
        'sleep_quality': 1,
        'exercise_frequency': 2,
        'stress_level': 5,
        'meal_regularity': 3,
        'has_chronic_condition': true,
        'chronic_condition': 'asthma',
      });

      expect(conditions.healthConcern, 'tired');
      expect(conditions.symptoms, ['fatigue', 'mental']);
      expect(conditions.sleepQuality, 1);
      expect(conditions.exerciseFrequency, 2);
      expect(conditions.stressLevel, 5);
      expect(conditions.mealRegularity, 3);
      expect(conditions.hasChronicCondition, isTrue);
      expect(conditions.chronicCondition, 'asthma');
    });
  });
}
