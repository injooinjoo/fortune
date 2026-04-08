import { Redirect } from 'expo-router';

import { ProfileScreen } from '../../../src/screens/profile-screen';
import { useAppBootstrap } from '../../../src/providers/app-bootstrap-provider';

export default function ProfileRoute() {
  const { session, status } = useAppBootstrap();

  if (status !== 'ready') {
    return null;
  }

  if (!session) {
    return (
      <Redirect
        href={{
          pathname: '/signup',
          params: {
            requireAuth: '1',
            returnTo: '/profile',
          },
        }}
      />
    );
  }

  return <ProfileScreen />;
}
