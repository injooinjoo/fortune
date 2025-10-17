import 'package:flutter/material.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../domain/models/fortune_result.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class FaceReadingResultWidget extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback? onShare;

  const FaceReadingResultWidget({
    super.key,
    required this.result,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    // Parse result content for display
    final content = result.content;
    final sections = _parseContent(content);

    return Container(
      decoration: BoxDecoration(
        color: TossDesignSystem.gray50,
        borderRadius: AppDimensions.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: AppSpacing.paddingAll20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [TossDesignSystem.tossBlue, TossDesignSystem.gray600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.face,
                  size: 48,
                  color: TossDesignSystem.gray50,
                ),
                const SizedBox(height: AppSpacing.spacing3),
                Text(
                  '당신의 관상 분석 결과',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TossDesignSystem.gray50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content sections
          Padding(
            padding: AppSpacing.paddingAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall score or rating
                if (sections.containsKey('score')) ...[
                  _buildScoreSection(context, sections['score']!),
                  const SizedBox(height: AppSpacing.spacing6),
                ],

                // Main fortune
                if (sections.containsKey('fortune')) ...[
                  _buildSection(
                    context: context,
                    title: '종합 운세',
                    content: sections['fortune']!,
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: AppSpacing.spacing5),
                ],

                // Personality traits
                if (sections.containsKey('personality')) ...[
                  _buildSection(
                    context: context,
                    title: '성격 특성',
                    content: sections['personality']!,
                    icon: Icons.psychology,
                  ),
                  const SizedBox(height: AppSpacing.spacing5),
                ],

                // Career & wealth
                if (sections.containsKey('career')) ...[
                  _buildSection(
                    context: context,
                    title: '재물운 & 직업운',
                    content: sections['career']!,
                    icon: Icons.trending_up,
                  ),
                  const SizedBox(height: AppSpacing.spacing5),
                ],

                // Love & relationships
                if (sections.containsKey('love')) ...[
                  _buildSection(
                    context: context,
                    title: '애정운',
                    content: sections['love']!,
                    icon: Icons.favorite,
                  ),
                  const SizedBox(height: AppSpacing.spacing5),
                ],

                // Advice
                if (sections.containsKey('advice')) ...[
                  _buildSection(
                    context: context,
                    title: '조언',
                    content: sections['advice']!,
                    icon: Icons.lightbulb,
                  ),
                ],
              ],
            ),
          ),

          // Share button
          if (onShare != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: TossButton(
                text: '결과 공유하기',
                onPressed: onShare,
                style: TossButtonStyle.primary,
                size: TossButtonSize.large,
                icon: const Icon(Icons.share),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context, String scoreText) {
    // Try to extract numeric score
    final scoreMatch = RegExp(r'(\d+)').firstMatch(scoreText);
    final score = scoreMatch != null ? int.tryParse(scoreMatch.group(1)!) ?? 0 : 0;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: TossDesignSystem.gray600.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                  Text(
                    '점',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TossDesignSystem.gray600.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing3),
          Text(
            _getScoreDescription(score),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getScoreColor(score),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: TossDesignSystem.tossBlue,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.spacing2),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: TossDesignSystem.tossBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing3),
        Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
            borderRadius: AppDimensions.borderRadiusSmall,
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, String> _parseContent(String content) {
    final sections = <String, String>{};

    // Simple parsing logic - can be enhanced based on actual API response format
    if (content.contains('점수:') || content.contains('평점:')) {
      final scoreMatch = RegExp(r'(점수|평점):\s*(\d+)').firstMatch(content);
      if (scoreMatch != null) {
        sections['score'] = scoreMatch.group(2)!;
      }
    }

    // Try to split content into sections
    final lines = content.split('\n');
    String currentSection = 'fortune';
    final sectionContent = StringBuffer();

    for (final line in lines) {
      if (line.contains('성격') || line.contains('특성')) {
        if (sectionContent.isNotEmpty) {
          sections[currentSection] = sectionContent.toString().trim();
          sectionContent.clear();
        }
        currentSection = 'personality';
      } else if (line.contains('재물') || line.contains('직업') || line.contains('사업')) {
        if (sectionContent.isNotEmpty) {
          sections[currentSection] = sectionContent.toString().trim();
          sectionContent.clear();
        }
        currentSection = 'career';
      } else if (line.contains('애정') || line.contains('연애') || line.contains('결혼')) {
        if (sectionContent.isNotEmpty) {
          sections[currentSection] = sectionContent.toString().trim();
          sectionContent.clear();
        }
        currentSection = 'love';
      } else if (line.contains('조언') || line.contains('충고')) {
        if (sectionContent.isNotEmpty) {
          sections[currentSection] = sectionContent.toString().trim();
          sectionContent.clear();
        }
        currentSection = 'advice';
      } else if (line.trim().isNotEmpty) {
        sectionContent.writeln(line);
      }
    }

    if (sectionContent.isNotEmpty) {
      sections[currentSection] = sectionContent.toString().trim();
    }

    // If no sections were parsed, put all content in fortune
    if (sections.isEmpty || (sections.length == 1 && sections.containsKey('score'))) {
      sections['fortune'] = content;
    }

    return sections;
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.primaryBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return '매우 좋음';
    if (score >= 60) return '좋음';
    if (score >= 40) return '보통';
    return '노력 필요';
  }
}