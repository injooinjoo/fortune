import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/navigation/fortune_chat_route.dart';
import '../../../../core/utils/logger.dart';
import '../providers/character_provider.dart';
import '../providers/user_created_character_provider.dart';
import '../../data/fortune_characters.dart';
import '../../domain/models/ai_character.dart';
import '../utils/chat_catalog_preview.dart';
import 'character_list_panel.dart';
import 'character_chat_panel.dart';
import 'character_onboarding_page.dart';
import '../../../../services/storage_service.dart';
import '../../../../presentation/providers/auth_provider.dart';

/// 홈 셸 (임시: 메시지 목록만 표시)
/// - 메시지 목록 (CharacterListPanel) - 메인
/// - 오른쪽에서 슬라이드 오버레이: 캐릭터 채팅 (CharacterChatPanel)
///
/// TODO: 나중에 복원할 패널들 (임시 숨김)
/// - 왼쪽: 운세 목록 (FortuneListPanel)
/// - 가운데: 메인 채팅 (ChatHomePage)
class SwipeHomeShell extends ConsumerStatefulWidget {
  const SwipeHomeShell({super.key});

  @override
  ConsumerState<SwipeHomeShell> createState() => _SwipeHomeShellState();
}

class _SwipeHomeShellState extends ConsumerState<SwipeHomeShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _chatOverlayController;
  late Animation<Offset> _chatOverlayAnimation;
  final StorageService _storageService = StorageService();
  FortuneChatLaunchRequest? _pendingLaunchRequest;
  String? _handledRouteLaunchSignature;
  String? _failedRouteLaunchSignature;

  bool _showChatOverlay = false;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();

    _chatOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 오른쪽에서 왼쪽으로 슬라이드 인
    _chatOverlayAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // 오른쪽에서 시작
      end: Offset.zero, // 화면 중앙으로
    ).animate(CurvedAnimation(
      parent: _chatOverlayController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_handleOpenCharacterFromRoute());
      }
    });
  }

  Future<void> _checkOnboarding() async {
    final completed = await _storageService.isCharacterOnboardingCompleted();
    if (!completed && mounted) {
      setState(() => _showOnboarding = true);
    }
  }

  void _onOnboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  @override
  void dispose() {
    _chatOverlayController.dispose();
    super.dispose();
  }

  /// 채팅 오버레이 열기 (오른쪽에서 슬라이드 인)
  void _showChatPanel() {
    setState(() {
      _showChatOverlay = true;
    });
    _chatOverlayController.forward();
  }

  /// 채팅 오버레이 닫기 (오른쪽으로 슬라이드 아웃)
  void _dismissChatPanel() {
    _chatOverlayController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showChatOverlay = false;
        });
        // 캐릭터 모드 해제
        ref.read(chatModeProvider.notifier).state = ChatMode.fortune;
        ref.read(selectedCharacterProvider.notifier).state = null;
        _pendingLaunchRequest = null;
      }
    });
  }

  Future<void> _handleOpenCharacterFromRoute() async {
    if (_catalogPreviewFromRoute() != null) {
      return;
    }

    final launchRequest =
        FortuneChatLaunchRequest.fromUri(GoRouterState.of(context).uri);

    if (!launchRequest.shouldOpenChat) {
      _pendingLaunchRequest = null;
      _handledRouteLaunchSignature = null;
      _failedRouteLaunchSignature = null;
      return;
    }

    final character = await _resolveLaunchCharacter(launchRequest);
    if (character == null) {
      setState(() {
        _pendingLaunchRequest = null;
      });
      _showMissingFortuneChatFallback(launchRequest);
      return;
    }

    final resolvedRequest = launchRequest.copyWith(characterId: character.id);
    if (_handledRouteLaunchSignature == resolvedRequest.launchSignature &&
        _showChatOverlay) {
      return;
    }

    ref.read(selectedCharacterProvider.notifier).state = character;
    ref.read(chatModeProvider.notifier).state = ChatMode.character;
    setState(() {
      _pendingLaunchRequest = resolvedRequest;
      _handledRouteLaunchSignature = resolvedRequest.launchSignature;
      _failedRouteLaunchSignature = null;
    });

    if (!_showChatOverlay) {
      _showChatPanel();
    }
  }

  Future<AiCharacter?> _resolveLaunchCharacter(
    FortuneChatLaunchRequest request,
  ) async {
    final explicitCharacterId = request.characterId;
    if (explicitCharacterId != null && explicitCharacterId.isNotEmpty) {
      var character = ref.read(characterByIdProvider(explicitCharacterId));
      if (character != null) {
        return character;
      }

      await ref.read(userCreatedCharactersProvider.notifier).ensureLoaded();
      character = ref.read(characterByIdProvider(explicitCharacterId));
      if (character != null) {
        return character;
      }
    }

    final fortuneType = request.fortuneType;
    if (fortuneType != null && fortuneType.isNotEmpty) {
      return findFortuneExpert(fortuneType);
    }

    return null;
  }

  void _showMissingFortuneChatFallback(FortuneChatLaunchRequest request) {
    if (_failedRouteLaunchSignature == request.launchSignature) {
      return;
    }

    _failedRouteLaunchSignature = request.launchSignature;
    Logger.warning('[SwipeHomeShell] Unable to resolve fortune chat launch', {
      'fortuneType': request.fortuneType,
      'characterId': request.characterId,
      'entrySource': request.entrySource,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이 운세는 아직 대화 시작 준비 중이에요.'),
      ),
    );
  }

  /// 캐릭터 선택 처리
  void _onCharacterSelected(AiCharacter character) {
    ref.read(selectedCharacterProvider.notifier).state = character;
    ref.read(chatModeProvider.notifier).state = ChatMode.character;
    _pendingLaunchRequest = null;
    // 채팅 오버레이 표시 (오른쪽에서 슬라이드 인)
    _showChatPanel();
  }

  // TODO: 나중에 복원 - 운세 선택 처리 (FortuneListPanel에서 호출)
  // void _onFortuneSelected(RecommendationChip chip) { ... }

  ChatCatalogPreview? _catalogPreviewFromRoute() {
    return ChatCatalogPreview.fromUri(GoRouterState.of(context).uri);
  }

  @override
  Widget build(BuildContext context) {
    final catalogPreview = _catalogPreviewFromRoute();
    final previewCharacter =
        catalogPreview != null ? catalogPreviewCharacter(catalogPreview) : null;
    final character = previewCharacter ?? ref.watch(selectedCharacterProvider);
    final isCatalogPreview = catalogPreview != null;
    final isRestoringConversations =
        isCatalogPreview ? false : ref.watch(chatRestorationInProgressProvider);
    final showsPreviewOverlay = isCatalogPreview &&
        catalogPreview.showsChatOverlay &&
        character != null;

    // 프로필 페이지에서 "메시지 보내기" 클릭 시 자동으로 채팅 패널 열기
    if (!isCatalogPreview) {
      ref.listen<AiCharacter?>(selectedCharacterProvider, (prev, next) {
        if (next != null && !_showChatOverlay) {
          _showChatPanel();
        }
      });
    }

    // 온보딩 표시
    if (!isCatalogPreview && _showOnboarding) {
      return CharacterOnboardingPage(
        onComplete: _onOnboardingComplete,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 메시지 목록 (CharacterListPanel) - 메인 화면
          CharacterListPanel(
            onCharacterSelected: _onCharacterSelected,
            catalogPreview: catalogPreview,
          ),

          // 캐릭터 채팅 오버레이 (오른쪽에서 슬라이드 인)
          if (showsPreviewOverlay)
            CharacterChatPanel(
              key: ValueKey(
                'catalog-preview-${catalogPreview.state}-${character.id}',
              ),
              character: character,
              initialFortuneType: catalogPreview.fortuneType,
              catalogPreview: catalogPreview,
            ),
          if (!showsPreviewOverlay && _showChatOverlay && character != null)
            SlideTransition(
              position: _chatOverlayAnimation,
              child: CharacterChatPanel(
                key: ValueKey(character.id),
                character: character,
                initialFortuneType: _pendingLaunchRequest?.fortuneType,
                autoStartFortune:
                    _pendingLaunchRequest?.autoStartFortune ?? false,
                entrySource: _pendingLaunchRequest?.entrySource,
                onBack: _dismissChatPanel,
              ),
            ),

          if (isRestoringConversations && !_showChatOverlay)
            _buildConversationRestoringOverlay(context),
        ],
      ),
    );
  }

  Widget _buildConversationRestoringOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.82),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.loading,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
