import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/toss_design_system.dart';

class TossNumberPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback? onBackspacePressed;
  final VoidCallback? onDoubleZeroPressed;
  
  const TossNumberPad({
    super.key,
    required this.onNumberPressed,
    this.onBackspacePressed,
    this.onDoubleZeroPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TossDesignSystem.white,
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          _buildNumberRow(['1', '2', '3']),
          
          // Row 2: 4, 5, 6
          _buildNumberRow(['4', '5', '6']),
          
          // Row 3: 7, 8, 9
          _buildNumberRow(['7', '8', '9']),
          
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
                child: _buildNumberButton('0', onPressed: () => onNumberPressed('0')),
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
  
  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      children: numbers.map((number) => 
        Expanded(
          child: _buildNumberButton(number, onPressed: () => onNumberPressed(number)),
        )
      ).toList(),
    );
  }
  
  Widget _buildNumberButton(String number, {required VoidCallback onPressed}) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(1),
      child: Material(
        color: TossDesignSystem.white,
        child: InkWell(
          onTap: () {
            print('[TossNumberPad] Button $number pressed at ${DateTime.now()}');
            HapticFeedback.lightImpact();
            onPressed();
            print('[TossNumberPad] onPressed callback executed for $number');
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: TossDesignSystem.gray100, width: 0.5),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 24,
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
            print('[TossNumberPad] Backspace pressed at ${DateTime.now()}');
            HapticFeedback.lightImpact();
            onBackspacePressed!();
            print('[TossNumberPad] onBackspacePressed callback executed');
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