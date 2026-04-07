// Raw corpus fields are only used internally for classification.
// The exported taxonomy only contains safe internal axes and flags.
export interface RankingGenderedTextBlock {
  text?: string;
  raw_html?: string;
}

export interface RankingGenderedItem {
  character_id?: string;
  source_url?: string;
  name?: string;
  creator_name?: string;
  hashtags?: string[];
  summary?: string;
  worldview?: RankingGenderedTextBlock;
  character_introduction?: RankingGenderedTextBlock;
  creator_comment?: RankingGenderedTextBlock;
  story?: string;
  image_urls?: string[];
  stats?: Record<string, unknown>;
  created_at?: string;
  modified_at?: string;
  best_rank?: number;
  appearance_count?: number;
  seen_in_genders?: string[];
  appearances?: Array<Record<string, unknown>>;
  seen_in_periods?: string[];
  [key: string]: unknown;
}

export interface RankingGenderedCorpus {
  scraped_at?: string;
  scope?: {
    genders?: string[];
    periods?: string[];
    [key: string]: unknown;
  };
  ranking_urls?: string[];
  raw_appearance_count?: number;
  unique_character_count?: number;
  failed_count?: number;
  errors?: unknown[];
  items?: RankingGenderedItem[];
  [key: string]: unknown;
}

export interface RankingTaxonomyAxes {
  genre: string;
  worldviewDensity: "low" | "medium" | "high";
  relationshipStart: string;
  attachmentStyle: string;
  flirtCadence: "low" | "medium" | "high" | "bursty";
  conflictPattern: string;
  reassuranceMode: string;
  speechTexture: string;
  dailyHook: string;
  safetyFlags: string[];
}

export interface RankingTaxonomyItem {
  characterId: string;
  axes: RankingTaxonomyAxes;
}

export interface RankingTaxonomyDataset {
  scrapedAt?: string;
  scope: {
    genders: string[];
    periods: string[];
  };
  counts: {
    rawAppearanceCount: number;
    uniqueCharacterCount: number;
    failedCount: number;
  };
  items: RankingTaxonomyItem[];
}

const GENRE_RULES: Array<{ label: string; patterns: RegExp[] }> = [
  {
    label: "school",
    patterns: [/학교/, /학원/, /교실/, /동아리/, /선배/, /후배/, /교복/],
  },
  {
    label: "office",
    patterns: [/회사/, /직장/, /사내/, /부장/, /팀장/, /프로젝트/],
  },
  {
    label: "fantasy",
    patterns: [/마법/, /용/, /기사/, /왕국/, /마왕/, /신전/, /던전/, /정령/],
  },
  {
    label: "historical",
    patterns: [/조선/, /궁궐/, /황실/, /귀족/, /사극/, /왕세자/],
  },
  {
    label: "sci-fi",
    patterns: [/우주/, /로봇/, /미래/, /AI/, /인공지능/, /우주선/, /안드로이드/],
  },
  {
    label: "mystery",
    patterns: [/사건/, /수사/, /추적/, /실종/, /의문/, /비밀/],
  },
  {
    label: "action",
    patterns: [/전투/, /검/, /총/, /훈련/, /임무/, /용병/, /경호/],
  },
  {
    label: "slice-of-life",
    patterns: [/일상/, /산책/, /식사/, /카페/, /생활/, /휴식/],
  },
];

const RELATIONSHIP_START_RULES: Array<{ label: string; patterns: RegExp[] }> = [
  {
    label: "childhood-friends",
    patterns: [/소꿉친구/, /어릴 때/, /어린 시절/, /childhood/],
  },
  {
    label: "slow-burn",
    patterns: [/천천히/, /서서히/, /미묘/, /점점/, /느리게/],
  },
  {
    label: "rivals-to-lovers",
    patterns: [/라이벌/, /앙숙/, /경쟁/, /대립/],
  },
  {
    label: "reunion",
    patterns: [/재회/, /다시 만남/, /오랜만/, /재결합/],
  },
  {
    label: "contract",
    patterns: [/계약/, /위장/, /약혼/, /조건부/],
  },
  {
    label: "first-meeting",
    patterns: [/첫 만남/, /처음 만난/, /첫눈/, /운명/],
  },
];

const ATTACHMENT_RULES: Array<{ label: string; patterns: RegExp[] }> = [
  {
    label: "protective",
    patterns: [/보호/, /지켜/, /돌봐/, /감싸/, /안심/],
  },
  {
    label: "avoidant",
    patterns: [/거리/, /무심/, /혼자/, /피하/, /숨기/],
  },
  {
    label: "anxious",
    patterns: [/집착/, /불안/, /매달/, /확인/, /흔들/],
  },
  {
    label: "push-pull",
    patterns: [/밀당/, /튕김/, /왔다갔다/, /오락가락/],
  },
  {
    label: "secure",
    patterns: [/안정/, /신뢰/, /편안/, /믿음/],
  },
];

const CONFLICT_RULES: Array<{ label: string; patterns: RegExp[] }> = [
  {
    label: "betrayal",
    patterns: [/배신/, /거짓/, /속임/, /배반/],
  },
  {
    label: "jealousy",
    patterns: [/질투/, /시기/],
  },
  {
    label: "misunderstanding",
    patterns: [/오해/, /착각/, /엇갈/],
  },
  {
    label: "distance",
    patterns: [/거리/, /멀어/, /회피/],
  },
  {
    label: "duty",
    patterns: [/책임/, /의무/, /가문/, /소명/],
  },
  {
    label: "secret",
    patterns: [/비밀/, /숨김/, /정체/],
  },
  {
    label: "competition",
    patterns: [/경쟁/, /라이벌/, /승부/],
  },
];

const REASSURANCE_RULES: Array<{ label: string; patterns: RegExp[] }> = [
  {
    label: "direct",
    patterns: [/직접/, /솔직/, /말로/, /분명/],
  },
  {
    label: "playful",
    patterns: [/장난/, /놀리/, /농담/],
  },
  {
    label: "acts-of-service",
    patterns: [/챙겨/, /도와/, /준비/, /데려/, /챙김/],
  },
  {
    label: "quiet-presence",
    patterns: [/곁/, /옆/, /함께/, /같이/],
  },
  {
    label: "protective",
    patterns: [/지켜/, /보호/, /막아/],
  },
  {
    label: "validation",
    patterns: [/괜찮아/, /믿어/, /괜찮지/, /알아/],
  },
];

const SPEECH_RULES: Array<{ label: string; patterns: RegExp[] }> = [
  {
    label: "short",
    patterns: [/짧은 답장/, /짧게/, /간결/, /무심/],
  },
  {
    label: "soft",
    patterns: [/부드럽/, /다정/, /조용/, /따뜻/],
  },
  {
    label: "sharp",
    patterns: [/날카/, /툭/, /차갑/, /냉정/],
  },
  {
    label: "dense",
    patterns: [/길게/, /풍부/, /설명/, /서술/],
  },
  {
    label: "chatty",
    patterns: [/수다/, /말이 많/, /떠들/],
  },
];

const DAILY_HOOK_RULES: Array<{ label: string; patterns: RegExp[] }> = [
  {
    label: "check-in",
    patterns: [/안부/, /보고/, /어땠어/, /오늘 어땠/],
  },
  {
    label: "shared-routine",
    patterns: [/밥/, /식사/, /커피/, /퇴근/, /등교/, /산책/],
  },
  {
    label: "problem-solving",
    patterns: [/고민/, /해결/, /조언/, /정리/],
  },
  {
    label: "teasing",
    patterns: [/놀리/, /장난/, /티격/],
  },
  {
    label: "quiet-presence",
    patterns: [/곁/, /옆/, /같이/, /함께/],
  },
  {
    label: "mission",
    patterns: [/임무/, /훈련/, /전투/, /작전/],
  },
  {
    label: "caregiving",
    patterns: [/챙겨/, /돌봄/, /약/, /간식/],
  },
  {
    label: "study",
    patterns: [/공부/, /과제/, /시험/],
  },
];

function normalizeText(value: unknown): string {
  if (typeof value !== "string") {
    return "";
  }

  return value.trim().replace(/\s+/g, " ").toLowerCase();
}

function textBlocksToString(...blocks: Array<string | undefined>): string {
  return blocks.filter((block) => typeof block === "string" && block.length > 0)
    .join(" ");
}

function patternScore(text: string, patterns: RegExp[]): number {
  return patterns.reduce((score, pattern) => score + (pattern.test(text) ? 1 : 0), 0);
}

function pickLabel(
  text: string,
  rules: Array<{ label: string; patterns: RegExp[] }>,
  fallback: string,
): string {
  let bestLabel = fallback;
  let bestScore = 0;

  for (const rule of rules) {
    const score = patternScore(text, rule.patterns);
    if (score > bestScore) {
      bestLabel = rule.label;
      bestScore = score;
    }
  }

  return bestLabel;
}

function classifyWorldviewDensity(text: string): "low" | "medium" | "high" {
  if (text.length >= 1800) {
    return "high";
  }
  if (text.length >= 800) {
    return "medium";
  }

  return "low";
}

function classifyFlirtCadence(text: string): "low" | "medium" | "high" | "bursty" {
  const burstSignals = patternScore(text, [/밀당/, /튕김/, /왔다갔다/, /장난/]);
  if (burstSignals >= 2) {
    return "bursty";
  }

  const flirtSignals = patternScore(text, [/플러팅/, /장난/, /직구/, /농담/, /다정/]);
  if (flirtSignals >= 3) {
    return "high";
  }
  if (flirtSignals >= 1) {
    return "medium";
  }

  return text.length >= 1000 ? "low" : "medium";
}

function classifySafetyFlags(item: RankingGenderedItem, text: string): string[] {
  const flags = new Set<string>();

  if ((item.source_url ?? "").includes("rofan.ai")) {
    flags.add("external_brand_trace");
  }

  if (patternScore(text, [/guest/i, /guest/, /게스트/]) > 0) {
    flags.add("placeholder_guest");
  }

  if (patternScore(text, [/OOC/i, /out of character/i, /캐붕/, /메타/, /roleplay/i]) > 0) {
    flags.add("meta_roleplay_marker");
  }

  if (patternScore(text, [/미성년/, /미성년자/, /학생/, /교복/]) > 0) {
    flags.add("age_sensitive_marker");
  }

  if (patternScore(text, [/노골/, /선정/, /야한/, /섹스/, /성적/]) > 0) {
    flags.add("explicit_content_marker");
  }

  if (patternScore(text, [/폭력/, /살해/, /죽여/, /협박/]) > 0) {
    flags.add("aggression_marker");
  }

  if (typeof item.character_id !== "string" || item.character_id.trim().length === 0) {
    flags.add("missing_character_id");
  }

  return Array.from(flags);
}

function buildCombinedText(item: RankingGenderedItem): string {
  return textBlocksToString(
    normalizeText(item.summary),
    normalizeText(item.story),
    normalizeText(item.worldview?.text),
    normalizeText(item.character_introduction?.text),
    normalizeText(item.creator_comment?.text),
    normalizeText(item.hashtags?.join(" ")),
    normalizeText(item.creator_name),
    normalizeText(item.name),
  );
}

export function extractSafeRankingTaxonomyItem(
  item: RankingGenderedItem,
): RankingTaxonomyItem | null {
  const characterId = typeof item.character_id === "string"
    ? item.character_id.trim()
    : "";

  if (!characterId) {
    return null;
  }

  const combinedText = buildCombinedText(item);

  return {
    characterId,
    axes: {
      genre: pickLabel(combinedText, GENRE_RULES, "slice-of-life"),
      worldviewDensity: classifyWorldviewDensity(combinedText),
      relationshipStart: pickLabel(
        combinedText,
        RELATIONSHIP_START_RULES,
        "slow-burn",
      ),
      attachmentStyle: pickLabel(combinedText, ATTACHMENT_RULES, "secure"),
      flirtCadence: classifyFlirtCadence(combinedText),
      conflictPattern: pickLabel(combinedText, CONFLICT_RULES, "misunderstanding"),
      reassuranceMode: pickLabel(combinedText, REASSURANCE_RULES, "direct"),
      speechTexture: pickLabel(combinedText, SPEECH_RULES, "balanced"),
      dailyHook: pickLabel(combinedText, DAILY_HOOK_RULES, "check-in"),
      safetyFlags: classifySafetyFlags(item, combinedText),
    },
  };
}

export function extractSafeRankingTaxonomy(
  corpus: RankingGenderedCorpus | string,
): RankingTaxonomyDataset {
  const parsedCorpus = typeof corpus === "string"
    ? JSON.parse(corpus) as RankingGenderedCorpus
    : corpus;

  const items = Array.isArray(parsedCorpus.items) ? parsedCorpus.items : [];
  const taxonomyItems = items
    .map((item) => extractSafeRankingTaxonomyItem(item))
    .filter((item): item is RankingTaxonomyItem => item !== null);

  return {
    scrapedAt: parsedCorpus.scraped_at,
    scope: {
      genders: Array.isArray(parsedCorpus.scope?.genders)
        ? parsedCorpus.scope.genders
          .filter((item): item is string =>
            typeof item === "string" && item.trim().length > 0
          )
          .map((item) => item.trim())
        : [],
      periods: Array.isArray(parsedCorpus.scope?.periods)
        ? parsedCorpus.scope.periods
          .filter((item): item is string =>
            typeof item === "string" && item.trim().length > 0
          )
          .map((item) => item.trim())
        : [],
    },
    counts: {
      rawAppearanceCount: typeof parsedCorpus.raw_appearance_count === "number"
        ? parsedCorpus.raw_appearance_count
        : 0,
      uniqueCharacterCount: typeof parsedCorpus.unique_character_count ===
          "number"
        ? parsedCorpus.unique_character_count
        : taxonomyItems.length,
      failedCount: typeof parsedCorpus.failed_count === "number"
        ? parsedCorpus.failed_count
        : 0,
    },
    items: taxonomyItems,
  };
}
