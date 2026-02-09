import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/ai_character.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_provider.dart';
import '../providers/sorted_characters_provider.dart';
import '../widgets/wave_typing_indicator.dart';

/// DM 목록 패널 (인스타그램 DM 스타일)
class CharacterListPanel extends ConsumerWidget {
  final void Function(AiCharacter character) onCharacterSelected;
  final bool isOverlay;
  final VoidCallback? onDismiss;

  const CharacterListPanel({
    super.key,
    required this.onCharacterSelected,
    this.isOverlay = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 정렬된 캐릭터 목록 사용 (타이핑 > 새 메시지 > 최근 대화 순)
    final characters = ref.watch(sortedCharactersProvider);

    return GestureDetector(
      onHorizontalDragEnd: isOverlay
          ? (details) {
              // 오른쪽으로 스와이프하면 닫기
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 100) {
                onDismiss?.call();
              }
            }
          : null,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(context),
              const Divider(height: 1),
              // 캐릭터 목록
              Expanded(
                child: ListView.builder(
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return _CharacterListItem(
                      character: character,
                      onTap: () => onCharacterSelected(character),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (isOverlay)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (isOverlay) const SizedBox(width: 12),
          Text(
            '메시지',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit_square, size: 24),
            onPressed: () => _showNewMessageSheet(context),
          ),
        ],
      ),
    );
  }

  void _showNewMessageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NewMessageSheet(
        onCharacterSelected: onCharacterSelected,
      ),
    );
  }
}

/// 캐릭터 목록 아이템 (인스타그램 DM 스타일 + 롱프레스 액션)
class _CharacterListItem extends ConsumerWidget {
  final AiCharacter character;
  final VoidCallback onTap;

  const _CharacterListItem({
    required this.character,
    required this.onTap,
  });

  void _onDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('대화 삭제'),
        content: Text('${character.name}와의 대화를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(characterChatProvider(character.id).notifier).clearConversation();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('알림 끄기'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('보관'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _onDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(characterChatProvider(character.id));
    final hasConversation = chatState.hasConversation;
    final isTyping = chatState.isCharacterTyping;
    final unreadCount = chatState.unreadCount;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showActions(context, ref),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 아바타 + 타이핑 인디케이터 (탭하면 프로필 페이지로 이동)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/character/${character.id}', extra: character);
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: character.accentColor,
                    backgroundImage: character.avatarAsset.isNotEmpty
                        ? AssetImage(character.avatarAsset)
                        : null,
                    child: character.avatarAsset.isEmpty
                        ? Text(
                            character.initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (isTyping)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                        ),
                        child: const Center(
                          child: MiniTypingIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 이름 + 태그 + 마지막 메시지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          character.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!hasConversation) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: character.accentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '새 대화',
                            style: context.labelTiny.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    character.tags.take(3).map((t) => '#$t').join(' '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTyping
                        ? '입력 중...'
                        : (hasConversation ? chatState.lastMessagePreview : character.shortDescription),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isTyping ? character.accentColor : Colors.grey[600],
                          fontWeight: isTyping ? FontWeight.w500 : FontWeight.normal,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 오른쪽: 타임스탬프 또는 읽지 않은 메시지 배지
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasConversation && chatState.lastMessageTime != null)
                  Text(
                    _formatTimestamp(chatState.lastMessageTime!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: unreadCount > 0 ? character.accentColor : Colors.grey,
                          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: character.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: context.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${time.month}/${time.day}';
  }
}

/// 새 대화 시작 바텀시트 (인스타그램 New message 스타일)
class _NewMessageSheet extends ConsumerWidget {
  final void Function(AiCharacter character) onCharacterSelected;

  const _NewMessageSheet({
    required this.onCharacterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(charactersProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '새로운 메시지',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '받는 사람:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '검색',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 추천 목록
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '추천',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            // 캐릭터 목록
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: character.accentColor,
                      child: Text(
                        character.initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      character.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    subtitle: Text(
                      character.shortDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onCharacterSelected(character);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
