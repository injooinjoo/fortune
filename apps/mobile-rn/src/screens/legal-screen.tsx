import { router } from 'expo-router';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';

export function LegalScreen({
  title,
  path,
  summary,
  sections,
}: {
  title: string;
  path: string;
  summary: string;
  sections: Array<{ title: string; body: string }>;
}) {
  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        {path}
      </AppText>
      <AppText variant="displaySmall">{title}</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        {summary}
      </AppText>

      <Card>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label="legal" />
          <Chip label="readable" tone="accent" />
          <Chip label="policy" />
        </View>
      </Card>

      {sections.map((section) => (
        <Card key={section.title}>
          <AppText variant="heading4">{section.title}</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            {section.body}
          </AppText>
        </Card>
      ))}

      <Card>
        <AppText variant="heading4">Navigation</AppText>
        <PrimaryButton onPress={() => router.push('/profile')} tone="secondary">
          프로필로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          Chat으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
