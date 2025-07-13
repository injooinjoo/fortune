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
