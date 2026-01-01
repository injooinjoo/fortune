import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/design_system.dart';
import '../../data/popular_dream_topics.dart';

/// 몽글몽글 떠다니는 꿈 버블 위젯
///
/// 15개의 랜덤 꿈 주제를 플로팅 버블 형태로 표시하고
/// 사용자가 선택할 수 있도록 합니다.
class FloatingDreamBubbles extends StatefulWidget {
  /// 버블 선택 시 콜백
  final Function(DreamTopic) onTopicSelected;

  /// 표시할 버블 개수 (기본 15개)
  final int bubbleCount;

  /// F14: 미리 로드된 토픽 목록 (성능 최적화)
  /// null이면 initState에서 랜덤 선택
  final List<DreamTopic>? preloadedTopics;

  /// 채팅용 컴팩트 모드 (배경 숨김, 여백 축소)
  final bool isCompact;

  const FloatingDreamBubbles({
    super.key,
    required this.onTopicSelected,
    this.bubbleCount = 15,
    this.preloadedTopics,
    this.isCompact = false,
  });

  @override
  State<FloatingDreamBubbles> createState() => _FloatingDreamBubblesState();
}

class _FloatingDreamBubblesState extends State<FloatingDreamBubbles> {
  late List<DreamTopic> _displayedTopics;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // F14: 미리 로드된 토픽이 있으면 사용, 없으면 새로 생성
    _displayedTopics = widget.preloadedTopics ??
        PopularDreamTopics.getRandomTopics(widget.bubbleCount);
  }

  /// 버블 새로고침 (다른 15개 랜덤 선택)
  void refreshBubbles() {
    setState(() {
      _displayedTopics = PopularDreamTopics.getRandomTopics(widget.bubbleCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 배경 그라디언트 - 컴팩트 모드에서는 숨김
        if (!widget.isCompact)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  colors.background,
                  colors.backgroundSecondary,
                  colors.surface,
                ],
              ),
            ),
          ),

        // 플로팅 버블들
        ..._displayedTopics.asMap().entries.map((entry) {
          final index = entry.key;
          final topic = entry.value;
          return _buildFloatingBubble(
            context: context,
            topic: topic,
            index: index,
            screenSize: size,
          );
        }),

        // 새로고침 버튼 (하단) - 컴팩트 모드에서는 위치 조정
        Positioned(
          bottom: widget.isCompact ? 10 : 100,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: refreshBubbles,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg, vertical: DSSpacing.sm + 4),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(DSRadius.xl + 6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '다른 꿈 보기',
                      style: typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBubble({
    required BuildContext context,
    required DreamTopic topic,
    required int index,
    required Size screenSize,
  }) {
    final typography = context.typography;

    // 버블 위치 계산 (화면 전체에 분산)
    final positions = _generateBubblePositions(screenSize, _displayedTopics.length);
    final position = positions[index];

    // 버블 크기 (랜덤 variation)
    final baseSize = 80 + _random.nextDouble() * 40;

    // 애니메이션 딜레이 (순차적으로 나타남)
    final delay = index * 80;

    // 플로팅 오프셋 (각 버블마다 다른 움직임)
    final floatOffsetX = (_random.nextDouble() - 0.5) * 20;
    final floatOffsetY = (_random.nextDouble() - 0.5) * 15;
    final floatDuration = 3000 + _random.nextInt(2000);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          debugPrint('🫧 [DreamBubbles] 버블 탭: ${topic.title} (${topic.id})');
          widget.onTopicSelected(topic);
        },
        child: _DreamBubble(
          topic: topic,
          size: baseSize,
          typography: typography,
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveX(
              begin: 0,
              end: floatOffsetX,
              duration: Duration(milliseconds: floatDuration),
              curve: Curves.easeInOut,
            )
            .moveY(
              begin: 0,
              end: floatOffsetY,
              duration: Duration(milliseconds: floatDuration + 500),
              curve: Curves.easeInOut,
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
            .scale(
              begin: const Offset(0.3, 0.3),
              end: const Offset(1.0, 1.0),
              delay: Duration(milliseconds: delay),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
      ),
    );
  }

  /// 버블 위치를 화면에 고르게 분산
  List<Offset> _generateBubblePositions(Size screenSize, int count) {
    final positions = <Offset>[];
    // 컴팩트 모드에서는 패딩과 여백 축소
    final padding = widget.isCompact ? 20.0 : 60.0;
    final availableWidth = screenSize.width - padding * 2;
    // 컴팩트 모드: 제한된 높이에 맞춤, 일반 모드: 상하단 여백
    final availableHeight = widget.isCompact
        ? screenSize.height - 60  // 컴팩트: 하단 버튼 여백만
        : screenSize.height - 280;

    // 그리드 기반 배치 + 약간의 랜덤 오프셋
    final cols = 3;
    final rows = (count / cols).ceil();
    final cellWidth = availableWidth / cols;
    final cellHeight = availableHeight / rows;

    // 컴팩트 모드: 상단 여백 축소
    final topOffset = widget.isCompact ? 20.0 : 120.0;

    for (int i = 0; i < count; i++) {
      final col = i % cols;
      final row = i ~/ cols;

      // 셀 내에서 랜덤 위치
      final randomOffsetX = (_random.nextDouble() - 0.5) * (cellWidth * 0.5);
      final randomOffsetY = (_random.nextDouble() - 0.5) * (cellHeight * 0.4);

      final x = padding + col * cellWidth + cellWidth / 2 - 50 + randomOffsetX;
      final y = topOffset + row * cellHeight + cellHeight / 2 - 50 + randomOffsetY;

      positions.add(Offset(
        x.clamp(10, screenSize.width - 110),
        y.clamp(widget.isCompact ? 10 : 100, screenSize.height - (widget.isCompact ? 80 : 200)),
      ));
    }

    return positions;
  }
}

/// 개별 꿈 버블 위젯
class _DreamBubble extends StatelessWidget {
  final DreamTopic topic;
  final double size;
  final DSTypographyScheme typography;

  const _DreamBubble({
    required this.topic,
    required this.size,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    // 카테고리별 색상
    final color = _getCategoryColor(topic.category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.5),
            color.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topic.emoji,
              style: TextStyle(fontSize: size * 0.35),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
              child: Text(
                topic.title.replaceAll(' 꿈', ''),
                style: typography.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: size * 0.12,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '동물':
        return const Color(0xFF4ECDC4); // 민트
      case '재물':
        return const Color(0xFFFFD93D); // 골드
      case '행동':
        return const Color(0xFF6C5CE7); // 퍼플
      case '사람':
        return const Color(0xFFFF6B9D); // 핑크
      case '자연':
        return const Color(0xFF00B894); // 그린
      case '장소':
        return const Color(0xFF74B9FF); // 블루
      default:
        return const Color(0xFF8B5CF6); // 기본 퍼플
    }
  }
}
