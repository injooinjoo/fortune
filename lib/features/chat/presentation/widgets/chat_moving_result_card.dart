import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/fortune_action_buttons.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/widgets/smart_image.dart';

/// 채팅용 이사운 결과 카드
///
/// Edge Function 응답 필드:
/// - score, overall_fortune, direction_analysis
/// - settlement_index: 정착 지수 (0-100)
/// - neighborhood_chemistry: 이웃 케미 (0-100)
/// - lucky_checklist: 럭키 가이드 체크리스트
/// - feng_shui_tips, lucky_dates, terrain_analysis
class ChatMovingResultCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final bool isBlurred;
  final List<String> blurredSections;

  const ChatMovingResultCard({
    super.key,
    required this.fortune,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  @override
  ConsumerState<ChatMovingResultCard> createState() => _ChatMovingResultCardState();
}

class _ChatMovingResultCardState extends ConsumerState<ChatMovingResultCard> {
  // 체크리스트 로컬 상태 (UI 인터랙션용)
  final Set<String> _checkedItems = {};

  /// 이사운 전용 민화 이미지
  static const List<String> _movingMinhwaImages = [
    'assets/images/minhwa/minhwa_overall_sunrise.webp',
    'assets/images/minhwa/minhwa_overall_tiger.webp',
    'assets/images/minhwa/minhwa_overall_dragon.webp',
  ];

  String _getMovingMinhwaImage() {
    final today = DateTime.now();
    final index = today.day % _movingMinhwaImages.length;
    return _movingMinhwaImages[index];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // additionalInfo에서 이사운 데이터 추출
    final data = widget.fortune.additionalInfo ?? {};

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
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 이미지 헤더
          _buildImageHeader(context, data),

          // 2. 점수 섹션
          _buildScoreSection(context, data),

          // 3. 정착 지수 & 이웃 케미 게이지 바
          _buildIndexGauges(context, data),

          // 4. 방위 분석 (블러)
          _buildDirectionSection(context, data),

          // 5. 럭키 체크리스트
          _buildLuckyChecklist(context, data),

          // 6. 풍수 조언 (블러)
          _buildFengShuiSection(context, data),

          // 7. 행운 아이템
          _buildLuckyItemsSection(context, data),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildImageHeader(BuildContext context, Map<String, dynamic> data) {
    final typography = context.typography;

    final currentArea = data['current_area'] ?? '';
    final targetArea = data['target_area'] ?? '';
    final direction = data['direction'] ?? '';

    return SizedBox(
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SmartImage(
            path: _getMovingMinhwaImage(),
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Positioned(
            left: DSSpacing.md,
            right: DSSpacing.md,
            bottom: DSSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('🏠', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '이사운',
                        style: typography.headingSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 좋아요 + 공유 버튼
                    FortuneActionButtons(
                      contentId: widget.fortune.id.isNotEmpty ? widget.fortune.id : 'moving_${DateTime.now().millisecondsSinceEpoch}',
                      contentType: 'moving',
                      shareTitle: '이사운 분석 결과',
                      shareContent: data['overall_fortune'] as String? ?? widget.fortune.content,
                      iconSize: 20,
                      iconColor: Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
                if (currentArea.isNotEmpty && targetArea.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$currentArea → $targetArea ${direction.isNotEmpty ? '($direction)' : ''}',
                    style: typography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    final score = data['score'] ?? data['moving_score'] ?? 75;
    final overallFortune = data['overall_fortune'] ?? data['content'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 원형 점수
          _MovingScoreCircle(score: score),

          const SizedBox(width: DSSpacing.md),

          // 전반적인 운세
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '종합 이사운',
                  style: typography.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  overallFortune,
                  style: typography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexGauges(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    // settlement_index 추출
    final settlementData = data['settlement_index'] as Map<String, dynamic>? ?? {};
    final settlementScore = (settlementData['score'] as num?)?.toInt() ?? 75;
    final settlementDesc = settlementData['description'] as String? ?? '정착 분석 중';

    // neighborhood_chemistry 추출
    final chemistryData = data['neighborhood_chemistry'] as Map<String, dynamic>? ?? {};
    final chemistryScore = (chemistryData['score'] as num?)?.toInt() ?? 70;
    final chemistryDesc = chemistryData['description'] as String? ?? '동네 분석 중';
    final vibeMatch = chemistryData['vibe_match'] as String? ?? '';

    final isSettlementBlurred = widget.blurredSections.contains('settlement_index');
    final isChemistryBlurred = widget.blurredSections.contains('neighborhood_chemistry');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '정착 & 동네 케미',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 정착 지수 게이지
          UnifiedBlurWrapper(
            isBlurred: isSettlementBlurred,
            blurredSections: widget.blurredSections,
            sectionKey: 'settlement_index',
            child: _buildGaugeBar(
              context: context,
              label: '정착 지수',
              emoji: '🏡',
              score: settlementScore,
              description: settlementDesc,
              color: _getScoreColor(settlementScore),
            ),
          ),

          const SizedBox(height: DSSpacing.md),

          // 이웃 케미 게이지
          UnifiedBlurWrapper(
            isBlurred: isChemistryBlurred,
            blurredSections: widget.blurredSections,
            sectionKey: 'neighborhood_chemistry',
            child: _buildGaugeBar(
              context: context,
              label: '이웃 케미',
              emoji: '🤝',
              score: chemistryScore,
              description: vibeMatch.isNotEmpty ? '$vibeMatch - $chemistryDesc' : chemistryDesc,
              color: _getScoreColor(chemistryScore),
            ),
          ),

          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildGaugeBar({
    required BuildContext context,
    required String label,
    required String emoji,
    required int score,
    required String description,
    required Color color,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 + 점수
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: typography.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '$score점',
              style: typography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 진행 바
        Stack(
          children: [
            // 배경
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
            ),
            // 진행
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  width: constraints.maxWidth * (score / 100),
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 4),

        // 설명
        Text(
          description,
          style: typography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDirectionSection(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    final directionData = data['direction_analysis'] as Map<String, dynamic>? ?? {};
    if (directionData.isEmpty) return const SizedBox.shrink();

    final direction = directionData['direction'] ?? '';
    final element = directionData['element'] ?? '';
    final meaning = directionData['direction_meaning'] ?? '';
    final compatibility = (directionData['compatibility'] as num?)?.toInt() ?? 0;

    final isBlurred = widget.blurredSections.contains('direction_analysis');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧭', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '방위 분석',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              if (direction.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                  ),
                  child: Text(
                    '$direction ($element)',
                    style: typography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          UnifiedBlurWrapper(
            isBlurred: isBlurred,
            blurredSections: widget.blurredSections,
            sectionKey: 'direction_analysis',
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (meaning.isNotEmpty)
                    Text(
                      meaning,
                      style: typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  if (compatibility > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '방위 궁합',
                          style: typography.labelSmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: compatibility / 100,
                            backgroundColor: colors.textSecondary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(_getScoreColor(compatibility)),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$compatibility점',
                          style: typography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(compatibility),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildLuckyChecklist(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    // lucky_checklist 추출
    List<dynamic> checklist = [];
    if (data['lucky_checklist'] != null) {
      checklist = data['lucky_checklist'] as List<dynamic>;
    }

    if (checklist.isEmpty) return const SizedBox.shrink();

    final isBlurred = widget.blurredSections.contains('lucky_checklist');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '럭키 가이드 체크리스트',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          UnifiedBlurWrapper(
            isBlurred: isBlurred,
            blurredSections: widget.blurredSections,
            sectionKey: 'lucky_checklist',
            child: Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: checklist.asMap().entries.map((entry) {
                  final item = entry.value as Map<String, dynamic>;
                  final itemId = item['id'] as String? ?? 'item_${entry.key}';
                  final task = item['task'] as String? ?? '';
                  final emoji = item['emoji'] as String? ?? '✨';
                  final reason = item['reason'] as String? ?? '';
                  final isChecked = _checkedItems.contains(itemId);

                  return _ChecklistItemTile(
                    emoji: emoji,
                    task: task,
                    reason: reason,
                    isChecked: isChecked,
                    onToggle: () {
                      setState(() {
                        if (isChecked) {
                          _checkedItems.remove(itemId);
                        } else {
                          _checkedItems.add(itemId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildFengShuiSection(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    final fengShui = data['feng_shui_tips'] as Map<String, dynamic>? ?? {};
    if (fengShui.isEmpty) return const SizedBox.shrink();

    final isBlurred = widget.blurredSections.contains('feng_shui_tips');

    final tips = [
      {'emoji': '🚪', 'label': '현관', 'text': fengShui['entrance']},
      {'emoji': '🛋️', 'label': '거실', 'text': fengShui['living_room']},
      {'emoji': '🛏️', 'label': '침실', 'text': fengShui['bedroom']},
      {'emoji': '🍳', 'label': '부엌', 'text': fengShui['kitchen']},
    ].where((tip) => tip['text'] != null && (tip['text'] as String).isNotEmpty).toList();

    if (tips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏯', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '풍수 조언',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          UnifiedBlurWrapper(
            isBlurred: isBlurred,
            blurredSections: widget.blurredSections,
            sectionKey: 'feng_shui_tips',
            child: Column(
              children: tips.map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip['emoji'] as String, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '${tip['label']}: ',
                        style: typography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip['text'] as String,
                          style: typography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsSection(BuildContext context, Map<String, dynamic> data) {
    final colors = context.colors;
    final typography = context.typography;

    final luckyItems = data['lucky_items'] as Map<String, dynamic>? ?? {};
    if (luckyItems.isEmpty) return const SizedBox.shrink();

    final items = luckyItems['items'] as List<dynamic>? ?? [];
    final itemsColors = luckyItems['colors'] as List<dynamic>? ?? [];
    final plants = luckyItems['plants'] as List<dynamic>? ?? [];

    if (items.isEmpty && itemsColors.isEmpty && plants.isEmpty) return const SizedBox.shrink();

    final isBlurred = widget.blurredSections.contains('lucky_items');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍀', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '행운 아이템',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          UnifiedBlurWrapper(
            isBlurred: isBlurred,
            blurredSections: widget.blurredSections,
            sectionKey: 'lucky_items',
            child: Wrap(
              spacing: DSSpacing.xs,
              runSpacing: DSSpacing.xs,
              children: [
                ...items.map((item) => _buildLuckyChip(context, '✨', item.toString())),
                ...itemsColors.map((c) => _buildLuckyChip(context, '🎨', c.toString())),
                ...plants.map((p) => _buildLuckyChip(context, '🪴', p.toString())),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildLuckyChip(BuildContext context, String emoji, String text) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: typography.labelSmall.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // 초록
    if (score >= 60) return const Color(0xFF3B82F6); // 파랑
    if (score >= 40) return const Color(0xFFF59E0B); // 주황
    return const Color(0xFFEF4444); // 빨강
  }
}

/// 원형 점수 위젯
class _MovingScoreCircle extends StatelessWidget {
  final int score;

  const _MovingScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                colors.textSecondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          // 진행 원
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // 점수 텍스트
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: typography.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
              Text(
                '점',
                style: typography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF3B82F6);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// 체크리스트 아이템 타일
class _ChecklistItemTile extends StatelessWidget {
  final String emoji;
  final String task;
  final String reason;
  final bool isChecked;
  final VoidCallback onToggle;

  const _ChecklistItemTile({
    required this.emoji,
    required this.task,
    required this.reason,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(DSRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 체크박스
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? colors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? colors.accent : colors.textSecondary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 10),

            // 이모지
            Text(emoji, style: const TextStyle(fontSize: 16)),

            const SizedBox(width: 8),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task,
                    style: typography.bodySmall.copyWith(
                      color: isChecked
                          ? colors.textSecondary
                          : colors.textPrimary,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      fontWeight: isChecked ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      reason,
                      style: typography.labelSmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
