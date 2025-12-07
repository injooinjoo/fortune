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

          // Compact Header
          _buildCompactHeader(),

          const SizedBox(height: 20),

          // Upload Section (바로 표시)
          _buildUploadSection(),

          const SizedBox(height: 24),

          // Compact Feature Hints (하단에 작게)
          _buildCompactFeatureHints(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 간소화된 상단 헤더
  Widget _buildCompactHeader() {
    return Row(
      children: [
        // 작은 아이콘
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9C27B0),
                Color(0xFF7B1FA2),
              ],
            ),
          ),
          child: const Icon(
            Icons.face_retouching_natural,
            color: TossDesignSystem.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // 제목 + 뱃지
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 관상 분석',
                style: TossDesignSystem.heading4.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'GPT-4 Vision 기반',
                style: TossDesignSystem.body3.copyWith(
                  color: isDark ? const Color(0xFFCE93D8) : TossDesignSystem.purple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 하단 간소화된 특징 힌트
  Widget _buildCompactFeatureHints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.grayDark100
            : TossDesignSystem.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHintItem(Icons.psychology, '성격'),
          _buildHintItem(Icons.stars, '운세'),
          _buildHintItem(Icons.tips_and_updates, '조언'),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildHintItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TossDesignSystem.body3.copyWith(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
          ),
        ),
      ],
    );
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

