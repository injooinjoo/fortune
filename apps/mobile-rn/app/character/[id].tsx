import { useLocalSearchParams } from 'expo-router';

import { RouteScreen } from '../../src/screens/route-screen';

export default function CharacterProfileRoute() {
  const params = useLocalSearchParams<{ id?: string }>();

  return (
    <RouteScreen
      routeId="character-profile"
      note={`characterId: ${params.id ?? 'unknown'}`}
    />
  );
}
