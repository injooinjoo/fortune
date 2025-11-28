import 'package:flutter/material.dart';

/// GPT-5 style gradient background for landing page
class LandingGradientBackground extends StatelessWidget {
  const LandingGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a1a2e), // 진한 남색
                  Color(0xFF16213e), // 어두운 파란색
                  Color(0xFF0f1624), // 거의 검정
                  Color(0xFF1a1a2e), // 진한 남색
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5E6FF), // 연한 보라
                  Color(0xFFFFE6F0), // 연한 핑크
                  Color(0xFFFFEFE6), // 연한 살구색
                  Color(0xFFFFF9E6), // 연한 노란색
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
      ),
    );
  }
}
