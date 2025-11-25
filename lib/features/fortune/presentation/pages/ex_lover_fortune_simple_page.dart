import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/ex_lover_simple_model.dart';
import '../../domain/models/conditions/ex_lover_fortune_conditions.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/ad_service.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';

import '../../../../core/widgets/unified_button.dart';
class ExLoverFortuneSimplePage extends ConsumerStatefulWidget {
  const ExLoverFortuneSimplePage({super.key});

  @override
  ConsumerState<ExLoverFortuneSimplePage> createState() => _ExLoverFortuneSimplePageState();
}

class _ExLoverFortuneSimplePageState extends ConsumerState<ExLoverFortuneSimplePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false; // ✅ 로딩 상태 추가

  // Step 1: 핵심 질문
  String? _timeSinceBreakup;
  String? _currentEmotion;
  String? _mainCuriosity;

  // Step 2: 선택 정보
  DateTime? _exBirthDate;
  String? _breakupReason;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_canProceedStep1()) {
        // 버튼이 비활성화되어 있으므로 메시지 표시
        if (_timeSinceBreakup == null) {
          _showMessage('이별한 시기를 선택해주세요');
        } else if (_currentEmotion == null) {
          _showMessage('현재 감정을 선택해주세요');
        } else if (_mainCuriosity == null) {
          _showMessage('가장 궁금한 것을 선택해주세요');
        }
        return;
      }
      setState(() {
        _currentStep = 1;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1) {
      _analyzeAndShowResult();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedStep1() {
    return _timeSinceBreakup != null &&
           _currentEmotion != null &&
           _mainCuriosity != null;
  }

  bool _canProceedStep2() {
    // Step 2는 선택사항이므로 항상 true 반환
    return true;
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: TossDesignSystem.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  Future<void> _analyzeAndShowResult() async {
    // ✅ 1단계: 로딩 시작
    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ 2단계: Premium 확인
      final tokenState = ref.read(tokenProvider);
      final isPremium = tokenState.hasUnlimitedAccess;

      Logger.info('[ExLoverFortune] Premium 상태: $isPremium');

      // ✅ 3단계: FortuneConditions 생성
      final conditions = ExLoverFortuneConditions(
        timeSinceBreakup: _timeSinceBreakup!,
        currentEmotion: _currentEmotion!,
        mainCuriosity: _mainCuriosity!,
        exBirthDate: _exBirthDate,
        breakupReason: _breakupReason,
      );

      // ✅ 4단계: UnifiedFortuneService 호출
      final fortuneService = UnifiedFortuneService(
        Supabase.instance.client,
        enableOptimization: true,
      );

      final result = await fortuneService.getFortune(
        fortuneType: 'ex_lover',
        dataSource: FortuneDataSource.api,
        inputConditions: conditions.toJson(),
        conditions: conditions,
        isPremium: isPremium, // ✅ Premium 상태 전달
      );

      Logger.info('[ExLoverFortune] 운세 생성 완료: ${result.id}');

      // ✅ 5단계: 로딩 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // ✅ 6단계: 광고 표시 (InterstitialAd)
      await AdService.instance.showInterstitialAdWithCallback(
        onAdCompleted: () async {
          // 결과 페이지로 이동
          if (mounted) {
            context.push(
              '/ex-lover-emotional-result',
              extra: result, // ✅ FortuneResult 전달
            );
          }
        },
        onAdFailed: () async {
          // 광고 실패해도 결과 페이지로 이동
          if (mounted) {
            context.push(
              '/ex-lover-emotional-result',
              extra: result, // ✅ FortuneResult 전달
            );
          }
        },
      );
    } catch (error, stackTrace) {
      Logger.error('[ExLoverFortune] 운세 생성 실패', error, stackTrace);

      // 로딩 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('운세 생성 중 오류가 발생했습니다'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      appBar: StandardFortuneAppBar(
        title: '헤어진 애인',
        onBackPressed: () {
          if (_currentStep > 0) {
            _previousStep();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: Stack(
        children: [
          // Page Content (프로그레스 인디케이터 제거)
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(isDark),
              _buildStep2(isDark),
            ],
          ),

          // Floating Progress Button
          _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    final canProceed = _currentStep == 0 ? _canProceedStep1() : _canProceedStep2();

    return UnifiedButton.floating(
      text: _currentStep == 0 ? '다음' : '마음 분석하기',
      onPressed: (_isLoading || !canProceed) ? null : _nextStep,
      isLoading: _isLoading, // ✅ 로딩 상태 전달
      isEnabled: canProceed && !_isLoading,
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 위로 메시지
          TossCard(
            style: TossCardStyle.elevated,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.purple.withValues(alpha: 0.8),
                        const Color(0xFFEC4899).withValues(alpha: 0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '힘드셨죠?',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '천천히 답해주세요. 당신의 마음을 읽어드릴게요.',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          
          SizedBox(height: 32),
          
          // 1. 이별 시기
          Text(
            '이별한 지 얼마나 되었나요?',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTimeChip('1개월 미만', 'recent', isDark),
              _buildTimeChip('1-3개월', 'short', isDark),
              _buildTimeChip('3-6개월', 'medium', isDark),
              _buildTimeChip('6개월-1년', 'long', isDark),
              _buildTimeChip('1년 이상', 'verylong', isDark),
            ],
          ),
          
          SizedBox(height: 32),
          
          // 2. 현재 감정
          Text(
            '지금 나의 마음은?',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ...emotionCards.map((card) => _buildEmotionCard(card, isDark)),
          
          SizedBox(height: 32),
          
          // 3. 가장 궁금한 것
          Text(
            '가장 궁금한 것을 하나만 선택해주세요',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ...curiosityCards.map((card) => _buildCuriosityCard(card, isDark)),

          // Floating 버튼 공간 확보
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TossCard(
            style: TossCardStyle.elevated,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.tossBlue.withValues(alpha: 0.8),
                        TossDesignSystem.purple.withValues(alpha: 0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '더 정확한 분석을 원하시나요?',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '선택사항이에요. 건너뛰어도 괜찮아요.',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32),
          
          // 상대방 생년월일
          NumericDateInput(
            label: '상대방 생년월일 (선택)',
            selectedDate: _exBirthDate,
            onDateChanged: (date) => setState(() => _exBirthDate = date),
            minDate: DateTime(1950),
            maxDate: DateTime.now(),
            showAge: true,
          ),
          
          SizedBox(height: 32),
          
          // 이별 이유
          Text(
            '이별 이유 (선택)',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildReasonChip('가치관 차이', 'differentValues', isDark),
              _buildReasonChip('시기가 맞지 않음', 'timing', isDark),
              _buildReasonChip('소통 부족', 'communication', isDark),
              _buildReasonChip('신뢰 문제', 'trust', isDark),
              _buildReasonChip('기타', 'other', isDark),
            ],
          ),

          // Floating 버튼 공간 확보
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, String value, bool isDark) {
    final isSelected = _timeSinceBreakup == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _timeSinceBreakup = value;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.purple.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.purple
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TossDesignSystem.body2.copyWith(
            color: isSelected
                ? TossDesignSystem.purple
                : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionCard(EmotionCard card, bool isDark) {
    final isSelected = _currentEmotion == card.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(16),
        onTap: () {
          setState(() {
            _currentEmotion = card.id;
          });
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Color(card.gradientColors[0])
                  : TossDesignSystem.white.withValues(alpha: 0.0),
              width: 2,
            ),
            gradient: isSelected
                ? LinearGradient(
                    colors: card.gradientColors.map((c) => Color(c).withValues(alpha: 0.1)).toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Row(
            children: [
              Text(
                card.emoji,
                style: TypographyUnified.numberLarge,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: TossDesignSystem.body1.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      card.description,
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: card.id,
                groupValue: _currentEmotion,
                onChanged: (value) {
                  setState(() {
                    _currentEmotion = value;
                  });
                },
                activeColor: Color(card.gradientColors[0]),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * emotionCards.indexOf(card)))
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildCuriosityCard(CuriosityCard card, bool isDark) {
    final isSelected = _mainCuriosity == card.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TossCard(
        style: TossCardStyle.filled,
        padding: const EdgeInsets.all(16),
        onTap: () {
          setState(() {
            _mainCuriosity = card.id;
          });
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? TossDesignSystem.purple
                  : TossDesignSystem.white.withValues(alpha: 0.0),
              width: 2,
            ),
            color: isSelected
                ? TossDesignSystem.purple.withValues(alpha: 0.05)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.purple.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    card.icon,
                    style: TypographyUnified.displaySmall,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: TossDesignSystem.body1.copyWith(
                        color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      card.description,
                      style: TossDesignSystem.caption.copyWith(
                        color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: card.id,
                groupValue: _mainCuriosity,
                onChanged: (value) {
                  setState(() {
                    _mainCuriosity = value;
                  });
                },
                activeColor: TossDesignSystem.purple,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * curiosityCards.indexOf(card)))
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildReasonChip(String label, String value, bool isDark) {
    final isSelected = _breakupReason == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _breakupReason = value;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.purple.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.purple
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TossDesignSystem.body2.copyWith(
            color: isSelected
                ? TossDesignSystem.purple
                : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}