import 'package:flutter/material.dart';

class DailyFortuneScreen extends StatelessWidget {
  const DailyFortuneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 운세'),
      ))
      body: const Center(
        child: Text('일일 운세 화면'))
      )
    );
  }
}