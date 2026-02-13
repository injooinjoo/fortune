import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/widgets/infographic/headers/saju_info_header.dart';
import '../../../fortune/presentation/widgets/saju/saju_widgets.dart';
import '../../../fortune/presentation/widgets/saju_element_chart.dart';

/// 채팅용 사주 분석 결과 카드
///
/// 7개 Expandable 섹션으로 사주 분석 결과를 표시합니다.
/// - 명식: 사주팔자 테이블 (기본 펼침)
/// - 오행: 오행 균형 차트
/// - 지장간: 지장간 분석
/// - 12운성: 12운성 분석
/// - 신살: 신살 길흉
/// - 합충: 합충형파해 관계
/// - 질문: LLM 운세 응답 (선택적)
class ChatSajuResultCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> sajuData;
  final Map<String, dynamic>? fortuneResult;

  const ChatSajuResultCard({
    super.key,
    required this.sajuData,
    this.fortuneResult,
  });

  @override
  ConsumerState<ChatSajuResultCard> createState() => _ChatSajuResultCardState();
}

class _ChatSajuResultCardState extends ConsumerState<ChatSajuResultCard>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러 (오행 차트용)
  late AnimationController _animationController;

  // 섹션별 확장 상태
  final Map<String, bool> _expandedSections = {
    'myungsik': true, // 명식만 기본 펼침
    'ohang': false,
    'jijanggan': false,
    'twelveStar': false,
    'sinsal': false,
    'hapchung': false,
    'question': false,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatSajuResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  /// 오행 균형 데이터 추출
  Map<String, dynamic> get _elementBalance {
    final elements = widget.sajuData['elements'] as Map<String, dynamic>?;
    final balance = widget.sajuData['elementBalance'] as Map<String, dynamic>?;

    return {
      '목': elements?['목'] ?? balance?['목'] ?? 0,
      '화': elements?['화'] ?? balance?['화'] ?? 0,
      '토': elements?['토'] ?? balance?['토'] ?? 0,
      '금': elements?['금'] ?? balance?['금'] ?? 0,
      '수': elements?['수'] ?? balance?['수'] ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        vertical: DSSpacing.sm,
        horizontal: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인포그래픽 헤더 (Hero + 오행 밸런스 통합)
          _buildInfoHeader(context),
          // 섹션들
          _buildSections(context),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    final colors = context.colors;
    final data = widget.sajuData;

    // 사주 팔자 데이터 추출
    Map<String, dynamic>? pillars;
    final myungsik = data['myungsik'] as Map<String, dynamic>?;
    if (myungsik != null) {
      pillars = {
        'year': {'sky': myungsik['yearSky'], 'earth': myungsik['yearEarth']},
        'month': {'sky': myungsik['monthSky'], 'earth': myungsik['monthEarth']},
        'day': {'sky': myungsik['daySky'], 'earth': myungsik['dayEarth']},
        'hour': {'sky': myungsik['hourSky'], 'earth': myungsik['hourEarth']},
      };
    }

    // 강/약 오행 찾기
    String? strongElement;
    String? weakElement;
    final balance = _elementBalance;
    if (balance.isNotEmpty) {
      final sorted = balance.entries.toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));
      if (sorted.isNotEmpty) strongElement = sorted.first.key;
      if (sorted.length > 1) weakElement = sorted.last.key;
    }

    return Stack(
      children: [
        // 인포그래픽 헤더
        SajuInfoHeader(
          birthDate: data['birthDate'] as String?,
          birthTime: data['birthTime'] as String?,
          pillars: pillars,
          elements: balance.isNotEmpty ? balance : null,
          strongElement: strongElement,
          weakElement: weakElement,
          advice: widget.fortuneResult?['advice'] as String?,
        ),
        // 액션 버튼 오버레이
        Positioned(
          top: DSSpacing.sm,
          right: DSSpacing.sm,
          child: Row(
            children: [
              FortuneActionButtons(
                contentId: widget.sajuData['id']?.toString() ??
                    'saju_${DateTime.now().millisecondsSinceEpoch}',
                contentType: 'saju',
                fortuneType: 'traditional',
                shareTitle: '사주 분석 결과',
                shareContent: '나의 사주팔자 분석 결과입니다.',
                iconSize: 20,
                iconColor: colors.textSecondary,
              ),
              IconButton(
                onPressed: _toggleAllSections,
                icon: Icon(
                  _areAllExpanded ? Icons.unfold_less : Icons.unfold_more,
                  color: colors.textSecondary,
                ),
                tooltip: _areAllExpanded ? '모두 접기' : '모두 펼치기',
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _areAllExpanded => _expandedSections.values.every((v) => v);

  void _toggleAllSections() {
    setState(() {
      final newValue = !_areAllExpanded;
      for (final key in _expandedSections.keys) {
        _expandedSections[key] = newValue;
      }
    });
  }

  Widget _buildSections(BuildContext context) {
    return Column(
      children: [
        // 1. 명식
        _buildExpandableSection(
          context,
          key: 'myungsik',
          title: '명식',
          subtitle: '四柱命式',
          icon: Icons.grid_view_rounded,
          child: SajuPillarTablePro(
            sajuData: widget.sajuData,
            showTitle: false,
          ),
        ),

        // 2. 오행
        _buildExpandableSection(
          context,
          key: 'ohang',
          title: '오행',
          subtitle: '五行均衡',
          icon: Icons.donut_large_outlined,
          child: SajuElementChart(
            elementBalance: _elementBalance,
            animationController: _animationController,
          ),
        ),

        // 3. 지장간
        _buildExpandableSection(
          context,
          key: 'jijanggan',
          title: '지장간',
          subtitle: '支藏干',
          icon: Icons.layers_outlined,
          child: SajuJijangganWidget(
            sajuData: widget.sajuData,
            showTitle: false,
          ),
        ),

        // 4. 12운성
        _buildExpandableSection(
          context,
          key: 'twelveStar',
          title: '12운성',
          subtitle: '十二運星',
          icon: Icons.star_outline_rounded,
          child: SajuTwelveStagesWidget(
            sajuData: widget.sajuData,
            showTitle: false,
          ),
        ),

        // 5. 신살
        _buildExpandableSection(
          context,
          key: 'sinsal',
          title: '신살',
          subtitle: '神殺',
          icon: Icons.flash_on_outlined,
          child: SajuSinsalWidget(
            sajuData: widget.sajuData,
            showTitle: false,
          ),
        ),

        // 6. 합충
        _buildExpandableSection(
          context,
          key: 'hapchung',
          title: '합충',
          subtitle: '合沖刑破害',
          icon: Icons.compare_arrows_rounded,
          child: SajuHapchungWidget(
            sajuData: widget.sajuData,
            showTitle: false,
          ),
        ),

        // 7. 질문 응답 (있을 경우만)
        if (widget.fortuneResult != null)
          _buildExpandableSection(
            context,
            key: 'question',
            title: '운세 질문',
            subtitle: '詢問',
            icon: Icons.question_answer_outlined,
            child: _buildFortuneResultContent(context),
          ),
      ],
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final colors = context.colors;
    final isExpanded = _expandedSections[key] ?? false;

    return Column(
      children: [
        // 섹션 헤더 (탭 가능)
        InkWell(
          onTap: () {
            setState(() {
              _expandedSections[key] = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colors.accent,
                  size: 20,
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  title,
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                Text(
                  subtitle,
                  style: context.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 섹션 내용
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.all(DSSpacing.sm),
            child: child,
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildFortuneResultContent(BuildContext context) {
    final colors = context.colors;
    final result = widget.fortuneResult;

    if (result == null) return const SizedBox.shrink();

    final content = result['content'] as String? ?? '';
    final advice = result['advice'] as String?;
    final summary = result['summary'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary != null && summary.isNotEmpty) ...[
          Text(
            summary,
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
        ],
        Text(
          content,
          style: context.bodyMedium.copyWith(
            color: colors.textPrimary,
            height: 1.6,
          ),
        ),
        if (advice != null && advice.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.md),
          Container(
            padding: const EdgeInsets.all(DSSpacing.sm),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: colors.accent,
                  size: 18,
                ),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    advice,
                    style: context.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
