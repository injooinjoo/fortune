import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../services/ad_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/biorhythm_fortune_conditions.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/components/toast.dart';
import 'biorhythm_result_page.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/theme/typography_unified.dart';

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
  final TextEditingController _dateController = TextEditingController();
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
            _dateController.text =
                '${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}';
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
            _dateController.text =
                '${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}';
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
    _dateController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TossDesignSystem.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDatePickerModal(),
    );
  }

  Widget _buildDatePickerModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime tempDate = _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TossButton(
                  text: '취소',
                  onPressed: () => Navigator.of(context).pop(),
                  style: TossButtonStyle.secondary,
                  size: TossButtonSize.small,
                ),
                Text(
                  '생년월일 선택',
                  style: TypographyUnified.heading4.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                  ),
                ),
                TossButton(
                  text: '확인',
                  onPressed: () {
                    setState(() {
                      _selectedDate = tempDate;
                      _dateController.text = 
                          '${tempDate.year}.${tempDate.month.toString().padLeft(2, '0')}.${tempDate.day.toString().padLeft(2, '0')}';
                    });
                    Navigator.of(context).pop();
                    HapticFeedback.mediumImpact();
                  },
                  style: TossButtonStyle.primary,
                  size: TossButtonSize.small,
                ),
              ],
            ),
          ),
          
          // 날짜 선택기
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: tempDate,
              minimumDate: DateTime(1900),
              maximumDate: DateTime.now(),
              onDateTimeChanged: (date) {
                tempDate = date;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeBiorhythm() async {
    if (_selectedDate == null) return;

    HapticFeedback.mediumImpact();

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
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundPrimary,
      appBar: const StandardFortuneAppBar(
        title: '바이오리듬 분석',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
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

                          // 메인 설명 카드
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: TossCard(
                              style: TossCardStyle.elevated,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // 바이오리듬 아이콘
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) => Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              TossTheme.primaryBlue,
                                              const Color(0xFF00C896),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: TossTheme.primaryBlue.withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.timeline_rounded,
                                          color: TossDesignSystem.white,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  Text(
                                    '당신의 생체 리듬을 분석하고\n최적의 타이밍을 찾아드릴게요',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),

                                  Text(
                                    '신체·감정·지적 리듬의 3가지 주기를 분석해\n오늘의 컨디션과 앞으로의 흐름을 알려드려요',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: TossTheme.textGray600,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 생년월일 입력 카드
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: TossCard(
                              style: TossCardStyle.outlined,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '생년월일',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  GestureDetector(
                                    onTap: _showDatePicker,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDark ? TossDesignSystem.grayDark700 : TossTheme.backgroundSecondary,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _selectedDate != null
                                              ? TossTheme.primaryBlue
                                              : (isDark ? TossDesignSystem.grayDark400 : TossTheme.borderGray300),
                                          width: _selectedDate != null ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedDate != null
                                                ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                                                : '생년월일을 선택해주세요',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: _selectedDate != null
                                                  ? (isDark ? TossDesignSystem.white : TossTheme.textBlack)
                                                  : (isDark ? TossDesignSystem.grayDark100 : TossTheme.textGray600),
                                              fontWeight: _selectedDate != null
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            color: _selectedDate != null
                                                ? TossTheme.primaryBlue
                                                : (isDark ? TossDesignSystem.grayDark100 : TossTheme.textGray600),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // 안내 문구
                          Text(
                            '분석 결과는 참고용으로만 활용해 주세요',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? TossDesignSystem.grayDark100 : TossTheme.textGray600,
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
              TossFloatingProgressButtonPositioned(
                text: '바이오리듬 분석하기',
                onPressed: _selectedDate != null && !_isLoading ? _analyzeBiorhythm : null,
                isEnabled: _selectedDate != null && !_isLoading,
                isVisible: true,
                showProgress: false,
                isLoading: _isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}