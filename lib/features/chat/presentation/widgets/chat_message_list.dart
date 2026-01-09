import 'dart:math';

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
        );
      },
    );
  }
}

/// 타이핑 인디케이터 - 재미있는 텍스트 + 전통 매듭 스타일
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late List<String> _messages;
  int _currentIndex = 0;

  // 재미있고 위트있는 로딩 메시지 50개
  static const List<String> _funMessages = [
    // 우주/신비 테마
    '우주에서 당신의 별을 찾는 중 ✨',
    '은하수 저편에서 답을 가져오는 중...',
    '별똥별에게 부탁하는 중이에요',
    '달님께 여쭤보고 있어요 🌙',
    '북극성이 방향을 알려주는 중...',
    // 귀여운/재미있는
    '운세 요정이 열심히 일하는 중 🧚',
    'AI가 커피 한 잔 마시고 올게요 ☕',
    '점쟁이 할머니가 준비 중이에요',
    '수정 구슬을 닦고 있어요 🔮',
    '타로 카드가 스트레칭 중...',
    // 유머러스
    '로딩이 좀 걸리지만 결과는 찐이에요',
    '좋은 운세는 시간이 걸리는 법...',
    '급하게 먹은 떡이 체하듯... 잠시만요',
    '천천히 가는 것도 멋진 일이에요',
    '우주의 와이파이가 좀 느려요 📡',
    // 동기부여/긍정
    '좋은 소식을 준비하고 있어요!',
    '오늘도 좋은 하루가 될 거예요',
    '행운이 당신을 찾아가는 중...',
    '긍정의 기운을 모으고 있어요 💪',
    '희망찬 메시지가 곧 도착해요',
    // 신비로운
    '고대의 지혜를 불러오는 중...',
    '점성술 계산기가 바쁘게 돌아가는 중',
    '음양오행의 조화를 맞추고 있어요',
    '천간지지가 회의 중이에요',
    '12지신들이 투표하고 있어요',
    // 재치있는
    '운명의 빨래를 개고 있어요 🧺',
    '행운의 배달부가 출발했어요 🚚',
    '운세 택배가 배송 중...',
    '당신의 미래가 렌더링 중입니다',
    '버퍼링... 아니 점보링 중! 🎱',
    // 계절/자연
    '봄바람에 운세를 실어 보내요 🍃',
    '무지개 너머에서 답을 찾는 중 🌈',
    '네잎클로버를 열심히 찾고 있어요 🍀',
    '행운의 바람이 불어오는 중...',
    '꽃잎이 운세를 알려줄 거예요 🌸',
    // 동물 테마
    '길냥이가 귀띔해주는 중... 🐱',
    '부엉이 박사가 분석 중이에요 🦉',
    '드래곤이 예언을 전해주러 와요 🐉',
    '행운의 두꺼비가 생각 중... 🐸',
    '황금거북이가 점괘를 내리는 중 🐢',
    // 테크+점술 믹스
    'AI 점쟁이가 딥러닝 중...',
    '클라우드 위 신선이 내려오는 중',
    '운세 서버가 열심히 연산 중...',
    '블록체인 위에 운명을 기록 중...',
    '알고리즘이 별자리를 계산 중...',
    // 감성적
    '소중한 당신을 위한 메시지 준비 중',
    '마음을 담아 결과를 만들고 있어요 💝',
    '정성을 다해 분석하고 있어요',
    '당신의 행복을 빌며 기다려주세요',
    '좋은 기운을 담아 가져올게요',
  ];

  @override
  void initState() {
    super.initState();
    // 랜덤 셔플
    _messages = List<String>.from(_funMessages)..shuffle(Random());

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _startMessageRolling();
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TraditionalKnotIndicator(
              size: 20,
              duration: Duration(seconds: 2),
            ),
            const SizedBox(width: DSSpacing.sm),
            Flexible(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _messages[_currentIndex],
                  style: DSTypography.bodySmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
