import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/fortune_haptic_service.dart';
import 'package:fortune/core/theme/app_animations.dart';
import '../../core/services/holiday_service.dart';
import '../../core/models/holiday_models.dart';
import '../../core/widgets/unified_button.dart';
import '../../core/widgets/unified_button_enums.dart';

class TimeBasedFortuneBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onDismiss;

  const TimeBasedFortuneBottomSheet({
    super.key,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => TimeBasedFortuneBottomSheet(
        onDismiss: onDismiss,
      ),
    ).then((_) {
      onDismiss?.call();
    });
  }

  @override
  ConsumerState<TimeBasedFortuneBottomSheet> createState() =>
      _TimeBasedFortuneBottomSheetState();
}

class _TimeBasedFortuneBottomSheetState
    extends ConsumerState<TimeBasedFortuneBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoadingFortune = false;
  Map<DateTime, CalendarEventInfo> _events = {};
  final HolidayService _holidayService = HolidayService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.durationMedium,
    );
    _animationController.forward();

    // 기본으로 오늘 날짜 선택
    _selectedDay = DateTime.now();
    _loadEventsForMonth(_focusedDay);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEventsForMonth(DateTime month) async {
    try {
      final events = await _holidayService.getEventsForMonth(month);
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      if (mounted) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        ref.read(fortuneHapticServiceProvider).selection();
      }
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    if (mounted) {
      setState(() {
        _focusedDay = focusedDay;
      });
      _loadEventsForMonth(focusedDay);
    }
  }

  void _onFortuneButtonPressed() async {
    if (_selectedDay == null || _isLoadingFortune) return;

    ref.read(fortuneHapticServiceProvider).dateConfirm();

    setState(() {
      _isLoadingFortune = true;
    });

    try {
      if (mounted) {
        setState(() {
          _isLoadingFortune = false;
        });
      }

      if (mounted) {
        Navigator.of(context).pop();

        final eventInfo = _events[DateTime(
            _selectedDay!.year, _selectedDay!.month, _selectedDay!.day)];

        context.push('/daily-calendar', extra: {
          'selectedDate': _selectedDay!.toIso8601String(),
          'autoGenerate': true,
          'fortuneParams': {
            'date': _selectedDay!.toIso8601String(),
            'isHoliday': eventInfo?.isHoliday ?? false,
            'holidayName': eventInfo?.holidayName,
            'specialName': eventInfo?.specialName,
            'auspiciousName': eventInfo?.auspiciousName,
            'isAuspicious': eventInfo?.isAuspicious ?? false,
            'auspiciousScore': eventInfo?.auspiciousScore,
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFortune = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('데이터 로딩 중 오류가 발생했습니다')));
      }
    }
  }

  Widget _buildCalendarCell(
      BuildContext context, DateTime day, DateTime focusedDay) {
    final typography = context.typography;
    final theme = Theme.of(context);
    final isSelected = isSameDay(day, _selectedDay);
    final isToday = isSameDay(day, DateTime.now());
    final isPastDate =
        day.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    final eventInfo = _events[DateTime(day.year, day.month, day.day)];
    final isHoliday = eventInfo?.isHoliday ?? false;
    final isSpecial = eventInfo?.isSpecial ?? false;
    final isAuspicious = eventInfo?.isAuspicious ?? false;
    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color textColor = theme.colorScheme.onSurface;
    Color? backgroundColor;
    Color? borderColor;

    if (isPastDate) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isToday) {
      borderColor = AppTheme.primaryColor;
      textColor = AppTheme.primaryColor;
    } else if (isHoliday || (isWeekend && !isPastDate)) {
      textColor = DSColors.error;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: typography.bodyMedium.copyWith(
                color: textColor,
                fontWeight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // 이벤트 표시 점들
          if (isHoliday || isSpecial || isAuspicious) ...[
            Positioned(
              right: 2,
              top: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHoliday)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: DSColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isSpecial)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: const BoxDecoration(
                        color: DSColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isAuspicious)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 2),
                      decoration: const BoxDecoration(
                        color: DSColors.warning,
                        shape: BoxShape.circle,
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

  Widget _buildSelectedDateInfo() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final eventInfo = _events[
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)];
    final isPastDate = _selectedDay!
        .isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return AnimatedContainer(
      duration: AppAnimations.durationShort,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy년 MM월 dd일').format(_selectedDay!),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          // 이벤트 정보 표시
          if (eventInfo != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (eventInfo.holidayName != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DSColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: DSColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.celebration,
                            size: 14, color: DSColors.error),
                        const SizedBox(width: 4),
                        Text(
                          eventInfo.holidayName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: DSColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (eventInfo.specialName != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DSColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: DSColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            size: 14, color: DSColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          eventInfo.specialName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: DSColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (eventInfo.auspiciousName != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DSColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: DSColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.home,
                            size: 14, color: DSColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          eventInfo.auspiciousName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: DSColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (eventInfo.auspiciousScore != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${eventInfo.auspiciousScore}점',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: DSColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ],

          // 경고 메시지
          if (isPastDate) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: DSColors.textSecondaryDark,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '과거 날짜입니다',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: DSColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isPastDate = _selectedDay
            ?.isBefore(DateTime.now().subtract(const Duration(days: 1))) ??
        false;
    final canGetFortune = _selectedDay != null && !isPastDate;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          )),
          child: Container(
            height: screenHeight * 0.82,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? DSColors.surface
                  : DSColors.surfaceDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: DSColors.textPrimaryDark.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(theme),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildCalendar(theme),
                        _buildSelectedDateInfo(),
                      ],
                    ),
                  ),
                ),
                _buildBottomButton(theme, canGetFortune),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.small,
        bottom: DSSpacing.xs,
      ),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: DSColors.textSecondaryDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Text(
        '운세를 확인할 날짜를 선택해주세요',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    final typography = context.typography;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar<CalendarEventInfo>(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {
            CalendarFormat.month: '월',
            CalendarFormat.week: '주',
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: (day) {
            final event = _events[DateTime(day.year, day.month, day.day)];
            return event != null ? [event] : [];
          },
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: _onPageChanged,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle:
                typography.bodyMedium.copyWith(color: DSColors.error),
            holidayTextStyle:
                typography.bodyMedium.copyWith(color: DSColors.error),
            selectedDecoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: _buildCalendarCell,
            selectedBuilder: _buildCalendarCell,
            todayBuilder: _buildCalendarCell,
            outsideBuilder: _buildCalendarCell,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: AppTheme.primaryColor,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: AppTheme.primaryColor,
            ),
            titleTextStyle:
                (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
            ),
            titleTextFormatter: (date, locale) =>
                DateFormat('yyyy년 M월', 'ko_KR').format(date),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: typography.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            weekendStyle: typography.bodySmall
                .copyWith(color: DSColors.error.withValues(alpha: 0.7)),
          ),
          daysOfWeekHeight: 40,
          locale: 'ko_KR',
        ),
      ),
    );
  }

  Widget _buildBottomButton(ThemeData theme, bool canGetFortune) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xLarge,
        right: AppSpacing.xLarge,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: DSColors.textPrimaryDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: UnifiedButton(
        text: canGetFortune
            ? '운세 보기'
            : (_selectedDay == null ? '날짜를 선택해주세요' : '선택할 수 없는 날짜입니다'),
        onPressed: (canGetFortune && !_isLoadingFortune)
            ? _onFortuneButtonPressed
            : null,
        style: UnifiedButtonStyle.primary,
        size: UnifiedButtonSize.large,
        isLoading: _isLoadingFortune,
        isEnabled: canGetFortune && !_isLoadingFortune,
        icon: !_isLoadingFortune
            ? const Icon(Icons.auto_awesome, size: 20, color: Colors.white)
            : null,
        width: double.infinity,
      ),
    );
  }
}
