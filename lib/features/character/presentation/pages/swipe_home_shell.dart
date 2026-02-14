import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/character_provider.dart';
import '../../domain/models/ai_character.dart';
import 'character_list_panel.dart';
import 'character_chat_panel.dart';
import 'character_onboarding_page.dart';
import '../../../../services/storage_service.dart';

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
  String? _pendingCharacterOpenId;

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
        _handleOpenCharacterFromRoute();
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
      }
      _pendingCharacterOpenId = null;
    });
  }

  void _handleOpenCharacterFromRoute() {
    final uri = GoRouterState.of(context).uri;
    final shouldOpen = uri.queryParameters['openCharacterChat'] == 'true';
    final characterId = uri.queryParameters['characterId'];

    if (!shouldOpen || characterId == null || characterId.isEmpty) {
      _pendingCharacterOpenId = null;
      return;
    }

    if (_pendingCharacterOpenId == characterId && _showChatOverlay) {
      return;
    }

    final character = ref.read(characterByIdProvider(characterId));
    if (character == null) return;

    ref.read(selectedCharacterProvider.notifier).state = character;
    ref.read(chatModeProvider.notifier).state = ChatMode.character;
    _pendingCharacterOpenId = characterId;

    if (!_showChatOverlay) {
      _showChatPanel();
    }
  }

  /// 캐릭터 선택 처리
  void _onCharacterSelected(AiCharacter character) {
    ref.read(selectedCharacterProvider.notifier).state = character;
    ref.read(chatModeProvider.notifier).state = ChatMode.character;
    // 채팅 오버레이 표시 (오른쪽에서 슬라이드 인)
    _showChatPanel();
  }

  // TODO: 나중에 복원 - 운세 선택 처리 (FortuneListPanel에서 호출)
  // void _onFortuneSelected(RecommendationChip chip) { ... }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(selectedCharacterProvider);

    // 프로필 페이지에서 "메시지 보내기" 클릭 시 자동으로 채팅 패널 열기
    ref.listen<AiCharacter?>(selectedCharacterProvider, (prev, next) {
      if (next != null && !_showChatOverlay) {
        _showChatPanel();
      }
    });

    // 온보딩 표시
    if (_showOnboarding) {
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
          ),

          // 캐릭터 채팅 오버레이 (오른쪽에서 슬라이드 인)
          if (_showChatOverlay && character != null)
            SlideTransition(
              position: _chatOverlayAnimation,
              child: CharacterChatPanel(
                key: ValueKey(character.id),
                character: character,
                onBack: _dismissChatPanel,
              ),
            ),
        ],
      ),
    );
  }
}
