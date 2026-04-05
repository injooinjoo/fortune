import { useEffect, useState } from 'react';

import { router } from 'expo-router';
import { TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

const bloodTypes = ['A', 'B', 'O', 'AB'] as const;

export function ProfileEditScreen() {
  const { onboardingProgress, session } = useAppBootstrap();
  const metadata = (session?.user.user_metadata ??
    {}) as Record<string, unknown>;
  const [displayName, setDisplayName] = useState(
    (metadata.name as string | undefined) ??
      (metadata.full_name as string | undefined) ??
      session?.user.email ??
      '',
  );
  const [birthDate, setBirthDate] = useState(
    (metadata.birth_date as string | undefined) ?? '',
  );
  const [birthTime, setBirthTime] = useState(
    (metadata.birth_time as string | undefined) ?? '',
  );
  const [mbti, setMbti] = useState((metadata.mbti as string | undefined) ?? '');
  const [bloodType, setBloodType] = useState(
    (metadata.blood_type as string | undefined) ?? '',
  );
  const [savedSnapshot, setSavedSnapshot] = useState<string | null>(null);

  useEffect(() => {
    if (!session) {
      setSavedSnapshot(null);
    }
  }, [session]);

  function handleSave() {
    try {
      const nextSnapshot = JSON.stringify({
        displayName,
        birthDate,
        birthTime,
        mbti,
        bloodType,
      });
      setSavedSnapshot(nextSnapshot);
    } catch (error) {
      void captureError(error, { surface: 'profile-edit:save' });
    }
  }

  if (!session) {
    return (
      <Screen>
        <AppText
          variant="labelMedium"
          color={fortuneTheme.colors.accentSecondary}
        >
          /profile/edit
        </AppText>
        <AppText variant="displaySmall">프로필 수정</AppText>
        <Card>
          <AppText variant="heading4">로그인이 필요합니다</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            계정이 연결된 뒤에 프로필 편집을 저장할 수 있습니다.
          </AppText>
          <PrimaryButton onPress={() => router.push('/signup')}>
            로그인 / 가입
          </PrimaryButton>
          <PrimaryButton onPress={() => router.back()} tone="secondary">
            돌아가기
          </PrimaryButton>
        </Card>
      </Screen>
    );
  }

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile/edit
      </AppText>
      <AppText variant="displaySmall">프로필 수정</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        RN shell 기준으로 편집 가능한 핵심 정보만 먼저 연결했습니다.
      </AppText>

      <Card>
        <AppText variant="heading4">상태</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`soft-gate:${onboardingProgress.softGateCompleted ? 'done' : 'todo'}`} />
          <Chip label={`auth:${onboardingProgress.authCompleted ? 'done' : 'todo'}`} />
          <Chip label={`birth:${onboardingProgress.birthCompleted ? 'done' : 'todo'}`} />
          <Chip label={`interest:${onboardingProgress.interestCompleted ? 'done' : 'todo'}`} />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">기본 정보</AppText>
        <Field
          label="표시 이름"
          placeholder="이름"
          value={displayName}
          onChangeText={setDisplayName}
        />
        <Field
          label="생년월일"
          placeholder="YYYY-MM-DD"
          value={birthDate}
          onChangeText={setBirthDate}
        />
        <Field
          label="태어난 시간"
          placeholder="HH:MM"
          value={birthTime}
          onChangeText={setBirthTime}
        />
        <Field
          label="MBTI"
          placeholder="INFJ"
          value={mbti}
          onChangeText={setMbti}
        />
        <Field
          label="혈액형"
          placeholder="A / B / O / AB"
          value={bloodType}
          onChangeText={setBloodType}
        />

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {bloodTypes.map((type) => (
            <PrimaryButton
              key={type}
              onPress={() => setBloodType(type)}
              tone={bloodType === type ? 'primary' : 'secondary'}
            >
              {type}
            </PrimaryButton>
          ))}
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">미리보기</AppText>
        <AppText variant="labelLarge">
          {displayName || '이름을 입력해 주세요'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {birthDate || '생년월일 미입력'} · {birthTime || '시간 미입력'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {mbti || 'MBTI 미입력'} · {bloodType || '혈액형 미입력'}
        </AppText>
        {savedSnapshot ? (
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            저장 스냅샷: {savedSnapshot}
          </AppText>
        ) : null}
      </Card>

      <Card>
        <AppText variant="heading4">동작</AppText>
        <PrimaryButton onPress={handleSave}>임시 저장</PrimaryButton>
        <PrimaryButton onPress={() => router.back()} tone="secondary">
          돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}

function Field({
  label,
  placeholder,
  value,
  onChangeText,
}: {
  label: string;
  placeholder: string;
  value: string;
  onChangeText: (value: string) => void;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <TextInput
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={fortuneTheme.colors.textTertiary}
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.lg,
          borderWidth: 1,
          color: fortuneTheme.colors.textPrimary,
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: 12,
        }}
        value={value}
      />
    </View>
  );
}
