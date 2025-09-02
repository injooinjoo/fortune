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
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';

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
      duration: TossTheme.animationSlow,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: TossTheme.animationNormal,
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

  /// 분수대 화면 - 토스 스타일로 개편
  Widget _buildFountainView() {
    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      appBar: AppHeader(
        title: '소원 빌기',
        showBackButton: true,
        centerTitle: true,
        onBackPressed: () {
          ref.read(navigationVisibilityProvider.notifier).show();
          context.pop();
        },
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: TossTheme.textGray600),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TossTheme.spacingXL),
            
            // 메인 헤더
            _buildMainHeader(),
            
            const SizedBox(height: TossTheme.spacingXL),
            
            // 토스 스타일 일러스트 카드
            _buildWishIllustrationCard(),
            
            const SizedBox(height: TossTheme.spacingXL),
            
            // 소원 상태 카드
            if (_hasWish) _buildWishStatusCard(),
            
            const SizedBox(height: TossTheme.spacingXL),
            
            // 액션 버튼들
            _buildActionButtons(),
            
            const SizedBox(height: TossTheme.spacingXXL),
          ],
        ),
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

  /// 신의 응답 화면 - 토스 스타일로 개편
  Widget _buildDivineResponseView() {
    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      appBar: AppHeader(
        title: '신의 응답',
        showBackButton: true,
        centerTitle: true,
        onBackPressed: () {
          ref.read(navigationVisibilityProvider.notifier).show();
          context.pop();
        },
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: TossTheme.textGray600),
            onPressed: _makeNewWish,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: TossTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: TossTheme.spacingL),
                
                // 신의 응답 헤더
                _buildResponseHeader(),
                
                const SizedBox(height: TossTheme.spacingXL),
                
                // 원본 소원 카드
                _buildOriginalWishCard(),
                
                const SizedBox(height: TossTheme.spacingL),
                
                // 신의 응답 카드
                _buildDivineResponseCard(),
                
                const SizedBox(height: TossTheme.spacingXL),
                
                // 새 소원 버튼
                TossButton(
                  text: '새로운 소원 빌기',
                  onPressed: _makeNewWish,
                  size: TossButtonSize.large,
                  width: double.infinity,
                ),
                
                const SizedBox(height: TossTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// 응답 헤더
  Widget _buildResponseHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✨ 신의 응답이 도착했어요',
          style: TossTheme.heading2,
        ),
        const SizedBox(height: TossTheme.spacingS),
        Text(
          '당신의 소원에 대한 특별한 메시지예요',
          style: TossTheme.subtitle1,
        ),
      ],
    );
  }

  /// 원본 소원 카드
  Widget _buildOriginalWishCard() {
    return TossCard(
      style: TossCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: TossTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '당신의 소원',
                style: TossTheme.heading5.copyWith(color: TossTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossTheme.spacingM),
            decoration: BoxDecoration(
              color: TossTheme.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(TossTheme.radiusS),
            ),
            child: Text(
              _wishText,
              style: TossTheme.body3,
            ),
          ),
          const SizedBox(height: TossTheme.spacingS),
          Text(
            '카테고리: $_category  •  긴급도: $_urgency/5',
            style: TossTheme.caption,
          ),
        ],
      ),
    );
  }

  /// 신의 응답 카드
  Widget _buildDivineResponseCard() {
    return TossCard(
      style: TossCardStyle.filled,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TossTheme.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TossTheme.primaryBlue,
              TossTheme.primaryBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: TossTheme.spacingS),
                Text(
                  '신의 응답',
                  style: TossTheme.heading4.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: TossTheme.spacingL),
            Text(
              _divineResponse,
              style: TossTheme.body2.copyWith(
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 헤더
  Widget _buildMainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🌟 소원을 빌어보세요',
          style: TossTheme.heading2,
        ),
        const SizedBox(height: TossTheme.spacingS),
        Text(
          '간절한 마음으로 소원을 작성하면\n신의 특별한 응답을 받을 수 있어요',
          style: TossTheme.subtitle1,
        ),
      ],
    );
  }

  /// 토스 스타일 일러스트 카드
  Widget _buildWishIllustrationCard() {
    return TossCard(
      style: TossCardStyle.filled,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TossTheme.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TossTheme.primaryBlue.withOpacity(0.1),
              TossTheme.primaryBlue.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.stars,
                  size: 40,
                  color: TossTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: TossTheme.spacingM),
              Text(
                '소원의 분수대',
                style: TossTheme.heading4,
              ),
              const SizedBox(height: TossTheme.spacingS),
              Text(
                '마음을 담아 소원을 빌어보세요',
                style: TossTheme.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 소원 상태 카드
  Widget _buildWishStatusCard() {
    return TossCard(
      style: TossCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: TossTheme.success,
                size: 20,
              ),
              const SizedBox(width: TossTheme.spacingS),
              Text(
                '소원이 준비되었어요',
                style: TossTheme.heading5.copyWith(color: TossTheme.success),
              ),
            ],
          ),
          const SizedBox(height: TossTheme.spacingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossTheme.spacingM),
            decoration: BoxDecoration(
              color: TossTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(TossTheme.radiusS),
            ),
            child: Text(
              _wishText.length > 50 ? '${_wishText.substring(0, 50)}...' : _wishText,
              style: TossTheme.body3,
            ),
          ),
          const SizedBox(height: TossTheme.spacingS),
          Text(
            '카테고리: $_category',
            style: TossTheme.caption,
          ),
        ],
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_hasWish) ...[
          TossButton(
            text: '소원 작성하기',
            onPressed: _writeWish,
            size: TossButtonSize.large,
            width: double.infinity,
          ),
        ] else ...[
          TossButton(
            text: _isThrowingCoin ? '소원을 전달하고 있어요...' : '소원 빌기',
            onPressed: _isThrowingCoin ? null : _throwCoin,
            size: TossButtonSize.large,
            width: double.infinity,
            isLoading: _isThrowingCoin,
          ),
          const SizedBox(height: TossTheme.spacingM),
          TossButton(
            text: '소원 다시 작성하기',
            onPressed: _writeWish,
            style: TossButtonStyle.secondary,
            size: TossButtonSize.large,
            width: double.infinity,
          ),
        ],
      ],
    );
  }

  /// 도움말 다이얼로그
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TossTheme.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: TossTheme.primaryBlue),
            const SizedBox(width: TossTheme.spacingS),
            Text('소원 빌기란?', style: TossTheme.heading4),
          ],
        ),
        content: Text(
          '소원 빌기는 운세를 보는 것이 아니라, 당신의 간절한 소원을 신에게 전달하고 신의 응답과 격려를 받는 특별한 경험입니다.\n\n'
          '소원을 작성하면 신이 당신만을 위한 맞춤형 응답과 조언을 주실 것입니다.',
          style: TossTheme.body3.copyWith(height: 1.5),
        ),
        actions: [
          TossButton(
            text: '확인',
            onPressed: () => Navigator.of(context).pop(),
            style: TossButtonStyle.secondary,
            size: TossButtonSize.small,
          ),
        ],
      ),
    );
  }
}