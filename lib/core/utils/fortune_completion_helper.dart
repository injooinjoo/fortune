import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../../presentation/providers/fortune_gauge_provider.dart';
import '../../shared/components/gauge_increment_overlay.dart';
import '../../shared/components/lucky_bag_celebration_overlay.dart';

/// 운세 완료 시 게이지 증가 및 축하 오버레이 표시를 담당하는 헬퍼 클래스
///
/// **사용법**:
/// ```dart
/// await FortuneCompletionHelper.onFortuneViewed(
///   context,
///   ref,
///   'tarot', // 운세 타입: tarot, mbti, saju 등
/// );
/// ```
///
/// **동작**:
/// 1. fortuneGaugeProvider를 통해 게이지 증가 시도
/// 2. 증가 성공 시 GaugeIncrementOverlay로 애니메이션 표시
/// 3. 10개 달성 시 LuckyBagCelebrationOverlay 표시
class FortuneCompletionHelper {
  /// 운세 결과를 끝까지 봤을 때 호출
  /// 게이지 증가 + 오버레이 애니메이션 표시
  static Future<void> onFortuneViewed(
    BuildContext context,
    WidgetRef ref,
    String fortuneType,
  ) async {
    Logger.info('[FortuneCompletionHelper] 운세 완료 - 타입: $fortuneType');

    // 1. 게이지 증가 시도
    final gaugeNotifier = ref.read(fortuneGaugeProvider.notifier);
    final previousProgress = ref.read(fortuneGaugeProvider).currentProgress;

    final wasIncremented = await gaugeNotifier.incrementGauge(fortuneType);

    if (wasIncremented) {
      // 증가 후 진행률 계산 (리셋 전 값)
      final expectedProgress = previousProgress + 1;
      final reachedTen = expectedProgress == 10;

      // 2. 게이지 증가 오버레이 표시
      if (context.mounted) {
        GaugeIncrementOverlay.show(
          context: context,
          fromProgress: previousProgress,
          toProgress: expectedProgress,  // 리셋 전 값 (10 포함)
        );
      }

      // 3. 10개 달성 시 축하 화면 (복주머니 지급 후 자동 리셋됨)
      if (reachedTen && context.mounted) {
        await Future.delayed(const Duration(milliseconds: 1600)); // 게이지 오버레이 끝난 후
        if (context.mounted) {
          LuckyBagCelebrationOverlay.show(context: context);
        }
      }
    }
  }
}
