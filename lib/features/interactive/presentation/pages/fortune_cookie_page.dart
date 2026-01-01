import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/utils/logger.dart';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';
import '../../../fortune/presentation/widgets/standard_fortune_app_bar.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';

/// F22: veo3 쿠키 부서지는 영상 경로
/// 사용자가 veo3로 생성한 영상을 아래 경로에 추가해주세요.
/// 권장 사양:
/// - 해상도: 1080x1080 (1:1 정사각형)
/// - 길이: 2-3초
/// - 포맷: MP4 (H.264)
/// - 내용: 포춘쿠키가 부서지면서 종이가 나오는 애니메이션
const String _kCookieCrackVideoPath = 'assets/videos/cookie_crack.mp4';

/// 포춘쿠키 타입 (U11: 오방색 적용)
/// 오방색: 청(靑), 적(赤), 황(黃), 백(白), 흑(黑)
enum CookieType {
  love('사랑', '💕', Color(0xFFDC143C), '연애와 인연에 관한 메시지'), // 적색 (화/火)
  wealth('재물', '💰', Color(0xFFDAA520), '금전과 재물에 관한 메시지'), // 황색 (토/土)
  health('건강', '🌿', Color(0xFF2E8B57), '건강과 활력에 관한 메시지'), // 청색 (목/木)
  wisdom('지혜', '🔮', Color(0xFF1E3A5F), '지혜와 깨달음의 메시지'), // 흑색 (수/水)
  luck('행운', '🍀', Color(0xFFC9A962), '오늘의 행운 메시지'); // 금색 (금/金)

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
  bool _isProcessing = false; // 애니메이션 중복 방지

  // F22: veo3 영상 플레이어
  VideoPlayerController? _videoController;
  bool _useVideoAnimation = false; // 영상 파일 존재 여부

  // Fortune content
  String _mainMessage = '';
  String _chineseProverb = '';
  String _chineseProverbMeaning = '';
  List<int> _luckyNumbers = [];
  Color _luckyColor = TossDesignSystem.tossBlue;
  String _luckyColorName = '';
  String _advice = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideoPlayer(); // F22: 영상 초기화
  }

  /// F22: veo3 영상 플레이어 초기화
  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.asset(_kCookieCrackVideoPath);
      await _videoController!.initialize();
      _useVideoAnimation = true;
      Logger.info('F22: Cookie crack video loaded successfully');
    } catch (e) {
      // 영상 파일이 없으면 기존 애니메이션 사용
      _useVideoAnimation = false;
      Logger.debug('F22: Video not available, using default animation');
    }
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
    _videoController?.dispose(); // F22: 영상 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
      appBar: _showPaper
          ? AppBar(
              backgroundColor: isDark
                  ? TossDesignSystem.backgroundDark
                  : TossDesignSystem.white,
              elevation: 0,
              automaticallyImplyLeading: false, // 백 버튼 제거
              title: Text(
                '포춘쿠키',
                style: TossDesignSystem.heading4.copyWith(
                  color: isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.gray900,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossDesignSystem.gray900,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
              ],
            )
          : const StandardFortuneAppBar(title: '포춘쿠키'),
      body: _showPaper ? _buildResultView() : _buildMainView(),
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
            child: Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Center(
                child: Text(
                  '탭하여 쿠키 깨뜨리기',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossDesignSystem.gray500,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .fadeIn(duration: 1.seconds)
                    .then(delay: 1.seconds)
                    .fadeOut(duration: 1.seconds),
              );
            }),
          ),
        ],
      );
    }
  }

  /// U11: 한국 전통 스타일 헤더 (한지/붓글씨)
  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 한지 배경색
    final hanjiColor = isDark
        ? const Color(0xFF2A2622) // 어두운 한지
        : const Color(0xFFF5F0E8); // 밝은 한지

    return Column(
      children: [
        // 전통 스타일 쿠키 아이콘 (금박 테두리)
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                hanjiColor,
                hanjiColor.withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFC9A962), // 금색 테두리
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC9A962).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/fortune_cards/fortune_cookie_fortune.png',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        )
            .animate()
            .scale(
                begin: const Offset(0.5, 0.5),
                duration: 600.ms,
                curve: Curves.elasticOut)
            .fadeIn(),
        const SizedBox(height: 28),
        // 붓글씨 스타일 제목 (GowunBatang)
        Text(
          '오늘의 운세를\n확인해보세요',
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: FontConfig.heading2,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF5F0E8) : const Color(0xFF2C2C2C),
            height: 1.4,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 14),
        // 부제목
        Text(
          '마음이 끌리는 쿠키를 선택하세요',
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: FontConfig.labelLarge,
            fontWeight: FontWeight.w400,
            color: isDark
                ? const Color(0xFFF5F0E8).withValues(alpha: 0.7)
                : const Color(0xFF5C5C5C),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 700.ms, delay: 300.ms),
      ],
    );
  }

  /// U11: 쿠키 터치 화면 헤더 (한국 전통 스타일)
  Widget _buildCookieHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          _isCracking ? '쿠키가 열리고 있어요!' : '쿠키를 탭해서 깨뜨리세요',
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: FontConfig.heading3,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF5F0E8) : const Color(0xFF2C2C2C),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          '특별한 메시지가 당신을 기다리고 있어요',
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: FontConfig.labelMedium,
            color: isDark
                ? const Color(0xFFF5F0E8).withValues(alpha: 0.7)
                : const Color(0xFF5C5C5C),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 700.ms, delay: 200.ms)
            .slideY(begin: -0.2, end: 0),
      ],
    );
  }

  /// U11: 한국 전통 스타일 쿠키 선택 그리드
  Widget _buildCookieSelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 오방색 안내 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2A2622).withValues(alpha: 0.5)
                : const Color(0xFFF5F0E8).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFC9A962).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '五方色',
                style: TextStyle(
                  fontFamily: FontConfig.primary,
                  fontSize: FontConfig.labelMedium,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC9A962),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '오방색으로 운세를 선택하세요',
                style: TextStyle(
                  fontFamily: FontConfig.primary,
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFFF5F0E8).withValues(alpha: 0.6)
                      : const Color(0xFF5C5C5C),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),

        // 2x3 그리드 레이아웃
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.05,
          ),
          itemCount: CookieType.values.length,
          itemBuilder: (context, index) {
            final cookie = CookieType.values[index];
            return _buildCookieTypeCard(cookie)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index))
                .scale(
                    begin: const Offset(0.92, 0.92),
                    delay: Duration(milliseconds: 100 * index));
          },
        ),
      ],
    );
  }

  /// U11: 한지 스타일 쿠키 타입 카드 (오방색 적용)
  Widget _buildCookieTypeCard(CookieType cookie) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 한지 배경색
    final hanjiColor =
        isDark ? const Color(0xFF2A2622) : const Color(0xFFF5F0E8);

    // 오행 라벨 매핑
    final elementLabel = switch (cookie) {
      CookieType.love => '火',
      CookieType.wealth => '土',
      CookieType.health => '木',
      CookieType.wisdom => '水',
      CookieType.luck => '金',
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCookie = cookie;
        });
        ref.read(fortuneHapticServiceProvider).selection();
      },
      child: Container(
        decoration: BoxDecoration(
          // 한지 텍스처 배경
          gradient: LinearGradient(
            colors: [
              hanjiColor,
              hanjiColor.withValues(alpha: 0.9),
              hanjiColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cookie.color.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cookie.color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 오행 한자 워터마크 (우측 상단)
            Positioned(
              top: 8,
              right: 10,
              child: Text(
                elementLabel,
                style: TextStyle(
                  fontFamily: FontConfig.primary,
                  fontSize: FontConfig.heading3,
                  fontWeight: FontWeight.w700,
                  color: cookie.color.withValues(alpha: 0.2),
                ),
              ),
            ),
            // 메인 콘텐츠
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이모지 아이콘 (한지 원형 배경)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: cookie.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cookie.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cookie.emoji,
                        style: const TextStyle(fontSize: FontConfig.heading1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 타이틀 (GowunBatang 폰트)
                  Text(
                    cookie.title,
                    style: TextStyle(
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.bodySmall,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFF5F0E8)
                          : const Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 설명
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      cookie.description,
                      style: TextStyle(
                        fontFamily: FontConfig.primary,
                        fontSize: FontConfig.captionLarge,
                        color: isDark
                            ? const Color(0xFFF5F0E8).withValues(alpha: 0.6)
                            : const Color(0xFF5C5C5C),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                              color:
                                  _selectedCookie!.color.withValues(alpha: 0.3),
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
                              // Minhwa Fortune Cookie Image
                              Image.asset(
                                'assets/images/fortune_cards/fortune_cookie_fortune.png',
                                width: 220,
                                height: 220,
                                fit: BoxFit.contain,
                              ),
                              // F22: Crack effect (영상 또는 기본 애니메이션)
                              if (_isCracking)
                                _useVideoAnimation && _videoController != null
                                    ? // veo3 영상 사용
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(80),
                                        child: SizedBox(
                                          width: 220,
                                          height: 160,
                                          child: VideoPlayer(_videoController!),
                                        ),
                                      )
                                    : // 기본 애니메이션
                                    Opacity(
                                        opacity: _crackAnimation.value
                                            .clamp(0.0, 1.0),
                                        child: Container(
                                          width: 220,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(80),
                                          ),
                                          child: CustomPaint(
                                            painter: ImprovedCrackPainter(
                                              progress: _crackAnimation.value,
                                            ),
                                          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.gray900,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFortuneCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _paperAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _paperAnimation.value,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minhwa Image Header
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/fortune_cards/fortune_cookie_fortune.png',
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        child: Text(
                          '${_selectedCookie!.title}의 메시지',
                          style: TossDesignSystem.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
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
                            Text(
                              '"',
                              style: DSTypography.displaySmall.copyWith(
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFFFFB74D),
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
                            Text(
                              '"',
                              style: DSTypography.displaySmall.copyWith(
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFFFFB74D),
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
                          color: isDark
                              ? TossDesignSystem.cardBackgroundDark
                              : TossDesignSystem.gray50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _chineseProverb,
                              style: TossDesignSystem.body1.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? TossDesignSystem.textPrimaryDark
                                    : TossDesignSystem.gray900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _chineseProverbMeaning,
                              style: TossDesignSystem.body2.copyWith(
                                color: isDark
                                    ? TossDesignSystem.textSecondaryDark
                                    : TossDesignSystem.gray600,
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
                            color: isDark
                                ? TossDesignSystem.borderDark
                                : TossDesignSystem.gray200,
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
                                color: TossDesignSystem.tossBlue
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
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
                                      color: isDark
                                          ? TossDesignSystem.textPrimaryDark
                                          : TossDesignSystem.gray700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _advice,
                                    style: TossDesignSystem.body2.copyWith(
                                      color: isDark
                                          ? TossDesignSystem.textPrimaryDark
                                          : TossDesignSystem.gray700,
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
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLuckyCard(
      String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
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
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossDesignSystem.gray600,
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
    return UnifiedButton(
      text: '운세 공유하기',
      onPressed: _shareFortune,
      style: UnifiedButtonStyle.secondary,
      icon: const Icon(Icons.share_outlined, size: 20),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Future<void> _onCookieTap() async {
    if (_isProcessing || _isShaking || _isCracking) return;

    final haptic = ref.read(fortuneHapticServiceProvider);

    setState(() {
      _isProcessing = true;
    });

    // 쿠키 탭 시작 - 카드 선택 햅틱
    haptic.cardSelect();

    setState(() {
      _isShaking = true;
    });

    // Shake animation with haptic feedback
    haptic.cookieShake(); // 흔들기 시작 시 연속 햅틱
    await _shakeController.forward();
    await _shakeController.reverse();
    await _shakeController.forward();
    await _shakeController.reverse();

    setState(() {
      _isShaking = false;
      _isCracking = true;
    });

    // F22: veo3 영상 재생 (있는 경우)
    if (_useVideoAnimation && _videoController != null) {
      _videoController!.play();
    }

    // Get fortune
    await _getFortune();

    // Crack animation with haptic at 50% point
    _crackController.addListener(_onCrackProgress);
    await _crackController.forward();
    _crackController.removeListener(_onCrackProgress);

    // Show paper with reveal haptic
    haptic.mysticalReveal();

    setState(() {
      _showPaper = true;
    });

    // Paper animation
    await _paperController.forward();

    // 결과 표시 완료
    haptic.loadingComplete();

    setState(() {
      _isProcessing = false;
    });
  }

  bool _crackHapticTriggered = false;

  void _onCrackProgress() {
    // 균열 애니메이션 50% 지점에서 햅틱
    if (!_crackHapticTriggered && _crackController.value >= 0.5) {
      _crackHapticTriggered = true;
      ref.read(fortuneHapticServiceProvider).cardSelect();
    }
  }

  Future<void> _getFortune() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // UnifiedFortuneService용 input_conditions 구성 (snake_case)
      final inputConditions = {
        'cookie_type': _selectedCookie?.name ?? 'luck',
      };

      await fortuneService.getFortune(
        fortuneType: 'fortune_cookie',
        dataSource: FortuneDataSource.local,
        inputConditions: inputConditions,
      );

      _generateMockFortune();
    } catch (e) {
      Logger.error('Failed to get fortune', e);
      _generateMockFortune();
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
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
      TossDesignSystem.errorRed,
      TossDesignSystem.tossBlue,
      TossDesignSystem.successGreen,
      TossDesignSystem.warningYellow,
      TossDesignSystem.purple,
      TossDesignSystem.orange,
      TossDesignSystem.pink,
      TossDesignSystem.teal,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  String _getLuckyColorName(Color color) {
    if (color == TossDesignSystem.errorRed) return '빨강';
    if (color == TossDesignSystem.tossBlue) return '파랑';
    if (color == TossDesignSystem.successGreen) return '초록';
    if (color == TossDesignSystem.warningYellow) return '노랑';
    if (color == TossDesignSystem.purple) return '보라';
    if (color == TossDesignSystem.orange) return '주황';
    if (color == TossDesignSystem.pink) return '분홍';
    if (color == TossDesignSystem.teal) return '청록';
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
      ..color = TossDesignSystem.black.withValues(alpha: 0.3 * progress)
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
    path.quadraticBezierTo(centerX - 10 * progress, centerY - 20 * progress,
        centerX - 30 * progress, centerY - 40 * progress);

    path.moveTo(centerX + 20, centerY);
    path.quadraticBezierTo(centerX + 10 * progress, centerY + 20 * progress,
        centerX + 30 * progress, centerY + 40 * progress);

    // 서브 균열
    if (progress > 0.5) {
      path.moveTo(centerX, centerY - 10);
      path.quadraticBezierTo(centerX + 15 * (progress - 0.5), centerY - 5,
          centerX + 25 * (progress - 0.5), centerY - 25 * (progress - 0.5));

      path.moveTo(centerX, centerY + 10);
      path.quadraticBezierTo(centerX - 15 * (progress - 0.5), centerY + 5,
          centerX - 25 * (progress - 0.5), centerY + 25 * (progress - 0.5));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ImprovedCrackPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
