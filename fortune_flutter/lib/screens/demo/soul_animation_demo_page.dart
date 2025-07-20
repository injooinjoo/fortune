import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/components/soul_earn_animation.dart';
import '../../shared/components/soul_consume_animation.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../shared/components/app_header.dart';
import '../../shared/components/token_balance_widget.dart';

class SoulAnimationDemoPage extends ConsumerWidget {
  const SoulAnimationDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppHeader(
        title: '영혼 애니메이션 데모',
        actions: const [
          TokenBalanceWidget(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                '영혼 획득/소비 애니메이션 테스트',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // 영혼 획득 애니메이션 섹션
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '영혼 획득 애니메이션',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '무료 운세를 볼 때 영혼을 획득하는 애니메이션',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildEarnButton(context, '+1 영혼', 1),
                        _buildEarnButton(context, '+3 영혼', 3),
                        _buildEarnButton(context, '+5 영혼', 5),
                        _buildEarnButton(context, '+10 영혼', 10),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 영혼 소비 애니메이션 섹션
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '영혼 소비 애니메이션',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '프리미엄 운세를 볼 때 영혼을 소비하는 애니메이션',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildConsumeButton(context, '-10 영혼', 10),
                        _buildConsumeButton(context, '-20 영혼', 20),
                        _buildConsumeButton(context, '-30 영혼', 30),
                        _buildConsumeButton(context, '-50 영혼', 50),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // 설명
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '애니메이션은 화면 중앙에서 시작하여\n우측 상단 영혼 잔액으로 이동합니다',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarnButton(BuildContext context, String label, int amount) {
    return ElevatedButton(
      onPressed: () {
        SoulEarnAnimation.show(
          context: context,
          soulAmount: amount,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.withValues(alpha: 0.2),
        foregroundColor: Colors.green,
      ),
      child: Text(label),
    );
  }

  Widget _buildConsumeButton(BuildContext context, String label, int amount) {
    return ElevatedButton(
      onPressed: () {
        SoulConsumeAnimation.show(
          context: context,
          soulAmount: amount,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.withValues(alpha: 0.2),
        foregroundColor: Colors.orange,
      ),
      child: Text(label),
    );
  }
}