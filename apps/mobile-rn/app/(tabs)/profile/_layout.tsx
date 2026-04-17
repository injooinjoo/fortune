import { Redirect, Stack } from 'expo-router';

import { useAppBootstrap } from '../../../src/providers/app-bootstrap-provider';

export default function ProfileStackLayout() {
  const { session } = useAppBootstrap();

  if (!session) {
    return <Redirect href="/signup" />;
  }

  return (
    <Stack
      screenOptions={{
        headerShown: false,
      }}
    />
  );
}
