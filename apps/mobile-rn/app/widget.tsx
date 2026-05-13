import { Redirect, useLocalSearchParams } from 'expo-router';
import {
  normalizeChatCharacterIdForChat,
  normalizeFortuneTypeForChat,
} from '@fortune/product-contracts';

function readSearchParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}

export default function WidgetDeepLinkRoute() {
  const params = useLocalSearchParams<Record<string, string | string[]>>();
  const characterId =
    normalizeChatCharacterIdForChat(readSearchParam(params.characterId)) ??
    undefined;
  const fortuneType =
    normalizeFortuneTypeForChat(readSearchParam(params.fortuneType)) ?? undefined;

  return (
    <Redirect
      href={{
        pathname: '/(tabs)/chat',
        params: {
          ...(characterId ? { characterId } : {}),
          ...(fortuneType ? { fortuneType } : {}),
        },
      }}
    />
  );
}
