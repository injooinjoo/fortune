import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/core/widgets/unified_date_picker.dart';
import 'package:fortune/core/widgets/unified_button.dart';

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

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 카드
                _buildHeaderCard(isDark),

                const SizedBox(height: 24),

                // 첫 번째 사람 정보 - 컴팩트 스타일
                _buildPerson1Label(),

                const SizedBox(height: 12),

                _buildPerson1Card(isDark),

                const SizedBox(height: 20),

                // 두 번째 사람 정보 - 강조된 스타일
                _buildPerson2Label(),

                const SizedBox(height: 16),

                _buildPerson2Card(isDark),

                SizedBox(height: 16),

                Center(
                  child: Text(
                    '분석 결과는 참고용으로만 활용해 주세요',
                    style: TossTheme.caption.copyWith(
                      color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
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
            isLoading: isLoading,
          ),
      ],
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEC4899),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite,
              color: TossDesignSystem.white,
              size: 36,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          SizedBox(height: 24),

          Text(
            '두 사람의 궁합',
            style: TossTheme.heading2.copyWith(
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12),

          Text(
            '이름과 생년월일을 입력하면\n두 사람의 궁합을 자세히 분석해드릴게요',
            style: TossTheme.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossTheme.textGray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildPerson1Label() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: TossTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 14,
                color: TossTheme.primaryBlue,
              ),
              SizedBox(width: 4),
              Text(
                '나',
                style: TossTheme.caption.copyWith(
                  color: TossTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerson1Card(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      style: AppCardStyle.outlined,
      child: Column(
        children: [
          TextField(
            controller: person1NameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력해주세요',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: TossTheme.borderGray300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: TossTheme.primaryBlue,
                  width: 1.5,
                ),
              ),
            ),
            style: TossTheme.body2.copyWith(
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                size: 16,
                color: TossDesignSystem.white,
              ),
              SizedBox(width: 6),
              Text(
                '상대방',
                style: TossTheme.body2.copyWith(
                  color: TossDesignSystem.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerson2Card(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: person2NameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '상대방 이름을 입력해주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? TossDesignSystem.grayDark400 : TossTheme.borderGray300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: TossTheme.primaryBlue,
                ),
              ),
            ),
            style: TossTheme.body1.copyWith(
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
            ),
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
