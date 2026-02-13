import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';

/// ChatGPT 스타일 음성 웨이브폼 애니메이션
/// 많은 얇은 바가 실시간 소리에 반응
class VoiceSpectrumAnimation extends StatefulWidget {
  final bool isRecording;
  final int barCount;
  final double soundLevel; // 0.0 ~ 10.0 (speech_to_text 기준)
  final bool isSpeaking; // 실제 음성 인식 중인지 (partial result 수신 중)

  const VoiceSpectrumAnimation({
    super.key,
    required this.isRecording,
    this.barCount = 50, // ChatGPT 스타일: 많은 바
    this.soundLevel = 0.0,
    this.isSpeaking = false,
  });

  @override
  State<VoiceSpectrumAnimation> createState() => _VoiceSpectrumAnimationState();
}

class _VoiceSpectrumAnimationState extends State<VoiceSpectrumAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Random _random = Random();

  // 각 바의 높이를 저장 (부드러운 전환용)
  List<double> _barHeights = [];
  List<double> _targetHeights = [];

  // iOS fallback: isSpeaking일 때 웨이브 애니메이션용
  double _fallbackPhase = 0.0;

  @override
  void initState() {
    super.initState();
    _barHeights = List.filled(widget.barCount, 0.3);
    _targetHeights = List.filled(widget.barCount, 0.3);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateBarHeights);

    _animationController.repeat();
  }

  void _updateBarHeights() {
    if (!widget.isRecording) return;

    setState(() {
      // 소리 레벨 정규화 (0.0 ~ 1.0)
      final normalizedLevel = (widget.soundLevel / 10.0).clamp(0.0, 1.0);

      // 실제 음성 감지: soundLevel > 0 (Android) OR isSpeaking (iOS - partial result 수신 중)
      final hasSoundLevel = normalizedLevel > 0.05;
      final isActive = hasSoundLevel || widget.isSpeaking;

      for (int i = 0; i < widget.barCount; i++) {
        double targetHeight;

        if (!isActive) {
          // 말 안할 때: 최소 높이로 대기
          targetHeight = 0.15;
        } else if (hasSoundLevel) {
          // Android: 실제 소리 레벨 반응
          final randomVariation = _random.nextDouble() * 0.25;
          final soundResponse = normalizedLevel * 0.6;

          final center = widget.barCount / 2;
          final distanceFromCenter = (i - center).abs() / center;
          final centerBoost = 1.0 - (distanceFromCenter * 0.4);

          targetHeight = (0.15 + randomVariation + (soundResponse * centerBoost)).clamp(0.1, 1.0);
        } else {
          // iOS fallback: isSpeaking일 때 웨이브 애니메이션
          _fallbackPhase += 0.02;
          final waveOffset = sin(_fallbackPhase + i * 0.3) * 0.3;
          final randomVariation = _random.nextDouble() * 0.15;

          final center = widget.barCount / 2;
          final distanceFromCenter = (i - center).abs() / center;
          final centerBoost = 1.0 - (distanceFromCenter * 0.3);

          targetHeight = (0.3 + waveOffset + randomVariation) * centerBoost;
          targetHeight = targetHeight.clamp(0.15, 0.8);
        }

        _targetHeights[i] = targetHeight;

        // 부드러운 전환 (lerp)
        final lerpSpeed = isActive ? 0.25 : 0.5;
        _barHeights[i] = _barHeights[i] + (_targetHeights[i] - _barHeights[i]) * lerpSpeed;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VoiceSpectrumAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.barCount != oldWidget.barCount) {
      _barHeights = List.filled(widget.barCount, 0.3);
      _targetHeights = List.filled(widget.barCount, 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return const SizedBox.shrink();
    }

    final isDark = context.isDark;
    // ChatGPT 스타일: 회색 웨이브폼
    final barColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 가용 너비에 맞게 바 개수 계산 (각 바 = 2px 너비 + 2px 마진 = 4px)
          final maxBars = (constraints.maxWidth / 4).floor();
          final actualBarCount = maxBars.clamp(10, widget.barCount);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              actualBarCount,
              (index) {
                // barCount가 줄어들 수 있으므로 인덱스 맵핑
                final mappedIndex = (index * widget.barCount / actualBarCount).floor().clamp(0, _barHeights.length - 1);
                final height = _barHeights[mappedIndex] * 28; // 최대 28px

                return Container(
                  width: 2,
                  height: height.clamp(4.0, 28.0),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
