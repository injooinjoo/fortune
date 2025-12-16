/// TOP 3 재능 위젯
///
/// 십성(十星) 기반으로 추출된 상위 3개 재능을 표시합니다.
/// 각 재능에 대해:
/// - 설명 (이 재능이 뭔지)
/// - 발현 모습 (어떻게 나타나는지)
/// - 개발 가이드 (어떻게 키울지)
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/components/app_card.dart';
import '../../domain/models/sipseong_talent.dart';

class TalentTop3Widget extends StatelessWidget {
  final List<SipseongTalent> top3Talents;

  const TalentTop3Widget({
    super.key,
    required this.top3Talents,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            'TOP 3 재능',
            style: DSTypography.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '사주팔자 십성 분석 결과, 당신에게 가장 강한 3가지 재능입니다',
            style: DSTypography.bodySmall.copyWith(
              height: 1.5,
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // TOP 3 재능 카드
          ...top3Talents.asMap().entries.map((entry) {
            final index = entry.key;
            final talent = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
              child: _TalentRankCard(
                rank: index + 1,
                talent: talent,
              ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms),
            );
          }),
        ],
      ),
    );
  }
}

class _TalentRankCard extends StatelessWidget {
  final int rank;
  final SipseongTalent talent;

  const _TalentRankCard({
    required this.rank,
    required this.talent,
  });

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  String _getRankBadge(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rankColor = _getRankColor(rank);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 순위 + 재능 이름
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: rankColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getRankBadge(rank),
                      style: DSTypography.labelMedium,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'TOP $rank',
                      style: DSTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: rankColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                talent.emoji,
                style: DSTypography.displaySmall,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      talent.title,
                      style: DSTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${talent.name}(十星)',
                      style: DSTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 재능 설명
          _buildSection(
            isDark: isDark,
            icon: '✨',
            title: '이 재능은',
            content: talent.talentDescription,
          ),
          const SizedBox(height: 12),

          // 발현 모습
          _buildSection(
            isDark: isDark,
            icon: '🎯',
            title: '발현 모습',
            content: talent.manifestation,
          ),
          const SizedBox(height: 12),

          // 개발 가이드
          _buildSection(
            isDark: isDark,
            icon: '📈',
            title: '개발 가이드',
            content: talent.developmentGuide,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: DSTypography.labelMedium,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: DSTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: DSTypography.bodySmall.copyWith(
              height: 1.6,
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 간단한 TOP 3 요약 위젯 (헤더용)
class TalentTop3Summary extends StatelessWidget {
  final List<SipseongTalent> top3Talents;

  const TalentTop3Summary({
    super.key,
    required this.top3Talents,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.accent.withValues(alpha: 0.1),
            DSColors.accentDark.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '당신의 TOP 3 재능',
            style: DSTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...top3Talents.asMap().entries.map((entry) {
            final index = entry.key;
            final talent = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: DSColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DSColors.accent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: DSTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: DSColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    talent.emoji,
                    style: DSTypography.headingSmall,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      talent.title,
                      style: DSTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
