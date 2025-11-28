import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 플로팅 꿈 주제 위젯 - 수평으로 흘러가는 애니메이션
class FloatingDreamTopicsWidget extends StatefulWidget {
  final Function(String topic) onTopicSelected;

  const FloatingDreamTopicsWidget({
    super.key,
    required this.onTopicSelected,
  });

  @override
  State<FloatingDreamTopicsWidget> createState() => _FloatingDreamTopicsWidgetState();
}

class _FloatingDreamTopicsWidgetState extends State<FloatingDreamTopicsWidget> {
  // 꿈 주제 목록
  static const List<String> _dreamTopics = [
    '이가 빠지는 꿈',
    '똥을 싸는 꿈',
    '불이 나는 꿈',
    '뱀 꿈',
    '돼지 꿈',
    '호랑이 꿈',
    '용 꿈',
    '귀신 나오는 꿈',
    '시험 보는 꿈',
    '지각하는 꿈',
    '하늘을 나는 꿈',
    '추락하는 꿈',
    '물에 빠지는 꿈',
    '수영하는 꿈',
    '큰 파도가 치는 꿈',
    '돈을 줍는 꿈',
    '복권 당첨 꿈',
    '도둑이 드는 꿈',
    '집이 무너지는 꿈',
    '자동차 사고 꿈',
    '죽는 꿈',
    '부모님 돌아가시는 꿈',
    '결혼하는 꿈',
    '이혼하는 꿈',
    '임신하는 꿈',
    '아기를 낳는 꿈',
    '연인이 바람피는 꿈',
    '전 애인 나오는 꿈',
    '벌레가 붙는 꿈',
    '거미 꿈',
    '피를 보는 꿈',
    '머리카락 빠지는 꿈',
    '대머리 되는 꿈',
    '나체로 다니는 꿈',
    '옷이 찢어지는 꿈',
    '신발 잃어버리는 꿈',
    '길을 잃는 꿈',
    '쫓기는 꿈',
    '싸우는 꿈',
    '칼에 찔리는 꿈',
    '총 맞는 꿈',
    '동물에게 쫓기는 꿈',
    '바다를 보는 꿈',
    '산을 오르는 꿈',
    '비 오는 꿈',
    '큰 똥 꿈',
    '토하는 꿈',
    '음식 먹는 꿈',
    '유명인 나오는 꿈',
  ];

  // 여러 줄의 스크롤 컨트롤러
  final List<ScrollController> _scrollControllers = [];
  final List<Timer> _scrollTimers = [];

  // 줄별로 다른 속도와 방향
  final List<double> _scrollSpeeds = [1.2, 0.8, 1.0, 0.9, 1.1];
  final List<bool> _scrollDirections = [true, false, true, false, true]; // true: 오른쪽→왼쪽

  @override
  void initState() {
    super.initState();
    // 5줄의 스크롤 컨트롤러 생성
    for (int i = 0; i < 5; i++) {
      _scrollControllers.add(ScrollController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrollAnimations();
    });
  }

  void _startScrollAnimations() {
    for (int i = 0; i < _scrollControllers.length; i++) {
      final controller = _scrollControllers[i];
      final speed = _scrollSpeeds[i];
      final goLeft = _scrollDirections[i];

      // 초기 위치 랜덤 설정
      if (controller.hasClients) {
        final maxScroll = controller.position.maxScrollExtent;
        controller.jumpTo(goLeft ? 0 : maxScroll);
      }

      // 스크롤 타이머 시작
      final timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!mounted || !controller.hasClients) return;

        final maxScroll = controller.position.maxScrollExtent;
        final currentScroll = controller.offset;

        if (goLeft) {
          // 왼쪽으로 스크롤
          if (currentScroll >= maxScroll) {
            controller.jumpTo(0);
          } else {
            controller.jumpTo(currentScroll + speed);
          }
        } else {
          // 오른쪽으로 스크롤
          if (currentScroll <= 0) {
            controller.jumpTo(maxScroll);
          } else {
            controller.jumpTo(currentScroll - speed);
          }
        }
      });

      _scrollTimers.add(timer);
    }
  }

  @override
  void dispose() {
    for (final timer in _scrollTimers) {
      timer.cancel();
    }
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 각 줄에 표시할 주제 셔플
  List<String> _getShuffledTopics(int rowIndex) {
    final topics = List<String>.from(_dreamTopics);
    // 각 줄마다 다른 시드로 셔플
    topics.shuffle(Random(rowIndex * 42));
    // 무한 스크롤 효과를 위해 3배로 복제
    return [...topics, ...topics, ...topics];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: List.generate(5, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < 4 ? 12 : 0,
          ),
          child: SizedBox(
            height: 44,
            child: ListView.builder(
              controller: _scrollControllers[rowIndex],
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _getShuffledTopics(rowIndex).length,
              itemBuilder: (context, index) {
                final topics = _getShuffledTopics(rowIndex);
                final topic = topics[index % topics.length];

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _DreamTopicChip(
                    topic: topic,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onTopicSelected(topic);
                    },
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

/// 개별 꿈 주제 칩
class _DreamTopicChip extends StatelessWidget {
  final String topic;
  final bool isDark;
  final VoidCallback onTap;

  const _DreamTopicChip({
    required this.topic,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? TossDesignSystem.surfaceBackgroundDark
              : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? TossDesignSystem.gray700
                : TossDesignSystem.gray200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          topic,
          style: TypographyUnified.bodyMedium.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
