import { Redirect } from 'expo-router';

import { DevToolsScreen } from '../../../src/screens/dev-tools-screen';
import { isTestAccountEmail } from '../../../src/lib/test-accounts';
import { useAppBootstrap } from '../../../src/providers/app-bootstrap-provider';

export default function ProfileDevToolsRoute() {
  const { session } = useAppBootstrap();
  const email = session?.user.email ?? null;

  // 진입 자체를 가드. 일반 사용자가 직접 URL 로 접근해도 프로필로 튕긴다.
  if (!isTestAccountEmail(email)) {
    return <Redirect href="/profile" />;
  }

  return <DevToolsScreen />;
}
