import { Redirect, useLocalSearchParams } from 'expo-router';

export default function ChatAliasRoute() {
  const params = useLocalSearchParams<Record<string, string | string[]>>();

  return (
    <Redirect
      href={{
        pathname: '/(tabs)/chat',
        params,
      }}
    />
  );
}
