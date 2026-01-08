import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/recommendation_chip.dart';
import '../providers/smart_recommendation_provider.dart';
import 'chat_message_bubble.dart';
import 'fortune_chip_grid.dart';

/// 채팅 메시지 리스트
class ChatMessageList extends ConsumerWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isTyping;
  final void Function(RecommendationChip chip) onChipTap;
  final VoidCallback? onViewAllTap;
  final double bottomPadding;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.messages,
    required this.isTyping,
    required this.onChipTap,
    this.onViewAllTap,
    this.bottomPadding = 0,
  });

  /// 이전 메시지에서 마지막 운세 타입 찾기
  String? _findLastFortuneType(int currentIndex) {
    for (int i = currentIndex - 1; i >= 0; i--) {
      final msg = messages[i];
      if (msg.type == ChatMessageType.fortuneResult && msg.fortuneType != null) {
        return msg.fortuneType;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        // 시스템 메시지 (추천 칩) - 스마트 추천 적용
        if (message.type == ChatMessageType.system) {
          final lastFortuneType = _findLastFortuneType(index);
          final chips = lastFortuneType != null
              ? ref.watch(smartRecommendationProvider(lastFortuneType))
              : defaultChips.take(4).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DSSpacing.md,
              horizontal: DSSpacing.md,
            ),
            child: FortuneChipGrid(
              chips: chips,
              onChipTap: onChipTap,
              showViewAll: lastFortuneType != null,
              onViewAllTap: onViewAllTap,
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

/// 타이핑 인디케이터 - 전통 매듭 스타일 (구름 말풍선 + 吉祥結 회전)
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: CloudBubble(
        type: CloudBubbleType.ai,
        showInkBleed: true,
        cornerAsset: 'assets/images/chat/corner_motif.svg',
        cornerSize: 16,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        child: const TraditionalKnotIndicator(
          size: 24,
          duration: Duration(seconds: 2),
        ),
      ),
    );
  }
}
