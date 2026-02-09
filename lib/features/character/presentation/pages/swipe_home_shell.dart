import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/character_provider.dart';
import '../../domain/models/ai_character.dart';
import '../widgets/fortune_list_panel.dart';
import 'character_list_panel.dart';
import 'character_chat_panel.dart';
import '../../../../features/chat/domain/models/recommendation_chip.dart';

/// 3-Panel 스와이프 홈 셸
/// - 왼쪽: 운세 목록 (FortuneListPanel)
/// - 가운데: DM 선택창 (CharacterListPanel) 또는 운세 채팅 (ChatHomePage)
/// - 오른쪽에서 슬라이드: 캐릭터 채팅 (CharacterChatPanel)
class SwipeHomeShell extends ConsumerStatefulWidget {
  const SwipeHomeShell({super.key});

  @override
  ConsumerState<SwipeHomeShell> createState() => _SwipeHomeShellState();
}

class _SwipeHomeShellState extends ConsumerState<SwipeHomeShell>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _chatOverlayController;
  late Animation<Offset> _chatOverlayAnimation;

  bool _showChatOverlay = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // 가운데(DM 목록)에서 시작

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

    // 프로필 페이지에서 "메시지 보내기" 클릭 시 자동으로 채팅 패널 열기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AiCharacter?>(selectedCharacterProvider, (prev, next) {
        if (next != null && !_showChatOverlay) {
          _showChatPanel();
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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
    });
  }

  /// 캐릭터 선택 처리
  void _onCharacterSelected(AiCharacter character) {
    ref.read(selectedCharacterProvider.notifier).state = character;
    ref.read(chatModeProvider.notifier).state = ChatMode.character;
    // 채팅 오버레이 표시 (오른쪽에서 슬라이드 인)
    _showChatPanel();
  }

  /// 운세 선택 처리 (FortuneListPanel에서 호출)
  void _onFortuneSelected(RecommendationChip chip) {
    ref.read(chatModeProvider.notifier).state = ChatMode.fortune;
    ref.read(selectedCharacterProvider.notifier).state = null;
    // 선택된 칩은 이미 pendingFortuneChipProvider에 저장됨
    // ChatHomePage로 네비게이션 (운세 채팅 화면)
    context.go('/home');
  }

  /// 가운데 패널 콘텐츠 (DM 목록)
  Widget _buildMainContent() {
    // 기본: DM 선택창 (메시지 목록)
    return CharacterListPanel(
      onCharacterSelected: _onCharacterSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(selectedCharacterProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 2-Panel PageView (왼쪽: 운세, 오른쪽: DM 목록)
          PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(), // 바운스 효과 제거
            onPageChanged: (_) {
              // 페이지 스와이프 시 키보드 닫기
              FocusScope.of(context).unfocus();
            },
            children: [
              // 왼쪽: 운세 목록
              FortuneListPanel(
                onFortuneSelected: _onFortuneSelected,
              ),
              // 오른쪽: DM 선택창
              _buildMainContent(),
            ],
          ),

          // 캐릭터 채팅 오버레이 (오른쪽에서 슬라이드 인)
          if (_showChatOverlay && character != null)
            SlideTransition(
              position: _chatOverlayAnimation,
              child: CharacterChatPanel(
                character: character,
                onBack: _dismissChatPanel,
              ),
            ),
        ],
      ),
    );
  }
}
