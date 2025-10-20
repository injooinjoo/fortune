import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/accordion_input_section.dart';

class LuckyItemsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;

  const LuckyItemsPage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<LuckyItemsPage> createState() => _LuckyItemsPageState();
}

class _LuckyItemsPageState extends ConsumerState<LuckyItemsPage> {
  // 선택된 값들
  DateTime? _selectedBirthDate;
  String? _selectedBirthTime;
  String? _selectedGender;

  // 아코디언 섹션
  List<AccordionInputSection> _accordionSections = [];

  @override
  void initState() {
    super.initState();
    _initializeFromProfile();
  }

  void _initializeFromProfile() {
    // 이미 로드된 프로필 정보 사용 (앱 시작 시 로드됨)
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;

    _selectedBirthDate = profile?.birthDate;
    _selectedBirthTime = profile?.birthTime;
    _selectedGender = profile?.gender;

    setState(() {

      _accordionSections = [
        AccordionInputSection(
          id: 'birthDate',
          title: '생년월일',
          icon: Icons.cake_rounded,
          inputWidgetBuilder: (context, onComplete) => _buildBirthDateInput(onComplete),
          value: _selectedBirthDate,
          isCompleted: _selectedBirthDate != null,
          displayValue: _selectedBirthDate != null ? _formatBirthDateDisplay(_selectedBirthDate!) : null,
        ),
        AccordionInputSection(
          id: 'birthTime',
          title: '출생 시간',
          icon: Icons.access_time_rounded,
          inputWidgetBuilder: (context, onComplete) => _buildBirthTimeInput(onComplete),
          value: _selectedBirthTime,
          isCompleted: _selectedBirthTime != null,
          displayValue: _selectedBirthTime != null ? _formatBirthTimeDisplay(_selectedBirthTime!) : null,
        ),
        AccordionInputSection(
          id: 'gender',
          title: '성별',
          icon: Icons.person_rounded,
          inputWidgetBuilder: (context, onComplete) => _buildGenderInput(onComplete),
          value: _selectedGender,
          isCompleted: _selectedGender != null,
          displayValue: _selectedGender != null ? _formatGenderDisplay(_selectedGender!) : null,
        ),
      ];
    });
  }

  // 생년월일 표시 포맷 (예: "1990년 5월 15일 (만 34세)")
  String _formatBirthDateDisplay(DateTime date) {
    final now = DateTime.now();
    final age = now.year - date.year - (now.month < date.month || (now.month == date.month && now.day < date.day) ? 1 : 0);
    return '${date.year}년 ${date.month}월 ${date.day}일 (만 ${age}세)';
  }

  // 출생 시간 표시 포맷 (예: "오전 10시 30분 (辰時)")
  String _formatBirthTimeDisplay(String time) {
    // "HH:MM" 형식만 파싱
    if (!time.contains(':')) {
      return time; // 이미 포맷된 텍스트면 그대로 반환
    }

    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final siTime = _getChineseHour(hour);

      return '$period ${displayHour}시 ${minute}분 ($siTime)';
    } catch (e) {
      return time; // 파싱 실패 시 원본 반환
    }
  }

  // 성별 표시 포맷
  String _formatGenderDisplay(String gender) {
    return gender == 'male' ? '남성 (陽)' : '여성 (陰)';
  }

  // 12지신 시간 계산
  String _getChineseHour(int hour) {
    const timeMap = {
      23: '子時', 0: '子時',  // 23:00-01:00 자시 (쥐)
      1: '丑時', 2: '丑時',   // 01:00-03:00 축시 (소)
      3: '寅時', 4: '寅時',   // 03:00-05:00 인시 (호랑이)
      5: '卯時', 6: '卯時',   // 05:00-07:00 묘시 (토끼)
      7: '辰時', 8: '辰時',   // 07:00-09:00 진시 (용)
      9: '巳時', 10: '巳時',  // 09:00-11:00 사시 (뱀)
      11: '午時', 12: '午時', // 11:00-13:00 오시 (말)
      13: '未時', 14: '未時', // 13:00-15:00 미시 (양)
      15: '申時', 16: '申時', // 15:00-17:00 신시 (원숭이)
      17: '酉時', 18: '酉時', // 17:00-19:00 유시 (닭)
      19: '戌時', 20: '戌時', // 19:00-21:00 술시 (개)
      21: '亥時', 22: '亥時', // 21:00-23:00 해시 (돼지)
    };
    return timeMap[hour] ?? '未詳';
  }

  // 아코디언 섹션 업데이트
  void _updateAccordionSection(String id, dynamic value, String displayValue) {
    final index = _accordionSections.indexWhere((section) => section.id == id);
    if (index != -1) {
      _accordionSections[index] = AccordionInputSection(
        id: _accordionSections[index].id,
        title: _accordionSections[index].title,
        icon: _accordionSections[index].icon,
        inputWidgetBuilder: _accordionSections[index].inputWidgetBuilder,
        value: value,
        isCompleted: true,
        displayValue: displayValue,
      );
    }
  }

  bool _canGenerate() {
    return _selectedBirthDate != null &&
        _selectedBirthTime != null &&
        _selectedGender != null;
  }

  Future<void> _handleGenerateFortune() async {
    if (!_canGenerate()) return;

    // 결과 페이지로 이동
    if (mounted) {
      context.push('/lucky-items-results', extra: {
        'birthDate': _selectedBirthDate,
        'birthTime': _selectedBirthTime,
        'gender': _selectedGender,
        'interests': [], // 빈 배열로 전달
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show selection UI with Accordion
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
      appBar: StandardFortuneAppBar(
        title: '행운 아이템',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: _buildTitleSection(),
                ),
                Expanded(
                  child: _accordionSections.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : AccordionInputForm(
                          sections: _accordionSections,
                          onAllCompleted: null, // floating button으로 운세 생성
                          completionButtonText: '🌟 행운 아이템 확인하기',
                        ),
                ),
              ],
            ),
            if (_canGenerate())
              TossFloatingProgressButtonPositioned(
                text: '🌟 행운 아이템 확인하기',
                onPressed: _canGenerate() ? () => _handleGenerateFortune() : null,
                isEnabled: _canGenerate(),
                showProgress: false,
                isVisible: _canGenerate(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신만의 행운을\n찾아드릴게요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '기본 정보를 입력하면\n맞춤 행운 아이템을 추천해드려요',
          style: TypographyUnified.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // 생년월일 입력 위젯
  Widget _buildBirthDateInput(Function(dynamic) onComplete) {
    return _buildDatePickerWithNumpad(
      initialDate: _selectedBirthDate,
      onDateSelected: (date) {
        setState(() {
          _selectedBirthDate = date;
          _updateAccordionSection('birthDate', date, _formatBirthDateDisplay(date));
        });
        onComplete(date);
      },
    );
  }

  // 출생 시간 입력 위젯
  Widget _buildBirthTimeInput(Function(dynamic) onComplete) {
    return _buildTimePickerWithNumpad(
      initialTime: _selectedBirthTime,
      onTimeSelected: (time) {
        setState(() {
          _selectedBirthTime = time;
          _updateAccordionSection('birthTime', time, _formatBirthTimeDisplay(time));
        });
        onComplete(time);
      },
    );
  }

  // 성별 입력 위젯
  Widget _buildGenderInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = 'male';
                _updateAccordionSection('gender', 'male', _formatGenderDisplay('male'));
              });
              HapticFeedback.mediumImpact();
              onComplete('male');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _selectedGender == 'male'
                    ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                    : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == 'male'
                      ? TossDesignSystem.tossBlue
                      : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
                  width: _selectedGender == 'male' ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.male,
                    size: 48,
                    color: _selectedGender == 'male'
                        ? TossDesignSystem.tossBlue
                        : TossDesignSystem.gray400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '남성',
                    style: TypographyUnified.buttonMedium.copyWith(
                      color: _selectedGender == 'male'
                          ? TossDesignSystem.tossBlue
                          : TossDesignSystem.gray600,
                      fontWeight: _selectedGender == 'male'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedGender = 'female';
                _updateAccordionSection('gender', 'female', _formatGenderDisplay('female'));
              });
              HapticFeedback.mediumImpact();
              onComplete('female');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _selectedGender == 'female'
                    ? const Color(0xFFEC407A).withValues(alpha: 0.1)
                    : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGender == 'female'
                      ? const Color(0xFFEC407A)
                      : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
                  width: _selectedGender == 'female' ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.female,
                    size: 48,
                    color: _selectedGender == 'female'
                        ? const Color(0xFFEC407A)
                        : TossDesignSystem.gray400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '여성',
                    style: TypographyUnified.buttonMedium.copyWith(
                      color: _selectedGender == 'female'
                          ? const Color(0xFFEC407A)
                          : TossDesignSystem.gray600,
                      fontWeight: _selectedGender == 'female'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 생년월일 입력 (TextField)
  Widget _buildDatePickerWithNumpad({
    required DateTime? initialDate,
    required Function(DateTime) onDateSelected,
  }) {
    final controller = TextEditingController(
      text: initialDate != null
          ? '${initialDate.year}${initialDate.month.toString().padLeft(2, '0')}${initialDate.day.toString().padLeft(2, '0')}'
          : '',
    );

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 8,
      decoration: InputDecoration(
        hintText: 'YYYYMMDD',
        labelText: '생년월일',
        counterText: '',
        filled: true,
        fillColor: TossDesignSystem.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        if (value.length == 8) {
          try {
            final year = int.parse(value.substring(0, 4));
            final month = int.parse(value.substring(4, 6));
            final day = int.parse(value.substring(6, 8));
            final date = DateTime(year, month, day);
            onDateSelected(date);
          } catch (e) {
            // Invalid date
          }
        }
      },
    );
  }

  // 출생 시간 입력 (TextField)
  Widget _buildTimePickerWithNumpad({
    required String? initialTime,
    required Function(String) onTimeSelected,
  }) {
    // initialTime이 "HH:MM" 형식인지 확인하고 숫자만 추출
    String initialValue = '';
    if (initialTime != null && initialTime.contains(':')) {
      initialValue = initialTime.replaceAll(':', '');
    }

    final controller = TextEditingController(text: initialValue);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 4,
      decoration: InputDecoration(
        hintText: 'HHMM',
        labelText: '출생 시간',
        counterText: '',
        filled: true,
        fillColor: TossDesignSystem.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        if (value.length == 4) {
          final hour = int.tryParse(value.substring(0, 2));
          final minute = int.tryParse(value.substring(2, 4));
          if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            onTimeSelected('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
          }
        }
      },
    );
  }


}
