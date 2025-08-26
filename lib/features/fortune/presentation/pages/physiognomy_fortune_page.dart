import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'physiognomy_camera_input_page.dart';

/// 관상 운세 메인 엔트리 페이지 (새로운 플로우)
class PhysiognomyFortunePage extends ConsumerWidget {
  const PhysiognomyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 바로 새로운 카메라 입력 페이지로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PhysiognomyCameraInputPage(),
        ),
      );
    });
    
    // 로딩 화면 표시
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '관상 분석 페이지로 이동 중...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}