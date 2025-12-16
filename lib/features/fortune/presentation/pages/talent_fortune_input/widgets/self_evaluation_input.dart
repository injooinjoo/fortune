import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';

class SelfEvaluationInput extends StatelessWidget {
  final TextEditingController strengthsController;
  final TextEditingController weaknessesController;
  final Function(String)? onChanged;

  const SelfEvaluationInput({
    super.key,
    required this.strengthsController,
    required this.weaknessesController,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        TextField(
          controller: strengthsController,
          decoration: InputDecoration(
            labelText: '강점',
            hintText: '예: 책임감, 빠른 실행력, 창의적 사고...',
            filled: true,
            fillColor: colors.backgroundSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 2,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: weaknessesController,
          decoration: InputDecoration(
            labelText: '약점',
            hintText: '예: 우유부단함, 쉽게 포기함, 조급함...',
            filled: true,
            fillColor: colors.backgroundSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
