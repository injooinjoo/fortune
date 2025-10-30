import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 음성 스펙트럼 애니메이션 (실제 마이크 입력 기반)
class VoiceSpectrumAnimation extends StatelessWidget {
  final bool isRecording;
  final int barCount;
  final double soundLevel; // 0.0 ~ 1.0

  const VoiceSpectrumAnimation({
    super.key,
    required this.isRecording,
    this.barCount = 30,
    this.soundLevel = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRecording) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final random = math.Random();

    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          barCount,
          (index) {
            // 각 막대는 약간씩 다른 높이 (중앙이 높고 양쪽이 낮음)
            final centerDistance = (index - barCount / 2).abs() / (barCount / 2);
            final baseHeight = 4.0 + (1.0 - centerDistance) * 8.0;

            // 사운드 레벨에 따라 높이 조절 (랜덤 변화 추가)
            final randomFactor = 0.7 + (random.nextDouble() * 0.6);
            final height = baseHeight + (soundLevel * 20 * randomFactor);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                width: 2,
                height: height.clamp(4.0, 32.0),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
