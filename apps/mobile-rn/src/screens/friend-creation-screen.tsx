import { useEffect, useRef, useState, type ReactNode } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { ActivityIndicator, Alert, Image, Pressable, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { VoiceTextInput } from '../components/voice-text-input';
import { supabase } from '../lib/supabase';
import { fortuneTheme } from '../lib/theme';
import { useMobileAppState } from '../providers/mobile-app-state-provider';
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
  step,
  title,
  description,
  onBack,
}: {
  children: ReactNode;
  footer: ReactNode;
  step: string;
  title: string;
  description: string;
  onBack: () => void;
}) {
  return (
    <Screen footer={footer} keyboardAvoiding>
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <Pressable
          accessibilityRole="button"
          onPress={onBack}
          style={({ pressed }) => ({ opacity: pressed ? 0.82 : 1 })}
        >
          <AppText variant="heading4" color={fortuneTheme.colors.accentSecondary}>‹</AppText>
        </Pressable>
        <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
          새 친구 만들기
        </AppText>
        <AppText variant="displaySmall">{title}</AppText>
        <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
          <TokenChip label={step} selected />
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
    fontFamily: 'System',
    fontSize: 15,
    minHeight: multiline ? 104 : 52,
    paddingHorizontal: 14,
    paddingVertical: multiline ? 14 : 12,
    textAlignVertical: multiline ? ('top' as const) : ('center' as const),
  } as const;
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

function normalizeReturnTo(value: string | string[] | undefined) {
  const nextValue = Array.isArray(value) ? value[0] : value;
  return nextValue && nextValue.startsWith('/') ? nextValue : '/chat';
}

export function FriendCreationBasicScreen() {
  const params = useLocalSearchParams<{
    reset?: string | string[];
    returnTo?: string | string[];
  }>();
  const returnTo = normalizeReturnTo(params.returnTo);
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
          onPrimary={() =>
            router.push({
              pathname: '/friends/new/persona',
              params: { returnTo },
            })
          }
          primaryDisabled={!isBasicComplete}
          primaryLabel="다음"
        />
      }
      onBack={() => router.replace(returnTo as Href)}

      step="1/5"
      title="기본 정보"
    >
      <FriendSection
        subtitle="대화에서 보일 친구 이름을 정하세요."
        title="표시 이름"
      >
        <TextInput
          autoFocus
          onChangeText={(value) => updateBasic({ name: value })}
          placeholder="이름을 입력하세요"
          placeholderTextColor={fortuneTheme.colors.textTertiary}
          returnKeyType="done"
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
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const returnTo = normalizeReturnTo(params.returnTo);
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
          onPrimary={() =>
            router.push({
              pathname: '/friends/new/story',
              params: { returnTo },
            })
          }
          onSecondary={() => router.back()}
          primaryDisabled={!isPersonaComplete}
          primaryLabel="다음"
          secondaryLabel="이전"
        />
      }
      onBack={() => router.back()}

      step="2/5"
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
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const returnTo = normalizeReturnTo(params.returnTo);
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
          onPrimary={() =>
            router.push({
              pathname: '/friends/new/review',
              params: { returnTo },
            })
          }
          onSecondary={() => router.back()}
          primaryDisabled={!isStoryComplete}
          primaryLabel="다음"
          secondaryLabel="이전"
        />
      }
      onBack={() => router.back()}

      step="3/5"
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
        <VoiceTextInput
          multiline
          onChangeText={(value) => updateStory({ scenario: value })}
          placeholder="관계 배경을 직접 적어보세요 (마이크로 말해도 돼요)"
          value={draft.scenario}
        />
      </FriendSection>

      <FriendSection
        subtitle="말투나 분위기에 반영될 메모입니다."
        title="기억 노트"
      >
        <VoiceTextInput
          multiline
          onChangeText={(value) => updateStory({ memoryNote: value })}
          placeholder="예: 퇴근길마다 같이 산책하는 사이예요"
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
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const returnTo = normalizeReturnTo(params.returnTo);
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
          onPrimary={() =>
            router.push({
              pathname: '/friends/new/avatar',
              params: { returnTo },
            })
          }
          onSecondary={() => router.back()}
          primaryDisabled={!canProceed}
          primaryLabel="다음"
          secondaryLabel="이전"
        />
      }
      onBack={() => router.back()}

      step="4/5"
      title="확인하기"
    >
      <SummaryCard lines={lines.basic} title="기본 정보" />
      <SummaryCard lines={lines.persona} title="캐릭터 설정" />
      <SummaryCard lines={lines.story} title="관계 설정" />
    </FriendWizardScaffold>
  );
}

type AvatarGenerationStatus = 'idle' | 'generating' | 'done' | 'error';

async function invokeAvatarFunction(
  body: { gender: string; appearancePrompt: string; name: string; stylePreset: string },
): Promise<string> {
  const { data, error } = await supabase!.functions.invoke(
    'generate-friend-avatar',
    { body },
  );

  if (error) throw error;

  const result = data as { success: boolean; data?: { avatarUrl: string }; error?: string };
  if (!result.success || !result.data?.avatarUrl) {
    throw new Error(result.error ?? '이미지 생성에 실패했어요');
  }
  return result.data.avatarUrl;
}

async function generateFriendAvatar(
  gender: string,
  appearancePrompt: string,
  name: string,
  stylePreset: string,
): Promise<string> {
  if (!supabase) {
    throw new Error('Supabase client is not configured');
  }

  const body = { gender, appearancePrompt, name, stylePreset };

  try {
    return await invokeAvatarFunction(body);
  } catch (firstError) {
    // 401 인증 실패 시 세션 갱신 후 1회 재시도
    const msg = firstError instanceof Error ? firstError.message : '';
    if (msg.includes('non-2xx') || msg.includes('401') || msg.includes('Unauthorized')) {
      console.warn('[generateFriendAvatar] auth error, refreshing session and retrying');
      await supabase.auth.refreshSession();
      return await invokeAvatarFunction(body);
    }
    throw firstError;
  }
}

export function FriendCreationAvatarScreen() {
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const returnTo = normalizeReturnTo(params.returnTo);
  const {
    draft,
    isBasicComplete,
    isPersonaComplete,
    isStoryComplete,
    updateAvatar,
  } = useFriendCreation();

  const [status, setStatus] = useState<AvatarGenerationStatus>('idle');
  const [promptText, setPromptText] = useState(draft.avatarPrompt);
  const [previewUrl, setPreviewUrl] = useState<string | null>(draft.avatarUrl);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!isBasicComplete || !isPersonaComplete || !isStoryComplete) {
      router.replace('/friends/new/basic');
    }
  }, [isBasicComplete, isPersonaComplete, isStoryComplete]);

  async function handleGenerate() {
    if (!promptText.trim()) return;

    setStatus('generating');
    setErrorMessage(null);
    try {
      const url = await generateFriendAvatar(
        draft.gender ?? 'other',
        promptText.trim(),
        draft.name,
        draft.stylePreset ?? 'warm',
      );
      setPreviewUrl(url);
      updateAvatar({ avatarPrompt: promptText.trim(), avatarUrl: url });
      setStatus('done');
    } catch (e) {
      const msg = e instanceof Error ? e.message : '알 수 없는 오류가 발생했어요';
      console.error('[generateFriendAvatar] error:', msg);
      setErrorMessage(msg);
      setStatus('error');
    }
  }

  function handleRegenerate() {
    setPreviewUrl(null);
    setErrorMessage(null);
    setStatus('idle');
  }

  function handleConfirm() {
    updateAvatar({ avatarPrompt: promptText.trim(), avatarUrl: previewUrl });
    router.push({
      pathname: '/friends/new/creating',
      params: { returnTo },
    });
  }

  function handleSkip() {
    updateAvatar({ avatarPrompt: '', avatarUrl: null });
    router.push({
      pathname: '/friends/new/creating',
      params: { returnTo },
    });
  }

  const canGenerate = promptText.trim().length > 0 && status !== 'generating';

  return (
    <FriendWizardScaffold
      description={`${draft.name || '친구'}의 외모를 묘사하면 AI가 프로필 이미지를 만들어줘요. 건너뛰어도 괜찮아요.`}
      footer={
        status === 'done' && previewUrl ? (
          <FooterRow
            onPrimary={handleConfirm}
            onSecondary={handleRegenerate}
            primaryLabel="이 얼굴로 결정"
            secondaryLabel="다시 생성"
          />
        ) : (
          <FooterRow
            onPrimary={status === 'idle' || status === 'error' ? handleGenerate : () => undefined}
            onSecondary={handleSkip}
            primaryDisabled={!canGenerate}
            primaryLabel={status === 'generating' ? '생성 중...' : '생성하기'}
            secondaryLabel="건너뛰기"
          />
        )
      }
      onBack={() => router.back()}
      step="5/5"
      title="얼굴 만들기"
    >
      <FriendSection
        subtitle="외모 특징을 자유롭게 적어주세요."
        title="외모 묘사"
      >
        <VoiceTextInput
          multiline
          onChangeText={setPromptText}
          placeholder="예: 짧은 머리, 날카로운 눈매, 부드러운 미소"
          value={promptText}
        />
      </FriendSection>

      {status === 'generating' ? (
        <Card>
          <View
            style={{
              alignItems: 'center',
              gap: fortuneTheme.spacing.md,
              paddingVertical: fortuneTheme.spacing.xl,
            }}
          >
            <ActivityIndicator
              color={fortuneTheme.colors.ctaBackground}
              size="large"
            />
            <AppText
              color={fortuneTheme.colors.textSecondary}
              variant="bodyLarge"
            >
              AI가 얼굴을 그리고 있어요...
            </AppText>
          </View>
        </Card>
      ) : null}

      {status === 'error' ? (
        <Card>
          <View
            style={{
              alignItems: 'center',
              gap: fortuneTheme.spacing.sm,
              paddingVertical: fortuneTheme.spacing.md,
            }}
          >
            <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
              이미지 생성에 실패했어요. 다시 시도해주세요.
            </AppText>
            {errorMessage ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                {errorMessage}
              </AppText>
            ) : null}
          </View>
        </Card>
      ) : null}

      {status === 'done' && previewUrl ? (
        <Card>
          <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.md }}>
            <View
              style={{
                borderRadius: fortuneTheme.radius.lg,
                overflow: 'hidden',
                width: 200,
                height: 200,
              }}
            >
              <Image
                source={{ uri: previewUrl, cache: 'force-cache' }}
                style={{ width: 200, height: 200 }}
                resizeMode="cover"
              />
            </View>
            <AppText
              color={fortuneTheme.colors.textSecondary}
              variant="bodySmall"
            >
              마음에 드는 얼굴인가요?
            </AppText>
          </View>
        </Card>
      ) : null}
    </FriendWizardScaffold>
  );
}

type CreatingStatus = 'saving' | 'success' | 'error';

export function FriendCreationCreatingScreen() {
  const {
    draft,
    isBasicComplete,
    isPersonaComplete,
    isStoryComplete,
    resetDraft,
    saveFriend,
    createdFriends,
  } = useFriendCreation();
  const { state: mobileAppState } = useMobileAppState();
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const [status, setStatus] = useState<CreatingStatus>('saving');
  const returnTo = normalizeReturnTo(params.returnTo);
  const attemptedRef = useRef(false);

  const FREE_CHARACTER_LIMIT = 1;
  const isPremium = mobileAppState.premium.isUnlimited ||
    (mobileAppState.premium.tokenBalance ?? 0) > 0;

  useEffect(() => {
    if (!isBasicComplete || !isPersonaComplete || !isStoryComplete) {
      router.replace('/friends/new/basic');
      return;
    }

    if (attemptedRef.current) {
      return;
    }

    attemptedRef.current = true;

    // 멀티 캐릭터 프리미엄 게이팅: 무료 1명, 프리미엄 무제한
    if (!isPremium && createdFriends.length >= FREE_CHARACTER_LIMIT) {
      Alert.alert(
        '캐릭터 슬롯이 꽉 찼어요',
        '무료 플랜은 캐릭터 1명까지 만들 수 있어요. 프리미엄으로 업그레이드하면 무제한으로 만들 수 있어요!',
        [
          { text: '돌아가기', onPress: () => router.back() },
          { text: '프리미엄 보기', onPress: () => router.push('/premium') },
        ],
      );
      setStatus('error');
      return;
    }

    async function createFriend() {
      try {
        setStatus('saving');
        await saveFriend(draft);
        setStatus('success');
      } catch {
        setStatus('error');
      }
    }

    void createFriend();
  }, [
    draft,
    isBasicComplete,
    isPersonaComplete,
    isStoryComplete,
    saveFriend,
  ]);

  function handleFinish() {
    resetDraft();
    router.replace(returnTo as Href);
  }

  function handleRetry() {
    setStatus('saving');

    saveFriend(draft)
      .then(() => setStatus('success'))
      .catch(() => setStatus('error'));
  }

  const statusLabel =
    status === 'saving'
      ? '친구 생성 설정을 저장하고 있어요.'
      : status === 'success'
        ? '준비가 끝났어요. 채팅 허브로 돌아가 새 친구 흐름을 이어갈 수 있습니다.'
        : '저장 중 문제가 발생했어요. 다시 시도해주세요.';

  const statusEmoji = status === 'error' ? '!' : '✦';

  return (
    <Screen>
      <View
        style={{
          alignItems: 'center',
          gap: fortuneTheme.spacing.lg,
          justifyContent: 'center',
          minHeight: 520,
          paddingTop: 60,
        }}
      >
        {/* Avatar */}
        {draft.avatarUrl ? (
          <View
            style={{
              borderRadius: 999,
              height: 100,
              overflow: 'hidden',
              width: 100,
            }}
          >
            <Image
              source={{ uri: draft.avatarUrl, cache: 'force-cache' }}
              style={{ width: 100, height: 100 }}
              resizeMode="cover"
            />
          </View>
        ) : (
          <View
            style={{
              alignItems: 'center',
              backgroundColor: status === 'error'
                ? fortuneTheme.colors.surfaceElevated
                : fortuneTheme.colors.ctaBackground + '20',
              borderRadius: 999,
              height: 100,
              justifyContent: 'center',
              width: 100,
            }}
          >
            <AppText style={{ fontSize: 44 }}>
              {status === 'error' ? '😢' : status === 'success' ? '🎉' : '✨'}
            </AppText>
          </View>
        )}

        {/* Title */}
        <AppText variant="displaySmall" style={{ textAlign: 'center' }}>
          {status === 'error'
            ? '저장에 실패했어요'
            : status === 'success'
              ? `${draft.name || '친구'}가 준비됐어요!`
              : `${draft.name || '친구'}를 만들고 있어요`}
        </AppText>

        {/* Subtitle */}
        <AppText
          variant="bodyLarge"
          color={fortuneTheme.colors.textSecondary}
          style={{ maxWidth: 280, textAlign: 'center' }}
        >
          {status === 'error'
            ? '다시 시도해주세요.'
            : status === 'success'
              ? '채팅에서 바로 대화를 시작할 수 있어요.'
              : '성격과 관계를 바탕으로 대화를 준비하고 있어요.'}
        </AppText>

        {/* Action */}
        <View style={{ width: '100%', paddingHorizontal: 20, marginTop: 20 }}>
          {status === 'error' ? (
            <PrimaryButton onPress={handleRetry}>다시 시도</PrimaryButton>
          ) : (
            <PrimaryButton
              onPress={status === 'success' ? handleFinish : undefined}
              disabled={status === 'saving'}
            >
              {status === 'success' ? '채팅 시작하기' : '준비 중...'}
            </PrimaryButton>
          )}
        </View>
      </View>
    </Screen>
  );
}
