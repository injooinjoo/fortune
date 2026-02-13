import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/font_config.dart';

/// 사주 개념 설명 카드 위젯
/// 각 탭에서 해당 개념에 대한 설명을 접을 수 있는 형태로 제공합니다.
class SajuConceptCard extends StatefulWidget {
  final String title;
  final String shortDescription;
  final String fullDescription;
  final IconData icon;
  final String? realLife; // 실생활 적용
  final String? tips; // 실용적 조언

  const SajuConceptCard({
    super.key,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    this.icon = Icons.info_outline,
    this.realLife,
    this.tips,
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
                // 기본 설명
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
                // 실생활 적용
                if (widget.realLife != null && widget.realLife!.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: DSColors.accentSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                      border: Border.all(
                        color: DSColors.accentSecondary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: DSColors.accentSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: DSSpacing.xs + 2),
                            Text(
                              '실생활에서는?',
                              style: context.labelMedium.copyWith(
                                color: DSColors.accentSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          widget.realLife!,
                          style: context.bodySmall.copyWith(
                            color: colors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // 실용적 조언
                if (widget.tips != null && widget.tips!.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: DSColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                      border: Border.all(
                        color: DSColors.success.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.tips_and_updates_outlined,
                              color: DSColors.success,
                              size: 16,
                            ),
                            const SizedBox(width: DSSpacing.xs + 2),
                            Text(
                              '이렇게 활용하세요!',
                              style: context.labelMedium.copyWith(
                                color: DSColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          widget.tips!,
                          style: context.bodySmall.copyWith(
                            color: colors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                const SizedBox(width: DSSpacing.xs),
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
  String? realLife, // 실생활 해석
  String? love, // 연애/인간관계
  String? career, // 직업/재물운
  String? health, // 건강 관련
  String? tips, // 실용적 조언
  String? compatibility, // 궁합/상성
}) {
  final colors = context.colors;

  // 오행별 색상 - DSColors로 매핑
  Color elementColor;
  switch (element) {
    case '木':
      elementColor = DSColors.success;
      break;
    case '火':
      elementColor = DSColors.error;
      break;
    case '土':
      elementColor = DSColors.warning;
      break;
    case '金':
      elementColor = DSColors.surface;
      break;
    case '水':
      elementColor = DSColors.info;
      break;
    default:
      elementColor = DSColors.accentSecondary;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: DSColors.overlay,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DSRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
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
                            fontSize: FontConfig.heading1,
                            fontWeight: FontWeight.w700,
                            color: elementColor,
                            fontFamily: FontConfig.primary,
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
                          const SizedBox(height: DSSpacing.xs),
                          Row(
                            children: [
                              // 오행 배지
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DSSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: elementColor,
                                  borderRadius:
                                      BorderRadius.circular(DSRadius.sm),
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
                                    color: colors.textTertiary
                                        .withValues(alpha: 0.2),
                                    borderRadius:
                                        BorderRadius.circular(DSRadius.sm),
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
                      const SizedBox(height: DSSpacing.xs),
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

                // 실생활 해석
                if (realLife != null && realLife.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '현대인의 모습으로 보면',
                    content: realLife,
                    icon: Icons.lightbulb_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 연애/인간관계
                if (love != null && love.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '연애 & 인간관계',
                    content: love,
                    icon: Icons.favorite_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 직업/재물운
                if (career != null && career.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '직업 & 재물운',
                    content: career,
                    icon: Icons.work_outline,
                    color: DSColors.warning,
                  ),
                ],

                // 건강
                if (health != null && health.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '건강 포인트',
                    content: health,
                    icon: Icons.health_and_safety_outlined,
                    color: DSColors.success,
                  ),
                ],

                // 실용적 조언
                if (tips != null && tips.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '이렇게 활용하세요!',
                    content: tips,
                    icon: Icons.tips_and_updates_outlined,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 궁합/상성
                if (compatibility != null && compatibility.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '궁합 & 상성',
                    content: compatibility,
                    icon: Icons.people_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                const SizedBox(height: DSSpacing.xl),
              ],
            ),
          ),
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
  String? realLife, // 현대인 유형
  String? loveStyle, // 연애 스타일
  String? workStyle, // 일하는 스타일
  String? stressSign, // 스트레스 신호
  String? rechargeWay, // 에너지 충전법
}) {
  final colors = context.colors;

  // 오행별 색상 - DSColors로 매핑
  Color elementColor;
  switch (element) {
    case '목':
    case '木':
      elementColor = DSColors.success;
      break;
    case '화':
    case '火':
      elementColor = DSColors.error;
      break;
    case '토':
    case '土':
      elementColor = DSColors.warning;
      break;
    case '금':
    case '金':
      elementColor = DSColors.surface;
      break;
    case '수':
    case '水':
      elementColor = DSColors.info;
      break;
    default:
      elementColor = DSColors.accentSecondary;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: DSColors.overlay,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DSRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
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
                            fontSize: FontConfig.heading1,
                            fontWeight: FontWeight.w700,
                            color: elementColor,
                            fontFamily: FontConfig.primary,
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
                          const SizedBox(height: DSSpacing.xs),
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
                      const SizedBox(height: DSSpacing.xs),
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

                // 현대인 유형
                if (realLife != null && realLife.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '현대인 유형으로 보면',
                    content: realLife,
                    icon: Icons.lightbulb_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 연애 스타일
                if (loveStyle != null && loveStyle.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '연애 스타일',
                    content: loveStyle,
                    icon: Icons.favorite_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 일하는 스타일
                if (workStyle != null && workStyle.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '일하는 스타일',
                    content: workStyle,
                    icon: Icons.work_outline,
                    color: DSColors.warning,
                  ),
                ],

                // 스트레스 신호
                if (stressSign != null && stressSign.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '스트레스 받으면?',
                    content: stressSign,
                    icon: Icons.warning_amber_outlined,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 에너지 충전법
                if (rechargeWay != null && rechargeWay.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '에너지 충전법',
                    content: rechargeWay,
                    icon: Icons.battery_charging_full_outlined,
                    color: DSColors.success,
                  ),
                ],

                const SizedBox(height: DSSpacing.xl),
              ],
            ),
          ),
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

/// 확장 가능한 섹션을 빌드하는 헬퍼 위젯
Widget _buildExpandedSection({
  required BuildContext context,
  required String title,
  required String content,
  required IconData icon,
  required Color color,
}) {
  final colors = context.colors;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(DSSpacing.md),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(DSRadius.sm),
      border: Border.all(
        color: color.withValues(alpha: 0.2),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: DSSpacing.xs + 2),
            Text(
              title,
              style: context.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          content,
          style: context.bodyMedium.copyWith(
            color: colors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    ),
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
  String? realLife, // 현대 생활 에너지 해석
  String? when, // 이 운성이 올 때
  String? career, // 직장/사업 의미
  String? love, // 연애/결혼 의미
  String? tips, // 이 시기를 잘 보내는 방법
  String? warning, // 주의할 점
}) {
  final colors = context.colors;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: DSColors.overlay,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DSRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
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
                            fontSize: FontConfig.heading1,
                            fontWeight: FontWeight.w700,
                            color: stageColor,
                            fontFamily: FontConfig.primary,
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
                          const SizedBox(height: DSSpacing.xs),
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
                      const SizedBox(height: DSSpacing.xs),
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

                // 현대 생활 에너지 해석
                if (realLife != null && realLife.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '현대인의 에너지로 보면',
                    content: realLife,
                    icon: Icons.lightbulb_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 이 운성이 올 때
                if (when != null && when.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '이 시기가 오면',
                    content: when,
                    icon: Icons.schedule_outlined,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 직장/사업
                if (career != null && career.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '직장 & 사업운',
                    content: career,
                    icon: Icons.work_outline,
                    color: DSColors.warning,
                  ),
                ],

                // 연애/결혼
                if (love != null && love.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '연애 & 결혼운',
                    content: love,
                    icon: Icons.favorite_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 이 시기를 잘 보내는 방법
                if (tips != null && tips.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '이 시기를 잘 보내려면',
                    content: tips,
                    icon: Icons.tips_and_updates_outlined,
                    color: DSColors.success,
                  ),
                ],

                // 주의할 점
                if (warning != null && warning.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '주의할 점',
                    content: warning,
                    icon: Icons.warning_amber_outlined,
                    color: DSColors.accentSecondary,
                  ),
                ],

                const SizedBox(height: DSSpacing.xl),
              ],
            ),
          ),
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
  String? realLife, // 현대 생활에서 나타나는 양상
  String? goodSide, // 긍정적 활용법
  String? badSide, // 주의해야 할 점
  String? career, // 직업/재물 영향
  String? love, // 연애/인간관계 영향
  String? tips, // 실용적 조언
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
    barrierColor: DSColors.overlay,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DSRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
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
                            fontSize: FontConfig.heading4,
                            fontWeight: FontWeight.w700,
                            color: sinsalColor,
                            fontFamily: FontConfig.primary,
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
                          const SizedBox(height: DSSpacing.xs),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DSSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: sinsalColor,
                                  borderRadius:
                                      BorderRadius.circular(DSRadius.sm),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      typeIcon,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: DSSpacing.xs),
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
                      const SizedBox(height: DSSpacing.xs),
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

                // 현대 생활에서의 양상
                if (realLife != null && realLife.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '현대 사회에서 나타나는 모습',
                    content: realLife,
                    icon: Icons.lightbulb_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 긍정적 활용법
                if (goodSide != null && goodSide.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '좋은 점 & 활용법',
                    content: goodSide,
                    icon: Icons.thumb_up_outlined,
                    color: DSColors.success,
                  ),
                ],

                // 주의해야 할 점
                if (badSide != null && badSide.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '주의할 점',
                    content: badSide,
                    icon: Icons.warning_amber_outlined,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 직업/재물 영향
                if (career != null && career.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '직업 & 재물운',
                    content: career,
                    icon: Icons.work_outline,
                    color: DSColors.warning,
                  ),
                ],

                // 연애/인간관계 영향
                if (love != null && love.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '연애 & 인간관계',
                    content: love,
                    icon: Icons.favorite_outline,
                    color: DSColors.accentSecondary,
                  ),
                ],

                // 실용적 조언
                if (tips != null && tips.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  _buildExpandedSection(
                    context: context,
                    title: '이렇게 활용하세요!',
                    content: tips,
                    icon: Icons.tips_and_updates_outlined,
                    color: DSColors.accentSecondary,
                  ),
                ],

                const SizedBox(height: DSSpacing.xl),
              ],
            ),
          ),
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
  String? realLife,
  String? advice,
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
    barrierColor: DSColors.overlay,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DSRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
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
                            fontSize: FontConfig.heading1,
                            fontWeight: FontWeight.w700,
                            color: relationColor,
                            fontFamily: FontConfig.primary,
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
                          const SizedBox(height: DSSpacing.xs),
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
                                const SizedBox(width: DSSpacing.xs),
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
                      const SizedBox(height: DSSpacing.xs),
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

                // 실생활 예시 (새로 추가)
                if (realLife != null && realLife.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: DSColors.accentSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                      border: Border.all(
                        color: DSColors.accentSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: DSColors.accentSecondary,
                            ),
                            const SizedBox(width: DSSpacing.xs),
                            Text(
                              '실생활에서는?',
                              style: context.labelMedium.copyWith(
                                color: DSColors.accentSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          realLife,
                          style: context.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 조언 (새로 추가)
                if (advice != null && advice.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DSSpacing.md),
                    decoration: BoxDecoration(
                      color: DSColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                      border: Border.all(
                        color: DSColors.success.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.tips_and_updates_outlined,
                              size: 18,
                              color: DSColors.success,
                            ),
                            const SizedBox(width: DSSpacing.xs),
                            Text(
                              '이럴 때 이렇게!',
                              style: context.labelMedium.copyWith(
                                color: DSColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DSSpacing.sm),
                        Text(
                          advice,
                          style: context.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: DSSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
