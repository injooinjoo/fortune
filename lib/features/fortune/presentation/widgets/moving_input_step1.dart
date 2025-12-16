import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';

/// 1단계: 기본 정보 입력
class MovingInputStep1 extends StatefulWidget {
  final Function(String name, DateTime birthDate) onComplete;

  const MovingInputStep1({
    super.key,
    required this.onComplete,
  });

  @override
  State<MovingInputStep1> createState() => _MovingInputStep1State();
}

class _MovingInputStep1State extends State<MovingInputStep1> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _canContinue() {
    return _nameController.text.trim().isNotEmpty && _birthDate != null;
  }

  void _handleNext() {
    if (_canContinue()) {
      widget.onComplete(_nameController.text.trim(), _birthDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSSpacing.xl),
          
          // 제목
          Text(
            '안녕하세요!\n이사운을 알아보기 위해\n기본 정보를 입력해 주세요',
            style: DSTypography.headingMedium,
          ),
          
          const SizedBox(height: DSSpacing.xxl),
          
          // 이름 입력
          Text(
            '이름',
            style: DSTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            child: TextField(
              controller: _nameController,
              style: DSTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: '이름을 입력하세요',
                hintStyle: DSTypography.bodyLarge.copyWith(color: DSColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: DSSpacing.md,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          const SizedBox(height: DSSpacing.xl),
          
          // 생년월일 선택
          NumericDateInput(
            label: '생년월일',
            selectedDate: _birthDate,
            onDateChanged: (date) => setState(() => _birthDate = date),
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            showAge: true,
          ),
          
          const Spacer(),
          
          // 다음 버튼
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: UnifiedButton(
                text: '다음',
                onPressed: _canContinue() ? _handleNext : null,
                style: UnifiedButtonStyle.primary,
                size: UnifiedButtonSize.large,
              ),
            ),
          ),
        ],
      ),
    );
  }
}