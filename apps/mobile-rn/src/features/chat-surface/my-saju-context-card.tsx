import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { fortuneTheme, withAlpha } from '../../lib/theme';
import type { ChatShellMySajuContextMessage } from '../../lib/chat-shell';

interface Props {
  message: ChatShellMySajuContextMessage;
}

/**
 * System-role card rendered inline in the chat thread when the user enters
 * "/chat" from their Manseryeok screen. Shows the 4 pillars, day master,
 * five-elements balance, and top ten-gods for at-a-glance context.
 */
export function MySajuContextCard({ message }: Props) {
  const { pillars, dayMaster, elements, dominantTenGods } = message.sajuSummary;

  return (
    <View
      style={{
        marginVertical: 8,
        paddingHorizontal: 16,
        paddingVertical: 14,
        borderRadius: fortuneTheme.radius.md,
        backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.08),
        borderWidth: 1,
        borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.2),
      }}
    >
      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.ctaBackground}
        style={{ fontWeight: '700', letterSpacing: 0.4 }}
      >
        내 사주 컨텍스트
      </AppText>

      <View style={{ flexDirection: 'row', gap: 8, marginTop: 8 }}>
        <PillarBadge label="년" value={pillars.year} />
        <PillarBadge label="월" value={pillars.month} />
        <PillarBadge label="일" value={pillars.day} emphasize />
        <PillarBadge label="시" value={pillars.hour} />
      </View>

      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textSecondary}
        style={{ marginTop: 8 }}
      >
        {`일간 ${dayMaster} · 木${elements.wood} 火${elements.fire} 土${elements.earth} 金${elements.metal} 水${elements.water}`}
      </AppText>

      {dominantTenGods.length > 0 ? (
        <AppText
          variant="labelSmall"
          color={fortuneTheme.colors.textSecondary}
          style={{ marginTop: 4 }}
        >
          {`주요 성향: ${dominantTenGods.join(', ')}`}
        </AppText>
      ) : null}
    </View>
  );
}

function PillarBadge({
  label,
  value,
  emphasize,
}: {
  label: string;
  value: string;
  emphasize?: boolean;
}) {
  return (
    <View
      style={{
        flex: 1,
        alignItems: 'center',
        paddingVertical: 6,
        borderRadius: fortuneTheme.radius.sm,
        backgroundColor: emphasize
          ? withAlpha(fortuneTheme.colors.ctaBackground, 0.18)
          : withAlpha(fortuneTheme.colors.ctaBackground, 0.06),
      }}
    >
      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textSecondary}
      >
        {label}
      </AppText>
      <AppText
        variant="bodyMedium"
        color={fortuneTheme.colors.textPrimary}
        style={{ fontWeight: emphasize ? '700' : '600' }}
      >
        {value}
      </AppText>
    </View>
  );
}
