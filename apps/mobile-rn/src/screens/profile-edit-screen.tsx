import { useEffect, useState } from "react";

import { router } from "expo-router";
import { TextInput, View } from "react-native";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { PrimaryButton } from "../components/primary-button";
import { Screen } from "../components/screen";
import { captureError } from "../lib/error-reporting";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

const bloodTypes = ["A", "B", "O", "AB"] as const;

export function ProfileEditScreen() {
  const { onboardingProgress, session, updateOnboardingProgress } =
    useAppBootstrap();
  const { state, saveProfile, status } = useMobileAppState();
  const [displayName, setDisplayName] = useState("");
  const [birthDate, setBirthDate] = useState("");
  const [birthTime, setBirthTime] = useState("");
  const [mbti, setMbti] = useState("");
  const [bloodType, setBloodType] = useState("");
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    if (status !== "ready" || hydrated) {
      return;
    }

    setDisplayName(state.profile.displayName.trim());
    setBirthDate(state.profile.birthDate.trim());
    setBirthTime(state.profile.birthTime.trim());
    setMbti(state.profile.mbti.trim());
    setBloodType(state.profile.bloodType.trim());
    setHydrated(true);
  }, [
    hydrated,
    state.profile.birthDate,
    state.profile.birthTime,
    state.profile.bloodType,
    state.profile.displayName,
    state.profile.mbti,
    status,
  ]);

  async function handleSave() {
    try {
      const nextProfile = {
        displayName: displayName.trim(),
        birthDate: birthDate.trim(),
        birthTime: birthTime.trim(),
        mbti: mbti.trim().toUpperCase(),
        bloodType: bloodType.trim().toUpperCase(),
      };

      await saveProfile(nextProfile);
      await updateOnboardingProgress({
        birthCompleted: nextProfile.birthDate.length > 0,
      });
    } catch (error) {
      void captureError(error, { surface: "profile-edit:save" });
    }
  }

  return (
    <Screen>
      <AppText variant="displaySmall">프로필 수정</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 프로필을 불러와 수정하고, 생년월일이 있으면 온보딩 상태도 함께
        갱신합니다.
      </AppText>

      <Card>
        <AppText variant="heading4">저장된 값</AppText>
        <AppText variant="labelLarge">
          {state.profile.displayName || displayName || "이름 미저장"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.profile.birthDate || "생년월일 미저장"} ·{" "}
          {state.profile.birthTime || "시간 미저장"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.profile.mbti || "MBTI 미저장"} ·{" "}
          {state.profile.bloodType || "혈액형 미저장"}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">온보딩 상태</AppText>
        <View style={{ gap: 8 }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.softGateCompleted
              ? '첫 확인 단계가 끝났어요.'
              : '첫 확인 단계가 아직 진행 중이에요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.authCompleted
              ? '계정 연결이 완료됐어요.'
              : '계정 연결은 아직 진행 중이에요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.birthCompleted
              ? '출생 정보 단계가 완료됐어요.'
              : '출생 정보 단계가 아직 진행 중이에요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.interestCompleted
              ? '관심사 단계도 완료됐어요.'
              : '관심사 단계는 아직 진행 중이에요.'}
          </AppText>
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

        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          {bloodTypes.map((type) => (
            <PrimaryButton
              key={type}
              onPress={() => setBloodType(type)}
              tone={bloodType === type ? "primary" : "secondary"}
            >
              {type}
            </PrimaryButton>
          ))}
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">미리보기</AppText>
        <AppText variant="labelLarge">
          {displayName || "이름을 입력해 주세요"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {birthDate || "생년월일 미입력"} · {birthTime || "시간 미입력"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {mbti || "MBTI 미입력"} · {bloodType || "혈액형 미입력"}
        </AppText>
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          {state.profile.birthDate
            ? "저장된 생년월일이 있어서 온보딩 진행 상태도 함께 반영돼요."
            : "생년월일을 저장하면 온보딩 진행 상태도 함께 갱신돼요."}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">동작</AppText>
        <PrimaryButton onPress={() => void handleSave()}>
          임시 저장
        </PrimaryButton>
        {!session ? (
          <PrimaryButton
            onPress={() =>
              router.push({
                pathname: '/signup',
                params: { returnTo: '/profile/edit' },
              })
            }
            tone="secondary"
          >
            계정 연결
          </PrimaryButton>
        ) : null}
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
