import { router } from "expo-router";
import { View } from "react-native";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { PrimaryButton } from "../components/primary-button";
import { RouteBackHeader } from "../components/route-back-header";
import { Screen } from "../components/screen";
import { formatFortuneTypeLabel } from "../lib/chat-shell";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

export function ProfileSajuSummaryScreen() {
  const { onboardingProgress, session } = useAppBootstrap();
  const { state } = useMobileAppState();
  const birthReady = Boolean(state.profile.birthDate.trim());
  const lastFortuneLabel = state.chat.lastFortuneType
    ? formatFortuneTypeLabel(state.chat.lastFortuneType)
    : null;

  return (
    <Screen header={<RouteBackHeader fallbackHref="/profile" />}>
      <AppText variant="displaySmall">사주 요약</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 프로필과 출생 정보가 준비되었는지 바로 확인할 수 있어요.
      </AppText>

      <Card>
        <AppText variant="heading4">준비 상태</AppText>
        <View style={{ gap: 8 }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {state.profile.displayName
              ? '저장된 이름이 있어요.'
              : '저장된 이름은 아직 없어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {session ? '로그인한 계정이에요.' : '게스트로 보고 있어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {birthReady
              ? '출생 정보가 저장되어 있어요.'
              : '출생 정보는 아직 저장되지 않았어요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.birthCompleted
              ? '출생 단계는 완료됐어요.'
              : '출생 단계는 아직 진행 중이에요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.interestCompleted
              ? '관심사 단계도 완료됐어요.'
              : '관심사 단계는 아직 진행 중이에요.'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.firstRunHandoffSeen
              ? '첫 안내 화면은 이미 확인했어요.'
              : '첫 안내 화면은 아직 확인하지 않았어요.'}
          </AppText>
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
            ? `메시지 ${state.chat.sentMessageCount}개를 보냈어요. · ${lastFortuneLabel ?? "정리 중"}`
            : "아직 최근 채팅 신호가 없습니다."}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">동작</AppText>
        <PrimaryButton onPress={() => router.push("/profile/edit")}>
          프로필 수정으로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push("/chat")} tone="secondary">
          채팅으로 이동
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
