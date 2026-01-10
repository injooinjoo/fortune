import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/font_config.dart';
import '../../../../core/theme/fortune_theme.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../presentation/providers/providers.dart';
import '../../domain/models/medical_document_models.dart';
import '../../data/services/medical_document_service.dart';
import '../../../../core/theme/obangseok_colors.dart';

/// 의료 문서 분석 결과 페이지
class MedicalDocumentResultPage extends ConsumerStatefulWidget {
  final MedicalDocumentUploadResult uploadResult;

  const MedicalDocumentResultPage({
    super.key,
    required this.uploadResult,
  });

  @override
  ConsumerState<MedicalDocumentResultPage> createState() =>
      _MedicalDocumentResultPageState();
}

class _MedicalDocumentResultPageState
    extends ConsumerState<MedicalDocumentResultPage> {
  final MedicalDocumentService _service = MedicalDocumentService();

  bool _isLoading = true;
  String? _error;
  MedicalDocumentAnalysisResult? _result;

  @override
  void initState() {
    super.initState();
    _analyzeDocument();
  }

  Future<void> _analyzeDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 토큰 확인 및 소비
      final tokenState = ref.read(tokenProvider);
      final currentTokens = tokenState.balance?.remainingTokens ?? 0;

      if (currentTokens < 3) {
        setState(() {
          _isLoading = false;
          _error = '복주머니가 부족합니다. (필요: 3개, 보유: $currentTokens개)';
        });
        return;
      }

      // 사용자 정보 가져오기
      final userProfile = tokenState.userProfile;

      // API 호출
      final result = await _service.analyzeDocument(
        uploadResult: widget.uploadResult,
        birthDate: userProfile?.birthDate?.toIso8601String().split('T').first,
        birthTime: userProfile?.birthTime,
        gender: userProfile?.gender.value,
      );

      // 토큰 소비
      await ref.read(tokenProvider.notifier).consumeTokens(
            fortuneType: 'health-document',
            amount: 3,
          );

      setState(() {
        _result = result;
        _isLoading = false;
      });

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.backgroundDark
          : TossDesignSystem.backgroundLight,
      appBar: _buildAppBar(isDark),
      body: _isLoading
          ? _buildLoadingView(isDark)
          : _error != null
              ? _buildErrorView(isDark)
              : _buildResultView(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color:
              isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
        ),
      ),
      title: Text(
        '검진 분석 결과',
        style: TossTheme.heading3.copyWith(
          color:
              isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ObangseokColors.cheongMuted.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ObangseokColors.cheongMuted),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '문서를 분석하고 있어요',
            style: TossTheme.heading3.copyWith(
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossTheme.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '신령이 검진 결과를 꼼꼼히 살피고 있습니다...',
            style: TossTheme.body2.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossTheme.textGray600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: TossTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '분석 중 오류가 발생했어요',
              style: TossTheme.heading3.copyWith(
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossTheme.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '알 수 없는 오류',
              style: TossTheme.body2.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossTheme.textGray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            UnifiedButton(
              text: '다시 시도',
              onPressed: _analyzeDocument,
              style: UnifiedButtonStyle.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(bool isDark) {
    if (_result == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 건강 점수 카드
          _buildScoreCard(isDark),
          const SizedBox(height: 20),

          // 문서 요약
          _buildDocumentSummary(isDark),
          const SizedBox(height: 20),

          // 검사 결과
          if (_result!.testResults.isNotEmpty) ...[
            _buildTestResults(isDark),
            const SizedBox(height: 20),
          ],

          // 사주 건강 분석
          _buildSajuAnalysis(isDark),
          const SizedBox(height: 20),

          // 권장사항
          _buildRecommendations(isDark),
          const SizedBox(height: 20),

          // 양생법
          _buildHealthRegimen(isDark),
          const SizedBox(height: 40),

          // 면책 조항
          _buildDisclaimer(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScoreCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _result!.scoreColor.withValues(alpha: 0.15),
            _result!.scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _result!.scoreColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_result!.healthScore}',
                style: TossTheme.heading1.copyWith(
                  fontSize: FontConfig.scoreXLarge,
                  fontWeight: FontWeight.w700,
                  color: _result!.scoreColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '점',
                  style: TossTheme.heading3.copyWith(
                    color: _result!.scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _result!.scoreColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _result!.scoreGrade,
              style: TossTheme.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: _result!.scoreColor,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildDocumentSummary(bool isDark) {
    final doc = _result!.documentAnalysis;
    return _buildSection(
      isDark: isDark,
      icon: Icons.description_outlined,
      iconColor: ObangseokColors.cheong,
      title: '문서 요약',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (doc.institution != null)
            _buildInfoRow('의료기관', doc.institution!, isDark),
          if (doc.documentDate != null)
            _buildInfoRow('검진일', doc.documentDate!, isDark),
          const SizedBox(height: 12),
          Text(
            doc.summary,
            style: TossTheme.body2.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossTheme.textGray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults(bool isDark) {
    return _buildSection(
      isDark: isDark,
      icon: Icons.analytics_outlined,
      iconColor: ObangseokColors.cheongMuted,
      title: '검사 항목 분석',
      subtitle:
          '총 ${_result!.totalTestItems}개 항목 중 ${_result!.cautionItemCount}개 주의',
      child: Column(
        children: _result!.testResults.map((category) {
          return _buildTestCategory(category, isDark);
        }).toList(),
      ),
    );
  }

  Widget _buildTestCategory(TestCategory category, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category.category,
            style: TossTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossTheme.textBlack,
            ),
          ),
        ),
        ...category.items.map((item) => _buildTestItem(item, isDark)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTestItem(TestItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.status.color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TossTheme.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossTheme.textBlack,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.status.color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status.displayName,
                  style: TossTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: FontConfig.captionSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${item.value} ${item.unit}',
                style: TossTheme.body2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: item.status.color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(정상: ${item.normalRange})',
                style: TossTheme.caption.copyWith(
                  color: isDark
                      ? TossDesignSystem.textTertiaryDark
                      : TossTheme.textGray500,
                ),
              ),
            ],
          ),
          if (item.interpretation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.interpretation,
              style: TossTheme.caption.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossTheme.textGray600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSajuAnalysis(bool isDark) {
    final saju = _result!.sajuAnalysis;
    return _buildSection(
      isDark: isDark,
      icon: Icons.auto_awesome_rounded,
      iconColor: ObangseokColors.cheongDark,
      title: '사주 기반 건강 분석',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오행 균형
          Row(
            children: [
              _buildElementChip(
                  '강함', saju.dominantElement, ObangseokColors.cheongMuted, isDark),
              const SizedBox(width: 8),
              _buildElementChip(
                  '약함', saju.weakElement, ObangseokColors.jeokMuted, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            saju.elementDescription,
            style: TossTheme.body2.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossTheme.textGray600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // 취약/강한 장기
          if (saju.vulnerableOrgans.isNotEmpty)
            _buildOrganList('주의 필요 장기', saju.vulnerableOrgans,
                ObangseokColors.jeokMuted, isDark),
          if (saju.strengthOrgans.isNotEmpty)
            _buildOrganList(
                '튼튼한 장기', saju.strengthOrgans, ObangseokColors.cheongMuted, isDark),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ObangseokColors.cheongDark.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates_rounded,
                    color: ObangseokColors.cheongDark, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    saju.sajuAdvice,
                    style: TossTheme.body2.copyWith(
                      color: isDark
                          ? TossDesignSystem.textSecondaryDark
                          : TossTheme.textGray600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementChip(
      String label, String element, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TossTheme.caption.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossTheme.textGray600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            element,
            style: TossTheme.body2.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganList(
      String title, List<String> organs, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TossTheme.caption.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossTheme.textGray600,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: organs
                  .map((organ) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          organ,
                          style: TossTheme.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(bool isDark) {
    final rec = _result!.recommendations;
    return _buildSection(
      isDark: isDark,
      icon: Icons.checklist_rounded,
      iconColor: ObangseokColors.hwangMuted,
      title: '권장사항',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rec.urgent.isNotEmpty) ...[
            _buildRecommendationGroup(
                '긴급', rec.urgent, ObangseokColors.jeokMuted, isDark),
            const SizedBox(height: 12),
          ],
          if (rec.general.isNotEmpty) ...[
            _buildRecommendationGroup(
                '일반', rec.general, ObangseokColors.cheong, isDark),
            const SizedBox(height: 12),
          ],
          if (rec.lifestyle.isNotEmpty)
            _buildRecommendationGroup(
                '생활습관', rec.lifestyle, ObangseokColors.cheongMuted, isDark),
        ],
      ),
    );
  }

  Widget _buildRecommendationGroup(
      String title, List<String> items, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TossTheme.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TossTheme.body2.copyWith(color: color)),
                  Expanded(
                    child: Text(
                      item,
                      style: TossTheme.body2.copyWith(
                        color: isDark
                            ? TossDesignSystem.textSecondaryDark
                            : TossTheme.textGray600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildHealthRegimen(bool isDark) {
    final regimen = _result!.healthRegimen;
    return _buildSection(
      isDark: isDark,
      icon: Icons.spa_rounded,
      iconColor: ObangseokColors.cheongMuted,
      title: '맞춤 양생법',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 식이 조언
          if (regimen.diet.isNotEmpty) ...[
            ...regimen.diet.map((advice) => _buildDietAdvice(advice, isDark)),
            const SizedBox(height: 16),
          ],

          // 운동 조언
          if (regimen.exercise.isNotEmpty) ...[
            Text(
              '추천 운동',
              style: TossTheme.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossTheme.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            ...regimen.exercise
                .map((exercise) => _buildExerciseAdvice(exercise, isDark)),
            const SizedBox(height: 16),
          ],

          // 생활습관
          if (regimen.lifestyle.isNotEmpty) ...[
            Text(
              '생활 양생',
              style: TossTheme.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? TossDesignSystem.textPrimaryDark
                    : TossTheme.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            ...regimen.lifestyle.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: ObangseokColors.cheongMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TossTheme.body2.copyWith(
                            color: isDark
                                ? TossDesignSystem.textSecondaryDark
                                : TossTheme.textGray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDietAdvice(DietAdvice advice, bool isDark) {
    final isRecommend = advice.isRecommend;
    final color =
        isRecommend ? ObangseokColors.cheongMuted : ObangseokColors.jeokMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRecommend ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                isRecommend ? '추천 음식' : '피해야 할 음식',
                style: TossTheme.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: advice.items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? TossDesignSystem.surfaceBackgroundDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item,
                        style: TossTheme.caption.copyWith(
                          color: isDark
                              ? TossDesignSystem.textPrimaryDark
                              : TossTheme.textBlack,
                        ),
                      ),
                    ))
                .toList(),
          ),
          if (advice.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              advice.reason,
              style: TossTheme.caption.copyWith(
                color: isDark
                    ? TossDesignSystem.textSecondaryDark
                    : TossTheme.textGray600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseAdvice(ExerciseAdvice exercise, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ObangseokColors.cheong.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_run_rounded,
                color: ObangseokColors.cheong, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.type,
                  style: TossTheme.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? TossDesignSystem.textPrimaryDark
                        : TossTheme.textBlack,
                  ),
                ),
                Text(
                  '${exercise.frequency} · ${exercise.duration}',
                  style: TossTheme.caption.copyWith(
                    color: isDark
                        ? TossDesignSystem.textSecondaryDark
                        : TossTheme.textGray600,
                  ),
                ),
                if (exercise.benefit.isNotEmpty)
                  Text(
                    exercise.benefit,
                    style: TossTheme.caption.copyWith(
                      color: ObangseokColors.cheongMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TossDesignSystem.surfaceBackgroundDark
            : TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: isDark
                ? TossDesignSystem.textTertiaryDark
                : TossTheme.textGray500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '이 분석 결과는 참고 자료이며, 의사의 전문적 진단을 대체하지 않습니다. 정확한 건강 상담은 의료 전문가와 상담하세요.',
              style: TossTheme.caption.copyWith(
                color: isDark
                    ? TossDesignSystem.textTertiaryDark
                    : TossTheme.textGray500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 공통 위젯 ====================

  Widget _buildSection({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TossTheme.body1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? TossDesignSystem.textPrimaryDark
                            : TossTheme.textBlack,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TossTheme.caption.copyWith(
                          color: isDark
                              ? TossDesignSystem.textSecondaryDark
                              : TossTheme.textGray600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TossTheme.caption.copyWith(
              color: isDark
                  ? TossDesignSystem.textSecondaryDark
                  : TossTheme.textGray600,
            ),
          ),
          Text(
            value,
            style: TossTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? TossDesignSystem.textPrimaryDark
                  : TossTheme.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
