import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/ex_lover_simple_model.dart';
import '../../../../services/ad_service.dart';
import '../widgets/standard_fortune_app_bar.dart';

class ExLoverFortuneSimplePage extends ConsumerStatefulWidget {
  const ExLoverFortuneSimplePage({super.key});

  @override
  ConsumerState<ExLoverFortuneSimplePage> createState() => _ExLoverFortuneSimplePageState();
}

class _ExLoverFortuneSimplePageState extends ConsumerState<ExLoverFortuneSimplePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
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
    if (_currentStep == 0 && _validateStep1()) {
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

  bool _validateStep1() {
    if (_timeSinceBreakup == null) {
      _showMessage('이별한 시기를 선택해주세요');
      return false;
    }
    if (_currentEmotion == null) {
      _showMessage('현재 감정을 선택해주세요');
      return false;
    }
    if (_mainCuriosity == null) {
      _showMessage('가장 궁금한 것을 선택해주세요');
      return false;
    }
    return true;
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

  void _analyzeAndShowResult() async {
    final input = ExLoverSimpleInput(
      timeSinceBreakup: _timeSinceBreakup!,
      currentEmotion: _currentEmotion!,
      mainCuriosity: _mainCuriosity!,
      exBirthDate: _exBirthDate,
      breakupReason: _breakupReason,
    );
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: TossDesignSystem.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: TossDesignSystem.purple,
              ),
              const SizedBox(height: 16),
              Text(
                '분석 중...',
                style: TossDesignSystem.body2,
              ),
            ],
          ),
        ),
      ),
    );
    
    // Show AdMob interstitial ad
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        // Close loading dialog
        Navigator.pop(context);
        
        // Navigate to result page
        context.push(
          '/ex-lover-emotional-result',
          extra: input,
        );
      },
      onAdFailed: () async {
        // Close loading dialog even if ad fails
        Navigator.pop(context);
        
        // Navigate to result page anyway
        context.push(
          '/ex-lover-emotional-result',
          extra: input,
        );
      },
    );
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
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(isDark),
          
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(isDark),
                _buildStep2(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: List.generate(2, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? TossDesignSystem.purple
                        : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray200),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).animate(target: index <= _currentStep ? 1 : 0)
                  .scaleX(begin: 0, end: 1, duration: 300.ms),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _currentStep == 0 ? '마음 들여다보기' : '추가 정보 (선택)',
            style: TossDesignSystem.caption.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
            ),
          ),
        ],
      ),
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
                const SizedBox(height: 16),
                Text(
                  '힘드셨죠?',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
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
          
          const SizedBox(height: 32),
          
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
          
          const SizedBox(height: 32),
          
          // 2. 현재 감정
          Text(
            '지금 나의 마음은?',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ...emotionCards.map((card) => _buildEmotionCard(card, isDark)).toList(),
          
          const SizedBox(height: 32),
          
          // 3. 가장 궁금한 것
          Text(
            '가장 궁금한 것을 하나만 선택해주세요',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ...curiosityCards.map((card) => _buildCuriosityCard(card, isDark)).toList(),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '다음',
              onPressed: _nextStep,
              style: TossButtonStyle.primary,
              isEnabled: _validateStep1(),
            ),
          ),
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
                const SizedBox(height: 16),
                Text(
                  '더 정확한 분석을 원하시나요?',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
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
          
          const SizedBox(height: 32),
          
          // 상대방 생년월일
          Text(
            '상대방 생년월일 (선택)',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _exBirthDate ?? DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: TossDesignSystem.purple,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  _exBirthDate = date;
                });
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: TossDesignSystem.purple,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _exBirthDate != null
                        ? '${_exBirthDate!.year}년 ${_exBirthDate!.month}월 ${_exBirthDate!.day}일'
                        : '생년월일 선택',
                    style: TossDesignSystem.body2.copyWith(
                      color: _exBirthDate != null
                          ? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900)
                          : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                  size: 20,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
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
          
          const SizedBox(height: 40),
          
          // 버튼
          Row(
            children: [
              Expanded(
                child: TossButton(
                  text: '건너뛰기',
                  onPressed: _analyzeAndShowResult,
                  style: TossButtonStyle.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TossButton(
                  text: '분석 시작',
                  onPressed: _analyzeAndShowResult,
                  style: TossButtonStyle.primary,
                  isEnabled: _canProceedStep2(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: TossDesignSystem.purple,
                ),
                const SizedBox(width: 4),
                Text(
                  '5 영혼 필요',
                  style: TossDesignSystem.caption.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                ),
              ],
            ),
          ),
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
                style: const TextStyle(fontSize: 32),
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
                    const SizedBox(height: 4),
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
                    style: const TextStyle(fontSize: 24),
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
                    const SizedBox(height: 4),
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