import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/design_system.dart';

/// 플로팅 꿈 주제 위젯 - 한 줄씩 번갈아 좌/우로 롤링
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
  // 꿈 주제 목록 (5줄로 나눔)
  static const List<List<String>> _dreamTopicRows = [
    ['이가 빠지는 꿈', '똥을 싸는 꿈', '불이 나는 꿈', '뱀 꿈', '돼지 꿈', '호랑이 꿈', '용 꿈', '귀신 나오는 꿈', '시험 보는 꿈', '지각하는 꿈'],
    ['하늘을 나는 꿈', '추락하는 꿈', '물에 빠지는 꿈', '수영하는 꿈', '큰 파도가 치는 꿈', '돈을 줍는 꿈', '복권 당첨 꿈', '도둑이 드는 꿈', '집이 무너지는 꿈', '자동차 사고 꿈'],
    ['죽는 꿈', '부모님 돌아가시는 꿈', '결혼하는 꿈', '이혼하는 꿈', '임신하는 꿈', '아기를 낳는 꿈', '연인이 바람피는 꿈', '전 애인 나오는 꿈', '벌레가 붙는 꿈', '거미 꿈'],
    ['피를 보는 꿈', '머리카락 빠지는 꿈', '대머리 되는 꿈', '나체로 다니는 꿈', '옷이 찢어지는 꿈', '신발 잃어버리는 꿈', '길을 잃는 꿈', '쫓기는 꿈', '싸우는 꿈', '칼에 찔리는 꿈'],
    ['총 맞는 꿈', '동물에게 쫓기는 꿈', '바다를 보는 꿈', '산을 오르는 꿈', '비 오는 꿈', '큰 똥 꿈', '토하는 꿈', '음식 먹는 꿈', '유명인 나오는 꿈', '고양이 꿈'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_dreamTopicRows.length, (rowIndex) {
        // 짝수 줄은 왼쪽으로, 홀수 줄은 오른쪽으로
        final scrollLeft = rowIndex.isEven;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _RollingChipRow(
            topics: _dreamTopicRows[rowIndex],
            scrollLeft: scrollLeft,
            onTopicSelected: widget.onTopicSelected,
            speed: 20.0 + (rowIndex * 5), // 각 줄마다 약간 다른 속도
          ),
        );
      }),
    );
  }
}

/// 무한 롤링하는 칩 Row
class _RollingChipRow extends StatefulWidget {
  final List<String> topics;
  final bool scrollLeft;
  final Function(String) onTopicSelected;
  final double speed;

  const _RollingChipRow({
    required this.topics,
    required this.scrollLeft,
    required this.onTopicSelected,
    required this.speed,
  });

  @override
  State<_RollingChipRow> createState() => _RollingChipRowState();
}

class _RollingChipRowState extends State<_RollingChipRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onScroll);

    _controller.repeat();

    // 초기 스크롤 위치 설정 (중간에서 시작)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollPosition = maxScroll / 2;
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final delta = widget.speed / 60; // 60fps 기준

    if (widget.scrollLeft) {
      _scrollPosition += delta;
      if (_scrollPosition >= maxScroll) {
        _scrollPosition = 0;
      }
    } else {
      _scrollPosition -= delta;
      if (_scrollPosition <= 0) {
        _scrollPosition = maxScroll;
      }
    }

    _scrollController.jumpTo(_scrollPosition.clamp(0, maxScroll));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 무한 스크롤을 위해 리스트를 3배로 늘림
    final extendedTopics = [...widget.topics, ...widget.topics, ...widget.topics];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: extendedTopics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final topic = extendedTopics[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTopicSelected(topic);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: DSColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                topic,
                style: context.bodyMedium.copyWith(
                  color: DSColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
