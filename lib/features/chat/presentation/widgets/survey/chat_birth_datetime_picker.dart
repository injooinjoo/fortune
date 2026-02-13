import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';

/// 생년월일+시간 롤링 피커 (사주용)
///
/// 년, 월, 일, 시, 분을 한 번에 선택
/// 시/분은 "모름" 옵션 포함
/// 날짜 전체를 모를 경우 "날짜 모름" 버튼 제공
class ChatBirthDatetimePicker extends StatefulWidget {
  final void Function(BirthDateTimeResult result) onSelected;
  final String? hintText;
  final DateTime? initialDate;

  const ChatBirthDatetimePicker({
    super.key,
    required this.onSelected,
    this.hintText,
    this.initialDate,
  });

  @override
  State<ChatBirthDatetimePicker> createState() => _ChatBirthDatetimePickerState();
}

class _ChatBirthDatetimePickerState extends State<ChatBirthDatetimePicker> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  int? _selectedHour; // null = 모름
  int? _selectedMinute; // null = 모름

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  // 범위
  final int _startYear = 1920;
  final int _endYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime(1990, 1, 1);
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;
    _selectedHour = null; // 기본 모름
    _selectedMinute = null;

    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - _startYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDay - 1,
    );
    _hourController = FixedExtentScrollController(initialItem: 0); // 모름
    _minuteController = FixedExtentScrollController(initialItem: 0); // 모름
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _updateDay() {
    final maxDay = _daysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > maxDay) {
      setState(() => _selectedDay = maxDay);
    }
  }

  void _onConfirm() {
    DSHaptics.success();
    widget.onSelected(BirthDateTimeResult(
      year: _selectedYear,
      month: _selectedMonth,
      day: _selectedDay,
      hour: _selectedHour,
      minute: _selectedMinute,
    ));
  }

  void _onUnknownDate() {
    DSHaptics.light();
    widget.onSelected(BirthDateTimeResult.unknown());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? colors.background : colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(DSRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: DSSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Text(
              widget.hintText ?? '생년월일을 선택하세요',
              style: typography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 날짜 모름 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onUnknownDate,
                borderRadius: BorderRadius.circular(DSRadius.md),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.textTertiary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      '❓ 날짜를 몰라요',
                      style: typography.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: DSSpacing.sm),

          // 컬럼 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
            child: Row(
              children: [
                _buildColumnHeader('년', 1, colors, typography),
                _buildColumnHeader('월', 0.6, colors, typography),
                _buildColumnHeader('일', 0.6, colors, typography),
                _buildColumnHeader('시', 0.6, colors, typography),
                _buildColumnHeader('분', 0.6, colors, typography),
              ],
            ),
          ),

          // 롤링 피커
          SizedBox(
            height: 180,
            child: Row(
              children: [
                // 년
                Expanded(
                  flex: 10,
                  child: _buildYearPicker(colors, typography, isDark),
                ),
                // 월
                Expanded(
                  flex: 6,
                  child: _buildMonthPicker(colors, typography, isDark),
                ),
                // 일
                Expanded(
                  flex: 6,
                  child: _buildDayPicker(colors, typography, isDark),
                ),
                // 시
                Expanded(
                  flex: 6,
                  child: _buildHourPicker(colors, typography, isDark),
                ),
                // 분
                Expanded(
                  flex: 6,
                  child: _buildMinutePicker(colors, typography, isDark),
                ),
              ],
            ),
          ),

          // 선택 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.md,
              DSSpacing.sm,
              DSSpacing.md,
              DSSpacing.xs,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.ctaBackground,
                  foregroundColor: colors.ctaForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                  ),
                ),
                child: Text(
                  _buildConfirmText(),
                  style: typography.labelMedium.copyWith(
                    color: colors.ctaForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // SafeArea 패딩 (최소값으로 제한)
          SizedBox(height: MediaQuery.of(context).padding.bottom.clamp(0, DSSpacing.sm)),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String label, double flex, DSColorScheme colors, DSTypographyScheme typography) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Center(
        child: Text(
          label,
          style: typography.labelSmall.copyWith(
            color: colors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildYearPicker(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    final years = List.generate(
      _endYear - _startYear + 1,
      (i) => _startYear + i,
    );

    return CupertinoPicker(
      scrollController: _yearController,
      itemExtent: 36,
      selectionOverlay: _buildSelectionOverlay(colors),
      onSelectedItemChanged: (index) {
        DSHaptics.selection();
        setState(() {
          _selectedYear = years[index];
          _updateDay();
        });
      },
      children: years.map((year) => _buildPickerItem(
        '$year',
        year == _selectedYear,
        colors,
        typography,
      )).toList(),
    );
  }

  Widget _buildMonthPicker(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    return CupertinoPicker(
      scrollController: _monthController,
      itemExtent: 36,
      selectionOverlay: _buildSelectionOverlay(colors),
      onSelectedItemChanged: (index) {
        DSHaptics.selection();
        setState(() {
          _selectedMonth = index + 1;
          _updateDay();
        });
      },
      children: List.generate(12, (i) => _buildPickerItem(
        '${i + 1}',
        (i + 1) == _selectedMonth,
        colors,
        typography,
      )),
    );
  }

  Widget _buildDayPicker(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    final maxDay = _daysInMonth(_selectedYear, _selectedMonth);

    return CupertinoPicker(
      scrollController: _dayController,
      itemExtent: 36,
      selectionOverlay: _buildSelectionOverlay(colors),
      onSelectedItemChanged: (index) {
        DSHaptics.selection();
        setState(() => _selectedDay = index + 1);
      },
      children: List.generate(maxDay, (i) => _buildPickerItem(
        '${i + 1}',
        (i + 1) == _selectedDay,
        colors,
        typography,
      )),
    );
  }

  Widget _buildHourPicker(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    // 0: 모름, 1-24: 0시-23시
    final items = ['?', ...List.generate(24, (i) => '$i')];

    return CupertinoPicker(
      scrollController: _hourController,
      itemExtent: 36,
      selectionOverlay: _buildSelectionOverlay(colors),
      onSelectedItemChanged: (index) {
        DSHaptics.selection();
        setState(() {
          _selectedHour = index == 0 ? null : index - 1;
        });
      },
      children: items.asMap().entries.map((e) => _buildPickerItem(
        e.value,
        e.key == 0 ? _selectedHour == null : _selectedHour == e.key - 1,
        colors,
        typography,
      )).toList(),
    );
  }

  Widget _buildMinutePicker(DSColorScheme colors, DSTypographyScheme typography, bool isDark) {
    // 0: 모름, 1-60: 0분-59분 (1분 단위)
    final items = ['?', ...List.generate(60, (i) => i.toString().padLeft(2, '0'))];

    return CupertinoPicker(
      scrollController: _minuteController,
      itemExtent: 36,
      selectionOverlay: _buildSelectionOverlay(colors),
      onSelectedItemChanged: (index) {
        DSHaptics.selection();
        setState(() {
          if (index == 0) {
            _selectedMinute = null;
          } else {
            _selectedMinute = index - 1;
          }
        });
      },
      children: items.asMap().entries.map((e) => _buildPickerItem(
        e.value,
        e.key == 0
            ? _selectedMinute == null
            : _selectedMinute == (e.key - 1),
        colors,
        typography,
      )).toList(),
    );
  }

  Widget _buildPickerItem(String text, bool isSelected, DSColorScheme colors, DSTypographyScheme typography) {
    return Center(
      child: Text(
        text,
        style: typography.labelMedium.copyWith(
          color: isSelected ? colors.textPrimary : colors.textTertiary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay(DSColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colors.textPrimary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
    );
  }

  String _buildConfirmText() {
    final dateStr = '$_selectedYear년 $_selectedMonth월 $_selectedDay일';

    if (_selectedHour == null) {
      return '$dateStr 선택';
    }

    final hourStr = '$_selectedHour시';
    final minuteStr = _selectedMinute != null ? ' $_selectedMinute분' : '';

    return '$dateStr $hourStr$minuteStr 선택';
  }
}

/// 생년월일+시간 선택 결과
class BirthDateTimeResult {
  final int? year;
  final int? month;
  final int? day;
  final int? hour;
  final int? minute;
  final bool isUnknown;

  const BirthDateTimeResult({
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.isUnknown = false,
  });

  factory BirthDateTimeResult.unknown() {
    return const BirthDateTimeResult(isUnknown: true);
  }

  /// ISO 8601 날짜 문자열 (날짜만)
  String? get dateString {
    if (isUnknown || year == null || month == null || day == null) return null;
    return DateTime(year!, month!, day!).toIso8601String();
  }

  /// 시간 문자열 (12시진 형식으로 변환 가능)
  String? get timeString {
    if (hour == null) return null;
    if (minute != null) {
      return '${hour!.toString().padLeft(2, '0')}:${minute!.toString().padLeft(2, '0')}';
    }
    return '${hour!.toString().padLeft(2, '0')}:00';
  }

  /// 표시용 텍스트
  String get displayText {
    if (isUnknown) return '날짜 모름';

    final datePart = year != null && month != null && day != null
        ? '$year년 $month월 $day일'
        : '';

    if (hour == null) return datePart;

    final timePart = minute != null ? '$hour시 $minute분' : '$hour시';
    return '$datePart $timePart';
  }

  /// 12시진 변환
  String? get birthTimeSlot {
    if (hour == null) return 'unknown';

    // 시간대별 12시진 매핑
    if (hour! >= 23 || hour! < 1) return '23-01'; // 자시
    if (hour! >= 1 && hour! < 3) return '01-03'; // 축시
    if (hour! >= 3 && hour! < 5) return '03-05'; // 인시
    if (hour! >= 5 && hour! < 7) return '05-07'; // 묘시
    if (hour! >= 7 && hour! < 9) return '07-09'; // 진시
    if (hour! >= 9 && hour! < 11) return '09-11'; // 사시
    if (hour! >= 11 && hour! < 13) return '11-13'; // 오시
    if (hour! >= 13 && hour! < 15) return '13-15'; // 미시
    if (hour! >= 15 && hour! < 17) return '15-17'; // 신시
    if (hour! >= 17 && hour! < 19) return '17-19'; // 유시
    if (hour! >= 19 && hour! < 21) return '19-21'; // 술시
    return '21-23'; // 해시
  }
}
