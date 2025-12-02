import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../shared/components/image_upload_selector.dart';
import '../../../../../../core/widgets/unified_button.dart';

class InputStep2Widget extends StatelessWidget {
  final bool isDark;
  final ImageUploadResult? uploadResult;
  final bool isAnalyzing;
  final VoidCallback onStartAnalysis;

  const InputStep2Widget({
    super.key,
    required this.isDark,
    required this.uploadResult,
    required this.isAnalyzing,
    required this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                '분석을 시작할\n준비가 되었습니다',
                style: TossDesignSystem.heading2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'AI가 당신의 관상을 상세하게 분석합니다',
                style: TossDesignSystem.body2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

              const SizedBox(height: 32),

              // Preview Card
              if (uploadResult != null)
                AppCard(
                  style: AppCardStyle.filled,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            uploadResult!.type == ImageUploadType.instagram
                                ? Icons.link
                                : Icons.check_circle,
                            color: TossDesignSystem.successGreen,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            uploadResult!.type == ImageUploadType.instagram
                                ? '인스타그램 프로필 준비됨'
                                : '사진 준비됨',
                            style: TossDesignSystem.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (uploadResult!.imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 350,
                            ),
                            child: Image.file(
                              uploadResult!.imageFile!,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      else if (uploadResult!.instagramUrl != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                TossDesignSystem.purple,
                                TossDesignSystem.pinkPrimary,
                                TossDesignSystem.warningOrange
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.camera_alt,
                                color: TossDesignSystem.white,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                uploadResult!.instagramUrl!,
                                style: TossDesignSystem.body2.copyWith(
                                  color: TossDesignSystem.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 100), // Bottom spacing for floating button
            ],
          ),
        ),

        // Floating Bottom Button
        UnifiedButton.floating(
          text: isAnalyzing ? 'AI가 분석 중...' : 'AI 관상 분석 시작',
          isEnabled: !isAnalyzing,
          onPressed: isAnalyzing ? null : onStartAnalysis,
          isLoading: isAnalyzing,
          icon: isAnalyzing ? null : const Icon(Icons.psychology, size: 20, color: TossDesignSystem.white),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TossDesignSystem.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: TossDesignSystem.purple,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
