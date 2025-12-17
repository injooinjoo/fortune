import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../../../services/storage_service.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/biorhythm_fortune_conditions.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/toast.dart';
import 'biorhythm_result_page.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/biorhythm/components/biorhythm_hanji_card.dart';
import '../widgets/biorhythm/components/rhythm_traditional_icon.dart';
import '../widgets/biorhythm/components/biorhythm_score_badge.dart';

class BiorhythmInputPage extends ConsumerStatefulWidget {
  const BiorhythmInputPage({super.key});

  @override
  ConsumerState<BiorhythmInputPage> createState() => _BiorhythmInputPageState();
}

class _BiorhythmInputPageState extends ConsumerState<BiorhythmInputPage>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  DateTime? _selectedDate;
  bool _isLoading = false; // ✅ 로딩 상태 추가

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();

    // 사용자 프로필에서 생년월일 가져오기
    _loadUserBirthDate();
  }

  Future<void> _loadUserBirthDate() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Supabase에서 사용자 프로필 가져오기
        final response = await supabase
            .from('user_profiles')
            .select('birth_date')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null && response['birth_date'] != null) {
          // birth_date 형식: YYYY-MM-DD
          final birthDateString = response['birth_date'] as String;
          final birthDate = DateTime.parse(birthDateString);

          setState(() {
            _selectedDate = birthDate;
          });
        }
      } else {
        // 로그인하지 않은 경우 로컬 스토리지에서 확인
        final storageService = StorageService();
        final profile = await storageService.getUserProfile();

        if (profile != null && profile['birth_date'] != null) {
          final birthDateString = profile['birth_date'] as String;
          final birthDate = DateTime.parse(birthDateString);

          setState(() {
            _selectedDate = birthDate;
          });
        }
      }
    } catch (e) {
      // 에러가 발생해도 앱이 계속 작동하도록 함
      debugPrint('생년월일 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _analyzeBiorhythm() async {
    if (_selectedDate == null) return;

    ref.read(fortuneHapticServiceProvider).sectionComplete();

    // 로딩 시작
    setState(() {
      _isLoading = true;
    });

    try {
      // 사용자 프로필 가져오기
      final userProfile = ref.read(userProfileProvider).value;
      final userName = userProfile?.name ?? 'Unknown';

      // Premium 상태 확인
      final tokenState = ref.read(tokenProvider);
      final isPremium = tokenState.hasUnlimitedAccess;

      Logger.info('[BiorhythmInputPage] Premium 상태: $isPremium');

      // FortuneConditions 생성
      final conditions = BiorhythmFortuneConditions(
        birthDate: _selectedDate!.toIso8601String().split('T')[0],
        name: userName,
      );

      // UnifiedFortuneService 호출
      final fortuneService = UnifiedFortuneService(
        Supabase.instance.client,
        enableOptimization: true,
      );

      final result = await fortuneService.getFortune(
        fortuneType: 'biorhythm',
        dataSource: FortuneDataSource.api,
        inputConditions: conditions.toJson(),
        conditions: conditions,
        isPremium: isPremium,
      );

      Logger.info('[BiorhythmInputPage] 바이오리듬 생성 완료: ${result.id}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // 결과 페이지로 이동
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BiorhythmResultPage(
                  birthDate: _selectedDate!,
                  fortuneResult: result,
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (error, stackTrace) {
      Logger.error('[BiorhythmInputPage] 바이오리듬 생성 실패', error, stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Toast.show(
          context,
          message: '바이오리듬 분석 중 오류가 발생했습니다',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hanjiBackground = DSBiorhythmColors.getHanjiBackground(isDark);
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return Scaffold(
      backgroundColor: hanjiBackground,
      appBar: const StandardFortuneAppBar(
        title: '바이오리듬',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Hanji texture background
              Positioned.fill(
                child: CustomPaint(
                  painter: _HanjiTexturePainter(isDark: isDark),
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // 메인 설명 카드 - 한지 스타일
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: BiorhythmHanjiCard(
                              style: HanjiCardStyle.scroll,
                              showCornerDecorations: true,
                              showSealStamp: true,
                              sealText: '運',
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // 전통 리듬 아이콘 3개
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) => Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: const RhythmTraditionalIconRow(
                                        iconSize: 56,
                                        showBackground: true,
                                        showLabels: false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // 타이틀 - 붓글씨 스타일
                                  Text(
                                    '생체 리듬의 흐름을\n읽어드립니다',
                                    style: TextStyle(
                                      fontFamily: 'GowunBatang',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),

                                  // 설명 - 전통 스타일
                                  Text(
                                    '신체(火) · 감정(木) · 지적(水)\n세 가지 기운의 주기를 분석하여\n오늘의 운세를 알려드립니다',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      color: textColor.withValues(alpha: 0.7),
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 16),

                                  // 오행 배지 행
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElementBadge(type: BiorhythmType.physical, size: 28),
                                      SizedBox(width: 12),
                                      ElementBadge(type: BiorhythmType.emotional, size: 28),
                                      SizedBox(width: 12),
                                      ElementBadge(type: BiorhythmType.intellectual, size: 28),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 생년월일 입력 카드 - 한지 스타일
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: BiorhythmHanjiCard(
                              style: HanjiCardStyle.standard,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: DSBiorhythmColors.getPhysical(isDark),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '생년월일',
                                        style: TextStyle(
                                          fontFamily: 'GowunBatang',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  NumericDateInput(
                                    selectedDate: _selectedDate,
                                    onDateChanged: (date) => setState(() => _selectedDate = date),
                                    minDate: DateTime(1900),
                                    maxDate: DateTime.now(),
                                    showAge: true,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // 안내 문구 - 전통 스타일
                          Text(
                            '※ 분석 결과는 참고용으로만 활용해 주세요',
                            style: TextStyle(
                              fontFamily: 'GowunBatang',
                              fontSize: 12,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              UnifiedButton.floating(
                text: '운세 분석하기',
                onPressed: _selectedDate != null && !_isLoading ? _analyzeBiorhythm : null,
                isEnabled: _selectedDate != null && !_isLoading,
                isLoading: _isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Hanji paper texture background painter
class _HanjiTexturePainter extends CustomPainter {
  final bool isDark;

  _HanjiTexturePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final textureColor = isDark
        ? Colors.white.withValues(alpha: 0.015)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.02);

    // Draw subtle fiber texture
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 5 + random.nextDouble() * 15;
      final angle = random.nextDouble() * math.pi;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + length * math.cos(angle), y + length * math.sin(angle)),
        Paint()
          ..color = textureColor
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HanjiTexturePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}