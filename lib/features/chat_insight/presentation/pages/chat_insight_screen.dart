import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/services/kakao_parser.dart';
import '../../domain/services/anonymizer.dart';
import '../../domain/services/feature_extractor.dart';
import '../../data/models/chat_insight_result.dart';
import '../widgets/paste_dialog.dart';
import '../widgets/quick_action_cards.dart';
import '../widgets/relation_context_card.dart';
import '../widgets/insight_card_widget.dart';
import '../widgets/timeline_card_widget.dart';
import '../widgets/pattern_card_widget.dart';
import '../widgets/trigger_card_widget.dart';
import '../widgets/guidance_card_widget.dart';
import '../widgets/privacy_bottom_sheet.dart';
import '../../data/storage/insight_storage.dart';

/// 대화 분석 인사이트의 분석 상태
enum _AnalysisState { idle, uploaded, configuring, analyzing, done, error }

/// 카톡 대화 분석 인사이트 메인 화면
class ChatInsightScreen extends ConsumerStatefulWidget {
  const ChatInsightScreen({super.key});

  @override
  ConsumerState<ChatInsightScreen> createState() => _ChatInsightScreenState();
}

class _ChatInsightScreenState extends ConsumerState<ChatInsightScreen> {
  _AnalysisState _state = _AnalysisState.idle;
  List<ParsedMessage>? _parsedMessages;
  ChatInsightResult? _result;
  String? _errorMessage;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          '대화 상담',
          style: typography.headingSmall.copyWith(color: colors.textPrimary),
        ),
        actions: [
          if (_state == _AnalysisState.done)
            IconButton(
              icon: Icon(Icons.refresh, color: colors.textSecondary),
              onPressed: _resetAnalysis,
              tooltip: '새 분석',
            ),
          IconButton(
            icon: Icon(Icons.lock_outline, color: colors.textSecondary),
            onPressed: () => PrivacyBottomSheet.show(context),
            tooltip: '프라이버시 설정',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _AnalysisState.idle:
        return _buildEmptyState(context);
      case _AnalysisState.uploaded:
      case _AnalysisState.configuring:
        return _buildConfiguringState(context);
      case _AnalysisState.analyzing:
        return _buildAnalyzingState(context);
      case _AnalysisState.done:
        return _buildResultState(context);
      case _AnalysisState.error:
        return _buildErrorState(context);
    }
  }

  // ── Empty State ──────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: DSSpacing.xl),
          // 시스템 안내 메시지 1
          const _SystemBubble(
            icon: Icons.chat_bubble_outline,
            text: '안녕하세요! 카카오톡 대화를 분석해서\n관계 인사이트를 알려드릴게요.',
          ),
          const SizedBox(height: DSSpacing.md),
          // 시스템 안내 메시지 2
          const _SystemBubble(
            icon: Icons.lock_outline,
            text: '대화 내용은 기기에서만 처리되고,\n서버로 전송되지 않아요.\n원문은 저장하지 않습니다.',
          ),
          const SizedBox(height: DSSpacing.md),
          // 시스템 안내 메시지 3
          const _SystemBubble(
            icon: Icons.lightbulb_outline,
            text: '연인, 친구, 가족 등 어떤 관계든\n분석할 수 있어요. 아래에서 시작해보세요!',
          ),
          const SizedBox(height: DSSpacing.xl),

          // Quick Action 카드
          QuickActionCards(
            onPasteTap: () => _showPasteDialog(context),
            onFileTap: _handleFileImport,
            onSampleTap: _handleSampleLoad,
          ),

          const SizedBox(height: DSSpacing.lg),

          // 프라이버시 배지
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DSRadius.full),
              border: Border.all(
                  color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, color: colors.textSecondary, size: 14),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  '로컬 분석 ON | 서버 OFF',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Configuring State ──────────────────────────────

  Widget _buildConfiguringState(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final messageCount = _parsedMessages?.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        children: [
          // 업로드 확인 버블
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Text(
                '카톡 대화 $messageCount줄 업로드 완료 ✓',
                style: typography.bodySmall.copyWith(color: colors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.lg),

          // 관계 설정 카드
          RelationContextCard(
            onConfigSubmit: (config) => _startAnalysis(config),
          ),
        ],
      ),
    );
  }

  // ── Analyzing State ──────────────────────────────

  Widget _buildAnalyzingState(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, color: colors.textSecondary, size: 48),
            const SizedBox(height: DSSpacing.lg),
            Text(
              '분석 중...',
              style:
                  typography.headingSmall.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: DSSpacing.md),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: colors.surface,
              valueColor: AlwaysStoppedAnimation(colors.textSecondary),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '${(_progress * 100).toInt()}%',
              style:
                  typography.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Result State ──────────────────────────────

  Widget _buildResultState(BuildContext context) {
    if (_result == null) return const SizedBox.shrink();
    final result = _result!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        children: [
          InsightCardWidget(
            scores: result.scores,
            highlights: result.highlights,
          ),
          const SizedBox(height: DSSpacing.sm),
          TimelineCardWidget(timeline: result.timeline),
          const SizedBox(height: DSSpacing.sm),
          PatternCardWidget(patterns: result.patterns),
          const SizedBox(height: DSSpacing.sm),
          TriggerCardWidget(triggers: result.triggers),
          const SizedBox(height: DSSpacing.sm),
          GuidanceCardWidget(guidance: result.guidance),
          const SizedBox(height: DSSpacing.xl),
        ],
      ),
    );
  }

  // ── Error State ──────────────────────────────

  Widget _buildErrorState(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 48),
            const SizedBox(height: DSSpacing.md),
            Text(
              _errorMessage ?? '분석 중 오류가 발생했어요',
              style:
                  typography.bodyMedium.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.lg),
            DSButton.primary(
              text: '다시 시도',
              onPressed: _resetAnalysis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────

  void _showPasteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PasteDialog(
        onSubmit: (text) {
          Navigator.pop(context);
          _handleParsedText(text);
        },
      ),
    );
  }

  void _handleParsedText(String text) {
    final result = KakaoParser.parse(text);

    if (result.error != null) {
      setState(() {
        _state = _AnalysisState.error;
        _errorMessage = result.errorMessage;
      });
      return;
    }

    setState(() {
      _parsedMessages = result.messages;
      _state = _AnalysisState.configuring;
    });
  }

  void _handleFileImport() {
    // TODO: Phase 4-2에서 file_picker 연동
    // 현재는 붙여넣기로 유도
    _showPasteDialog(context);
  }

  void _handleSampleLoad() {
    // 샘플 데이터로 분석 체험
    final sampleText = _generateSampleChat();
    _handleParsedText(sampleText);
  }

  Future<void> _startAnalysis(AnalysisConfig config) async {
    if (_parsedMessages == null || _parsedMessages!.isEmpty) return;

    setState(() {
      _state = _AnalysisState.analyzing;
      _progress = 0;
    });

    try {
      // Step 1: 익명화 (20%)
      await _updateProgress(0.2);
      final senders = _parsedMessages!.map((m) => m.sender).toSet().toList();
      final userSender = senders.first;
      final mapping =
          Anonymizer.createSenderMapping(senders, userSender);
      final anonymized =
          Anonymizer.anonymize(_parsedMessages!, mapping);

      // Step 2: 로컬 분석 (80%)
      await _updateProgress(0.5);
      final result = FeatureExtractor.analyze(anonymized, config);
      await _updateProgress(0.8);

      // Step 3: 완료 (100%)
      await _updateProgress(1.0);

      // 원문 즉시 폐기
      _parsedMessages = null;

      // 결과 로컬 저장
      await InsightStorage.save(result);

      setState(() {
        _result = result;
        _state = _AnalysisState.done;
      });
    } catch (e) {
      setState(() {
        _state = _AnalysisState.error;
        _errorMessage = '분석 중 오류가 발생했어요: $e';
      });
    }
  }

  Future<void> _updateProgress(double value) async {
    setState(() => _progress = value);
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  void _resetAnalysis() {
    setState(() {
      _state = _AnalysisState.idle;
      _parsedMessages = null;
      _result = null;
      _errorMessage = null;
      _progress = 0;
    });
  }

  String _generateSampleChat() {
    final lines = <String>[
      '--------------- 2026년 1월 4일 토요일 ---------------',
      '오후 2:30, A : 새해 복 많이 받아! 🎉',
      '오후 2:31, B : 고마워~ 너도! 올해 뭐 하고 싶어?',
      '오후 2:33, A : 여행 가고 싶다! 같이 갈래?',
      '오후 2:35, B : 좋아좋아! 어디로?',
      '오후 2:40, A : 제주도 어때? 맛집 투어하자',
      '오후 2:41, B : 완전 좋아!! 언제 갈까?',
      '오후 8:15, A : 오늘 뭐 했어?',
      '오후 8:20, B : 친구들이랑 밥 먹었어~ 너는?',
      '오후 8:22, A : 나도 가족이랑! 고기 먹었다 ㅎㅎ',
      '오후 8:23, B : 맛있겠다 😋',
      '--------------- 2026년 1월 11일 토요일 ---------------',
      '오후 1:00, A : 점심 먹었어?',
      '오후 1:30, B : 응 먹었어',
      '오후 3:00, A : 오늘 날씨 좋다! 산책 갈래?',
      '오후 4:15, B : 음 좀 피곤해서 집에 있을래',
      '오후 4:16, A : 알겠어~ 푹 쉬어!',
      '오후 9:00, A : 잘 자~',
      '오후 9:45, B : 응 잘 자',
      '--------------- 2026년 1월 18일 일요일 ---------------',
      '오전 10:00, A : 좋은 아침!',
      '오후 12:30, B : 응',
      '오후 3:00, A : 이번 주말에 뭐 해?',
      '오후 5:30, B : 음 좀 바빠',
      '오후 5:32, A : 그렇구나.. 다음에 보자',
      '오후 11:00, A : 잘 자!',
      '--------------- 2026년 1월 20일 화요일 ---------------',
      '오후 10:00, A : 오늘 힘들었어...',
      '오후 10:45, B : 그랬구나',
      '오후 10:47, A : 회사에서 프로젝트가 너무 힘들어',
      '오후 11:30, B : 힘내',
      '--------------- 2026년 1월 25일 토요일 ---------------',
      '오후 6:30, A : 이번 주말에 뭐 해?',
      '오후 7:00, B : 음 좀 바빠',
      '오후 7:01, A : 알겠어 ㅋ',
      '오후 9:00, A : 밥은 먹었어?',
      '오후 10:00, B : 응',
      '--------------- 2026년 2월 1일 토요일 ---------------',
      '오후 1:00, A : 주말 잘 보내고 있어?',
      '오후 3:00, B : 응',
      '오후 3:01, A : 요즘 좀 바쁜 것 같아',
      '오후 3:02, B : 응 좀 그래',
      '오후 3:05, A : 그래도 밥은 잘 챙겨먹어!',
      '오후 3:30, B : 고마워 너도',
      '오후 8:00, A : 내일 뭐 해?',
      '오후 9:00, B : 아직 모르겠어',
      '오후 9:01, A : 시간되면 같이 뭐 하자',
      '오후 9:30, B : 생각해볼게',
      '오후 10:00, A : 알겠어~ 잘 자!',
      '오후 10:30, B : 응 잘 자',
      '오후 10:31, A : 수고했어 오늘도',
      '오후 10:32, B : 고마워',
    ];
    return lines.join('\n');
  }
}

/// 시스템 안내 버블
class _SystemBubble extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SystemBubble({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.textSecondary, size: 20),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: typography.bodyMedium
                    .copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
