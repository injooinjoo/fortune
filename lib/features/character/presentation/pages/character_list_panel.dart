import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/navigation/fortune_chat_route.dart';
import '../../../../core/services/supabase_connection_service.dart';
import '../../../../core/widgets/paper_runtime_chrome.dart';
import 'package:ondo/core/utils/haptic_utils.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../data/services/character_localizer.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../utils/character_accent_palette.dart';
import '../utils/chat_catalog_preview.dart';
import '../utils/onboarding_interest_catalog.dart';
import '../utils/profile_avatar_tap_handler.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_provider.dart';
import '../providers/sorted_characters_provider.dart';
import '../providers/user_created_character_provider.dart';
import '../widgets/wave_typing_indicator.dart';

const String _newFriendCreationAction = 'new_friend_creation';

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
  final ScrollController _listScrollController = ScrollController();
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = result.every((r) => r == ConnectivityResult.none);
      });
    }
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
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
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _handleStarterOptionTap(OnboardingInterestOption option) async {
    HapticUtils.lightImpact();
    ref.read(characterListTabProvider.notifier).state = option.targetTab;

    if (option.targetTab == CharacterListTab.story) {
      return;
    }

    final targetCharacter = option.expertId != null
        ? ref.read(characterByIdProvider(option.expertId!))
        : (option.specialtyCategory != null
            ? ref.read(categoryExpertProvider(option.specialtyCategory!))
            : null);

    if (targetCharacter != null) {
      widget.onCharacterSelected(targetCharacter);
    }
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
    final userProfile = isCatalogPreview
        ? null
        : ref.watch(userProfileNotifierProvider).valueOrNull;
    final starterOptions = isCatalogPreview
        ? const <OnboardingInterestOption>[]
        : selectedOnboardingInterestIds(
            userProfile?.fortunePreferences?.categoryWeights,
          )
            .map((id) => onboardingInterestById[id])
            .whereType<OnboardingInterestOption>()
            .take(3)
            .toList(growable: false);
    final showsStarterSection = starterOptions.isNotEmpty;

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
                  ref.read(characterListTabProvider.notifier).state = tab;
                },
              ),
              const Divider(height: 1),
              // 오프라인 배너
              if (_isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.xs + 2,
                  ),
                  color: colors.error.withValues(alpha: 0.12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 16,
                        color: colors.error,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          'You are offline. Some features may be limited.\n'
                          '오프라인 상태입니다. 일부 기능이 제한될 수 있습니다.',
                          style: context.typography.labelSmall.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // 캐릭터 목록
              Expanded(
                child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: characters.length + (showsStarterSection ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showsStarterSection && index == 0) {
                      return _PersonalizedStarterSection(
                        options: starterOptions,
                        onOptionTap: _handleStarterOptionTap,
                      );
                    }

                    final characterIndex =
                        showsStarterSection ? index - 1 : index;
                    final character = characters[characterIndex];
                    return _CharacterListItem(
                      character: character,
                      previewChatState: widget.catalogPreview != null
                          ? catalogPreviewListState(
                              preview: widget.catalogPreview!,
                              character: character,
                              index: characterIndex,
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

    return Container(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.md + 2,
        DSSpacing.md,
        DSSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.isOverlay)
            IconButton(
              icon: Icon(Icons.close, color: colors.textPrimary),
              onPressed: widget.onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (widget.isOverlay) const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              '메시지',
              style: context.headingLarge.copyWith(
                color: colors.textPrimary,
                height: 1.0,
                letterSpacing: -0.6,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.backgroundSecondary.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: colors.border.withValues(alpha: 0.68)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: colors.textPrimary,
              ),
              onPressed: () => _showNewMessageSheet(context),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
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
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.backgroundSecondary.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.68),
                ),
                image: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(profileImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileImageUrl == null || profileImageUrl.isEmpty
                  ? Icon(Icons.person, size: 18, color: colors.textSecondary)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNewMessageSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface.withValues(alpha: 0),
      builder: (ctx) => const _NewMessageSheet(),
    );

    if (!context.mounted || result == null) {
      return;
    }

    if (result is AiCharacter) {
      widget.onCharacterSelected(result);
      return;
    }

    if (result == _newFriendCreationAction) {
      ref.read(friendCreationDraftProvider.notifier).reset();
      context.push('/friends/new/basic');
    }
  }
}

class _PersonalizedStarterSection extends StatelessWidget {
  final List<OnboardingInterestOption> options;
  final ValueChanged<OnboardingInterestOption> onOptionTap;

  const _PersonalizedStarterSection({
    required this.options,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: PaperRuntimePanel(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '맞춤 시작점',
                  style: context.heading4.copyWith(color: colors.textPrimary),
                ),
                const Spacer(),
                PaperRuntimePill(
                  label: '${options.length}개 추천',
                  emphasize: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '방금 고른 관심사를 기준으로 바로 시작할 수 있는 흐름을 모아봤어요.',
              style: typography.bodySmall.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 14),
            for (final option in options) ...[
              _StarterOptionCard(
                option: option,
                onTap: () => onOptionTap(option),
              ),
              if (option != options.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _StarterOptionCard extends StatelessWidget {
  final OnboardingInterestOption option;
  final VoidCallback onTap;

  const _StarterOptionCard({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isStory = option.targetTab == CharacterListTab.story;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.radius.lg),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: colors.backgroundSecondary.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(context.radius.lg),
            border: Border.all(color: colors.border.withValues(alpha: 0.68)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isStory ? Icons.favorite_outline : Icons.auto_awesome,
                  color: colors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: typography.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PaperRuntimePill(label: isStory ? '스토리' : '전문가'),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.xs,
        DSSpacing.md,
        DSSpacing.sm,
      ),
      child: Row(
        children: [
          _TabButton(
            label: context.l10n.story,
            isSelected: currentTab == CharacterListTab.story,
            onTap: isLocked ? null : () => onTabChanged(CharacterListTab.story),
          ),
          const SizedBox(width: DSSpacing.xs),
          _TabButton(
            label: context.l10n.viewFortune,
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
  final bool isSelected;
  final VoidCallback? onTap;

  const _TabButton({
    required this.label,
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
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: colors.border.withValues(alpha: 0.68)),
        ),
        child: Text(
          label,
          style: context.typography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? colors.background : colors.textSecondary,
          ),
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
        content: Text(
          context.l10n.leaveConversationConfirm(
            CharacterLocalizer.resolveName(context, widget.character),
          ),
        ),
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
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
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
        content: Text(
          context.l10n.notificationOffMessage(
            CharacterLocalizer.resolveName(context, widget.character),
          ),
        ),
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
    final tagsText = CharacterLocalizer.resolveTags(
      context,
      widget.character,
    ).take(3).map((t) => '#$t').join(' ');

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
      child: IntrinsicHeight(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // 아바타 (탭하면 프로필)
                    GestureDetector(
                      onTap: interactionsEnabled
                          ? () {
                              HapticUtils.lightImpact();
                              context.push(
                                '/character/${widget.character.id}',
                                extra: widget.character,
                              );
                            }
                          : null,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 26,
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
                                child: const Center(
                                  child: MiniTypingIndicator(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),
                    // 이름 + 태그 + 마지막 메시지 (Paper 3줄 구조)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 줄 1: 이름 + 타임스탬프
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  CharacterLocalizer.resolveName(
                                    context,
                                    widget.character,
                                  ),
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
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
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
                                      widget.character.specialtyCategory!,
                                    ),
                                    style: typography.labelSmall.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
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
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 줄 2: 태그 + 배지
                          Row(
                            children: [
                              if (tagsText.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    tagsText,
                                    style: typography.labelSmall.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: DSColors.ctaBackground,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                const Spacer(),
                              if (hasUnread) ...[
                                const SizedBox(width: 8),
                                DSBadge(
                                  count: unreadCount,
                                  color: DSBadgeColor.error,
                                  style: DSBadgeStyle.pill,
                                ),
                              ] else if (isMyTurn) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A4A),
                                    borderRadius: BorderRadius.circular(
                                      DSRadius.md,
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.yourTurn,
                                    style: typography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFF5F6FB),
                                    ),
                                  ),
                                ),
                              ] else if (!hasConversation) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A2A1A),
                                    borderRadius: BorderRadius.circular(
                                      DSRadius.md,
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.newConversation,
                                    style: typography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFF5F6FB),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 줄 3: 메시지 미리보기
                          Text(
                            isTyping
                                ? context.l10n.typing
                                : (hasConversation
                                    ? chatState.lastMessagePreview
                                    : CharacterLocalizer
                                        .resolveShortDescription(
                                        context,
                                        widget.character,
                                      )),
                            style: typography.bodySmall.copyWith(
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

/// 새로운 친구 시작 바텀시트
class _NewMessageSheet extends ConsumerStatefulWidget {
  const _NewMessageSheet();

  @override
  ConsumerState<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends ConsumerState<_NewMessageSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _buildRecommendedSummary(BuildContext context, AiCharacter character) {
    final tags = CharacterLocalizer.resolveTags(context, character).take(3);
    if (tags.isNotEmpty) {
      return tags.join(' · ');
    }
    return CharacterLocalizer.resolveShortDescription(context, character);
  }

  List<AiCharacter> _filterCharacters(
    BuildContext context,
    List<AiCharacter> characters,
  ) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return characters;
    }

    return characters.where((character) {
      final name = CharacterLocalizer.resolveName(context, character);
      final summary = _buildRecommendedSummary(context, character);
      final haystack =
          '$name ${character.name} $summary ${character.tags.join(' ')}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  String _buildResultSummary({
    required int myCount,
    required int recommendedCount,
  }) {
    final totalCount = myCount + recommendedCount;
    if (_query.trim().isNotEmpty) {
      return '검색 결과 $totalCount명';
    }

    if (myCount > 0) {
      return '내가 만든 친구 $myCount명 · 추천 친구 $recommendedCount명';
    }

    return '추천 친구 $recommendedCount명';
  }

  @override
  Widget build(BuildContext context) {
    final myCharacters = _filterCharacters(
      context,
      ref.watch(userCreatedAiCharactersProvider),
    );
    final recommendedCharacters = _filterCharacters(
      context,
      ref.watch(recommendedStoryCharactersProvider),
    );
    final resultSummary = _buildResultSummary(
      myCount: myCharacters.length,
      recommendedCount: recommendedCharacters.length,
    );
    final hasResults =
        myCharacters.isNotEmpty || recommendedCharacters.isNotEmpty;

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
              margin: const EdgeInsets.only(top: DSSpacing.xs),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.md,
                DSSpacing.sm,
                DSSpacing.md,
                DSSpacing.xs + 2,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Text(
                        '새로운 친구',
                        style: context.typography.headingSmall.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '추천 친구를 바로 고르거나, 취향에 맞는 친구를 직접 만들 수 있어요.',
                      style: context.typography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.md,
                DSSpacing.sm,
                DSSpacing.md,
                DSSpacing.xs,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: '친구 검색',
                  hintStyle: context.typography.bodyMedium.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.colors.textSecondary,
                  ),
                  filled: true,
                  fillColor: context.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.sm,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.md,
                0,
                DSSpacing.md,
                DSSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  resultSummary,
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.md,
                  DSSpacing.xs,
                  DSSpacing.md,
                  DSSpacing.xl,
                ),
                children: [
                  _NewFriendActionCard(
                    onTap: () =>
                        Navigator.pop(context, _newFriendCreationAction),
                  ),
                  if (myCharacters.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xl),
                    _SheetSectionTitle(
                      title: '내가 만든 친구',
                      count: myCharacters.length,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    ...myCharacters.map(
                      (character) =>
                          _NewMessageCharacterTile(character: character),
                    ),
                  ],
                  const SizedBox(height: DSSpacing.xl),
                  _SheetSectionTitle(
                    title: '추천 친구',
                    count: recommendedCharacters.length,
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  if (!hasResults)
                    const _NewMessageEmptyState()
                  else
                    ...recommendedCharacters.map(
                      (character) =>
                          _NewMessageCharacterTile(character: character),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final label = count != null ? '$title $count' : title;
    return Text(
      label,
      style: context.typography.bodyLarge.copyWith(
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _NewFriendActionCard extends StatelessWidget {
  const _NewFriendActionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSRadius.lg),
      child: Ink(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2A),
          borderRadius: BorderRadius.circular(DSRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A4A),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Text(
                '직접 만들기',
                style: context.typography.bodyLarge.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2A3A),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: context.colors.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '친구 새로 만들기',
                        style: context.typography.bodyLarge.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '이름, 성격, 분위기, 관계를 정해서 원하는 흐름의 대화를 바로 시작하세요.',
                        style: context.typography.labelSmall.copyWith(
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _NewFriendActionChip(label: '이름'),
                _NewFriendActionChip(label: '관계'),
                _NewFriendActionChip(label: '성격'),
                _NewFriendActionChip(label: '관심사'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewFriendActionChip extends StatelessWidget {
  const _NewFriendActionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: context.typography.bodyLarge.copyWith(
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

class _NewMessageEmptyState extends StatelessWidget {
  const _NewMessageEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.xl + 4,
      ),
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(context.radius.xl),
        border: Border.all(
          color: context.colors.border.withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 28,
            color: context.colors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '검색 결과가 없어요',
            style: context.typography.labelLarge.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '다른 키워드로 다시 찾아보거나, 위에서 새 친구를 직접 만들어보세요.',
            textAlign: TextAlign.center,
            style: context.typography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewMessageCharacterTile extends StatelessWidget {
  const _NewMessageCharacterTile({required this.character});

  final AiCharacter character;

  String _buildSummary(BuildContext context) {
    final tags = CharacterLocalizer.resolveTags(context, character).take(3);
    if (tags.isNotEmpty) {
      return tags.join(' · ');
    }
    return CharacterLocalizer.resolveShortDescription(context, character);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _buildSummary(context);
    final accentPalette = CharacterAccentPalette.from(
      source: character.accentColor,
      brightness: Theme.of(context).brightness,
    );

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1.8),
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
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
        CharacterLocalizer.resolveName(context, character),
        style: context.typography.bodyLarge.copyWith(
          color: context.colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        summary,
        style: context.typography.labelSmall.copyWith(
          color: context.colors.textTertiary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => Navigator.pop(context, character),
    );
  }
}
