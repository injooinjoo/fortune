import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';

/// 토스 스타일 정보 배너 위젯
///
/// 토스 앱의 "재직중인 회사에서..." 같은 배너 디자인을 재현한 공용 컴포넌트
///
/// 사용 예시:
/// ```dart
/// InfoBanner(
///   icon: Icons.calendar_month,
///   iconColor: TossDesignSystem.tossBlue,
///   title: '캘린더 연동으로 더 정확한 운세를!',
///   subtitle: '일정 기반 맞춤 조언을 받아보세요',
///   onTap: _syncCalendar,
///   onClose: () => setState(() => _showBanner = false),
/// )
/// ```
class InfoBanner extends StatelessWidget {
  /// 배너 좌측에 표시될 아이콘
  final IconData icon;

  /// 아이콘 색상
  final Color iconColor;

  /// 배너 메인 타이틀
  final String title;

  /// 배너 서브타이틀 (선택사항)
  final String? subtitle;

  /// 배너 탭 시 호출될 콜백
  final VoidCallback? onTap;

  /// X 버튼 탭 시 호출될 콜백
  final VoidCallback onClose;

  /// 배너 배경색 (선택사항, 기본값은 tossBlue)
  final Color? backgroundColor;

  /// 커스텀 우측 위젯 (선택사항, 기본값은 화살표)
  final Widget? trailing;

  const InfoBanner({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.onClose,
    this.backgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // backgroundColor가 transparent이면 배경색 없이 테두리만
    final isTransparent = backgroundColor == Colors.transparent;
    final bgColor = isTransparent
        ? Colors.transparent
        : (backgroundColor ??
            TossDesignSystem.tossBlue.withValues(alpha: isDark ? 0.15 : 0.08));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTransparent
              ? (isDark ? Colors.white24 : Colors.black12)
              : ((backgroundColor ?? TossDesignSystem.tossBlue)
                  .withValues(alpha: isDark ? 0.3 : 0.2)),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 좌측 체크 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // 중앙 텍스트 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? TossDesignSystem.textPrimaryDark
                              : TossDesignSystem.textPrimaryLight,
                          height: 1.3,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: context.bodySmall.copyWith(
                            color: isDark
                                ? TossDesignSystem.textSecondaryDark
                                : TossDesignSystem.textSecondaryLight,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 우측 영역 (커스텀 또는 화살표)
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossDesignSystem.textSecondaryLight,
                  ),
                const SizedBox(width: 8),
                // 우측 X 닫기 버튼
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: isDark
                          ? TossDesignSystem.textSecondaryDark
                          : TossDesignSystem.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 토스 스타일 배너의 변형 버전들

/// 성공 배너 (초록색)
class TossSuccessBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback onClose;

  const TossSuccessBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InfoBanner(
      icon: Icons.check_circle_outline,
      iconColor: TossDesignSystem.successGreen,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      onClose: onClose,
      backgroundColor: TossDesignSystem.successGreen,
    );
  }
}

/// 경고 배너 (주황색)
class TossWarningBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback onClose;

  const TossWarningBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InfoBanner(
      icon: Icons.warning_amber_rounded,
      iconColor: TossDesignSystem.warningOrange,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      onClose: onClose,
      backgroundColor: TossDesignSystem.warningOrange,
    );
  }
}

/// 에러 배너 (빨간색)
class TossErrorBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback onClose;

  const TossErrorBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InfoBanner(
      icon: Icons.error_outline,
      iconColor: TossDesignSystem.errorRed,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      onClose: onClose,
      backgroundColor: TossDesignSystem.errorRed,
    );
  }
}
