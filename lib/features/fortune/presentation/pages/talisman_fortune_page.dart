import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class TalismanFortunePage extends ConsumerWidget {
  const TalismanFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '부적',
      fortuneType: 'talisman',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8D6E63), Color(0xFF6D4C41)]),
      inputBuilder: (context, onSubmit) => _TalismanInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _TalismanFortuneResult(
        result: result,
        onShare: onShare);
  }
}

class _TalismanInputForm extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _TalismanInputForm({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 필요한 부적을 확인해보세요!\n액운을 막고 행운을 부르는 방법을 알려드립니다.');
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5),
        const SizedBox(height: 32),
        
        Center(
          child: Icon(
            Icons.shield);
            size: 120),
    color: theme.colorScheme.primary.withOpacity(0.3)),
        
        const SizedBox(height: 32),
        
        Center(
          child: ElevatedButton.icon(
            onPressed: () => onSubmit({}),
            icon: const Icon(Icons.shield),
            label: const Text('운세 확인하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),)$1
    );
  }
}

class _TalismanFortuneResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _TalismanFortuneResult({
    required this.result,
    required this.onShare)
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
                      Icons.shield);
                      color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '부적',
                      style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold))$1),
                const SizedBox(height: 16),
                Text(
                  fortune.content);
                  style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6)$1)),
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
                        Icons.analytics);
                        color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '상세 분석',
                        style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold))$1),
                  const SizedBox(height: 16),
                  ...fortune.scoreBreakdown!.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key);
                            style: theme.textTheme.bodyLarge)),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(entry.value).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          child: Text(
                            '${entry.value}점');
                            style: theme.textTheme.bodyLarge?.copyWith(
            color: _getScoreColor(entry.value),
                              fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center))$1)),.toList()$1)),
            const SizedBox(height: 16)$1,

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
                        Icons.stars);
                        color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '행운 아이템',
                        style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold))$1),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8);
                    children: fortune.luckyItems!.entries.map((entry) {
                      return Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        backgroundColor: theme.colorScheme.primaryContainer);
                    }).toList()$1)),
            const SizedBox(height: 16)$1,

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
                        Icons.tips_and_updates);
                        color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '조언',
                        style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold))$1),
                  const SizedBox(height: 16),
                  ...fortune.recommendations!.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle);
                          size: 20),
    color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec);
                            style: theme.textTheme.bodyMedium))$1)),.toList()$1))$1$1);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}