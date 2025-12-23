import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/fortune_design_system.dart';
import '../../../../core/theme/fortune_theme.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/constants/fortune_type_names.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/widgets/unified_button_enums.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../domain/models/fortune_history.dart';

/// 운세 히스토리 상세 페이지
class FortuneHistoryDetailPage extends StatelessWidget {
  final FortuneHistory history;

  const FortuneHistoryDetailPage({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = history.summary['score'] as int? ?? 0;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundWhite,
      appBar: AppHeader(
        title: history.title,
        showBackButton: true,
        centerTitle: true,
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 날짜 및 타입 정보
            _buildDateInfo(context, isDark)
                .animate()
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // 점수 섹션
            if (score > 0)
              _buildScoreSection(context, isDark, score)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

            // 메인 내용
            _buildMainContent(context, isDark)
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            // 상세 결과 (fortune_data)
            if (history.detailedResult != null)
              _buildDetailedResult(context, isDark)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),

            // 태그
            if (history.tags != null && history.tags!.isNotEmpty)
              _buildTagsSection(context, isDark)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),

            // 액션 버튼
            _buildActionButtons(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context, bool isDark) {
    final fortuneTypeName = FortuneTypeNames.getName(history.fortuneType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              fortuneTypeName,
              style: TossDesignSystem.caption.copyWith(
                color: TossDesignSystem.tossBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat('yyyy년 MM월 dd일 HH:mm').format(history.createdAt),
            style: TossDesignSystem.body3.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context, bool isDark, int score) {
    final scoreColor = _getScoreColor(score);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 70.0,
              lineWidth: 8.0,
              animation: true,
              percent: score / 100,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TossDesignSystem.display2.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '점',
                    style: TossDesignSystem.body2.copyWith(
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: scoreColor,
              backgroundColor: scoreColor.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreMessage(score),
              style: TossDesignSystem.heading3.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    final content = history.summary['content'] as String? ??
                    history.summary['message'] as String? ??
                    '';

    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운세 요약',
              style: TossDesignSystem.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TossDesignSystem.body2.copyWith(
                color: isDark ? TossDesignSystem.grayDark800 : TossDesignSystem.gray800,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResult(BuildContext context, bool isDark) {
    final data = history.detailedResult!;
    final sections = <Widget>[];

    // 다양한 운세 데이터 구조 처리
    _addSectionIfExists(sections, data, 'advice', '조언', Icons.lightbulb, TossDesignSystem.warningOrange, isDark);
    _addSectionIfExists(sections, data, 'love', '연애운', Icons.favorite, TossDesignSystem.errorRed, isDark);
    _addSectionIfExists(sections, data, 'career', '직업운', Icons.work, TossDesignSystem.tossBlue, isDark);
    _addSectionIfExists(sections, data, 'money', '금전운', Icons.attach_money, TossDesignSystem.successGreen, isDark);
    _addSectionIfExists(sections, data, 'health', '건강운', Icons.favorite_border, TossDesignSystem.purple, isDark);
    _addSectionIfExists(sections, data, 'overall', '종합운', Icons.star, TossDesignSystem.orange, isDark);
    _addSectionIfExists(sections, data, 'description', '상세 설명', Icons.description, TossDesignSystem.gray600, isDark);

    // 행운 아이템 처리
    if (data['luckyItems'] != null || data['lucky_items'] != null) {
      final luckyItems = data['luckyItems'] ?? data['lucky_items'];
      if (luckyItems is Map<String, dynamic>) {
        sections.add(_buildLuckyItemsSection(context, isDark, luckyItems));
      }
    }

    // 추천 사항 처리
    if (data['recommendations'] != null) {
      final recommendations = data['recommendations'];
      if (recommendations is List && recommendations.isNotEmpty) {
        sections.add(_buildListSection(context, isDark, '추천 사항', recommendations.cast<String>(), Icons.check_circle, TossDesignSystem.successGreen));
      }
    }

    // 주의 사항 처리
    if (data['warnings'] != null) {
      final warnings = data['warnings'];
      if (warnings is List && warnings.isNotEmpty) {
        sections.add(_buildListSection(context, isDark, '주의 사항', warnings.cast<String>(), Icons.warning_amber, TossDesignSystem.warningOrange));
      }
    }

    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(children: sections);
  }

  void _addSectionIfExists(
    List<Widget> sections,
    Map<String, dynamic> data,
    String key,
    String title,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final value = data[key];
    if (value != null && value is String && value.isNotEmpty) {
      sections.add(_buildContentSection(title, value, icon, color, isDark));
    }
  }

  Widget _buildContentSection(String title, String content, IconData icon, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              FortuneTextCleaner.clean(content),
              style: TossDesignSystem.body3.copyWith(
                color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyItemsSection(BuildContext context, bool isDark, Map<String, dynamic> luckyItems) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: TossDesignSystem.purple, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  '행운 아이템',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (luckyItems['color'] != null)
                  _buildLuckyChip('색상', luckyItems['color'].toString(), Icons.palette, TossDesignSystem.purple),
                if (luckyItems['number'] != null)
                  _buildLuckyChip('숫자', luckyItems['number'].toString(), Icons.looks_one, TossDesignSystem.successGreen),
                if (luckyItems['direction'] != null)
                  _buildLuckyChip('방향', luckyItems['direction'].toString(), Icons.explore, TossDesignSystem.tossBlue),
                if (luckyItems['time'] != null)
                  _buildLuckyChip('시간', luckyItems['time'].toString(), Icons.schedule, TossDesignSystem.warningOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TossDesignSystem.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, bool isDark, String title, List<String> items, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      FortuneTextCleaner.clean(item),
                      style: TossDesignSystem.body3.copyWith(
                        color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: history.tags!.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '#$tag',
            style: TossDesignSystem.caption.copyWith(
              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: UnifiedButton(
        text: '공유하기',
        onPressed: () {
          final score = history.summary['score'] as int? ?? 0;
          final content = history.summary['content'] as String? ??
                          history.summary['message'] as String? ?? '';
          Share.share(
            '${history.title}\n\n$content\n\n운세 점수: $score점\n\n날짜: ${DateFormat('yyyy년 MM월 dd일').format(history.createdAt)}',
          );
        },
        style: UnifiedButtonStyle.primary,
        icon: const Icon(Icons.share, size: 20),
        width: double.infinity,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return '최상의 운세!';
    if (score >= 80) return '아주 좋은 운세';
    if (score >= 70) return '좋은 운세';
    if (score >= 60) return '무난한 운세';
    if (score >= 50) return '평범한 운세';
    if (score >= 40) return '조심이 필요한 날';
    return '신중한 하루를 보내세요';
  }
}
