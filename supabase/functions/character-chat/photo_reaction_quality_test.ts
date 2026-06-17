import {
  buildPhotoReactionRetryPrompt,
  evaluatePhotoReactionQuality,
  PHOTO_REACTION_SAFE_FALLBACK,
  PHOTO_REACTION_STRICT_PROMPT,
} from "./photo_reaction_quality.ts";
import { PROACTIVE_REVEAL_CAPTIONS } from "./proactive_reveal_captions.ts";

Deno.test("photo reaction QA blocks generic photo placeholders", () => {
  const result = evaluatePhotoReactionQuality("사진 한 장 보냈네.", {
    hasImageInput: true,
  });

  if (result.ok) {
    throw new Error("generic photo placeholder must fail QA");
  }
  if (!result.issues.includes("generic_photo_placeholder")) {
    throw new Error(`missing generic issue: ${result.issues.join(",")}`);
  }
});

Deno.test("photo reaction QA requires a concrete visual anchor", () => {
  const result = evaluatePhotoReactionQuality("헐 귀엽다 ㅋㅋ", {
    hasImageInput: true,
  });

  if (result.ok) {
    throw new Error("photo reply without visual anchor must fail QA");
  }
  if (!result.issues.includes("missing_visual_anchor")) {
    throw new Error(`missing visual anchor issue: ${result.issues.join(",")}`);
  }
});

Deno.test("photo reaction QA does not pass on short-token false positives", () => {
  const weakReplies = [
    "그러면 진짜 좋겠다 ㅋㅋ",
    "방금 봤는데 귀엽다 ㅋㅋ",
    "어쩌면 이거 괜찮은데?",
  ];

  for (const reply of weakReplies) {
    const result = evaluatePhotoReactionQuality(reply, { hasImageInput: true });
    if (result.ok || !result.issues.includes("missing_visual_anchor")) {
      throw new Error(`short-token false positive must fail QA: ${reply}`);
    }
  }
});

Deno.test("photo reaction QA accepts natural chat reactions with image detail", () => {
  const result = evaluatePhotoReactionQuality(
    "헐 뒤에 노을 색 진짜 예쁘다. 이거 보고 그냥 지나치기 어렵긴 했겠다.",
    { hasImageInput: true },
  );

  if (!result.ok) {
    throw new Error(`expected pass, got ${result.issues.join(",")}`);
  }
});

Deno.test("strict prompt and retry prompt explicitly ban photo-only reactions", () => {
  if (!PHOTO_REACTION_STRICT_PROMPT.includes("사진 한 장")) {
    throw new Error("strict prompt must name the failed phrase");
  }

  const retryPrompt = buildPhotoReactionRetryPrompt({
    previousReply: "사진 한 장 보냈네.",
    issues: ["generic_photo_placeholder"],
  });
  if (!retryPrompt.includes("시각 단서 1개")) {
    throw new Error("retry prompt must require concrete visual detail");
  }
});

Deno.test("safe fallback blocks generic photo placeholders when retry fails", () => {
  const result = evaluatePhotoReactionQuality(PHOTO_REACTION_SAFE_FALLBACK, {
    hasImageInput: true,
  });

  if (result.issues.includes("generic_photo_placeholder")) {
    throw new Error(
      "safe fallback must not contain generic photo placeholder wording",
    );
  }
});

Deno.test("proactive lunch reveal captions are not generic photo placeholders", () => {
    const captions = [...PROACTIVE_REVEAL_CAPTIONS];
    if (captions.length === 0) {
      throw new Error("empty proactive reveal caption pool");
    }

    const banned = ["사진 한 장", "사진 보냈", "사진이야", "어 이거", "이거임"];
    const generic = captions.find((caption) =>
      banned.some((phrase) => caption.includes(phrase))
    );
    if (generic) {
      throw new Error(
        `generic proactive reveal caption must not be shipped: ${generic}`,
      );
    }

    const lunchAnchored = captions.every((caption) =>
      /점심|먹|밥|메뉴|나온/.test(caption)
    );
    if (!lunchAnchored) {
      throw new Error(
        `all proactive lunch captions must anchor to meal context: ${
          captions.join(", ")
        }`,
      );
    }
});
