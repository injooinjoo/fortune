import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/toss_design_system.dart';
import '../theme/app_theme_extensions.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../shared/components/app_header.dart'; // FontSize enum
import '../../presentation/providers/font_size_provider.dart';
import '../utils/haptic_utils.dart';
import '../../presentation/widgets/fortune_explanation_bottom_sheet.dart';
import '../../core/constants/fortune_type_names.dart';

/// 🎨 공통 운세 결과 위젯 라이브러리
///
/// Silicon Valley Best Practices:
/// - ✅ Reusable Components (재사용 가능한 컴포넌트)
/// - ✅ Composition over Inheritance (상속보다 조합)
/// - ✅ Consistent Design System (일관된 디자인 시스템)
/// - ✅ Type-Safe Callbacks (타입 안전 콜백)
///
/// **사용 예시**:
/// ```dart
/// FortuneResultWidgets.buildScoreCard(
///   context: context,
///   score: 85,
///   fortuneType: 'mbti',
///   category: 'MBTI 운세',
/// )
/// ```
class FortuneResultWidgets {
  // Private constructor to prevent instantiation
  FortuneResultWidgets._();

  // ==================== 📊 점수 표시 ====================

  /// 전체 점수 카드 (Overall Score)
  ///
  /// **파라미터**:
  /// - `context`: BuildContext
  /// - `score`: 운세 점수 (0-100)
  /// - `fortuneType`: 운세 타입 (예: 'mbti', 'tarot')
  /// - `category`: 운세 카테고리 (예: 'MBTI 운세', '타로 운세')
  /// - `onHelpPressed`: 도움말 버튼 클릭 콜백 (optional)
  static Widget buildScoreCard({
    required BuildContext context,
    required int score,
    required String fortuneType,
    required String category,
    Map<String, dynamic>? fortuneData,
  }) {
    final scoreColor = _getScoreColor(context, score);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      scoreColor.withValues(alpha: 0.2),
                      scoreColor.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: scoreColor.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$score점',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.help_outline,
                      color: TossDesignSystem.white,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticUtils.lightImpact();
                      FortuneExplanationBottomSheet.show(
                        context,
                        fortuneType: fortuneType,
                        fortuneData: fortuneData ?? {
                          'score': score,
                        },
                      );
                    },
                    tooltip: '${FortuneTypeNames.getName(fortuneType)} 가이드',
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getScoreMessage(score),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  /// 점수 분해 (Score Breakdown)
  ///
  /// **파라미터**:
  /// - `context`: BuildContext
  /// - `scoreBreakdown`: 세부 점수 맵 (예: {'연애운': 80, '금전운': 70})
  static Widget buildScoreBreakdown({
    required BuildContext context,
    required Map<String, dynamic> scoreBreakdown,
  }) {
    if (scoreBreakdown.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('세부 점수', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ...scoreBreakdown.entries.map((entry) {
            final score = entry.value as int;
            final color = _getScoreColor(context, score);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$score점',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== 🎁 행운 아이템 ====================

  /// 행운 아이템 그리드 (Lucky Items)
  ///
  /// **파라미터**:
  /// - `context`: BuildContext
  /// - `luckyItems`: 행운 아이템 맵 (예: {'color': '빨강', 'number': '7'})
  static Widget buildLuckyItems({
    required BuildContext context,
    required Map<String, dynamic> luckyItems,
  }) {
    if (luckyItems.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '행운의 아이템',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: luckyItems.entries.map((entry) {
              return GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(16),
                blur: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getLuckyItemIcon(context, entry.key),
                    const SizedBox(height: 8),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== 📝 본문 ====================

  /// 운세 본문 (Description)
  ///
  /// **파라미터**:
  /// - `context`: BuildContext
  /// - `ref`: WidgetRef (폰트 크기 설정용)
  /// - `description`: 운세 본문 텍스트
  /// - `fortuneType`: 운세 타입 (도움말 버튼용)
  /// - `fortuneData`: 운세 데이터 (도움말 버튼용)
  static Widget buildDescription({
    required BuildContext context,
    required WidgetRef ref,
    required String description,
    required String fortuneType,
    Map<String, dynamic>? fortuneData,
  }) {
    if (description.isEmpty) return const SizedBox.shrink();

    final fontSize = ref.watch(fontSizeProvider);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상세 운세',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  HapticUtils.lightImpact();
                  FortuneExplanationBottomSheet.show(
                    context,
                    fortuneType: fortuneType,
                    fortuneData: fortuneData ?? {},
                  );
                },
                tooltip: '${FortuneTypeNames.getName(fortuneType)} 가이드',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: _getFontSize(fontSize),
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  // ==================== 💡 추천 사항 ====================

  /// 추천 사항 리스트 (Recommendations)
  ///
  /// **파라미터**:
  /// - `context`: BuildContext
  /// - `recommendations`: 추천 사항 리스트
  static Widget buildRecommendations({
    required BuildContext context,
    required List<String> recommendations,
  }) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추천 사항',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== 🔧 Helper Methods ====================

  /// 점수에 따른 색상 반환
  static Color _getScoreColor(BuildContext context, int score) {
    final fortuneTheme = context.fortuneTheme;
    if (score >= 80) return fortuneTheme.scoreExcellent;
    if (score >= 60) return fortuneTheme.scoreGood;
    if (score >= 40) return fortuneTheme.scoreFair;
    return fortuneTheme.scorePoor;
  }

  /// 점수에 따른 메시지 반환
  static String _getScoreMessage(int score) {
    if (score >= 90) return '최고의 운세입니다! 🎉';
    if (score >= 80) return '아주 좋은 운세입니다! ✨';
    if (score >= 70) return '좋은 운세입니다 😊';
    if (score >= 60) return '평균적인 운세입니다';
    if (score >= 50) return '조심이 필요한 시기입니다';
    if (score >= 40) return '신중히 행동하세요';
    return '어려운 시기지만 극복할 수 있습니다';
  }

  /// 행운 아이템 아이콘 반환
  static Widget _getLuckyItemIcon(BuildContext context, String type) {
    IconData iconData;
    Color color;
    final colorScheme = Theme.of(context).colorScheme;
    final fortuneTheme = context.fortuneTheme;

    switch (type.toLowerCase()) {
      case 'color':
      case '색깔':
        iconData = Icons.palette_rounded;
        color = colorScheme.primary;
        break;
      case 'number':
      case '숫자':
        iconData = Icons.looks_one_rounded;
        color = colorScheme.secondary;
        break;
      case 'direction':
      case '방향':
        iconData = Icons.explore_rounded;
        color = fortuneTheme.scoreExcellent;
        break;
      case 'time':
      case '시간':
        iconData = Icons.access_time_rounded;
        color = fortuneTheme.scoreFair;
        break;
      case 'food':
      case '음식':
        iconData = Icons.restaurant_rounded;
        color = colorScheme.error;
        break;
      case 'person':
      case '사람':
        iconData = Icons.person_rounded;
        color = colorScheme.tertiary;
        break;
      default:
        iconData = Icons.star_rounded;
        color = colorScheme.primary;
    }

    return Icon(iconData, size: 32, color: color);
  }

  /// 폰트 크기 반환
  static double _getFontSize(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 14;
      case FontSize.medium:
        return 16;
      case FontSize.large:
        return 18;
    }
  }
}
