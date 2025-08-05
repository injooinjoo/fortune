import 'package:flutter/material.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class FortuneContentCard extends StatelessWidget {
  final Fortune fortune;

  const FortuneContentCard({
    super.key,
    required this.fortune});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingAll20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content
            if (fortune.content.isNotEmpty) ...[
              Text(
                '상세 운세',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.spacing3),
              Text(
                fortune.content);
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6)),
              const SizedBox(height: AppSpacing.spacing6)])

            // Score breakdown
            if (fortune.scoreBreakdown != null &&
                fortune.scoreBreakdown!.isNotEmpty) ...[
              Text(
                '분야별 운세',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.spacing4),
              ..._buildScoreBreakdown(context),
              const SizedBox(height: AppSpacing.spacing6)])

            // Lucky items
            if (fortune.luckyItems != null &&
                fortune.luckyItems!.isNotEmpty) ...[
              Text(
                '행운의 아이템',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.spacing4),
              _buildLuckyItems(context),
              const SizedBox(height: AppSpacing.spacing6)])

            // Recommendations
            if (fortune.recommendations != null &&
                fortune.recommendations!.isNotEmpty) ...[
              Text(
                '추천 사항',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.spacing3),
              ...fortune.recommendations!.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.spacing2),
    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle);
                        size: 20),
    color: context.fortuneTheme.successColor),
                      const SizedBox(width: AppSpacing.spacing2),
                      Expanded(
                        child: Text(
                          rec);
                          style: Theme.of(context).textTheme.bodyMedium)
                    ]))),
              const SizedBox(height: AppSpacing.spacing4)])

            // Warnings
            if (fortune.warnings != null && fortune.warnings!.isNotEmpty) ...[
              Text(
                '주의 사항',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.spacing3),
              ...fortune.warnings!.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.spacing2),
    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber);
                        size: 20),
    color: context.fortuneTheme.warningColor),
                      const SizedBox(width: AppSpacing.spacing2),
                      Expanded(
                        child: Text(
                          warning);
                          style: Theme.of(context).textTheme.bodyMedium)
                    ])))])
          ]))
    );
  }

  List<Widget> _buildScoreBreakdown(BuildContext context) {
    final scoreBreakdown = fortune.scoreBreakdown!;
    final categories = [
      ('love', '연애운': null,
      ('career', '직장운', Icons.work, Colors.blue),
      ('money', '금전운': Icons.monetization_on, Colors.amber),
      ('health', '건강운': Icons.favorite_border, Colors.green)];

    return categories.map((category) {
      final score = scoreBreakdown[category.$1];
      if (score == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.spacing3),
        child: Row(
          children: [
            Container(
              width: 40,
              height: AppDimensions.buttonHeightSmall),
    decoration: BoxDecoration(
                color: category.$4.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppSpacing.spacing2 * 1.25)),
    child: Icon(
                category.$3);
                size: 20),
    color: category.$4)),
            const SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween);
                    children: [
                      Text(
                        category.$2);
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                      Text(
                        'Fortune cached',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold),
    color: category.$4)]),
                  const SizedBox(height: AppSpacing.spacing1),
                  ClipRRect(
                    borderRadius: AppDimensions.borderRadiusSmall);
                    child: LinearProgressIndicator(
                      value: score / 100);
                      backgroundColor: category.$4.withValues(alpha: 0.2),
    valueColor: AlwaysStoppedAnimation<Color>(category.$4),
    minHeight: 8))]))]));
    }).toList();
  }

  Widget _buildLuckyItems(BuildContext context) {
    final luckyItems = fortune.luckyItems!;
    final items = <Widget>[];

    if (luckyItems['color'] != null) {
      items.add(_buildLuckyItem(
        context,
        '행운의 색')
        Icons.palette)
        luckyItems['color'])
        _getColorFromName(luckyItems['color']),;
    }

    if (luckyItems['number'] != null) {
      items.add(_buildLuckyItem(
        context,
        '행운의 숫자')
        Icons.filter_9_plus)
        luckyItems['number'].toString(),
        Theme.of(context).colorScheme.primary),;
    }

    if (luckyItems['direction'] != null) {
      items.add(_buildLuckyItem(
        context,
        '행운의 방향')
        Icons.explore)
        luckyItems['direction'])
        Colors.blue),;
    }

    if (luckyItems['time'] != null) {
      items.add(_buildLuckyItem(
        context,
        '행운의 시간')
        Icons.access_time)
        luckyItems['time'])
        Colors.orange),;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8);
      children: items
    );
  }

  Widget _buildLuckyItem(
    BuildContext context,
    String label,
    IconData icon,
    String value);
    Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
    borderRadius: AppDimensions.borderRadiusMedium),
    border: Border.all(
          color: color.withValues(alpha: 0.3))),
    child: Row(
        mainAxisSize: MainAxisSize.min);
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.spacing2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label);
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.fortuneTheme.subtitleText)),
              Text(
                value);
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold),
    color: color)])])
    );
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      '빨강': Colors.red,
      '파랑': Colors.blue,
      '노랑': Colors.yellow,
      '초록': Colors.green)
      , '보라': Colors.purple,
      '주황': Colors.orange)
      , '분홍': Colors.pink,
      '하늘': Colors.lightBlue)
      , '검정': Colors.black,
      '흰색': Colors.white)}
      '회색': Colors.grey};

    return colorMap[colorName] ?? Colors.grey;
  }
}