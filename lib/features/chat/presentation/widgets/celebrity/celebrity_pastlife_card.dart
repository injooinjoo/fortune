import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../domain/entities/fortune.dart';
import '../../../../../shared/widgets/smart_image.dart';

/// 유명인 전생인연 전용 카드
///
/// 6개 상세 항목:
/// - 전생 관계 유형
/// - 전생 스토리
/// - 카르마 과제
/// - 현생 연결고리
/// - 영혼 계약
/// - 해소 방법
class CelebrityPastLifeCard extends ConsumerStatefulWidget {
  final Fortune fortune;
  final String? celebrityName;
  final String? celebrityImageUrl;

  const CelebrityPastLifeCard({
    super.key,
    required this.fortune,
    this.celebrityName,
    this.celebrityImageUrl,
  });

  @override
  ConsumerState<CelebrityPastLifeCard> createState() =>
      _CelebrityPastLifeCardState();
}

class _CelebrityPastLifeCardState extends ConsumerState<CelebrityPastLifeCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(fortuneHapticServiceProvider).mysticalReveal();
      }
    });
  }

  // 데이터 추출 헬퍼
  Map<String, dynamic> get _additionalInfo =>
      widget.fortune.additionalInfo ?? {};

  Map<String, dynamic>? get _pastLifeRelationship =>
      _additionalInfo['past_life_relationship'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _pastLifeStory =>
      _additionalInfo['past_life_story'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _karmaMission =>
      _additionalInfo['karma_mission'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _presentConnection =>
      _additionalInfo['present_connection'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _soulContract =>
      _additionalInfo['soul_contract'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _resolutionGuide =>
      _additionalInfo['resolution_guide'] as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // 헤더
          _buildHeader(context).animate().fadeIn(duration: 400.ms),

          // 메인 메시지
          _buildMainMessage(context)
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),

          // 1. 전생 관계 유형
          if (_pastLifeRelationship != null)
            _buildRelationshipSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms),

          // 2. 전생 스토리
          if (_pastLifeStory != null)
            _buildStorySection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms),

          // 3. 카르마 과제
          if (_karmaMission != null)
            _buildKarmaSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms),

          // 4. 현생 연결고리
          if (_presentConnection != null)
            _buildConnectionSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms),

          // 5. 영혼 계약
          if (_soulContract != null)
            _buildSoulContractSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms),

          // 6. 해소 방법
          if (_resolutionGuide != null)
            _buildResolutionSection(context)
                .animate()
                .fadeIn(duration: 500.ms, delay: 700.ms),

          const SizedBox(height: DSSpacing.md),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final score = widget.fortune.score;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF312E81).withValues(alpha: 0.15), // 신비로운 남보라색
            const Color(0xFF4C1D95).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          // 유명인 아바타 + 달
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF312E81).withValues(alpha: 0.2),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: widget.celebrityImageUrl != null
                      ? SmartImage(
                          path: widget.celebrityImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text('🌙', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(width: DSSpacing.md),

          // 이름 + 타입
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.celebrityName ?? '유명인'}과의 전생 인연',
                  style: typography.headingSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '🌙 영혼의 기억 분석',
                  style: typography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 점수 배지 (별 모양)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.sm,
              vertical: DSSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(DSRadius.full),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$score',
                  style: typography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMessage(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final message = widget.fortune.content;

    return Padding(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFF312E81).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          message,
          style: typography.bodyMedium.copyWith(
            color: colors.textPrimary,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipSection(BuildContext context) {
    final typography = context.typography;
    final data = _pastLifeRelationship!;

    return _buildSection(
      context,
      icon: '🎭',
      title: '전생 관계',
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF312E81).withValues(alpha: 0.1),
              const Color(0xFF4C1D95).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Column(
          children: [
            // 관계 유형 배지
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
              child: Text(
                data['type'] ?? '운명적 인연',
                style: typography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            // 시대와 장소
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(context, '🏛️', data['era'] ?? '', const Color(0xFFB8860B)),
                const SizedBox(width: DSSpacing.sm),
                _buildInfoChip(context, '📍', data['location'] ?? '', const Color(0xFF22C55E)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String emoji, String text, Color color) {
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: typography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _pastLifeStory!;
    final keyEvents = data['key_events'] as List? ?? [];

    return _buildSection(
      context,
      icon: '📜',
      title: '전생 스토리',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 내러티브
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.textPrimary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(DSRadius.md),
              border: Border(
                left: BorderSide(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              data['narrative'] ?? '',
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (keyEvents.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Text(
              '✨ 운명의 순간들',
              style: typography.labelMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...keyEvents.take(3).map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      event.toString(),
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (data['emotional_bond'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💔'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['emotional_bond'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKarmaSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _karmaMission!;

    return _buildSection(
      context,
      icon: '⚖️',
      title: '카르마 과제',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['unfinished_business'] != null)
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔮 못다한 이야기',
                    style: typography.labelSmall.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    data['unfinished_business'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          if (data['current_life_purpose'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 이번 생의 목적',
                    style: typography.labelSmall.copyWith(
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    data['current_life_purpose'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (data['healing_path'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌿'),
                const SizedBox(width: DSSpacing.xs),
                Expanded(
                  child: Text(
                    data['healing_path'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _presentConnection!;
    final signs = data['signs'] as List? ?? [];

    return _buildSection(
      context,
      icon: '🔗',
      title: '현생 연결고리',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (signs.isNotEmpty) ...[
            Text(
              '전생 인연의 증거',
              style: typography.labelSmall.copyWith(
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...signs.take(3).map((sign) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      sign.toString(),
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (data['deja_vu_moments'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👁️ 데자뷔 순간',
                    style: typography.labelSmall.copyWith(
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    data['deja_vu_moments'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (data['unexplained_feelings'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💫 설명 안 되는 끌림',
                    style: typography.labelSmall.copyWith(
                      color: const Color(0xFFEC4899),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    data['unexplained_feelings'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoulContractSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _soulContract!;
    final lessons = data['lessons'] as List? ?? [];

    return _buildSection(
      context,
      icon: '📝',
      title: '영혼 계약',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['agreement'] != null)
            Container(
              padding: const EdgeInsets.all(DSSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.1),
                    const Color(0xFFFFA500).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text('📜', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: DSSpacing.sm),
                  Text(
                    data['agreement'],
                    style: typography.bodySmall.copyWith(
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          if (lessons.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              '📚 배울 교훈',
              style: typography.labelSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            ...lessons.take(2).map((lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      lesson.toString(),
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (data['rewards'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎁'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['rewards'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResolutionSection(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final data = _resolutionGuide!;
    final steps = data['steps'] as List? ?? [];

    return _buildSection(
      context,
      icon: '🌟',
      title: '인연 완성 가이드',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (steps.isNotEmpty) ...[
            ...steps.asMap().entries.take(3).map((entry) {
              final index = entry.key + 1;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: typography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        step.toString(),
                        style: typography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (data['rituals'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🕯️'),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      data['rituals'],
                      style: typography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (data['timeline'] != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⏰', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    data['timeline'],
                    style: typography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
  }) {
    final colors = context.colors;
    final typography = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                title,
                style: typography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF312E81).withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
