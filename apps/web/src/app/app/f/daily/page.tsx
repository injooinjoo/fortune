import { redirect } from 'next/navigation';

/**
 * 오늘의 운세는 공개 경로(/운세/오늘)로 옮겼다.
 * 로그인 상태로 이 경로에 들어온 사용자를 위해 리다이렉트만 남긴다.
 */
export default function LegacyDailyFortunePage() {
  redirect('/운세/오늘');
}
