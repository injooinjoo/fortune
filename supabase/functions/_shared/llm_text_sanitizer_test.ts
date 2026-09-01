import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { sanitizeLlmText } from "./llm_text_sanitizer.ts";

Deno.test("프로덕션에서 실제로 노출된 중국어 스팸 꼬리표를 제거한다", () => {
  // 2026-09-01 zpzg.co.kr `/운세/오늘` 결과 본문에서 그대로 관측된 문자열.
  const raw = "회원님, 완벽보다 꾸준함이 진짜 치트키! 오늘의 작은 선택이 건강한 내일을 만들어요✨娱乐网址";

  const { text, removed } = sanitizeLlmText(raw);

  assertEquals(text, "회원님, 완벽보다 꾸준함이 진짜 치트키! 오늘의 작은 선택이 건강한 내일을 만들어요✨");
  assertEquals(removed, ["娱乐网址"]);
});

Deno.test("한글·이모지·영문·숫자는 건드리지 않는다", () => {
  const raw = "💫 오늘의 바이브\n갓생 지수 83점🔥 NewJeans 들으면서 10분 산책!";

  const { text, removed } = sanitizeLlmText(raw);

  assertEquals(text, raw);
  assertEquals(removed, []);
});

Deno.test("본문에 섞인 링크를 제거한다", () => {
  const { text, removed } = sanitizeLlmText("오늘은 산책하기 좋은 날 https://spam.example/promo 이에요");

  assertEquals(text, "오늘은 산책하기 좋은 날 이에요");
  assertEquals(removed, ["https://spam.example/promo"]);
});

Deno.test("눈에 보이지 않는 폭 없는 문자를 제거한다", () => {
  const { text } = sanitizeLlmText("오늘​은‌ 좋은 날");

  assertEquals(text, "오늘은 좋은 날");
});

Deno.test("allowHanja 면 사주·오행 한자는 남긴다", () => {
  const raw = "오행은 木火土金水 균형이 핵심이에요";

  const { text, removed } = sanitizeLlmText(raw, { allowHanja: true });

  assertEquals(text, raw);
  assertEquals(removed, []);
});

Deno.test("제거 후 남은 공백과 빈 줄을 정리한다", () => {
  const { text } = sanitizeLlmText("첫 줄 娱乐网址\n\n\n\n둘째 줄");

  assertEquals(text, "첫 줄\n\n둘째 줄");
});
