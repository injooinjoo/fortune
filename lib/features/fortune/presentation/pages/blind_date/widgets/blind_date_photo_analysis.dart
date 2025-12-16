import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/widgets/unified_button.dart';
import '../../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../../widgets/multi_photo_selector.dart';
import '../../../../../../services/vision_api_service.dart';

/// 사진 분석 섹션 위젯
class BlindDatePhotoAnalysis extends StatelessWidget {
  final List<XFile> myPhotos;
  final List<XFile> partnerPhotos;
  final bool isAnalyzingPhotos;
  final ValueChanged<List<XFile>> onMyPhotosSelected;
  final ValueChanged<List<XFile>> onPartnerPhotosSelected;
  final VoidCallback? onAnalyzePressed;
  final Widget userInfoForm;

  const BlindDatePhotoAnalysis({
    super.key,
    required this.myPhotos,
    required this.partnerPhotos,
    required this.isAnalyzingPhotos,
    required this.onMyPhotosSelected,
    required this.onPartnerPhotosSelected,
    this.onAnalyzePressed,
    required this.userInfoForm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Column(
      children: [
        // My Photos Section
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '내 사진 분석',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MultiPhotoSelector(
                  title: '내 사진 선택',
                  maxPhotos: 5,
                  onPhotosSelected: onMyPhotosSelected,
                  initialPhotos: myPhotos,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Partner Photos Section (Optional)
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '상대방 정보 (선택)',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '상대방 사진이 있으면 매칭 확률을 더 정확하게 분석할 수 있습니다',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                MultiPhotoSelector(
                  title: '상대방 사진 선택',
                  maxPhotos: 3,
                  onPhotosSelected: onPartnerPhotosSelected,
                  initialPhotos: partnerPhotos,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Analysis Button
        if (myPhotos.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: UnifiedButton(
              text: isAnalyzingPhotos ? 'AI가 분석 중...' : 'AI 사진 분석 시작',
              onPressed: isAnalyzingPhotos ? null : onAnalyzePressed,
              style: UnifiedButtonStyle.primary,
              size: UnifiedButtonSize.large,
              icon: isAnalyzingPhotos
                  ? null
                  : const Icon(Icons.auto_awesome),
            ),
          ),

        // Basic User Info (still required)
        const SizedBox(height: 24),
        userInfoForm,
      ],
    );
  }
}

/// 사진 분석 결과 표시 위젯
class BlindDatePhotoAnalysisResult extends StatelessWidget {
  final BlindDateAnalysis analysis;

  const BlindDatePhotoAnalysisResult({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI 사진 분석 결과',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Matching Score
              if (analysis.partnerStyle != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '매칭 확률',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${analysis.matchingScore}%',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: _getSuccessColor(analysis.matchingScore),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // My Analysis
              _buildAnalysisCard(
                context: context,
                title: '내 이미지 분석',
                style: analysis.myStyle,
                personality: analysis.myPersonality,
                icon: Icons.person,
              ),

              // Partner Analysis (if available)
              if (analysis.partnerStyle != null) ...[
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  context: context,
                  title: '상대방 이미지 분석',
                  style: analysis.partnerStyle!,
                  personality: analysis.partnerPersonality!,
                  icon: Icons.favorite,
                ),
              ],

              const SizedBox(height: 16),

              // AI Tips
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          size: 16,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI 추천 포인트',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...analysis.firstImpressionTips.take(3).map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard({
    required BuildContext context,
    required String title,
    required String style,
    required String personality,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '스타일',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      style,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '성격',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      personality,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSuccessColor(int rate) {
    if (rate >= 80) return DSColors.success;
    if (rate >= 60) return DSColors.warning;
    return DSColors.error;
  }
}
