import { useMemo } from "react";

import { router } from "expo-router";
import { Pressable, View } from "react-native";

import {
  fortuneCharacters,
  fortuneTypesById,
} from "@fortune/product-contracts";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { Chip } from "../components/chip";
import { PrimaryButton } from "../components/primary-button";
import { Screen } from "../components/screen";
import { captureError } from "../lib/error-reporting";
import { supabase } from "../lib/supabase";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

export function ProfileScreen() {
  const { onboardingProgress, session } = useAppBootstrap();
  const { state } = useMobileAppState();
  const savedName =
    state.profile.displayName.trim() ||
    (session?.user.user_metadata.name as string | undefined) ||
    (session?.user.user_metadata.full_name as string | undefined) ||
    session?.user.email ||
    "게스트";
  const recentCharacter = useMemo(() => {
    if (!state.chat.selectedCharacterId) {
      return null;
    }

    return (
      fortuneCharacters.find(
        (character) => character.id === state.chat.selectedCharacterId,
      ) ?? null
    );
  }, [state.chat.selectedCharacterId]);
  const lastFortuneType = state.chat.lastFortuneType
    ? fortuneTypesById[state.chat.lastFortuneType]
    : null;
  const hasRecentChatSignal = Boolean(
    state.chat.selectedCharacterId ||
    state.chat.lastFortuneType ||
    state.chat.sentMessageCount > 0,
  );

  async function handleSignOut() {
    try {
      await supabase?.auth.signOut();
      router.replace("/chat");
    } catch (error) {
      await captureError(error, { surface: "profile:sign-out" });
    }
  }

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile
      </AppText>
      <AppText variant="displaySmall">프로필 허브</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 프로필, 프리미엄 상태, 최근 채팅 신호를 한눈에 볼 수 있습니다.
      </AppText>

      <Card>
        <AppText variant="heading4">저장된 프로필</AppText>
        <AppText variant="labelLarge">{savedName}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.profile.birthDate || state.profile.birthTime
            ? [
                state.profile.birthDate || "생년월일 미저장",
                state.profile.birthTime || "시간 미저장",
              ].join(" · ")
            : "생년월일 미저장"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.profile.mbti || "MBTI 미저장"} ·{" "}
          {state.profile.bloodType || "혈액형 미저장"}
        </AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip
            label={`provider:${session?.user.app_metadata.provider ?? "guest"}`}
            tone="accent"
          />
          <Chip label={`saved:${state.profile.displayName ? "yes" : "no"}`} />
          <Chip
            label={`birth:${state.profile.birthDate ? "saved" : "empty"}`}
            tone={state.profile.birthDate ? "success" : "neutral"}
          />
          <Chip
            label={`gate:${onboardingProgress.birthCompleted ? "ready" : "todo"}`}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">프리미엄 / 토큰</AppText>
        <AppText variant="labelLarge">
          {state.premium.tokenBalance.toLocaleString("ko-KR")} tokens
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {state.premium.status === "subscription"
            ? "구독 상태입니다."
            : state.premium.status === "lifetime"
              ? "평생 이용 상태입니다."
              : "구독 전 상태입니다."}
        </AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip label={`status:${state.premium.status}`} tone="accent" />
          <Chip label={`restore:${state.premium.restoreCount}`} />
          <Chip label={`balance:${state.premium.tokenBalance}`} />
          {state.premium.activeProductId ? (
            <Chip
              label={`active:${state.premium.activeProductId}`}
              tone="success"
            />
          ) : null}
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">최근 채팅 신호</AppText>
        <AppText variant="labelLarge">
          {recentCharacter?.name ?? "최근 캐릭터 없음"}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {hasRecentChatSignal
            ? state.chat.sentMessageCount > 0
              ? `메시지 ${state.chat.sentMessageCount}개 · ${
                  lastFortuneType?.labelKey ??
                  state.chat.lastFortuneType ??
                  "fortune 없음"
                }`
              : `최근 선택 캐릭터: ${recentCharacter?.name ?? state.chat.selectedCharacterId}`
            : "아직 채팅 신호가 없습니다."}
        </AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip
            label={`messages:${state.chat.sentMessageCount}`}
            tone={state.chat.sentMessageCount > 0 ? "success" : "neutral"}
          />
          <Chip
            label={
              state.chat.lastFortuneType
                ? `fortune:${state.chat.lastFortuneType}`
                : "fortune:none"
            }
          />
          <Chip
            label={
              recentCharacter
                ? `character:${recentCharacter.name}`
                : "character:none"
            }
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">나의 온도</AppText>
        <ProfileMenuRow
          label="프로필 수정"
          description="이름, 출생 정보, 이미지 표면"
          onPress={() => router.push("/profile/edit")}
        />
        <ProfileMenuRow
          label="사주 요약"
          description="사주 요약 및 기반 정보 확인"
          onPress={() => router.push("/profile/saju-summary")}
        />
        <ProfileMenuRow
          label="인간관계"
          description="관계 프로필과 연결 관리"
          onPress={() => router.push("/profile/relationships")}
        />
        <ProfileMenuRow
          label="알림 설정"
          description="푸시 및 딥링크 기본값"
          onPress={() => router.push("/profile/notifications")}
        />
      </Card>

      <Card>
        <AppText variant="heading4">구독 관리</AppText>
        <ProfileMenuRow
          label="구독 및 토큰"
          description="프리미엄 구독과 토큰 패키지"
          onPress={() => router.push("/premium")}
        />
        <ProfileMenuRow
          label="개인정보처리방침"
          description="법률 및 정책 문서"
          onPress={() => router.push("/privacy-policy")}
        />
        <ProfileMenuRow
          label="이용약관"
          description="서비스 이용 정책"
          onPress={() => router.push("/terms-of-service")}
        />
      </Card>

      {!session ? (
        <Card>
          <AppText variant="heading4">계정 연결</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            로그인하면 원격 계정과 동기화할 수 있지만, 지금 보이는 프로필 상태는
            이 기기에 저장된 값입니다.
          </AppText>
          <PrimaryButton onPress={() => router.push("/signup")}>
            회원가입 / 로그인
          </PrimaryButton>
        </Card>
      ) : null}

      <Card>
        <AppText variant="heading4">계정</AppText>
        <PrimaryButton onPress={() => void handleSignOut()} tone="secondary">
          로그아웃
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push("/account-deletion")}>
          계정 삭제
        </PrimaryButton>
      </Card>
    </Screen>
  );
}

function ProfileMenuRow({
  description,
  label,
  onPress,
}: {
  description: string;
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({
        opacity: pressed ? 0.82 : 1,
      })}
    >
      <View
        style={{
          borderBottomColor: fortuneTheme.colors.border,
          borderBottomWidth: 1,
          gap: fortuneTheme.spacing.xs,
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <AppText variant="bodyMedium">{label}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
      </View>
    </Pressable>
  );
}
