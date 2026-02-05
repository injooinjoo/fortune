import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fortune/core/design_system/design_system.dart';
import '../../presentation/providers/content_interaction_provider.dart';
import '../../services/fortune_share_service.dart';

/// 결과 카드용 좋아요 + 공유 버튼 컴포넌트
class FortuneActionButtons extends ConsumerStatefulWidget {
  /// 콘텐츠 고유 ID
  final String contentId;

  /// 콘텐츠 타입 (fortune, tarot, saju 등)
  final String contentType;

  /// fortune_history ID (공유 기록용)
  final String? fortuneHistoryId;

  /// 공유 시 표시될 제목
  final String shareTitle;

  /// 공유 시 표시될 내용
  final String shareContent;

  /// 사용자 이름 (공유 메시지용)
  final String? userName;

  /// 공유용 이미지 데이터
  final Uint8List? shareImage;

  /// 캡처용 GlobalKey (위젯 스크린샷)
  final GlobalKey? captureKey;

  /// 운세 타입 (딥링크용, 예: "daily", "love", "tarot")
  final String? fortuneType;

  /// 아이콘 크기
  final double iconSize;

  /// 아이콘 색상 (null이면 테마 기본)
  final Color? iconColor;

  /// 버튼 간격
  final double spacing;

  const FortuneActionButtons({
    super.key,
    required this.contentId,
    required this.contentType,
    this.fortuneHistoryId,
    this.shareTitle = '',
    this.shareContent = '',
    this.userName,
    this.shareImage,
    this.captureKey,
    this.fortuneType,
    this.iconSize = 22,
    this.iconColor,
    this.spacing = 8,
  });

  @override
  ConsumerState<FortuneActionButtons> createState() => _FortuneActionButtonsState();
}

class _FortuneActionButtonsState extends ConsumerState<FortuneActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playHeartAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultColor = context.colors.textTertiary;
    final iconColor = widget.iconColor ?? defaultColor;

    final interactionState = ref.watch(contentInteractionProvider(widget.contentId));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 좋아요 버튼
        _LikeButton(
          isSaved: interactionState.isSaved,
          isLoading: interactionState.isLoading,
          iconSize: widget.iconSize,
          iconColor: iconColor,
          scaleAnimation: _scaleAnimation,
          onTap: () => _handleLikeTap(interactionState.isSaved),
        ),
        SizedBox(width: widget.spacing),
        // 공유 버튼
        _ShareButton(
          iconSize: widget.iconSize,
          iconColor: iconColor,
          onTap: _handleShareTap,
        ),
      ],
    );
  }

  Future<void> _handleLikeTap(bool currentState) async {
    // 햅틱 피드백
    HapticFeedback.lightImpact();

    // 애니메이션 재생
    if (!currentState) {
      _playHeartAnimation();
    }

    // 상태 토글
    await ref.read(contentInteractionProvider(widget.contentId).notifier).toggleSave(
          contentType: widget.contentType,
        );
  }

  Future<void> _handleShareTap() async {
    HapticFeedback.lightImpact();

    final shareService = FortuneShareService();
    Uint8List? imageData = widget.shareImage;

    // 캡처 키가 있으면 위젯 캡처
    if (imageData == null && widget.captureKey != null) {
      imageData = await shareService.captureWidget(widget.captureKey!);
    }

    if (!mounted) return;

    await shareService.showShareSheet(
      context: context,
      contentId: widget.contentId,
      contentType: widget.contentType,
      title: widget.shareTitle,
      content: widget.shareContent,
      userName: widget.userName,
      previewImage: imageData,
      fortuneHistoryId: widget.fortuneHistoryId,
      fortuneType: widget.fortuneType,
    );
  }
}

/// 좋아요 버튼 (하트)
class _LikeButton extends StatelessWidget {
  final bool isSaved;
  final bool isLoading;
  final double iconSize;
  final Color iconColor;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const _LikeButton({
    required this.isSaved,
    required this.isLoading,
    required this.iconSize,
    required this.iconColor,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSaved ? scaleAnimation.value : 1.0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_outline,
                  key: ValueKey(isSaved),
                  size: iconSize,
                  color: isSaved ? DSColors.error : iconColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 공유 버튼
class _ShareButton extends StatelessWidget {
  final double iconSize;
  final Color iconColor;
  final VoidCallback onTap;

  const _ShareButton({
    required this.iconSize,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.share_outlined,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}

/// 간단한 좋아요 버튼만 필요한 경우
class LikeOnlyButton extends ConsumerWidget {
  final String contentId;
  final String contentType;
  final double iconSize;
  final Color? iconColor;

  const LikeOnlyButton({
    super.key,
    required this.contentId,
    required this.contentType,
    this.iconSize = 22,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultColor = context.colors.textTertiary;
    final color = iconColor ?? defaultColor;

    final interactionState = ref.watch(contentInteractionProvider(contentId));

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await ref.read(contentInteractionProvider(contentId).notifier).toggleSave(
              contentType: contentType,
            );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          interactionState.isSaved ? Icons.favorite : Icons.favorite_outline,
          size: iconSize,
          color: interactionState.isSaved ? DSColors.error : color,
        ),
      ),
    );
  }
}

/// 간단한 공유 버튼만 필요한 경우
class ShareOnlyButton extends StatelessWidget {
  final String contentId;
  final String contentType;
  final String shareTitle;
  final String shareContent;
  final Uint8List? shareImage;
  final double iconSize;
  final Color? iconColor;

  const ShareOnlyButton({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.shareTitle,
    required this.shareContent,
    this.shareImage,
    this.iconSize = 22,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = context.colors.textTertiary;
    final color = iconColor ?? defaultColor;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final shareService = FortuneShareService();
        await shareService.showShareSheet(
          context: context,
          contentId: contentId,
          contentType: contentType,
          title: shareTitle,
          content: shareContent,
          previewImage: shareImage,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.share_outlined,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
