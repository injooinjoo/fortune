import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/models/user_created_character.dart';
import '../providers/user_created_character_provider.dart';

const List<String> _personalityOptions = [
  '다정한',
  '지적인',
  '유쾌한',
  '차분한',
  '솔직한',
  '장난기 많은',
  '세심한',
  '도도한',
];

const List<String> _interestOptions = [
  '영화',
  '음악',
  '독서',
  '여행',
  '사진',
  '운동',
  '맛집',
  '전시',
];

const List<String> _scenarioPresets = [
  '같은 동네에서 자주 마주치는 사이',
  '친구의 친구로 알게 된 사이',
  '같은 회사에서 일하는 사이',
  '취향이 겹쳐 가까워진 사이',
];

class FriendCreationBasicPage extends ConsumerWidget {
  const FriendCreationBasicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(friendCreationDraftProvider);
    final notifier = ref.read(friendCreationDraftProvider.notifier);

    return _FriendCreationScaffold(
      step: 1,
      title: '기본 정보',
      primaryText: '다음',
      onPrimaryPressed: draft.isBasicComplete
          ? () => context.push('/friends/new/persona')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: '표시 이름',
            subtitle: '대화에서 보일 친구 이름을 정하세요',
          ),
          TextFormField(
            initialValue: draft.name,
            onChanged: (value) => notifier.updateBasic(name: value),
            decoration: const InputDecoration(
              hintText: '이름을 입력하세요',
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: '성별'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UserCreatedCharacterGender.values
                .map(
                  (gender) => _SelectableChip(
                    label: _genderLabel(gender),
                    selected: draft.gender == gender,
                    onTap: () => notifier.updateBasic(gender: gender),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: '나와의 관계'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UserCreatedCharacterRelationship.values
                .map(
                  (relationship) => _SelectableChip(
                    label: _relationshipLabel(relationship),
                    selected: draft.relationship == relationship,
                    onTap: () => notifier.updateBasic(
                      relationship: relationship,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class FriendCreationPersonaPage extends ConsumerWidget {
  const FriendCreationPersonaPage({super.key});

  List<String> _toggleTag(List<String> current, String tag) {
    if (current.contains(tag)) {
      return current.where((value) => value != tag).toList();
    }
    if (current.length >= 3) {
      return current;
    }
    return [...current, tag];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(friendCreationDraftProvider);
    final notifier = ref.read(friendCreationDraftProvider.notifier);

    return _FriendCreationScaffold(
      step: 2,
      title: '캐릭터 설정',
      primaryText: '다음',
      secondaryText: '이전',
      onSecondaryPressed: () => context.pop(),
      onPrimaryPressed: draft.isPersonaComplete
          ? () => context.push('/friends/new/story')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: '분위기',
            subtitle: '대표 이미지를 대신할 기본 느낌이에요',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UserCreatedCharacterStylePreset.values
                .map(
                  (preset) => _SelectableChip(
                    label: _stylePresetLabel(preset),
                    selected: draft.stylePreset == preset,
                    onTap: () => notifier.updatePersona(stylePreset: preset),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: '성격 태그',
            subtitle: '2~3개 선택',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _personalityOptions
                .map(
                  (tag) => _SelectableChip(
                    label: tag,
                    selected: draft.personalityTags.contains(tag),
                    onTap: () => notifier.updatePersona(
                      personalityTags: _toggleTag(draft.personalityTags, tag),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: '관심사 태그',
            subtitle: '2~3개 선택',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestOptions
                .map(
                  (tag) => _SelectableChip(
                    label: tag,
                    selected: draft.interestTags.contains(tag),
                    onTap: () => notifier.updatePersona(
                      interestTags: _toggleTag(draft.interestTags, tag),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class FriendCreationStoryPage extends ConsumerWidget {
  const FriendCreationStoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(friendCreationDraftProvider);
    final notifier = ref.read(friendCreationDraftProvider.notifier);

    return _FriendCreationScaffold(
      step: 3,
      title: '관계 설정',
      primaryText: '다음',
      secondaryText: '이전',
      onSecondaryPressed: () => context.pop(),
      onPrimaryPressed: draft.isStoryComplete
          ? () => context.push('/friends/new/review')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: '관계 시나리오',
            subtitle: '어떤 배경에서 시작할지 정하세요',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _scenarioPresets
                .map(
                  (preset) => _SelectableChip(
                    label: preset,
                    selected: draft.scenario == preset,
                    onTap: () => notifier.updateStory(scenario: preset),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: draft.scenario,
            minLines: 2,
            maxLines: 3,
            onChanged: (value) => notifier.updateStory(scenario: value),
            decoration: const InputDecoration(
              hintText: '관계 배경을 직접 적어보세요',
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: '기억 노트',
            subtitle: '말투나 분위기에 반영될 메모예요',
          ),
          TextFormField(
            initialValue: draft.memoryNote,
            minLines: 4,
            maxLines: 6,
            onChanged: (value) => notifier.updateStory(memoryNote: value),
            decoration: const InputDecoration(
              hintText: '예: 퇴근길마다 같이 산책하는 사이예요',
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: '시간 설정'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UserCreatedCharacterTimeMode.values
                .map(
                  (mode) => _SelectableChip(
                    label: _timeModeLabel(mode),
                    selected: draft.timeMode == mode,
                    onTap: () => notifier.updateStory(timeMode: mode),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class FriendCreationReviewPage extends ConsumerWidget {
  const FriendCreationReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(friendCreationDraftProvider);

    return _FriendCreationScaffold(
      step: 4,
      title: '대화 시작하기',
      primaryText: '대화 시작하기',
      secondaryText: '이전',
      onSecondaryPressed: () => context.pop(),
      onPrimaryPressed: draft.isBasicComplete &&
              draft.isPersonaComplete &&
              draft.isStoryComplete
          ? () => context.push('/friends/new/creating')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCard(
            title: '기본 정보',
            lines: [
              '이름: ${draft.name}',
              '성별: ${_genderLabel(draft.gender)}',
              '관계: ${_relationshipLabel(draft.relationship)}',
            ],
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            title: '캐릭터 설정',
            lines: [
              '분위기: ${_stylePresetLabel(draft.stylePreset)}',
              '성격: ${draft.personalityTags.join(', ')}',
              '관심사: ${draft.interestTags.join(', ')}',
            ],
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            title: '관계 설정',
            lines: [
              '시작 배경: ${draft.scenario}',
              if (draft.memoryNote.trim().isNotEmpty)
                '기억 노트: ${draft.memoryNote.trim()}',
              '시간 설정: ${_timeModeLabel(draft.timeMode)}',
            ],
          ),
        ],
      ),
    );
  }
}

class FriendCreationCreatingPage extends ConsumerStatefulWidget {
  const FriendCreationCreatingPage({super.key});

  @override
  ConsumerState<FriendCreationCreatingPage> createState() =>
      _FriendCreationCreatingPageState();
}

class _FriendCreationCreatingPageState
    extends ConsumerState<FriendCreationCreatingPage> {
  bool _didStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createFriend();
    });
  }

  Future<void> _createFriend() async {
    if (_didStart) return;
    _didStart = true;

    final draft = ref.read(friendCreationDraftProvider);
    if (!draft.isBasicComplete ||
        !draft.isPersonaComplete ||
        !draft.isStoryComplete) {
      if (!mounted) return;
      context.go('/friends/new/basic');
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final created = await ref
        .read(userCreatedCharactersProvider.notifier)
        .createCharacter(draft);
    ref.read(friendCreationDraftProvider.notifier).reset();

    if (!mounted) return;

    final uri = Uri(
      path: '/chat',
      queryParameters: {
        'openCharacterChat': 'true',
        'characterId': created.id,
      },
    );
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2640),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '✦',
                    style: TextStyle(
                      fontSize: 32,
                      color: context.colors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              Text(
                '친구를 만들고 있어요',
                style: const TextStyle(
                  fontFamily: 'NanumMyeongjo',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.md),
              Text(
                '성격과 관계 배경을 바탕으로 대화를 준비하고 있어요. 잠시만 기다려주세요.',
                style: context.typography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DSSpacing.lg),
              SizedBox(
                width: 260,
                child: LinearProgressIndicator(
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                  backgroundColor: const Color(0xFF333333),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendCreationScaffold extends StatelessWidget {
  const _FriendCreationScaffold({
    required this.step,
    required this.title,
    required this.child,
    required this.primaryText,
    this.secondaryText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  final int step;
  final String title;
  final Widget child;
  final String primaryText;
  final String? secondaryText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '새 친구 만들기',
          style: context.typography.headingSmall.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$step/4',
                      style: context.typography.bodySmall.copyWith(
                        color: context.colors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'NanumMyeongjo',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ).copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  if (secondaryText != null) ...[
                    Expanded(
                      child: DSButton.secondary(
                        text: secondaryText!,
                        onPressed: onSecondaryPressed,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: DSButton.primary(
                      text: primaryText,
                      onPressed: onPrimaryPressed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.typography.bodyLarge.copyWith(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: context.colors.ctaBackground,
      backgroundColor: context.colors.surface,
      labelStyle: context.typography.bodyLarge.copyWith(
        color: selected
            ? context.colors.ctaForeground
            : context.colors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: selected
            ? context.colors.ctaBackground
            : context.colors.border.withValues(alpha: 0.8),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.full),
      ),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.typography.bodyLarge.copyWith(
              color: context.colors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: Text(
                line,
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _genderLabel(UserCreatedCharacterGender gender) {
  return switch (gender) {
    UserCreatedCharacterGender.female => '여성',
    UserCreatedCharacterGender.male => '남성',
    UserCreatedCharacterGender.other => '기타',
  };
}

String _relationshipLabel(UserCreatedCharacterRelationship relationship) {
  return switch (relationship) {
    UserCreatedCharacterRelationship.friend => '친구',
    UserCreatedCharacterRelationship.crush => '썸',
    UserCreatedCharacterRelationship.partner => '연인',
    UserCreatedCharacterRelationship.colleague => '동료',
  };
}

String _stylePresetLabel(UserCreatedCharacterStylePreset preset) {
  return switch (preset) {
    UserCreatedCharacterStylePreset.warm => '따뜻한',
    UserCreatedCharacterStylePreset.calm => '차분한',
    UserCreatedCharacterStylePreset.chic => '시크한',
    UserCreatedCharacterStylePreset.dreamy => '몽환적인',
  };
}

String _timeModeLabel(UserCreatedCharacterTimeMode mode) {
  return switch (mode) {
    UserCreatedCharacterTimeMode.realTime => '현실 시간 반영',
    UserCreatedCharacterTimeMode.timeless => '상관없이 진행',
  };
}
