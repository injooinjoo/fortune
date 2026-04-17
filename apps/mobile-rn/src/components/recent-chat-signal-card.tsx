import { type FortuneTypeId } from '@fortune/product-contracts';
import { View } from 'react-native';

import { findChatCharacterById } from '../lib/chat-characters';
import { formatFortuneTypeLabel } from '../lib/chat-shell';
import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';
import { Card } from './card';

interface RecentChatSignalCardProps {
  selectedCharacterId: string | null;
  lastFortuneType: FortuneTypeId | null;
  sentMessageCount: number;
  title?: string;
  detailCopy?: string;
  emptyCopy?: string;
}

export function RecentChatSignalCard({
  detailCopy,
  emptyCopy = '아직 최근 채팅 신호가 없습니다.',
  lastFortuneType,
  selectedCharacterId,
  sentMessageCount,
  title = '최근 채팅 신호',
}: RecentChatSignalCardProps) {
  const recentCharacter = findChatCharacterById(selectedCharacterId);
  const hasRecentChatSignal = Boolean(
    selectedCharacterId || lastFortuneType || sentMessageCount > 0,
  );

  return (
    <Card>
      <AppText variant="heading4">{title}</AppText>
      <AppText variant="labelLarge">
        {recentCharacter?.name ?? '최근 캐릭터 없음'}
      </AppText>
      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        {hasRecentChatSignal
          ? detailCopy ??
            (sentMessageCount > 0
              ? `메시지 ${sentMessageCount}개를 보냈어요.`
              : `최근 선택 캐릭터: ${recentCharacter?.name ?? '기록 없음'}`)
          : emptyCopy}
      </AppText>
      <View style={{ gap: 8 }}>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {sentMessageCount > 0 && lastFortuneType
            ? `최근 인사이트: ${formatFortuneTypeLabel(lastFortuneType)}`
            : '최근 인사이트가 아직 없어요.'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {recentCharacter
            ? `최근 캐릭터: ${recentCharacter.name}`
            : '최근 캐릭터 기록이 없어요.'}
        </AppText>
      </View>
    </Card>
  );
}
