import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/fortune_type_names.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../domain/models/fortune_history.dart';

class TimelineView extends StatelessWidget {
  final List<FortuneHistory> history;
  final double fontScale;
  final Function(FortuneHistory) onItemTap;

  const TimelineView({
    Key? key,
    required this.history,
    required this.fontScale,
    required this.onItemTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Group history by month
    final Map<String, List<FortuneHistory>> groupedByMonth = {};
    for (final item in history) {
      final monthKey = DateFormat('yyyy-MM').format(item.createdAt);
      groupedByMonth.putIfAbsent(monthKey, () => []).add(item);
    }
    
    // Sort months in descending order
    final sortedMonths = groupedByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    if (sortedMonths.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '운세 타임라인',
            style: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...sortedMonths.map((monthKey) {
            final monthData = groupedByMonth[monthKey]!;
            final monthDate = DateTime.parse('$monthKey-01');
            
            // Calculate average score for the month
            final scores = monthData
                .where((item) => item.summary['score'] != null)
                .map((item) => item.summary['score'] as int)
                .toList();
            final avgScore = scores.isEmpty 
                ? 0 
                : (scores.reduce((a, b) => a + b) / scores.length).round();
            
            // Count fortune types
            final Map<String, int> typeCount = {};
            for (final item in monthData) {
              final type = FortuneTypeNames.getName(item.fortuneType);
              typeCount[type] = (typeCount[type] ?? 0) + 1;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy년 MM월').format(monthDate),
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getScoreColor(avgScore).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              child: Text(
                                '평균 ${avgScore}점',
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(avgScore)),
                            const SizedBox(width: 8),
                            Text(
                              '${monthData.length}회',
                              style: TextStyle(
                                fontSize: 12 * fontScale,
                                color: theme.colorScheme.onSurface.withOpacity(0.6)))])])),
                  const SizedBox(height: 12),
                  
                  // Fortune Type Summary
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: typeCount.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(20),
                        child: Text(
                          '${entry.key} ${entry.value}회',
                          style: TextStyle(
                            fontSize: 12 * fontScale,
                            color: theme.colorScheme.onSurface.withOpacity(0.7)));
                    }).toList()),
                  const SizedBox(height: 16),
                  
                  // Fortune Items
                  Column(
                    children: monthData.map((item) {
                      final score = item.summary['score'] as int? ?? 0;
                      final content = item.summary['content'] as String? ?? '';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => onItemTap(item),
                          borderRadius: BorderRadius.circular(12),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Date & Score
                                Container(
                                  width: 60,
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat('dd').format(item.createdAt),
                                        style: TextStyle(
                                          fontSize: 20 * fontScale,
                                          fontWeight: FontWeight.bold)),
                                      Text(
                                        DateFormat('E', 'ko').format(item.createdAt),
                                        style: TextStyle(
                                          fontSize: 12 * fontScale,
                                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getScoreColor(score).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        child: Text(
                                          '$score점',
                                          style: TextStyle(
                                            fontSize: 12 * fontScale,
                                            fontWeight: FontWeight.bold,
                                            color: _getScoreColor(score))]),
                                const SizedBox(width: 16),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _getFortuneIcon(item.fortuneType),
                                            style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 16 * fontScale,
                                              fontWeight: FontWeight.bold))]),
                                      const SizedBox(height: 4),
                                      Text(
                                        content,
                                        style: TextStyle(
                                          fontSize: 14 * fontScale,
                                          color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)])),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3)]));
                    }).toList()]);
          }).toList()]));
  }

  String _getFortuneIcon(String fortuneType) {
    final icons = {
      'daily': '📅',
      'today': '☀️',
      'weekly': '📆',
      'monthly': '🗓️',
      'love': '💕',
      'money': '💰',
      'career': '💼',
      'health': '🏥',
      'study': '📚',
      'tarot': '🔮'};
    
    for (final entry in icons.entries) {
      if (fortuneType.contains(entry.key)) {
        return entry.value;
      }
    }
    return '🔮';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}