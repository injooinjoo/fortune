import { useEffect, useState, type ReactNode } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { Pressable, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import {
  type FriendCreationDraft,
  type FriendDraftGender,
  type FriendDraftRelationship,
  type FriendDraftStylePreset,
  type FriendDraftTimeMode,
  useFriendCreation,
} from '../providers/friend-creation-provider';

const personalityOptions = [
  '다정한',
  '지적인',
  '유쾌한',
  '차분한',
  '솔직한',
  '장난기 많은',
  '세심한',
  '도도한',
] as const;

const interestOptions = [
  '영화',
  '음악',
  '독서',
  '여행',
  '사진',
  '운동',
  '맛집',
  '전시',
] as const;

const scenarioPresets = [
  '같은 동네에서 자주 마주치는 사이',
  '친구의 친구로 알게 된 사이',
  '같은 회사에서 일하는 사이',
  '취향이 겹쳐 가까워진 사이',
] as const;

const genderOptions: readonly {
  label: string;
  value: FriendDraftGender;
}[] = [
  { label: '여성', value: 'female' },
  { label: '남성', value: 'male' },
  { label: '기타', value: 'other' },
];

const relationshipOptions: readonly {
  label: string;
  value: FriendDraftRelationship;
}[] = [
  { label: '친구', value: 'friend' },
  { label: '썸', value: 'crush' },
  { label: '연인', value: 'partner' },
  { label: '동료', value: 'colleague' },
];

const stylePresetOptions: readonly {
  label: string;
  value: FriendDraftStylePreset;
}[] = [
  { label: '따뜻한', value: 'warm' },
  { label: '차가운', value: 'calm' },
  { label: '신비로운', value: 'chic' },
  { label: '밝은', value: 'dreamy' },
];

const timeModeOptions: readonly {
  label: string;
  value: FriendDraftTimeMode;
}[] = [
  { label: '실시간', value: 'realTime' },
  { label: '느린 대화', value: 'timeless' },
];

function toggleTag(current: string[], next: string) {
  if (current.includes(next)) {
    return current.filter((value) => value !== next);
  }

  if (current.length >= 3) {
    return current;
  }

  return [...current, next];
}

function FriendWizardScaffold({
  children,
  footer,
  routePath,
  step,
  title,
  description,
  onBack,
}: {
  children: ReactNode;
  footer: ReactNode;
  routePath: string;
  step: string;
  title: string;
  description: string;
  onBack: () => void;
}) {
  return (
    <Screen footer={footer}>
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <Pressable
          accessibilityRole="button"
          onPress={onBack}
          style={({ pressed }) => ({ opacity: pressed ? 0.82 : 1 })}
        >
          <AppText variant="heading4">‹</AppText>
        </Pressable>
        <AppText
          variant="labelMedium"
          color={fortuneTheme.colors.accentSecondary}
        >
          {routePath}
        </AppText>
        <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
          새 친구 만들기
        </AppText>
        <AppText variant="displaySmall">{title}</AppText>
        <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
          <TokenChip label={step} selected />
          <TokenChip label="wizard" />
        </View>
      </View>

      {children}
    </Screen>
  );
}

function FriendSection({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle?: string;
  children: ReactNode;
}) {
  return (
    <Card>
      <View style={{ gap: 4 }}>
        <AppText variant="heading4">{title}</AppText>
        {subtitle ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {subtitle}
          </AppText>
        ) : null}
      </View>
      {children}
    </Card>
  );
}

function TokenChip({
  label,
  onPress,
  selected = false,
}: {
  label: string;
  onPress?: () => void;
  selected?: boolean;
}) {
  const content = (
    <View
      style={{
        alignSelf: 'flex-start',
        backgroundColor: selected
          ? fortuneTheme.colors.ctaBackground
          : fortuneTheme.colors.surfaceSecondary,
        borderColor: selected
          ? fortuneTheme.colors.ctaBackground
          : fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.full,
        borderWidth: 1,
        paddingHorizontal: 14,
        paddingVertical: 8,
      }}
    >
      <AppText
        variant="labelSmall"
        color={
          selected
            ? fortuneTheme.colors.ctaForeground
            : fortuneTheme.colors.textSecondary
        }
      >
        {label}
      </AppText>
    </View>
  );

  if (!onPress) {
    return content;
  }

  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
    >
      {content}
    </Pressable>
  );
}

function FooterRow({
  primaryLabel,
  secondaryLabel,
  onPrimary,
  onSecondary,
  primaryDisabled = false,
}: {
  primaryLabel: string;
  secondaryLabel?: string;
  onPrimary: () => void;
  onSecondary?: () => void;
  primaryDisabled?: boolean;
}) {
  return (
    <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
      {secondaryLabel && onSecondary ? (
        <View style={{ flex: 1 }}>
          <PrimaryButton onPress={onSecondary} tone="secondary">
            {secondaryLabel}
          </PrimaryButton>
        </View>
      ) : null}
      <View style={{ flex: 1 }}>
        <Pressable
          accessibilityRole="button"
          disabled={primaryDisabled}
          onPress={onPrimary}
          style={({ pressed }) => ({
            backgroundColor: primaryDisabled
              ? fortuneTheme.colors.surfaceElevated
              : fortuneTheme.colors.ctaBackground,
            borderRadius: fortuneTheme.radius.full,
            opacity: pressed ? 0.84 : 1,
            paddingHorizontal: 18,
            paddingVertical: 14,
          })}
        >
          <AppText
            variant="labelLarge"
            color={
              primaryDisabled
                ? fortuneTheme.colors.textTertiary
                : fortuneTheme.colors.ctaForeground
            }
            style={{ textAlign: 'center' }}
          >
            {primaryLabel}
          </AppText>
        </Pressable>
      </View>
    </View>
  );
}

function SummaryCard({
  title,
  lines,
}: {
  title: string;
  lines: string[];
}) {
  return (
    <Card style={{ backgroundColor: fortuneTheme.colors.surfaceSecondary }}>
      <AppText variant="heading4" color={fortuneTheme.colors.accentSecondary}>
        {title}
      </AppText>
      <View style={{ gap: 6 }}>
        {lines.map((line) => (
          <AppText
            key={`${title}:${line}`}
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            {line}
          </AppText>
        ))}
      </View>
    </Card>
  );
}

function inputStyle(multiline = false) {
  return {
    backgroundColor: fortuneTheme.colors.surfaceSecondary,
    borderColor: fortuneTheme.colors.border,
    borderRadius: fortuneTheme.radius.lg,
    borderWidth: 1,
    color: fortuneTheme.colors.textPrimary,
    minHeight: multiline ? 104 : 52,
    paddingHorizontal: 14,
    paddingVertical: multiline ? 14 : 12,
    textAlignVertical: multiline ? ('top' as const) : ('center' as const),
  };
}

function relationshipLabel(value: FriendDraftRelationship | null) {
  return (
    relationshipOptions.find((option) => option.value === value)?.label ?? '미선택'
  );
}

function genderLabel(value: FriendDraftGender | null) {
  return genderOptions.find((option) => option.value === value)?.label ?? '미선택';
}

function stylePresetLabel(value: FriendDraftStylePreset | null) {
  return (
    stylePresetOptions.find((option) => option.value === value)?.label ?? '미선택'
  );
}

function timeModeLabel(value: FriendDraftTimeMode | null) {
  return timeModeOptions.find((option) => option.value === value)?.label ?? '미선택';
}

function reviewLines(draft: FriendCreationDraft) {
  return {
    basic: [
      `이름: ${draft.name || '미입력'}`,
      `성별: ${genderLabel(draft.gender)}`,
      `관계: ${relationshipLabel(draft.relationship)}`,
    ],
    persona: [
      `분위기: ${stylePresetLabel(draft.stylePreset)}`,
      `성격: ${draft.personalityTags.join(', ') || '미선택'}`,
      `관심사: ${draft.interestTags.join(', ') || '미선택'}`,
    ],
    story: [
      `시작 배경: ${draft.scenario || '미입력'}`,
      draft.memoryNote.trim()
        ? `기억 노트: ${draft.memoryNote.trim()}`
        : '기억 노트: 없음',
      `시간 설정: ${timeModeLabel(draft.timeMode)}`,
    ],
  };
}

export function FriendCreationBasicScreen() {
  const params = useLocalSearchParams<{ reset?: string | string[] }>();
  const { draft, isBasicComplete, resetDraft, updateBasic } =
    useFriendCreation();
  const reset = Array.isArray(params.reset) ? params.reset[0] : params.reset;

  useEffect(() => {
    if (reset === '1') {
      resetDraft();
    }
  }, [reset, resetDraft]);

  return (
    <FriendWizardScaffold
      description="이름, 성별, 관계를 먼저 정하면 이후 페르소나와 스토리 단계가 안정적으로 이어집니다."
      footer={
        <FooterRow
          onPrimary={() => router.push('/friends/new/persona')}
          primaryDisabled={!isBasicComplete}
          primaryLabel="다음"
        />
      }
      onBack={() => router.replace('/chat')}
      routePath="/friends/new/basic"
      step="1/4"
      title="기본 정보"
    >
      <FriendSection
        subtitle="대화에서 보일 친구 이름을 정하세요."
        title="표시 이름"
      >
        <TextInput
          onChangeText={(value) => updateBasic({ name: value })}
          placeholder="이름을 입력하세요"
          placeholderTextColor={fortuneTheme.colors.textTertiary}
          style={inputStyle()}
          value={draft.name}
        />
      </FriendSection>

      <FriendSection title="성별">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {genderOptions.map((option) => (
            <TokenChip
              key={option.value}
              label={option.label}
              onPress={() => updateBasic({ gender: option.value })}
              selected={draft.gender === option.value}
            />
          ))}
        </View>
      </FriendSection>

      <FriendSection title="나와의 관계">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {relationshipOptions.map((option) => (
            <TokenChip
              key={option.value}
              label={option.label}
              onPress={() => updateBasic({ relationship: option.value })}
              selected={draft.relationship === option.value}
            />
          ))}
        </View>
      </FriendSection>
    </FriendWizardScaffold>
  );
}

export function FriendCreationPersonaScreen() {
  const { draft, isPersonaComplete, updatePersona } = useFriendCreation();

  useEffect(() => {
    if (!draft.name.trim() || draft.gender === null || draft.relationship === null) {
      router.replace('/friends/new/basic');
    }
  }, [draft.gender, draft.name, draft.relationship]);

  return (
    <FriendWizardScaffold
      description="대표 분위기와 성격, 관심사를 고르면 새 친구의 말투와 첫 인상이 정리됩니다."
      footer={
        <FooterRow
          onPrimary={() => router.push('/friends/new/story')}
          onSecondary={() => router.back()}
          primaryDisabled={!isPersonaComplete}
          primaryLabel="다음"
          secondaryLabel="이전"
        />
      }
      onBack={() => router.back()}
      routePath="/friends/new/persona"
      step="2/4"
      title="캐릭터 설정"
    >
      <FriendSection
        subtitle="대표 이미지를 대신할 기본 느낌입니다."
        title="분위기"
      >
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {stylePresetOptions.map((option) => (
            <TokenChip
              key={option.value}
              label={option.label}
              onPress={() => updatePersona({ stylePreset: option.value })}
              selected={draft.stylePreset === option.value}
            />
          ))}
        </View>
      </FriendSection>

      <FriendSection subtitle="2~3개 선택" title="성격 태그">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {personalityOptions.map((option) => (
            <TokenChip
              key={option}
              label={option}
              onPress={() =>
                updatePersona({
                  personalityTags: toggleTag(draft.personalityTags, option),
                })
              }
              selected={draft.personalityTags.includes(option)}
            />
          ))}
        </View>
      </FriendSection>

      <FriendSection subtitle="2~3개 선택" title="관심사 태그">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {interestOptions.map((option) => (
            <TokenChip
              key={option}
              label={option}
              onPress={() =>
                updatePersona({
                  interestTags: toggleTag(draft.interestTags, option),
                })
              }
              selected={draft.interestTags.includes(option)}
            />
          ))}
        </View>
      </FriendSection>
    </FriendWizardScaffold>
  );
}

export function FriendCreationStoryScreen() {
  const { draft, isStoryComplete, updateStory } = useFriendCreation();

  useEffect(() => {
    const missingBasic =
      !draft.name.trim() || draft.gender === null || draft.relationship === null;
    const missingPersona =
      draft.stylePreset === null ||
      draft.personalityTags.length < 2 ||
      draft.interestTags.length < 2;

    if (missingBasic || missingPersona) {
      router.replace(missingBasic ? '/friends/new/basic' : '/friends/new/persona');
    }
  }, [
    draft.gender,
    draft.interestTags.length,
    draft.name,
    draft.personalityTags.length,
    draft.relationship,
    draft.stylePreset,
  ]);

  return (
    <FriendWizardScaffold
      description="어떤 배경에서 시작하는지 정하면 review 단계에서 대화 방향을 자연스럽게 확인할 수 있습니다."
      footer={
        <FooterRow
          onPrimary={() => router.push('/friends/new/review')}
          onSecondary={() => router.back()}
          primaryDisabled={!isStoryComplete}
          primaryLabel="다음"
          secondaryLabel="이전"
        />
      }
      onBack={() => router.back()}
      routePath="/friends/new/story"
      step="3/4"
      title="관계 설정"
    >
      <FriendSection
        subtitle="어떤 배경에서 시작할지 정하세요."
        title="관계 시나리오"
      >
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {scenarioPresets.map((preset) => (
            <TokenChip
              key={preset}
              label={preset}
              onPress={() => updateStory({ scenario: preset })}
              selected={draft.scenario === preset}
            />
          ))}
        </View>
        <TextInput
          multiline
          onChangeText={(value) => updateStory({ scenario: value })}
          placeholder="관계 배경을 직접 적어보세요"
          placeholderTextColor={fortuneTheme.colors.textTertiary}
          style={inputStyle(true)}
          value={draft.scenario}
        />
      </FriendSection>

      <FriendSection
        subtitle="말투나 분위기에 반영될 메모입니다."
        title="기억 노트"
      >
        <TextInput
          multiline
          onChangeText={(value) => updateStory({ memoryNote: value })}
          placeholder="예: 퇴근길마다 같이 산책하는 사이예요"
          placeholderTextColor={fortuneTheme.colors.textTertiary}
          style={inputStyle(true)}
          value={draft.memoryNote}
        />
      </FriendSection>

      <FriendSection title="시간 설정">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {timeModeOptions.map((option) => (
            <TokenChip
              key={option.value}
              label={option.label}
              onPress={() => updateStory({ timeMode: option.value })}
              selected={draft.timeMode === option.value}
            />
          ))}
        </View>
      </FriendSection>
    </FriendWizardScaffold>
  );
}

export function FriendCreationReviewScreen() {
  const { draft, isBasicComplete, isPersonaComplete, isStoryComplete } =
    useFriendCreation();
  const lines = reviewLines(draft);
  const canProceed = isBasicComplete && isPersonaComplete && isStoryComplete;

  useEffect(() => {
    if (!isBasicComplete) {
      router.replace('/friends/new/basic');
      return;
    }

    if (!isPersonaComplete) {
      router.replace('/friends/new/persona');
      return;
    }

    if (!isStoryComplete) {
      router.replace('/friends/new/story');
    }
  }, [isBasicComplete, isPersonaComplete, isStoryComplete]);

  return (
    <FriendWizardScaffold
      description="문서 기준으로 생성 전 확인 단계입니다. 기본 정보, 캐릭터 설정, 관계 설정을 한 번 더 검토하세요."
      footer={
        <FooterRow
          onPrimary={() => router.push('/friends/new/creating')}
          onSecondary={() => router.back()}
          primaryDisabled={!canProceed}
          primaryLabel="대화 시작하기"
          secondaryLabel="이전"
        />
      }
      onBack={() => router.back()}
      routePath="/friends/new/review"
      step="4/4"
      title="대화 시작하기"
    >
      <SummaryCard lines={lines.basic} title="기본 정보" />
      <SummaryCard lines={lines.persona} title="캐릭터 설정" />
      <SummaryCard lines={lines.story} title="관계 설정" />
    </FriendWizardScaffold>
  );
}

export function FriendCreationCreatingScreen() {
  const {
    draft,
    isBasicComplete,
    isPersonaComplete,
    isStoryComplete,
    resetDraft,
  } = useFriendCreation();
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const [isReady, setIsReady] = useState(false);
  const returnToParam = Array.isArray(params.returnTo)
    ? params.returnTo[0]
    : params.returnTo;
  const returnTo =
    returnToParam && returnToParam.startsWith('/')
      ? (returnToParam as Href)
      : '/chat';

  useEffect(() => {
    if (!isBasicComplete || !isPersonaComplete || !isStoryComplete) {
      router.replace('/friends/new/basic');
      return;
    }

    const timeout = setTimeout(() => {
      setIsReady(true);
    }, 1400);

    return () => clearTimeout(timeout);
  }, [
    isBasicComplete,
    isPersonaComplete,
    isStoryComplete,
  ]);

  function handleFinish() {
    resetDraft();
    router.replace(returnTo);
  }

  return (
    <Screen>
      <View
        style={{
          alignItems: 'center',
          gap: fortuneTheme.spacing.md,
          justifyContent: 'center',
          minHeight: 520,
        }}
      >
        <View
          style={{
            alignItems: 'center',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderColor: fortuneTheme.colors.border,
            borderRadius: 999,
            borderWidth: 1,
            height: 84,
            justifyContent: 'center',
            width: 84,
          }}
        >
          <AppText
            variant="displaySmall"
            color={fortuneTheme.colors.accentSecondary}
          >
            ✦
          </AppText>
        </View>
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
            /friends/new/creating
          </AppText>
          <AppText variant="displaySmall">친구를 만들고 있어요</AppText>
          <AppText
            variant="bodyLarge"
            color={fortuneTheme.colors.textSecondary}
            style={{ maxWidth: 300, textAlign: 'center' }}
          >
            {draft.name
              ? `${draft.name}의 분위기와 관계 설정을 바탕으로 대화 시작점을 정리하고 있어요.`
              : '성격과 관계 배경을 바탕으로 대화 시작점을 정리하고 있어요.'}
          </AppText>
        </View>
        <Card style={{ width: '100%' }}>
          <AppText variant="heading4">생성 준비</AppText>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
            <TokenChip label={`name:${draft.name || 'pending'}`} selected />
            <TokenChip label={`persona:${draft.personalityTags.length}`} />
            <TokenChip label={`interest:${draft.interestTags.length}`} />
            <TokenChip label={`mode:${timeModeLabel(draft.timeMode)}`} />
          </View>
        </Card>
        <Card style={{ width: '100%' }}>
          <AppText variant="heading4">다음 동작</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {isReady
              ? '준비가 끝났어요. 채팅 허브로 돌아가 새 친구 흐름을 이어갈 수 있습니다.'
              : '친구 생성 설정을 정리하고 있어요.'}
          </AppText>
          <PrimaryButton onPress={isReady ? handleFinish : undefined}>
            {isReady ? '채팅으로 이동' : '준비 중...'}
          </PrimaryButton>
        </Card>
      </View>
    </Screen>
  );
}
