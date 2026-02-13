import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import 'affinity_change_indicator.dart';

/// 캐릭터 채팅 메시지 버블 (4종)
/// - user: 오른쪽 정렬
/// - character: 왼쪽 정렬 + 아바타
/// - system: 중앙 정렬
/// - narration: 중앙 정렬 + 이탤릭
class CharacterMessageBubble extends StatelessWidget {
  final CharacterChatMessage message;
  final AiCharacter character;

  const CharacterMessageBubble({
    super.key,
    required this.message,
    required this.character,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 48), // 왼쪽 여백
          // 읽음 표시 (메시지 왼쪽에 "1" 표시)
          if (message.status == MessageStatus.sent)
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 4),
              child: Text(
                '1',
                style: context.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.userBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: context.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 캐릭터 메시지 (왼쪽 + 아바타) - 그림자로 구분되는 떠다니는 버블
  Widget _buildCharacterBubble(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/character/${character.id}', extra: character);
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: character.accentColor,
              backgroundImage: character.avatarAsset.isNotEmpty
                  ? AssetImage(character.avatarAsset)
                  : null,
              child: character.avatarAsset.isEmpty
                  ? Text(
                      character.initial,
                      style: context.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지가 있으면 먼저 표시 (점심 사진 등)
                if (message.hasImage) _buildImageBubble(context, colors),
                // 텍스트 버블
                if (message.text.isNotEmpty)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(message.hasImage ? 20 : 4),
                            topRight: const Radius.circular(20),
                            bottomLeft: const Radius.circular(20),
                            bottomRight: const Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildFormattedText(context, message.text),
                      ),
                      // 호감도 변경 인디케이터 (버블 우측 상단)
                      if (message.affinityChange != null &&
                          message.affinityChange != 0)
                        Positioned(
                          top: -8,
                          right: -4,
                          child: AffinityChangeIndicator(
                            change: message.affinityChange!,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 48), // 오른쪽 여백
        ],
      ),
    );
  }

  /// 이미지 버블 (점심 사진 등 proactive 메시지용)
  Widget _buildImageBubble(BuildContext context, DSColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          message.imageAsset!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 이미지 로드 실패 시 placeholder
            return Container(
              width: 200,
              height: 150,
              color: colors.backgroundSecondary,
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 48,
                  color: colors.textTertiary,
                ),
              ),
            );
          },
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
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

  /// 포맷된 텍스트 (별표로 감싼 부분은 이탤릭) - GPT 스타일
  Widget _buildFormattedText(BuildContext context, String text) {
    final colors = context.colors;
    // 별표로 감싼 부분을 이탤릭으로 표시
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\*([^*]+)\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // 일반 텍스트
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: context.bodyMedium.copyWith(
            color: colors.textPrimary,
            height: 1.5,
          ),
        ));
      }
      // 이탤릭 텍스트
      parts.add(TextSpan(
        text: match.group(1),
        style: context.bodyMedium.copyWith(
          fontStyle: FontStyle.italic,
          color: colors.textSecondary,
          height: 1.5,
        ),
      ));
      lastEnd = match.end;
    }

    // 나머지 텍스트
    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: context.bodyMedium.copyWith(
          color: colors.textPrimary,
          height: 1.5,
        ),
      ));
    }

    if (parts.isEmpty) {
      return Text(
        text,
        style: context.bodyMedium.copyWith(
          color: colors.textPrimary,
          height: 1.5,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: colors.textPrimary),
        children: parts,
      ),
    );
  }
}
