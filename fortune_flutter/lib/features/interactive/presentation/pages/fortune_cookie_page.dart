import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../fortune/domain/models/fortune_result.dart';
import '../../../fortune/presentation/pages/base_fortune_page_v2.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_theme_extensions.dart';
import 'dart:math' as math;

class FortuneCookiePage extends ConsumerWidget {
  const FortuneCookiePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '포춘 쿠키',
      fortuneType: 'fortune-cookie',
      headerGradient: LinearGradient(
        colors: [AppTheme.warningColor, AppTheme.tertiaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      inputBuilder: (context, onSubmit) => _FortuneCookieInput(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _FortuneCookieResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _FortuneCookieInput extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _FortuneCookieInput({required this.onSubmit});

  @override
  State<_FortuneCookieInput> createState() => _FortuneCookieInputState();
}

class _FortuneCookieInputState extends State<_FortuneCookieInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onCookieTap() async {
    setState(() {
      _isShaking = true;
    });

    // Shake animation
    for (int i = 0; i < 3; i++) {
      await _animationController.forward();
      await _animationController.reverse();
    }

    setState(() {
      _isShaking = false;
    });

    // Submit with empty params as fortune cookie doesn't need user input
    widget.onSubmit({});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '포춘 쿠키를 터치하세요!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '오늘의 행운 메시지가 담겨있습니다',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.fortuneTheme.subtitleText,
            ),
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _onCookieTap,
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: _isShaking ? Offset(_shakeAnimation.value, 0) : Offset.zero,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.warningColor,
                          AppTheme.warningColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.warningColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.cookie,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          Text(
            '탭하여 열기',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.fortuneTheme.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _FortuneCookieResult extends StatelessWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _FortuneCookieResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final fortuneMessage = result.mainFortune ?? '오늘은 좋은 일이 생길 예정입니다!';
    final luckyNumbers = result.luckyItems?['lucky_numbers'] as List<dynamic>? ?? [7, 13, 21];
    final luckyColor = result.luckyItems?['lucky_color'] ?? '금색';
    final advice = result.recommendations?.firstOrNull ?? '긍정적인 마음가짐으로 하루를 시작하세요.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Opened cookie animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: value * math.pi * 2,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.warningColor,
                          AppTheme.tertiaryColor,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Fortune message
          GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Text(
                  '오늘의 메시지',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fortuneMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lucky items
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.looks_one,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '행운의 숫자',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.fortuneTheme.subtitleText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        luckyNumbers.join(', '),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.palette,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '행운의 색',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.fortuneTheme.subtitleText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        luckyColor,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Advice
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warningColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '조언',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  advice,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Share button
          ElevatedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            label: const Text('공유하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}