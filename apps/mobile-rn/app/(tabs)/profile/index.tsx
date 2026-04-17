import { Redirect } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';

import { ProfileScreen } from '../../../src/screens/profile-screen';
import { useAppBootstrap } from '../../../src/providers/app-bootstrap-provider';

export default function ProfileRoute() {
  const { session, status } = useAppBootstrap();

  if (status !== 'ready') {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#000' }}>
        <ActivityIndicator color="#fff" />
      </View>
    );
  }

  if (!session) {
    return <Redirect href="/signup" />;
  }

  return <ProfileScreen />;
}
