import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/loading_messages.dart';
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

  /// 타이핑 인디케이터가 렌더링 완료되면 호출됨
  final VoidCallback? onTypingIndicatorRendered;

  /// 운세 결과 카드가 렌더링 완료되면 호출됨
  /// messageId와 context를 전달하여 1회성 스크롤 처리 가능
  final void Function(String messageId, BuildContext context)?
      onFortuneResultRendered;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.messages,
    required this.isTyping,
    required this.onChipTap,
    this.onViewAllTap,
    this.bottomPadding = 0,
    this.onTypingIndicatorRendered,
    this.onFortuneResultRendered,
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
        // 타이핑 인디케이터 (현재 진행 중인 운세 타입 전달)
        if (index == messages.length && isTyping) {
          return _TypingIndicator(
            fortuneType: _findLastFortuneType(messages.length),
            onRendered: onTypingIndicatorRendered,
          );
        }

        final message = messages[index];

        // 시스템 메시지 (추천 칩) - 스마트 추천 적용
        if (message.type == ChatMessageType.system) {
          // __all__ 마커: 모든 기본 칩 표시 (전체운세보기)
          final showAll = message.chipIds?.contains('__all__') == true;

          List<RecommendationChip> chips;
          if (showAll) {
            chips = defaultChips;
          } else {
            final lastFortuneType = _findLastFortuneType(index);
            chips = lastFortuneType != null
                ? ref.watch(smartRecommendationProvider(lastFortuneType))
                : defaultChips.take(4).toList();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DSSpacing.md,
              horizontal: DSSpacing.md,
            ),
            child: FortuneChipGrid(
              chips: chips,
              onChipTap: onChipTap,
              showViewAll: !showAll && _findLastFortuneType(index) != null,
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
          onFortuneResultRendered: onFortuneResultRendered,
        );
      },
    );
  }
}

/// 타이핑 인디케이터 - 운세별 맞춤 텍스트 + 전통 매듭 스타일
class _TypingIndicator extends StatefulWidget {
  final String? fortuneType;

  /// 렌더링 완료 시 호출되는 콜백
  final VoidCallback? onRendered;

  const _TypingIndicator({this.fortuneType, this.onRendered});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late List<String> _messages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 운세 타입별 맞춤 메시지 + 랜덤 셔플
    _messages = List<String>.from(LoadingMessages.getMessages(widget.fortuneType))
      ..shuffle(Random());

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _startMessageRolling();

    // 렌더링 완료 후 콜백 호출 (스크롤용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRendered?.call();
    });
  }

  void _startMessageRolling() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _nextMessage();
    });
  }

  void _nextMessage() async {
    await _controller.reverse();
    if (!mounted) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _messages.length;
    });

    await _controller.forward();
    if (mounted) _startMessageRolling();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            _messages[_currentIndex],
            style: context.bodySmall.copyWith(
              color: isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
