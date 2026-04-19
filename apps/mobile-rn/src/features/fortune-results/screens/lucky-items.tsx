import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { Chip } from '../../../components/chip';
import { fortuneTheme } from '../../../lib/theme';
import { HeroLucky } from '../heroes';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  InsetQuote,
  KeywordPills,
  SectionCard,
  Timeline,
} from '../primitives';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  Type helpers for safe access to raw API response                   */
/* ------------------------------------------------------------------ */

type R = Record<string, unknown>;

function obj(val: unknown): R {
  return val != null && typeof val === 'object' && !Array.isArray(val)
    ? (val as R)
    : {};
}

function str(val: unknown, fallback = ''): string {
  return typeof val === 'string' && val.trim() ? val.trim() : fallback;
}

function num(val: unknown, fallback = 0): number {
  if (typeof val === 'number' && !Number.isNaN(val)) return val;
  if (typeof val === 'string') {
    const n = Number(val);
    if (!Number.isNaN(n)) return n;
  }
  return fallback;
}

function arr(val: unknown): unknown[] {
  return Array.isArray(val) ? val : [];
}

function strArr(val: unknown): string[] {
  return arr(val)
    .map((v) => str(v))
    .filter(Boolean);
}

function numArr(val: unknown): number[] {
  return arr(val)
    .map((v) => num(v, -1))
    .filter((n) => n >= 0);
}


/* ------------------------------------------------------------------ */
/*  Category emoji mapping                                             */
/* ------------------------------------------------------------------ */

const CATEGORY_EMOJI: Record<string, string> = {
  color: '🎨',
  fashion: '👔',
  food: '🍽️',
  number: '🔢',
  place: '🧭',
  game: '🎮',
  shopping: '🛍️',
  health: '💪',
  lifestyle: '🏠',
};

/* ------------------------------------------------------------------ */
/*  Item card with reason                                              */
/* ------------------------------------------------------------------ */

function ItemDetailCard({
  emoji,
  name,
  reason,
}: {
  emoji: string;
  name: string;
  reason: string;
}) {
  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        gap: fortuneTheme.spacing.xs,
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
        <AppText variant="emojiInline">{emoji}</AppText>
        <AppText variant="labelLarge">{name}</AppText>
      </View>
      {reason ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {reason}
        </AppText>
      ) : null}
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  LuckyItemsResult                                                   */
/* ------------------------------------------------------------------ */

export function LuckyItemsResult(props: FortuneResultComponentProps) {
  const _meta = resultMetadataByKind['lucky-items'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Extract structured API data ---

  // Top-level
  const title = str(raw.title, result.summary || '오늘의 행운 아이템');
  const summary = str(raw.summary, str(raw.lucky_summary, ''));
  const content = str(raw.content);
  const keyword = str(raw.keyword);
  const element = str(raw.element);
  const score = num(raw.score, result.score ?? 78);
  const todayTip = str(raw.todayTip);
  const selectedCategory = str(raw.selectedCategory, 'fashion');
  const selectedCategoryLabel = str(raw.selectedCategoryLabel, '');

  // Color
  const colorRaw = raw.color;
  const colorStr = typeof colorRaw === 'string' ? colorRaw : '';
  const colorDetail = obj(raw.colorDetail);
  const colorPrimary = str(colorDetail.primary, colorStr);
  const colorSecondary = str(colorDetail.secondary);
  const colorReason = str(colorDetail.reason);

  // Fashion
  const fashionItems = strArr(raw.fashion);
  const fashionDetail = arr(raw.fashionDetail);

  // Numbers
  const numbers = numArr(raw.numbers);
  const numbersExplanation = str(raw.numbersExplanation);
  const avoidNumbers = numArr(raw.avoidNumbers);

  // Food
  const foodItems = strArr(raw.food);
  const foodDetail = arr(raw.foodDetail);

  // Jewelry
  const jewelryItems = strArr(raw.jewelry);
  const jewelryDetail = arr(raw.jewelryDetail);

  // Material
  const materialItems = strArr(raw.material);
  const materialDetail = arr(raw.materialDetail);

  // Direction
  const direction = str(raw.direction, '');
  const directionDetail = obj(raw.directionDetail);
  const directionCompass = str(raw.directionCompass, str(directionDetail.compass, direction));
  const directionReason = str(directionDetail.reason);

  // Places
  const placesItems = strArr(raw.places);
  const placesDetail = arr(raw.placesDetail);

  // Relationships
  const relationshipsItems = strArr(raw.relationships);
  const relationshipsDetail = arr(raw.relationshipsDetail);

  // Advice
  const adviceStr = str(raw.advice, str(raw.lucky_advice, ''));
  const adviceDetail = obj(raw.adviceDetail);
  const adviceMorning = str(adviceDetail.morning);
  const adviceAfternoon = str(adviceDetail.afternoon);
  const adviceEvening = str(adviceDetail.evening);
  const adviceOverall = str(adviceDetail.overall, adviceStr);
  const hasTimeAdvice = adviceMorning || adviceAfternoon || adviceEvening;

  // Hero chips
  const heroChips = keyword
    ? keyword.split(',').map((s) => s.trim()).filter(Boolean)
    : result.contextTags.length > 0
      ? result.contextTags
      : [element, selectedCategoryLabel].filter(Boolean);

  const categoryEmoji = CATEGORY_EMOJI[selectedCategory] ?? '🍀';

  // Build up to 6 hero tiles from the most compelling item categories.
  const heroTiles: Array<{ emoji: string; label: string }> = [
    ...(colorPrimary ? [{ emoji: '🎨', label: colorPrimary }] : []),
    ...(fashionItems[0] ? [{ emoji: '👔', label: fashionItems[0] }] : []),
    ...(foodItems[0] ? [{ emoji: '🍽️', label: foodItems[0] }] : []),
    ...(numbers[0] !== undefined ? [{ emoji: '🔢', label: String(numbers[0]) }] : []),
    ...(directionCompass ? [{ emoji: '🧭', label: directionCompass }] : []),
    ...(jewelryItems[0] ? [{ emoji: '💎', label: jewelryItems[0] }] : []),
    ...(placesItems[0] ? [{ emoji: '📍', label: placesItems[0] }] : []),
    ...(materialItems[0] ? [{ emoji: '🧶', label: materialItems[0] }] : []),
  ].slice(0, 6);

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Section 1: Hero — Signature 3x2 lucky-tile grid              */}
      {/* ============================================================ */}
      <HeroLucky
        items={heroTiles}
        luckyScore={score}
        description={summary || title}
      />

      {element || heroChips.length > 0 ? (
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: fortuneTheme.spacing.xs,
          }}
        >
          {element ? <Chip label={`오행: ${element}`} tone="accent" /> : null}
          {heroChips.map((chip) => (
            <Chip key={chip} label={chip} />
          ))}
        </View>
      ) : null}

      {/* ============================================================ */}
      {/*  Section 2: Content — Analysis narrative                      */}
      {/* ============================================================ */}
      {(content || summary) && (
        <Card style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">오행 분석</AppText>
          <AppText
            variant="oracleBody"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 28 }}
          >
            {content || summary}
          </AppText>
        </Card>
      )}

      {/* ============================================================ */}
      {/*  Section 3: 행운의 색상                                        */}
      {/* ============================================================ */}
      {hasRaw && colorPrimary && (
        <SectionCard title="행운의 색상" description="오늘 어울리는 색상입니다.">
          <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.md, alignItems: 'center' }}>
            <View
              style={{
                flexDirection: 'row',
                gap: fortuneTheme.spacing.sm,
                alignItems: 'center',
              }}
            >
              <View
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: fortuneTheme.radius.full,
                  backgroundColor: fortuneTheme.colors.ctaBackground,
                  borderWidth: 2,
                  borderColor: fortuneTheme.colors.border,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <AppText variant="emojiInline">🎨</AppText>
              </View>
              <View style={{ gap: 2 }}>
                <AppText variant="heading4">{colorPrimary}</AppText>
                {colorSecondary ? (
                  <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                    서브: {colorSecondary}
                  </AppText>
                ) : null}
              </View>
            </View>
          </View>
          {colorReason ? <InsetQuote text={colorReason} /> : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 4: 패션 아이템                                        */}
      {/* ============================================================ */}
      {hasRaw && fashionItems.length > 0 && (
        <SectionCard title="패션 아이템" description="오늘 입으면 좋은 아이템">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {fashionDetail.length > 0
              ? fashionDetail.map((item, i) => {
                  const d = obj(item);
                  return (
                    <ItemDetailCard
                      key={`fashion-${i}`}
                      emoji="👔"
                      name={str(d.item, fashionItems[i] ?? '')}
                      reason={str(d.reason)}
                    />
                  );
                })
              : fashionItems.map((item, i) => (
                  <ItemDetailCard key={`fashion-${i}`} emoji="👔" name={item} reason="" />
                ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 5: 행운의 숫자                                        */}
      {/* ============================================================ */}
      {hasRaw && numbers.length > 0 && (
        <SectionCard title="행운의 숫자" description="오늘의 행운 넘버">
          <View
            style={{
              flexDirection: 'row',
              gap: fortuneTheme.spacing.sm,
              justifyContent: 'center',
            }}
          >
            {numbers.map((n, i) => (
              <View
                key={`num-${i}`}
                style={{
                  backgroundColor: fortuneTheme.colors.ctaBackground,
                  borderRadius: fortuneTheme.radius.full,
                  width: 52,
                  height: 52,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <AppText variant="heading3" color={fortuneTheme.colors.ctaForeground}>
                  {n}
                </AppText>
              </View>
            ))}
          </View>
          {numbersExplanation ? (
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ textAlign: 'center', marginTop: fortuneTheme.spacing.xs }}
            >
              {numbersExplanation}
            </AppText>
          ) : null}
          {avoidNumbers.length > 0 && (
            <View
              style={{
                flexDirection: 'row',
                gap: fortuneTheme.spacing.xs,
                justifyContent: 'center',
                marginTop: fortuneTheme.spacing.sm,
              }}
            >
              <AppText variant="labelMedium" color={fortuneTheme.colors.error}>
                피해야 할 숫자:
              </AppText>
              {avoidNumbers.map((n, i) => (
                <View
                  key={`avoid-${i}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    borderRadius: fortuneTheme.radius.full,
                    borderWidth: 1,
                    borderColor: fortuneTheme.colors.error,
                    width: 32,
                    height: 32,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <AppText variant="labelLarge" color={fortuneTheme.colors.error}>
                    {n}
                  </AppText>
                </View>
              ))}
            </View>
          )}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 6: 행운의 음식                                        */}
      {/* ============================================================ */}
      {hasRaw && foodItems.length > 0 && (
        <SectionCard title="행운의 음식" description="오늘 먹으면 좋은 음식">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {foodDetail.length > 0
              ? foodDetail.map((item, i) => {
                  const d = obj(item);
                  const timing = str(d.timing);
                  return (
                    <Card
                      key={`food-${i}`}
                      style={{
                        backgroundColor: fortuneTheme.colors.surfaceSecondary,
                        gap: fortuneTheme.spacing.xs,
                      }}
                    >
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                        <AppText variant="emojiInline">🍽️</AppText>
                        <AppText variant="labelLarge">{str(d.item, foodItems[i] ?? '')}</AppText>
                        {timing ? <Chip label={timing} /> : null}
                      </View>
                      {str(d.reason) ? (
                        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                          {str(d.reason)}
                        </AppText>
                      ) : null}
                    </Card>
                  );
                })
              : foodItems.map((item, i) => (
                  <ItemDetailCard key={`food-${i}`} emoji="🍽️" name={item} reason="" />
                ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 7: 보석/액세서리                                      */}
      {/* ============================================================ */}
      {hasRaw && jewelryItems.length > 0 && (
        <SectionCard title="보석 / 액세서리" description="에너지를 보완하는 아이템">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {jewelryDetail.length > 0
              ? jewelryDetail.map((item, i) => {
                  const d = obj(item);
                  return (
                    <ItemDetailCard
                      key={`jewelry-${i}`}
                      emoji="💎"
                      name={str(d.item, jewelryItems[i] ?? '')}
                      reason={str(d.reason)}
                    />
                  );
                })
              : jewelryItems.map((item, i) => (
                  <ItemDetailCard key={`jewelry-${i}`} emoji="💎" name={item} reason="" />
                ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 7.5: 소재/재질                                        */}
      {/* ============================================================ */}
      {hasRaw && materialItems.length > 0 && (
        <SectionCard title="행운의 소재" description="오늘과 잘 맞는 재질">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {materialDetail.length > 0
              ? materialDetail.map((item, i) => {
                  const d = obj(item);
                  return (
                    <ItemDetailCard
                      key={`material-${i}`}
                      emoji="🧶"
                      name={str(d.item, materialItems[i] ?? '')}
                      reason={str(d.reason)}
                    />
                  );
                })
              : materialItems.map((item, i) => (
                  <ItemDetailCard key={`material-${i}`} emoji="🧶" name={item} reason="" />
                ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 8: 방향 + 장소                                        */}
      {/* ============================================================ */}
      {hasRaw && (directionCompass || placesItems.length > 0) && (
        <SectionCard title="방향 / 장소" description="행운의 방위와 추천 장소">
          {directionCompass && (
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.backgroundTertiary,
                alignItems: 'center',
                gap: fortuneTheme.spacing.sm,
                paddingVertical: fortuneTheme.spacing.lg,
              }}
            >
              <AppText variant="emojiHero">🧭</AppText>
              <AppText variant="heading2">{directionCompass}</AppText>
              {directionReason ? (
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                  style={{ textAlign: 'center', paddingHorizontal: fortuneTheme.spacing.md }}
                >
                  {directionReason}
                </AppText>
              ) : null}
            </Card>
          )}

          {placesDetail.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.sm }}>
              {placesDetail.map((item, i) => {
                const d = obj(item);
                const placeName = str(d.place, placesItems[i] ?? '');
                const category = str(d.category);
                const reason = str(d.reason);
                const timing = str(d.timing);
                return (
                  <Card
                    key={`place-${i}`}
                    style={{
                      backgroundColor: fortuneTheme.colors.surfaceSecondary,
                      gap: fortuneTheme.spacing.xs,
                    }}
                  >
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                      <AppText variant="emojiInline">📍</AppText>
                      <AppText variant="labelLarge">{placeName}</AppText>
                      {category ? <Chip label={category} /> : null}
                    </View>
                    {reason ? (
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {reason}
                      </AppText>
                    ) : null}
                    {timing ? (
                      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                        추천 시간: {timing}
                      </AppText>
                    ) : null}
                  </Card>
                );
              })}
            </View>
          ) : placesItems.length > 0 ? (
            <KeywordPills keywords={placesItems} />
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 9: 인연                                               */}
      {/* ============================================================ */}
      {hasRaw && relationshipsItems.length > 0 && (
        <SectionCard title="오늘의 인연" description="만나면 좋은 사람 유형">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {relationshipsDetail.length > 0
              ? relationshipsDetail.map((item, i) => {
                  const d = obj(item);
                  return (
                    <ItemDetailCard
                      key={`rel-${i}`}
                      emoji="🤝"
                      name={str(d.type, relationshipsItems[i] ?? '')}
                      reason={str(d.reason)}
                    />
                  );
                })
              : relationshipsItems.map((item, i) => (
                  <ItemDetailCard key={`rel-${i}`} emoji="🤝" name={item} reason="" />
                ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Section 10: 행운 타이밍 — Time-of-day advice                  */}
      {/* ============================================================ */}
      {hasRaw && hasTimeAdvice && (
        <SectionCard title="행운 타이밍" description="시간대별 행운 활용법">
          <Timeline
            items={[
              ...(adviceMorning ? [{ title: '오전', body: adviceMorning, tag: '🌅' }] : []),
              ...(adviceAfternoon ? [{ title: '오후', body: adviceAfternoon, tag: '☀️' }] : []),
              ...(adviceEvening ? [{ title: '저녁', body: adviceEvening, tag: '🌙' }] : []),
            ]}
          />
        </SectionCard>
      )}

      {/* Overall advice */}
      {hasRaw && adviceOverall && !hasTimeAdvice && (
        <SectionCard title="오늘의 조언">
          <InsetQuote text={adviceOverall} />
        </SectionCard>
      )}

      {/* Today tip */}
      {todayTip ? (
        <SectionCard title="핵심 팁">
          <InsetQuote text={todayTip} />
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Fallback sections when no raw data                           */}
      {/* ============================================================ */}
      {!hasRaw && result.highlights.length > 0 && (
        <SectionCard title="핵심 포인트">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}

      {!hasRaw && result.recommendations.length > 0 && (
        <SectionCard title="추천 행동">
          <BulletList items={result.recommendations} />
        </SectionCard>
      )}

      {!hasRaw && result.luckyItems.length > 0 && (
        <SectionCard title="행운 포인트">
          <KeywordPills keywords={result.luckyItems} />
        </SectionCard>
      )}

      {result.specialTip && (
        <SectionCard title="한 줄 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}
