import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../data/services/character_localizer.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_provider.dart';
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
    // 현재 탭에 맞는 캐릭터 목록 사용
    final currentTab = ref.watch(characterListTabProvider);
    final characters = ref.watch(currentTabCharactersProvider);

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
              _buildHeader(context, ref),
              // 탭 바
              _CharacterTabBar(
                currentTab: currentTab,
                onTabChanged: (tab) {
                  ref.read(characterListTabProvider.notifier).state = tab;
                },
              ),
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

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileNotifierProvider).valueOrNull;
    final profileImageUrl = userProfile?.profileImageUrl;

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
            context.l10n.messages,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          // 새 메시지 버튼
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 24,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () => _showNewMessageSheet(context),
          ),
          const SizedBox(width: 4),
          // 프로필 이미지 (설정으로 이동)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/profile');
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
              child: profileImageUrl == null || profileImageUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.grey[600],
                    )
                  : null,
            ),
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

/// 캐릭터 목록 탭 바 (스토리 / 운세보기)
class _CharacterTabBar extends StatelessWidget {
  final CharacterListTab currentTab;
  final void Function(CharacterListTab) onTabChanged;

  const _CharacterTabBar({
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TabButton(
            label: context.l10n.story,
            icon: Icons.favorite_outline,
            isSelected: currentTab == CharacterListTab.story,
            onTap: () => onTabChanged(CharacterListTab.story),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: context.l10n.viewFortune,
            icon: Icons.auto_awesome,
            isSelected: currentTab == CharacterListTab.fortune,
            onTap: () => onTabChanged(CharacterListTab.fortune),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 캐릭터 목록 아이템 (인스타그램 DM 스타일 + iOS 스타일 스와이프 액션 버튼)
class _CharacterListItem extends ConsumerStatefulWidget {
  final AiCharacter character;
  final VoidCallback onTap;

  const _CharacterListItem({
    required this.character,
    required this.onTap,
  });

  @override
  ConsumerState<_CharacterListItem> createState() => _CharacterListItemState();
}

class _CharacterListItemState extends ConsumerState<_CharacterListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  bool _isActionRevealed = false;
  static const double _actionButtonsWidth = 160.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<double>(
      begin: 0,
      end: _actionButtonsWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDelete(BuildContext context) {
    _closeActions();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.leaveConversation),
        content: Text(context.l10n.leaveConversationConfirm(
            CharacterLocalizer.getName(context, widget.character.id))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(characterChatProvider(widget.character.id).notifier)
                  .clearConversation();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.leave),
          ),
        ],
      ),
    );
  }

  void _onToggleMute(BuildContext context) {
    _closeActions();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.notificationOffMessage(
            CharacterLocalizer.getName(context, widget.character.id))),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openActions() {
    if (!_isActionRevealed) {
      _controller.forward();
      setState(() => _isActionRevealed = true);
    }
  }

  void _closeActions() {
    if (_isActionRevealed) {
      _controller.reverse();
      setState(() => _isActionRevealed = false);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < -5 && !_isActionRevealed) {
      _openActions();
    } else if (details.delta.dx > 5 && _isActionRevealed) {
      _closeActions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(characterChatProvider(widget.character.id));
    final hasConversation = chatState.hasConversation;
    final isTyping = chatState.isCharacterTyping;
    final unreadCount = chatState.unreadCount;

    // 마지막 메시지가 캐릭터인지 확인 (내가 보낸 게 마지막이면 뱃지 안 보임)
    final isLastMessageFromCharacter = chatState.messages.isNotEmpty &&
        chatState.messages.last.type == CharacterChatMessageType.character;
    final showUnreadBadge = unreadCount > 0 && isLastMessageFromCharacter;

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: (_) {},
      onTap: () {
        if (_isActionRevealed) {
          _closeActions();
        } else {
          widget.onTap();
        }
      },
      child: SizedBox(
        height: 109,
        child: Stack(
          children: [
            // 액션 버튼들 (배경에 고정)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: _actionButtonsWidth,
              child: Row(
                children: [
                  // 알림 끄기 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onToggleMute(context),
                      child: Container(
                        color: Colors.grey[500],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_off_outlined,
                                color: Colors.white, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.muteNotification,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 나가기 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onDelete(context),
                      child: Container(
                        color: Colors.red,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.exit_to_app,
                                color: Colors.white, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.leave,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 메인 콘텐츠 (슬라이드)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(-_slideAnimation.value, 0),
                child: child,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // 아바타 (탭하면 프로필)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/character/${widget.character.id}',
                            extra: widget.character);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: widget.character.accentColor,
                            backgroundImage:
                                widget.character.avatarAsset.isNotEmpty
                                    ? AssetImage(widget.character.avatarAsset)
                                    : null,
                            child: widget.character.avatarAsset.isEmpty
                                ? Text(
                                    widget.character.initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          // 타이핑 인디케이터
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
                                  border: Border.all(
                                      color: Colors.grey[200]!, width: 1),
                                ),
                                child:
                                    const Center(child: MiniTypingIndicator()),
                              ),
                            ),
                          // 읽지 않은 메시지 빨간 점 (캐릭터가 마지막에 보낸 경우에만)
                          if (!isTyping && showUnreadBadge)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          // 온라인 상태 표시 (최근 활동이 있는 캐릭터)
                          // 읽지 않은 메시지가 있고 타이핑 중이 아닐 때 표시
                          if (!isTyping && showUnreadBadge)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50), // 초록색 (온라인)
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          // 운세 전문가 배지
                          if (widget.character.isFortuneExpert)
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: widget.character.accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.auto_awesome,
                                      size: 10, color: Colors.white),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  CharacterLocalizer.getName(
                                      context, widget.character.id),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: showUnreadBadge
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // 운세 전문가 카테고리 배지
                              if (widget.character.isFortuneExpert &&
                                  widget.character.specialtyCategory !=
                                      null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.character.accentColor
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: widget.character.accentColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    widget.character.specialtyCategory!,
                                    style: context.labelTiny.copyWith(
                                      color: widget.character.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              if (!hasConversation) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.character.accentColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.l10n.newConversation,
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
                            CharacterLocalizer.getTags(
                                    context, widget.character.id)
                                .take(3)
                                .map((t) => '#$t')
                                .join(' '),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTyping
                                ? context.l10n.typing
                                : (hasConversation
                                    ? chatState.lastMessagePreview
                                    : CharacterLocalizer.getShortDescription(
                                        context, widget.character.id)),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isTyping ? FontWeight.w500 : FontWeight.w400,
                              color: isTyping
                                  ? widget.character.accentColor
                                  : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 타임스탬프 + 읽지 않은 메시지 배지
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasConversation &&
                            chatState.lastMessageTime != null)
                          Text(
                            _formatTimestamp(chatState.lastMessageTime!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: showUnreadBadge
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: showUnreadBadge ? Colors.red : Colors.grey,
                            ),
                          ),
                        if (showUnreadBadge) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
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
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return context.l10n.justNow;
    if (diff.inMinutes < 60) return context.l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return context.l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return context.l10n.daysAgo(diff.inDays);
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
                    context.l10n.newMessage,
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
                    context.l10n.recipient,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: context.l10n.search,
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
                  context.l10n.recommended,
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
                      backgroundImage: character.avatarAsset.isNotEmpty
                          ? AssetImage(character.avatarAsset)
                          : null,
                      child: character.avatarAsset.isEmpty
                          ? Text(
                              character.initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      CharacterLocalizer.getName(context, character.id),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    subtitle: Text(
                      CharacterLocalizer.getShortDescription(
                          context, character.id),
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
