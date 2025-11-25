import 'package:flutter/material.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';

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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: TossTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _handleNext() {
    if (_canContinue()) {
      widget.onComplete(_nameController.text.trim(), _birthDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TossTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: TossTheme.spacingXL),
          
          // 제목
          Text(
            '안녕하세요!\n이사운을 알아보기 위해\n기본 정보를 입력해 주세요',
            style: TossTheme.heading2,
          ),
          
          const SizedBox(height: TossTheme.spacingXXL),
          
          // 이름 입력
          Text(
            '이름',
            style: TossTheme.body1.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          TossCard(
            padding: const EdgeInsets.symmetric(
              horizontal: TossTheme.spacingM,
              vertical: TossTheme.spacingS,
            ),
            child: TextField(
              controller: _nameController,
              style: TossTheme.inputStyle,
              decoration: InputDecoration(
                hintText: '이름을 입력하세요',
                hintStyle: TossTheme.hintStyle,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: TossTheme.spacingM,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          const SizedBox(height: TossTheme.spacingXL),
          
          // 생년월일 선택
          Text(
            '생년월일',
            style: TossTheme.body1.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TossTheme.spacingM),
          TossCard(
            onTap: _selectBirthDate,
            padding: const EdgeInsets.all(TossTheme.spacingM),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: _birthDate != null 
                      ? TossTheme.primaryBlue 
                      : TossTheme.textGray400,
                  size: 20,
                ),
                const SizedBox(width: TossTheme.spacingM),
                Expanded(
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: _birthDate != null
                        ? TossTheme.inputStyle
                        : TossTheme.hintStyle,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: TossTheme.textGray400,
                ),
              ],
            ),
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