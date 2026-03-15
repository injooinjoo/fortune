import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '내 사주 요약',
          style: context.heading3.copyWith(color: colors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.pageHorizontal,
          DSSpacing.md,
          DSSpacing.pageHorizontal,
          DSSpacing.xxl,
        ),
        children: [
          DSCard.elevated(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: _BirthInfoSummary(profile: profile),
          ),
          const SizedBox(height: DSSpacing.xl),
          if (state.isLoading && state.sajuData == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: DSSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.sajuData == null)
            _EmptySajuState(profile: profile)
          else
            _SajuContent(
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
    );
  }
}

class _BirthInfoSummary extends StatelessWidget {
  const _BirthInfoSummary({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기준 정보',
          style: context.heading4.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        Text(
          profile?.birthDate == null
              ? '생년월일과 태어난 시간을 입력하면 사주를 계산할 수 있어요.'
              : '${_formatBirth(profile!.birthDate!)} · ${profile!.birthTime ?? '시간 미입력'}',
          style: context.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmptySajuState extends ConsumerWidget {
  const _EmptySajuState({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCalculate = profile?.birthDate != null;

    return DSCard.outlined(
      padding: const EdgeInsets.all(DSSpacing.lg),
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
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
          DSButton.primary(
            text: canCalculate ? '사주 생성하기' : '내 정보 수정하기',
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

class _SajuContent extends StatelessWidget {
  const _SajuContent({
    required this.sajuData,
    required this.onRefresh,
  });

  final Map<String, dynamic> sajuData;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final elements = Map<String, dynamic>.from(
      sajuData['elements'] as Map<String, dynamic>? ?? const {},
    );
    final interpretation = sajuData['interpretation'] as String? ?? '';
    final personality = sajuData['personalityAnalysis'] as String? ?? '';
    final career = sajuData['careerGuidance'] as String? ?? '';
    final relationship = sajuData['relationshipAdvice'] as String? ?? '';
    final dayPillar = _pillarLabel(
      sajuData['day'] as Map<String, dynamic>?,
    );

    return Column(
      children: [
        DSCard.elevated(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '핵심 요약',
                style: context.heading4.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                '일주 $dayPillar · 강한 오행 ${sajuData['dominantElement'] ?? '미확인'} · '
                '보완 오행 ${sajuData['lackingElement'] ?? '미확인'}',
                style: context.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (interpretation.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.md),
                Text(
                  interpretation,
                  style: context.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
              const SizedBox(height: DSSpacing.lg),
              DSButton.secondary(
                text: '다시 계산하기',
                onPressed: onRefresh,
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.xl),
        DSSectionHeader(title: '오행 밸런스', uppercase: false),
        DSCard.outlined(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            children: [
              for (final element in ['목', '화', '토', '금', '수'])
                Padding(
                  padding: EdgeInsets.only(
                    bottom: element == '수' ? 0 : DSSpacing.md,
                  ),
                  child: _ElementMeter(
                    label: element,
                    value: (elements[element] as num?)?.toInt() ?? 0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.xl),
        _TextSection(
          title: '성향 분석',
          value: personality,
        ),
        const SizedBox(height: DSSpacing.xl),
        _TextSection(
          title: '커리어 가이드',
          value: career,
        ),
        const SizedBox(height: DSSpacing.xl),
        _TextSection(
          title: '관계 조언',
          value: relationship,
        ),
      ],
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DSCard.outlined(
      padding: const EdgeInsets.all(DSSpacing.lg),
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
            value.isEmpty ? '아직 계산된 설명이 없어요.' : value,
            style: context.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementMeter extends StatelessWidget {
  const _ElementMeter({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final normalized = (value / 4).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: context.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DSRadius.full),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: normalized,
              backgroundColor: colors.backgroundSecondary,
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Text(
          '$value',
          style: context.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
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

String _formatBirth(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}
