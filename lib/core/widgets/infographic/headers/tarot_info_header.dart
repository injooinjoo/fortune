import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../../../theme/typography_unified.dart';
import '../energy_gauge.dart';
import '../theme_chips.dart';

/// 타로 결과 인포그래픽 헤더
///
/// 타로 카드 미리보기, 에너지 게이지, 키 테마를 표시
///
/// 사용 예시:
/// ```dart
/// TarotInfoHeader(
///   spreadName: 'Three Card Spread',
///   question: '연애운을 알려주세요',
///   cards: [...],
///   energyLevel: 82,
///   keyThemes: ['변화', '새시작', '희망'],
/// )
/// ```
class TarotInfoHeader extends StatelessWidget {
  /// 스프레드 이름
  final String spreadName;

  /// 질문
  final String? question;

  /// 선택된 카드들
  final List<Map<String, dynamic>> cards;

  /// 에너지 레벨 (0-100)
  final int energyLevel;

  /// 키 테마/키워드
  final List<String> keyThemes;

  const TarotInfoHeader({
    super.key,
    required this.spreadName,
    this.question,
    required this.cards,
    this.energyLevel = 75,
    this.keyThemes = const [],
  });

  /// API 응답 데이터에서 생성
  factory TarotInfoHeader.fromData(Map<String, dynamic> data) {
    final cardsList = (data['cards'] as List?)
            ?.map((c) => c as Map<String, dynamic>)
            .toList() ??
        [];
    final themes = (data['keyThemes'] as List?)?.cast<String>() ?? [];

    return TarotInfoHeader(
      spreadName: data['spreadDisplayName'] as String? ??
          data['spreadName'] as String? ??
          '타로 리딩',
      question: data['question'] as String?,
      cards: cardsList,
      energyLevel: (data['energyLevel'] as num?)?.toInt() ?? 75,
      keyThemes: themes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accentSecondary.withValues(alpha: 0.08),
            colors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스프레드 정보
          _buildSpreadInfo(context),

          // 질문
          if (question != null && question!.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildQuestion(context),
          ],

          // 카드 미리보기
          if (cards.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildCardPreview(context),
          ],

          // 에너지 게이지
          const SizedBox(height: DSSpacing.md),
          _buildEnergySection(context),

          // 키 테마
          if (keyThemes.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            HashtagChips(hashtags: keyThemes),
          ],
        ],
      ),
    );
  }

  Widget _buildSpreadInfo(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.accentSecondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('🔮', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: DSSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '타로 리딩',
              style: context.heading4.copyWith(
                color: colors.textPrimary,
              ),
            ),
            Text(
              '$spreadName • ${cards.length}장',
              style: context.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💬', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"$question"',
              style: context.bodySmall.copyWith(
                color: colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cards.asMap().entries.map((entry) {
          final index = entry.key;
          final card = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
            child: _TarotCardMini(
              cardName: card['cardNameKr'] as String? ?? '카드',
              positionName: card['positionName'] as String? ?? '',
              isReversed: card['isReversed'] as bool? ?? false,
              colors: colors,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnergySection(BuildContext context) {
    return EnergyGauge(
      value: energyLevel,
      label: '에너지',
      icon: '⚡',
      height: 10,
      useGradient: true,
    );
  }
}

/// 타로 카드 미니 위젯
class _TarotCardMini extends StatelessWidget {
  final String cardName;
  final String positionName;
  final bool isReversed;
  final DSColorScheme colors;

  const _TarotCardMini({
    required this.cardName,
    required this.positionName,
    required this.isReversed,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isReversed ? colors.error : colors.accentSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 포지션 이름
        if (positionName.isNotEmpty)
          Text(
            positionName,
            style: context.labelSmall.copyWith(
              color: colors.accentSecondary,
              fontSize: 10,
            ),
          ),
        const SizedBox(height: 4),
        // 카드
        Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '🎴',
              style: TextStyle(
                fontSize: 24,
                color: isReversed ? colors.error : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 카드 이름
        SizedBox(
          width: 60,
          child: Text(
            cardName,
            style: context.labelSmall.copyWith(
              color: colors.textPrimary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 역방향 표시
        if (isReversed)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '역',
              style: context.labelSmall.copyWith(
                color: colors.error,
                fontSize: 8,
              ),
            ),
          ),
      ],
    );
  }
}
