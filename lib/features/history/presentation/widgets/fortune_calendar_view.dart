import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/fortune_history.dart';

/// 운세 히스토리 캘린더 뷰
class FortuneCalendarView extends StatefulWidget {
  final List<FortuneHistory> history;
  final Function(FortuneHistory)? onDateTap;

  const FortuneCalendarView({
    super.key,
    required this.history,
    this.onDateTap,
  });

  @override
  State<FortuneCalendarView> createState() => _FortuneCalendarViewState();
}

class _FortuneCalendarViewState extends State<FortuneCalendarView> {
  late DateTime _currentMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          // 월 네비게이션
          _buildMonthNavigation(),
          const SizedBox(height: DSSpacing.lg),
          // 요일 헤더
          _buildWeekdayHeaders(),
          const SizedBox(height: DSSpacing.sm),
          // 캘린더 그리드
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: context.colors.textPrimary),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          DateFormat('yyyy년 MM월').format(_currentMonth),
          style: context.heading1.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: context.colors.textPrimary),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: weekdays.map((weekday) {
        return Expanded(
          child: Text(
            weekday,
            style: context.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    
    final days = <Widget>[];
    
    // 이전 달 빈 공간
    for (int i = 0; i < firstWeekday; i++) {
      days.add(Container());
    }
    
    // 이번 달 날짜들
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final fortuneForDate = _getFortuneForDate(date);
      
      days.add(_buildCalendarDay(date, fortuneForDate));
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: days,
    );
  }

  Widget _buildCalendarDay(DateTime date, FortuneHistory? fortune) {
    final isToday = _isToday(date);
    final hasFortune = fortune != null;
    
    Color backgroundColor = Colors.white.withValues(alpha: 0.0);
    Color textColor = context.colors.textPrimary;
    
    if (isToday) {
      backgroundColor = context.colors.accent.withValues(alpha: 0.1);
      textColor = context.colors.accent;
    }
    
    if (hasFortune) {
      final score = fortune.summary['score'] as int? ?? 0;
      backgroundColor = _getScoreColor(score).withValues(alpha: 0.2);
      textColor = _getScoreColor(score);
    }
    
    return GestureDetector(
      onTap: hasFortune && widget.onDateTap != null 
        ? () => widget.onDateTap!(fortune)
        : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(DSRadius.smd),
          border: isToday ? Border.all(
            color: context.colors.accent,
            width: 1.5,
          ) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: context.heading3.copyWith(
                color: textColor,
                fontWeight: isToday || hasFortune 
                  ? FontWeight.w700 
                  : FontWeight.w500,
              ),
            ),
            if (hasFortune) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  FortuneHistory? _getFortuneForDate(DateTime date) {
    try {
      return widget.history.firstWhere((fortune) {
        return fortune.createdAt.year == date.year &&
               fortune.createdAt.month == date.month &&
               fortune.createdAt.day == date.day;
      });
    } catch (e) {
      return null;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 70) return context.colors.accent;
    if (score >= 60) return DSColors.warning;
    return DSColors.error;
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
        1,
      );
    });
  }
}
