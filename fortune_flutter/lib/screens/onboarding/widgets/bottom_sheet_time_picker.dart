import 'package:flutter/material.dart';

class BottomSheetTimePicker extends StatelessWidget {
  final String? selectedTime;
  final Function(String?) onTimeSelected;
  
  const BottomSheetTimePicker({
    super.key,
    this.selectedTime,
    required this.onTimeSelected,
  });

  static final List<Map<String, String>> timeOptions = [
    {'value': '자시', 'time': '23:00 - 01:00'},
    {'value': '축시', 'time': '01:00 - 03:00'},
    {'value': '인시', 'time': '03:00 - 05:00'},
    {'value': '묘시', 'time': '05:00 - 07:00'},
    {'value': '진시', 'time': '07:00 - 09:00'},
    {'value': '사시', 'time': '09:00 - 11:00'},
    {'value': '오시', 'time': '11:00 - 13:00'},
    {'value': '미시', 'time': '13:00 - 15:00'},
    {'value': '신시', 'time': '15:00 - 17:00'},
    {'value': '유시', 'time': '17:00 - 19:00'},
    {'value': '술시', 'time': '19:00 - 21:00'},
    {'value': '해시', 'time': '21:00 - 23:00'},
    {'value': '모름', 'time': '시간을 모르겠어요'},
  ];

  static Future<String?> show(BuildContext context, {String? initialTime}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetTimePicker(
        selectedTime: initialTime,
        onTimeSelected: (time) {
          Navigator.of(context).pop(time);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '태어난 시간',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Time options
          Expanded(
            child: ListView.builder(
              itemCount: timeOptions.length,
              itemBuilder: (context, index) {
                final option = timeOptions[index];
                final isSelected = selectedTime == option['value'];
                
                return InkWell(
                  onTap: () => onTimeSelected(option['value']),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['value']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                              ),
                            ),
                            if (option['value'] != '모름')
                              Text(
                                option['time']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}