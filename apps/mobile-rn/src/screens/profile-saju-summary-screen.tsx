import { useCallback, useEffect, useState } from "react";
import { ActivityIndicator, Pressable, View, type ViewStyle } from "react-native";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { RouteBackHeader } from "../components/route-back-header";
import { Screen } from "../components/screen";
import { captureError } from "../lib/error-reporting";
import { getSajuData, type SajuData } from "../lib/saju-remote";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

/* ────────────────────────────────────────────
 * Saju element color mapping (五行)
 * ──────────────────────────────────────────── */

const ELEMENT_COLORS: Record<string, string> = {
  木: "#4A90D9",
  火: "#D94A4A",
  土: "#D9A84A",
  金: "#C0C0C0",
  水: "#4A4AD9",
};

const PILLAR_COLORS = ["#4A90D9", "#3DB56E", "#D94A4A", "#9B59B6"];

type SajuPillar = {
  label: string;
  heavenlyStem: string;
  earthlyBranch: string;
  color: string;
};

/* ────────────────────────────────────────────
 * Helpers — build pillars from API data
 * ──────────────────────────────────────────── */

function buildPillarsFromData(data: SajuData): SajuPillar[] {
  return [
    {
      label: "년주",
      heavenlyStem: data.year_stem_hanja,
      earthlyBranch: data.year_branch_hanja,
      color: PILLAR_COLORS[0],
    },
    {
      label: "월주",
      heavenlyStem: data.month_stem_hanja,
      earthlyBranch: data.month_branch_hanja,
      color: PILLAR_COLORS[1],
    },
    {
      label: "일주",
      heavenlyStem: data.day_stem_hanja,
      earthlyBranch: data.day_branch_hanja,
      color: PILLAR_COLORS[2],
    },
    {
      label: "시주",
      heavenlyStem: data.hour_stem_hanja ?? "?",
      earthlyBranch: data.hour_branch_hanja ?? "?",
      color: PILLAR_COLORS[3],
    },
  ];
}

type OhaengWeight = { element: string; label: string; color: string; weight: number };

function buildOhaengFromData(data: SajuData): OhaengWeight[] {
  const balance = data.element_balance;
  const total =
    (balance.목 + balance.화 + balance.토 + balance.금 + balance.수) || 1;

  const LABELS: Record<string, string> = {
    火: "화",
    木: "목",
    土: "토",
    金: "금",
    水: "수",
  };

  const ELEMENT_KEYS: { hanja: string; korean: keyof typeof balance }[] = [
    { hanja: "火", korean: "화" },
    { hanja: "木", korean: "목" },
    { hanja: "土", korean: "토" },
    { hanja: "金", korean: "금" },
    { hanja: "水", korean: "수" },
  ];

  return ELEMENT_KEYS.map(({ hanja, korean }) => ({
    element: hanja,
    label: LABELS[hanja],
    color: ELEMENT_COLORS[hanja],
    weight: balance[korean] / total,
  }));
}

function formatBirthDisplay(birthDate: string, birthTime: string): string {
  // birthDate is stored as "YYYY-MM-DD" or "YYYYMMDD" or Korean format
  const cleaned = birthDate.replace(/[-./]/g, "");
  if (cleaned.length >= 8) {
    const y = cleaned.slice(0, 4);
    const m = cleaned.slice(4, 6);
    const d = cleaned.slice(6, 8);
    const time = birthTime || "00:00";
    return `${y}년 ${parseInt(m, 10)}월 ${parseInt(d, 10)}일 ${time}`;
  }
  return `${birthDate} ${birthTime || ""}`.trim();
}

/* ────────────────────────────────────────────
 * Heavenly stem / Earthly branch descriptions
 * ──────────────────────────────────────────── */

const STEM_DESC: Record<string, { name: string; element: string; desc: string }> = {
  甲: { name: "갑목", element: "木", desc: "큰 나무의 기운. 곧고 강직하며 성장을 상징합니다." },
  乙: { name: "을목", element: "木", desc: "풀과 꽃의 기운. 유연하고 부드러우며 적응력이 뛰어납니다." },
  丙: { name: "병화", element: "火", desc: "태양의 기운. 밝고 열정적이며 리더십이 있습니다." },
  丁: { name: "정화", element: "火", desc: "촛불의 기운. 섬세하고 따뜻하며 내면이 깊습니다." },
  戊: { name: "무토", element: "土", desc: "산의 기운. 안정적이고 신뢰감을 줍니다." },
  己: { name: "기토", element: "土", desc: "대지의 기운. 포용력이 넓고 실용적입니다." },
  庚: { name: "경금", element: "金", desc: "강철의 기운. 결단력이 있고 정의롭습니다." },
  辛: { name: "신금", element: "金", desc: "보석의 기운. 섬세하고 완벽을 추구합니다." },
  壬: { name: "임수", element: "水", desc: "바다의 기운. 지혜롭고 큰 그림을 봅니다." },
  癸: { name: "계수", element: "水", desc: "비의 기운. 감성이 풍부하고 직관력이 뛰어납니다." },
};

const BRANCH_DESC: Record<string, { name: string; animal: string; desc: string }> = {
  子: { name: "자", animal: "쥐", desc: "영리하고 적응력이 뛰어나며 기회를 잘 포착합니다." },
  丑: { name: "축", animal: "소", desc: "성실하고 인내심이 강하며 묵묵히 목표를 이룹니다." },
  寅: { name: "인", animal: "호랑이", desc: "용감하고 독립적이며 카리스마가 있습니다." },
  卯: { name: "묘", animal: "토끼", desc: "온화하고 세심하며 예술적 감각이 있습니다." },
  辰: { name: "진", animal: "용", desc: "야망이 크고 에너지가 넘치며 창의적입니다." },
  巳: { name: "사", animal: "뱀", desc: "지혜롭고 직관적이며 깊은 통찰력을 가집니다." },
  午: { name: "오", animal: "말", desc: "활동적이고 자유로우며 열정이 넘칩니다." },
  未: { name: "미", animal: "양", desc: "부드럽고 창의적이며 예술적 재능이 있습니다." },
  申: { name: "신", animal: "원숭이", desc: "똑똑하고 재치 있으며 문제 해결 능력이 뛰어납니다." },
  酉: { name: "유", animal: "닭", desc: "정확하고 성실하며 분석력이 뛰어납니다." },
  戌: { name: "술", animal: "개", desc: "충직하고 정의로우며 믿음직합니다." },
  亥: { name: "해", animal: "돼지", desc: "너그럽고 낙천적이며 복이 많습니다." },
};

/* ────────────────────────────────────────────
 * Sub-components
 * ──────────────────────────────────────────── */

function SajuPillarBox({
  pillar,
  isSelected,
  onPress,
}: {
  pillar: SajuPillar;
  isSelected: boolean;
  onPress: () => void;
}) {
  const characterBoxStyle = (bg: string): ViewStyle => ({
    width: 52,
    height: 52,
    borderRadius: fortuneTheme.radius.md,
    backgroundColor: bg,
    alignItems: "center",
    justifyContent: "center",
  });

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        alignItems: "center",
        gap: 6,
        flex: 1,
        opacity: pressed ? 0.7 : 1,
        borderWidth: isSelected ? 2 : 0,
        borderColor: isSelected ? pillar.color : "transparent",
        borderRadius: fortuneTheme.radius.lg,
        paddingVertical: 6,
      })}
    >
      <AppText variant="labelSmall" color={isSelected ? pillar.color : fortuneTheme.colors.textSecondary}>
        {pillar.label}
      </AppText>
      <View style={characterBoxStyle(pillar.color)}>
        <AppText
          variant="heading2"
          color="#FFFFFF"
          style={{ textShadowColor: "rgba(0,0,0,0.3)", textShadowRadius: 2 }}
        >
          {pillar.heavenlyStem}
        </AppText>
      </View>
      <View style={characterBoxStyle(`${pillar.color}99`)}>
        <AppText
          variant="heading2"
          color="#FFFFFF"
          style={{ textShadowColor: "rgba(0,0,0,0.3)", textShadowRadius: 2 }}
        >
          {pillar.earthlyBranch}
        </AppText>
      </View>
    </Pressable>
  );
}

function PillarDetail({ pillar }: { pillar: SajuPillar }) {
  const stemInfo = STEM_DESC[pillar.heavenlyStem];
  const branchInfo = BRANCH_DESC[pillar.earthlyBranch];

  return (
    <View
      style={{
        backgroundColor: `${pillar.color}15`,
        borderRadius: fortuneTheme.radius.md,
        padding: 14,
        gap: 12,
        marginTop: 8,
      }}
    >
      <AppText variant="labelLarge" color={pillar.color}>
        {pillar.label} 상세
      </AppText>

      {stemInfo ? (
        <View style={{ gap: 4 }}>
          <AppText variant="bodyMedium" style={{ fontWeight: "700" }}>
            천간 · {pillar.heavenlyStem} ({stemInfo.name})
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {stemInfo.desc}
          </AppText>
        </View>
      ) : null}

      {branchInfo ? (
        <View style={{ gap: 4 }}>
          <AppText variant="bodyMedium" style={{ fontWeight: "700" }}>
            지지 · {pillar.earthlyBranch} ({branchInfo.name} · {branchInfo.animal}띠)
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {branchInfo.desc}
          </AppText>
        </View>
      ) : null}
    </View>
  );
}

function OhaengBar({ item }: { item: OhaengWeight }) {
  const barWidth = Math.max(item.weight * 100, 12);
  return (
    <View
      style={{
        flexDirection: "row",
        alignItems: "center",
        gap: 10,
      }}
    >
      <View style={{ width: 28, alignItems: "center" }}>
        <AppText variant="labelMedium" color={item.color}>
          {item.label}
        </AppText>
      </View>
      <View
        style={{
          flex: 1,
          height: 22,
          borderRadius: fortuneTheme.radius.full,
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          overflow: "hidden",
        }}
      >
        <View
          style={{
            width: `${barWidth}%`,
            height: "100%",
            borderRadius: fortuneTheme.radius.full,
            backgroundColor: item.color,
            opacity: 0.85,
          }}
        />
      </View>
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textSecondary}
        style={{ width: 32, textAlign: "right" }}
      >
        {Math.round(item.weight * 100)}%
      </AppText>
    </View>
  );
}

function EmptyBirthPrompt() {
  return (
    <Card>
      <View style={{ alignItems: "center", paddingVertical: 24, gap: 12 }}>
        <AppText variant="heading3" color={fortuneTheme.colors.textSecondary}>
          출생 정보가 필요해요
        </AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: "center" }}
        >
          사주 요약을 보려면 프로필에서{"\n"}생년월일과 태어난 시간을 입력해
          주세요.
        </AppText>
      </View>
    </Card>
  );
}

/* ────────────────────────────────────────────
 * Loading / Error states
 * ──────────────────────────────────────────── */

function LoadingState() {
  return (
    <Card>
      <View style={{ alignItems: "center", paddingVertical: 36, gap: 14 }}>
        <ActivityIndicator size="large" color={fortuneTheme.colors.ctaBackground} />
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          사주 데이터를 불러오는 중...
        </AppText>
      </View>
    </Card>
  );
}

function ErrorState({ message, onRetry }: { message: string; onRetry: () => void }) {
  return (
    <Card>
      <View style={{ alignItems: "center", paddingVertical: 24, gap: 12 }}>
        <AppText variant="heading3" color={fortuneTheme.colors.textSecondary}>
          사주 데이터를 불러오지 못했어요
        </AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: "center" }}
        >
          {message}
        </AppText>
        <Pressable
          onPress={onRetry}
          style={({ pressed }) => ({
            paddingHorizontal: 24,
            paddingVertical: 10,
            borderRadius: fortuneTheme.radius.md,
            backgroundColor: fortuneTheme.colors.ctaBackground,
            opacity: pressed ? 0.7 : 1,
            marginTop: 4,
          })}
        >
          <AppText variant="labelMedium" color="#FFFFFF">
            다시 시도
          </AppText>
        </Pressable>
      </View>
    </Card>
  );
}

/* ────────────────────────────────────────────
 * Main screen
 * ──────────────────────────────────────────── */

type FetchStatus = "idle" | "loading" | "success" | "error";

export function ProfileSajuSummaryScreen() {
  const { state } = useMobileAppState();
  const { session } = useAppBootstrap();
  const birthReady = Boolean(state.profile.birthDate.trim());
  const [selectedPillarIndex, setSelectedPillarIndex] = useState<number | null>(null);

  const [sajuData, setSajuData] = useState<SajuData | null>(null);
  const [fetchStatus, setFetchStatus] = useState<FetchStatus>("idle");
  const [errorMessage, setErrorMessage] = useState("");
  const [retryTrigger, setRetryTrigger] = useState(0);

  const birthDate = state.profile.birthDate;
  const birthTime = state.profile.birthTime;

  useEffect(() => {
    if (!birthReady || !session) {
      return;
    }

    let cancelled = false;

    async function load() {
      setFetchStatus("loading");
      setErrorMessage("");

      try {
        // On retry (retryTrigger > 0) bypass cache by fetching fresh data
        const data =
          retryTrigger > 0
            ? await (await import("../lib/saju-remote")).fetchSajuData(session!, birthDate, birthTime)
            : await getSajuData(session!, birthDate, birthTime);

        if (!cancelled) {
          setSajuData(data);
          setFetchStatus("success");
        }
      } catch (error) {
        if (!cancelled) {
          const msg =
            error instanceof Error
              ? error.message
              : "알 수 없는 오류가 발생했습니다.";
          setErrorMessage(msg);
          setFetchStatus("error");
          captureError(error, { surface: "saju-summary:fetch" }).catch(
            () => undefined,
          );
        }
      }
    }

    void load();

    return () => {
      cancelled = true;
    };
  }, [birthReady, session, birthDate, birthTime, retryTrigger]);

  const handleRetryPress = useCallback(() => {
    setSajuData(null);
    setRetryTrigger((prev) => prev + 1);
  }, []);

  if (!birthReady) {
    return (
      <Screen
        header={
          <RouteBackHeader fallbackHref="/profile" label="사주 요약" />
        }
      >
        <EmptyBirthPrompt />
      </Screen>
    );
  }

  if (fetchStatus === "idle" || fetchStatus === "loading") {
    return (
      <Screen
        header={<RouteBackHeader fallbackHref="/profile" label="사주 요약" />}
      >
        <LoadingState />
      </Screen>
    );
  }

  if (fetchStatus === "error" || !sajuData) {
    return (
      <Screen
        header={<RouteBackHeader fallbackHref="/profile" label="사주 요약" />}
      >
        <ErrorState
          message={errorMessage || "사주 데이터를 가져올 수 없습니다."}
          onRetry={handleRetryPress}
        />
      </Screen>
    );
  }

  const pillars = buildPillarsFromData(sajuData);
  const ohaeng = buildOhaengFromData(sajuData);
  const personality =
    sajuData.personality_traits ||
    "사주 정보를 기반으로 성격 분석을 준비하고 있습니다.";
  const birthDisplay = formatBirthDisplay(birthDate, birthTime);

  return (
    <Screen
      header={<RouteBackHeader fallbackHref="/profile" label="사주 요약" />}
    >
      {/* -- 사주 팔자 -- */}
      <Card>
        <AppText variant="heading4">사주 팔자</AppText>

        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {birthDisplay}
        </AppText>

        <View
          style={{
            flexDirection: "row",
            justifyContent: "space-between",
            paddingTop: 8,
          }}
        >
          {pillars.map((p, i) => (
            <SajuPillarBox
              key={p.label}
              pillar={p}
              isSelected={selectedPillarIndex === i}
              onPress={() => setSelectedPillarIndex(selectedPillarIndex === i ? null : i)}
            />
          ))}
        </View>

        {/* 선택된 주의 상세 설명 */}
        {selectedPillarIndex != null ? (
          <PillarDetail pillar={pillars[selectedPillarIndex]} />
        ) : (
          <AppText
            variant="caption"
            color={fortuneTheme.colors.textTertiary}
            style={{ textAlign: "center", marginTop: 4 }}
          >
            주를 탭하면 상세 설명을 볼 수 있어요
          </AppText>
        )}
      </Card>

      {/* -- 오행 분석 -- */}
      <Card>
        <AppText variant="heading4">오행 분석</AppText>

        <View style={{ gap: 8, paddingTop: 4 }}>
          {ohaeng.map((item) => (
            <OhaengBar key={item.element} item={item} />
          ))}
        </View>

        {sajuData.dominant_element || sajuData.weak_element ? (
          <View style={{ paddingTop: 8, gap: 4 }}>
            {sajuData.dominant_element ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                강한 오행: {sajuData.dominant_element}
              </AppText>
            ) : null}
            {sajuData.weak_element ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                약한 오행: {sajuData.weak_element}
              </AppText>
            ) : null}
          </View>
        ) : null}
      </Card>

      {/* -- 성격 특성 -- */}
      <Card>
        <AppText variant="heading4">성격 특성</AppText>

        <AppText
          variant="bodyMedium"
          color={fortuneTheme.colors.textSecondary}
          style={{ lineHeight: 24 }}
        >
          {personality}
        </AppText>
      </Card>

      {/* -- 인사이트 요약 (if available from LLM) -- */}
      {sajuData.fortune_summary ? (
        <Card>
          <AppText variant="heading4">인사이트 요약</AppText>

          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 24 }}
          >
            {sajuData.fortune_summary}
          </AppText>
        </Card>
      ) : null}

      {/* -- 보완 방법 (if available) -- */}
      {sajuData.enhancement_method ? (
        <Card>
          <AppText variant="heading4">오행 보완법</AppText>

          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 24 }}
          >
            {sajuData.enhancement_method}
          </AppText>
        </Card>
      ) : null}
    </Screen>
  );
}
