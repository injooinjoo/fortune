import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/widgets/app_widgets.dart';
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
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
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
          // 위로 메시지 - ChatGPT 스타일
          const PageHeaderSection(
            emoji: '💜',
            title: '힘드셨죠?',
            subtitle: '천천히 답해주세요. 당신의 마음을 읽어드릴게요.',
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 40),

          // 1. 이별 시기
          const FieldLabel(text: '이별한 지 얼마나 되었나요?'),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectionChip(
                label: '1개월 미만',
                isSelected: _timeSinceBreakup == 'recent',
                onTap: () => setState(() => _timeSinceBreakup = 'recent'),
              ),
              SelectionChip(
                label: '1-3개월',
                isSelected: _timeSinceBreakup == 'short',
                onTap: () => setState(() => _timeSinceBreakup = 'short'),
              ),
              SelectionChip(
                label: '3-6개월',
                isSelected: _timeSinceBreakup == 'medium',
                onTap: () => setState(() => _timeSinceBreakup = 'medium'),
              ),
              SelectionChip(
                label: '6개월-1년',
                isSelected: _timeSinceBreakup == 'long',
                onTap: () => setState(() => _timeSinceBreakup = 'long'),
              ),
              SelectionChip(
                label: '1년 이상',
                isSelected: _timeSinceBreakup == 'verylong',
                onTap: () => setState(() => _timeSinceBreakup = 'verylong'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 2. 현재 감정
          const FieldLabel(text: '지금 나의 마음은?'),

          ...emotionCards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectionCard(
              title: card.title,
              subtitle: card.description,
              emoji: card.emoji,
              isSelected: _currentEmotion == card.id,
              onTap: () => setState(() => _currentEmotion = card.id),
            ),
          )),

          const SizedBox(height: 32),

          // 3. 가장 궁금한 것
          const FieldLabel(text: '가장 궁금한 것을 하나만 선택해주세요'),

          ...curiosityCards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectionCard(
              title: card.title,
              subtitle: card.description,
              emoji: card.icon,
              isSelected: _mainCuriosity == card.id,
              onTap: () => setState(() => _mainCuriosity = card.id),
            ),
          )),

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
          // 헤더 - ChatGPT 스타일
          const PageHeaderSection(
            emoji: '✨',
            title: '더 정확한 분석을 원하시나요?',
            subtitle: '선택사항이에요. 건너뛰어도 괜찮아요.',
          ),

          const SizedBox(height: 40),

          // 상대방 생년월일
          NumericDateInput(
            label: '상대방 생년월일 (선택)',
            selectedDate: _exBirthDate,
            onDateChanged: (date) => setState(() => _exBirthDate = date),
            minDate: DateTime(1950),
            maxDate: DateTime.now(),
            showAge: true,
          ),

          const SizedBox(height: 32),

          // 이별 이유
          const FieldLabel(text: '이별 이유 (선택)'),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectionChip(
                label: '가치관 차이',
                isSelected: _breakupReason == 'differentValues',
                onTap: () => setState(() => _breakupReason = 'differentValues'),
              ),
              SelectionChip(
                label: '시기가 맞지 않음',
                isSelected: _breakupReason == 'timing',
                onTap: () => setState(() => _breakupReason = 'timing'),
              ),
              SelectionChip(
                label: '소통 부족',
                isSelected: _breakupReason == 'communication',
                onTap: () => setState(() => _breakupReason = 'communication'),
              ),
              SelectionChip(
                label: '신뢰 문제',
                isSelected: _breakupReason == 'trust',
                onTap: () => setState(() => _breakupReason = 'trust'),
              ),
              SelectionChip(
                label: '기타',
                isSelected: _breakupReason == 'other',
                onTap: () => setState(() => _breakupReason = 'other'),
              ),
            ],
          ),

          // Floating 버튼 공간 확보
          const SizedBox(height: 100),
        ],
      ),
    );
  }

}