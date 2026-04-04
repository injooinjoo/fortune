import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/navigation/fortune_chat_route.dart';
import '../../../../core/widgets/paper_runtime_chrome.dart';
import 'package:ondo/core/utils/haptic_utils.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/social_auth_provider.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../presentation/widgets/social_login_bottom_sheet.dart';
import '../../data/services/character_localizer.dart';
import '../../domain/models/ai_character.dart';
import '../../domain/models/character_chat_message.dart';
import '../../domain/models/character_chat_state.dart';
import '../utils/character_accent_palette.dart';
import '../utils/chat_catalog_preview.dart';
import '../utils/onboarding_interest_catalog.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_provider.dart';
import '../providers/sorted_characters_provider.dart';
import '../providers/user_created_character_provider.dart';
import '../widgets/wave_typing_indicator.dart';

const String _newFriendCreationAction = 'new_friend_creation';

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
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _handleStarterOptionTap(
    OnboardingInterestOption option,
  ) async {
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
                      horizontal: DSSpacing.md, vertical: DSSpacing.xs + 2),
                  color: colors.error.withValues(alpha: 0.12),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 16, color: colors.error),
                      const SizedBox(width: DSSpacing.xs),
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
              // 스토리 서클 (인스타그램 스타일)
              if (!isCatalogPreview)
                _StoryCirclesRow(
                  characters: characters.take(4).toList(),
                  onCharacterTap: widget.onCharacterSelected,
                  onNewFriendTap: () => _showNewMessageSheet(context),
                ),
              // 캐릭터 목록
              Expanded(
                child: _buildCharacterList(
                  context,
                  characters: characters,
                  showsStarterSection: showsStarterSection,
                  starterOptions: starterOptions,
                  isCatalogPreview: isCatalogPreview,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(20, DSSpacing.md + 2, 20, DSSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.0,
                letterSpacing: -0.6,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: 검색 기능
              HapticUtils.lightImpact();
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.search,
                size: 24,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          GestureDetector(
            onTap: () => _showNewMessageSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.edit_note_outlined,
                size: 24,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          // 유저 프로필 아이콘
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              final currentUser = ref.read(userProvider).value;
              if (currentUser == null) {
                // 로그아웃 상태 → 로그인 바텀시트
                SocialLoginBottomSheet.showForAuthentication(
                  context,
                  ref: ref,
                  socialAuthService: ref.read(socialAuthServiceProvider),
                );
              } else {
                context.push('/profile');
              }
            },
            child: _buildProfileAvatar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final colors = context.colors;
    final userProfile = ref.watch(userProfileNotifierProvider).valueOrNull;
    final profileImageUrl = userProfile?.profileImageUrl;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
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
          ? Icon(
              Icons.person_outline,
              size: 16,
              color: colors.textSecondary,
            )
          : null,
    );
  }

  Widget _buildCharacterList(
    BuildContext context, {
    required List<AiCharacter> characters,
    required bool showsStarterSection,
    required List<OnboardingInterestOption> starterOptions,
    required bool isCatalogPreview,
  }) {
    // 대화 있는 캐릭터 vs 추천 친구 분리
    final conversationCharacters = <AiCharacter>[];
    final recommendedCharacters = <AiCharacter>[];
    for (final character in characters) {
      if (isCatalogPreview) {
        conversationCharacters.add(character);
        continue;
      }
      final chatState = ref.watch(characterChatProvider(character.id));
      if (chatState.hasConversation) {
        conversationCharacters.add(character);
      } else {
        recommendedCharacters.add(character);
      }
    }

    final itemCount = conversationCharacters.length +
        (showsStarterSection ? 1 : 0) +
        (recommendedCharacters.isNotEmpty ? 1 : 0) + // 섹션 헤더
        recommendedCharacters.length;

    return ListView.builder(
      controller: _listScrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        var cursor = 0;

        // 맞춤 시작점 섹션
        if (showsStarterSection) {
          if (index == cursor) {
            return _PersonalizedStarterSection(
              options: starterOptions,
              onOptionTap: _handleStarterOptionTap,
            );
          }
          cursor++;
        }

        // 대화 있는 캐릭터들
        if (index - cursor < conversationCharacters.length) {
          final character = conversationCharacters[index - cursor];
          return _CharacterListItem(
            character: character,
            previewChatState: isCatalogPreview
                ? catalogPreviewListState(
                    preview: widget.catalogPreview!,
                    character: character,
                    index: index - cursor,
                  )
                : null,
            onTap: isCatalogPreview
                ? () {}
                : () => widget.onCharacterSelected(character),
          );
        }
        cursor += conversationCharacters.length;

        // 추천 친구 섹션 헤더
        if (recommendedCharacters.isNotEmpty && index == cursor) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '추천 친구',
              style: context.typography.labelMedium.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        if (recommendedCharacters.isNotEmpty) cursor++;

        // 추천 친구 아이템들
        if (index - cursor < recommendedCharacters.length) {
          final character = recommendedCharacters[index - cursor];
          return _RecommendedCharacterItem(
            character: character,
            onTap: () => widget.onCharacterSelected(character),
          );
        }

        return const SizedBox.shrink();
      },
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
          horizontal: DSSpacing.md, vertical: DSSpacing.sm),
      child: PaperRuntimePanel(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '맞춤 시작점',
                  style: context.heading4.copyWith(
                    color: colors.textPrimary,
                  ),
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
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
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

  const _StarterOptionCard({
    required this.option,
    required this.onTap,
  });

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
            border: Border.all(
              color: colors.border.withValues(alpha: 0.68),
            ),
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
                      style: typography.labelMedium.copyWith(
                        color: colors.textSubtitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PaperRuntimePill(
                label: isStory ? '스토리' : '전문가',
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colors.textSubtitle,
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
          DSSpacing.md, DSSpacing.xs, DSSpacing.md, DSSpacing.sm),
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
            horizontal: DSSpacing.md, vertical: DSSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? colors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: colors.border.withValues(alpha: 0.68),
                ),
        ),
        child: Text(
          label,
          style: context.typography.labelMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? colors.background : colors.textSubtitle,
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
        content: Text(context.l10n.leaveConversationConfirm(
            CharacterLocalizer.resolveName(context, widget.character))),
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
            CharacterLocalizer.resolveName(context, widget.character))),
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

    // 마지막 메시지가 캐릭터인지 확인
    final isLastMessageFromCharacter = chatState.messages.isNotEmpty &&
        chatState.messages.last.type == CharacterChatMessageType.character;
    // 읽지 않은 메시지가 있으면 내 차례 대신 숫자 배지를 우선 표시한다.
    final hasUnread = unreadCount > 0;
    final isMyTurn =
        hasConversation && isLastMessageFromCharacter && !hasUnread;
    final previewColor = isTyping
        ? accentPalette.accent
        : hasUnread
            ? colors.textPrimary
            : colors.textSubtitle;

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
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                            radius: 24,
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
                                      fontSize: 18,
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
                    const SizedBox(width: 14),
                    // 카톡 스타일 2줄: 이름(좌) + 시간(우) / 프리뷰(좌) + 배지(우)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 줄 1: 이름(좌) ← → 타임스탬프(우)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  CharacterLocalizer.resolveName(
                                    context,
                                    widget.character,
                                  ),
                                  style: typography.bodyLarge.copyWith(
                                    fontWeight: hasUnread
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasConversation &&
                                  chatState.lastMessageTime != null)
                                Text(
                                  _formatTimestamp(chatState.lastMessageTime!),
                                  style: typography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSubtitle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 줄 2: 메시지 프리뷰(좌) ← → 배지(우)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isTyping
                                      ? context.l10n.typing
                                      : (hasConversation
                                          ? chatState.lastMessagePreview
                                          : CharacterLocalizer
                                              .resolveShortDescription(
                                              context,
                                              widget.character,
                                            )),
                                  style: typography.bodyMedium.copyWith(
                                    fontWeight: isTyping || hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: previewColor,
                                    height: 1.35,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasUnread) ...[
                                const SizedBox(width: 8),
                                const _UnreadDot(),
                              ] else if (isMyTurn) ...[
                                const SizedBox(width: 8),
                                _InlineBadge(
                                  label: context.l10n.yourTurn,
                                ),
                              ],
                            ],
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

/// 읽지 않음 도트 (카카오톡 스타일)
class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: DSColors.ctaBackground,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 인라인 배지 (내 차례 / 새 대화)
class _InlineBadge extends StatelessWidget {
  final String label;

  const _InlineBadge({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: colors.borderFocus.withValues(alpha: 0.92),
        ),
      ),
      child: Text(
        label,
        style: context.typography.labelSmall.copyWith(
          color: DSColors.ctaBackground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 스토리 서클 (인스타그램 DM 스타일 상단 아바타 행)
class _StoryCirclesRow extends StatelessWidget {
  final List<AiCharacter> characters;
  final void Function(AiCharacter) onCharacterTap;
  final VoidCallback onNewFriendTap;

  const _StoryCirclesRow({
    required this.characters,
    required this.onCharacterTap,
    required this.onNewFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          for (final character in characters) ...[
            _buildCircle(
              context,
              label: CharacterLocalizer.resolveName(context, character),
              accentColor: CharacterAccentPalette.from(
                source: character.accentColor,
                brightness: Theme.of(context).brightness,
              ),
              character: character,
              onTap: () => onCharacterTap(character),
            ),
            const SizedBox(width: 16),
          ],
          // 새 친구 추가 버튼
          GestureDetector(
            onTap: onNewFriendTap,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.68),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '새 친구',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSubtitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(
    BuildContext context, {
    required String label,
    required CharacterAccentPalette accentColor,
    required AiCharacter character,
    required VoidCallback onTap,
  }) {
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: DSColors.ctaBackground,
                width: 2,
              ),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 24,
                backgroundColor: accentColor.accent,
                backgroundImage: character.avatarAsset.isNotEmpty
                    ? AssetImage(character.avatarAsset)
                    : null,
                child: character.avatarAsset.isEmpty
                    ? Text(
                        character.initial,
                        style: typography.bodyLarge.copyWith(
                          color: accentColor.onAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: typography.labelMedium.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 추천 친구 리스트 아이템 (인스타그램 DM 스타일)
class _RecommendedCharacterItem extends StatelessWidget {
  final AiCharacter character;
  final VoidCallback onTap;

  const _RecommendedCharacterItem({
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final accentPalette = CharacterAccentPalette.from(
      source: character.accentColor,
      brightness: Theme.of(context).brightness,
    );
    final tags =
        CharacterLocalizer.resolveTags(context, character).take(4).join(' · ');
    final summary = tags.isNotEmpty
        ? tags
        : CharacterLocalizer.resolveShortDescription(context, character);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // 아바타
            CircleAvatar(
              radius: 24,
              backgroundColor: accentPalette.accent,
              backgroundImage: character.avatarAsset.isNotEmpty
                  ? AssetImage(character.avatarAsset)
                  : null,
              child: character.avatarAsset.isEmpty
                  ? Text(
                      character.initial,
                      style: typography.bodyLarge.copyWith(
                        color: accentPalette.onAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // 이름 + 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CharacterLocalizer.resolveName(context, character),
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 대화하기 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.68),
                ),
              ),
              child: Text(
                '대화하기',
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  DSSpacing.md, DSSpacing.sm, DSSpacing.md, DSSpacing.xs + 2),
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
                        color: context.colors.textSubtitle,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DSSpacing.md, DSSpacing.sm, DSSpacing.md, DSSpacing.xs),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: '친구 검색',
                  hintStyle: context.typography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.colors.textSecondary,
                  ),
                  filled: true,
                  fillColor: context.colors.backgroundSecondary,
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
                  DSSpacing.md, 0, DSSpacing.md, DSSpacing.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  resultSummary,
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSubtitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                    DSSpacing.md, DSSpacing.xs, DSSpacing.md, DSSpacing.xl),
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
  const _SheetSectionTitle({
    required this.title,
    this.count,
  });

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final label = count != null ? '$title $count' : title;
    return Text(
      label,
      style: context.typography.bodyLarge.copyWith(
        color: context.colors.textSubtitle,
        fontWeight: FontWeight.w600,
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
          color: context.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(
            color: context.colors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.backgroundTertiary,
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
                  decoration: BoxDecoration(
                    color: context.colors.backgroundTertiary,
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
                        style: context.typography.bodySmall.copyWith(
                          color: context.colors.textSubtitle,
                          fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm + 4,
        vertical: DSSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.backgroundTertiary,
        borderRadius: BorderRadius.circular(DSRadius.full),
      ),
      child: Text(
        label,
        style: context.typography.labelSmall.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w500,
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
          horizontal: DSSpacing.lg, vertical: DSSpacing.xl + 4),
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
              color: context.colors.textSubtitle,
              height: 1.45,
              fontWeight: FontWeight.w500,
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
        style: context.typography.labelMedium.copyWith(
          color: context.colors.textSubtitle,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => Navigator.pop(context, character),
    );
  }
}
