/**
 * MBTI 16유형 — `/운세/엠비티아이` 와 `/운세/엠비티아이/<유형>` 이 공유한다.
 *
 * 순서와 별명은 `supabase/functions/fortune-mbti/index.ts` 의
 * `MBTI_CHARACTERISTICS` 를 따랐다 (별명은 description 의 앞부분).
 * Edge Function 은 이 16개 밖의 문자열에 400 을 준다.
 */

export interface MbtiType {
  /** 대문자 4글자. 경로 조각이자 서버에 보내는 값. */
  id: string;
  nickname: string;
}

export const MBTI_TYPES: ReadonlyArray<MbtiType> = [
  { id: 'INTJ', nickname: '전략가' },
  { id: 'INTP', nickname: '논리술사' },
  { id: 'ENTJ', nickname: '통솔자' },
  { id: 'ENTP', nickname: '변론가' },
  { id: 'INFJ', nickname: '옹호자' },
  { id: 'INFP', nickname: '중재자' },
  { id: 'ENFJ', nickname: '선도자' },
  { id: 'ENFP', nickname: '활동가' },
  { id: 'ISTJ', nickname: '현실주의자' },
  { id: 'ISFJ', nickname: '수호자' },
  { id: 'ESTJ', nickname: '경영자' },
  { id: 'ESFJ', nickname: '집정관' },
  { id: 'ISTP', nickname: '만능재주꾼' },
  { id: 'ISFP', nickname: '모험가' },
  { id: 'ESTP', nickname: '사업가' },
  { id: 'ESFP', nickname: '연예인' },
];

/** 경로가 소문자로 들어와도 찾을 수 있게 대문자로 맞춘 뒤 조회한다. */
export function findMbtiType(id: string): MbtiType | undefined {
  const normalized = id.trim().toUpperCase();
  return MBTI_TYPES.find((type) => type.id === normalized);
}
