import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/components/app_input.dart';
import '../../../../core/widgets/date_picker/numeric_date_input.dart';

/// 사주팔자 정보 입력 폼 위젯
class SajuInputForm extends StatefulWidget {
  final Function(String name, DateTime birthDate, String? birthTime, String gender) onComplete;

  const SajuInputForm({
    super.key,
    required this.onComplete,
  });

  @override
  State<SajuInputForm> createState() => _SajuInputFormState();
}

class _SajuInputFormState extends State<SajuInputForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTime;
  String _selectedGender = '남';
  bool _unknownTime = false;
  
  final List<String> _hourOptions = [
    '모름',
    '자시 (23:00-01:00)', '축시 (01:00-03:00)', '인시 (03:00-05:00)',
    '묘시 (05:00-07:00)', '진시 (07:00-09:00)', '사시 (09:00-11:00)',
    '오시 (11:00-13:00)', '미시 (13:00-15:00)', '신시 (15:00-17:00)',
    '유시 (17:00-19:00)', '술시 (19:00-21:00)', '해시 (21:00-23:00)',
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _selectTime(String? value) {
    setState(() {
      if (value == '모름') {
        _unknownTime = true;
        _selectedTime = null;
      } else {
        _unknownTime = false;
        _selectedTime = value;
      }
    });
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate != null) {
        widget.onComplete(
          _nameController.text.trim(),
          _selectedDate!,
          _selectedTime,
          _selectedGender,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DSSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: DSSpacing.lg),
                        
                        // 제목과 설명
                        _buildHeader(),
                        
                        const SizedBox(height: DSSpacing.xl),
                        
                        // 이름 입력
                        _buildNameInput(),
                        
                        const SizedBox(height: DSSpacing.lg),
                        
                        // 생년월일 선택
                        _buildDateInput(),
                        
                        const SizedBox(height: DSSpacing.lg),
                        
                        // 출생 시간 선택
                        _buildTimeInput(),
                        
                        const SizedBox(height: DSSpacing.lg),
                        
                        // 성별 선택
                        _buildGenderInput(),
                        
                        const SizedBox(height: DSSpacing.xl),
                        
                        // 안내 메시지
                        _buildInfoMessage(),
                        
                        const SizedBox(height: DSSpacing.xl),
                        
                        // 확인 버튼
                        UnifiedButton(
                          text: '사주팔자 분석하기',
                          onPressed: _onSubmit,
                          style: UnifiedButtonStyle.primary,
                          width: double.infinity,
                          icon: const Icon(Icons.auto_awesome),
                        ),
                        
                        const SizedBox(height: DSSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정보 입력',
          style: context.displaySmall.copyWith(
            color: DSColors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          '정확한 사주팔자 분석을 위해\n기본 정보를 입력해주세요',
          style: context.bodyLarge.copyWith(
            color: DSColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: DSColors.accent,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '이름',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' *',
                style: context.bodyLarge.copyWith(
                  color: DSColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          TossTextField(
            controller: _nameController,
            hintText: '성함을 입력해주세요',
            onChanged: (value) {
              // validation logic can be added here if needed
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z가-힣\s]')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: DSColors.accent,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '생년월일',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' *',
                style: context.bodyLarge.copyWith(
                  color: DSColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          NumericDateInput(
            selectedDate: _selectedDate,
            onDateChanged: (date) => setState(() => _selectedDate = date),
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            showAge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                color: DSColors.accent,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '출생 시간',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '정확한 분석을 위해 출생 시간을 선택해주세요',
            style: context.labelSmall.copyWith(
              color: DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: DSColors.border),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _unknownTime ? '모름' : _selectedTime,
                hint: Text(
                  '출생 시간을 선택하세요',
                  style: context.bodyLarge.copyWith(
                    color: DSColors.textTertiary,
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: DSColors.textTertiary,
                ),
                style: context.bodyLarge.copyWith(
                  color: DSColors.textPrimary,
                ),
                dropdownColor: DSColors.background,
                items: _hourOptions.map((String time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: _selectTime,
              ),
            ),
          ),
          if (_unknownTime) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: DSColors.warning,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      '시간을 모르는 경우 정오(12시) 기준으로 분석됩니다',
                      style: context.labelSmall.copyWith(
                        color: DSColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderInput() {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wc_outlined,
                color: DSColors.accent,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '성별',
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' *',
                style: context.bodyLarge.copyWith(
                  color: DSColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = '남'),
                  child: Container(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: _selectedGender == '남'
                          ? DSColors.accent.withValues(alpha: 0.1)
                          : DSColors.backgroundSecondary,
                      border: Border.all(
                        color: _selectedGender == '남'
                            ? DSColors.accent
                            : DSColors.border,
                      ),
                      borderRadius: BorderRadius.circular(DSRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.male,
                          color: _selectedGender == '남'
                              ? DSColors.accent
                              : DSColors.textSecondary,
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        Text(
                          '남성',
                          style: context.bodyLarge.copyWith(
                            color: _selectedGender == '남'
                                ? DSColors.accent
                                : DSColors.textSecondary,
                            fontWeight: _selectedGender == '남'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = '여'),
                  child: Container(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: _selectedGender == '여'
                          ? DSColors.accent.withValues(alpha: 0.1)
                          : DSColors.backgroundSecondary,
                      border: Border.all(
                        color: _selectedGender == '여'
                            ? DSColors.accent
                            : DSColors.border,
                      ),
                      borderRadius: BorderRadius.circular(DSRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.female,
                          color: _selectedGender == '여'
                              ? DSColors.accent
                              : DSColors.textSecondary,
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        Text(
                          '여성',
                          style: context.bodyLarge.copyWith(
                            color: _selectedGender == '여'
                                ? DSColors.accent
                                : DSColors.textSecondary,
                            fontWeight: _selectedGender == '여'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: DSColors.accent,
            size: 20,
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '개인정보 보호',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DSColors.accent,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                Text(
                  '입력하신 정보는 사주 분석 목적으로만 사용되며, 서버에 저장되지 않습니다.',
                  style: context.labelSmall.copyWith(
                    color: DSColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}