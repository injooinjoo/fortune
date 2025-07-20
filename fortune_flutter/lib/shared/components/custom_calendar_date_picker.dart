import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomCalendarDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateChanged;
  final Function()? onConfirm;

  const CustomCalendarDatePicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.onConfirm,
  }) : super(key: key);

  @override
  State<CustomCalendarDatePicker> createState() => _CustomCalendarDatePickerState();
}

class _CustomCalendarDatePickerState extends State<CustomCalendarDatePicker> {
  late DateTime _selectedDate;
  late DateTime _viewingDate;
  late PageController _pageController;
  late FixedExtentScrollController _yearScrollController;
  late FixedExtentScrollController _monthScrollController;
  
  final List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> _koreanMonths = [
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewingDate = widget.initialDate;
    
    // Calculate initial page
    int initialPage = _calculatePageIndex(_viewingDate);
    _pageController = PageController(initialPage: initialPage);
    
    // Initialize scroll controllers
    int yearIndex = _viewingDate.year - widget.firstDate.year;
    int monthIndex = _viewingDate.month - 1;
    _yearScrollController = FixedExtentScrollController(initialItem: yearIndex);
    _monthScrollController = FixedExtentScrollController(initialItem: monthIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _yearScrollController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  int _calculatePageIndex(DateTime date) {
    int yearDiff = date.year - widget.firstDate.year;
    int monthDiff = date.month - widget.firstDate.month;
    return yearDiff * 12 + monthDiff;
  }

  DateTime _getDateFromPageIndex(int index) {
    int totalMonths = widget.firstDate.month + index;
    int year = widget.firstDate.year + (totalMonths - 1) ~/ 12;
    int month = ((totalMonths - 1) % 12) + 1;
    return DateTime(year, month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Month/Year selector header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, size: 28),
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              GestureDetector(
                onTap: _showMonthYearPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_viewingDate.year}년 ${_koreanMonths[_viewingDate.month - 1]}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 28),
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
        
        // Week days header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays.map((day) => Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            )).toList(),
          ),
        ),
        
        SizedBox(height: 8),
        
        // Calendar grid
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _viewingDate = _getDateFromPageIndex(index);
              });
            },
            itemBuilder: (context, index) {
              DateTime monthDate = _getDateFromPageIndex(index);
              return _buildMonthView(monthDate);
            },
          ),
        ),
        
        // Bottom date display with confirm button
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Text(
                  '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (widget.onConfirm != null) ...[
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: widget.onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView(DateTime monthDate) {
    // Calculate first day of month and days in month
    DateTime firstDay = DateTime(monthDate.year, monthDate.month, 1);
    int daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    int startingWeekday = firstDay.weekday % 7; // Convert to 0-6 (Sun-Sat)
    
    // Calculate previous month's days
    DateTime prevMonth = DateTime(monthDate.year, monthDate.month - 1);
    int daysInPrevMonth = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;
    
    List<Widget> dayWidgets = [];
    
    // Add previous month's trailing days
    for (int i = startingWeekday - 1; i >= 0; i--) {
      int day = daysInPrevMonth - i;
      dayWidgets.add(_buildDayCell(
        day: day,
        isCurrentMonth: false,
        date: DateTime(prevMonth.year, prevMonth.month, day),
      ));
    }
    
    // Add current month's days
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(monthDate.year, monthDate.month, day);
      dayWidgets.add(_buildDayCell(
        day: day,
        isCurrentMonth: true,
        date: date,
      ));
    }
    
    // Add next month's leading days
    int remainingCells = 42 - dayWidgets.length; // 6 weeks * 7 days
    for (int day = 1; day <= remainingCells; day++) {
      dayWidgets.add(_buildDayCell(
        day: day,
        isCurrentMonth: false,
        date: DateTime(monthDate.year, monthDate.month + 1, day),
      ));
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: dayWidgets,
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isCurrentMonth,
    required DateTime date,
  }) {
    bool isSelected = _isSameDay(date, _selectedDate);
    bool isToday = _isSameDay(date, DateTime.now());
    bool isDisabled = date.isAfter(widget.lastDate) || date.isBefore(widget.firstDate);
    
    return GestureDetector(
      onTap: isDisabled ? null : () {
        setState(() {
          _selectedDate = date;
          _viewingDate = date;
        });
        widget.onDateChanged(date);
      },
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.black : Colors.transparent,
          border: isSelected 
            ? Border.all(color: Colors.black, width: 2)
            : isToday 
              ? Border.all(color: Colors.grey[400]!, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
              color: isDisabled 
                ? Colors.grey[300]
                : !isCurrentMonth 
                  ? Colors.grey[400]
                  : isSelected 
                    ? Colors.white
                    : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  void _showMonthYearPicker() {
    // Reset scroll controllers to current viewing date
    final int initialYearIndex = _viewingDate.year - widget.firstDate.year;
    final int initialMonthIndex = _viewingDate.month - 1;
    _yearScrollController.jumpToItem(initialYearIndex);
    _monthScrollController.jumpToItem(initialMonthIndex);
    
    // Track selected values
    int tempSelectedYear = _viewingDate.year;
    int tempSelectedMonth = _viewingDate.month;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('취소', style: TextStyle(fontSize: 16)),
                  ),
                  Text(
                    '날짜 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Update viewing date with selected year and month
                      DateTime newViewingDate = DateTime(tempSelectedYear, tempSelectedMonth);
                      
                      setState(() {
                        _viewingDate = newViewingDate;
                      });
                      
                      // Close the modal first
                      Navigator.pop(context);
                      
                      // Then animate to the selected page after a brief delay to ensure modal is closed
                      Future.delayed(Duration(milliseconds: 100), () {
                        int pageIndex = _calculatePageIndex(newViewingDate);
                        _pageController.animateToPage(
                          pageIndex,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            // Year and Month pickers
            Expanded(
              child: Stack(
                children: [
                  // Center highlight overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          color: Colors.grey[50],
                        ),
                      ),
                    ),
                  ),
                  // Pickers row
                  Row(
                    children: [
                      // Year picker
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _yearScrollController,
                          itemExtent: 50,
                          physics: FixedExtentScrollPhysics(),
                          useMagnifier: true,
                          magnification: 1.2,
                          diameterRatio: 1.5,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              tempSelectedYear = widget.firstDate.year + index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0) return null;
                              int year = widget.firstDate.year + index;
                              if (year > widget.lastDate.year) return null;
                              
                              int? selectedIndex;
                              try {
                                selectedIndex = _yearScrollController.selectedItem;
                              } catch (e) {
                                selectedIndex = initialYearIndex;
                              }
                              bool isSelected = index == selectedIndex;
                              
                              return Center(
                                child: Text(
                                  '${year}년',
                                  style: TextStyle(
                                    fontSize: isSelected ? 20 : 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Month picker
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _monthScrollController,
                          itemExtent: 50,
                          physics: FixedExtentScrollPhysics(),
                          useMagnifier: true,
                          magnification: 1.2,
                          diameterRatio: 1.5,
                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              tempSelectedMonth = index + 1;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index >= 12) return null;
                              
                              int? selectedIndex;
                              try {
                                selectedIndex = _monthScrollController.selectedItem;
                              } catch (e) {
                                selectedIndex = initialMonthIndex;
                              }
                              bool isSelected = index == selectedIndex;
                              
                              return Center(
                                child: Text(
                                  _koreanMonths[index],
                                  style: TextStyle(
                                    fontSize: isSelected ? 20 : 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? Colors.black : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                            childCount: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}