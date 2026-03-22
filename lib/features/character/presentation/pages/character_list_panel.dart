import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/navigation/fortune_chat_route.dart';
import '../../../../core/services/supabase_connection_service.dart';
import 'package:fortune/core/utils/haptic_utils.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../data/services/character_localizer.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../utils/character_accent_palette.dart';
import '../utils/chat_catalog_preview.dart';
import '../utils/profile_avatar_tap_handler.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_provider.dart';
import '../providers/sorted_characters_provider.dart';
import '../widgets/wave_typing_indicator.dart';

/// 카테고리 영문 → 한글 라벨 변환
String _specialtyCategoryLabel(String category) {
  const labels = {
    'lifestyle': '라이프',
    'traditional': '전통',
    'zodiac': '별자리',
    'personality': '심리',
    'love': '연애',
    'career': '재물',
    'lucky': '행운',
    'sports': '스포츠',
    'fengshui': '풍수',
    'special': '타로',
  };
  return labels[category] ?? category;
}

/// DM 목록 패널 (인스타그램 DM 스타일)
class CharacterListPanel extends ConsumerStatefulWidget {
  final void Function(AiCharacter character) onCharacterSelected;
  final bool isOverlay;
  final VoidCallback? onDismiss;
  final ChatCatalogPreview? catalogPreview;

  const CharacterListPanel({
    super.key,
    required this.onCharacterSelected,
    this.isOverlay = false,
    this.onDismiss,
    this.catalogPreview,
  });

  @override
  ConsumerState<CharacterListPanel> createState() => _CharacterListPanelState();
}

class _CharacterListPanelState extends ConsumerState<CharacterListPanel> {
  static const double _topChromeRevealOffset = 12;
  final ScrollController _listScrollController = ScrollController();
  bool _showTopChrome = true;
  double _lastScrollOffset = 0;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_handleListScroll);
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = result.every((r) => r == ConnectivityResult.none);
      });
    }
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() {
          _isOffline = results.every((r) => r == ConnectivityResult.none);
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _listScrollController.removeListener(_handleListScroll);
    _listScrollController.dispose();
    super.dispose();
  }

  void _setTopChromeVisibility(bool visible) {
    if (_showTopChrome == visible || !mounted) {
      return;
    }

    setState(() {
      _showTopChrome = visible;
    });
  }

  void _handleListScroll() {
    if (!_listScrollController.hasClients) {
      return;
    }

    final offset = _listScrollController.offset;
    final delta = offset - _lastScrollOffset;

    if (offset <= 0) {
      _lastScrollOffset = 0;
      _setTopChromeVisibility(true);
      return;
    }

    if (delta > 0 && offset > _topChromeRevealOffset) {
      _setTopChromeVisibility(false);
    } else if (delta < 0) {
      _setTopChromeVisibility(true);
    }

    _lastScrollOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final CharacterListTab? previewTab = widget.catalogPreview != null
        ? catalogPreviewTab(widget.catalogPreview!)
        : null;
    final CharacterListTab currentTab =
        previewTab ?? ref.watch(characterListTabProvider);
    final isCatalogPreview = widget.catalogPreview != null;
    final characters = isCatalogPreview
        ? (currentTab == CharacterListTab.story
            ? ref.watch(storyCharactersProvider)
            : ref.watch(fortuneCharactersProvider))
        : (currentTab == CharacterListTab.story
            ? ref.watch(sortedStoryCharactersProvider)
            : ref.watch(sortedFortuneCharactersProvider));

    return GestureDetector(
      onHorizontalDragEnd: widget.isOverlay
          ? (details) {
              // 오른쪽으로 스와이프하면 닫기
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 100) {
                widget.onDismiss?.call();
              }
            }
          : null,
      child: Container(
        color: colors.background,
        child: SafeArea(
          child: Column(
            children: [
              ClipRect(
                child: AnimatedAlign(
                  duration: DSAnimation.normal,
                  curve: DSAnimation.emphasized,
                  alignment: Alignment.topCenter,
                  heightFactor: _showTopChrome ? 1 : 0,
                  child: AnimatedOpacity(
                    duration: DSAnimation.quick,
                    curve: DSAnimation.primary,
                    opacity: _showTopChrome ? 1 : 0,
                    child: AnimatedSlide(
                      duration: DSAnimation.normal,
                      curve: DSAnimation.emphasized,
                      offset:
                          _showTopChrome ? Offset.zero : const Offset(0, -0.08),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 헤더
                          _buildHeader(context),
                          // 탭 바
                          _CharacterTabBar(
                            currentTab: currentTab,
                            isLocked: isCatalogPreview,
                            onTabChanged: (tab) {
                              if (isCatalogPreview) {
                                return;
                              }
                              _setTopChromeVisibility(true);
                              ref
                                  .read(characterListTabProvider.notifier)
                                  .state = tab;
                            },
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 오프라인 배너
              if (_isOffline)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: colors.error.withValues(alpha: 0.12),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 16, color: colors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You are offline. Some features may be limited.\n'
                          '오프라인 상태입니다. 일부 기능이 제한될 수 있습니다.',
                          style: context.typography.labelSmall
                              .copyWith(color: colors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              // 캐릭터 목록
              Expanded(
                child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return _CharacterListItem(
                      character: character,
                      previewChatState: widget.catalogPreview != null
                          ? catalogPreviewListState(
                              preview: widget.catalogPreview!,
                              character: character,
                              index: index,
                            )
                          : null,
                      onTap: isCatalogPreview
                          ? () {}
                          : () => widget.onCharacterSelected(character),
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
    final userProfile = ref.watch(userProfileNotifierProvider).valueOrNull;
    final profileImageUrl = userProfile?.profileImageUrl;
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (widget.isOverlay)
            IconButton(
              icon: Icon(Icons.close, color: colors.textPrimary),
              onPressed: widget.onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (widget.isOverlay) const SizedBox(width: 12),
          Text(
            context.l10n.messages,
            style: typography.headingLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 24,
              color: colors.textPrimary,
            ),
            onPressed: () => _showNewMessageSheet(context),
          ),
          const SizedBox(width: 4),
          // 프로필 이미지 (설정으로 이동)
          GestureDetector(
            onTap: () async {
              HapticUtils.lightImpact();
              await handleProfileAvatarTap(
                context: context,
                ref: ref,
                currentUser: SupabaseConnectionService.tryGetCurrentUser(),
                openProfileSheet: () async {
                  context.push('/profile');
                },
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.backgroundSecondary,
              backgroundImage:
                  profileImageUrl != null && profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
              child: profileImageUrl == null || profileImageUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 18,
                      color: colors.textSecondary,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNewMessageSheet(BuildContext context) async {
    final selectedCharacter = await showModalBottomSheet<AiCharacter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
      builder: (ctx) => const _NewMessageSheet(),
    );

    if (!context.mounted || selectedCharacter == null) {
      return;
    }

    widget.onCharacterSelected(selectedCharacter);
  }
}

/// 캐릭터 목록 탭 바 (스토리 / 운세보기)
class _CharacterTabBar extends StatelessWidget {
  final CharacterListTab currentTab;
  final void Function(CharacterListTab) onTabChanged;
  final bool isLocked;

  const _CharacterTabBar({
    required this.currentTab,
    required this.onTabChanged,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TabButton(
            label: context.l10n.story,
            icon: Icons.favorite_outline,
            isSelected: currentTab == CharacterListTab.story,
            onTap: isLocked ? null : () => onTabChanged(CharacterListTab.story),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: context.l10n.viewFortune,
            icon: Icons.auto_awesome,
            isSelected: currentTab == CharacterListTab.fortune,
            onTap:
                isLocked ? null : () => onTabChanged(CharacterListTab.fortune),
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
  final VoidCallback? onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.ctaBackground : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(context.radius.full),
          border: isSelected
              ? null
              : Border.all(color: colors.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colors.ctaForeground : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.typography.labelLarge.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colors.ctaForeground : colors.textSecondary,
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
  final CharacterChatState? previewChatState;

  const _CharacterListItem({
    required this.character,
    required this.onTap,
    this.previewChatState,
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
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(characterChatProvider(widget.character.id).notifier)
                  .clearConversationData();
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: Text(context.l10n.leave),
          ),
        ],
      ),
    );
  }

  void _onToggleMute(BuildContext context) {
    _closeActions();
    HapticUtils.lightImpact();
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
    final colors = context.colors;
    final typography = context.typography;
    final CharacterChatState chatState = widget.previewChatState ??
        ref.watch(characterChatProvider(widget.character.id));
    final interactionsEnabled = widget.previewChatState == null;
    final accentPalette = CharacterAccentPalette.from(
      source: widget.character.accentColor,
      brightness: Theme.of(context).brightness,
    );
    final hasConversation = chatState.hasConversation;
    final isTyping = chatState.isCharacterTyping;
    final unreadCount = chatState.unreadCount;
    final tagsText = CharacterLocalizer.getTags(context, widget.character.id)
        .take(3)
        .map((t) => '#$t')
        .join(' ');

    // 마지막 메시지가 캐릭터인지 확인
    final isLastMessageFromCharacter = chatState.messages.isNotEmpty &&
        chatState.messages.last.type == CharacterChatMessageType.character;
    // 읽지 않은 메시지가 있으면 내 차례 대신 숫자 배지를 우선 표시한다.
    final hasUnread = unreadCount > 0;
    final isMyTurn =
        hasConversation && isLastMessageFromCharacter && !hasUnread;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: interactionsEnabled ? _handleDragUpdate : null,
      onHorizontalDragEnd: (_) {},
      onTap: () {
        if (_isActionRevealed) {
          _closeActions();
        } else {
          widget.onTap();
        }
      },
      child: SizedBox(
        height: 84,
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
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onToggleMute(context),
                      child: Container(
                        color: colors.surfaceSecondary,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              color: colors.textPrimary,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.muteNotification,
                              style: typography.labelSmall.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
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
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onDelete(context),
                      child: Container(
                        color: colors.errorBackground,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.exit_to_app,
                              color: colors.error,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.leave,
                              style: typography.labelSmall.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w700,
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
                  color: colors.background,
                  border: Border(
                    bottom: BorderSide(
                      color: colors.divider.withValues(alpha: 0.62),
                      width: 1,
                    ),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    // 아바타 (탭하면 프로필)
                    GestureDetector(
                      onTap: interactionsEnabled
                          ? () {
                              HapticUtils.lightImpact();
                              context.push('/character/${widget.character.id}',
                                  extra: widget.character);
                            }
                          : null,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: accentPalette.accent,
                            backgroundImage:
                                widget.character.avatarAsset.isNotEmpty
                                    ? AssetImage(widget.character.avatarAsset)
                                    : null,
                            child: widget.character.avatarAsset.isEmpty
                                ? Text(
                                    widget.character.initial,
                                    style: typography.bodyLarge.copyWith(
                                      color: accentPalette.onAccent,
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
                                  color: colors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.border,
                                    width: 1,
                                  ),
                                ),
                                child:
                                    const Center(child: MiniTypingIndicator()),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
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
                                  style: typography.bodyLarge.copyWith(
                                    fontWeight: hasUnread
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: colors.textPrimary,
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
                                    color: colors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: colors.border.withValues(
                                        alpha: 0.78,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _specialtyCategoryLabel(
                                        widget.character.specialtyCategory!),
                                    style: typography.labelSmall.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                              if (tagsText.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    tagsText,
                                    style: typography.labelMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colors.textTertiary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isTyping
                                ? context.l10n.typing
                                : (hasConversation
                                    ? chatState.lastMessagePreview
                                    : CharacterLocalizer.getShortDescription(
                                        context, widget.character.id)),
                            style: typography.bodyMedium.copyWith(
                              fontWeight: isTyping || hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: isTyping
                                  ? accentPalette.accent
                                  : hasUnread
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 타임스탬프 + 내 차례 표시
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasConversation &&
                            chatState.lastMessageTime != null)
                          Text(
                            _formatTimestamp(chatState.lastMessageTime!),
                            style: typography.labelSmall.copyWith(
                              fontWeight: FontWeight.w400,
                              color: colors.textTertiary,
                            ),
                          ),
                        if (!hasConversation)
                          Text(
                            context.l10n.newConversation,
                            style: typography.labelSmall.copyWith(
                              fontWeight: FontWeight.w400,
                              color: colors.textTertiary,
                            ),
                          ),
                        if (hasUnread) ...[
                          const SizedBox(height: 6),
                          DSBadge(
                            count: unreadCount,
                            color: DSBadgeColor.error,
                            style: DSBadgeStyle.pill,
                          ),
                        ] else if (isMyTurn) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.colors.backgroundSecondary,
                              borderRadius:
                                  BorderRadius.circular(context.radius.full),
                            ),
                            child: Text(
                              context.l10n.yourTurn,
                              style: context.typography.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
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
  const _NewMessageSheet();

  String _buildRecommendedSummary(BuildContext context, String characterId) {
    final tags = CharacterLocalizer.getTags(context, characterId).take(3);
    if (tags.isNotEmpty) {
      return tags.join(' · ');
    }
    return CharacterLocalizer.getShortDescription(context, characterId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(charactersProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.radius.xxl),
          ),
          border: Border(
            top: BorderSide(
              color: context.colors.border.withValues(alpha: 0.72),
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    context.l10n.newMessage,
                    style: context.typography.headingSmall.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    context.l10n.recipient,
                    style: context.typography.labelLarge.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: context.l10n.search,
                        hintStyle: context.typography.labelLarge.copyWith(
                          color: context.colors.textTertiary,
                        ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.recommended,
                  style: context.typography.labelLarge.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  final summary =
                      _buildRecommendedSummary(context, character.id);
                  final accentPalette = CharacterAccentPalette.from(
                    source: character.accentColor,
                    brightness: Theme.of(context).brightness,
                  );
                  return ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -1.8),
                    minVerticalPadding: 0,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: accentPalette.accent,
                      backgroundImage: character.avatarAsset.isNotEmpty
                          ? AssetImage(character.avatarAsset)
                          : null,
                      child: character.avatarAsset.isEmpty
                          ? Text(
                              character.initial,
                              style: context.typography.labelLarge.copyWith(
                                color: accentPalette.onAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      CharacterLocalizer.getName(context, character.id),
                      style: context.typography.bodyLarge.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      summary,
                      style: context.typography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.pop(context, character),
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
