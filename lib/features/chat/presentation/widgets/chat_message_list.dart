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

        // 일반 메시지
        return ChatMessageBubble(
          message: message,
        );
      },
    );
  }
}

/// 타이핑 인디케이터
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md, // 수평 패딩 추가
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.accentSecondary,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Text(
              '운세를 살펴보고 있어요...',
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
