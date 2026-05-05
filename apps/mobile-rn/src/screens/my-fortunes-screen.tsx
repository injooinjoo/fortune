/**
 * PR-B3: "내 운세" — 사용자가 본 모든 운세 결과 모음.
 *
 * 디자인:
 * - 데이터 신축 X — 기존 chat_messages 의 embedded-result 메시지를 그대로 쿼리
 *   (audit Task 2 결정)
 * - 시간 역순 (최근 상단)
 * - 탭 → 기존 /result/[resultKind]?payload=... 라우트 재사용
 * - 빈 상태: 안내 멘트만 — 신규 사용자에게 강요하는 surface 가 안 됨
 *
 * Out of MVP (Round 3 결정):
 * - 삭제 / 공유 / 북마크 / 카테고리 필터 — 향후 별도 plan
 */

import { useEffect, useState } from 'react';

import { Pressable, ScrollView, View } from 'react-native';
import { router, type Href } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { type ChatShellEmbeddedResultMessage } from '../lib/chat-shell';
import { loadAllEmbeddedResults } from '../lib/chat-db';
import { fortuneTheme } from '../lib/theme';
import { findCatalogEntry } from '@fortune/product-contracts';

interface VaultEntry {
  characterId: string;
  message: ChatShellEmbeddedResultMessage;
  createdAt: number;
}

function formatRelativeDate(timestamp: number): string {
  const now = Date.now();
  const diff = now - timestamp;
  const day = 1000 * 60 * 60 * 24;

  if (diff < day) return '오늘';
  if (diff < 2 * day) return '어제';
  if (diff < 7 * day) return `${Math.floor(diff / day)}일 전`;

  const date = new Date(timestamp);
  return `${date.getFullYear()}.${(date.getMonth() + 1).toString().padStart(2, '0')}.${date.getDate().toString().padStart(2, '0')}`;
}

export function MyFortunesScreen() {
  const [entries, setEntries] = useState<VaultEntry[] | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const rows = await loadAllEmbeddedResults(200);
      if (cancelled) return;
      const filtered = rows.filter(
        (r): r is VaultEntry =>
          r.message.kind === 'embedded-result',
      );
      setEntries(filtered);
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <Screen header={<RouteBackHeader fallbackHref={'/profile' as Href} label="돌아가기" />}>
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <AppText variant="displaySmall">내 운세</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          이전에 본 운세 결과를 다시 볼 수 있어요.
        </AppText>
      </View>

      {entries === null ? (
        <Card style={{ marginTop: fortuneTheme.spacing.md }}>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            불러오는 중...
          </AppText>
        </Card>
      ) : entries.length === 0 ? (
        <Card style={{ marginTop: fortuneTheme.spacing.md, gap: 4 }}>
          <AppText variant="labelLarge">아직 본 운세가 없어요</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            채팅에서 운세를 본 뒤 다시 와봐.
          </AppText>
        </Card>
      ) : (
        <ScrollView
          style={{ marginTop: fortuneTheme.spacing.md }}
          contentContainerStyle={{ gap: fortuneTheme.spacing.sm }}
        >
          {entries.map((entry, idx) => {
            const catalogEntry = findCatalogEntry(entry.message.fortuneType);
            const displayName =
              catalogEntry?.displayName ?? entry.message.title ?? entry.message.fortuneType;

            return (
              <Pressable
                key={`${entry.message.id}-${idx}`}
                accessibilityRole="button"
                accessibilityLabel={`${displayName} 결과 다시 보기`}
                onPress={() => {
                  // 기존 /result/[resultKind] viewer 재사용 — payload 그대로 전달.
                  const payloadParam = encodeURIComponent(
                    JSON.stringify(entry.message.payload),
                  );
                  router.push(
                    `/result/${entry.message.resultKind}?payload=${payloadParam}` as Href,
                  );
                }}
                style={({ pressed }) => ({
                  backgroundColor: fortuneTheme.colors.surface,
                  borderRadius: fortuneTheme.radius.lg,
                  borderColor: fortuneTheme.colors.border,
                  borderWidth: 1,
                  padding: fortuneTheme.spacing.sm,
                  opacity: pressed ? 0.84 : 1,
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: fortuneTheme.spacing.sm,
                })}
              >
                <View style={{ flex: 1, gap: 2 }}>
                  <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
                    {displayName}
                  </AppText>
                  {catalogEntry?.shortDesc ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {catalogEntry.shortDesc}
                    </AppText>
                  ) : null}
                </View>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                  {formatRelativeDate(entry.createdAt)}
                </AppText>
              </Pressable>
            );
          })}
        </ScrollView>
      )}
    </Screen>
  );
}
