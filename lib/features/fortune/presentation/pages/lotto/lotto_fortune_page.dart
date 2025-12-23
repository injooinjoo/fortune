import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/font_config.dart';
import '../../../../../core/theme/obangseok_colors.dart';
import '../../../../../core/theme/typography_unified.dart';
import '../../../../../core/design_system/components/traditional/hanji_card.dart';
import '../../../../../core/widgets/accordion_input_section.dart';
import '../../../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../core/services/location_manager.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/utils/fortune_completion_helper.dart';
import '../../../../../core/utils/subscription_snackbar.dart';
import '../../../../../presentation/providers/auth_provider.dart';
import '../../../../../presentation/providers/ad_provider.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../presentation/providers/subscription_provider.dart';
import '../../../domain/services/lotto_number_generator.dart';
import 'widgets/widgets.dart';

/// 로또 운세 페이지
///
/// 사주 정보를 기반으로 6개의 로또 번호를 생성합니다.
/// - 5개: 바로 공개
/// - 1개: 광고 시청 후 공개 (프리미엄 사용자는 바로 공개)
/// 추가로 행운의 구매 장소, 최적 구매 타이밍, 사주 기반 조언을 제공합니다.
class LottoFortunePage extends ConsumerStatefulWidget {
  const LottoFortunePage({super.key});

  @override
  ConsumerState<LottoFortunePage> createState() => _LottoFortunePageState();
}

class _LottoFortunePageState extends ConsumerState<LottoFortunePage> {
  // 입력 상태
  DateTime? _selectedBirthDate;
  String? _selectedBirthTime;
  String? _selectedGender;
  List<AccordionInputSection> _sections = [];

  // 결과 상태
  bool _showResult = false;
  LottoFortuneResult? _result;
  bool _isPremiumUnlocked = false;
  bool _isGenerating = false;

  // 위치 상태
  String? _currentLocationName;

  @override
  void initState() {
    super.initState();
    _initializeSections();
    _loadUserProfile();
  }

  void _initializeSections() {
    _sections = [
      AccordionInputSection(
        id: 'birthDate',
        title: '생년월일',
        icon: Icons.cake_outlined,
        inputWidgetBuilder: (context, onValueChanged) =>
            _buildDatePicker(onValueChanged),
      ),
      AccordionInputSection(
        id: 'birthTime',
        title: '태어난 시간',
        icon: Icons.access_time_outlined,
        inputWidgetBuilder: (context, onValueChanged) =>
            _buildTimePicker(onValueChanged),
      ),
      AccordionInputSection(
        id: 'gender',
        title: '성별',
        icon: Icons.person_outline,
        inputWidgetBuilder: (context, onValueChanged) =>
            _buildGenderSelect(onValueChanged),
      ),
    ];
  }

  void _loadUserProfile() {
    final profile = ref.read(userProfileProvider).value;
    if (profile != null) {
      setState(() {
        if (profile.birthDate != null) {
          _selectedBirthDate = profile.birthDate;
          final index = _sections.indexWhere((s) => s.id == 'birthDate');
          if (index != -1) {
            _sections[index].isCompleted = true;
            _sections[index].value = profile.birthDate;
            _sections[index].displayValue =
                '생년월일: ${profile.birthDate!.year}.${profile.birthDate!.month}.${profile.birthDate!.day}';
          }
        }

        if (profile.birthTime != null) {
          _selectedBirthTime = profile.birthTime;
          final index = _sections.indexWhere((s) => s.id == 'birthTime');
          if (index != -1) {
            _sections[index].isCompleted = true;
            _sections[index].value = profile.birthTime;
            _sections[index].displayValue = '태어난 시간: ${profile.birthTime}';
          }
        }

        if (profile.gender != null) {
          _selectedGender = profile.gender;
          final index = _sections.indexWhere((s) => s.id == 'gender');
          if (index != -1) {
            _sections[index].isCompleted = true;
            _sections[index].value = profile.gender;
            _sections[index].displayValue =
                '성별: ${profile.gender == "male" ? "남성" : "여성"}';
          }
        }
      });
    }
  }

  bool _canGenerate() {
    return _selectedBirthDate != null && _selectedGender != null;
  }

  Future<void> _generateNumbers() async {
    if (!_canGenerate()) return;

    setState(() {
      _isGenerating = true;
    });

    // 햅틱 피드백
    ref.read(fortuneHapticServiceProvider).mysticalReveal();

    // 현재 위치 가져오기
    String? locationName;
    try {
      final locationInfo = await LocationManager.instance.getCurrentLocation();
      locationName = locationInfo.cityName;
    } catch (e) {
      Logger.debug('[Lotto] 위치 정보 가져오기 실패: $e');
    }

    // 번호 생성
    final result = LottoNumberGenerator.generate(
      birthDate: _selectedBirthDate!,
      birthTime: _selectedBirthTime,
      gender: _selectedGender,
      currentLocation: locationName,
    );

    // 프리미엄 사용자 체크
    final isPremium = ref.read(isPremiumProvider);

    if (mounted) {
      setState(() {
        _result = result;
        _currentLocationName = locationName;
        _isPremiumUnlocked = isPremium;
        _showResult = true;
        _isGenerating = false;
      });

      // 게이지 증가
      FortuneCompletionHelper.onFortuneViewed(context, ref, 'lotto');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? ObangseokColors.hanjiBackgroundDark
          : ObangseokColors.hanjiBackground,
      appBar: _buildAppBar(context, isDark),
      body: _showResult ? _buildResultView(isDark) : _buildInputView(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark
          ? ObangseokColors.hanjiBackgroundDark
          : ObangseokColors.hanjiBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: _showResult
          ? null // 결과 화면에서는 왼쪽 버튼 없음
          : IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: ObangseokColors.getMeok(context),
              ),
              onPressed: () => context.pop(),
            ),
      automaticallyImplyLeading: false,
      title: Text(
        '로또 운세',
        style: TextStyle(
          fontFamily: FontConfig.primary,
          color: ObangseokColors.getMeok(context),
          fontSize: FontConfig.buttonMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: _showResult
          ? [
              // 결과 화면에서는 오른쪽에 X 버튼
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: ObangseokColors.getMeok(context),
                ),
                onPressed: () {
                  setState(() {
                    _showResult = false;
                  });
                },
              ),
            ]
          : null,
    );
  }

  Widget _buildInputView(bool isDark) {
    return Stack(
      children: [
        // AccordionInputForm은 내부적으로 CustomScrollView를 사용하므로
        // SingleChildScrollView로 감싸면 안 됨 (unbounded height 에러)
        AccordionInputForm(
          sections: _sections,
          header: _buildHeaderCard(isDark),
        ),
        // 확인 버튼
        if (_canGenerate())
          UnifiedButton.floating(
            text: '🎰 행운 번호 확인하기',
            onPressed:
                _canGenerate() && !_isGenerating ? _generateNumbers : null,
            isEnabled: _canGenerate() && !_isGenerating,
            showProgress: _isGenerating,
            isLoading: _isGenerating,
          ),
      ],
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return HanjiCard(
      colorScheme: HanjiColorScheme.luck,
      style: HanjiCardStyle.elevated,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 배경 용 민화 이미지 (우하단)
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: isDark ? 0.06 : 0.10,
                child: Image.asset(
                  'assets/images/minhwa/minhwa_overall_dragon.webp',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // 메인 콘텐츠
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ObangseokColors.hwang,
                          ObangseokColors.hwangLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ObangseokColors.hwang.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/fortune/categories/lotto_main.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.casino_rounded,
                          size: 48,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '로또 운세',
                    style: TypographyUnified.heading2.copyWith(
                      fontFamily: FontConfig.primary,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? ObangseokColors.baekDark
                          : ObangseokColors.meok,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '사주를 기반으로 오늘의 행운 번호와\n구매 장소, 최적 타이밍을 추천해드립니다',
                    style: TypographyUnified.bodyMedium.copyWith(
                      color: isDark
                          ? ObangseokColors.baekDark.withValues(alpha: 0.7)
                          : ObangseokColors.meok.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(bool isDark) {
    if (_result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isPremium = ref.watch(isPremiumProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: LottoResultContainer(
            result: _result!,
            isPremiumUnlocked: _isPremiumUnlocked || isPremium,
            onUnlockPressed:
                (!_isPremiumUnlocked && !isPremium) ? _showAdAndUnlock : null,
            currentLocationName: _currentLocationName,
          ),
        ),
        // 광고 보고 잠금 해제 버튼 (프리미엄이 아니고 아직 해제 안 했을 때)
        if (!_isPremiumUnlocked && !isPremium)
          UnifiedButton.floatingDanger(
            text: '🔓 광고 보고 전체 번호 확인',
            onPressed: _showAdAndUnlock,
            isEnabled: true,
          ),
      ],
    );
  }

  Future<void> _showAdAndUnlock() async {
    Logger.debug('[Lotto] 광고 시청 후 프리미엄 번호 해제 시작');

    try {
      final adService = ref.read(adServiceProvider);

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중입니다...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고 로드에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, rewardItem) async {
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          if (mounted) {
            setState(() {
              _isPremiumUnlocked = true;
            });

            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e) {
      Logger.debug('[Lotto] 광고 표시 실패: $e');

      // 실패해도 해제
      if (mounted) {
        setState(() {
          _isPremiumUnlocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 로드에 실패했지만 번호를 보여드립니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildDatePicker(Function(dynamic) onValueChanged) {
    return NumericDateInput(
      label: '생년월일',
      selectedDate: _selectedBirthDate,
      onDateChanged: (date) {
        setState(() {
          _selectedBirthDate = date;
          final index = _sections.indexWhere((s) => s.id == 'birthDate');
          if (index != -1) {
            _sections[index] = _sections[index].copyWith(
              isCompleted: true,
              value: date,
              displayValue: '생년월일: ${date.year}.${date.month}.${date.day}',
            );
          }
        });
        onValueChanged(date);
      },
      minDate: DateTime(1900),
      maxDate: DateTime.now(),
      showAge: true,
    );
  }

  Widget _buildTimePicker(Function(dynamic) onValueChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final times = [
      '자시 (23:00-01:00)',
      '축시 (01:00-03:00)',
      '인시 (03:00-05:00)',
      '묘시 (05:00-07:00)',
      '진시 (07:00-09:00)',
      '사시 (09:00-11:00)',
      '오시 (11:00-13:00)',
      '미시 (13:00-15:00)',
      '신시 (15:00-17:00)',
      '유시 (17:00-19:00)',
      '술시 (19:00-21:00)',
      '해시 (21:00-23:00)'
    ];

    return Column(
      children: times.map((time) {
        return RadioListTile<String>(
          title: Text(
            time,
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
            ),
          ),
          value: time,
          groupValue: _selectedBirthTime,
          activeColor: ObangseokColors.hwang,
          onChanged: (value) {
            setState(() {
              _selectedBirthTime = value;
              final index = _sections.indexWhere((s) => s.id == 'birthTime');
              if (index != -1) {
                _sections[index] = _sections[index].copyWith(
                  isCompleted: true,
                  value: value,
                  displayValue: '태어난 시간: $value',
                );
              }
            });
            onValueChanged(value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildGenderSelect(Function(dynamic) onValueChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        RadioListTile<String>(
          title: Text(
            '남성',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
            ),
          ),
          value: 'male',
          groupValue: _selectedGender,
          activeColor: ObangseokColors.hwang,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
              final index = _sections.indexWhere((s) => s.id == 'gender');
              if (index != -1) {
                _sections[index] = _sections[index].copyWith(
                  isCompleted: true,
                  value: value,
                  displayValue: '성별: 남성',
                );
              }
            });
            onValueChanged(value);
          },
        ),
        RadioListTile<String>(
          title: Text(
            '여성',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? ObangseokColors.baekDark : ObangseokColors.meok,
            ),
          ),
          value: 'female',
          groupValue: _selectedGender,
          activeColor: ObangseokColors.hwang,
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
              final index = _sections.indexWhere((s) => s.id == 'gender');
              if (index != -1) {
                _sections[index] = _sections[index].copyWith(
                  isCompleted: true,
                  value: value,
                  displayValue: '성별: 여성',
                );
              }
            });
            onValueChanged(value);
          },
        ),
      ],
    );
  }
}
