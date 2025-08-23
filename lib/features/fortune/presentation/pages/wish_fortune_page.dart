import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/divine_response_widget.dart';
import '../widgets/wish_input_bottom_sheet.dart';
import '../widgets/wish_fountain_widget.dart';
import '../widgets/coin_throw_animation.dart';
import '../../domain/services/divine_wish_analyzer.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../services/ad_service.dart';

/// 소원 빌기 페이지 - 분수대에 동전을 던지는 새로운 경험
class WishFortunePage extends ConsumerStatefulWidget {
  const WishFortunePage({super.key});

  @override
  ConsumerState<WishFortunePage> createState() => _WishFortunePageState();
}

enum WishPageState {
  fountain,      // 분수대 화면
  coinThrow,     // 동전 던지기 애니메이션
  divineResponse // 신의 응답
}

class _WishFortunePageState extends ConsumerState<WishFortunePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  WishPageState _currentState = WishPageState.fountain;
  String _wishText = '';
  String _category = '';
  int _urgency = 3;
  String _divineResponse = '';
  bool _hasWish = false;
  bool _isThrowingCoin = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // 페이지 로드시 네비게이션 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).hide();
      _checkForAutoGeneration();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// 자동 생성 파라미터 확인
  void _checkForAutoGeneration() {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    
    if (extra != null && extra['autoGenerate'] == true) {
      final wishParams = extra['wishParams'] as Map<String, dynamic>?;
      if (wishParams != null) {
        _generateDivineResponse(
          wishParams['text'] ?? '',
          wishParams['category'] ?? '',
          wishParams['urgency'] ?? 3,
        );
      }
    }
  }

  /// 신의 응답 생성
  void _generateDivineResponse(String wishText, String category, int urgency) {
    setState(() {
      _wishText = wishText;
      _category = category;
      _urgency = urgency;
      _divineResponse = DivineWishAnalyzer.generateDivineResponse(
        wishText: wishText,
        category: category,
        urgency: urgency,
      );
      _currentState = WishPageState.divineResponse;
    });
    
    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  /// 소원 작성하기
  void _writeWish() {
    WishInputBottomSheet.show(
      context,
      onWishSubmitted: _onWishSubmitted,
    );
  }

  /// 소원 작성 완료 콜백
  void _onWishSubmitted(String wishText, String category, int urgency) {
    setState(() {
      _wishText = wishText;
      _category = category;
      _urgency = urgency;
      _hasWish = true;
    });
  }

  /// 동전 던지기
  void _throwCoin() {
    setState(() {
      _isThrowingCoin = true;
    });
    
    // AdMob 광고 직접 표시
    AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () {
        // 광고 완료 후 신의 응답 표시
        if (mounted) {
          setState(() {
            _isThrowingCoin = false;
          });
          _generateDivineResponse(_wishText, _category, _urgency);
        }
      },
      onAdFailed: () {
        // 광고 실패 시에도 결과 표시
        if (mounted) {
          setState(() {
            _isThrowingCoin = false;
          });
          _generateDivineResponse(_wishText, _category, _urgency);
        }
      },
    );
  }

  /// 새로운 소원 빌기
  void _makeNewWish() {
    setState(() {
      _currentState = WishPageState.fountain;
      _hasWish = false;
      _wishText = '';
      _category = '';
      _urgency = 3;
      _divineResponse = '';
      _isThrowingCoin = false;
    });
    
    _fadeController.reset();
    _slideController.reset();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case WishPageState.fountain:
        return _buildFountainView();
      case WishPageState.divineResponse:
        return _buildDivineResponseView();
      case WishPageState.coinThrow:
        // 더 이상 사용하지 않지만 enum에서 제거하지 않고 fountain으로 리다이렉트
        return _buildFountainView();
    }
  }

  /// 분수대 화면
  Widget _buildFountainView() {
    return Scaffold(
      appBar: AppHeader(
        title: '소원 빌기',
        showBackButton: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: WishFountainWidget(
        onWriteWish: _writeWish,
        onThrowCoin: _hasWish ? _throwCoin : null,
        hasWish: _hasWish,
        coinCount: 127,
        isThrowingCoin: _isThrowingCoin,
      ),
    );
  }

  // 더 이상 사용하지 않는 동전 던지기 화면 메서드는 주석 처리
  // Widget _buildCoinThrowView() {
  //   return CoinThrowAnimation(
  //     onAnimationComplete: _onCoinThrowComplete,
  //     wishText: _wishText,
  //     category: _category,
  //   );
  // }

  /// 신의 응답 화면
  Widget _buildDivineResponseView() {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Stack(
            children: [
              // 신의 응답 위젯
              DivineResponseWidget(
                wishText: _wishText,
                category: _category,
                urgency: _urgency,
                divineResponse: _divineResponse,
              ),
              
              // 상단 버튼들
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 뒤로가기 버튼
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          ref.read(navigationVisibilityProvider.notifier).show();
                          context.pop();
                        },
                      ),
                    ),
                    
                    // 새 소원 버튼
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton.icon(
                        onPressed: _makeNewWish,
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        label: const Text(
                          '새 소원',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 도움말 다이얼로그
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF6B46C1)),
            SizedBox(width: 8),
            Text('소원 빌기란?'),
          ],
        ),
        content: const Text(
          '소원 빌기는 운세를 보는 것이 아니라, 당신의 간절한 소원을 신에게 전달하고 신의 응답과 격려를 받는 특별한 경험입니다.\n\n'
          '소원을 작성하면 신이 당신만을 위한 맞춤형 응답과 조언을 주실 것입니다.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}