import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/toss_design_system.dart';
import '../../../core/providers/user_settings_provider.dart';
import '../../../core/theme/typography_theme.dart';

class NumericKeypad extends ConsumerWidget {
  final Function(String) onNumberPressed;
  final VoidCallback? onBackspacePressed;
  final VoidCallback? onDoubleZeroPressed;
  
  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    this.onBackspacePressed,
    this.onDoubleZeroPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    return Container(
      color: TossDesignSystem.white,
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          _buildNumberRow(['1', '2', '3'], typography),
          
          // Row 2: 4, 5, 6
          _buildNumberRow(['4', '5', '6'], typography),
          
          // Row 3: 7, 8, 9
          _buildNumberRow(['7', '8', '9'], typography),
          
          // Row 4: Empty, 0, Backspace
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.all(1),
                ),
              ),
              Expanded(
                child: _buildNumberButton('0', typography, onPressed: () => onNumberPressed('0')),
              ),
              Expanded(
                child: _buildBackspaceButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberRow(List<String> numbers, TypographyTheme typography) {
    return Row(
      children: numbers.map((number) => 
        Expanded(
          child: _buildNumberButton(number, typography, onPressed: () => onNumberPressed(number)),
        )
      ).toList(),
    );
  }
  
  Widget _buildNumberButton(String number, TypographyTheme typography, {required VoidCallback onPressed}) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(1),
      child: Material(
        color: TossDesignSystem.white,
        child: InkWell(
          onTap: () {
            debugPrint('[NumericKeypad] Button $number pressed at ${DateTime.now()}');
            HapticFeedback.lightImpact();
            onPressed();
            debugPrint('[NumericKeypad] onPressed callback executed for $number');
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: TossDesignSystem.gray100, width: 0.5),
            ),
            child: Center(
              child: Text(
                number,
                style: typography.displaySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TossDesignSystem.grayDark900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBackspaceButton() {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(1),
      child: Material(
        color: TossDesignSystem.white,
        child: InkWell(
          onTap: onBackspacePressed != null ? () {
            debugPrint('[NumericKeypad] Backspace pressed at ${DateTime.now()}');
            HapticFeedback.lightImpact();
            onBackspacePressed!();
            debugPrint('[NumericKeypad] onBackspacePressed callback executed');
          } : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: TossDesignSystem.gray100, width: 0.5),
            ),
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 24,
                color: onBackspacePressed != null ? TossDesignSystem.gray700 : TossDesignSystem.gray300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}