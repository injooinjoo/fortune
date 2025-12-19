import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

/// 사주 개념 설명 카드 위젯
/// 각 탭에서 해당 개념에 대한 설명을 접을 수 있는 형태로 제공합니다.
class SajuConceptCard extends StatefulWidget {
  final String title;
  final String shortDescription;
  final String fullDescription;
  final IconData icon;

  const SajuConceptCard({
    super.key,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    this.icon = Icons.info_outline,
  });

  @override
  State<SajuConceptCard> createState() => _SajuConceptCardState();
}

class _SajuConceptCardState extends State<SajuConceptCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (제목 + 아이콘)
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Icon(
                  widget.icon,
                  color: colors.accent,
                  size: 16,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  widget.title,
                  style: context.labelLarge.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: DSSpacing.sm),

          // 짧은 설명
          Text(
            widget.shortDescription,
            style: context.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),

          // 확장된 설명 (애니메이션)
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: DSSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DSSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                    border: Border.all(
                      color: colors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.fullDescription,
                    style: context.bodySmall.copyWith(
                      color: colors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DSSpacing.sm),

          // 펼치기/접기 버튼
          GestureDetector(
            onTap: _toggleExpand,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? '접기' : '자세히 보기',
                  style: context.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: colors.accent,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 천간/지지 터치 해설 바텀시트를 표시하는 함수
void showCharacterExplanationSheet({
  required BuildContext context,
  required String hanja,
  required String korean,
  required String element,
  required String elementKorean,
  required String meaning,
  required String description,
  String? animal, // 지지의 경우 띠 동물
  String? time, // 지지의 경우 시간대
}) {
  final colors = context.colors;

  // 오행별 색상
  Color getElementColor(String element) {
    switch (element) {
      case '木':
        return const Color(0xFF4CAF50);
      case '火':
        return const Color(0xFFE53935);
      case '土':
        return const Color(0xFFFF9800);
      case '金':
        return const Color(0xFFFFD700);
      case '水':
        return const Color(0xFF2196F3);
      default:
        return colors.accent;
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),

            // 헤더: 한자 + 한글 + 오행 배지
            Row(
              children: [
                // 한자
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: getElementColor(element).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: getElementColor(element).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hanja,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: getElementColor(element),
                        fontFamily: 'ZenSerif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),

                // 한글 이름 + 오행
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$hanja ($korean)',
                        style: context.heading3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // 오행 배지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: getElementColor(element),
                              borderRadius: BorderRadius.circular(DSRadius.sm),
                            ),
                            child: Text(
                              '$element ($elementKorean)',
                              style: context.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // 띠 동물 (지지인 경우)
                          if (animal != null) ...[
                            const SizedBox(width: DSSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DSSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.textTertiary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(DSRadius.sm),
                              ),
                              child: Text(
                                animal,
                                style: context.labelSmall.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DSSpacing.lg),

            // 시간대 (지지인 경우)
            if (time != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DSSpacing.md),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: colors.textTertiary,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '시간대: $time',
                      style: context.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSSpacing.md),
            ],

            // 의미
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: getElementColor(element).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(
                  color: getElementColor(element).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '의미',
                    style: context.labelMedium.copyWith(
                      color: getElementColor(element),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meaning,
                    style: context.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 상세 설명
            Text(
              '상세 설명',
              style: context.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              description,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),

            const SizedBox(height: DSSpacing.xl),
          ],
        ),
      ),
    ),
  );
}

/// 오행 터치 해설 바텀시트를 표시하는 함수
void showOhangExplanationSheet({
  required BuildContext context,
  required String element,
  required String hanja,
  required String meaning,
  required String personality,
  required String description,
  required String season,
  required String direction,
  required String organ,
  required String colorName,
  required String number,
}) {
  final colors = context.colors;

  Color getElementColor(String element) {
    switch (element) {
      case '목':
        return const Color(0xFF4CAF50);
      case '화':
        return const Color(0xFFE53935);
      case '토':
        return const Color(0xFFFF9800);
      case '금':
        return const Color(0xFFFFD700);
      case '수':
        return const Color(0xFF2196F3);
      default:
        return colors.accent;
    }
  }

  final elementColor = getElementColor(element);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),

            // 헤더: 한자 + 한글
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: elementColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: elementColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hanja,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: elementColor,
                        fontFamily: 'ZenSerif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$element ($hanja)',
                        style: context.heading3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: elementColor,
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          personality,
                          style: context.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DSSpacing.lg),

            // 기본 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Wrap(
                spacing: DSSpacing.lg,
                runSpacing: DSSpacing.sm,
                children: [
                  _buildInfoChip(context, '계절', season, elementColor),
                  _buildInfoChip(context, '방위', direction, elementColor),
                  _buildInfoChip(context, '장부', organ, elementColor),
                  _buildInfoChip(context, '색상', colorName, elementColor),
                  _buildInfoChip(context, '수리', number, elementColor),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 의미
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: elementColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(
                  color: elementColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '의미',
                    style: context.labelMedium.copyWith(
                      color: elementColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meaning,
                    style: context.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 상세 설명
            Text(
              '상세 설명',
              style: context.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              description,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),

            const SizedBox(height: DSSpacing.xl),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoChip(
    BuildContext context, String label, String value, Color color) {
  final colors = context.colors;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$label: ',
        style: context.labelSmall.copyWith(
          color: colors.textTertiary,
        ),
      ),
      Text(
        value,
        style: context.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

/// 12운성 터치 해설 바텀시트를 표시하는 함수
void showTwelveStageExplanationSheet({
  required BuildContext context,
  required String hanja,
  required String korean,
  required String meaning,
  required String description,
  required String fortune,
  required Color stageColor,
}) {
  final colors = context.colors;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),

            // 헤더
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: stageColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hanja,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: stageColor,
                        fontFamily: 'ZenSerif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$korean ($hanja)',
                        style: context.heading3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: stageColor,
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Text(
                          '12운성',
                          style: context.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DSSpacing.lg),

            // 의미
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: stageColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(
                  color: stageColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '의미',
                    style: context.labelMedium.copyWith(
                      color: stageColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meaning,
                    style: context.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 운세
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: stageColor,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      fortune,
                      style: context.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 상세 설명
            Text(
              '상세 설명',
              style: context.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              description,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),

            const SizedBox(height: DSSpacing.xl),
          ],
        ),
      ),
    ),
  );
}

/// 신살 터치 해설 바텀시트를 표시하는 함수
void showSinsalExplanationSheet({
  required BuildContext context,
  required String hanja,
  required String korean,
  required String type,
  required String meaning,
  required String description,
  required Color sinsalColor,
}) {
  final colors = context.colors;

  IconData typeIcon;
  switch (type) {
    case '길신':
      typeIcon = Icons.thumb_up_outlined;
      break;
    case '흉신':
      typeIcon = Icons.warning_amber_outlined;
      break;
    default:
      typeIcon = Icons.balance_outlined;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),

            // 헤더
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: sinsalColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: sinsalColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hanja.length > 2 ? hanja.substring(0, 2) : hanja,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: sinsalColor,
                        fontFamily: 'ZenSerif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        korean,
                        style: context.heading3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sinsalColor,
                              borderRadius: BorderRadius.circular(DSRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  typeIcon,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  type,
                                  style: context.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: DSSpacing.sm),
                          Text(
                            hanja,
                            style: context.labelSmall.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DSSpacing.lg),

            // 의미
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: sinsalColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(
                  color: sinsalColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '의미',
                    style: context.labelMedium.copyWith(
                      color: sinsalColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meaning,
                    style: context.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 상세 설명
            Text(
              '상세 설명',
              style: context.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              description,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),

            const SizedBox(height: DSSpacing.xl),
          ],
        ),
      ),
    ),
  );
}

/// 합충형파해 터치 해설 바텀시트를 표시하는 함수
void showHapchungExplanationSheet({
  required BuildContext context,
  required String hanja,
  required String korean,
  required String meaning,
  required String description,
  required String effect,
  required Color relationColor,
}) {
  final colors = context.colors;

  IconData relationIcon;
  switch (hanja) {
    case '合':
      relationIcon = Icons.link_outlined;
      break;
    case '沖':
      relationIcon = Icons.swap_horiz;
      break;
    case '刑':
      relationIcon = Icons.gavel_outlined;
      break;
    case '破':
      relationIcon = Icons.broken_image_outlined;
      break;
    case '害':
      relationIcon = Icons.warning_outlined;
      break;
    default:
      relationIcon = Icons.help_outline;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DSRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.lg),

            // 헤더
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: relationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: relationColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hanja,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: relationColor,
                        fontFamily: 'ZenSerif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$korean ($hanja)',
                        style: context.heading3.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: relationColor,
                          borderRadius: BorderRadius.circular(DSRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              relationIcon,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '합충형파해',
                              style: context.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DSSpacing.lg),

            // 의미
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: relationColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DSRadius.sm),
                border: Border.all(
                  color: relationColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '의미',
                    style: context.labelMedium.copyWith(
                      color: relationColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meaning,
                    style: context.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 효과
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: relationColor,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Text(
                      effect,
                      style: context.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.md),

            // 상세 설명
            Text(
              '상세 설명',
              style: context.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              description,
              style: context.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),

            const SizedBox(height: DSSpacing.xl),
          ],
        ),
      ),
    ),
  );
}