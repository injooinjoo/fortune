import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/widgets/app_widgets.dart';
import 'package:fortune/core/widgets/unified_date_picker.dart';
import 'package:fortune/core/widgets/unified_button.dart';
import 'package:fortune/features/fortune/presentation/widgets/fortune_loading_skeleton.dart';

class CompatibilityInputView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController person1NameController;
  final TextEditingController person2NameController;
  final DateTime? person1BirthDate;
  final DateTime? person2BirthDate;
  final ValueChanged<DateTime?> onPerson1BirthDateChanged;
  final ValueChanged<DateTime?> onPerson2BirthDateChanged;
  final VoidCallback onAnalyze;
  final bool isLoading;
  final bool canAnalyze;

  const CompatibilityInputView({
    super.key,
    required this.formKey,
    required this.person1NameController,
    required this.person2NameController,
    required this.person1BirthDate,
    required this.person2BirthDate,
    required this.onPerson1BirthDateChanged,
    required this.onPerson2BirthDateChanged,
    required this.onAnalyze,
    required this.isLoading,
    required this.canAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 로딩 중일 때 스켈레톤 UI 표시
    if (isLoading) {
      return _buildLoadingSkeleton(isDark);
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 카드 - ChatGPT 스타일
                const PageHeaderSection(
                  emoji: '💕',
                  title: '두 사람의 궁합',
                  subtitle: '이름과 생년월일을 입력하면\n두 사람의 궁합을 자세히 분석해드릴게요',
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

                const SizedBox(height: 32),

                // 첫 번째 사람 정보 - 컴팩트 스타일
                _buildPerson1Label(),

                const SizedBox(height: 12),

                _buildPerson1Card(isDark),

                const SizedBox(height: 24),

                // 두 번째 사람 정보 - 강조된 스타일
                _buildPerson2Label(),

                const SizedBox(height: 16),

                _buildPerson2Card(isDark),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    '분석 결과는 참고용으로만 활용해 주세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Floating 버튼 - 조건 미달성 시 숨김
        if (canAnalyze)
          UnifiedButton.floating(
            text: '궁합 분석하기',
            onPressed: canAnalyze ? onAnalyze : null,
            isEnabled: canAnalyze,
          ),
      ],
    );
  }

  /// 로딩 스켈레톤 UI
  Widget _buildLoadingSkeleton(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FortuneLoadingSkeleton(
        itemCount: 4,
        showHeader: true,
        loadingMessages: const [
          '두 분의 궁합을 분석하고 있어요...',
          '사주팔자를 확인하는 중...',
          '운명의 연결고리를 찾는 중...',
          '특별한 인연을 분석하는 중...',
        ],
      ),
    );
  }

  Widget _buildPerson1Label() {
    return const FieldLabel(text: '👤 나의 정보');
  }

  Widget _buildPerson1Card(bool isDark) {
    return ModernCard(
      child: Column(
        children: [
          PillTextField(
            controller: person1NameController,
            labelText: '이름',
            hintText: '이름을 입력해주세요',
          ),

          const SizedBox(height: 12),

          UnifiedDatePicker(
            mode: UnifiedDatePickerMode.numeric,
            selectedDate: person1BirthDate,
            onDateChanged: (date) {
              onPerson1BirthDateChanged(date);
              HapticFeedback.mediumImpact();
            },
            label: '생년월일',
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            showAge: false,
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildPerson2Label() {
    return const FieldLabel(text: '💕 상대방 정보');
  }

  Widget _buildPerson2Card(bool isDark) {
    return ModernCard(
      child: Column(
        children: [
          PillTextField(
            controller: person2NameController,
            labelText: '이름',
            hintText: '상대방 이름을 입력해주세요',
          ),

          const SizedBox(height: 16),

          UnifiedDatePicker(
            mode: UnifiedDatePickerMode.numeric,
            selectedDate: person2BirthDate,
            onDateChanged: (date) {
              onPerson2BirthDateChanged(date);
              HapticFeedback.mediumImpact();
            },
            label: '상대방 생년월일',
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            showAge: false,
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3);
  }
}
