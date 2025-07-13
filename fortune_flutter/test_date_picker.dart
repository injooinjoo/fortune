import 'package:flutter/material.dart';
import 'lib/shared/components/custom_calendar_date_picker.dart';

void main() {
  runApp(MaterialApp(
    home: TestDatePicker(),
  ));
}

class TestDatePicker extends StatefulWidget {
  @override
  _TestDatePickerState createState() => _TestDatePickerState();
}

class _TestDatePickerState extends State<TestDatePicker> {
  DateTime selectedDate = DateTime(1999, 12, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Date Picker Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Date: ${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: CustomCalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      onConfirm: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              child: Text('Open Date Picker'),
            ),
          ],
        ),
      ),
    );
  }
}