import type { FortuneTypeId } from '@fortune/product-contracts';

import type { EmbeddedResultProfileContext } from './types';

export type FortuneRuntimeBlockReason =
  | 'missing-profile-birth-date'
  | 'photo-required'
  | 'edge-unavailable';

const photoRequiredFortuneTypes = new Set<FortuneTypeId>([
  'face-reading',
  'ootd-evaluation',
]);

const edgeUnavailableFortuneTypes = new Set<FortuneTypeId>(['lotto']);

const profileBirthDateRequiredFortuneTypes = new Set<FortuneTypeId>([
  'mbti',
  'compatibility',
  'zodiac',
  'zodiac-animal',
  'constellation',
  'birthstone',
]);

export function resolveFortuneRuntimeBlockReason(
  fortuneType: FortuneTypeId,
  profile: EmbeddedResultProfileContext,
): FortuneRuntimeBlockReason | null {
  if (
    profileBirthDateRequiredFortuneTypes.has(fortuneType) &&
    !profile.birthDate
  ) {
    return 'missing-profile-birth-date';
  }

  if (photoRequiredFortuneTypes.has(fortuneType)) {
    return 'photo-required';
  }

  if (edgeUnavailableFortuneTypes.has(fortuneType)) {
    return 'edge-unavailable';
  }

  return null;
}

export function buildFortuneRuntimeBlockMessage(
  fortuneType: FortuneTypeId,
  reason: FortuneRuntimeBlockReason,
) {
  switch (reason) {
    case 'missing-profile-birth-date':
      return '이 결과는 생년월일이 있어야 정확히 볼 수 있어요. 프로필에서 생년월일을 먼저 입력해주세요.';
    case 'photo-required':
      return fortuneType === 'face-reading'
        ? '관상 결과는 얼굴 사진이 있어야 정확히 볼 수 있어요. 사진 첨부 연결을 먼저 붙인 뒤 같은 대화 안에서 바로 이어드릴게요.'
        : 'OOTD 결과는 착장 사진이 있어야 정확히 볼 수 있어요. 사진 첨부 연결을 먼저 붙인 뒤 같은 대화 안에서 바로 이어드릴게요.';
    case 'edge-unavailable':
      return '이 운세는 전용 분석 연결을 정리 중이라 지금은 다른 결과로 섞어 보여주지 않겠습니다.';
    default:
      return null;
  }
}
