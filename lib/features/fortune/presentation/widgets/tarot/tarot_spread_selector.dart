import 'package:flutter/material.dart';
import '../../../domain/models/tarot_card_model.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../shared/components/floating_bottom_button.dart';
import '../../../../../core/theme/toss_design_system.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Stack(
          children: [
            // 스크롤 가능한 컨텐츠
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 100, // FloatingBottomButton을 위한 공간
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    '스프레드를 선택하세요',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 부제목
                  Text(
                    '질문: ${widget.question}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 32),

                  // 스프레드 옵션들
                  _buildSpreadCard(
                    spread: TarotSpreadType.single,
                    icon: Icons.style,
                    color: const Color(0xFF3B82F6),
                    recommended: '빠른 답변이 필요할 때',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  _buildSpreadCard(
                    spread: TarotSpreadType.threeCard,
                    icon: Icons.timeline,
                    color: const Color(0xFF7C3AED),
                    recommended: '시간의 흐름을 보고 싶을 때',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  _buildSpreadCard(
                    spread: TarotSpreadType.relationship,
                    icon: Icons.favorite,
                    color: const Color(0xFFEC4899),
                    recommended: '연애/관계 질문',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 16),

                  _buildSpreadCard(
                    spread: TarotSpreadType.celticCross,
                    icon: Icons.apps,
                    color: const Color(0xFF10B981),
                    recommended: '심층 분석이 필요할 때',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // FloatingBottomButton
            FloatingBottomButton(
              text: '카드 뽑기',
              onPressed: _selectedSpread != null
                  ? () => widget.onSpreadSelected(_selectedSpread!)
                  : null,
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
              hideWhenDisabled: true,
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

    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.cardBackgroundLight),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? TossDesignSystem.borderDark : TossDesignSystem.borderLight),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                        color: isSelected ? TossDesignSystem.white : color,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 제목과 설명
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                spread.displayName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? color
                                      : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${spread.cardCount}장',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            spread.description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
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
                    color: isDark ? TossDesignSystem.surfaceBackgroundDark : TossDesignSystem.surfaceBackgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        recommended,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // 스프레드 미리보기
                if (spread != TarotSpreadType.single) ...[
                  const SizedBox(height: 16),
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

    switch (spread) {
      case TarotSpreadType.threeCard:
        preview = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final labels = ['과거', '현재', '미래'];
            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
        break;

      case TarotSpreadType.relationship:
        preview = SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 중앙 카드 (현재 관계)
              Positioned(
                top: 30,
                child: _buildMiniCard('4', color),
              ),
              // 왼쪽 카드 (나)
              Positioned(
                left: 20,
                top: 30,
                child: _buildMiniCard('1', color),
              ),
              // 오른쪽 카드 (상대)
              Positioned(
                right: 20,
                top: 30,
                child: _buildMiniCard('2', color),
              ),
              // 위 카드 (과거)
              Positioned(
                top: 0,
                child: _buildMiniCard('3', color),
              ),
              // 아래 카드 (미래)
              Positioned(
                bottom: 0,
                child: _buildMiniCard('5', color),
              ),
            ],
          ),
        );
        break;

      case TarotSpreadType.celticCross:
        preview = Center(
          child: Text(
            '켈틱 크로스 - 10장의 카드로\n가장 상세한 분석을 제공합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? TossDesignSystem.textTertiaryDark : TossDesignSystem.textTertiaryLight,
              height: 1.4,
            ),
          ),
        );
        break;

      default:
        preview = const SizedBox.shrink();
    }

    return preview;
  }

  Widget _buildMiniCard(String number, Color color) {
    return Container(
      width: 24,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}