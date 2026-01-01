import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_system/design_system.dart';

/// 오늘의 결과 날짜 라벨 위젯
///
/// 운세 결과 페이지 상단에 표시하여 매일 접속을 유도합니다.
/// "오늘 2026년 1월 1일 목요일" 형식으로 표시됩니다.
///
/// 사용법:
/// ```dart
/// const TodayResultLabel() // 기본 (accent 색상)
/// const TodayResultLabel(useLightTheme: true) // 그라데이션 배경용 (흰색)
/// const TodayResultLabel(showRevisitHint: true) // 재방문 유도 문구 표시
/// ```
class TodayResultLabel extends StatelessWidget {
  /// 컴팩트 모드 (아이콘 없이 텍스트만)
  final bool compact;

  /// 밝은 테마 사용 (그라데이션 배경에서 사용)
  final bool useLightTheme;

  /// 재방문 유도 문구 표시 ("내일 새로운 인사이트!")
  final bool showRevisitHint;

  const TodayResultLabel({
    super.key,
    this.compact = false,
    this.useLightTheme = false,
    this.showRevisitHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final dateText = DateFormat('M월 d일 EEEE', 'ko_KR').format(now);

    // 색상 결정: 밝은 테마면 흰색, 아니면 accent
    final labelColor = useLightTheme ? Colors.white : colors.accent;
    final bgColor = useLightTheme
        ? Colors.white.withValues(alpha: 0.2)
        : colors.accent.withValues(alpha: 0.1);
    final hintColor = useLightTheme
        ? Colors.white.withValues(alpha: 0.8)
        : colors.textSecondary;

    if (compact) {
      return Text(
        '오늘 $dateText',
        style: DSTypography.labelSmall.copyWith(
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: useLightTheme
                ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: labelColor,
              ),
              const SizedBox(width: 6),
              Text(
                '오늘의 인사이트',
                style: DSTypography.labelMedium.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: labelColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateText,
                style: DSTypography.labelSmall.copyWith(
                  color: labelColor.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (showRevisitHint) ...[
          const SizedBox(height: 6),
          Text(
            '내일이 되면 새로운 인사이트가 준비돼요',
            style: DSTypography.labelSmall.copyWith(
              color: hintColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
