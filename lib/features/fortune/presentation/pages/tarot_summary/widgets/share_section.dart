import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';

class ShareSection extends StatelessWidget {
  final double fontScale;
  final VoidCallback onShareMessage;
  final VoidCallback onCopy;
  final VoidCallback onShareImage;

  const ShareSection({
    super.key,
    required this.fontScale,
    required this.onShareMessage,
    required this.onCopy,
    required this.onShareImage,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF9333EA).withValues(alpha: 0.1),
          const Color(0xFF7C3AED).withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '친구와 공유하기',
                style: DSTypography.labelLarge.copyWith(
                  fontSize: DSTypography.labelLarge.fontSize! * fontScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton(
                icon: Icons.message,
                label: '메시지',
                color: const Color(0xFF00C853),
                onTap: onShareMessage,
                fontScale: fontScale,
              ),
              _buildShareButton(
                icon: Icons.copy,
                label: '복사',
                color: const Color(0xFF2196F3),
                onTap: onCopy,
                fontScale: fontScale,
              ),
              _buildShareButton(
                icon: Icons.image,
                label: '이미지',
                color: const Color(0xFFFF6F00),
                onTap: onShareImage,
                fontScale: fontScale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double fontScale,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: DSTypography.labelMedium.copyWith(
                fontSize: DSTypography.labelMedium.fontSize! * fontScale,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
