import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// GPT/Claude 스타일의 타이핑 효과 위젯
///
/// Features:
/// - 한 글자씩 타이핑 효과
/// - Ghost text (희미한 전체 텍스트 미리보기)
/// - 깜빡이는 커서
/// - 랜덤 속도 (자연스러운 타이핑 느낌)
class GptStyleTypingText extends StatefulWidget {
  /// 표시할 텍스트
  final String text;

  /// 텍스트 스타일
  final TextStyle? style;

  /// Ghost text 표시 여부 (희미한 전체 텍스트)
  final bool showGhostText;

  /// 커서 표시 여부
  final bool showCursor;

  /// 타이핑 시작 여부 (false면 대기)
  final bool startTyping;

  /// 타이핑 완료 콜백
  final VoidCallback? onComplete;

  /// 최소 딜레이 (ms) - 빠른 타이핑 효과
  final int minDelay;

  /// 최대 딜레이 (ms) - 빠른 타이핑 효과
  final int maxDelay;

  const GptStyleTypingText({
    super.key,
    required this.text,
    this.style,
    this.showGhostText = true,
    this.showCursor = true,
    this.startTyping = true,
    this.onComplete,
    this.minDelay = 10,
    this.maxDelay = 25,
  });

  @override
  State<GptStyleTypingText> createState() => _GptStyleTypingTextState();
}

class _GptStyleTypingTextState extends State<GptStyleTypingText>
    with SingleTickerProviderStateMixin {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _typingTimer;
  bool _isComplete = false;
  bool _hasStarted = false;

  /// Grapheme clusters for proper Unicode handling (emoji, Korean, etc.)
  late List<String> _graphemes;

  // 커서 깜빡임 애니메이션
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();

    // UTF-16 안전한 grapheme cluster 분리
    _graphemes = widget.text.characters.toList();

    // 커서 깜빡임 설정
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);

    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_cursorController);

    if (widget.startTyping) {
      _startTyping();
    }
  }

  @override
  void didUpdateWidget(covariant GptStyleTypingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // startTyping이 true로 변경되면 타이핑 시작
    if (widget.startTyping && !oldWidget.startTyping && !_hasStarted) {
      _startTyping();
    }

    // 텍스트가 변경되면 리셋
    if (widget.text != oldWidget.text) {
      _graphemes = widget.text.characters.toList();
      _reset();
      if (widget.startTyping) {
        _startTyping();
      }
    }
  }

  void _reset() {
    _typingTimer?.cancel();
    _displayedText = '';
    _currentIndex = 0;
    _isComplete = false;
    _hasStarted = false;
  }

  void _startTyping() {
    if (_hasStarted) return;

    _hasStarted = true;

    // 빈 텍스트면 즉시 완료 처리 (커서 깜빡임 방지)
    if (widget.text.isEmpty) {
      _onTypingComplete();
      return;
    }

    _scheduleNextCharacter();
  }

  void _scheduleNextCharacter() {
    // grapheme cluster 단위로 길이 체크 (UTF-16 안전)
    if (_currentIndex >= _graphemes.length) {
      _onTypingComplete();
      return;
    }

    // 랜덤 딜레이 (40~80ms)
    final delay = Random().nextInt(widget.maxDelay - widget.minDelay) + widget.minDelay;

    _typingTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;

      setState(() {
        // grapheme cluster 단위로 추가 (이모지, 한글 완성형 등 안전 처리)
        _displayedText += _graphemes[_currentIndex];
        _currentIndex++;
      });

      _scheduleNextCharacter();
    });
  }

  void _onTypingComplete() {
    if (_isComplete) return;

    setState(() {
      _isComplete = true;
    });

    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final textColor = effectiveStyle.color ?? Colors.black;

    return Stack(
      children: [
        // Ghost text (희미한 전체 텍스트)
        if (widget.showGhostText && !_isComplete)
          Text(
            widget.text,
            style: effectiveStyle.copyWith(
              color: textColor.withValues(alpha: 0.15),
            ),
          ),

        // 타이핑된 텍스트 + 커서
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                _displayedText,
                style: effectiveStyle,
              ),
            ),
            // 깜빡이는 커서
            if (widget.showCursor && !_isComplete)
              AnimatedBuilder(
                animation: _cursorAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cursorAnimation.value,
                    child: Text(
                      '▍',
                      style: effectiveStyle.copyWith(
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// 여러 문단을 순차적으로 타이핑하는 위젯
class GptStyleTypingParagraphs extends StatefulWidget {
  /// 문단 리스트
  final List<String> paragraphs;

  /// 텍스트 스타일
  final TextStyle? style;

  /// 문단 간 간격
  final double paragraphSpacing;

  /// Ghost text 표시 여부
  final bool showGhostText;

  /// 커서 표시 여부
  final bool showCursor;

  /// 타이핑 시작 여부
  final bool startTyping;

  /// 모든 타이핑 완료 콜백
  final VoidCallback? onComplete;

  const GptStyleTypingParagraphs({
    super.key,
    required this.paragraphs,
    this.style,
    this.paragraphSpacing = 16.0,
    this.showGhostText = true,
    this.showCursor = true,
    this.startTyping = true,
    this.onComplete,
  });

  @override
  State<GptStyleTypingParagraphs> createState() => _GptStyleTypingParagraphsState();
}

class _GptStyleTypingParagraphsState extends State<GptStyleTypingParagraphs> {
  int _currentParagraph = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.paragraphs.asMap().entries.map((entry) {
        final index = entry.key;
        final paragraph = entry.value;
        final isLastParagraph = index == widget.paragraphs.length - 1;

        return Padding(
          padding: EdgeInsets.only(
            bottom: isLastParagraph ? 0 : widget.paragraphSpacing,
          ),
          child: GptStyleTypingText(
            text: paragraph,
            style: widget.style,
            showGhostText: widget.showGhostText,
            showCursor: widget.showCursor && index == _currentParagraph,
            startTyping: widget.startTyping && index <= _currentParagraph,
            onComplete: () {
              if (index < widget.paragraphs.length - 1) {
                setState(() {
                  _currentParagraph = index + 1;
                });
              } else {
                widget.onComplete?.call();
              }
            },
          ),
        );
      }).toList(),
    );
  }
}

/// API 대기 중 커서만 깜빡이는 로딩 인디케이터
///
/// 버튼 로딩 애니메이션 대신 사용하여
/// 결과 화면에서 GPT 스타일의 대기 상태를 표시합니다.
class TypingLoadingIndicator extends StatefulWidget {
  /// 텍스트 스타일 (커서 색상 결정)
  final TextStyle? style;

  /// 로딩 안내 문구 (예: "운세를 불러오는 중...")
  final String? loadingText;

  /// 로딩 문구 스타일
  final TextStyle? loadingTextStyle;

  const TypingLoadingIndicator({
    super.key,
    this.style,
    this.loadingText,
    this.loadingTextStyle,
  });

  @override
  State<TypingLoadingIndicator> createState() => _TypingLoadingIndicatorState();
}

class _TypingLoadingIndicatorState extends State<TypingLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);

    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_cursorController);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final textColor = effectiveStyle.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 로딩 안내 문구 (있을 경우)
        if (widget.loadingText != null && widget.loadingText!.isNotEmpty) ...[
          Text(
            widget.loadingText!,
            style: widget.loadingTextStyle ?? effectiveStyle.copyWith(
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
        ],
        // 깜빡이는 커서
        AnimatedBuilder(
          animation: _cursorAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _cursorAnimation.value,
              child: Text(
                '▍',
                style: effectiveStyle.copyWith(
                  color: textColor,
                  fontSize: (effectiveStyle.fontSize ?? 16) * 1.2,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
