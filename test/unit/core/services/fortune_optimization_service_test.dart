import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/services/fortune_optimization_service.dart';

void main() {
  group('FortuneOptimizationService strategy', () {
    test('mbti uses edge-managed shared cache strategy', () {
      expect(
        FortuneOptimizationService.usesEdgeManagedSharedCache('mbti'),
        isTrue,
      );
    });

    test('daily keeps client-side reuse strategy', () {
      expect(
        FortuneOptimizationService.usesEdgeManagedSharedCache('daily'),
        isFalse,
      );
    });
  });
}
