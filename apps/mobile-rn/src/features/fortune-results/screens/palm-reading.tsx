/**
 * 손금가이드 결과 화면 — generic poster-guide 컴포넌트의 thin alias.
 *
 * 손금/뷰티/헤어/관상-가이드/OOTD/소개팅/전생 7종은 모두 동일한 full-bleed
 * 이미지 + 공유 버튼 패턴이라 generic `OndoPosterGuideResult` 가 단일 출처입니다.
 *
 * 본 alias 는 기존 registry 호환성을 위해 유지되며, posterType 을 명시적으로
 * 'palm-reading' 으로 지정해 응답 누락 시에도 라벨/공유 메시지가 흐르지 않게 합니다.
 */
import type { FortuneResultComponentProps } from '../types';
import { OndoPosterGuideResult } from './poster-guide';

export function OndoPalmReadingResult(props: FortuneResultComponentProps) {
  return <OndoPosterGuideResult {...props} posterType="palm-reading" />;
}
