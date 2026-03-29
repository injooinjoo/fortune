import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/widgets/smart_image.dart';
import 'package:ondo/core/utils/haptic_utils.dart';
import '../../../chat/presentation/widgets/chat_saju_result_card.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../utils/character_accent_palette.dart';
import '../utils/character_chat_surface_style.dart';
import 'affinity_change_indicator.dart';
import 'embedded_fortune_component.dart';

/// 캐릭터 채팅 메시지 버블 (4종)
/// - user: 오른쪽 정렬
/// - character: 왼쪽 정렬 + 아바타
/// - system: 중앙 정렬
/// - narration: 중앙 정렬 + 이탤릭
class CharacterMessageBubble extends StatelessWidget {
  final CharacterChatMessage message;
  final AiCharacter character;
  final bool showAvatar;

  const CharacterMessageBubble({
    super.key,
    required this.message,
    required this.character,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case CharacterChatMessageType.user:
        return _buildUserBubble(context);
      case CharacterChatMessageType.character:
        return _buildCharacterBubble(context);
      case CharacterChatMessageType.system:
        return _buildSystemBubble(context);
      case CharacterChatMessageType.narration:
        return _buildNarrationBubble(context);
      case CharacterChatMessageType.choice:
        // 선택지는 CharacterChoiceWidget에서 별도로 렌더링됨
        return const SizedBox.shrink();
    }
  }

  /// 유저 메시지 (오른쪽) - GPT 스타일
  Widget _buildUserBubble(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: CharacterChatSurfaceStyle.messageSideInset),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 이미지 썸네일 (사진 메시지인 경우)
                if (message.hasImage && message.imageAsset != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ClipRRect(
                      borderRadius:
                          CharacterChatSurfaceStyle.mediaBorderRadius(),
                      child: Image.file(
                        File(message.imageAsset!),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: colors.surfaceSecondary,
                            borderRadius:
                                CharacterChatSurfaceStyle.mediaBorderRadius(),
                          ),
                          child:
                              const Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
                    ),
                  ),
                // 텍스트 버블 (이미지만 있고 텍스트가 📷 사진인 경우 숨김)
                if (!message.hasImage ||
                    (message.text != '📷 사진' && message.text.isNotEmpty))
                  Container(
                    padding: CharacterChatSurfaceStyle.bubblePadding,
                    decoration: CharacterChatSurfaceStyle.bubbleDecoration(
                      context,
                      backgroundColor: colors.userBubble,
                      borderRadius:
                          CharacterChatSurfaceStyle.outgoingBubbleRadius(),
                      borderAlpha: 0.42,
                    ),
                    child: Text(
                      message.text,
                      style: context.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 캐릭터 메시지 (왼쪽 + 아바타) - 그림자로 구분되는 떠다니는 버블
  Widget _buildCharacterBubble(BuildContext context) {
    final colors = context.colors;
    final accentPalette = CharacterAccentPalette.from(
      source: character.accentColor,
      brightness: Theme.of(context).brightness,
    );

    if (message.hasSajuData) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: showAvatar ? 4 : 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              _buildAvatar(context, accentPalette),
              const SizedBox(height: DSSpacing.xs),
            ],
            ChatSajuResultCard(
              sajuData: message.sajuData!,
              margin: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
            ),
          ],
        ),
      );
    }

    if (message.hasEmbeddedWidget &&
        EmbeddedFortuneComponent.supportsType(message.embeddedWidgetType)) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: showAvatar ? 4 : 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              _buildAvatar(context, accentPalette),
              const SizedBox(height: DSSpacing.xs),
            ],
            EmbeddedFortuneComponent(
              embeddedWidgetType: message.embeddedWidgetType!,
              componentData: message.componentData!,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: showAvatar ? DSSpacing.xs : DSSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar)
            _buildAvatar(context, accentPalette)
          else
            const SizedBox(width: 32),
          const SizedBox(width: CharacterChatSurfaceStyle.avatarGap),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지가 있으면 먼저 표시 (점심 사진 등)
                if (message.hasImage) _buildImageBubble(context, colors),
                // 텍스트 버블
                if (message.text.isNotEmpty)
                  GestureDetector(
                    onLongPress: () => _showReportMenu(context),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: CharacterChatSurfaceStyle.bubblePadding,
                          decoration:
                              CharacterChatSurfaceStyle.bubbleDecoration(
                            context,
                            backgroundColor: colors.surface,
                            borderRadius:
                                CharacterChatSurfaceStyle.incomingBubbleRadius(
                              hasLeadingMedia: message.hasImage,
                            ),
                            borderAlpha: 0.45,
                          ),
                          child: _buildFormattedText(context, message.text),
                        ),
                        // 호감도 변경 인디케이터 (버블 우측 상단)
                        if (message.affinityChange != null &&
                            message.affinityChange != 0)
                          Positioned(
                            top: -8,
                            right: -2,
                            child: AffinityChangeIndicator(
                              change: message.affinityChange!,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: CharacterChatSurfaceStyle.messageSideInset),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    CharacterAccentPalette accentPalette,
  ) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/character/${character.id}', extra: character);
      },
      child: CircleAvatar(
        radius: 16,
        backgroundColor: accentPalette.accent,
        backgroundImage: character.avatarAsset.isNotEmpty
            ? AssetImage(character.avatarAsset)
            : null,
        child: character.avatarAsset.isEmpty
            ? Text(
                character.initial,
                style: context.labelMedium.copyWith(
                  color: accentPalette.onAccent,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  /// 이미지 버블 (점심 사진 등 proactive 메시지용)
  Widget _buildImageBubble(BuildContext context, DSColorScheme colors) {
    final imagePath =
        (message.imageAsset != null && message.imageAsset!.isNotEmpty)
            ? message.imageAsset!
            : message.imageUrl;
    if (imagePath == null || imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    final fallbackIcon = switch (message.mediaCategory) {
      CharacterMediaCategory.selfie => Icons.photo_camera_front,
      CharacterMediaCategory.meal => Icons.restaurant,
      CharacterMediaCategory.cafe => Icons.local_cafe,
      CharacterMediaCategory.commute => Icons.directions_transit,
      CharacterMediaCategory.workout => Icons.fitness_center,
      CharacterMediaCategory.night => Icons.nights_stay,
      null => Icons.image,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        borderRadius: CharacterChatSurfaceStyle.mediaBorderRadius(),
        boxShadow: CharacterChatSurfaceStyle.shadow(
          context,
          alpha: 0.08,
          blurRadius: 14,
        ),
      ),
      child: ClipRRect(
        borderRadius: CharacterChatSurfaceStyle.mediaBorderRadius(),
        child: SmartImage(
          path: imagePath,
          width: 220,
          height: 150,
          fit: BoxFit.cover,
          errorWidget: Container(
            width: 220,
            height: 150,
            color: colors.backgroundSecondary,
            child: Center(
              child: Icon(
                fallbackIcon,
                size: 48,
                color: colors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 시스템 메시지 (중앙) - GPT 스타일
  Widget _buildSystemBubble(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: CharacterChatSurfaceStyle.mediaBorderRadius(),
            boxShadow: CharacterChatSurfaceStyle.shadow(
              context,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ),
          child: Text(
            message.text,
            style: context.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// 나레이션 메시지 (중앙 + 이탤릭) - GPT 스타일
  Widget _buildNarrationBubble(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Center(
        child: Text(
          message.text,
          style: context.bodySmall.copyWith(
            color: colors.textTertiary,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 마크다운 포맷 텍스트 - **bold**, *italic*, 줄바꿈 자동 처리
  Widget _buildFormattedText(BuildContext context, String text) {
    final colors = context.colors;
    final baseStyle = context.bodyMedium.copyWith(
      color: colors.textPrimary,
      height: 1.6,
    );

    return MarkdownBody(
      data: text,
      shrinkWrap: true,
      softLineBreak: true,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        // 본문
        p: baseStyle,
        pPadding: EdgeInsets.zero,
        // 볼드
        strong: baseStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        // 이탤릭
        em: baseStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: colors.textSecondary,
        ),
        // 리스트
        listBullet: baseStyle.copyWith(
          color: colors.textTertiary,
          fontSize: 12,
        ),
        listBulletPadding: const EdgeInsets.only(right: 4),
        listIndent: 16,
        // 문단 간격
        blockSpacing: 8,
        // 인라인 코드
        code: baseStyle.copyWith(
          fontSize: 13,
          backgroundColor: colors.backgroundSecondary,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        // 헤딩 (AI 응답에 가끔 포함)
        h1: context.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: colors.textPrimary,
          height: 1.4,
        ),
        h2: context.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: colors.textPrimary,
          height: 1.4,
        ),
        h3: context.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: colors.textPrimary,
          height: 1.4,
        ),
        // 구분선
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colors.border.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showReportMenu(BuildContext context) {
    HapticUtils.lightImpact();
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: colors.error),
              title: Text(
                'Report inappropriate content\n부적절한 콘텐츠 신고',
                style: context.bodySmall.copyWith(color: colors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Report submitted. Thank you.\n신고가 접수되었습니다. 감사합니다.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
