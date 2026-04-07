import { router } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';

export function LegalScreen({
  title,
  path: _path,
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
      <AppText variant="displaySmall">{title}</AppText>
      <AppText variant="bodyLarge">{summary}</AppText>

      {sections.map((section) => (
        <Card key={section.title}>
          <AppText variant="heading4">{section.title}</AppText>
          <AppText variant="bodyMedium">{section.body}</AppText>
        </Card>
      ))}

      <Card>
        <AppText variant="heading4">이어서 보기</AppText>
        <PrimaryButton onPress={() => router.push('/profile')} tone="secondary">
          프로필로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          채팅으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
