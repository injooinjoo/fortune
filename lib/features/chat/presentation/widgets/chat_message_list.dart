import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/recommendation_chip.dart';
import 'chat_message_bubble.dart';
import 'fortune_chip_grid.dart';

/// 채팅 메시지 리스트
class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isTyping;
  final void Function(RecommendationChip chip) onChipTap;
  final double bottomPadding;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.messages,
    required this.isTyping,
    required this.onChipTap,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      // 부드러운 스크롤 physics
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      // 수직 패딩만 적용 (수평 패딩은 개별 메시지에서 처리)
      // 운세 결과 카드가 전체 너비를 사용할 수 있도록 함
      // bottomPadding: 떠다니는 입력란 공간 확보
      padding: EdgeInsets.fromLTRB(0, DSSpacing.md, 0, DSSpacing.md + bottomPadding),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // 타이핑 인디케이터
        if (index == messages.length && isTyping) {
          return const _TypingIndicator();
        }

        final message = messages[index];

        // 시스템 메시지 (추천 칩) - 수평 패딩 포함
        if (message.type == ChatMessageType.system) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DSSpacing.md,
              horizontal: DSSpacing.md,
            ),
            child: FortuneChipGrid(
              chips: defaultChips,
              onChipTap: onChipTap,
            ),
          );
        }

        // 온보딩 입력 메시지는 표시하지 않음 (하단 입력란 사용)
        if (message.type == ChatMessageType.onboardingInput) {
          return const SizedBox.shrink();
        }

        // 일반 메시지
        return ChatMessageBubble(
          message: message,
        );
      },
    );
  }
}

/// 타이핑 인디케이터 - 점 3개 bounce 애니메이션
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // 순차적으로 애니메이션 시작
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index < 2 ? 6 : 0,
                  ),
                  child: Transform.translate(
                    offset: Offset(0, _animations[index].value),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
