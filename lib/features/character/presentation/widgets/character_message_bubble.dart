import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';

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

  /// 유저 메시지 (오른쪽) - 읽음 표시 포함
  Widget _buildUserBubble(BuildContext context) {
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
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: character.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: context.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 캐릭터 메시지 (왼쪽 + 아바타) - 아바타 탭 시 프로필 페이지로 이동
  Widget _buildCharacterBubble(BuildContext context) {
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: _buildFormattedText(context, message.text),
            ),
          ),
          const SizedBox(width: 48), // 오른쪽 여백
        ],
      ),
    );
  }

  /// 시스템 메시지 (중앙)
  Widget _buildSystemBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.text,
            style: context.bodySmall.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// 나레이션 메시지 (중앙 + 이탤릭)
  Widget _buildNarrationBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Center(
        child: Text(
          message.text,
          style: context.bodySmall.copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 포맷된 텍스트 (별표로 감싼 부분은 이탤릭)
  Widget _buildFormattedText(BuildContext context, String text) {
    // 별표로 감싼 부분을 이탤릭으로 표시
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\*([^*]+)\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // 일반 텍스트
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: context.bodyMedium,
        ));
      }
      // 이탤릭 텍스트
      parts.add(TextSpan(
        text: match.group(1),
        style: context.bodyMedium.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ));
      lastEnd = match.end;
    }

    // 나머지 텍스트
    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: context.bodyMedium,
      ));
    }

    if (parts.isEmpty) {
      return Text(text, style: context.bodyMedium);
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.grey[800]),
        children: parts,
      ),
    );
  }
}
