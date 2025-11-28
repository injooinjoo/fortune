import 'package:flutter/material.dart';
import 'score_widgets.dart';
import 'keyword_widgets.dart';
import 'lucky_item_widgets.dart';
import 'category_widgets.dart';
import 'chart_widgets.dart';
import 'misc_widgets.dart';

/// Facade class for backward compatibility with FortuneInfographicWidgets
///
/// This class delegates all calls to the split widget classes.
/// Use this for existing code that depends on FortuneInfographicWidgets.
class FortuneInfographicWidgets {
  FortuneInfographicWidgets._();

  // ========== Score Widgets ==========

  /// 토스 스타일 메인 점수 표시 (깔끔한 흰 배경)
  static Widget buildTossStyleMainScore({
    required int score,
    required String message,
    String? subtitle,
    double size = 280,
  }) => ScoreWidgets.buildTossStyleMainScore(
    score: score,
    message: message,
    subtitle: subtitle,
    size: size,
  );

  /// Hero-style score chart (원형 점수 차트)
  static Widget buildHeroScoreChart({
    required int score,
    required String title,
    double size = 200,
    Color? color,
  }) => ScoreWidgets.buildHeroScoreChart(
    score: score,
    title: title,
    size: size,
    color: color,
  );

  /// Mini statistics dashboard (토스 스타일)
  static Widget buildMiniStatsDashboard({
    required Map<String, dynamic> stats,
    required BuildContext context,
  }) => ScoreWidgets.buildMiniStatsDashboard(
    stats: stats,
    context: context,
  );

  // ========== Keyword Widgets ==========

  /// Keyword cloud widget
  static Widget buildKeywordCloud({
    required List<String> keywords,
    double maxFontSize = 32,
    double minFontSize = 14,
    Map<String, double>? importance,
  }) => KeywordWidgets.buildKeywordCloud(
    keywords: keywords,
    maxFontSize: maxFontSize,
    minFontSize: minFontSize,
    importance: importance,
  );

  /// 토스 스타일 키워드 섹션 (개선된 디자인)
  static Widget buildTossStyleKeywordSection({
    required List<String> keywords,
    required Map<String, double> importance,
    required BuildContext context,
  }) => KeywordWidgets.buildTossStyleKeywordSection(
    keywords: keywords,
    importance: importance,
    context: context,
  );

  // ========== Lucky Item Widgets ==========

  /// Lucky items grid
  static Widget buildLuckyItemsGrid({
    required List<Map<String, dynamic>> items,
    int crossAxisCount = 2,
    double? itemSize,
    List<Map<String, dynamic>>? luckyItems,
  }) => LuckyItemWidgets.buildLuckyItemsGrid(
    items: items,
    crossAxisCount: crossAxisCount,
    itemSize: itemSize,
    luckyItems: luckyItems,
  );

  /// Lucky tags with color, food, numbers, and direction
  static Widget buildTossStyleLuckyTags({
    String? luckyColor,
    String? luckyFood,
    List<String>? luckyNumbers,
    String? luckyDirection,
  }) => LuckyItemWidgets.buildTossStyleLuckyTags(
    luckyColor: luckyColor,
    luckyFood: luckyFood,
    luckyNumbers: luckyNumbers,
    luckyDirection: luckyDirection,
  );

  /// Lucky outfit (placeholder implementation)
  static Widget buildTossStyleLuckyOutfit({
    String? outfitDescription,
    List<String>? outfitItems,
    String? outfitStyle,
  }) => LuckyItemWidgets.buildTossStyleLuckyOutfit(
    outfitDescription: outfitDescription,
    outfitItems: outfitItems,
    outfitStyle: outfitStyle,
  );

  /// Saju lucky items (placeholder implementation)
  static Widget buildSajuLuckyItems(
    Map<String, dynamic>? sajuInsight, {
    required bool isDarkMode,
  }) => LuckyItemWidgets.buildSajuLuckyItems(
    sajuInsight,
    isDarkMode: isDarkMode,
  );

  // ========== Category Widgets ==========

  /// Category cards implementation
  static Widget buildCategoryCards(
    Map<String, dynamic> categories, {
    required bool isDarkMode,
  }) => CategoryWidgets.buildCategoryCards(
    categories,
    isDarkMode: isDarkMode,
  );

  /// Fortune summary with user profile information
  static Widget buildTossStyleFortuneSummary({
    Map<String, dynamic>? fortuneSummary,
    String? userZodiacAnimal,
    String? userZodiacSign,
    String? userMBTI,
  }) => CategoryWidgets.buildTossStyleFortuneSummary(
    fortuneSummary: fortuneSummary,
    userZodiacAnimal: userZodiacAnimal,
    userZodiacSign: userZodiacSign,
    userMBTI: userMBTI,
  );

  /// AI insights card with real data display
  static Widget buildAIInsightsCard({
    String? insight,
    List<String>? tips,
  }) => CategoryWidgets.buildAIInsightsCard(
    insight: insight,
    tips: tips,
  );

  // ========== Chart Widgets ==========

  /// Radar chart with real score data
  static Widget buildRadarChart({
    required Map<String, int> scores,
    double? size,
    Color? primaryColor,
  }) => ChartWidgets.buildRadarChart(
    scores: scores,
    size: size,
    primaryColor: primaryColor,
  );

  /// Timeline chart with real hourly data
  static Widget buildTimelineChart({
    required List<int> hourlyScores,
    required int currentHour,
    required double height,
  }) => ChartWidgets.buildTimelineChart(
    hourlyScores: hourlyScores,
    currentHour: currentHour,
    height: height,
  );

  // ========== Misc Widgets ==========

  /// Action checklist (placeholder implementation)
  static Widget buildActionChecklist(
    List<Map<String, dynamic>>? actions, {
    required bool isDarkMode,
  }) => MiscWidgets.buildActionChecklist(
    actions,
    isDarkMode: isDarkMode,
  );

  /// Weather fortune widget
  static Widget buildWeatherFortune(
    Map<String, dynamic>? weatherSummary,
    int score,
  ) => MiscWidgets.buildWeatherFortune(
    weatherSummary,
    score,
  );

  /// Shareable card (placeholder implementation)
  static Widget buildShareableCard(Map<String, dynamic>? shareCard) =>
    MiscWidgets.buildShareableCard(shareCard);

  /// Celebrity list (placeholder implementation)
  static Widget buildTossStyleCelebrityList({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> celebrities,
  }) => MiscWidgets.buildTossStyleCelebrityList(
    title: title,
    subtitle: subtitle,
    celebrities: celebrities,
  );

  /// Age fortune card (placeholder implementation)
  static Widget buildTossStyleAgeFortuneCard({
    required int userAge,
    String? ageDescription,
    int? ageScore,
  }) => MiscWidgets.buildTossStyleAgeFortuneCard(
    userAge: userAge,
    ageDescription: ageDescription,
    ageScore: ageScore,
  );

  /// Share section (placeholder implementation)
  static Widget buildTossStyleShareSection({
    VoidCallback? onShare,
    VoidCallback? onSaveImage,
  }) => MiscWidgets.buildTossStyleShareSection(
    onShare: onShare,
    onSaveImage: onSaveImage,
  );
}
