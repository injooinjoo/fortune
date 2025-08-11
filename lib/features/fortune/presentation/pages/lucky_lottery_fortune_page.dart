import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class LuckyLotteryFortunePage extends ConsumerWidget {
  const LuckyLotteryFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '로또 운세',
      fortuneType: 'lucky-lottery',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
      inputBuilder: (context, onSubmit) => _LotteryInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _LotteryFortuneResult(
        result: result,
        onShare: onShare));
  }
}

class _LotteryInputForm extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _LotteryInputForm({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 로또 행운을 확인해보세요!\n당신의 행운 번호와 구매 전략을 알려드립니다.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5)),
        const SizedBox(height: 32),
        
        // Lottery balls animation
        Center(
          child: Container(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        Center(
          child: ElevatedButton.icon(
            onPressed: () => onSubmit({}),
            icon: const Icon(Icons.casino_rounded),
            label: const Text('행운 번호 확인하기'),
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

class _LotteryFortuneResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _LotteryFortuneResult({
    required this.result,
    required this.onShare});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortune = result.fortune;
    
    // Extract lucky numbers from metadata
    final luckyNumbers = fortune.metadata?['luckyNumbers'] as List<int>? ?? [];
    final bonusNumber = fortune.metadata?['bonusNumber'] as int? ?? 0;
    final bestTime = fortune.metadata?['bestTime'] as String? ?? '';
    final bestPlace = fortune.metadata?['bestPlace'] as String? ?? '';
    final avoidNumbers = fortune.metadata?['avoidNumbers'] as List<int>? ?? [];
    final strategy = fortune.metadata?['strategy'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lucky Numbers Display
          GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.withOpacity(0.1),
                Colors.orange.withOpacity(0.1)]),
            child: Column(
              children: [
                Text(
                  '오늘의 행운 번호',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...luckyNumbers.map((number) => _buildNumberBall(context, number, false)).toList(),
                    const SizedBox(width: 16),
                    Icon(Icons.add, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 16),
                    _buildNumberBall(context, bonusNumber, true)])])),
          const SizedBox(height: 16),

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
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '상세 분석',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold)),
                  ],
                ),  
                const SizedBox(height: 16),
                Text(
                  fortune.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Best Time & Place
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: theme.colorScheme.primary,
                        size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '행운의 시간',
                        style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        bestTime,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              ),  
              const SizedBox(width: 16),
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.place,
                        color: theme.colorScheme.primary,
                        size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '행운의 장소',
                        style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        bestPlace,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Strategy
          if (strategy.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        '구매 전략',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold)),
                    ],
                  ),  
                  const SizedBox(height: 16),
                  Text(
                    strategy,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 16)],

          // Avoid Numbers
          if (avoidNumbers.isNotEmpty) ...[
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.05),
                  Colors.orange.withOpacity(0.05)]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '피해야 할 번호',
                        style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: avoidNumbers.map((number) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          number.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16)],

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
                        color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '행운 팁',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold)),
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
                          color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec,
                            style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildNumberBall(BuildContext context, int number, bool isBonus) {
    final color = _getNumberColor(number);
    
    return Container(
      width: 45,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBonus 
            ? [Colors.red, Colors.deepOrange]
            : [color, color.withOpacity(0.8)]),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white),
        ),
      ),
    );
  }

  Color _getNumberColor(int number) {
    if (number <= 10) return Colors.yellow[700]!;
    if (number <= 20) return Colors.blue[700]!;
    if (number <= 30) return Colors.red[700]!;
    if (number <= 40) return Colors.grey[700]!;
    return Colors.green[700]!;
  }
}