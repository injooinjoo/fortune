import { router } from "expo-router";
import { View } from "react-native";

import { fortuneTypesById } from "@fortune/product-contracts";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { Chip } from "../components/chip";
import { PrimaryButton } from "../components/primary-button";
import { Screen } from "../components/screen";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

export function ProfileSajuSummaryScreen() {
  const { onboardingProgress, session } = useAppBootstrap();
  const { state } = useMobileAppState();
  const birthReady = Boolean(state.profile.birthDate.trim());
  const lastFortuneType = state.chat.lastFortuneType
    ? fortuneTypesById[state.chat.lastFortuneType]
    : null;

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile/saju-summary
      </AppText>
      <AppText variant="displaySmall">사주 요약</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 프로필과 출생 정보가 준비되었는지 shared state 기준으로
        보여줍니다.
      </AppText>

      <Card>
        <AppText variant="heading4">준비 상태</AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip label={`saved:${state.profile.displayName ? "yes" : "no"}`} />
          <Chip label={`session:${session ? "active" : "guest"}`} />
          <Chip
            label={`birth-saved:${birthReady ? "yes" : "no"}`}
            tone={birthReady ? "success" : "neutral"}
          />
          <Chip
            label={`birth:${onboardingProgress.birthCompleted ? "done" : "todo"}`}
          />
          <Chip
            label={`interest:${onboardingProgress.interestCompleted ? "done" : "todo"}`}
          />
          <Chip
            label={`handoff:${onboardingProgress.firstRunHandoffSeen ? "done" : "todo"}`}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">저장된 프로필</AppText>
        <AppText variant="labelLarge">
          {state.profile.displayName || "이름 미저장"}
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
        <AppText variant="heading4">해석 준비도</AppText>
        <AppText variant="labelLarge">
          {birthReady ? "사주 계산 준비됨" : "출생 정보가 더 필요해요"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {birthReady
            ? "저장된 생년월일이 있어서 이후 실제 사주 화면으로 연결하기 쉽습니다."
            : "생년월일을 저장하면 사주 요약과 관련 인사이트가 열립니다."}
        </AppText>
        <AppText variant="labelLarge">최근 채팅 신호</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.chat.sentMessageCount > 0
            ? `메시지 ${state.chat.sentMessageCount}개 · ${
                lastFortuneType?.labelKey ??
                state.chat.lastFortuneType ??
                "fortune 없음"
              }`
            : "아직 최근 채팅 신호가 없습니다."}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">동작</AppText>
        <PrimaryButton onPress={() => router.push("/profile/edit")}>
          프로필 수정으로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push("/chat")} tone="secondary">
          Chat 허브로 이동
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
