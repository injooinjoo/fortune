import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { fortuneTheme } from '../../lib/theme';
import { resultMetadataByKind } from '../fortune-results/mapping';
import { RenderFortuneResult } from '../fortune-results/registry';
import { type ResultKind } from '../fortune-results/types';

export function EmbeddedResultCard({
  resultKind,
}: {
  resultKind: ResultKind;
}) {
  const metadata = resultMetadataByKind[resultKind];

  return (
    <View style={{ width: '100%' }}>
      <Card>
        <View style={{ gap: 4 }}>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            {metadata.eyebrow}
          </AppText>
          <AppText variant="heading4">{metadata.title}</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {metadata.subtitle}
          </AppText>
        </View>
        <RenderFortuneResult resultKind={resultKind} />
      </Card>
    </View>
  );
}
