import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class WishFortunePage extends ConsumerWidget {
  const WishFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '소원 성취',
      fortuneType: 'wish',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF4081), Color(0xFFF50057)]),
      inputBuilder: (context, onSubmit) => _WishInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _WishFortuneResult(
        result: result,
        onShare: onShare));
  }
}

class _WishInputForm extends StatelessWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _WishInputForm({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '소원 성취 가능성을 확인해보세요!\n소원을 이루기 위한 방법을 알려드립니다.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5)),
        const SizedBox(height: 32),
        
        Center(
          child: Icon(
            Icons.star,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.3))),
        
        const SizedBox(height: 32),
        
        Center(
          child: ElevatedButton.icon(
            onPressed: () => onSubmit({}),
            icon: const Icon(Icons.star),
            label: const Text('운세 확인하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)))))]);
  }
}

class _WishFortuneResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _WishFortuneResult({
    required this.result,
    required this.onShare});

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
                      Icons.star,
                      color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '소원 성취 운세',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                Text(
                  fortune.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6))]))]));
  }
}