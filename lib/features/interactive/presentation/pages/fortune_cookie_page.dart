import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';
import '../../../fortune/presentation/widgets/fortune_button.dart';

/// 포춘쿠키 타입
enum CookieType {
  love('사랑', '💕', Color(0xFFFF6B9D), '연애와 인연에 관한 메시지'),
  wealth('재물', '💰', Color(0xFFFFC107), '금전과 재물에 관한 메시지'),
  health('건강', '🌿', Color(0xFF66BB6A), '건강과 활력에 관한 메시지'),
  wisdom('지혜', '🔮', Color(0xFF7E57C2), '지혜와 깨달음의 메시지'),
  luck('행운', '🍀', Color(0xFF29B6F6), '오늘의 행운 메시지');

  const CookieType(this.title, this.emoji, this.color, this.description);
  
  final String title;
  final String emoji;
  final Color color;
  final String description;
}

class FortuneCookiePage extends ConsumerStatefulWidget {
  const FortuneCookiePage({super.key});

  @override
  ConsumerState<FortuneCookiePage> createState() => _FortuneCookiePageState();
}

class _FortuneCookiePageState extends ConsumerState<FortuneCookiePage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _shakeController;
  late AnimationController _crackController;
  late AnimationController _paperController;
  late AnimationController _floatController;
  
  // Animations
  late Animation<double> _shakeAnimation;
  late Animation<double> _crackAnimation;
  late Animation<double> _paperAnimation;
  late Animation<double> _floatAnimation;
  
  // State
  CookieType? _selectedCookie;
  bool _isShaking = false;
  bool _isCracking = false;
  bool _showPaper = false;
  bool _isLoading = false;
  bool _isProcessing = false; // 애니메이션 중복 방지
  Fortune? _fortune;
  
  // Fortune content
  String _mainMessage = '';
  String _chineseProverb = '';
  String _chineseProverbMeaning = '';
  List<int> _luckyNumbers = [];
  Color _luckyColor = Colors.blue;
  String _luckyColorName = '';
  String _advice = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _crackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _paperController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _shakeAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _crackAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _crackController,
      curve: Curves.easeOutBack,
    ));
    
    _paperAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _paperController,
      curve: const ElasticOutCurve(0.8),
    ));
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _crackController.dispose();
    _paperController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.white,
      appBar: _buildAppBar(),
      body: _showPaper ? _buildResultView() : _buildMainView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TossDesignSystem.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: TossDesignSystem.gray900),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '포춘 쿠키',
        style: TossDesignSystem.heading3.copyWith(
          color: TossDesignSystem.gray900,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_showPaper)
          IconButton(
            icon: Icon(Icons.refresh, color: TossDesignSystem.gray900),
            onPressed: _resetCookie,
          ),
      ],
    );
  }

  Widget _buildMainView() {
    if (_selectedCookie == null) {
      // 쿠키 선택 화면
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildCookieSelection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    } else {
      // 쿠키 터치 화면 - 중앙 배치
      return Stack(
        children: [
          // 헤더 텍스트
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildCookieHeader(),
          ),
          
          // 중앙 쿠키
          Center(
            child: _buildCenteredCookie(),
          ),
          
          // 하단 힌트
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Center(
              child: Text(
                '탭하여 쿠키 깨뜨리기',
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.gray500,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).fadeIn(duration: 1.seconds)
                .then(delay: 1.seconds)
                .fadeOut(duration: 1.seconds),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          '포춘 쿠키를 선택하세요',
          style: TossDesignSystem.heading2.copyWith(
            color: TossDesignSystem.gray900,
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: -0.2, end: 0),
        const SizedBox(height: 12),
        Text(
          '오늘의 운세가 담긴 쿠키를 골라보세요',
          style: TossDesignSystem.body2.copyWith(
            color: TossDesignSystem.gray600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate()
          .fadeIn(duration: 700.ms, delay: 200.ms)
          .slideY(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildCookieHeader() {
    return Column(
      children: [
        Text(
          _isCracking 
            ? '쿠키가 열리고 있어요!'
            : '쿠키를 탭해서 깨뜨리세요',
          style: TossDesignSystem.heading3.copyWith(
            color: TossDesignSystem.gray900,
          ),
          textAlign: TextAlign.center,
        ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          '특별한 메시지가 당신을 기다리고 있어요',
          style: TossDesignSystem.body2.copyWith(
            color: TossDesignSystem.gray600,
          ),
          textAlign: TextAlign.center,
        ).animate()
          .fadeIn(duration: 700.ms, delay: 200.ms)
          .slideY(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildCookieSelection() {
    return Column(
      children: [
        _buildSectionTitle('어떤 운세가 궁금하신가요?'),
        const SizedBox(height: 16),
        ...CookieType.values.map((cookie) => 
          _buildCookieTypeCard(cookie)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * cookie.index))
            .slideX(begin: -0.1, end: 0)
        ),
      ],
    );
  }

  Widget _buildCookieTypeCard(CookieType cookie) {
    final isSelected = _selectedCookie == cookie;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCookie = cookie;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: TossCard(
          padding: const EdgeInsets.all(20),
          style: isSelected ? TossCardStyle.filled : TossCardStyle.outlined,
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cookie.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    cookie.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cookie.title} 포춘쿠키',
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cookie.description,
                      style: TossDesignSystem.body2.copyWith(
                        color: TossDesignSystem.gray600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: cookie.color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredCookie() {
    return GestureDetector(
      onTap: _isProcessing ? null : _onCookieTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _shakeAnimation,
          _crackAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _isShaking ? _shakeAnimation.value : 0,
              0,
            ),
            child: Transform.scale(
              scale: 1.0 - (_crackAnimation.value * 0.1),
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cookie shadow
                    Positioned(
                      bottom: 50,
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedCookie!.color.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Cookie body
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cookie shape
                              Container(
                                width: 220,
                                height: 160,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFC68A),
                                      Color(0xFFFFB56B),
                                      Color(0xFFFF9F40),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(80),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF9F40).withOpacity(0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                              ),
                              // Cookie texture
                              Container(
                                width: 220,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.center,
                                  ),
                                ),
                              ),
                              // Crack effect
                              if (_isCracking)
                                Opacity(
                                  opacity: _crackAnimation.value,
                                  child: Container(
                                    width: 220,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: CustomPaint(
                                      painter: ImprovedCrackPainter(
                                        progress: _crackAnimation.value,
                                      ),
                                    ),
                                  ),
                                ),
                              // Cookie emoji
                              Text(
                                _selectedCookie!.emoji,
                                style: TextStyle(
                                  fontSize: 60,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildResultHeader(),
          const SizedBox(height: 32),
          _buildFortuneCard(),
          const SizedBox(height: 20),
          _buildLuckyInfo(),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _selectedCookie!.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_selectedCookie!.title} 포춘쿠키',
            style: TossDesignSystem.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: _selectedCookie!.color,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '오늘의 운세 메시지',
          style: TossDesignSystem.heading2.copyWith(
            color: TossDesignSystem.gray900,
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 800.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildFortuneCard() {
    return AnimatedBuilder(
      animation: _paperAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _paperAnimation.value,
          child: TossCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Main message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFF9E6),
                        Color(0xFFFFF3CD),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFE4A1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '"',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFFFB74D),
                          height: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _mainMessage,
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: TossDesignSystem.gray900,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '"',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFFFB74D),
                          height: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Chinese proverb
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _chineseProverb,
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TossDesignSystem.gray900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _chineseProverbMeaning,
                        style: TossDesignSystem.body2.copyWith(
                          color: TossDesignSystem.gray600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Advice
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TossDesignSystem.gray200,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: TossDesignSystem.tossBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: TossDesignSystem.tossBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오늘의 조언',
                              style: TossDesignSystem.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: TossDesignSystem.gray700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _advice,
                              style: TossDesignSystem.body2.copyWith(
                                color: TossDesignSystem.gray700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLuckyInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildLuckyCard(
            '행운의 숫자',
            _luckyNumbers.join(', '),
            Icons.casino_outlined,
            TossDesignSystem.tossBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildLuckyCard(
            '행운의 색상',
            _luckyColorName,
            Icons.palette_outlined,
            _luckyColor,
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 800.ms, delay: 400.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLuckyCard(String title, String value, IconData icon, Color color) {
    return TossCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TossDesignSystem.caption.copyWith(
              color: TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        FortuneButton(
          text: '새로운 쿠키 열기',
          onPressed: _resetCookie,
          type: FortuneButtonType.primary,
          icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FortuneButton(
          text: '운세 공유하기',
          onPressed: _shareFortune,
          type: FortuneButtonType.secondary,
          icon: const Icon(Icons.share_outlined, size: 20),
        ),
      ],
    ).animate()
      .fadeIn(duration: 800.ms, delay: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TossDesignSystem.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: TossDesignSystem.gray700,
          ),
        ),
      ],
    );
  }

  Future<void> _onCookieTap() async {
    if (_isProcessing || _isShaking || _isCracking) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isShaking = true;
    });
    
    // Shake animation
    await _shakeController.forward();
    await _shakeController.reverse();
    await _shakeController.forward();
    await _shakeController.reverse();
    
    setState(() {
      _isShaking = false;
      _isCracking = true;
    });
    
    // Get fortune
    await _getFortune();
    
    // Crack animation
    await _crackController.forward();
    
    // Show paper
    setState(() {
      _showPaper = true;
    });
    
    // Paper animation
    await _paperController.forward();
    
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _getFortune() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.value?.session?.user.id ?? 'anonymous';
      
      final fortune = await ref.read(fortuneServiceProvider).getFortune(
        fortuneType: 'fortune-cookie',
        userId: userId,
        params: {
          'cookieType': _selectedCookie?.name ?? 'luck',
        },
      );

      if (fortune != null) {
        _parseFortune(fortune);
      } else {
        _generateMockFortune();
      }
    } catch (e) {
      Logger.error('Failed to get fortune', e);
      _generateMockFortune();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseFortune(Fortune fortune) {
    final result = fortune.metadata ?? {};
    
    setState(() {
      _mainMessage = result['message'] ?? fortune.content ?? _generateDefaultMessage();
      _chineseProverb = result['proverb'] ?? _generateDefaultProverb();
      _chineseProverbMeaning = result['proverbMeaning'] ?? _generateDefaultProverbMeaning();
      _luckyNumbers = _parseNumbers(result['luckyNumbers']) ?? _generateLuckyNumbers();
      _luckyColor = _parseColor(result['luckyColor']) ?? _generateLuckyColor();
      _luckyColorName = result['luckyColorName'] ?? _getLuckyColorName(_luckyColor);
      _advice = result['advice'] ?? _generateAdvice();
    });
  }

  List<int>? _parseNumbers(dynamic numbers) {
    if (numbers is List) {
      return numbers.map((e) => e as int).toList();
    } else if (numbers is String) {
      return numbers.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    }
    return null;
  }

  Color? _parseColor(dynamic color) {
    if (color is String) {
      if (color.startsWith('#')) {
        return Color(int.parse(color.substring(1), radix: 16) | 0xFF000000);
      } else if (color.startsWith('0x')) {
        return Color(int.parse(color));
      }
    }
    return null;
  }

  void _generateMockFortune() {
    setState(() {
      _mainMessage = _generateDefaultMessage();
      _chineseProverb = _generateDefaultProverb();
      _chineseProverbMeaning = _generateDefaultProverbMeaning();
      _luckyNumbers = _generateLuckyNumbers();
      _luckyColor = _generateLuckyColor();
      _luckyColorName = _getLuckyColorName(_luckyColor);
      _advice = _generateAdvice();
    });
  }

  String _generateDefaultMessage() {
    final messages = {
      CookieType.love: [
        '새로운 인연이 당신을 기다리고 있습니다',
        '사랑하는 사람과의 관계가 더욱 깊어질 것입니다',
        '예상치 못한 곳에서 운명적인 만남이 있을 것입니다',
      ],
      CookieType.wealth: [
        '뜻밖의 재물이 들어올 징조가 보입니다',
        '투자한 것이 좋은 결실을 맺을 것입니다',
        '경제적 안정을 찾게 될 것입니다',
      ],
      CookieType.health: [
        '건강한 에너지가 넘치는 하루가 될 것입니다',
        '몸과 마음이 균형을 찾게 될 것입니다',
        '활력이 넘치는 시기가 다가옵니다',
      ],
      CookieType.wisdom: [
        '중요한 깨달음을 얻게 될 것입니다',
        '지혜로운 선택이 좋은 결과를 가져올 것입니다',
        '새로운 관점으로 세상을 보게 될 것입니다',
      ],
      CookieType.luck: [
        '행운이 당신 곁에 머물 것입니다',
        '모든 일이 순조롭게 풀릴 것입니다',
        '기대 이상의 좋은 일이 생길 것입니다',
      ],
    };
    
    final list = messages[_selectedCookie] ?? messages[CookieType.luck]!;
    return list[math.Random().nextInt(list.length)];
  }

  String _generateDefaultProverb() {
    final proverbs = [
      '千里之行 始於足下',
      '水滴石穿',
      '福禄寿喜',
      '一期一会',
      '日日是好日',
    ];
    return proverbs[math.Random().nextInt(proverbs.length)];
  }

  String _generateDefaultProverbMeaning() {
    final meanings = [
      '천 리 길도 한 걸음부터',
      '물방울이 돌을 뚫는다',
      '복, 녹, 수, 기쁨',
      '일생에 한 번뿐인 만남',
      '매일이 좋은 날',
    ];
    return meanings[math.Random().nextInt(meanings.length)];
  }

  List<int> _generateLuckyNumbers() {
    final random = math.Random();
    final numbers = <int>{};
    while (numbers.length < 3) {
      numbers.add(random.nextInt(45) + 1);
    }
    return numbers.toList()..sort();
  }

  Color _generateLuckyColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  String _getLuckyColorName(Color color) {
    if (color == Colors.red) return '빨강';
    if (color == Colors.blue) return '파랑';
    if (color == Colors.green) return '초록';
    if (color == Colors.yellow) return '노랑';
    if (color == Colors.purple) return '보라';
    if (color == Colors.orange) return '주황';
    if (color == Colors.pink) return '분홍';
    if (color == Colors.teal) return '청록';
    return '파랑';
  }

  String _generateAdvice() {
    final advice = {
      CookieType.love: [
        '진심을 담은 말 한마디가 관계를 변화시킬 수 있습니다',
        '상대방의 입장에서 생각해보는 시간을 가져보세요',
        '사랑은 기다림이 아닌 다가감입니다',
      ],
      CookieType.wealth: [
        '작은 절약이 큰 부를 만듭니다',
        '투자하기 전에 충분히 공부하세요',
        '수입과 지출의 균형을 맞추세요',
      ],
      CookieType.health: [
        '규칙적인 생활 습관이 건강의 기초입니다',
        '스트레스 관리에 신경 쓰세요',
        '충분한 수면과 휴식을 취하세요',
      ],
      CookieType.wisdom: [
        '매일 조금씩 배우는 것이 중요합니다',
        '실수를 두려워하지 마세요',
        '다양한 관점에서 생각해보세요',
      ],
      CookieType.luck: [
        '긍정적인 마음가짐이 행운을 부릅니다',
        '기회는 준비된 자에게 찾아옵니다',
        '감사하는 마음을 잊지 마세요',
      ],
    };
    
    final list = advice[_selectedCookie] ?? advice[CookieType.luck]!;
    return list[math.Random().nextInt(list.length)];
  }

  void _resetCookie() {
    setState(() {
      _selectedCookie = null;
      _showPaper = false;
      _isCracking = false;
      _isShaking = false;
      _isProcessing = false;
    });
    
    _crackController.reset();
    _paperController.reset();
    _shakeController.reset();
  }

  void _shareFortune() {
    final text = '''
🥠 ${_selectedCookie!.title} 포춘쿠키

"$_mainMessage"

$_chineseProverb
($_chineseProverbMeaning)

💡 오늘의 조언: $_advice

🎲 행운의 숫자: ${_luckyNumbers.join(', ')}
🎨 행운의 색상: $_luckyColorName

포춘쿠키로 오늘의 운세를 확인해보세요!
    ''';
    
    Share.share(text);
  }
}

/// 개선된 크랙 페인터 - 픽셀 깨짐 방지
class ImprovedCrackPainter extends CustomPainter {
  final double progress;

  ImprovedCrackPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3 * progress)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true // 안티앨리어싱 적용
      ..strokeCap = StrokeCap.round; // 부드러운 끝처리

    final path = Path();
    
    // 더 자연스러운 균열 패턴
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;
    
    // 메인 균열
    path.moveTo(centerX - 20, centerY);
    path.quadraticBezierTo(
      centerX - 10 * progress, 
      centerY - 20 * progress,
      centerX - 30 * progress, 
      centerY - 40 * progress
    );
    
    path.moveTo(centerX + 20, centerY);
    path.quadraticBezierTo(
      centerX + 10 * progress, 
      centerY + 20 * progress,
      centerX + 30 * progress, 
      centerY + 40 * progress
    );
    
    // 서브 균열
    if (progress > 0.5) {
      path.moveTo(centerX, centerY - 10);
      path.quadraticBezierTo(
        centerX + 15 * (progress - 0.5), 
        centerY - 5,
        centerX + 25 * (progress - 0.5), 
        centerY - 25 * (progress - 0.5)
      );
      
      path.moveTo(centerX, centerY + 10);
      path.quadraticBezierTo(
        centerX - 15 * (progress - 0.5), 
        centerY + 5,
        centerX - 25 * (progress - 0.5), 
        centerY + 25 * (progress - 0.5)
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ImprovedCrackPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}