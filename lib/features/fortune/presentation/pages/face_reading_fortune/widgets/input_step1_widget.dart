import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../shared/components/image_upload_selector.dart';

class InputStep1Widget extends StatelessWidget {
  final bool isDark;
  final Function(ImageUploadResult) onImageSelected;

  const InputStep1Widget({
    super.key,
    required this.isDark,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Hero Section with gradient background
          _buildHeroSection(context),

          const SizedBox(height: 24),

          // Feature Cards - 관상에서 알 수 있는 것
          _buildFeatureSection(),

          const SizedBox(height: 28),

          // Upload Section
          _buildUploadSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2D1B4E),
                  const Color(0xFF1A1A2E),
                ]
              : [
                  const Color(0xFFF8F0FF),
                  const Color(0xFFEDE7F6),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? TossDesignSystem.purple.withValues(alpha: 0.3)
              : TossDesignSystem.purple.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          // Face Icon with glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFF7B1FA2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.purple.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              color: Colors.white,
              size: 36,
            ),
          ).animate().fadeIn(duration: 500.ms).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: 20),

          // Title
          Text(
            'AI 관상 분석',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? Colors.white : TossDesignSystem.gray900,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            '얼굴에 담긴 당신만의 이야기를\n지금 바로 확인해보세요',
            textAlign: TextAlign.center,
            style: TossDesignSystem.body2.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : TossDesignSystem.gray600,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 16),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? TossDesignSystem.purple.withValues(alpha: 0.3)
                  : TossDesignSystem.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: isDark ? const Color(0xFFCE93D8) : TossDesignSystem.purple,
                ),
                const SizedBox(width: 6),
                Text(
                  'GPT-4 Vision 기반 정밀 분석',
                  style: TossDesignSystem.body3.copyWith(
                    color: isDark ? const Color(0xFFCE93D8) : TossDesignSystem.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFeatureSection() {
    final features = [
      _FeatureItem(
        icon: Icons.psychology,
        title: '성격 분석',
        description: '얼굴형, 눈, 코, 입에서\n읽는 내면의 성격',
        color: const Color(0xFF5C6BC0),
      ),
      _FeatureItem(
        icon: Icons.stars,
        title: '타고난 운',
        description: '재물운, 연애운,\n직업운까지 한눈에',
        color: const Color(0xFFFFB74D),
      ),
      _FeatureItem(
        icon: Icons.tips_and_updates,
        title: '맞춤 조언',
        description: '당신에게 딱 맞는\n운세 활용 가이드',
        color: const Color(0xFF4DB6AC),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '관상에서 알 수 있는 것',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

        const SizedBox(height: 12),

        Row(
          children: features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 6,
                  right: index == features.length - 1 ? 0 : 6,
                ),
                child: _buildFeatureCard(feature, index),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? TossDesignSystem.grayDark200
              : TossDesignSystem.gray200,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            feature.title,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature.description,
            textAlign: TextAlign.center,
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 400 + (index * 100)),
        ).slideY(begin: 0.15, end: 0);
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Text(
                '사진 업로드',
                style: TossDesignSystem.body1.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TossDesignSystem.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '필수',
                  style: TossDesignSystem.body3.copyWith(
                    color: TossDesignSystem.errorRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

        const SizedBox(height: 12),

        ImageUploadSelector(
          title: '',
          description: '',
          onImageSelected: onImageSelected,
          showInstagramOption: true,
          imageHeight: 200,
          guidelines: const [
            '정면을 바라보는 사진',
            '밝은 조명 권장',
            '선글라스/마스크 제거',
            '1인 사진만 가능',
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
      ],
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
