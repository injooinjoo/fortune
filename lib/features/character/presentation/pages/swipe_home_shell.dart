import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/navigation/fortune_chat_route.dart';
import '../../../../core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_connection_service.dart';
import '../../../../screens/auth/signup_screen.dart';
import '../../../../screens/onboarding/onboarding_page.dart';
import '../providers/character_provider.dart';
import '../providers/user_created_character_provider.dart';
import '../../data/fortune_characters.dart';
import '../../domain/models/ai_character.dart';
import '../utils/chat_catalog_preview.dart';
import 'character_list_panel.dart';
import 'character_chat_panel.dart';
import '../../../../services/storage_service.dart';
import '../../../../presentation/providers/auth_provider.dart';

/// 홈 셸 (임시: 메시지 목록만 표시)
/// - 메시지 목록 (CharacterListPanel) - 메인
/// - 오른쪽에서 슬라이드 오버레이: 캐릭터 채팅 (CharacterChatPanel)
///
/// TODO: 나중에 복원할 패널들 (임시 숨김)
/// - 왼쪽: 운세 목록 (FortuneListPanel)
/// - 가운데: 메인 채팅 (ChatHomePage)
enum _ShellOnboardingGate { none, authEntry, profileFlow }

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
  bool _isCheckingOnboarding = true;
  _ShellOnboardingGate _onboardingGate = _ShellOnboardingGate.none;

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
    if (mounted) {
      setState(() {
        _isCheckingOnboarding = true;
      });
    }

    final progress = await _storageService.getUnifiedOnboardingProgress();
    final currentUser = SupabaseConnectionService.tryGetCurrentUser();
    final localProfile = await _storageService.getUserProfile();

    final hasBirthData = _hasBirthData(localProfile);
    final hasInterestSelection = _hasInterestSelection(localProfile);
    final legacyCompleted =
        await _storageService.isCharacterOnboardingCompleted() ||
            localProfile?['onboarding_completed'] == true;

    // force_onboarding 플래그: 테스트 계정은 매번 온보딩 표시
    final forceOnboarding =
        _shouldForceOnboarding(localProfile) ||
        await _checkForceOnboardingFromDb(currentUser);

    _ShellOnboardingGate nextGate = _ShellOnboardingGate.none;

    if (forceOnboarding && currentUser != null) {
      // 로컬 온보딩 상태 초기화 후 온보딩 강제 표시
      await _storageService.saveUnifiedOnboardingProgress(
        progress.copyWith(
          softGateCompleted: false,
          birthCompleted: false,
          interestCompleted: false,
          firstRunHandoffSeen: false,
        ),
      );
      nextGate = _ShellOnboardingGate.profileFlow;
    } else if (legacyCompleted) {
      await _storageService.saveUnifiedOnboardingProgress(
        progress.copyWith(
          softGateCompleted: true,
          authCompleted: true,
          birthCompleted: true,
          interestCompleted: true,
          firstRunHandoffSeen: true,
        ),
      );
    } else if (currentUser == null) {
      nextGate = progress.softGateCompleted
          ? _ShellOnboardingGate.none
          : _ShellOnboardingGate.authEntry;
    } else {
      final needsBirthStep = !progress.birthCompleted && !hasBirthData;
      final needsInterestStep =
          !progress.interestCompleted && !hasInterestSelection;
      final needsHandoff = !progress.firstRunHandoffSeen;

      await _storageService.saveUnifiedOnboardingProgress(
        progress.copyWith(
          authCompleted: true,
          birthCompleted: progress.birthCompleted || hasBirthData,
          interestCompleted: progress.interestCompleted || hasInterestSelection,
        ),
      );

      if (needsBirthStep || needsInterestStep || needsHandoff) {
        nextGate = _ShellOnboardingGate.profileFlow;
      }
    }

    if (mounted) {
      setState(() {
        _onboardingGate = nextGate;
        _isCheckingOnboarding = false;
      });
    }
  }

  bool _shouldForceOnboarding(Map<String, dynamic>? profileJson) {
    if (profileJson == null) return false;
    final isTest = profileJson['is_test_account'] == true;
    if (!isTest) return false;
    final features = _asMap(profileJson['test_account_features']);
    return features?['force_onboarding'] == true;
  }

  Future<bool> _checkForceOnboardingFromDb(User? user) async {
    if (user == null) return false;
    try {
      final row = await Supabase.instance.client
          .from('user_profiles')
          .select('is_test_account, test_account_features')
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 2));
      if (row == null || row['is_test_account'] != true) return false;
      final features = _asMap(row['test_account_features']);
      return features?['force_onboarding'] == true;
    } catch (_) {
      return false;
    }
  }

  bool _hasBirthData(Map<String, dynamic>? profileJson) {
    final raw = profileJson?['birth_date'];
    return raw != null && raw.toString().trim().isNotEmpty;
  }

  bool _hasInterestSelection(Map<String, dynamic>? profileJson) {
    final preferences = _asMap(profileJson?['fortune_preferences']);
    final weights = _asMap(preferences?['category_weights']);
    return weights != null && weights.isNotEmpty;
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Future<void> _handleGuestBrowse() async {
    await _storageService.updateUnifiedOnboardingProgress(
      softGateCompleted: true,
    );

    if (mounted) {
      setState(() {
        _onboardingGate = _ShellOnboardingGate.none;
      });
    }
  }

  void _onOnboardingComplete() {
    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingGate = _ShellOnboardingGate.none;
    });
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

    if (!isCatalogPreview && _isCheckingOnboarding) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isCatalogPreview &&
        _onboardingGate == _ShellOnboardingGate.authEntry) {
      return SignupScreen(
        eyebrow: '먼저 둘러보기',
        title: '대화를 둘러본 뒤,\n필요할 때 이어가세요',
        description: '계정을 연결하면 저장과 개인화가 바로 이어지고, 지금은 둘러보기로 가볍게 시작할 수 있어요.',
        onAuthenticated: () {
          unawaited(_checkOnboarding());
        },
        onBrowseAsGuest: _handleGuestBrowse,
      );
    }

    if (!isCatalogPreview &&
        _onboardingGate == _ShellOnboardingGate.profileFlow) {
      return OnboardingPage(
        onCompleted: _onOnboardingComplete,
        showGuestBrowseAction: false,
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
