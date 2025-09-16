import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/services/divine_wish_analyzer.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';

/// 소원 카테고리 정의
enum WishCategory {
  love('💕', '사랑', '연애, 결혼, 짝사랑', Colors.pink),
  money('💰', '돈', '재물, 투자, 사업', Colors.green),
  health('🌿', '건강', '건강, 회복, 장수', Colors.lightGreen),
  success('🏆', '성공', '취업, 승진, 성취', Colors.orange),
  family('👨‍👩‍👧‍👦', '가족', '가족, 화목, 관계', Colors.blue),
  study('📚', '학업', '시험, 공부, 성적', Colors.indigo),
  other('🌟', '기타', '소원이 있으시면', Colors.purple);

  const WishCategory(this.emoji, this.name, this.description, this.color);

  final String emoji;
  final String name;
  final String description;
  final Color color;
}

/// 소원 빌기 페이지 - 직접 소원을 입력하는 새로운 경험
class WishFortunePage extends ConsumerStatefulWidget {
  const WishFortunePage({super.key});

  @override
  ConsumerState<WishFortunePage> createState() => _WishFortunePageState();
}

enum WishPageState {
  input,         // 소원 입력 화면
  divineResponse // 신의 응답
}

class _WishFortunePageState extends ConsumerState<WishFortunePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers for input fields
  final TextEditingController _wishController = TextEditingController();

  WishPageState _currentState = WishPageState.input;
  WishCategory _selectedCategory = WishCategory.love;
  int _urgencyLevel = 3;
  String _divineResponse = '';

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

    // 페이지 로드시 네비게이션 숨기기 및 광고 미리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).hide();
      _checkForAutoGeneration();

      // 광고 미리 로드하여 버튼 클릭 시 바로 표시되도록 함
      AdService.instance.loadInterstitialAd();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  /// 자동 생성 파라미터 확인
  void _checkForAutoGeneration() {
    // Auto generation removed as we now start with input page
  }

  /// 신의 응답 생성
  void _generateDivineResponse() {
    final wishText = _wishController.text.trim();
    final category = _selectedCategory.name;
    final urgency = _urgencyLevel;

    setState(() {
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

  /// 소원 빌기 - 광고 표시 후 신의 응답
  void _submitWish() {
    if (!_canSubmit()) return;

    // 광고 표시 후 신의 응답 표시
    AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () {
        if (mounted) {
          _generateDivineResponse();
        }
      },
      onAdFailed: () {
        // 광고 실패 시에도 결과 표시
        if (mounted) {
          _generateDivineResponse();
        }
      },
    );
  }

  bool _canSubmit() {
    return _wishController.text.trim().isNotEmpty;
  }


  /// 새로운 소원 빌기
  void _makeNewWish() {
    setState(() {
      _currentState = WishPageState.input;
      _wishController.clear();
      _selectedCategory = WishCategory.love;
      _urgencyLevel = 3;
      _divineResponse = '';
    });

    _fadeController.reset();
    _slideController.reset();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case WishPageState.input:
        return _buildInputView();
      case WishPageState.divineResponse:
        return _buildDivineResponseView();
    }
  }

  /// 소원 입력 화면
  Widget _buildInputView() {
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

            // 카테고리 선택
            _buildCategorySelection(),

            const SizedBox(height: TossTheme.spacingXL),

            // 소원 입력
            _buildWishInput(),

            const SizedBox(height: TossTheme.spacingXL),

            // 긴급도 설정
            _buildUrgencyLevel(),

            const SizedBox(height: TossTheme.spacingXL),

            // 제출 버튼
            TossButton(
              text: '소원 빌기',
              onPressed: _canSubmit() ? _submitWish : null,
              size: TossButtonSize.large,
              width: double.infinity,
            ),

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
              _wishController.text.trim(),
              style: TossTheme.body3,
            ),
          ),
          const SizedBox(height: TossTheme.spacingS),
          Text(
            '카테고리: ${_selectedCategory.name}  •  긴급도: $_urgencyLevel/5',
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

  /// 카테고리 선택
  Widget _buildCategorySelection() {
    return TossCard(
      style: TossCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 소원인가요?',
            style: TossTheme.heading5,
          ),
          const SizedBox(height: TossTheme.spacingM),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WishCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? TossTheme.primaryBlue : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? TossTheme.primaryBlue : TossTheme.borderGray200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : TossTheme.textGray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 소원 입력
  Widget _buildWishInput() {
    return TossCard(
      style: TossCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '소원을 자세히 적어주세요',
            style: TossTheme.heading5,
          ),
          const SizedBox(height: TossTheme.spacingM),
          TextField(
            controller: _wishController,
            maxLines: 4,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: '마음을 담아 소원을 적어보세요...',
              hintStyle: TextStyle(
                color: TossTheme.textGray400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusS),
                borderSide: BorderSide(color: TossTheme.borderGray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusS),
                borderSide: BorderSide(color: TossTheme.borderGray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TossTheme.radiusS),
                borderSide: BorderSide(color: TossTheme.primaryBlue),
              ),
              filled: true,
              fillColor: TossTheme.backgroundSecondary,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TossTheme.body3,
          ),
        ],
      ),
    );
  }

  /// 긴급도 설정
  Widget _buildUrgencyLevel() {
    return TossCard(
      style: TossCardStyle.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '얼마나 간절한가요?',
            style: TossTheme.heading5,
          ),
          const SizedBox(height: TossTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _urgencyLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: TossTheme.primaryBlue,
                  onChanged: (value) {
                    setState(() {
                      _urgencyLevel = value.round();
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            _getUrgencyText(_urgencyLevel),
            style: TossTheme.caption,
          ),
        ],
      ),
    );
  }

  String _getUrgencyText(int level) {
    switch (level) {
      case 1: return '조금 바라는 정도예요';
      case 2: return '그럭저럭 이루고 싶어요';
      case 3: return '꽤 간절해요';
      case 4: return '정말 간절해요';
      case 5: return '온 마음을 다해 빌어요';
      default: return '';
    }
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