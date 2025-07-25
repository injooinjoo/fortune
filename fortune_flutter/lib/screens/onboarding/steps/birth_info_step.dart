import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/custom_calendar_picker.dart';
import '../widgets/bottom_sheet_time_picker.dart';

class BirthInfoStep extends StatefulWidget {
  final Function(DateTime, String?) onBirthInfoChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const BirthInfoStep({
    super.key,
    required this.onBirthInfoChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BirthInfoStep> createState() => _BirthInfoStepState();
}

class _BirthInfoStepState extends State<BirthInfoStep> {
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _hasSelectedDate = false;

  void _selectDate() async {
    final date = await CustomCalendarPicker.show(
      context,
      initialDate: _selectedDate ?? DateTime(1980, 1, 1),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _hasSelectedDate = true;
      });
      
      // Automatically show time picker after date selection
      await Future.delayed(Duration(milliseconds: 300));
      _selectTime();
    }
  }

  void _selectTime() async {
    final time = await BottomSheetTimePicker.show(
      context,
      initialTime: _selectedTime,
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
      
      // Update parent with both values
      if (_selectedDate != null) {
        widget.onBirthInfoChanged(_selectedDate!, _selectedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack,
              icon: Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
            ),
          ),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '생일이 언제인가요?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).shimmer(
                  duration: 1200.ms,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '정확한 운세를 위해 필요해요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
                const SizedBox(height: 48),
                
                // Birth date selector
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedDate != null ? Theme.of(context).primaryColor : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? DateFormat('yyyy년 M월 d일').format(_selectedDate!)
                              : '생년월일을 선택하세요',
                          style: TextStyle(
                            fontSize: 18,
                            color: _selectedDate != null ? Colors.black : Colors.grey[400],
                            fontWeight: _selectedDate != null ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: _selectedDate != null ? Theme.of(context).primaryColor : Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 600.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  curve: Curves.easeOutQuart,
                ),
                
                const SizedBox(height: 32),
                
                // Birth time selector (only show after date is selected)
                if (_hasSelectedDate)
                  GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTime != null ? Theme.of(context).primaryColor : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime ?? '태어난 시간을 선택하세요',
                            style: TextStyle(
                              fontSize: 18,
                              color: _selectedTime != null ? Colors.black : Colors.grey[400],
                              fontWeight: _selectedTime != null ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            color: _selectedTime != null ? Theme.of(context).primaryColor : Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    curve: Curves.easeOutQuart,
                  ),
                
                const SizedBox(height: 80),
                
                // Next button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_selectedDate != null && _selectedTime != null) ? widget.onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate(delay: 700.ms).fadeIn(duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}