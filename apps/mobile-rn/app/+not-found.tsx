import { RouteScreen } from '../src/screens/route-screen';

export default function NotFoundScreen() {
  return (
    <RouteScreen
      routeId="chat"
      note="요청한 화면을 찾지 못해 기본 채팅 화면으로 안내합니다."
    />
  );
}
