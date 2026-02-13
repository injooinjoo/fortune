import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../data/models/chat_insight_result.dart';

/// 관계 설정 인라인 카드 (관계유형 + 기간 + 분석 깊이)
class RelationContextCard extends StatefulWidget {
  final void Function(AnalysisConfig config) onConfigSubmit;

  const RelationContextCard({super.key, required this.onConfigSubmit});

  @override
  State<RelationContextCard> createState() => _RelationContextCardState();
}

class _RelationContextCardState extends State<RelationContextCard> {
  RelationType? _relationType;
  DateRange _dateRange = DateRange.all;
  AnalysisIntensity _intensity = AnalysisIntensity.standard;

  bool get _canSubmit => _relationType != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return DSCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Icon(Icons.tune, color: colors.textSecondary, size: 20),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '관계 설정',
                style:
                    typography.headingSmall.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // Row 1: 상대
          Text('상대',
              style:
                  typography.labelMedium.copyWith(color: colors.textSecondary)),
          const SizedBox(height: DSSpacing.xs),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: RelationType.values.map((type) {
              final isSelected = _relationType == type;
              return ChoiceChip(
                label: Text(_relationLabel(type)),
                selected: isSelected,
                onSelected: (_) => setState(() => _relationType = type),
                selectedColor: colors.ctaBackground.withValues(alpha: 0.15),
                backgroundColor: colors.surface,
                labelStyle: typography.labelSmall.copyWith(
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected
                      ? colors.ctaBackground
                      : colors.textTertiary.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.md),

          // Row 2: 기간
          Text('기간',
              style:
                  typography.labelMedium.copyWith(color: colors.textSecondary)),
          const SizedBox(height: DSSpacing.xs),
          Wrap(
            spacing: DSSpacing.xs,
            children: DateRange.values.map((range) {
              final isSelected = _dateRange == range;
              return ChoiceChip(
                label: Text(_dateRangeLabel(range)),
                selected: isSelected,
                onSelected: (_) => setState(() => _dateRange = range),
                selectedColor: colors.ctaBackground.withValues(alpha: 0.15),
                backgroundColor: colors.surface,
                labelStyle: typography.labelSmall.copyWith(
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected
                      ? colors.ctaBackground
                      : colors.textTertiary.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.md),

          // Row 3: 분석 깊이
          Text('분석',
              style:
                  typography.labelMedium.copyWith(color: colors.textSecondary)),
          const SizedBox(height: DSSpacing.xs),
          Wrap(
            spacing: DSSpacing.xs,
            children: AnalysisIntensity.values.map((intensity) {
              final isSelected = _intensity == intensity;
              return ChoiceChip(
                label: Text(_intensityLabel(intensity)),
                selected: isSelected,
                onSelected: (_) => setState(() => _intensity = intensity),
                selectedColor: colors.ctaBackground.withValues(alpha: 0.15),
                backgroundColor: colors.surface,
                labelStyle: typography.labelSmall.copyWith(
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected
                      ? colors.ctaBackground
                      : colors.textTertiary.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DSSpacing.lg),

          // 분석 시작 버튼
          SizedBox(
            width: double.infinity,
            child: DSButton.primary(
              text: '🔍 분석 시작',
              onPressed: _canSubmit
                  ? () => widget.onConfigSubmit(
                        AnalysisConfig(
                          relationType: _relationType!,
                          dateRange: _dateRange,
                          intensity: _intensity,
                        ),
                      )
                  : null,
            ),
          ),

          if (!_canSubmit) ...[
            const SizedBox(height: DSSpacing.xs),
            Text(
              '상대를 선택해주세요',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _relationLabel(RelationType type) {
    switch (type) {
      case RelationType.lover:
        return '연인';
      case RelationType.crush:
        return '썸';
      case RelationType.friend:
        return '친구';
      case RelationType.family:
        return '가족';
      case RelationType.boss:
        return '상사';
      case RelationType.other:
        return '기타';
    }
  }

  String _dateRangeLabel(DateRange range) {
    switch (range) {
      case DateRange.all:
        return '전체';
      case DateRange.days7:
        return '7일';
      case DateRange.days30:
        return '30일';
    }
  }

  String _intensityLabel(AnalysisIntensity intensity) {
    switch (intensity) {
      case AnalysisIntensity.light:
        return '라이트';
      case AnalysisIntensity.standard:
        return '표준';
      case AnalysisIntensity.deep:
        return '딥';
    }
  }
}
