import 'package:flutter/material.dart';
import '../../../../../../core/theme/typography_unified.dart';

/// 개인정보 보호 안내 배너
/// 사용자에게 사진이 서버에 저장되지 않음을 안내합니다.
class PrivacyNoticeBanner extends StatelessWidget {
  /// 배너 스타일
  final PrivacyBannerStyle style;

  /// 더 알아보기 클릭 콜백
  final VoidCallback? onLearnMore;

  const PrivacyNoticeBanner({
    super.key,
    this.style = PrivacyBannerStyle.compact,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: style == PrivacyBannerStyle.compact ? 16 : 0,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.green.shade900.withOpacity(0.3)
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade200.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 안전 아이콘
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: Colors.green.shade700,
              size: style == PrivacyBannerStyle.compact ? 18 : 24,
            ),
          ),
          const SizedBox(width: 12),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '사진은 서버에 저장되지 않아요',
                  style: context.bodyMedium.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (style == PrivacyBannerStyle.expanded) ...[
                  const SizedBox(height: 4),
                  Text(
                    '분석 후 즉시 삭제되니 안심하세요',
                    style: context.bodySmall.copyWith(
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 더 알아보기 버튼
          if (onLearnMore != null)
            TextButton(
              onPressed: onLearnMore,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '자세히',
                style: context.labelSmall.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 배너 스타일
enum PrivacyBannerStyle {
  /// 한 줄 간략 표시
  compact,

  /// 두 줄 상세 표시
  expanded,
}

/// 인라인 개인정보 안내 텍스트
/// 카메라 화면 하단 등에 사용
class PrivacyNoticeInline extends StatelessWidget {
  const PrivacyNoticeInline({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock_outline,
          size: 14,
          color: Colors.white.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '사진은 분석 후 즉시 삭제됩니다',
          style: context.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
