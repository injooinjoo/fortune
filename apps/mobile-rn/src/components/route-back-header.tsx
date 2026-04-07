import { router, type Href } from 'expo-router';
import { Pressable, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

interface RouteBackHeaderProps {
  fallbackHref?: Href;
  accessibilityLabel?: string;
  label?: string;
}

function normalizeHrefToPath(href: Href | undefined) {
  if (!href) {
    return null;
  }

  if (typeof href === 'string') {
    return href.split('?')[0] ?? href;
  }

  const pathname = href.pathname;

  return typeof pathname === 'string' ? pathname : null;
}

export function resolveBackDestinationLabel(href: Href | undefined) {
  const path = normalizeHrefToPath(href);

  if (!path) {
    return undefined;
  }

  if (path === '/chat') {
    return '메시지';
  }

  if (path === '/profile') {
    return '프로필';
  }

  if (path === '/profile/edit') {
    return '프로필 수정';
  }

  if (path === '/profile/notifications') {
    return '알림 설정';
  }

  if (path === '/profile/relationships') {
    return '관계도';
  }

  if (path === '/profile/saju-summary') {
    return '사주 요약';
  }

  if (path === '/premium') {
    return '프리미엄';
  }

  if (path === '/signup') {
    return '로그인 및 시작';
  }

  if (path === '/onboarding') {
    return '처음 설정하기';
  }

  if (path.startsWith('/character/')) {
    return '캐릭터 프로필';
  }

  return undefined;
}

export function RouteBackHeader({
  fallbackHref = '/chat',
  accessibilityLabel,
  label,
}: RouteBackHeaderProps) {
  const resolvedLabel = label ?? resolveBackDestinationLabel(fallbackHref);
  const resolvedAccessibilityLabel =
    accessibilityLabel ??
    (resolvedLabel ? `${resolvedLabel}로 돌아가기` : '뒤로 가기');

  function handlePress() {
    if (router.canGoBack()) {
      router.back();
      return;
    }

    router.replace(fallbackHref);
  }

  return (
    <Pressable
      accessibilityLabel={resolvedAccessibilityLabel}
      accessibilityRole="button"
      hitSlop={8}
      onPress={handlePress}
      style={({ pressed }) => ({ opacity: pressed ? 0.78 : 1 })}
    >
      <View
        style={{
          alignItems: 'center',
          alignSelf: 'flex-start',
          flexDirection: 'row',
          gap: fortuneTheme.spacing.xs,
          paddingVertical: fortuneTheme.spacing.xs,
        }}
      >
        <AppText
          style={{ lineHeight: 22 }}
          variant="heading4"
          color={fortuneTheme.colors.accentSecondary}
        >
          ‹
        </AppText>
        {resolvedLabel ? (
          <AppText
            variant="labelLarge"
            color={fortuneTheme.colors.accentSecondary}
          >
            {resolvedLabel}
          </AppText>
        ) : null}
      </View>
    </Pressable>
  );
}
