import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_assets.dart';

/// 인포그래픽 컨테이너 위젯
///
/// Instagram 공유에 최적화된 4:5 비율의 컨테이너입니다.
/// 스크린샷/공유 시 개인정보 숨김 기능을 지원합니다.
class InfographicContainer extends StatelessWidget {
  const InfographicContainer({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showWatermark = true,
    this.isShareMode = false,
    this.backgroundColor,
    this.gradient,
    this.padding,
    this.fortuneType,
    this.showCornerDecorations = false,
    this.showBackgroundPattern = true,
  });

  /// 인포그래픽 내용
  final Widget child;

  /// 상단 제목 (선택)
  final String? title;

  /// 부제목/날짜 (선택)
  final String? subtitle;

  /// 워터마크 표시 여부
  final bool showWatermark;

  /// 공유 모드 (개인정보 숨김)
  final bool isShareMode;

  /// 배경색 (선택)
  final Color? backgroundColor;

  /// 그라데이션 배경 (선택, backgroundColor보다 우선)
  final Gradient? gradient;

  /// 커스텀 패딩
  final EdgeInsetsGeometry? padding;

  /// 운세 타입 (배경 패턴 선택용)
  final String? fortuneType;

  /// 코너 장식 표시 여부
  final bool showCornerDecorations;

  /// 배경 패턴 표시 여부
  final bool showBackgroundPattern;

  /// Instagram 최적 비율 (4:5)
  static const double aspectRatio = 4 / 5;

  /// 표준 높이 (iPhone 기준)
  static const double standardHeight = 468.75;

  @override
  Widget build(BuildContext context) {
    final bgPattern = fortuneType != null
        ? InfographicAssets.getBackgroundForType(fortuneType!)
        : InfographicAssets.bgPatternDaily;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: gradient == null
              ? (backgroundColor ?? context.colors.surface)
              : null,
          gradient: gradient,
          borderRadius: DSRadius.lgBorder,
          boxShadow: context.shadows.sm,
        ),
        child: ClipRRect(
          borderRadius: DSRadius.lgBorder,
          child: Stack(
            children: [
              // 배경 패턴
              if (showBackgroundPattern)
                Positioned.fill(
                  child: Image.asset(
                    bgPattern,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // 코너 장식 - 좌상단
              if (showCornerDecorations)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    InfographicAssets.decoCornerOrnament,
                    width: 80,
                    height: 80,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // 코너 장식 - 우하단 (180도 회전)
              if (showCornerDecorations)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Transform.rotate(
                    angle: 3.14159, // 180 degrees
                    child: Image.asset(
                      InfographicAssets.decoCornerOrnament,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),

              // 메인 콘텐츠
              Positioned.fill(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(DSSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 메인 콘텐츠 - 남은 공간을 채우고 스크롤 가능
                      // 헤더(제목)는 결과 카드 상단에 표시되므로 인포그래픽 내부에는 표시하지 않음
                      Expanded(
                        child: ClipRect(
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 워터마크
              if (showWatermark)
                Positioned(
                  right: DSSpacing.sm,
                  bottom: DSSpacing.sm,
                  child: _AppWatermark(isShareMode: isShareMode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 앱 워터마크
class _AppWatermark extends StatelessWidget {
  const _AppWatermark({
    this.isShareMode = false,
  });

  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.1),
        borderRadius: DSRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Fortune',
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 인포그래픽 공유 데이터
class InfographicShareData {
  const InfographicShareData({
    required this.fortuneType,
    required this.date,
    this.userName,
    this.score,
    this.summary,
  });

  final String fortuneType;
  final DateTime date;
  final String? userName;
  final int? score;
  final String? summary;
}
