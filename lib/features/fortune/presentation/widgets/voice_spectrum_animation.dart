import 'package:flutter/material.dart';

/// 음성 스펙트럼 애니메이션 (실제 마이크 입력 기반)
/// Duolingo 스타일의 부드럽고 유기적인 애니메이션
class VoiceSpectrumAnimation extends StatefulWidget {
  final bool isRecording;
  final int barCount;
  final double soundLevel; // 0.0 ~ 1.0

  const VoiceSpectrumAnimation({
    super.key,
    required this.isRecording,
    this.barCount = 5, // 바 개수 줄임 (더 굵고 둥글게)
    this.soundLevel = 0.0,
  });

  @override
  State<VoiceSpectrumAnimation> createState() => _VoiceSpectrumAnimationState();
}

class _VoiceSpectrumAnimationState extends State<VoiceSpectrumAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  
  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              widget.barCount,
              (index) {
                // 중앙 강조형 배치
                final centerDistance = (index - widget.barCount / 2).abs();
                
                // 기본 높이 (숨쉬기 효과 포함)
                final breathing = _breathingController.value * 4.0;
                final baseHeight = 8.0 + breathing;

                // 소리에 반응하는 높이
                // 중앙일수록 더 크게 반응
                final sensitivity = 1.0 - (centerDistance * 0.2); 
                final soundHeight = widget.soundLevel * 40 * sensitivity;
                
                // 최종 높이 계산
                // 급격한 변화를 줄이기 위해 clamp 사용하지만, 
                // 실제로는 상위 위젯에서 soundLevel이 부드럽게 들어오면 더 좋음
                final targetHeight = (baseHeight + soundHeight).clamp(8.0, 40.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80), // 반응 속도 조절
                    curve: Curves.easeOutQuad,
                    width: 6, // 더 굵게
                    height: targetHeight,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF6B4EFF) : const Color(0xFF5835E8), // 브랜드 컬러 사용 (예시)
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
