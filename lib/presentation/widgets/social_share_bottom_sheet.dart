import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/theme/font_config.dart';

/// U09: 스크린샷 감지 UI 리뉴얼 - 한지 스타일 전통 디자인
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
    required this.onShare});

  @override
  ConsumerState<SocialShareBottomSheet> createState() => _SocialShareBottomSheetState();
}

class _SocialShareBottomSheetState extends ConsumerState<SocialShareBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // U09: Traditional Korean color palette (한지/오방색 스타일)
  static const _hanjiBeige = Color(0xFFFFF8E1);
  static const _traditionalBrown = Color(0xFF8D6E63);
  static const _lightBrown = Color(0xFFBCAAA4);
  static const _darkBrown = Color(0xFF5D4037);
  static const _sealRed = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this);

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: size.height * 0.72,
          decoration: BoxDecoration(
            // U09: 한지 스타일 배경
            color: isDark ? const Color(0xFF1C1C1E) : _hanjiBeige,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: _traditionalBrown.withValues(alpha: 0.3), width: 2),
              left: BorderSide(color: _traditionalBrown.withValues(alpha: 0.3), width: 2),
              right: BorderSide(color: _traditionalBrown.withValues(alpha: 0.3), width: 2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, -8))]),
          child: Transform.translate(
            offset: Offset(0, size.height * 0.72 * _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  _buildHandle(isDark),
                  _buildHeader(theme, isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildPreview(theme, isDark),
                          const SizedBox(height: 20),
                          _buildShareOptions(theme, isDark),
                          const SizedBox(height: 16),
                          _buildSaveOptions(theme, isDark),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: _traditionalBrown.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(3)));
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // U09: 전통 스타일 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _sealRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _sealRed.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text(
                '共',
                style: TextStyle(
                  color: _sealRed,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontConfig.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운세 공유하기',
                  style: TextStyle(
                    color: isDark ? Colors.white : _darkBrown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '친구들과 오늘의 운세를 나눠보세요',
                  style: TextStyle(
                    color: (isDark ? Colors.white : _darkBrown).withValues(alpha: 0.6),
                    fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: (isDark ? Colors.white : _darkBrown).withValues(alpha: 0.5),
            ),
            padding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme, bool isDark) {
    if (widget.previewImage == null) {
      return const SizedBox();
    }

    // U09: 한지 스타일 미리보기 카드
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _lightBrown.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '📜 미리보기',
            style: TextStyle(
              color: isDark ? Colors.white : _darkBrown,
              fontSize: 14,
              fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              widget.previewImage!,
              height: 160,
              fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOptions(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 16, color: _traditionalBrown),
            const SizedBox(width: 8),
            Text(
              'SNS로 공유하기',
              style: TextStyle(
                color: isDark ? Colors.white : _darkBrown,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildShareButton(
              platform: SharePlatform.kakaoTalk,
              label: '카카오톡',
              icon: Icons.chat_bubble,
              color: const Color(0xFFFEE500),
              iconColor: const Color(0xFF3C1E1E)),
            _buildShareButton(
              platform: SharePlatform.instagram,
              label: '인스타그램',
              icon: Icons.camera_alt,
              gradient: const LinearGradient(
                colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFCAF45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
            _buildShareButton(
              platform: SharePlatform.facebook,
              label: '페이스북',
              icon: Icons.facebook,
              color: const Color(0xFF1877F2)),
            _buildShareButton(
              platform: SharePlatform.twitter,
              label: 'X',
              icon: Icons.tag,
              color: const Color(0xFF1DA1F2)),
            _buildShareButton(
              platform: SharePlatform.whatsapp,
              label: 'WhatsApp',
              icon: Icons.message,
              color: const Color(0xFF25D366)),
            _buildShareButton(
              platform: SharePlatform.other,
              label: '더보기',
              icon: Icons.more_horiz,
              color: _traditionalBrown)])]);
  }

  Widget _buildShareButton({
    required SharePlatform platform,
    required String label,
    required IconData icon,
    Color? color,
    Color? iconColor,
    Gradient? gradient}) {
    return InkWell(
      onTap: () {
        widget.onShare(platform);
        Navigator.of(context).pop();
      },
      borderRadius: AppDimensions.borderRadiusMedium,
      child: Container(
        width: AppSpacing.spacing24 * 1.04,
        padding: AppSpacing.paddingVertical16,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: AppDimensions.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: (color ?? TossDesignSystem.gray600).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor ?? TossDesignSystem.grayDark900,
              size: AppDimensions.iconSizeXLarge),
            const SizedBox(height: AppSpacing.spacing2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall)])));
  }

  Widget _buildSaveOptions(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // U09: 전통 스타일 헤더
        Row(
          children: [
            Container(width: 3, height: 16, color: _traditionalBrown),
            const SizedBox(width: 8),
            Text(
              '저장 옵션',
              style: TextStyle(
                color: isDark ? Colors.white : _darkBrown,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                onTap: () {
                  widget.onShare(SharePlatform.gallery);
                  Navigator.of(context).pop();
                },
                icon: Icons.download_outlined,
                label: '갤러리에 저장',
                color: _traditionalBrown)),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                onTap: () {
                  widget.onShare(SharePlatform.copy);
                  Navigator.of(context).pop();
                },
                icon: Icons.copy_outlined,
                label: '텍스트 복사',
                color: _lightBrown))])]);
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color}) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: AppDimensions.borderRadiusMedium,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusMedium,
        child: Container(
          padding: AppSpacing.paddingVertical16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: AppDimensions.iconSizeSmall),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color)),
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
  other}