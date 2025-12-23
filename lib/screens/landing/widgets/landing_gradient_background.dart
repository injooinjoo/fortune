import 'package:flutter/material.dart';

/// Korean Traditional Hanji (한지) style gradient background for landing page
/// Design Philosophy: "Ink on Hanji Paper" (한지 위의 먹)
class LandingGradientBackground extends StatelessWidget {
  const LandingGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            // Dark Mode: 벼루(砚) & 먹(墨) inspired - Inkstone aesthetic
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E), // 깊은 현무색 (Deep charcoal)
                  Color(0xFF16182A), // 먹색 (Ink black)
                  Color(0xFF1D1D2B), // 벼루색 (Inkstone)
                  Color(0xFF141420), // 심야색 (Midnight)
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              )
            // Light Mode: 한지(韓紙) & 미색(米色) - Hanji paper aesthetic
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8F4EC), // 순백색 한지 (Pure hanji)
                  Color(0xFFF5F0E6), // 기본 한지색 (Hanji)
                  Color(0xFFF2EBE0), // 담황색 (Light tan)
                  Color(0xFFEDE5D5), // 미색 (Cream/Ivory)
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
      ),
    );
  }
}
