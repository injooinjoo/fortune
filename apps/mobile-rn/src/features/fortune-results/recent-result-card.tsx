import { type FortuneTypeId } from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { PrimaryButton } from '../../components/primary-button';
import {
  findChatCharacterById,
  isFortuneChatCharacter,
} from '../../lib/chat-characters';
import { formatFortuneTypeLabel } from '../../lib/chat-shell';
import { fortuneTheme } from '../../lib/theme';
import { resolveResultKindFromFortuneType } from './mapping';

interface RecentResultCardProps {
  lastFortuneType: FortuneTypeId | null;
  selectedCharacterId: string | null;
  onOpen: (fortuneType: FortuneTypeId) => void;
}

export function RecentResultCard({
  lastFortuneType,
  onOpen,
  selectedCharacterId,
}: RecentResultCardProps) {
  if (!lastFortuneType) {
    return null;
  }

  if (!resolveResultKindFromFortuneType(lastFortuneType)) {
    return null;
  }

  const recentCharacter = findChatCharacterById(selectedCharacterId);
  const recentFortuneCharacter =
    recentCharacter && isFortuneChatCharacter(recentCharacter)
      ? recentCharacter
      : null;

  return (
    <Card>
      <AppText variant="heading4">최근 결과 다시 보기</AppText>
      <AppText variant="labelLarge">
        {formatFortuneTypeLabel(lastFortuneType)}
      </AppText>
      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        {recentFortuneCharacter
          ? `${recentFortuneCharacter.name}와 보던 결과를 같은 채팅 안에서 다시 열 수 있습니다.`
          : '직전 인사이트 결과를 같은 채팅 안에서 다시 엽니다.'}
      </AppText>
      {recentFortuneCharacter ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          최근 함께 본 캐릭터: {recentFortuneCharacter.name}
        </AppText>
      ) : null}
      <PrimaryButton onPress={() => onOpen(lastFortuneType)}>
        최근 결과 다시 보기
      </PrimaryButton>
    </Card>
  );
}
