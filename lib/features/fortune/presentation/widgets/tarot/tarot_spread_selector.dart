import 'package:flutter/material.dart';
import '../../../domain/models/tarot_card_model.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/constants/tarot/tarot_helper.dart';

class TarotSpreadSelector extends StatefulWidget {
  final Function(TarotSpreadType) onSpreadSelected;
  final String question;

  const TarotSpreadSelector({
    super.key,
    required this.onSpreadSelected,
    required this.question,
  });

  @override
  State<TarotSpreadSelector> createState() => _TarotSpreadSelectorState();
}

class _TarotSpreadSelectorState extends State<TarotSpreadSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TarotSpreadType? _selectedSpread;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // F11: 난이도별 색상 반환
  Color _getDifficultyColor(TarotDifficulty difficulty) {
    switch (difficulty) {
      case TarotDifficulty.beginner:
        return const Color(0xFF22C55E); // 초록 - 쉬움
      case TarotDifficulty.intermediate:
        return const Color(0xFFF59E0B); // 주황 - 중간
      case TarotDifficulty.advanced:
        return const Color(0xFFEF4444); // 빨강 - 어려움
    }
  }

  // F11: 스프레드별 설정 반환
  Map<String, dynamic> _getSpreadConfig(TarotSpreadType spread) {
    switch (spread) {
      case TarotSpreadType.single:
        return {
          'icon': Icons.style,
          'color': const Color(0xFF3B82F6),
          'recommended': '빠른 답변이 필요할 때',
        };
      case TarotSpreadType.threeCard:
        return {
          'icon': Icons.timeline,
          'color': const Color(0xFF7C3AED),
          'recommended': '시간의 흐름을 보고 싶을 때',
        };
      case TarotSpreadType.relationship:
        return {
          'icon': Icons.favorite,
          'color': const Color(0xFFEC4899),
          'recommended': '연애/관계 질문',
        };
      case TarotSpreadType.celticCross:
        return {
          'icon': Icons.apps,
          'color': const Color(0xFF10B981),
          'recommended': '심층 분석이 필요할 때',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final typography = context.typography;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Stack(
          children: [
            // 스크롤 가능한 컨텐츠
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: DSSpacing.lg,
                right: DSSpacing.lg,
                top: DSSpacing.lg,
                bottom: 100, // FloatingBottomButton을 위한 공간
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    '스프레드를 선택하세요',
                    style: typography.headingLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: 8),

                  // 부제목
                  Text(
                    '질문: ${widget.question}',
                    style: typography.bodySmall.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 32),

                  // F11: 난이도순 정렬된 스프레드 옵션들
                  ...TarotSpreadType.sortedByDifficulty.map((spread) {
                    final config = _getSpreadConfig(spread);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildSpreadCard(
                        spread: spread,
                        icon: config['icon'] as IconData,
                        color: config['color'] as Color,
                        recommended: config['recommended'] as String,
                        isDark: isDark,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // FloatingBottomButton
            UnifiedButton.floating(
              text: '카드 뽑기',
              onPressed: _selectedSpread != null
                  ? () => widget.onSpreadSelected(_selectedSpread!)
                  : null,
              isEnabled: _selectedSpread != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadCard({
    required TarotSpreadType spread,
    required IconData icon,
    required Color color,
    required String recommended,
    required bool isDark,
  }) {
    final isSelected = _selectedSpread == spread;
    final colors = context.colors;
    final typography = context.typography;

    return Material(
      color: Colors.white.withValues(alpha: 0.0),
      borderRadius: BorderRadius.circular(DSRadius.lg),
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colors.surface,
          border: Border.all(
            color: isSelected
                ? color
                : colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(DSRadius.lg),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSpread = spread;
            });
          },
          borderRadius: BorderRadius.circular(DSRadius.lg),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 아이콘
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? color : color.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : color,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: DSSpacing.md),

                    // 제목과 설명
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                spread.displayName,
                                style: typography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? color
                                      : colors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // F11: 난이도 뱃지
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(spread.difficulty).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(DSRadius.sm),
                                ),
                                child: Text(
                                  spread.difficulty.label,
                                  style: typography.labelSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getDifficultyColor(spread.difficulty),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(DSRadius.md),
                                ),
                                child: Text(
                                  '${spread.cardCount}장',
                                  style: typography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            spread.description,
                            style: typography.bodySmall.copyWith(
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 선택 표시
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 24,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // 추천 상황
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: color,
                      ),
                      SizedBox(width: 6),
                      Text(
                        recommended,
                        style: typography.labelMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 스프레드 미리보기
                if (spread != TarotSpreadType.single) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildSpreadPreview(spread, color, isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpreadPreview(TarotSpreadType spread, Color color, bool isDark) {
    Widget preview;

    // 3카드 스프레드 미리보기용 카드 인덱스 (바보, 마법사, 여사제)
    const threeCardIndices = [0, 1, 2];
    // 관계 스프레드용 카드 인덱스 (연인, 여황제, 황제, 운명의 수레바퀴, 태양)
    const relationshipIndices = [6, 3, 4, 10, 19];

    switch (spread) {
      case TarotSpreadType.threeCard:
        preview = SizedBox(
          height: 95, // 고정 높이로 오버플로우 방지
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(3, (index) {
              final labels = ['과거', '현재', '미래'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTarotImageCard(
                        cardIndex: threeCardIndices[index],
                        color: color,
                        width: 45,
                        height: 68,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: context.typography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
        break;

      case TarotSpreadType.relationship:
        // 관계 스프레드: 5장 가로 정렬
        final labels = ['나', '상대', '현재', '조언', '미래'];
        preview = SizedBox(
          height: 95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTarotImageCard(
                        cardIndex: relationshipIndices[index],
                        color: color,
                        width: 38,
                        height: 57,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: context.typography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
        break;

      case TarotSpreadType.celticCross:
        preview = Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: List.generate(10, (index) {
              return _buildTarotImageCard(
                cardIndex: index, // 0~9 카드 순서대로
                color: color,
                width: 24,
                height: 36,
              );
            }),
          ),
        );
        break;

      default:
        preview = const SizedBox.shrink();
    }

    return preview;
  }

  /// 실제 타로 카드 이미지를 표시하는 미리보기 카드
  Widget _buildTarotImageCard({
    required int cardIndex,
    required Color color,
    required double width,
    required double height,
  }) {
    // TarotHelper를 사용하여 카드 이미지 경로 생성
    final cardFileName = TarotHelper.getMajorArcanaFileName(cardIndex);
    final imagePath = 'assets/images/tarot/decks/rider_waite/major/$cardFileName';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 폴백: 색상 그라데이션 박스
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: color,
                  size: width * 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}