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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'AI가 당신의\n관상을 분석합니다',
            style: TossDesignSystem.heading2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 8),

          Text(
            '사진이나 인스타그램 프로필로\n숨겨진 운명과 성격을 알아보세요',
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

          const SizedBox(height: 32),

          // Image Upload Selector
          ImageUploadSelector(
            title: '분석 방법 선택',
            description: '원하는 방법으로 사진을 제공해주세요',
            onImageSelected: onImageSelected,
            showInstagramOption: true,
            guidelines: const [
              '정면을 바라보는 사진을 사용해주세요',
              '밝은 조명에서 촬영된 사진이 좋습니다',
              '선글라스나 마스크는 제거해주세요',
              '한 명만 나온 사진을 사용해주세요',
            ],
          ),
        ],
      ),
    );
  }
}
