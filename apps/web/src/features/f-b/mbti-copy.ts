interface MbtiButtonLabelOptions {
  costPoints: number;
  loading: boolean;
  lockedMbti?: string;
}

export function mbtiButtonLabel({
  costPoints,
  loading,
  lockedMbti,
}: MbtiButtonLabelOptions): string {
  if (loading) return '읽는 중…';

  const reading = lockedMbti ? `${lockedMbti} 오늘의 운세` : '오늘의 MBTI 운세';
  return `온도 ${costPoints}개로 ${reading} 보기`;
}
