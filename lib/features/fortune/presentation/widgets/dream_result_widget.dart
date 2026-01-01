import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/widgets/gpt_style_typing_text.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';

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
    // 총 메시지 개수 (9개 섹션: 기존 6 + 키워드/확언/감정)
    final totalMessages = 9;

    for (int i = 0; i < totalMessages; i++) {
      _visibleMessages.add(false);
    }

    // 순차적으로 메시지 표시
    _showNextMessage();
  }

  void _showNextMessage() {
    if (_currentMessageIndex < _visibleMessages.length) {
      Future.delayed(
          Duration(milliseconds: _currentMessageIndex == 0 ? 300 : 800), () {
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

    Logger.debug('[DreamResult] 🎨 Building ChatGPT-style widget');
    Logger.debug('[DreamResult]   - isBlurred: ${widget.isBlurred}');
    Logger.debug('[DreamResult]   - data keys: ${data.keys.toList()}');

    // 데이터 추출

    final interpretation = data['interpretation'] as String? ?? '';
    final mainTheme =
        (data['analysis'] as Map<String, dynamic>?)?['mainTheme'] as String? ??
            '';
    final psychologicalInsight = (data['analysis']
            as Map<String, dynamic>?)?['psychologicalInsight'] as String? ??
        '';
    final todayGuidance = data['todayGuidance'] as String? ?? '';
    final symbolAnalysis = (data['analysis']
            as Map<String, dynamic>?)?['symbolAnalysis'] as List<dynamic>? ??
        [];
    final actionAdvice = data['actionAdvice'] as List<dynamic>? ?? [];

    // 추가 필드들
    final luckyKeywords = data['luckyKeywords'] as List<dynamic>? ?? [];
    final avoidKeywords = data['avoidKeywords'] as List<dynamic>? ?? [];
    final affirmations = data['affirmations'] as List<dynamic>? ?? [];
    final emotionalBalance = data['emotionalBalance'] as num? ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. 꿈의 주제
        if (_visibleMessages.isNotEmpty && _visibleMessages[0])
          _buildBotMessage(
            isDark: isDark,
            title: '꿈의 주제',
            content: mainTheme.isNotEmpty ? mainTheme : '분석 중...',
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 1. 기본 해몽
        if (_visibleMessages.length > 1 && _visibleMessages[1])
          _buildBotMessage(
            isDark: isDark,
            title: '기본 해몽',
            content:
                interpretation.isNotEmpty ? interpretation : '꿈의 메시지를 해석하였습니다.',
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 2. 심리 분석 (블러)
        if (_visibleMessages.length > 2 && _visibleMessages[2])
          _buildBotMessage(
            isDark: isDark,
            title: '심리 분석',
            content: psychologicalInsight.isNotEmpty
                ? psychologicalInsight
                : '분석 중...',
            isBlurred: widget.isBlurred &&
                widget.blurredSections.contains('psychologicalInsight'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 3. 오늘의 조언 (블러)
        if (_visibleMessages.length > 3 && _visibleMessages[3])
          _buildBotMessage(
            isDark: isDark,
            title: '오늘의 조언',
            content:
                todayGuidance.isNotEmpty ? todayGuidance : '오늘 하루를 긍정적으로 보내세요.',
            isBlurred: widget.isBlurred &&
                widget.blurredSections.contains('todayGuidance'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 4. 상징 분석 (블러)
        if (_visibleMessages.length > 4 &&
            _visibleMessages[4] &&
            symbolAnalysis.isNotEmpty)
          _buildSymbolMessage(
            isDark: isDark,
            symbolAnalysis: symbolAnalysis,
            isBlurred: widget.isBlurred &&
                widget.blurredSections.contains('symbolAnalysis'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        if (symbolAnalysis.isNotEmpty) const SizedBox(height: 12),

        // 5. 행동 조언 (블러)
        if (_visibleMessages.length > 5 &&
            _visibleMessages[5] &&
            actionAdvice.isNotEmpty)
          _buildActionMessage(
            isDark: isDark,
            actionAdvice: actionAdvice,
            isBlurred: widget.isBlurred &&
                widget.blurredSections.contains('actionAdvice'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        if (actionAdvice.isNotEmpty) const SizedBox(height: 12),

        // 6. 감정 균형 점수
        if (_visibleMessages.length > 6 && _visibleMessages[6])
          _buildEmotionalBalanceMessage(
            isDark: isDark,
            emotionalBalance: emotionalBalance.toInt(),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 12),

        // 7. 행운/주의 키워드
        if (_visibleMessages.length > 7 &&
            _visibleMessages[7] &&
            (luckyKeywords.isNotEmpty || avoidKeywords.isNotEmpty))
          _buildKeywordsMessage(
            isDark: isDark,
            luckyKeywords: luckyKeywords,
            avoidKeywords: avoidKeywords,
            isBlurred: widget.isBlurred &&
                widget.blurredSections.contains('keywords'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        if (luckyKeywords.isNotEmpty || avoidKeywords.isNotEmpty)
          const SizedBox(height: 12),

        // 8. 긍정 확언
        if (_visibleMessages.length > 8 &&
            _visibleMessages[8] &&
            affirmations.isNotEmpty)
          _buildAffirmationsMessage(
            isDark: isDark,
            affirmations: affirmations,
            isBlurred: widget.isBlurred &&
                widget.blurredSections.contains('affirmations'),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),

        const SizedBox(height: 100), // 버튼 여유 공간
      ],
    );
  }

  /// 봇 메시지 버블 (왼쪽 정렬)
  Widget _buildBotMessage({
    required bool isDark,
    required String content,
    String? title,
    bool isBlurred = false,
    bool startTyping = true,
    VoidCallback? onTypingComplete,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
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
                      style: context.heading3.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  GptStyleTypingText(
                    text: content,
                    style: context.bodyMedium.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.87)
                          : Colors.black.withValues(alpha: 0.87),
                      height: 1.6,
                    ),
                    startTyping: startTyping,
                    showGhostText: true,
                    onComplete: onTypingComplete,
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
              '상징 분석',
              style: context.heading3.copyWith(
                color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (isBlurred)
              UnifiedBlurWrapper(
                isBlurred: true,
                blurredSections: const ['symbolAnalysis'],
                sectionKey: 'symbolAnalysis',
                fortuneType: widget.fortuneResult.type,
                child: Text(
                  symbolAnalysis
                      .map((s) => '${s['symbol']}: ${s['meaning']}')
                      .join('\n'),
                  style: context.bodyMedium.copyWith(color: Colors.grey),
                ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DSColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          symbolName,
                          style: context.bodySmall.copyWith(
                            color: DSColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          meaning,
                          style: context.bodyMedium.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.87),
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
              '행동 조언',
              style: context.heading3.copyWith(
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
                      style: context.bodyMedium.copyWith(color: Colors.grey),
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
                          color: DSColors.accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: context.bodySmall.copyWith(
                              color: DSColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          advice,
                          style: context.bodyMedium.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.black.withValues(alpha: 0.87),
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
    );
  }

  /// 블러 처리된 콘텐츠 (제목 제외, 내용만 블러)
  Widget _buildBlurredContent({
    required String content,
    String? title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 제목에 따른 색상 결정
    Color getTitleColor() {
      if (title == null) return DSColors.accent;
      if (title.contains('심리'))
        return isDark ? Colors.purple.shade300 : Colors.purple;
      if (title.contains('조언'))
        return isDark ? Colors.orange.shade300 : Colors.orange;
      return isDark ? Colors.white : Colors.black;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목은 블러 없이 표시
        if (title != null) ...[
          Text(
            title,
            style: context.heading3.copyWith(
              color: getTitleColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        UnifiedBlurWrapper(
          isBlurred: true,
          blurredSections: const ['bot'],
          sectionKey: 'bot',
          fortuneType: widget.fortuneResult.type,
          child: Text(
            content,
            style: context.bodyMedium.copyWith(
              color: Colors.grey,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  /// 감정 균형 점수 메시지
  Widget _buildEmotionalBalanceMessage({
    required bool isDark,
    required int emotionalBalance,
  }) {
    // 1-10 점수를 색상과 이모지로 변환
    final Color balanceColor;
    final String emoji;
    final String description;

    if (emotionalBalance >= 8) {
      balanceColor = DSColors.success;
      emoji = '😊';
      description = '매우 긍정적인 에너지가 충만해요';
    } else if (emotionalBalance >= 6) {
      balanceColor = Colors.lightGreen;
      emoji = '🙂';
      description = '안정적이고 균형잡힌 상태예요';
    } else if (emotionalBalance >= 4) {
      balanceColor = DSColors.warning;
      emoji = '😐';
      description = '평온하지만 약간의 변화가 필요해요';
    } else if (emotionalBalance >= 2) {
      balanceColor = Colors.orange;
      emoji = '😔';
      description = '마음의 휴식이 필요한 시기예요';
    } else {
      balanceColor = DSColors.error;
      emoji = '😰';
      description = '스트레스 관리에 신경 쓰세요';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
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
            Text(
              '감정 균형',
              style: context.heading3.copyWith(
                color: isDark ? Colors.teal.shade300 : Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$emotionalBalance',
                            style: context.heading2.copyWith(
                              color: balanceColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' / 10',
                            style: context.bodySmall.copyWith(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: emotionalBalance / 10,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(balanceColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: context.bodySmall.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 행운/주의 키워드 메시지
  Widget _buildKeywordsMessage({
    required bool isDark,
    required List<dynamic> luckyKeywords,
    required List<dynamic> avoidKeywords,
    required bool isBlurred,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
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
            Text(
              '오늘의 키워드',
              style: context.heading3.copyWith(
                color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (isBlurred)
              UnifiedBlurWrapper(
                isBlurred: true,
                blurredSections: const ['keywords'],
                sectionKey: 'keywords',
                fortuneType: widget.fortuneResult.type,
                child: Text(
                  '${luckyKeywords.join(', ')}\n${avoidKeywords.join(', ')}',
                  style: context.bodyMedium.copyWith(color: Colors.grey),
                ),
              )
            else ...[
              if (luckyKeywords.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.thumb_up, size: 16, color: DSColors.success),
                    const SizedBox(width: 6),
                    Text(
                      '행운 키워드',
                      style: context.labelMedium.copyWith(
                        color: DSColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: luckyKeywords.map((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DSColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: DSColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        keyword.toString(),
                        style: context.bodySmall.copyWith(
                          color: DSColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (avoidKeywords.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.warning_amber, size: 16, color: DSColors.error),
                    const SizedBox(width: 6),
                    Text(
                      '주의 키워드',
                      style: context.labelMedium.copyWith(
                        color: DSColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: avoidKeywords.map((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DSColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: DSColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        keyword.toString(),
                        style: context.bodySmall.copyWith(
                          color: DSColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// 긍정 확언 메시지
  Widget _buildAffirmationsMessage({
    required bool isDark,
    required List<dynamic> affirmations,
    required bool isBlurred,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                : [Colors.deepPurple.shade50, Colors.indigo.shade50],
          ),
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
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '오늘의 확언',
                  style: context.heading3.copyWith(
                    color: isDark ? Colors.white : Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isBlurred)
              UnifiedBlurWrapper(
                isBlurred: true,
                blurredSections: const ['affirmations'],
                sectionKey: 'affirmations',
                fortuneType: widget.fortuneResult.type,
                child: Text(
                  affirmations.join('\n'),
                  style: context.bodyMedium.copyWith(color: Colors.grey),
                ),
              )
            else
              ...affirmations.asMap().entries.map((entry) {
                final affirmation = entry.value.toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          affirmation,
                          style: context.bodyMedium.copyWith(
                            color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.deepPurple.shade700,
                            fontStyle: FontStyle.italic,
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
    );
  }
}
