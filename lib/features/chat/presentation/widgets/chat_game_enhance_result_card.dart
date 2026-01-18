import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/theme/obangseok_colors.dart';

/// 채팅용 게임 강화운세 결과 카드
///
/// Edge Function 응답 필드:
/// - score, lucky_grade, status_message
/// - enhance_stats (success_aura, protection_field, chance_time_active, stack_bonus)
/// - lucky_times (golden_hour, golden_hour_range, avoid_time)
/// - enhance_ritual (lucky_spot, lucky_direction, lucky_action, lucky_phrase)
/// - enhance_roadmap[] (phase, action, tip, risk_level)
/// - lucky_info (lucky_number, lucky_color, lucky_food)
/// - warnings[], encouragement{}, hashtags[]
class ChatGameEnhanceResultCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> fortuneData;
  final String fortuneId;

  const ChatGameEnhanceResultCard({
    super.key,
    required this.fortuneData,
    required this.fortuneId,
  });

  @override
  ConsumerState<ChatGameEnhanceResultCard> createState() =>
      _ChatGameEnhanceResultCardState();
}

class _ChatGameEnhanceResultCardState
    extends ConsumerState<ChatGameEnhanceResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get fortuneData => widget.fortuneData;
  String get fortuneId => widget.fortuneId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      child: DSCard.hanji(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 게임 스타일 히어로 헤더
            _buildGameHeroHeader(context),

            // 2. 강화 스탯 (게이지 바)
            _buildEnhanceStatsSection(context),

            // 3. 황금 시간
            _buildLuckyTimesSection(context),

            // 4. 강화 의식
            _buildEnhanceRitualSection(context),

            // 5. 강화 로드맵
            _buildEnhanceRoadmapSection(context),

            // 6. 행운 정보
            _buildLuckyInfoSection(context),

            // 7. 주의사항
            _buildWarningsSection(context),

            // 8. 응원 메시지
            _buildEncouragementSection(context),

            // 9. 해시태그
            _buildHashtagsSection(context),

            // 10. 복주머니 후원
            _buildDonationSection(context),

            const SizedBox(height: DSSpacing.sm),
          ],
        ),
      ),
    );
  }

  /// 게임 스타일 히어로 헤더
  Widget _buildGameHeroHeader(BuildContext context) {
    final typography = context.typography;
    final score = fortuneData['score'] as int? ?? 80;
    final luckyGrade = fortuneData['lucky_grade'] as String? ?? 'A';
    final statusMessage =
        fortuneData['status_message'] as String? ?? '강화 기운이 좋아요!';

    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 다이나믹 그라데이션 배경
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getGradeGradientStart(luckyGrade),
                      _getGradeGradientEnd(luckyGrade),
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
              );
            },
          ),

          // 2. 파티클 효과 오버레이
          Positioned.fill(
            child: CustomPaint(
              painter: _GameParticlePainter(
                animation: _animController,
                gradeColor: _getGradeColor(luckyGrade),
              ),
            ),
          ),

          // 3. 헥스 패턴 오버레이 (게임 느낌)
          Positioned.fill(
            child: CustomPaint(
              painter: _HexPatternPainter(),
            ),
          ),

          // 4. 중앙 무기 아이콘 + 글로우
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _buildWeaponIcon(luckyGrade),
                );
              },
            ),
          ),

          // 5. 뱃지 (좌상단)
          Positioned(
            top: DSSpacing.sm,
            left: DSSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(DSRadius.full),
                border: Border.all(
                  color: _getGradeColor(luckyGrade).withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    'ENHANCE',
                    style: typography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. 액션 버튼 (우상단)
          Positioned(
            top: DSSpacing.sm,
            right: DSSpacing.sm,
            child: FortuneActionButtons(
              contentId: fortuneId,
              contentType: 'gameEnhance',
              fortuneType: 'gameEnhance',
              shareTitle: '강화의 기운',
              shareContent: statusMessage,
              iconColor: Colors.white,
              iconSize: 20,
            ),
          ),

          // 7. 등급 + 점수 (우측 중앙)
          Positioned(
            right: DSSpacing.md,
            top: 50,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: _getGradeColor(luckyGrade)
                            .withValues(alpha: 0.3 * _glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 등급 뱃지
                      _buildGradeBadge(luckyGrade, typography),
                      const SizedBox(height: 8),
                      // 점수
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(DSRadius.md),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$score',
                              style: typography.headingMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'PT',
                              style: typography.labelSmall.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 8. 타이틀 & 메시지 (하단)
          Positioned(
            left: DSSpacing.md,
            right: DSSpacing.md,
            bottom: DSSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔥 강화의 기운',
                  style: typography.headingSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: _getGradeColor(luckyGrade).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    statusMessage,
                    style: typography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 무기 아이콘 빌더
  Widget _buildWeaponIcon(String grade) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _getGradeColor(grade).withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Text(
              _getWeaponEmoji(grade),
              style: const TextStyle(fontSize: 48),
            ),
          ),
        ),
      ],
    );
  }

  /// 등급 뱃지 빌더
  Widget _buildGradeBadge(String grade, DSTypographyScheme typography) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getGradeColor(grade),
            _getGradeColor(grade).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getGradeColor(grade).withValues(alpha: 0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        grade,
        style: typography.headingSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhanceStatsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final stats = fortuneData['enhance_stats'] as Map<String, dynamic>? ?? {};

    final successAura = stats['success_aura'] as int? ?? 80;
    final successAuraDesc = stats['success_aura_desc'] as String? ?? '';
    final protectionField = stats['protection_field'] as int? ?? 70;
    final protectionFieldDesc = stats['protection_field_desc'] as String? ?? '';
    final chanceTimeActive = stats['chance_time_active'] as bool? ?? false;
    final chanceTimeDesc = stats['chance_time_desc'] as String? ?? '';
    final stackBonus = stats['stack_bonus'] as String? ?? 'STABLE';
    final stackBonusDesc = stats['stack_bonus_desc'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: const Text('📊', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '강화 스탯',
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 성공 기운 게이지
          _buildStatGaugeBar(
            context,
            icon: '✨',
            label: '성공 기운',
            value: successAura,
            color: const Color(0xFFFF6B00),
            desc: successAuraDesc,
          ),
          const SizedBox(height: DSSpacing.sm),

          // 파괴 방어 게이지
          _buildStatGaugeBar(
            context,
            icon: '🛡️',
            label: '파괴 방어',
            value: protectionField,
            color: const Color(0xFF3B82F6),
            desc: protectionFieldDesc,
          ),
          const SizedBox(height: DSSpacing.sm),

          // 스택 보너스
          Row(
            children: [
              _buildStackBonusChip(context, stackBonus),
              if (stackBonusDesc.isNotEmpty) ...[
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Text(
                    stackBonusDesc,
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // 찬스타임
          if (chanceTimeActive) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildChanceTimeCard(context, chanceTimeDesc),
          ],
        ],
      ),
    );
  }

  /// 스탯 게이지 바
  Widget _buildStatGaugeBar(
    BuildContext context, {
    required String icon,
    required String label,
    required int value,
    required Color color,
    String desc = '',
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: typography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: typography.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 게이지 바
        Stack(
          children: [
            // 배경
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // 진행 바
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: 12,
              width: (MediaQuery.of(context).size.width - 64) * (value / 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // 하이라이트
            Positioned(
              top: 2,
              left: 4,
              right: 4,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            desc,
            style: typography.bodySmall.copyWith(
              color: colors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  /// 스택 보너스 칩
  Widget _buildStackBonusChip(BuildContext context, String stackBonus) {
    final typography = context.typography;
    final color = _getStackColor(stackBonus);
    final icon = _getStackIcon(stackBonus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DSRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '스택 $stackBonus',
            style: typography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 찬스타임 카드
  Widget _buildChanceTimeCard(BuildContext context, String desc) {
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.2),
            const Color(0xFFFF6B00).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Text('⚡', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔥 찬스타임 활성화!',
                  style: typography.labelMedium.copyWith(
                    color: const Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: typography.bodySmall.copyWith(
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyTimesSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final luckyTimes =
        fortuneData['lucky_times'] as Map<String, dynamic>? ?? {};

    final goldenHour = luckyTimes['golden_hour'] as String? ?? '';
    final goldenHourRange = luckyTimes['golden_hour_range'] as String? ?? '';
    final goldenHourReason = luckyTimes['golden_hour_reason'] as String? ?? '';
    final avoidTime = luckyTimes['avoid_time'] as String? ?? '';
    final avoidTimeReason = luckyTimes['avoid_time_reason'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A5F).withValues(alpha: 0.1),
              const Color(0xFF0F172A).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: const Text('⏰', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '황금 시간',
                  style: typography.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 황금 시간
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        goldenHour.isNotEmpty ? goldenHour : goldenHourRange,
                        style: typography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (goldenHourRange.isNotEmpty && goldenHour.isNotEmpty) ...[
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    '($goldenHourRange)',
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (goldenHourReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '💫 $goldenHourReason',
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: DSSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: DSSpacing.sm),

            // 피해야 할 시간
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ObangseokColors.jeokMuted.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    border: Border.all(
                      color: ObangseokColors.jeokMuted.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        avoidTime,
                        style: typography.labelMedium.copyWith(
                          color: ObangseokColors.jeokMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '피하세요',
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
            if (avoidTimeReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  avoidTimeReason,
                  style: typography.bodySmall.copyWith(
                    color: colors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhanceRitualSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final ritual = fortuneData['enhance_ritual'] as Map<String, dynamic>? ?? {};

    final luckySpot = ritual['lucky_spot'] as String? ?? '';
    final luckyDirection = ritual['lucky_direction'] as String? ?? '';
    final luckyAction = ritual['lucky_action'] as String? ?? '';
    final luckyPhrase = ritual['lucky_phrase'] as String? ?? '';
    final avoidAction = ritual['avoid_action'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFA855F7).withValues(alpha: 0.1),
              const Color(0xFF7C3AED).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: const Color(0xFFA855F7).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: const Text('🧙', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: DSSpacing.sm),
                Text(
                  '강화 의식',
                  style: typography.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                  ),
                  child: Text(
                    'RITUAL',
                    style: typography.labelSmall.copyWith(
                      color: const Color(0xFFA855F7),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),

            // 의식 항목들
            _buildRitualStep(context, 1, '📍', '위치', luckySpot),
            _buildRitualStep(context, 2, '👀', '방향', luckyDirection),
            _buildRitualStep(context, 3, '🕺', '액션', luckyAction),
            if (luckyPhrase.isNotEmpty)
              _buildRitualStep(context, 4, '💬', '주문', '"$luckyPhrase"',
                  isHighlight: true),
            if (avoidAction.isNotEmpty)
              _buildRitualStep(context, 5, '🚫', '금지', avoidAction,
                  isWarning: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRitualStep(
    BuildContext context,
    int step,
    String icon,
    String label,
    String value, {
    bool isHighlight = false,
    bool isWarning = false,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스텝 번호
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isWarning
                  ? ObangseokColors.jeokMuted.withValues(alpha: 0.2)
                  : isHighlight
                      ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                      : const Color(0xFFA855F7).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: typography.labelSmall.copyWith(
                  color: isWarning
                      ? ObangseokColors.jeokMuted
                      : isHighlight
                          ? const Color(0xFFB45309)
                          : const Color(0xFFA855F7),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: typography.bodySmall.copyWith(
                color: isWarning
                    ? ObangseokColors.jeokMuted
                    : isHighlight
                        ? const Color(0xFFB45309)
                        : colors.textPrimary,
                fontWeight: isHighlight || isWarning ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhanceRoadmapSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final roadmap = fortuneData['enhance_roadmap'] as List? ?? [];

    if (roadmap.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                ),
                child: const Text('🗺️', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '강화 로드맵',
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          ...roadmap.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final phase = item['phase'] as String? ?? '';
            final action = item['action'] as String? ?? '';
            final tip = item['tip'] as String? ?? '';
            final riskLevel = item['risk_level'] as String? ?? 'low';
            final isLast = index == roadmap.length - 1;

            return _buildRoadmapItem(
              context,
              index: index + 1,
              phase: phase,
              action: action,
              tip: tip,
              riskLevel: riskLevel,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRoadmapItem(
    BuildContext context, {
    required int index,
    required String phase,
    required String action,
    required String tip,
    required String riskLevel,
    required bool isLast,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final riskColor = _getRiskColor(riskLevel);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [riskColor, riskColor.withValues(alpha: 0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: riskColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: typography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      riskColor.withValues(alpha: 0.5),
                      colors.border.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: DSSpacing.sm),
        // 콘텐츠
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : DSSpacing.xs),
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border.all(
                color: riskColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        phase,
                        style: typography.labelMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(DSRadius.full),
                      ),
                      child: Text(
                        riskLevel.toUpperCase(),
                        style: typography.labelSmall.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (tip.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 $tip',
                    style: typography.bodySmall.copyWith(
                      color: colors.textTertiary,
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyInfoSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final luckyInfo = fortuneData['lucky_info'] as Map<String, dynamic>? ?? {};

    final luckyNumber = luckyInfo['lucky_number'];
    final luckyNumberMeaning =
        luckyInfo['lucky_number_meaning'] as String? ?? '';
    final luckyColor = luckyInfo['lucky_color'] as String? ?? '';
    final luckyColorTip = luckyInfo['lucky_color_tip'] as String? ?? '';
    final luckyFood = luckyInfo['lucky_food'] as String? ?? '';
    final luckyFoodReason = luckyInfo['lucky_food_reason'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🍀', style: TextStyle(fontSize: 20)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '행운 정보',
                  style: typography.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),

            Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              children: [
                if (luckyNumber != null)
                  _buildLuckyChip(
                      context, '🔢', '$luckyNumber', luckyNumberMeaning),
                if (luckyColor.isNotEmpty)
                  _buildLuckyChip(context, '🎨', luckyColor, luckyColorTip),
                if (luckyFood.isNotEmpty)
                  _buildLuckyChip(context, '🍽️', luckyFood, luckyFoodReason),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyChip(
    BuildContext context,
    String icon,
    String value,
    String tooltip,
  ) {
    final colors = context.colors;
    final typography = context.typography;

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.full),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: typography.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final warnings = fortuneData['warnings'] as List? ?? [];

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: ObangseokColors.jeokMuted.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: ObangseokColors.jeokMuted.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '주의사항',
                  style: typography.labelMedium.copyWith(
                    color: ObangseokColors.jeokMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            ...warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: typography.bodySmall.copyWith(
                          color: ObangseokColors.jeokMuted,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          warning.toString(),
                          style: typography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEncouragementSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final encouragement =
        fortuneData['encouragement'] as Map<String, dynamic>? ?? {};

    final beforeEnhance = encouragement['before_enhance'] as String? ?? '';

    if (beforeEnhance.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6B00).withValues(alpha: 0.15),
              const Color(0xFFFFD700).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Text('💪', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                beforeEnhance,
                style: typography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashtagsSection(BuildContext context) {
    final typography = context.typography;
    final hashtags = fortuneData['hashtags'] as List? ?? [];

    if (hashtags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.xs,
      ),
      child: Wrap(
        spacing: DSSpacing.xs,
        children: hashtags.map((tag) {
          return Text(
            tag.toString(),
            style: typography.labelSmall.copyWith(
              color: const Color(0xFFFF6B00),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDonationSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFDC2626).withValues(alpha: 0.1),
              const Color(0xFFEA580C).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: const Color(0xFFDC2626).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🧧', style: TextStyle(fontSize: 24)),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '강화 기운 더 받기',
                  style: typography.labelLarge.copyWith(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDonationButton(context, '1천원', '+5%', Colors.green),
                _buildDonationButton(context, '3천원', '+15%', Colors.blue),
                _buildDonationButton(
                    context, '5천원', '+30%', const Color(0xFFA855F7)),
              ],
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '복주머니로 강화 기운 충전!',
              style: typography.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationButton(
    BuildContext context,
    String amount,
    String bonus,
    Color accentColor,
  ) {
    final typography = context.typography;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$amount 후원 기능 준비 중입니다'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              amount,
              style: typography.labelMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              bonus,
              style: typography.labelSmall.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Helper Methods =====

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'SSS':
        return const Color(0xFFFFD700); // 골드
      case 'SS':
        return const Color(0xFFA855F7); // 보라 (에픽)
      case 'S':
        return const Color(0xFFFF6B00); // 오렌지
      case 'A':
        return const Color(0xFF3B82F6); // 파랑
      case 'B':
        return const Color(0xFF10B981); // 초록
      default:
        return const Color(0xFF6B7280); // 회색
    }
  }

  Color _getGradeGradientStart(String grade) {
    switch (grade) {
      case 'SSS':
        return const Color(0xFFB8860B);
      case 'SS':
        return const Color(0xFF7C3AED);
      case 'S':
        return const Color(0xFFEA580C);
      case 'A':
        return const Color(0xFF1D4ED8);
      case 'B':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF4B5563);
    }
  }

  Color _getGradeGradientEnd(String grade) {
    switch (grade) {
      case 'SSS':
        return const Color(0xFFFFD700);
      case 'SS':
        return const Color(0xFFC084FC);
      case 'S':
        return const Color(0xFFFBBF24);
      case 'A':
        return const Color(0xFF60A5FA);
      case 'B':
        return const Color(0xFF34D399);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String _getWeaponEmoji(String grade) {
    switch (grade) {
      case 'SSS':
        return '⚔️';
      case 'SS':
        return '🗡️';
      case 'S':
        return '🔱';
      case 'A':
        return '🏹';
      case 'B':
        return '🛡️';
      default:
        return '⚒️';
    }
  }

  String _getStackIcon(String stackBonus) {
    switch (stackBonus) {
      case 'UP':
        return '📈';
      case 'DOWN':
        return '📉';
      default:
        return '➡️';
    }
  }

  Color _getStackColor(String stackBonus) {
    switch (stackBonus) {
      case 'UP':
        return const Color(0xFF10B981);
      case 'DOWN':
        return ObangseokColors.jeokMuted;
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

/// 게임 파티클 효과 페인터
class _GameParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Color gradeColor;

  _GameParticlePainter({
    required this.animation,
    required this.gradeColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    // 별/파티클 그리기
    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + animation.value * 30) % size.height;
      final radius = 1.0 + random.nextDouble() * 2;
      final alpha = 0.3 + random.nextDouble() * 0.5;

      paint.color = gradeColor.withValues(alpha: alpha * animation.value);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GameParticlePainter oldDelegate) => true;
}

/// 헥스 패턴 페인터 (게임 UI 느낌)
class _HexPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const hexSize = 30.0;
    final rows = (size.height / (hexSize * 1.5)).ceil() + 1;
    final cols = (size.width / (hexSize * 1.732)).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final xOffset = col * hexSize * 1.732 + (row % 2) * hexSize * 0.866;
        final yOffset = row * hexSize * 1.5;
        _drawHexagon(canvas, Offset(xOffset, yOffset), hexSize * 0.5, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * math.pi / 180;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
