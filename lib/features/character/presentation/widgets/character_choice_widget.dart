import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/character_choice.dart';
import '../../domain/models/ai_character.dart';

/// 캐릭터 대화 중 선택지 표시 위젯
class CharacterChoiceWidget extends StatefulWidget {
  final ChoiceSet choiceSet;
  final AiCharacter character;
  final void Function(CharacterChoice choice) onChoiceSelected;
  final VoidCallback? onTimeout;

  const CharacterChoiceWidget({
    super.key,
    required this.choiceSet,
    required this.character,
    required this.onChoiceSelected,
    this.onTimeout,
  });

  @override
  State<CharacterChoiceWidget> createState() => _CharacterChoiceWidgetState();
}

class _CharacterChoiceWidgetState extends State<CharacterChoiceWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    // 타임아웃 설정
    if (widget.choiceSet.timeoutSeconds != null) {
      _remainingSeconds = widget.choiceSet.timeoutSeconds!;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_isSelected) return;

    HapticFeedback.mediumImpact();
    if (widget.choiceSet.defaultChoiceIndex != null &&
        widget.choiceSet.defaultChoiceIndex! < widget.choiceSet.choices.length) {
      final defaultChoice =
          widget.choiceSet.choices[widget.choiceSet.defaultChoiceIndex!];
      _selectChoice(defaultChoice);
    } else {
      widget.onTimeout?.call();
    }
  }

  void _selectChoice(CharacterChoice choice) {
    if (_isSelected) return;

    setState(() => _isSelected = true);
    HapticFeedback.lightImpact();
    _timer?.cancel();

    // 선택 애니메이션 후 콜백
    Future.delayed(const Duration(milliseconds: 200), () {
      widget.onChoiceSelected(choice);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DSColors.surfaceDark : Colors.grey[100];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.character.accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상황 설명 (있는 경우)
            if (widget.choiceSet.situation != null) ...[
              Text(
                widget.choiceSet.situation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // 타이머 표시 (있는 경우)
            if (widget.choiceSet.timeoutSeconds != null && !_isSelected) ...[
              _buildTimerIndicator(context),
              const SizedBox(height: 12),
            ],

            // 선택지 버튼들
            ...widget.choiceSet.choices.asMap().entries.map((entry) {
              final index = entry.key;
              final choice = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < widget.choiceSet.choices.length - 1 ? 8 : 0,
                ),
                child: _buildChoiceButton(context, choice),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerIndicator(BuildContext context) {
    final progress = _remainingSeconds / widget.choiceSet.timeoutSeconds!;
    final isUrgent = _remainingSeconds <= 3;

    return Row(
      children: [
        Icon(
          Icons.timer,
          size: 16,
          color: isUrgent ? Colors.red : Colors.grey[500],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? Colors.red : widget.character.accentColor,
              ),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$_remainingSeconds초',
          style: context.labelMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isUrgent ? Colors.red : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(BuildContext context, CharacterChoice choice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 선택지 타입에 따른 색상
    Color buttonColor;
    Color textColor;

    switch (choice.type) {
      case ChoiceType.positive:
        buttonColor = widget.character.accentColor;
        textColor = DSColors.accent;
      case ChoiceType.negative:
        buttonColor = isDark ? DSColors.surfaceDark : Colors.grey[200]!;
        textColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
      case ChoiceType.bold:
        buttonColor = Colors.red[400]!;
        textColor = DSColors.accent;
      case ChoiceType.shy:
        buttonColor = Colors.pink[100]!;
        textColor = Colors.pink[800]!;
      case ChoiceType.neutral:
        buttonColor = isDark ? DSColors.surfaceDark : DSColors.accent;
        textColor = isDark ? DSColors.accent : DSColors.textPrimaryDark;
    }

    return AnimatedOpacity(
      opacity: _isSelected ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(12),
        elevation: _isSelected ? 0 : 2,
        child: InkWell(
          onTap: _isSelected ? null : () => _selectChoice(choice),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                // 이모지
                Text(
                  choice.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 12),
                // 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.text,
                        style: context.bodyMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (choice.hint != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          choice.hint!,
                          style: context.labelMedium.copyWith(
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 호감도 변화 표시
                if (choice.affinityChange != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: choice.affinityChange > 0
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      choice.affinityChange > 0
                          ? '+${choice.affinityChange}'
                          : '${choice.affinityChange}',
                      style: context.labelMedium.copyWith(
                        color: choice.affinityChange > 0
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
