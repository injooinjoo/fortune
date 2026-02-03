import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/design_system/design_system.dart';

/// 공유 바텀시트 - 카카오톡/인스타그램 전용
class SocialShareBottomSheet extends ConsumerStatefulWidget {
  final String fortuneTitle;
  final String fortuneContent;
  final String? userName;
  final Uint8List? previewImage;
  final Function(SharePlatform platform) onShare;

  const SocialShareBottomSheet({
    super.key,
    required this.fortuneTitle,
    required this.fortuneContent,
    this.userName,
    this.previewImage,
    required this.onShare,
  });

  @override
  ConsumerState<SocialShareBottomSheet> createState() =>
      _SocialShareBottomSheetState();
}

class _SocialShareBottomSheetState extends ConsumerState<SocialShareBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DSRadius.xl),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들 바
                _buildHandle(colors),

                // 헤더
                _buildHeader(context, colors, typography, isDark),

                const SizedBox(height: DSSpacing.lg),

                // 공유 버튼들 (카카오톡, 인스타그램)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildShareButton(
                          context: context,
                          platform: SharePlatform.kakaoTalk,
                          label: '카카오톡',
                          svgPath: 'assets/images/social/kakao.svg',
                          backgroundColor: const Color(0xFFFEE500), // 브랜드 고유 색상 - Kakao
                          textColor: const Color(0xFF391B1B), // 브랜드 고유 색상 - Kakao
                        ),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: _buildShareButton(
                          context: context,
                          platform: SharePlatform.instagram,
                          label: '인스타그램',
                          svgPath: 'assets/images/social/instagram.svg',
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFF262626), // 브랜드 고유 색상 - Instagram
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DSSpacing.lg),

                // 구분선
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: colors.textPrimary.withValues(alpha: 0.08),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.md,
                        ),
                        child: Text(
                          '또는',
                          style: typography.labelSmall.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: colors.textPrimary.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DSSpacing.lg),

                // 저장 옵션 (갤러리 저장, 텍스트 복사)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onShare(SharePlatform.gallery);
                            Navigator.of(context).pop();
                          },
                          icon: Icons.download_rounded,
                          label: '이미지 저장',
                          colors: colors,
                          typography: typography,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.md),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onShare(SharePlatform.copy);
                            Navigator.of(context).pop();
                          },
                          icon: Icons.content_copy_rounded,
                          label: '텍스트 복사',
                          colors: colors,
                          typography: typography,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DSSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle(DSColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colors.textPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DSColorScheme colors,
    DSTypographyScheme typography,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        DSSpacing.lg,
        DSSpacing.sm,
        0,
      ),
      child: Row(
        children: [
          // 공유 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.md),
            ),
            child: Icon(
              Icons.share_rounded,
              color: colors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: DSSpacing.md),

          // 타이틀
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공유하기',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '친구들과 결과를 공유해보세요',
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 닫기 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: colors.textTertiary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required BuildContext context,
    required SharePlatform platform,
    required String label,
    required String svgPath,
    Color? backgroundColor,
    Gradient? gradient,
    required Color textColor,
  }) {
    final typography = context.typography;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onShare(platform);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null ? backgroundColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? Colors.purple).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: DSSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 정식 SVG 아이콘
                SvgPicture.asset(
                  svgPath,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(height: DSSpacing.sm),
                Text(
                  label,
                  style: typography.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required DSColorScheme colors,
    required DSTypographyScheme typography,
  }) {
    return Material(
      color: colors.backgroundSecondary,
      borderRadius: BorderRadius.circular(DSRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: DSSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: colors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                label,
                style: typography.labelMedium.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SharePlatform {
  kakaoTalk,
  instagram,
  facebook,
  twitter,
  whatsapp,
  gallery,
  copy,
  other,
}
