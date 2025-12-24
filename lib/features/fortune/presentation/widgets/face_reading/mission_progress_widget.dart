import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/theme/typography_unified.dart';

/// 미션 진행률 위젯
/// 진행률을 재미있게 표시합니다 (자기계발 느낌 ❌)
///
/// 핵심 가치: 위로·공감·공유 (자기계발 ❌)
/// 타겟: 2-30대 여성
class MissionProgressWidget extends StatelessWidget {
  /// 현재 진행 횟수
  final int currentCount;

  /// 목표 횟수
  final int targetCount;

  /// 미션 타입
  final MissionType missionType;

  /// 다크 모드 여부
  final bool isDark;

  /// 미션 완료 콜백
  final VoidCallback? onComplete;

  const MissionProgressWidget({
    super.key,
    required this.currentCount,
    required this.targetCount,
    required this.missionType,
    this.isDark = false,
    this.onComplete,
  });

  double get progress =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  bool get isComplete => currentCount >= targetCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? DSColors.success.withValues(alpha: 0.4)
              : isDark
                  ? DSColors.borderDark
                  : DSColors.border,
        ),
      ),
      child: Row(
        children: [
          // 미션 아이콘
          _buildMissionIcon(context),
          const SizedBox(width: 14),

          // 미션 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMissionTitle(),
                  style: context.labelMedium.copyWith(
                    color: isDark
                        ? DSColors.textPrimaryDark
                        : DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMissionSubtitle(),
                  style: context.labelSmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // 진행 바
                _buildProgressBar(context),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 보상
          _buildReward(context),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 미션 아이콘
  Widget _buildMissionIcon(BuildContext context) {
    final (emoji, color) = _getMissionStyle();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isComplete
            ? DSColors.success.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          if (isComplete)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: DSColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 진행 바
  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? DSColors.borderDark
                      : DSColors.border.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? DSColors.success : DSColors.accent,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$currentCount/$targetCount',
              style: context.labelSmall.copyWith(
                color: isComplete
                    ? DSColors.success
                    : isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 보상 표시
  Widget _buildReward(BuildContext context) {
    final reward = _getMissionReward();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete
            ? DSColors.success.withValues(alpha: 0.15)
            : DSColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '💎',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            '+$reward',
            style: context.labelSmall.copyWith(
              color: isComplete ? DSColors.success : DSColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 미션 타이틀
  String _getMissionTitle() {
    switch (missionType) {
      case MissionType.dailySmile:
        return '오늘의 미소';
      case MissionType.weeklyStreak:
        return '7일 연속 기록';
      case MissionType.shareResult:
        return '친구와 나누기';
      case MissionType.firstAnalysis:
        return '첫 분석';
      case MissionType.morningCheck:
        return '아침 체크인';
      case MissionType.eveningReflection:
        return '하루 마무리';
    }
  }

  /// 미션 서브타이틀
  String _getMissionSubtitle() {
    if (isComplete) {
      return '완료했어요! 🎉';
    }

    switch (missionType) {
      case MissionType.dailySmile:
        return '오늘도 웃는 얼굴 남기기';
      case MissionType.weeklyStreak:
        return '매일 꾸준히 기록하면 선물이!';
      case MissionType.shareResult:
        return '분석 결과를 공유해 보세요';
      case MissionType.firstAnalysis:
        return '첫 관상 분석을 해 보세요';
      case MissionType.morningCheck:
        return '아침에 컨디션을 확인해요';
      case MissionType.eveningReflection:
        return '오늘 하루를 돌아봐요';
    }
  }

  /// 미션 스타일 (이모지, 색상)
  (String, Color) _getMissionStyle() {
    switch (missionType) {
      case MissionType.dailySmile:
        return ('😊', DSColors.accent);
      case MissionType.weeklyStreak:
        return ('🔥', DSColors.warning);
      case MissionType.shareResult:
        return ('💕', DSColors.accentSecondary);
      case MissionType.firstAnalysis:
        return ('✨', DSColors.success);
      case MissionType.morningCheck:
        return ('🌅', DSColors.warning);
      case MissionType.eveningReflection:
        return ('🌙', DSColors.accentSecondary);
    }
  }

  /// 미션 보상
  int _getMissionReward() {
    switch (missionType) {
      case MissionType.dailySmile:
        return 5;
      case MissionType.weeklyStreak:
        return 30;
      case MissionType.shareResult:
        return 10;
      case MissionType.firstAnalysis:
        return 20;
      case MissionType.morningCheck:
        return 3;
      case MissionType.eveningReflection:
        return 3;
    }
  }
}

/// 미션 타입
enum MissionType {
  dailySmile,
  weeklyStreak,
  shareResult,
  firstAnalysis,
  morningCheck,
  eveningReflection,
}

/// 미션 목록 카드
class MissionListCard extends StatelessWidget {
  /// 미션 목록
  final List<MissionItem> missions;

  /// 다크 모드 여부
  final bool isDark;

  /// 미션 탭 콜백
  final void Function(MissionItem mission)? onMissionTap;

  const MissionListCard({
    super.key,
    required this.missions,
    this.isDark = false,
    this.onMissionTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = missions.where((m) => m.isComplete).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surfaceDark : DSColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? DSColors.borderDark : DSColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DSColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🎯',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 작은 도전',
                      style: context.labelMedium.copyWith(
                        color: isDark
                            ? DSColors.textPrimaryDark
                            : DSColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completedCount/${missions.length} 완료',
                      style: context.labelSmall.copyWith(
                        color: isDark
                            ? DSColors.textSecondaryDark
                            : DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 총 보상
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DSColors.accent.withValues(alpha: 0.15),
                      DSColors.accentSecondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${_getTotalReward()}',
                      style: context.labelMedium.copyWith(
                        color: DSColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 미션 목록
          ...missions.map((mission) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => onMissionTap?.call(mission),
                  child: MissionProgressWidget(
                    currentCount: mission.currentCount,
                    targetCount: mission.targetCount,
                    missionType: mission.type,
                    isDark: isDark,
                  ),
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  int _getTotalReward() {
    return missions
        .where((m) => m.isComplete)
        .map((m) => m.reward)
        .fold(0, (sum, reward) => sum + reward);
  }
}

/// 미션 아이템 데이터
class MissionItem {
  final MissionType type;
  final int currentCount;
  final int targetCount;
  final int reward;

  MissionItem({
    required this.type,
    required this.currentCount,
    required this.targetCount,
    required this.reward,
  });

  bool get isComplete => currentCount >= targetCount;
}
