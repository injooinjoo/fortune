import 'package:flutter/material.dart';
import '../../core/theme/fortune_design_system.dart';

/// 앱 전체에 '한지(Hanji)' 질감의 배경을 일관되게 적용하는 Scaffold 위젯입니다.
class HanjiScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;

  const HanjiScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      // 배경은 Stack으로 처리하여 이미지 질감을 살립니다.
      body: Stack(
        children: [
          // 1. 기본 색상 배경
          Container(
            color: backgroundColor ?? FortuneDesignSystem.hanjiBeige,
          ),

          // 2. 한지 텍스처 이미지 (Asset 준비 전까지는 오류 방지를 위해 투명하게 처리하거나 로딩 스킵)
          Positioned.fill(
            child: Opacity(
              opacity: 0.6, // 질감을 은은하게 조절
              child: Image.asset(
                'assets/textures/bg_hanji_base.png',
                repeat: ImageRepeat.repeat, // 타일링 적용
                errorBuilder: (context, error, stackTrace) {
                  // 이미지가 아직 없는 경우 빈 컨테이너 반환
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // 3. 실제 컨텐츠
          SafeArea(
            child: body,
          ),
        ],
      ),
    );
  }
}
