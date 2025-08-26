import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/utils/logger.dart';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';

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
      backgroundColor: AppColors.tossBackground,
      appBar: _buildAppBar(),
      body: _showPaper ? _buildResultView() : _buildMainView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.tossTextPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '포춘 쿠키',
        style: TextStyle(
          color: AppColors.tossTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_showPaper)
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.tossBlue),
            onPressed: _resetCookie,
          ),
      ],
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 40),
            if (_selectedCookie == null) ...[
              _buildCookieSelection(),
            ] else ...[
              _buildSelectedCookie(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _selectedCookie == null 
            ? '포춘 쿠키를 선택하세요'
            : _isCracking 
              ? '쿠키가 열리고 있어요!'
              : '쿠키를 탭해서 깨뜨리세요',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.tossTextPrimary,
            letterSpacing: -0.5,
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: -0.2, end: 0),
        const SizedBox(height: 12),
        Text(
          _selectedCookie == null
            ? '오늘의 운세가 담긴 쿠키를 골라보세요'
            : '특별한 메시지가 당신을 기다리고 있어요',
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.tossTextSecondary,
            height: 1.5,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cookie.color : AppColors.tossBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? cookie.color.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cookie.color.withValues(alpha: 0.1),
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tossTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cookie.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.tossTextSecondary,
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
    );
  }

  Widget _buildSelectedCookie() {
    return Column(
      children: [
        const SizedBox(height: 40),
        GestureDetector(
          onTap: _onCookieTap,
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
                  child: Container(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cookie shadow
                        Positioned(
                          bottom: 20,
                          child: Container(
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: _selectedCookie!.color.withValues(alpha: 0.3),
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
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFFC68A),
                                          const Color(0xFFFFB56B),
                                          const Color(0xFFFF9F40),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(80),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF9F40).withValues(alpha: 0.4),
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
                                          Colors.white.withValues(alpha: 0.2),
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
                                          painter: CrackPainter(
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
                                          color: Colors.black.withValues(alpha: 0.2),
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
        ),
        const SizedBox(height: 40),
        Text(
          '탭하여 쿠키 깨뜨리기',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.tossTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).fadeIn(duration: const Duration(seconds: 1))
          .then()
          .fadeOut(duration: const Duration(seconds: 1), delay: const Duration(seconds: 1)),
      ],
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
            color: _selectedCookie!.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_selectedCookie!.title} 포춘쿠키',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _selectedCookie!.color,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '오늘의 운세 메시지',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.tossTextPrimary,
            letterSpacing: -0.5,
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _selectedCookie!.color.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Main message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFF9E6),
                        const Color(0xFFFFF3CD),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tossTextPrimary,
                          height: 1.6,
                          letterSpacing: -0.3,
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
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _chineseProverb,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tossTextPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _chineseProverbMeaning,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.tossTextSecondary,
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
                      color: AppColors.tossBorder,
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
                          color: AppColors.tossBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.tossBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '오늘의 조언',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tossTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _advice,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.tossTextPrimary,
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
            AppColors.tossBlue,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.tossTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _shareFortune,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tossBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.share, size: 20),
                SizedBox(width: 8),
                Text(
                  '운세 공유하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _resetCookie,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.tossTextPrimary,
              side: const BorderSide(color: AppColors.tossBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '다른 쿠키 선택하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 800.ms, delay: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.tossTextPrimary,
        ),
      ),
    );
  }

  Future<void> _onCookieTap() async {
    if (_isShaking || _isCracking) return;
    
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
    
    // Generate fortune
    await _generateFortune();
    
    // Crack animation
    await _crackController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _showPaper = true;
    });
    
    // Paper animation
    await _paperController.forward();
  }

  Future<void> _generateFortune() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        _generateLocalFortune();
        return;
      }

      final userProfile = await ref.read(userProfileProvider.future);
      
      final params = {
        'cookieType': _selectedCookie!.name,
        'name': userProfile?.name ?? '사용자',
        'birthDate': userProfile?.birthDate?.toIso8601String(),
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getFortune(
        fortuneType: 'fortune_cookie',
        userId: user.id,
        params: params,
      );

      _parseFortune(fortune);
    } catch (e) {
      Logger.error('Failed to generate fortune', e);
      _generateLocalFortune();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseFortune(Fortune fortune) {
    final content = fortune.content ?? '';
    final lines = content.split('\n');
    
    _mainMessage = lines.isNotEmpty ? lines[0] : _getDefaultMessage();
    _chineseProverb = lines.length > 1 ? lines[1] : _getDefaultProverb();
    _chineseProverbMeaning = lines.length > 2 ? lines[2] : _getDefaultProverbMeaning();
    _advice = lines.length > 3 ? lines[3] : _getDefaultAdvice();
    
    _generateLuckyInfo();
  }

  void _generateLocalFortune() {
    _mainMessage = _getDefaultMessage();
    _chineseProverb = _getDefaultProverb();
    _chineseProverbMeaning = _getDefaultProverbMeaning();
    _advice = _getDefaultAdvice();
    _generateLuckyInfo();
  }

  void _generateLuckyInfo() {
    final random = math.Random();
    _luckyNumbers = List.generate(6, (_) => random.nextInt(45) + 1)..sort();
    
    final colors = [
      (Colors.red, '빨강'),
      (Colors.blue, '파랑'),
      (Colors.green, '초록'),
      (Colors.yellow, '노랑'),
      (Colors.purple, '보라'),
      (Colors.orange, '주황'),
      (Colors.pink, '분홍'),
      (Colors.teal, '청록'),
    ];
    
    final selectedColor = colors[random.nextInt(colors.length)];
    _luckyColor = selectedColor.$1;
    _luckyColorName = selectedColor.$2;
  }

  String _getDefaultMessage() {
    final messages = {
      CookieType.love: '사랑하는 사람과의 소중한 순간이 찾아올 거예요',
      CookieType.wealth: '예상치 못한 곳에서 재물의 기회가 찾아옵니다',
      CookieType.health: '건강한 습관이 큰 변화를 만들어낼 거예요',
      CookieType.wisdom: '오늘의 경험이 내일의 지혜가 됩니다',
      CookieType.luck: '행운은 준비된 자에게 찾아옵니다',
    };
    return messages[_selectedCookie] ?? '좋은 일이 생길 거예요';
  }

  String _getDefaultProverb() {
    final proverbs = {
      CookieType.love: '緣分天定',
      CookieType.wealth: '積少成多',
      CookieType.health: '健康第一',
      CookieType.wisdom: '學無止境',
      CookieType.luck: '吉星高照',
    };
    return proverbs[_selectedCookie] ?? '萬事如意';
  }

  String _getDefaultProverbMeaning() {
    final meanings = {
      CookieType.love: '인연은 하늘이 정한다',
      CookieType.wealth: '작은 것이 모여 큰 것이 된다',
      CookieType.health: '건강이 제일이다',
      CookieType.wisdom: '배움에는 끝이 없다',
      CookieType.luck: '길한 별이 높이 비춘다',
    };
    return meanings[_selectedCookie] ?? '모든 일이 뜻대로 되기를';
  }

  String _getDefaultAdvice() {
    final advices = {
      CookieType.love: '마음을 열고 주변을 둘러보세요. 특별한 인연이 가까이 있을지도 몰라요.',
      CookieType.wealth: '작은 투자나 저축을 시작하기 좋은 시기입니다. 꾸준함이 열쇠예요.',
      CookieType.health: '오늘 30분만 운동에 투자해보세요. 몸과 마음이 가벼워질 거예요.',
      CookieType.wisdom: '새로운 것을 배우기 좋은 날입니다. 호기심을 따라가 보세요.',
      CookieType.luck: '긍정적인 마음가짐이 더 큰 행운을 불러옵니다.',
    };
    return advices[_selectedCookie] ?? '오늘 하루도 최선을 다해보세요.';
  }

  void _shareFortune() {
    final shareText = '''
🥠 ${_selectedCookie!.title} 포춘쿠키

"$_mainMessage"

$_chineseProverb
$_chineseProverbMeaning

💡 오늘의 조언
$_advice

🎰 행운의 숫자: ${_luckyNumbers.join(', ')}
🎨 행운의 색상: $_luckyColorName

- Fortune 앱에서 확인한 오늘의 운세 -
''';
    
    Share.share(shareText);
  }

  void _resetCookie() {
    setState(() {
      _selectedCookie = null;
      _showPaper = false;
      _isCracking = false;
      _fortune = null;
    });
    
    _crackController.reset();
    _paperController.reset();
  }
}

// Custom painter for crack effect
class CrackPainter extends CustomPainter {
  final double progress;

  CrackPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw crack lines
    path.moveTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.5 * progress, size.height * 0.3 * progress);
    path.moveTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width * 0.5 * progress, size.height * 0.7 * progress);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CrackPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}