import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/infographic_container.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/category_bar_chart.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/versus_bar.dart';
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

/// 사주 분석용 템플릿
class SajuChartTemplate extends StatelessWidget {
  const SajuChartTemplate({
    super.key,
    required this.pillars,
    required this.elements,
    this.geukguk,
    this.yongshin,
    this.interpretation,
    this.date,
    this.isShareMode = false,
  });

  /// 4주 (년월일시)
  final List<SajuPillar> pillars;

  /// 오행 분포
  final Map<String, int> elements;

  /// 격국
  final String? geukguk;

  /// 용신
  final String? yongshin;

  /// 해석
  final String? interpretation;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '나의 사주 분석',
      isShareMode: isShareMode,
      headerWidget: _buildPillars(context),
      chartWidget: _buildElementsChart(context),
      footerWidget: _buildInterpretation(context),
    );
  }

  Widget _buildPillars(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < pillars.length && i < 4; i++)
          _SajuPillarWidget(
            pillar: pillars[i],
            label: ['年', '月', '日', '時'][i],
          ),
      ],
    );
  }

  Widget _buildElementsChart(BuildContext context) {
    final elementColors = {
      '목': const Color(0xFF4CAF50),
      '화': const Color(0xFFE53935),
      '토': const Color(0xFFFFB300),
      '금': const Color(0xFF9E9E9E),
      '수': const Color(0xFF2196F3),
    };

    final categories = elements.entries.map((e) {
      return CategoryData(
        label: e.key,
        value: e.value,
        color: elementColors[e.key],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: CategoryBarChart(
        categories: categories,
        maxValue: 100,
        barHeight: 10,
        showValues: true,
        showIcons: false,
      ),
    );
  }

  Widget _buildInterpretation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 격국 + 용신
          if (geukguk != null || yongshin != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (geukguk != null) ...[
                  Text(
                    '격국: $geukguk',
                    style: context.typography.labelMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                if (geukguk != null && yongshin != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
                    child: Text(
                      '·',
                      style: TextStyle(color: context.colors.textTertiary),
                    ),
                  ),
                if (yongshin != null) ...[
                  Text(
                    '용신: $yongshin',
                    style: context.typography.labelMedium.copyWith(
                      color: context.colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),

          // 해석
          if (interpretation != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '"$interpretation"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 사주 기둥 데이터
class SajuPillar {
  const SajuPillar({
    required this.heavenlyStem,
    required this.earthlyBranch,
    this.heavenlyStemElement,
    this.earthlyBranchElement,
  });

  /// 천간
  final String heavenlyStem;

  /// 지지
  final String earthlyBranch;

  /// 천간 오행
  final String? heavenlyStemElement;

  /// 지지 오행
  final String? earthlyBranchElement;
}

class _SajuPillarWidget extends StatelessWidget {
  const _SajuPillarWidget({
    required this.pillar,
    required this.label,
  });

  final SajuPillar pillar;
  final String label;

  Color _getElementColor(String? element) {
    switch (element) {
      case '목':
        return const Color(0xFF4CAF50);
      case '화':
        return const Color(0xFFE53935);
      case '토':
        return const Color(0xFFFFB300);
      case '금':
        return const Color(0xFF9E9E9E);
      case '수':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 라벨
        Text(
          label,
          style: context.typography.labelSmall.copyWith(
            color: context.colors.textTertiary,
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        // 천간
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getElementColor(pillar.heavenlyStemElement).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getElementColor(pillar.heavenlyStemElement),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              pillar.heavenlyStem,
              style: context.typography.headingMedium.copyWith(
                color: _getElementColor(pillar.heavenlyStemElement),
              ),
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        // 지지
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getElementColor(pillar.earthlyBranchElement).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getElementColor(pillar.earthlyBranchElement),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              pillar.earthlyBranch,
              style: context.typography.headingMedium.copyWith(
                color: _getElementColor(pillar.earthlyBranchElement),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// MBTI 운세용 템플릿
class MbtiChartTemplate extends StatelessWidget {
  const MbtiChartTemplate({
    super.key,
    required this.mbtiType,
    required this.dimensions,
    this.todayMessage,
    this.warning,
    this.date,
    this.isShareMode = false,
  });

  /// MBTI 타입 (예: ENFP)
  final String mbtiType;

  /// 4차원 점수 (E-I, N-S, T-F, J-P)
  final List<MbtiDimension> dimensions;

  /// 오늘 메시지
  final String? todayMessage;

  /// 경고 메시지
  final String? warning;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '$mbtiType의 오늘',
      isShareMode: isShareMode,
      chartWidget: _buildDimensionsChart(context),
      footerWidget: _buildMessages(context),
    );
  }

  Widget _buildDimensionsChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: dimensions.map((dim) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: _MbtiDimensionBar(dimension: dim),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessages(BuildContext context) {
    if (todayMessage == null && warning == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 오늘 메시지
        if (todayMessage != null)
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.accent.withOpacity(0.1),
              borderRadius: DSRadius.mdBorder,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Text(
                    todayMessage!,
                    style: context.typography.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 경고
        if (warning != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.warning.withOpacity(0.1),
              borderRadius: DSRadius.smBorder,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: context.colors.warning,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    warning!,
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// MBTI 차원 데이터
class MbtiDimension {
  const MbtiDimension({
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
  });

  /// 왼쪽 라벨 (예: E)
  final String leftLabel;

  /// 오른쪽 라벨 (예: I)
  final String rightLabel;

  /// 값 (0-100, 50이 중간)
  final int value;
}

class _MbtiDimensionBar extends StatelessWidget {
  const _MbtiDimensionBar({
    required this.dimension,
  });

  final MbtiDimension dimension;

  @override
  Widget build(BuildContext context) {
    final isLeft = dimension.value >= 50;
    final progress = isLeft
        ? (dimension.value - 50) / 50
        : (50 - dimension.value) / 50;

    return Row(
      children: [
        // 왼쪽 라벨
        SizedBox(
          width: 24,
          child: Text(
            dimension.leftLabel,
            style: context.typography.labelMedium.copyWith(
              color: isLeft
                  ? context.colors.accent
                  : context.colors.textTertiary,
              fontWeight: isLeft ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),

        // 바
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // 중앙 표시
                Center(
                  child: Container(
                    width: 2,
                    height: 8,
                    color: context.colors.textTertiary.withOpacity(0.5),
                  ),
                ),
                // 진행 바
                Positioned(
                  left: isLeft ? null : 0,
                  right: isLeft ? 0 : null,
                  top: 0,
                  bottom: 0,
                  child: FractionallySizedBox(
                    widthFactor: progress * 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.accent,
                        borderRadius: BorderRadius.horizontal(
                          left: isLeft ? Radius.zero : const Radius.circular(4),
                          right: isLeft ? const Radius.circular(4) : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),

        // 오른쪽 라벨
        SizedBox(
          width: 24,
          child: Text(
            dimension.rightLabel,
            style: context.typography.labelMedium.copyWith(
              color: !isLeft
                  ? context.colors.accent
                  : context.colors.textTertiary,
              fontWeight: !isLeft ? FontWeight.w700 : FontWeight.w400,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),

        // 점수
        SizedBox(
          width: 32,
          child: Text(
            '${dimension.value}',
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// 바이오리듬 템플릿
class BiorhythmChartTemplate extends StatelessWidget {
  const BiorhythmChartTemplate({
    super.key,
    required this.physical,
    required this.emotional,
    required this.intellectual,
    this.overallRating,
    this.advice,
    this.date,
    this.isShareMode = false,
  });

  /// 신체 리듬 (0-100)
  final BiorhythmData physical;

  /// 감정 리듬 (0-100)
  final BiorhythmData emotional;

  /// 지성 리듬 (0-100)
  final BiorhythmData intellectual;

  /// 종합 평가 (별점 1-5)
  final int? overallRating;

  /// 조언
  final String? advice;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '오늘의 바이오리듬',
      isShareMode: isShareMode,
      chartWidget: _buildRhythmChart(context),
      footerWidget: _buildSummary(context),
    );
  }

  Widget _buildRhythmChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BiorhythmBar(
            label: '신체',
            icon: Icons.fitness_center_rounded,
            data: physical,
            color: const Color(0xFFE53935),
          ),
          const SizedBox(height: DSSpacing.md),
          _BiorhythmBar(
            label: '감정',
            icon: Icons.favorite_rounded,
            data: emotional,
            color: const Color(0xFFE91E63),
          ),
          const SizedBox(height: DSSpacing.md),
          _BiorhythmBar(
            label: '지성',
            icon: Icons.psychology_rounded,
            data: intellectual,
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 종합 평가
          if (overallRating != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '종합 컨디션: ',
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                ...List.generate(5, (index) {
                  return Icon(
                    index < overallRating!
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 20,
                    color: index < overallRating!
                        ? context.colors.warning
                        : context.colors.textTertiary,
                  );
                }),
              ],
            ),
          ],

          // 조언
          if (advice != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '"$advice"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 바이오리듬 데이터
class BiorhythmData {
  const BiorhythmData({
    required this.value,
    required this.phase,
  });

  /// 값 (0-100)
  final int value;

  /// 상태 (상승기, 정점, 하강기, 저점)
  final BiorhythmPhase phase;
}

enum BiorhythmPhase {
  rising,
  peak,
  falling,
  low,
}

class _BiorhythmBar extends StatelessWidget {
  const _BiorhythmBar({
    required this.label,
    required this.icon,
    required this.data,
    required this.color,
  });

  final String label;
  final IconData icon;
  final BiorhythmData data;
  final Color color;

  IconData _getPhaseIcon() {
    switch (data.phase) {
      case BiorhythmPhase.rising:
        return Icons.trending_up_rounded;
      case BiorhythmPhase.peak:
        return Icons.arrow_forward_rounded;
      case BiorhythmPhase.falling:
        return Icons.trending_down_rounded;
      case BiorhythmPhase.low:
        return Icons.arrow_downward_rounded;
    }
  }

  String _getPhaseLabel() {
    switch (data.phase) {
      case BiorhythmPhase.rising:
        return '상승기';
      case BiorhythmPhase.peak:
        return '정점';
      case BiorhythmPhase.falling:
        return '하강기';
      case BiorhythmPhase.low:
        return '저점';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 행
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: DSSpacing.xs),
            Text(
              label,
              style: context.typography.labelMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${data.value}%',
              style: context.typography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.xs),

        // 바
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: context.colors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: data.value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.xxs),

        // 상태
        Row(
          children: [
            Icon(_getPhaseIcon(), size: 14, color: context.colors.textTertiary),
            const SizedBox(width: DSSpacing.xxs),
            Text(
              _getPhaseLabel(),
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 궁합 분석 템플릿
class CompatibilityChartTemplate extends StatelessWidget {
  const CompatibilityChartTemplate({
    super.key,
    required this.overallScore,
    required this.categories,
    this.personAName,
    this.personBName,
    this.summary,
    this.date,
    this.isShareMode = false,
  });

  /// 종합 점수
  final int overallScore;

  /// 카테고리별 점수
  final List<CompatibilityCategory> categories;

  /// A 이름
  final String? personAName;

  /// B 이름
  final String? personBName;

  /// 요약
  final String? summary;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '두 사람의 궁합',
      isShareMode: isShareMode,
      headerWidget: _buildHeader(context),
      chartWidget: _buildCategoriesChart(context),
      footerWidget: summary != null ? _buildSummary(context) : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Person A
        PrivacyShield(
          isShielded: isShareMode,
          style: PrivacyStyle.replace,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.accent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                personAName?.characters.first ?? 'A',
                style: context.typography.headingMedium.copyWith(
                  color: context.colors.accent,
                ),
              ),
            ),
          ),
        ),

        // 중앙 점수
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 24,
                color: Colors.pinkAccent,
              ),
              Text(
                '$overallScore%',
                style: context.typography.headingLarge.copyWith(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Person B
        PrivacyShield(
          isShielded: isShareMode,
          style: PrivacyStyle.replace,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.accentSecondary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                personBName?.characters.first ?? 'B',
                style: context.typography.headingMedium.copyWith(
                  color: context.colors.accentSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: CompatibilityBar(
              label: cat.label,
              score: cat.value,
              maxScore: 100,
              showScore: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withOpacity(0.1),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 20,
            color: Colors.pinkAccent,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              '"$summary"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 궁합 카테고리 데이터
class CompatibilityCategory {
  const CompatibilityCategory({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final int value;
  final Color? color;
}

/// 경기 분석 템플릿
class SportsChartTemplate extends StatelessWidget {
  const SportsChartTemplate({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.teamAWinRate,
    this.matchInfo,
    this.teamAAnalysis,
    this.teamBAnalysis,
    this.luckyItems,
    this.date,
    this.isShareMode = false,
  });

  /// 팀 A 이름
  final String teamA;

  /// 팀 B 이름
  final String teamB;

  /// 팀 A 승률 (0-100)
  final int teamAWinRate;

  /// 경기 정보
  final String? matchInfo;

  /// 팀 A 분석
  final String? teamAAnalysis;

  /// 팀 B 분석
  final String? teamBAnalysis;

  /// 행운 요소
  final List<String>? luckyItems;

  /// 날짜
  final DateTime? date;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '경기 인사이트 분석',
      subtitle: matchInfo,
      isShareMode: isShareMode,
      chartWidget: _buildVersusChart(context),
      footerWidget: _buildAnalysis(context),
    );
  }

  Widget _buildVersusChart(BuildContext context) {
    return VersusBar(
      leftLabel: teamA,
      rightLabel: teamB,
      leftValue: teamAWinRate.toDouble(),
      rightValue: (100 - teamAWinRate).toDouble(),
      leftColor: context.colors.accent,
      rightColor: context.colors.error,
      showPercentage: true,
      animate: true,
    );
  }

  Widget _buildAnalysis(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 팀 분석
        Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary.withOpacity(0.5),
            borderRadius: DSRadius.mdBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (teamAAnalysis != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: context.colors.accent,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        '$teamA: $teamAAnalysis',
                        style: context.typography.bodySmall.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (teamBAnalysis != null) ...[
                const SizedBox(height: DSSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.trending_down_rounded,
                      size: 16,
                      color: context.colors.error,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        '$teamB: $teamBAnalysis',
                        style: context.typography.bodySmall.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // 행운 요소
        if (luckyItems != null && luckyItems!.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.accent.withOpacity(0.1),
              borderRadius: DSRadius.smBorder,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: luckyItems!.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
                  child: Text(
                    item,
                    style: context.typography.labelSmall.copyWith(
                      color: context.colors.accent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // 면책 문구
        const SizedBox(height: DSSpacing.sm),
        Container(
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.warning.withOpacity(0.1),
            borderRadius: DSRadius.smBorder,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: context.colors.warning,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '도박/배팅 목적 사용 불가',
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.warning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 성격 DNA 템플릿 (MBTI × 혈액형 × 별자리 × 띠)
class PersonalityDnaChartTemplate extends StatelessWidget {
  const PersonalityDnaChartTemplate({
    super.key,
    required this.mbti,
    required this.bloodType,
    required this.zodiac,
    required this.chineseZodiac,
    required this.personalityType,
    this.scores,
    this.powerColor,
    this.powerColorValue,
    this.isShareMode = false,
  });

  /// MBTI 유형
  final String mbti;

  /// 혈액형
  final String bloodType;

  /// 별자리
  final String zodiac;

  /// 띠
  final String chineseZodiac;

  /// 성격 타입명
  final String personalityType;

  /// 분야별 점수 (연애/직업/건강/사교)
  final List<DnaScore>? scores;

  /// 파워 컬러 이름
  final String? powerColor;

  /// 파워 컬러 값
  final Color? powerColorValue;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '나의 성격 DNA',
      isShareMode: isShareMode,
      headerWidget: _buildDnaCards(context),
      chartWidget: _buildPersonalityInfo(context),
      footerWidget: _buildScores(context),
    );
  }

  Widget _buildDnaCards(BuildContext context) {
    final items = [
      _DnaItem(label: 'MBTI', value: mbti, icon: Icons.psychology_rounded),
      _DnaItem(label: '혈액형', value: bloodType, icon: Icons.water_drop_rounded),
      _DnaItem(label: '별자리', value: zodiac, icon: Icons.star_rounded),
      _DnaItem(label: '띠', value: chineseZodiac, icon: Icons.pets_rounded),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.border.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 16, color: context.colors.accent),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                item.value,
                style: context.typography.labelMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                item.label,
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalityInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.accent.withOpacity(0.1),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            personalityType,
            style: context.typography.headingMedium.copyWith(
              color: context.colors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (powerColor != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.palette_rounded,
                  size: 16,
                  color: powerColorValue ?? context.colors.accent,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '파워 컬러: $powerColor',
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (powerColorValue != null) ...[
                  const SizedBox(width: DSSpacing.sm),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: powerColorValue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.border,
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScores(BuildContext context) {
    if (scores == null || scores!.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: scores!.map((score) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.label,
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                '${score.value}',
                style: context.typography.headingSmall.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DnaItem {
  const _DnaItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

/// DNA 점수 데이터
class DnaScore {
  const DnaScore({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;
}

/// 재능 분석 템플릿 (레이더 차트)
class TalentChartTemplate extends StatelessWidget {
  const TalentChartTemplate({
    super.key,
    required this.overallScore,
    required this.talents,
    this.topTalent,
    this.advice,
    this.isShareMode = false,
  });

  /// 종합 점수
  final int overallScore;

  /// 재능 목록
  final List<TalentData> talents;

  /// 최고 재능
  final String? topTalent;

  /// 조언
  final String? advice;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '재능 분석',
      isShareMode: isShareMode,
      headerWidget: _buildHeader(context),
      chartWidget: _buildTalentBars(context),
      footerWidget: advice != null ? _buildAdvice(context) : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$overallScore',
                style: context.typography.displaySmall.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '종합',
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (topTalent != null) ...[
          const SizedBox(width: DSSpacing.lg),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '최고 재능',
                style: context.typography.labelSmall.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 20,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    topTalent!,
                    style: context.typography.headingSmall.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTalentBars(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: talents.map((talent) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: _buildTalentBar(context, talent),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTalentBar(BuildContext context, TalentData talent) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            talent.label,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: context.colors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: talent.value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: talent.color ?? context.colors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        SizedBox(
          width: 30,
          child: Text(
            '${talent.value}',
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.accent.withOpacity(0.1),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 20,
            color: context.colors.accent,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              '"$advice"',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 재능 데이터
class TalentData {
  const TalentData({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final int value;
  final Color? color;
}

/// 재물 운세 템플릿 (10섹터 분석)
class InvestmentChartTemplate extends StatelessWidget {
  const InvestmentChartTemplate({
    super.key,
    required this.overallScore,
    required this.sectors,
    this.topSector,
    this.bottomSector,
    this.advice,
    this.warningMessage,
    this.isShareMode = false,
  });

  /// 종합 점수
  final int overallScore;

  /// 섹터별 점수
  final List<InvestmentSector> sectors;

  /// 최고 섹터
  final String? topSector;

  /// 최저 섹터
  final String? bottomSector;

  /// 조언
  final String? advice;

  /// 경고 메시지
  final String? warningMessage;

  /// 공유 모드
  final bool isShareMode;

  @override
  Widget build(BuildContext context) {
    return ChartTemplate(
      title: '오늘의 재물운',
      isShareMode: isShareMode,
      headerWidget: _buildHeader(context),
      chartWidget: _buildSectorGrid(context),
      footerWidget: _buildFooter(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.2),
                Colors.orange.withOpacity(0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on_rounded,
                size: 24,
                color: Colors.amber,
              ),
              Text(
                '$overallScore',
                style: context.typography.displaySmall.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DSSpacing.lg),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topSector != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up_rounded, size: 16, color: context.colors.success),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '유망: $topSector',
                    style: context.typography.labelMedium.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            if (bottomSector != null) ...[
              const SizedBox(height: DSSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_down_rounded, size: 16, color: context.colors.error),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    '주의: $bottomSector',
                    style: context.typography.labelMedium.copyWith(
                      color: context.colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSectorGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary.withOpacity(0.5),
        borderRadius: DSRadius.mdBorder,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: sectors.map((sector) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: _buildSectorBar(context, sector),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectorBar(BuildContext context, InvestmentSector sector) {
    final isPositive = sector.value >= 50;
    final barColor = isPositive ? context.colors.success : context.colors.error;

    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            sector.label,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: context.colors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: sector.value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.xs),
        SizedBox(
          width: 28,
          child: Text(
            '${sector.value}',
            style: context.typography.labelSmall.copyWith(
              color: barColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 조언
        if (advice != null)
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: DSRadius.mdBorder,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 20,
                  color: Colors.amber,
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Text(
                    advice!,
                    style: context.typography.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 경고
        if (warningMessage != null) ...[
          const SizedBox(height: DSSpacing.sm),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.warning.withOpacity(0.1),
              borderRadius: DSRadius.smBorder,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: context.colors.warning,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  warningMessage!,
                  style: context.typography.labelSmall.copyWith(
                    color: context.colors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 투자 섹터 데이터
class InvestmentSector {
  const InvestmentSector({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;
}
