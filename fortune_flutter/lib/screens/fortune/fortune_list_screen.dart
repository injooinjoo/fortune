import 'package:flutter/material.dart';

class FortuneListScreen extends StatelessWidget {
  const FortuneListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운세 목록'),
      ))
      body: const Center(
        child: Text('운세 목록 화면'))
      )
    );
  }
}