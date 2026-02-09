import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_container.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/privacy_shield.dart';

/// 차트/분석 중심 인포그래픽 템플릿 (템플릿 B)
///
/// 8개 운세 타입에 사용:
/// - traditional_saju (사주 분석)
/// - mbti (MBTI 운세)
/// - biorhythm (바이오리듬)
/// - personality-dna (성격 DNA)
/// - compatibility (궁합 분석)
/// - talent (재능 분석)
/// - investment (재물 운세)
/// - sports_game (경기 분석)
///
/// 레이아웃:
/// - 상단: 제목 + 주요 정보
/// - 중간: 차트/분석 시각화
/// - 하단: 요약/해석
class ChartTemplate extends StatelessWidget {
  const ChartTemplate({
    super.key,
    required this.title,
    required this.chartWidget,
    this.subtitle,
    this.headerWidget,
    this.footerWidget,
    this.showWatermark = true,
    this.isShareMode = false,
    this.backgroundColor,
  });

  /// 제목
  final String title;

  /// 부제목 (선택)
  final String? subtitle;

  /// 헤더 위젯 (선택)
  final Widget? headerWidget;

  /// 차트 위젯 (필수)
  final Widget chartWidget;

  /// 푸터 위젯 (선택)
  final Widget? footerWidget;

  /// 워터마크 표시 여부
  final bool showWatermark;

  /// 공유 모드
  final bool isShareMode;

  /// 배경색 (선택)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return PrivacyModeProvider(
      isShareMode: isShareMode,
      child: InfographicContainer(
        title: title,
        subtitle: subtitle,
        showWatermark: showWatermark,
        isShareMode: isShareMode,
        backgroundColor: backgroundColor,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 헤더 위젯
        if (headerWidget != null) ...[
          headerWidget!,
          const SizedBox(height: DSSpacing.md),
        ],

        // 메인 차트
        chartWidget,

        // 푸터 위젯
        if (footerWidget != null) ...[
          const SizedBox(height: DSSpacing.md),
          footerWidget!,
        ],
      ],
    );
  }
}
