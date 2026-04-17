import { useEffect, useState } from "react";

import { Ionicons } from "@expo/vector-icons";
import { router } from "expo-router";
import { Alert, Pressable, TextInput, View } from "react-native";

import { AppText } from "../components/app-text";
import { InlineCalendar } from "../components/inline-calendar";
import { PrimaryButton } from "../components/primary-button";
import { Screen } from "../components/screen";
import { captureError } from "../lib/error-reporting";
import { patchMobileAppState } from "../lib/storage";
import { fortuneTheme } from "../lib/theme";
import { ensureRemoteUserProfile, updateRemoteUserProfile } from "../lib/user-profile-remote";
import { invalidateFortuneResultCache } from "../features/chat-results/edge-runtime";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

type Gender = "male" | "female" | null;

const genderOptions: readonly { label: string; value: Gender }[] = [
  { label: "남성", value: "male" },
  { label: "여성", value: "female" },
];

export function ProfileEditScreen() {
  const { session, updateOnboardingProgress } = useAppBootstrap();
  const { state, refreshLocalState, status } = useMobileAppState();
  const [displayName, setDisplayName] = useState("");
  const [birthDate, setBirthDate] = useState("");
  const [birthTime, setBirthTime] = useState("");
  const [mbti, setMbti] = useState("");
  const [bloodType, setBloodType] = useState("");
  const [gender, setGender] = useState<Gender>(null);
  const [hydrated, setHydrated] = useState(false);
  const [saving, setSaving] = useState(false);
  const [editingBirthDate, setEditingBirthDate] = useState(false);

  const email = session?.user.email ?? null;

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
    if (saving) return;
    setSaving(true);
    try {
      const nextProfile = {
        displayName: displayName.trim(),
        birthDate: birthDate.trim(),
        birthTime: birthTime.trim(),
        mbti: mbti.trim().toUpperCase(),
        bloodType: bloodType.trim().toUpperCase(),
      };

      const userId = session?.user.id ?? null;

      // 1. Write directly to SecureStore (bypasses provider's serialized queue)
      console.log('[profile-edit] saving:', JSON.stringify(nextProfile));
      await patchMobileAppState(
        {
          profile: {
            ...nextProfile,
            interestIds: state.profile.interestIds,
          },
        },
        userId,
      );
      console.log('[profile-edit] SecureStore write done');

      // 2. Sync React state from SecureStore immediately
      await refreshLocalState();
      console.log('[profile-edit] refreshLocalState done');

      // 3. Push to Supabase BEFORE navigating back, so syncRemoteProfile
      //    on the profile screen won't read stale remote data.
      if (session) {
        try {
          await ensureRemoteUserProfile(session);
          await updateRemoteUserProfile(session.user.id, {
            name: nextProfile.displayName || null,
            birth_date: nextProfile.birthDate || null,
            birth_time: nextProfile.birthTime || null,
            mbti: nextProfile.mbti || null,
            blood_type: nextProfile.bloodType || null,
          });
          console.log('[profile-edit] Supabase push done');
        } catch (remoteError) {
          console.warn('[profile-edit] Supabase push failed:', remoteError);
        }
      }

      updateOnboardingProgress({
        birthCompleted: nextProfile.birthDate.length > 0,
      }).catch(() => undefined);
      invalidateFortuneResultCache();

      if (router.canGoBack()) {
        router.back();
      } else {
        router.replace("/profile");
      }
      setTimeout(() => Alert.alert("저장 완료", "프로필이 저장되었어요."), 300);
    } catch (error) {
      void captureError(error, { surface: "profile-edit:save" });
      Alert.alert("저장 실패", error instanceof Error ? error.message : "프로필을 저장하지 못했어요. 다시 시도해주세요.");
    } finally {
      setSaving(false);
    }
  }

  function handleCancel() {
    if (router.canGoBack()) {
      router.back();
    } else {
      router.replace("/profile");
    }
  }

  const initial =
    displayName.trim().charAt(0).toUpperCase() ||
    (session?.user.user_metadata.name as string | undefined)?.charAt(0).toUpperCase() ||
    "U";

  return (
    <Screen
      keyboardAvoiding
      header={
        <View
          style={{
            flexDirection: "row",
            alignItems: "center",
            justifyContent: "space-between",
            paddingVertical: fortuneTheme.spacing.xs,
          }}
        >
          <Pressable
            accessibilityLabel="취소"
            accessibilityRole="button"
            hitSlop={16}
            onPress={handleCancel}
            style={({ pressed }) => ({
              minWidth: 44,
              minHeight: 44,
              alignItems: "center",
              justifyContent: "center",
              opacity: pressed ? 0.6 : 1,
            })}
          >
            <AppText
              variant="bodyLarge"
              color={fortuneTheme.colors.accentSecondary}
            >
              취소
            </AppText>
          </Pressable>

          <AppText variant="heading4">프로필 수정</AppText>

          <Pressable
            accessibilityLabel="저장"
            accessibilityRole="button"
            disabled={saving}
            hitSlop={16}
            onPress={() => void handleSave()}
            style={({ pressed }) => ({
              minWidth: 44,
              minHeight: 44,
              alignItems: "center",
              justifyContent: "center",
              opacity: saving ? 0.4 : pressed ? 0.6 : 1,
            })}
          >
            <AppText
              variant="bodyLarge"
              color={fortuneTheme.colors.accentSecondary}
              style={{ fontWeight: "700" }}
            >
              저장
            </AppText>
          </Pressable>
        </View>
      }
    >
      {/* Avatar */}
      <View style={{ alignItems: "center", paddingVertical: fortuneTheme.spacing.lg }}>
        <View
          style={{
            width: 96,
            height: 96,
            borderRadius: 48,
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderWidth: 1,
            borderColor: fortuneTheme.colors.border,
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <AppText
            variant="displayMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            {initial}
          </AppText>

          {/* Camera icon overlay */}
          <View
            style={{
              position: "absolute",
              bottom: 0,
              right: 0,
              width: 32,
              height: 32,
              borderRadius: 16,
              backgroundColor: fortuneTheme.colors.ctaBackground,
              alignItems: "center",
              justifyContent: "center",
              borderWidth: 2,
              borderColor: fortuneTheme.colors.background,
            }}
          >
            <Ionicons
              name="camera"
              size={16}
              color={fortuneTheme.colors.ctaForeground}
            />
          </View>
        </View>
      </View>

      {/* Form fields */}
      <View style={{ gap: fortuneTheme.spacing.lg }}>
        <Field
          label="이름"
          placeholder="이름을 입력해주세요"
          value={displayName}
          onChangeText={setDisplayName}
        />

        <ReadOnlyField label="이메일" value={email ?? "로그인 후 표시됩니다"} />

        {/* 생년월일 — 달력 선택 */}
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
            생년월일
          </AppText>
          {birthDate && !editingBirthDate ? (
            <Pressable
              onPress={() => setEditingBirthDate(true)}
              style={({ pressed }) => ({
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderColor: fortuneTheme.colors.ctaBackground,
                borderRadius: fortuneTheme.radius.lg,
                borderWidth: 1,
                paddingHorizontal: fortuneTheme.spacing.md,
                paddingVertical: 14,
                flexDirection: "row",
                justifyContent: "space-between",
                alignItems: "center",
                opacity: pressed ? 0.8 : 1,
              })}
            >
              <AppText variant="bodyMedium">{birthDate}</AppText>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>변경</AppText>
            </Pressable>
          ) : (
            <InlineCalendar
              selectedDate={birthDate ? (() => { const [y, m, d] = birthDate.split("-").map(Number); return new Date(y, m - 1, d); })() : null}
              onSelectDate={(date) => {
                const y = date.getFullYear();
                const m = String(date.getMonth() + 1).padStart(2, "0");
                const d = String(date.getDate()).padStart(2, "0");
                setBirthDate(`${y}-${m}-${d}`);
                setEditingBirthDate(false);
              }}
              maxDate={new Date()}
            />
          )}
        </View>

        {/* 성별 — 칩 선택 */}
        <ChipSelector
          label="성별"
          options={genderOptions}
          selected={gender}
          onSelect={(v) => setGender(v as Gender)}
        />

        {/* 태어난 시간 — 시간 칩 */}
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
            태어난 시간
          </AppText>
          <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 6 }}>
            {["모름", "00:00~02:00", "02:00~04:00", "04:00~06:00", "06:00~08:00", "08:00~10:00", "10:00~12:00", "12:00~14:00", "14:00~16:00", "16:00~18:00", "18:00~20:00", "20:00~22:00", "22:00~24:00"].map((slot) => {
              const isSelected = birthTime === slot || (slot === "모름" && birthTime === "");
              return (
                <Pressable
                  key={slot}
                  onPress={() => setBirthTime(slot === "모름" ? "" : slot)}
                  style={({ pressed }) => ({
                    paddingHorizontal: 12,
                    paddingVertical: 8,
                    borderRadius: fortuneTheme.radius.full,
                    borderWidth: 1,
                    borderColor: isSelected ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.border,
                    backgroundColor: isSelected ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.surfaceSecondary,
                    opacity: pressed ? 0.7 : 1,
                  })}
                >
                  <AppText
                    variant="labelSmall"
                    color={isSelected ? fortuneTheme.colors.ctaForeground : fortuneTheme.colors.textSecondary}
                  >
                    {slot}
                  </AppText>
                </Pressable>
              );
            })}
          </View>
        </View>

        {/* MBTI — 칩 선택 */}
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
            MBTI
          </AppText>
          <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 6 }}>
            {["INTJ", "INTP", "ENTJ", "ENTP", "INFJ", "INFP", "ENFJ", "ENFP", "ISTJ", "ISFJ", "ESTJ", "ESFJ", "ISTP", "ISFP", "ESTP", "ESFP", "모름"].map((type) => {
              const isSelected = mbti === type || (type === "모름" && mbti === "");
              return (
                <Pressable
                  key={type}
                  onPress={() => setMbti(type === "모름" ? "" : type)}
                  style={({ pressed }) => ({
                    paddingHorizontal: 12,
                    paddingVertical: 8,
                    borderRadius: fortuneTheme.radius.full,
                    borderWidth: 1,
                    borderColor: isSelected ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.border,
                    backgroundColor: isSelected ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.surfaceSecondary,
                    opacity: pressed ? 0.7 : 1,
                  })}
                >
                  <AppText
                    variant="labelSmall"
                    color={isSelected ? fortuneTheme.colors.ctaForeground : fortuneTheme.colors.textSecondary}
                  >
                    {type}
                  </AppText>
                </Pressable>
              );
            })}
          </View>
        </View>

        {/* 혈액형 — 칩 선택 */}
        <ChipSelector
          label="혈액형"
          options={[
            { label: "A형", value: "A" },
            { label: "B형", value: "B" },
            { label: "O형", value: "O" },
            { label: "AB형", value: "AB" },
            { label: "모름", value: "" },
          ]}
          selected={bloodType}
          onSelect={setBloodType}
        />
        {/* 저장 버튼 (폼 하단) */}
        <PrimaryButton
          disabled={saving}
          onPress={() => void handleSave()}
        >
          {saving ? "저장 중..." : "프로필 저장"}
        </PrimaryButton>
      </View>

    </Screen>
  );
}

function Field({
  label,
  placeholder,
  value,
  onChangeText,
  autoCapitalize,
}: {
  label: string;
  placeholder: string;
  value: string;
  onChangeText: (value: string) => void;
  autoCapitalize?: "none" | "sentences" | "words" | "characters";
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <TextInput
        autoCapitalize={autoCapitalize}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={fortuneTheme.colors.textTertiary}
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.lg,
          borderWidth: 1,
          color: fortuneTheme.colors.textPrimary,
          fontFamily: "System",
          fontSize: 15,
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: 14,
        }}
        value={value}
      />
    </View>
  );
}

function ChipSelector({
  label,
  options,
  selected,
  onSelect,
}: {
  label: string;
  options: readonly { label: string; value: string | null }[];
  selected: string | null;
  onSelect: (value: string) => void;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
        {options.map((option) => {
          const isSelected = selected === option.value;
          return (
            <Pressable
              key={option.label}
              accessibilityRole="button"
              onPress={() => onSelect(option.value ?? "")}
              style={({ pressed }) => ({
                flex: options.length <= 3 ? 1 : undefined,
                paddingVertical: 14,
                paddingHorizontal: 16,
                borderRadius: fortuneTheme.radius.lg,
                borderWidth: 1,
                borderColor: isSelected ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.border,
                backgroundColor: isSelected ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.surfaceSecondary,
                alignItems: "center",
                opacity: pressed ? 0.8 : 1,
              })}
            >
              <AppText
                variant="labelLarge"
                color={isSelected ? fortuneTheme.colors.ctaForeground : fortuneTheme.colors.textPrimary}
              >
                {option.label}
              </AppText>
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

function ReadOnlyField({ label, value }: { label: string; value: string }) {
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.lg,
          borderWidth: 1,
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: 14,
          opacity: 0.6,
        }}
      >
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          {value}
        </AppText>
      </View>
    </View>
  );
}
