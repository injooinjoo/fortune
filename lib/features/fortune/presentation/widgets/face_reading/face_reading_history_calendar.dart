import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/face_reading_history_entry.dart';

/// 관상 분석 히스토리 캘린더
/// 월별 분석 기록을 캘린더 형태로 표시합니다.
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class FaceReadingHistoryCalendar extends ConsumerStatefulWidget {
  /// 히스토리 엔트리 목록
  final List<FaceReadingHistoryEntry> entries;

  /// 날짜 선택 콜백
  final void Function(DateTime date, FaceReadingHistoryEntry? entry)?
      onDateSelected;

  /// 엔트리 상세보기 콜백
  final void Function(FaceReadingHistoryEntry entry)? onEntryTap;

  /// 비교하기 콜백 (두 날짜 선택 시)
  final void Function(DateTime date1, DateTime date2)? onCompareRequest;

  /// 초기 선택 날짜
  final DateTime? initialSelectedDate;

  /// 비교 모드 활성화 여부
  final bool compareMode;

  const FaceReadingHistoryCalendar({
    super.key,
    required this.entries,
    this.onDateSelected,
    this.onEntryTap,
    this.onCompareRequest,
    this.initialSelectedDate,
    this.compareMode = false,
  });

  @override
  ConsumerState<FaceReadingHistoryCalendar> createState() =>
      _FaceReadingHistoryCalendarState();
}

class _FaceReadingHistoryCalendarState
    extends ConsumerState<FaceReadingHistoryCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  DateTime? _compareDate; // 비교 모드에서 두 번째 날짜
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // 날짜별 엔트리 맵 (빠른 조회용)
  late Map<DateTime, FaceReadingHistoryEntry> _entryMap;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialSelectedDate ?? DateTime.now();
    _selectedDay = widget.initialSelectedDate;
    _buildEntryMap();
  }

  @override
  void didUpdateWidget(FaceReadingHistoryCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != oldWidget.entries) {
      _buildEntryMap();
    }
    if (widget.compareMode != oldWidget.compareMode && !widget.compareMode) {
      _compareDate = null;
    }
  }

  void _buildEntryMap() {
    _entryMap = {};
    for (final entry in widget.entries) {
      final normalizedDate = _normalizeDate(entry.createdAt);
      _entryMap[normalizedDate] = entry;
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  FaceReadingHistoryEntry? _getEntryForDay(DateTime day) {
    return _entryMap[_normalizeDate(day)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark ? DSColors.borderDark : DSColors.border,
        ),
      ),
      child: Column(
        children: [
          // 헤더
          _buildHeader(),

          // 캘린더
          TableCalendar<FaceReadingHistoryEntry>(
            firstDay: DateTime(2020),
            lastDay: DateTime.now().add(const Duration(days: 1)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            locale: 'ko_KR',
            selectedDayPredicate: (day) {
              if (widget.compareMode && _compareDate != null) {
                return _isSameDay(_selectedDay, day) ||
                    _isSameDay(_compareDate, day);
              }
              return _isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              _handleDaySelected(selectedDay, focusedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              final entry = _getEntryForDay(day);
              return entry != null ? [entry] : [];
            },
            calendarStyle: _buildCalendarStyle(),
            calendarBuilders: _buildCalendarBuilders(),
            headerStyle: _buildHeaderStyle(),
            daysOfWeekStyle: _buildDaysOfWeekStyle(),
          ),

          // 선택된 날짜 정보
          if (_selectedDay != null) _buildSelectedDayInfo(),

          // 비교 모드 안내
          if (widget.compareMode) _buildCompareModeHint(),

          // 통계 요약
          _buildStatsSummary(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// 헤더 빌드
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: DSColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나의 분석 기록',
                  style: context.labelMedium.copyWith(
                    color: context.isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.entries.length}번의 순간이 기록되었어요',
                  style: context.labelSmall.copyWith(
                    color: context.isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 비교 모드 토글
          if (widget.onCompareRequest != null) _buildCompareToggle(),
        ],
      ),
    );
  }

  /// 비교 모드 토글 버튼
  Widget _buildCompareToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _compareDate = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.compareMode
              ? DSColors.accent.withValues(alpha: 0.15)
              : DSColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: widget.compareMode
              ? Border.all(color: DSColors.accent.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.compare_arrows,
              color: DSColors.accent,
              size: 16,
            ),
            const SizedBox(width: DSSpacing.xs),
            Text(
              '비교',
              style: context.labelSmall.copyWith(
                color: DSColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 캘린더 스타일
  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      outsideDaysVisible: false,
      weekendTextStyle: const TextStyle(
        color: DSColors.warning,
        fontWeight: FontWeight.w500,
      ),
      todayDecoration: BoxDecoration(
        color: DSColors.accent.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      todayTextStyle: const TextStyle(
        color: DSColors.accent,
        fontWeight: FontWeight.w700,
      ),
      selectedDecoration: const BoxDecoration(
        color: DSColors.accent,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      markerDecoration: const BoxDecoration(
        color: DSColors.success,
        shape: BoxShape.circle,
      ),
      markersMaxCount: 1,
      markerSize: 6,
      markerMargin: const EdgeInsets.only(top: 2),
    );
  }

  /// 캘린더 빌더
  CalendarBuilders<FaceReadingHistoryEntry> _buildCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, day, events) {
        if (events.isEmpty) return null;

        final entry = events.first;
        final score = entry.overallFortuneScore;
        final color = _getScoreColor(score);

        return Positioned(
          bottom: 2,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      defaultBuilder: (context, day, focusedDay) {
        final entry = _getEntryForDay(day);
        final isCompareSelected =
            widget.compareMode && _isSameDay(_compareDate, day);

        if (entry != null) {
          final score = entry.overallFortuneScore;
          final color = _getScoreColor(score);

          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isCompareSelected
                  ? DSColors.accentSecondary.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: isCompareSelected
                  ? Border.all(
                      color: DSColors.accentSecondary,
                      width: 2,
                    )
                  : Border.all(
                      color: color.withValues(alpha: 0.4),
                      width: 1,
                    ),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: context.labelSmall.copyWith(
                  color: context.isDark
                      ? DSColors.textPrimaryDark
                      : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
        return null;
      },
    );
  }

  /// 헤더 스타일
  HeaderStyle _buildHeaderStyle() {
    return HeaderStyle(
      formatButtonVisible: true,
      titleCentered: true,
      formatButtonShowsNext: false,
      formatButtonDecoration: BoxDecoration(
        color: DSColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      formatButtonTextStyle: context.labelSmall.copyWith(
        color: DSColors.accent,
        fontWeight: FontWeight.w600,
      ),
      titleTextStyle: context.labelLarge.copyWith(
        color: context.isDark ? DSColors.textPrimaryDark : DSColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      leftChevronIcon: Icon(
        Icons.chevron_left,
        color: context.isDark
            ? DSColors.textSecondaryDark
            : DSColors.textSecondary,
      ),
      rightChevronIcon: Icon(
        Icons.chevron_right,
        color: context.isDark
            ? DSColors.textSecondaryDark
            : DSColors.textSecondary,
      ),
    );
  }

  /// 요일 스타일
  DaysOfWeekStyle _buildDaysOfWeekStyle() {
    return DaysOfWeekStyle(
      weekdayStyle: context.labelSmall.copyWith(
        color: context.isDark
            ? DSColors.textSecondaryDark
            : DSColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      weekendStyle: context.labelSmall.copyWith(
        color: DSColors.warning,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 날짜 선택 처리
  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final entry = _getEntryForDay(selectedDay);

    if (widget.compareMode) {
      // 비교 모드
      if (_selectedDay == null) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      } else if (_compareDate == null &&
          !_isSameDay(_selectedDay, selectedDay)) {
        setState(() {
          _compareDate = selectedDay;
        });
        // 두 날짜 선택 완료 → 비교 요청
        if (widget.onCompareRequest != null) {
          widget.onCompareRequest!(_selectedDay!, _compareDate!);
        }
      } else {
        // 다시 첫 번째 날짜 선택
        setState(() {
          _selectedDay = selectedDay;
          _compareDate = null;
          _focusedDay = focusedDay;
        });
      }
    } else {
      // 일반 모드
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }

    widget.onDateSelected?.call(selectedDay, entry);
  }

  /// 선택된 날짜 정보 표시
  Widget _buildSelectedDayInfo() {
    final entry = _getEntryForDay(_selectedDay!);
    final dateStr = DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDay!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark
            ? DSColors.backgroundDark.withValues(alpha: 0.5)
            : DSColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.isDark ? DSColors.borderDark : DSColors.border,
        ),
      ),
      child: entry != null
          ? _buildEntryPreview(entry, dateStr)
          : _buildNoEntryMessage(dateStr),
    );
  }

  /// 엔트리 미리보기
  Widget _buildEntryPreview(FaceReadingHistoryEntry entry, String dateStr) {
    return GestureDetector(
      onTap: () => widget.onEntryTap?.call(entry),
      child: Row(
        children: [
          // 점수 표시
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getScoreColor(entry.overallFortuneScore)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${entry.overallFortuneScore}',
                style: context.heading4.copyWith(
                  color: _getScoreColor(entry.overallFortuneScore),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: context.labelMedium.copyWith(
                    color: context.isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSSpacing.xxs),
                Text(
                  entry.priorityInsights.isNotEmpty
                      ? entry.priorityInsights.first.message
                      : '분석 결과가 기록되어 있어요',
                  style: context.labelSmall.copyWith(
                    color: context.isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 화살표
          Icon(
            Icons.chevron_right,
            color: context.isDark
                ? DSColors.textSecondaryDark
                : DSColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// 엔트리 없는 날짜 메시지
  Widget _buildNoEntryMessage(String dateStr) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DSColors.border.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.face_outlined,
            color: context.isDark
                ? DSColors.textSecondaryDark
                : DSColors.textSecondary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: context.labelMedium.copyWith(
                  color: context.isDark
                      ? DSColors.textPrimaryDark
                      : DSColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                '이 날은 기록이 없어요',
                style: context.labelSmall.copyWith(
                  color: context.isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 비교 모드 안내
  Widget _buildCompareModeHint() {
    if (!widget.compareMode) return const SizedBox.shrink();

    String message;
    if (_selectedDay == null) {
      message = '첫 번째 날짜를 선택해 주세요';
    } else if (_compareDate == null) {
      message = '비교할 두 번째 날짜를 선택해 주세요';
    } else {
      message = '두 날짜가 선택되었어요';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DSColors.accentSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: DSColors.accentSecondary,
            size: 18,
          ),
          const SizedBox(width: DSSpacing.sm),
          Text(
            message,
            style: context.labelSmall.copyWith(
              color: DSColors.accentSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 요약
  Widget _buildStatsSummary() {
    if (widget.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    // 이번 달 기록 수
    final now = DateTime.now();
    final thisMonthEntries = widget.entries
        .where((e) =>
            e.createdAt.year == now.year && e.createdAt.month == now.month)
        .length;

    // 연속 기록 일수 계산
    int streakDays = 0;
    final sortedEntries = List<FaceReadingHistoryEntry>.from(widget.entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (sortedEntries.isNotEmpty) {
      DateTime checkDate = _normalizeDate(DateTime.now());
      for (final entry in sortedEntries) {
        final entryDate = _normalizeDate(entry.createdAt);
        if (_isSameDay(entryDate, checkDate) ||
            _isSameDay(
                entryDate, checkDate.subtract(const Duration(days: 1)))) {
          streakDays++;
          checkDate = entryDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.accent.withValues(alpha: 0.08),
            DSColors.accentSecondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('이번 달', '$thisMonthEntries회', Icons.calendar_today),
          Container(
            width: 1,
            height: 32,
            color: context.isDark ? DSColors.borderDark : DSColors.border,
          ),
          _buildStatItem('연속 기록', '$streakDays일', Icons.local_fire_department),
          Container(
            width: 1,
            height: 32,
            color: context.isDark ? DSColors.borderDark : DSColors.border,
          ),
          _buildStatItem('총 기록', '${widget.entries.length}회', Icons.history),
        ],
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: DSColors.accent,
          size: 18,
        ),
        const SizedBox(height: DSSpacing.xs),
        Text(
          value,
          style: context.labelMedium.copyWith(
            color: context.isDark
                ? DSColors.textPrimaryDark
                : DSColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: context.isDark
                ? DSColors.textSecondaryDark
                : DSColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// 점수에 따른 색상 반환
  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.accentSecondary;
  }
}
