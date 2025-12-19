import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/typography_unified.dart';

/// 🎁 공유 카드
class ShareCard extends StatelessWidget {
  final int score;
  final String message;
  final bool isDark;

  const ShareCard({
    super.key,
    required this.score,
    required this.message,
    required this.isDark,
  });

  void _shareContent() {
    final shareText = '''
🔮 오늘의 운세

📊 총운 점수: $score점
💬 $message

오늘도 좋은 하루 되세요! ✨

#오늘의운세 #일일운세 #행운
''';

    Share.share(shareText, subject: '오늘의 운세');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 운세 공유하기',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '친구들과 함께 운세를 나눠보세요',
          style: context.bodySmall.copyWith(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 16),

        // 공유 미리보기 카드 - 전통 오방색 그라데이션
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E5F3C), const Color(0xFF2E8B57)]  // 목(木) - 성장과 번영
                  : [const Color(0xFF2E8B57), const Color(0xFF3D9970)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                '🔮',
                style: TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 10),
              const Text(
                '오늘의 운세',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$score점',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2,
                  fontFamily: 'ZenSerif',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ZenSerif',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.95, 0.95), duration: 500.ms, curve: Curves.easeOut),

        const SizedBox(height: 16),

        // 공유 버튼 - 전통 색상
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareContent,
            icon: const Text('📤', style: TextStyle(fontSize: 18)),
            label: const Text(
              '공유하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFF2E8B57)  // 목(木) - 전통 청록
                  : const Color(0xFF2E8B57),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms, delay: 200.ms)
          .slideY(begin: 0.1, duration: 500.ms, delay: 200.ms),
      ],
    );
  }
}
