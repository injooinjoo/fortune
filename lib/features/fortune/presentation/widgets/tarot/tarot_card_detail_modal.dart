import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/constants/tarot_metadata.dart';
import '../../../domain/models/tarot_card_model.dart';

/// 타로 카드 상세 정보를 표시하는 모달
///
/// - 카드 이미지 + 스토리텔링 해석 표시
/// - 모든 메타데이터를 접이식 섹션으로 제공
/// - X 버튼으로 닫기
class TarotCardDetailModal extends StatelessWidget {
  final TarotCard card;
  final String? question;
  final Map<String, dynamic>? interpretation;

  const TarotCardDetailModal({
    super.key,
    required this.card,
    this.question,
    this.interpretation,
  });

  /// 모달을 표시하는 편의 메서드
  static Future<void> show(
    BuildContext context, {
    required TarotCard card,
    String? question,
    Map<String, dynamic>? interpretation,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => TarotCardDetailModal(
        card: card,
        question: question,
        interpretation: interpretation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 카드 메타데이터 가져오기
    final cardInfo = TarotMetadata.getCard(card.number);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더 (타이틀 + X 버튼)
              _buildHeader(context),

              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카드 이미지
                      _buildCardImage(context),

                      const SizedBox(height: 16),

                      // 원소 & 점성술 정보
                      if (cardInfo != null) _buildElementInfo(context, cardInfo),

                      const SizedBox(height: 16),

                      // 키워드 칩
                      if (cardInfo != null) _buildKeywordChips(context, cardInfo),

                      const SizedBox(height: 24),

                      // 스토리텔링 해석 섹션 (API 결과) - 핵심!
                      _buildStorytellingSection(context),

                      const SizedBox(height: 16),

                      // 정방향/역방향 의미
                      if (cardInfo != null) _buildMeaningSection(context, cardInfo),

                      // 접이식 상세 정보 섹션들
                      if (cardInfo != null) ..._buildExpandableSections(context, cardInfo),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 헤더 빌드
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                Text(
                  card.cardNameKr,
                  style: context.typography.headingSmall.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: card.isReversed
                        ? DSColors.error.withValues(alpha: 0.1)
                        : DSColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                  ),
                  child: Text(
                    card.isReversed ? '역방향' : '정방향',
                    style: context.typography.labelSmall.copyWith(
                      color: card.isReversed ? DSColors.error : DSColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.close,
                color: context.colors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카드 이미지 빌드
  Widget _buildCardImage(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 320),
        child: AspectRatio(
          aspectRatio: 0.65,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DSRadius.md),
              child: Transform.rotate(
                angle: card.isReversed ? 3.14159 : 0,
                child: Image.asset(
                  card.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: context.colors.surfaceSecondary,
                      child: Icon(
                        Icons.image_not_supported,
                        color: context.colors.textTertiary,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 원소 & 점성술 정보
  Widget _buildElementInfo(BuildContext context, TarotCardInfo cardInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInfoChip(
          context,
          icon: _getElementIcon(cardInfo.element),
          label: cardInfo.element,
          color: _getElementColor(cardInfo.element),
        ),
        if (cardInfo.astrology != null) ...[
          const SizedBox(width: 12),
          _buildInfoChip(
            context,
            icon: Icons.auto_awesome,
            label: cardInfo.astrology!,
            color: DSColors.accentSecondary,
          ),
        ],
        if (cardInfo.numerology != null) ...[
          const SizedBox(width: 12),
          _buildInfoChip(
            context,
            icon: Icons.tag,
            label: '${cardInfo.numerology}',
            color: DSColors.accent,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 키워드 칩
  Widget _buildKeywordChips(BuildContext context, TarotCardInfo cardInfo) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: cardInfo.keywords.map((keyword) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(DSRadius.full),
          ),
          child: Text(
            keyword,
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 스토리텔링 해석 섹션 (API 결과) - 가장 중요한 섹션!
  Widget _buildStorytellingSection(BuildContext context) {
    // API 해석 결과 추출
    final storytellingContent = interpretation?['interpretation'] as String? ??
        interpretation?['message'] as String? ??
        interpretation?['content'] as String?;

    if (storytellingContent == null || storytellingContent.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.accent.withValues(alpha: 0.08),
            DSColors.accentSecondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_stories,
                color: DSColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '당신을 위한 해석',
                style: context.typography.labelLarge.copyWith(
                  color: DSColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (question != null && question!.isNotEmpty) ...[
            Text(
              '"$question"에 대한 답변',
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            storytellingContent,
            style: context.typography.bodyMedium.copyWith(
              color: context.colors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 정방향/역방향 의미 섹션
  Widget _buildMeaningSection(BuildContext context, TarotCardInfo cardInfo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMeaningRow(
            context,
            icon: Icons.arrow_upward,
            label: '정방향',
            meaning: cardInfo.uprightMeaning,
            color: DSColors.accent,
            isHighlighted: !card.isReversed,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildMeaningRow(
            context,
            icon: Icons.arrow_downward,
            label: '역방향',
            meaning: cardInfo.reversedMeaning,
            color: DSColors.error,
            isHighlighted: card.isReversed,
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String meaning,
    required Color color,
    required bool isHighlighted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isHighlighted ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.sm),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.typography.labelMedium.copyWith(
                  color: color,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meaning,
                style: context.typography.bodySmall.copyWith(
                  color: isHighlighted
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 접이식 상세 정보 섹션들
  List<Widget> _buildExpandableSections(BuildContext context, TarotCardInfo cardInfo) {
    final sections = <Widget>[];

    // 카드 스토리
    if (cardInfo.story != null && cardInfo.story!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.menu_book,
        title: '카드 스토리',
        content: cardInfo.story!,
      ));
    }

    // 심리학적 의미
    if (cardInfo.psychologicalMeaning != null && cardInfo.psychologicalMeaning!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.psychology,
        title: '심리학적 의미',
        content: cardInfo.psychologicalMeaning!,
      ));
    }

    // 영적 의미
    if (cardInfo.spiritualMeaning != null && cardInfo.spiritualMeaning!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.self_improvement,
        title: '영적 의미',
        content: cardInfo.spiritualMeaning!,
      ));
    }

    // 신화적 연결
    if (cardInfo.mythology != null && cardInfo.mythology!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.auto_awesome,
        title: '신화와 전설',
        content: cardInfo.mythology!,
      ));
    }

    // 일상 적용
    if (cardInfo.dailyApplications != null && cardInfo.dailyApplications!.isNotEmpty) {
      sections.add(_buildExpandableListSection(
        context,
        icon: Icons.lightbulb_outline,
        title: '일상에서 적용하기',
        items: cardInfo.dailyApplications!,
      ));
    }

    // 명상법
    if (cardInfo.meditation != null && cardInfo.meditation!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.spa,
        title: '명상법',
        content: cardInfo.meditation!,
      ));
    }

    // 확언
    if (cardInfo.affirmations != null && cardInfo.affirmations!.isNotEmpty) {
      sections.add(_buildExpandableListSection(
        context,
        icon: Icons.format_quote,
        title: '확언 (Affirmations)',
        items: cardInfo.affirmations!,
      ));
    }

    // 색상 상징
    if (cardInfo.colorSymbolism != null && cardInfo.colorSymbolism!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.palette,
        title: '색상 상징',
        content: cardInfo.colorSymbolism!,
      ));
    }

    // 크리스탈
    if (cardInfo.crystals != null && cardInfo.crystals!.isNotEmpty) {
      sections.add(_buildExpandableListSection(
        context,
        icon: Icons.diamond,
        title: '연결된 크리스탈',
        items: cardInfo.crystals!,
      ));
    }

    // 타이밍
    if (cardInfo.timing != null && cardInfo.timing!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.schedule,
        title: '타이밍',
        content: cardInfo.timing!,
      ));
    }

    // 건강 메시지
    if (cardInfo.healthMessage != null && cardInfo.healthMessage!.isNotEmpty) {
      sections.add(_buildExpandableSection(
        context,
        icon: Icons.favorite,
        title: '건강 메시지',
        content: cardInfo.healthMessage!,
      ));
    }

    // 조언
    sections.add(_buildExpandableSection(
      context,
      icon: Icons.tips_and_updates,
      title: '조언',
      content: cardInfo.advice,
    ));

    // 질문
    if (cardInfo.questions.isNotEmpty) {
      sections.add(_buildExpandableListSection(
        context,
        icon: Icons.help_outline,
        title: '생각해볼 질문',
        items: cardInfo.questions,
      ));
    }

    return sections;
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
          backgroundColor: context.colors.surfaceSecondary,
          collapsedBackgroundColor: context.colors.surfaceSecondary,
          leading: Icon(icon, size: 20, color: DSColors.accent),
          title: Text(
            title,
            style: context.typography.labelLarge.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          children: [
            Text(
              content,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableListSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
          backgroundColor: context.colors.surfaceSecondary,
          collapsedBackgroundColor: context.colors.surfaceSecondary,
          leading: Icon(icon, size: 20, color: DSColors.accent),
          title: Text(
            title,
            style: context.typography.labelLarge.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: DSColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: context.typography.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 원소별 아이콘
  IconData _getElementIcon(String element) {
    switch (element) {
      case '불':
        return Icons.local_fire_department;
      case '물':
        return Icons.water_drop;
      case '공기':
        return Icons.air;
      case '땅':
        return Icons.landscape;
      case '모든 원소':
        return Icons.all_inclusive;
      default:
        return Icons.help_outline;
    }
  }

  /// 원소별 색상
  Color _getElementColor(String element) {
    switch (element) {
      case '불':
        return const Color(0xFFE74C3C);
      case '물':
        return const Color(0xFF3498DB);
      case '공기':
        return const Color(0xFF9B59B6);
      case '땅':
        return const Color(0xFF27AE60);
      case '모든 원소':
        return DSColors.accent;
      default:
        return DSColors.textSecondary;
    }
  }
}
