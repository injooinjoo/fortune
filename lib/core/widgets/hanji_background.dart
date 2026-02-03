import 'package:flutter/material.dart';
import '../design_system/theme/ds_extensions.dart';

/// 한지 텍스처 배경 위젯
///
/// 앱 전체에서 은은한 한지 질감 배경을 제공합니다.
/// 라이트/다크 모드에 따라 자동으로 적절한 opacity를 적용합니다.
class HanjiBackground extends StatelessWidget {
  /// 배경 위에 표시할 콘텐츠
  final Widget child;

  /// 텍스처 불투명도 (기본값: 라이트 0.08, 다크 0.04)
  final double? opacity;

  /// 배경색 (기본값: 테마의 scaffoldBackgroundColor)
  final Color? backgroundColor;

  /// 텍스처 사용 여부 (false면 일반 배경만 표시)
  final bool showTexture;

  const HanjiBackground({
    super.key,
    required this.child,
    this.opacity,
    this.backgroundColor,
    this.showTexture = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final defaultOpacity = isDark ? 0.04 : 0.08;
    final effectiveOpacity = opacity ?? defaultOpacity;
    final bgColor = backgroundColor ?? colors.background;

    if (!showTexture) {
      return Container(
        color: bgColor,
        child: child,
      );
    }

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          // 한지 텍스처 레이어
          Positioned.fill(
            child: Opacity(
              opacity: effectiveOpacity,
              child: Image.asset(
                'assets/images/hanji_texture.png',
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
                color: isDark ? Colors.white : null,
                colorBlendMode: isDark ? BlendMode.overlay : null,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          // 콘텐츠 레이어
          child,
        ],
      ),
    );
  }
}

/// Scaffold에 한지 배경을 적용하는 확장
///
/// 사용 예시:
/// ```dart
/// HanjiScaffold(
///   appBar: AppBar(title: Text('운세')),
///   body: YourContent(),
/// )
/// ```
class HanjiScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final double? textureOpacity;
  final bool showTexture;

  const HanjiScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.textureOpacity,
    this.showTexture = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final defaultOpacity = isDark ? 0.04 : 0.08;
    final effectiveOpacity = textureOpacity ?? defaultOpacity;
    final bgColor = colors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: appBar,
      body: showTexture && body != null
          ? Stack(
              children: [
                // 한지 텍스처 레이어
                Positioned.fill(
                  child: Opacity(
                    opacity: effectiveOpacity,
                    child: Image.asset(
                      'assets/images/hanji_texture.png',
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                      color: isDark ? Colors.white : null,
                      colorBlendMode: isDark ? BlendMode.overlay : null,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                // 바디 콘텐츠
                body!,
              ],
            )
          : body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
