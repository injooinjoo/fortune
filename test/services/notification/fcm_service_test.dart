import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/services/notification/fcm_service.dart';

void main() {
  group('NotificationSettings', () {
    test('toJson includes characterDm and dailyFortuneTime', () {
      const settings = NotificationSettings(
        enabled: true,
        dailyFortune: false,
        tokenAlert: true,
        promotion: false,
        characterDm: false,
        dailyFortuneTime: '08:30',
      );

      expect(settings.toJson(), {
        'enabled': true,
        'dailyFortune': false,
        'tokenAlert': true,
        'promotion': false,
        'characterDm': false,
        'dailyFortuneTime': '08:30',
      });
    });

    test('fromJson falls back to characterDm enabled by default', () {
      final settings = NotificationSettings.fromJson(<String, dynamic>{});

      expect(settings.enabled, isTrue);
      expect(settings.dailyFortune, isTrue);
      expect(settings.tokenAlert, isTrue);
      expect(settings.promotion, isTrue);
      expect(settings.characterDm, isTrue);
      expect(settings.dailyFortuneTime, '07:00');
    });
  });
}
