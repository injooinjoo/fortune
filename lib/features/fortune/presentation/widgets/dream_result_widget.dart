import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/models/fortune_result.dart';

/// ChatGPT 스타일 대화형 꿈 해몽 결과 위젯
class DreamResultWidget extends StatefulWidget {
  final FortuneResult fortuneResult;
  final bool isBlurred;
  final List<String> blurredSections;

  const DreamResultWidget({
    super.key,
    required this.fortuneResult,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  State<DreamResultWidget> createState() => _DreamResultWidgetState();
}

class _DreamResultWidgetState extends State<DreamResultWidget> {
  final List<bool> _visibleMessages = [];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _startMessageAnimation();
  }

  void _startMessageAnimation() {
    // 총 메시지 개수 (제목 + 6개 섹션)
    final totalMessages = 7;

    for (int i = 0; i < totalMessages; i++) {
      _visibleMessages.add(false);
    }

    // 순차적으로 메시지 표시
    _showNextMessage();
  }

  void _showNextMessage() {
    if (_currentMessageIndex < _visibleMessages.length) {
      Future.delayed(Duration(milliseconds: _currentMessageIndex == 0 ? 300 : 800), () {
        if (mounted) {
          setState(() {
            _visibleMessages[_currentMessageIndex] = true;
            _currentMessageIndex++;
          });
          _showNextMessage();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = widget.fortuneResult.data;

    print('[DreamResult] 🎨 Building ChatGPT-style widget');
    print('[DreamResult]   - isBlurred: ${widget.isBlurred}');
    print('[DreamResult]   - data keys: ${data.keys.toList()}');

    // 데이터 추출
    final dream = data['dream'] as String? ?? '';
    final interpretation = data['interpretation'] as String? ?? '';
    final mainTheme = (data['analysis'] as Map<String, dynamic>?)?['mainTheme'] as String? ?? '';
    final psychologicalInsight = (data['analysis'] as Map<String, dynamic>?)?['psychologicalInsight'] as String? ?? '';
    final todayGuidance = data['todayGuidance'] as String? ?? '';
    final symbolAnalysis = (data['analysis'] as Map<String, dynamic>?)?['symbolAnalysis'] as List<dynamic>? ?? [];
    final actionAdvice = data['actionAdvice'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. 제목 메시지
        if (_visibleMessages.isNotEmpty && _visibleMessages[0])
          _buildBotMessage(
            isDark: isDark,
            content: '🌙 당신의 꿈 해몽',
            icon: '🌙',
            isTitle: true,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 16),

        // 1. 꿈의 주제
        if (_visibleMessages.length > 1 && _visibleMessages[1])
          _buildBotMessage(
            isDark: isDark,
            title: '🎯 꿈의 주제',
            content: mainTheme.isNotEmpty ? mainTheme : '분석 중...',
            icon: '🎯',
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 2. 기본 해몽
        if (_visibleMessages.length > 2 && _visibleMessages[2])
          _buildBotMessage(
            isDark: isDark,
            title: '📖 기본 해몽',
            content: interpretation.isNotEmpty ? interpretation : '꿈의 메시지를 해석하였습니다.',
            icon: '📖',
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 3. 심리 분석 (블러)
        if (_visibleMessages.length > 3 && _visibleMessages[3])
          _buildBotMessage(
            isDark: isDark,
            title: '🧠 심리 분석',
            content: psychologicalInsight.isNotEmpty ? psychologicalInsight : '분석 중...',
            icon: '🧠',
            isBlurred: widget.isBlurred && widget.blurredSections.contains('psychologicalInsight'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 4. 오늘의 조언 (블러)
        if (_visibleMessages.length > 4 && _visibleMessages[4])
          _buildBotMessage(
            isDark: isDark,
            title: '💡 오늘의 조언',
            content: todayGuidance.isNotEmpty ? todayGuidance : '오늘 하루를 긍정적으로 보내세요.',
            icon: '💡',
            isBlurred: widget.isBlurred && widget.blurredSections.contains('todayGuidance'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 5. 상징 분석 (블러)
        if (_visibleMessages.length > 5 && _visibleMessages[5] && symbolAnalysis.isNotEmpty)
          _buildSymbolMessage(
            isDark: isDark,
            symbolAnalysis: symbolAnalysis,
            isBlurred: widget.isBlurred && widget.blurredSections.contains('symbolAnalysis'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        if (symbolAnalysis.isNotEmpty) const SizedBox(height: 12),

        // 6. 행동 조언 (블러)
        if (_visibleMessages.length > 6 && _visibleMessages[6] && actionAdvice.isNotEmpty)
          _buildActionMessage(
            isDark: isDark,
            actionAdvice: actionAdvice,
            isBlurred: widget.isBlurred && widget.blurredSections.contains('actionAdvice'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 100), // 버튼 여유 공간
      ],
    );
  }

  /// 봇 메시지 버블 (왼쪽 정렬)
  Widget _buildBotMessage({
    required bool isDark,
    required String content,
    required String icon,
    String? title,
    bool isTitle = false,
    bool isBlurred = false,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 메시지 버블
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: isBlurred
                    ? _buildBlurredContent(content: content, title: title)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) ...[
                            Text(
                              title,
                              style: TypographyUnified.heading4.copyWith(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            content,
                            style: (isTitle ? TypographyUnified.heading2 : TypographyUnified.bodyMedium).copyWith(
                              color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black.withValues(alpha: 0.87),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상징 분석 메시지
  Widget _buildSymbolMessage({
    required bool isDark,
    required List<dynamic> symbolAnalysis,
    required bool isBlurred,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔮', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            // 메시지 버블
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목은 항상 표시
                    Text(
                      '🔮 상징 분석',
                      style: TypographyUnified.heading4.copyWith(
                        color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isBlurred)
                      // 내용만 블러 처리
                      Stack(
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Text(
                              symbolAnalysis.map((s) => '${s['symbol']}: ${s['meaning']}').join('\n'),
                              style: TypographyUnified.bodyMedium.copyWith(color: Colors.grey),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Icon(
                                Icons.lock_outline,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      ...symbolAnalysis.map((symbol) {
                        final symbolName = symbol['symbol'] as String? ?? '';
                        final meaning = symbol['meaning'] as String? ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  symbolName,
                                  style: TypographyUnified.bodySmall.copyWith(
                                    color: TossDesignSystem.tossBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  meaning,
                                  style: TypographyUnified.bodyMedium.copyWith(
                                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.87),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 행동 조언 메시지
  Widget _buildActionMessage({
    required bool isDark,
    required List<dynamic> actionAdvice,
    required bool isBlurred,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            // 메시지 버블
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목은 항상 표시
                    Text(
                      '✨ 행동 조언',
                      style: TypographyUnified.heading4.copyWith(
                        color: isDark ? Colors.pink.shade300 : Colors.pink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isBlurred)
                      // 내용만 블러 처리
                      Stack(
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Text(
                              actionAdvice.join('\n'),
                              style: TypographyUnified.bodyMedium.copyWith(color: Colors.grey),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Icon(
                                Icons.lock_outline,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      ...actionAdvice.asMap().entries.map((entry) {
                        final index = entry.key;
                        final advice = entry.value as String;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TypographyUnified.bodySmall.copyWith(
                                      color: TossDesignSystem.tossBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  advice,
                                  style: TypographyUnified.bodyMedium.copyWith(
                                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.87),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 블러 처리된 콘텐츠 (제목 제외, 내용만 블러)
  Widget _buildBlurredContent({
    required String content,
    String? title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목은 블러 없이 표시
        if (title != null) ...[
          Text(
            title,
            style: TypographyUnified.heading4.copyWith(
              color: title.startsWith('🧠') ? (isDark ? Colors.purple.shade300 : Colors.purple) :
                     title.startsWith('💡') ? (isDark ? Colors.orange.shade300 : Colors.orange) :
                     title.startsWith('🔮') ? (isDark ? Colors.indigo.shade300 : Colors.indigo) :
                     title.startsWith('✨') ? (isDark ? Colors.pink.shade300 : Colors.pink) :
                     TossDesignSystem.tossBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        // 내용만 블러 처리
        Stack(
          children: [
            // 블러된 텍스트
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Text(
                content,
                style: TypographyUnified.bodyMedium.copyWith(
                  color: Colors.grey,
                  height: 1.6,
                ),
              ),
            ),
            // 반투명 오버레이
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // 잠금 아이콘
            Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
