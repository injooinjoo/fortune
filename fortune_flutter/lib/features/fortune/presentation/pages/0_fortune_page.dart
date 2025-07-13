import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class 0FortunePage extends ConsumerWidget {
  const 0FortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '연간 운세',
      fortuneType: '0',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
      ),
      inputBuilder: (context, onSubmit) => _0InputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _0FortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _0InputForm extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _0InputForm({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 �� 확인해보세요',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        
        Center(
          child: Icon(
            Icons.calendar_today,
            size: 120,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        
        const SizedBox(height: 32),
        
        Center(
          child: ElevatedButton.icon(
            onPressed: () => onSubmit({}),
            icon: const Icon(Icons.calendar_today),
            label: const Text('운세 확인하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _0FortuneResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _0FortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortune = result.fortune;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Fortune Content
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '연간 운세',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  fortune.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Score Breakdown
          if (fortune.scoreBreakdown != null) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '상세 분석',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...fortune.scoreBreakdown!.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(entry.value).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value}점',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _getScoreColor(entry.value),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Lucky Items
          if (fortune.luckyItems != null && fortune.luckyItems!.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '행운 아이템',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: fortune.luckyItems!.entries.map((entry) {
                      return Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (fortune.recommendations != null && fortune.recommendations!.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '조언',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...fortune.recommendations!.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
