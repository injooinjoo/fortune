import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EnhancedDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final Map<DateTime, double>? luckyScores; // 0.0 to 1.0
  final List<DateTime>? auspiciousDays; // 손없는날
  final Map<DateTime, String>? holidayMap;
  
  const EnhancedDatePicker({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    this.luckyScores,
    this.auspiciousDays,
    this.holidayMap,
  }) : super(key: key);

  @override
  State<EnhancedDatePicker> createState() => _EnhancedDatePickerState();
}

class _EnhancedDatePickerState extends State<EnhancedDatePicker> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  Color _getDayColor(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    // Check if it's an auspicious day (손없는날)
    if (widget.auspiciousDays?.any((d) => 
        d.year == normalizedDay.year && 
        d.month == normalizedDay.month && 
        d.day == normalizedDay.day) ?? false) {
      return Colors.amber.shade400;
    }
    
    // Check lucky score
    final score = widget.luckyScores?[normalizedDay];
    if (score != null) {
      if (score >= 0.8) return Colors.green.shade400;
      if (score >= 0.6) return Colors.blue.shade400;
      if (score >= 0.4) return Colors.orange.shade400;
      return Colors.red.shade400;
    }
    
    return Colors.grey.shade300;
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '날짜 길흉 안내',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(Colors.amber.shade400, '손없는날'),
              _buildLegendItem(Colors.green.shade400, '매우 길한 날'),
              _buildLegendItem(Colors.blue.shade400, '길한 날'),
              _buildLegendItem(Colors.orange.shade400, '보통'),
              _buildLegendItem(Colors.red.shade400, '피해야 할 날'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDayDetails(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final isAuspicious = widget.auspiciousDays?.any((d) => 
        d.year == normalizedDay.year && 
        d.month == normalizedDay.month && 
        d.day == normalizedDay.day) ?? false;
    final luckyScore = widget.luckyScores?[normalizedDay];
    final holiday = widget.holidayMap?[normalizedDay];
    
    if (!isAuspicious && luckyScore == null && holiday == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('yyyy년 MM월 dd일').format(day),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (isAuspicious) ...[
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                const SizedBox(width: 4),
                const Text(
                  '손없는날 - 이사하기 매우 좋은 날',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (luckyScore != null) ...[
            Row(
              children: [
                Icon(
                  luckyScore >= 0.6 ? Icons.thumb_up : Icons.thumb_down,
                  color: _getDayColor(day),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '길흉점수: ${(luckyScore * 100).toInt()}점',
                  style: TextStyle(
                    color: _getDayColor(day),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (holiday != null) ...[
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  holiday,
                  style: const TextStyle(color: Colors.red),
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
    return Column(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDateSelected(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: Colors.red),
                holidayTextStyle: const TextStyle(color: Colors.red),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final isAuspicious = widget.auspiciousDays?.any((d) => 
                      d.year == normalizedDay.year && 
                      d.month == normalizedDay.month && 
                      d.day == normalizedDay.day) ?? false;
                  
                  if (isAuspicious) {
                    return Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                defaultBuilder: (context, day, focusedDay) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final color = _getDayColor(normalizedDay);
                  final isWeekend = day.weekday == DateTime.saturday || 
                                   day.weekday == DateTime.sunday;
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isWeekend ? Colors.red : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        if (_selectedDay != null) _buildDayDetails(_selectedDay!),
        _buildLegend(),
      ],
    );
  }
}