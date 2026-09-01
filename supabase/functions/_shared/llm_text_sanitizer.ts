// LLM 이 생성한 한국어 본문에 섞여 나오는 이물질을 제거한다.
//
// 실제 프로덕션 사고: 2026-09-01 `/운세/오늘` 결과의 "💬 오늘의 한마디" 끝에
// `娱乐网址`(중국어 도박/유흥 사이트 SEO 스팸 토큰)가 그대로 렌더됐다. 모델이
// 학습 데이터의 스팸 꼬리표를 문장 끝에 붙였고, 응답을 검증하는 지점이 하나도
// 없어서 유료 결과물에 그대로 실렸다.
//
// `fortune_safety_guard.ts` 는 시스템 프롬프트에 붙는 **입력** 가드다.
// 이 파일은 모델이 이미 뱉은 **출력**을 걸러내는 짝이다. 프롬프트로 막는 것과
// 출력에서 지우는 것 둘 다 필요하다 — 프롬프트는 확률이고 출력 필터는 계약이다.
//
// 사용법:
//   import { sanitizeLlmText } from '../_shared/llm_text_sanitizer.ts'
//   const { text, removed } = sanitizeLlmText(response.content.trim())
//   if (removed.length) console.warn('LLM 이물질 제거', removed)

/**
 * 한자(CJK 통합 한자 + 확장 A + 호환 한자).
 *
 * 한국어 운세 본문에 한자가 필요한 경우는 사주/오행처럼 한자 자체가 콘텐츠일
 * 때뿐이다. `fortune-daily` 는 프롬프트에서 "딱딱한 사자성어나 고어 절대 금지"
 * 를 이미 명시하므로 한자는 전부 이물질로 본다. 사주 계열에서 재사용할 때는
 * `allowHanja: true` 로 이 규칙만 끈다.
 */
const HAN_RUN = /[㐀-䶿一-鿿豈-﫿]+/g;

/** 운세 본문에 URL 이 나올 이유가 없다. 스팸의 본체는 대개 링크다. */
const URL_LIKE = /(?:https?:\/\/|www\.)[^\s<>"']+/gi;

/** 프롬프트 인젝션/스팸에 흔히 끼는 폭 없는 문자. 눈에 안 보여서 더 위험하다. */
const ZERO_WIDTH = /[​-‍⁠﻿]/g;

export type SanitizeOptions = {
  /** 사주·오행처럼 한자가 콘텐츠인 운세에서만 true. 기본은 제거. */
  allowHanja?: boolean;
};

export type SanitizeResult = {
  /** 정리된 본문. */
  text: string;
  /** 제거한 조각들. 비어 있지 않으면 모델이 이상한 걸 뱉었다는 신호다. */
  removed: string[];
};

/**
 * 한국어 LLM 본문에서 스팸/이물질을 제거하고 공백을 정리한다.
 *
 * 이모지(U+1F300~)와 한글(U+AC00~U+D7A3)은 건드리지 않는다.
 */
export function sanitizeLlmText(input: string, options: SanitizeOptions = {}): SanitizeResult {
  const removed: string[] = [];

  const collect = (match: string) => {
    removed.push(match);
    return '';
  };

  let text = input.replace(ZERO_WIDTH, '');
  text = text.replace(URL_LIKE, collect);
  if (!options.allowHanja) {
    text = text.replace(HAN_RUN, collect);
  }

  // 제거하고 남은 공백 정리. 줄 구조(빈 줄 한 개)는 원문 서식이라 유지한다.
  text = text
    .split('\n')
    .map((line) => line.replace(/[ \t]{2,}/g, ' ').trimEnd())
    .join('\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();

  return { text, removed };
}
