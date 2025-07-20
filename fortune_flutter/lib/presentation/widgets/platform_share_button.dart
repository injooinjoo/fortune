import 'package:flutter/material.dart';

class PlatformShareButton extends StatelessWidget {
  final SharePlatform platform;
  final VoidCallback onTap;
  final double size;
  final bool showLabel;

  const PlatformShareButton({
    super.key,
    required this.platform,
    required this.onTap,
    this.size = 56,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getPlatformConfig(platform);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 4),
      child: Container(
        width: size,
        height: showLabel ? size + 20 : size,
        padding: EdgeInsets.all(size * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                color: config.gradient == null ? config.color : null,
                gradient: config.gradient,
                borderRadius: BorderRadius.circular(size * 0.2),
                boxShadow: [
                  BoxShadow(
                    color: (config.color ?? Colors.grey).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: config.customIcon ?? Icon(
                config.icon,
                color: config.iconColor ?? Colors.white,
                size: size * 0.5,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(
                config.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _PlatformConfig _getPlatformConfig(SharePlatform platform) {
    switch (platform) {
      case SharePlatform.kakaoTalk:
        return _PlatformConfig(
          label: '카카오톡',
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFFFEE500),
          iconColor: Colors.black87,
          customIcon: _buildKakaoIcon(),
        );
      case SharePlatform.instagram:
        return _PlatformConfig(
          label: '인스타그램',
          icon: Icons.camera_alt_rounded,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF833AB4),
              Color(0xFFF56040),
              Color(0xFFFCAF45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case SharePlatform.facebook:
        return _PlatformConfig(
          label: '페이스북',
          icon: Icons.facebook,
          color: const Color(0xFF1877F2),
        );
      case SharePlatform.twitter:
        return _PlatformConfig(
          label: 'X',
          icon: Icons.close,
          color: Colors.black,
          customIcon: _buildXIcon(),
        );
      case SharePlatform.whatsapp:
        return _PlatformConfig(
          label: 'WhatsApp',
          icon: Icons.message_rounded,
          color: const Color(0xFF25D366),
          customIcon: _buildWhatsAppIcon(),
        );
      case SharePlatform.line:
        return _PlatformConfig(
          label: '라인',
          icon: Icons.message_outlined,
          color: const Color(0xFF00B900),
        );
      case SharePlatform.telegram:
        return _PlatformConfig(
          label: '텔레그램',
          icon: Icons.send_rounded,
          color: const Color(0xFF0088CC),
        );
      case SharePlatform.gallery:
        return _PlatformConfig(
          label: '저장',
          icon: Icons.download_rounded,
          color: Colors.grey[700]!,
        );
      case SharePlatform.copy:
        return _PlatformConfig(
          label: '복사',
          icon: Icons.copy_rounded,
          color: Colors.grey[600]!,
        );
      default:
        return _PlatformConfig(
          label: '더보기',
          icon: Icons.more_horiz_rounded,
          color: Colors.grey[500]!,
        );
    }
  }

  Widget? _buildKakaoIcon() {
    return Center(
      child: CustomPaint(
        size: const Size(32, 32),
        painter: _KakaoIconPainter(),
      ),
    );
  }

  Widget? _buildXIcon() {
    return const Center(
      child: Text(
        '𝕏',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget? _buildWhatsAppIcon() {
    return Center(
      child: CustomPaint(
        size: const Size(32, 32),
        painter: _WhatsAppIconPainter(),
      ),
    );
  }
}

class _PlatformConfig {
  final String label;
  final IconData icon;
  final Color? color;
  final Color? iconColor;
  final Gradient? gradient;
  final Widget? customIcon;

  _PlatformConfig({
    required this.label,
    required this.icon,
    this.color,
    this.iconColor,
    this.gradient,
    this.customIcon,
  });
}

enum SharePlatform {
  kakaoTalk,
  instagram,
  facebook,
  twitter,
  whatsapp,
  line,
  telegram,
  gallery,
  copy,
  other,
}

class _KakaoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    // Simplified KakaoTalk speech bubble
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.1, 
          size.width * 0.85, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.8, 
          size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.3, size.height * 0.95)
      ..lineTo(size.width * 0.35, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.7, 
          size.width * 0.15, size.height * 0.6)
      ..lineTo(size.width * 0.15, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.1, 
          size.width * 0.5, size.height * 0.1)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WhatsAppIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Simplified WhatsApp phone icon
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.35,
          size.width * 0.25, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.65,
          size.width * 0.35, size.height * 0.75)
      ..lineTo(size.width * 0.45, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.6,
          size.width * 0.6, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.6,
          size.width * 0.75, size.height * 0.55)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.35,
          size.width * 0.75, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.25,
          size.width * 0.5, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.25,
          size.width * 0.35, size.height * 0.25)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}