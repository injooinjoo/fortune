import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/widgets/paper_runtime_chrome.dart';
import '../../core/widgets/paper_runtime_surface_kit.dart';
import '../../features/fortune/presentation/providers/saju_provider.dart';
import '../../models/user_profile.dart';
import '../../presentation/providers/providers.dart';

class SajuSummaryPage extends ConsumerStatefulWidget {
  const SajuSummaryPage({super.key});

  @override
  ConsumerState<SajuSummaryPage> createState() => _SajuSummaryPageState();
}

class _SajuSummaryPageState extends ConsumerState<SajuSummaryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sajuProvider.notifier).ensureLoaded(
            trigger: 'profileSajuSummary.init',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sajuProvider);
    final profile = ref.watch(userProfileNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const PaperRuntimeAppBar(title: '사주 요약'),
      body: PaperRuntimeBackground(
        showRings: false,
        applySafeArea: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.pageHorizontal,
            DSSpacing.md,
            DSSpacing.pageHorizontal,
            DSSpacing.xxl,
          ),
          children: [
            if (state.isLoading && state.sajuData == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: DSSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.sajuData == null)
              _EmptySajuState(profile: profile)
            else
              _SajuSummaryContent(
                profile: profile,
                sajuData: state.sajuData!,
                onRefresh: () async {
                  if (profile?.birthDate == null) {
                    return;
                  }
                  await ref.read(sajuProvider.notifier).calculateAndSaveSaju(
                        birthDate: profile!.birthDate!,
                        birthTime: profile.birthTime,
                        isLunar: profile.isLunarBirthdate ?? false,
                      );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptySajuState extends ConsumerWidget {
  const _EmptySajuState({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCalculate = profile?.birthDate != null;

    return PaperRuntimePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            canCalculate ? '사주를 생성할 수 있어요' : '출생 정보가 더 필요해요',
            style: context.heading4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            canCalculate
                ? '등록된 출생 정보를 바탕으로 사주 요약을 생성해 볼게요.'
                : '생년월일과 태어난 시간을 등록하면 사주 요약이 표시됩니다.',
            style: context.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: DSSpacing.xl),
          PaperRuntimeButton(
            label: canCalculate ? '사주 생성하기' : '내 정보 수정하기',
            onPressed: () async {
              if (!canCalculate) {
                context.push('/profile/edit');
                return;
              }

              await ref.read(sajuProvider.notifier).calculateAndSaveSaju(
                    birthDate: profile!.birthDate!,
                    birthTime: profile!.birthTime,
                    isLunar: profile!.isLunarBirthdate ?? false,
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _SajuSummaryContent extends StatelessWidget {
  final UserProfile? profile;
  final Map<String, dynamic> sajuData;
  final Future<void> Function() onRefresh;

  const _SajuSummaryContent({
    required this.profile,
    required this.sajuData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final elements = Map<String, dynamic>.from(
      sajuData['elements'] as Map<String, dynamic>? ?? const {},
    );
    final personality = sajuData['personalityAnalysis'] as String? ?? '';
    final interpretation = sajuData['interpretation'] as String? ?? '';
    final career = sajuData['careerGuidance'] as String? ?? '';
    final relationship = sajuData['relationshipAdvice'] as String? ?? '';

    final pillars = [
      ('년주', sajuData['year'] as Map<String, dynamic>?),
      ('월주', sajuData['month'] as Map<String, dynamic>?),
      ('일주', sajuData['day'] as Map<String, dynamic>?),
      ('시주', sajuData['hour'] as Map<String, dynamic>?),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaperRuntimePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '사주 팔자',
                    style: context.heading4.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      _formatBirthMoment(profile),
                      style: context.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.md),
              Row(
                children: [
                  for (final (label, pillar) in pillars) ...[
                    Expanded(
                      child: _PillarTile(
                        label: label,
                        value: _pillarLabel(pillar),
                      ),
                    ),
                    if (label != '시주') const SizedBox(width: DSSpacing.sm),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.xl),
        Text(
          '오행 분석',
          style: context.heading4.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Row(
          children: [
            for (final item in _elementItems(elements)) ...[
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (item.key != '수') const SizedBox(width: DSSpacing.sm),
            ],
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: DSSpacing.md,
          runSpacing: DSSpacing.xs,
          children: [
            for (final item in _elementItems(elements))
              _ElementLegend(
                color: item.color,
                label: '${item.key}(${item.label})',
              ),
          ],
        ),
        const SizedBox(height: DSSpacing.xl),
        PaperRuntimePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '성격 특성',
                style: context.heading4.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                personality.isEmpty ? '아직 계산된 설명이 없어요.' : personality,
                style: context.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xl),
          _TextPanel(title: '핵심 요약', value: interpretation),
        ],
        if (career.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xl),
          _TextPanel(title: '커리어 가이드', value: career),
        ],
        if (relationship.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xl),
          _TextPanel(title: '관계 조언', value: relationship),
        ],
        const SizedBox(height: DSSpacing.xl),
        PaperRuntimeButton(
          label: '다시 계산하기',
          onPressed: onRefresh,
          variant: PaperRuntimeButtonVariant.secondary,
        ),
      ],
    );
  }
}

class _PillarTile extends StatelessWidget {
  final String label;
  final String value;

  const _PillarTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(DSRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Text(
            value,
            style: context.heading4.copyWith(
              color: const Color(0xFFE8C697),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ElementLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: DSSpacing.xs),
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TextPanel extends StatelessWidget {
  final String title;
  final String value;

  const _TextPanel({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return PaperRuntimePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.heading4.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            value,
            style: context.bodyMedium.copyWith(
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementItem {
  final String key;
  final String label;
  final Color color;

  const _ElementItem({
    required this.key,
    required this.label,
    required this.color,
  });
}

List<_ElementItem> _elementItems(Map<String, dynamic> elements) {
  return const [
    _ElementItem(key: '화', label: '火', color: Color(0xFFFF6A6A)),
    _ElementItem(key: '목', label: '木', color: Color(0xFF57D3CB)),
    _ElementItem(key: '토', label: '土', color: Color(0xFFFFDF6A)),
    _ElementItem(key: '금', label: '金', color: Color(0xFFE6E6E6)),
    _ElementItem(key: '수', label: '水', color: Color(0xFF97B4FF)),
  ];
}

String _pillarLabel(Map<String, dynamic>? pillar) {
  if (pillar == null) {
    return '미확인';
  }

  final stem = pillar['cheongan']?['char'] ?? '';
  final branch = pillar['jiji']?['char'] ?? '';
  final label = '$stem$branch'.trim();
  return label.isEmpty ? '미확인' : label;
}

String _formatBirthMoment(UserProfile? profile) {
  if (profile?.birthDate == null) {
    return '출생 정보 없음';
  }

  final date = profile!.birthDate!;
  final time =
      profile.birthTime?.isNotEmpty == true ? profile.birthTime! : '00:00';
  return '${date.year}년 ${date.month}월 ${date.day}일 $time';
}
