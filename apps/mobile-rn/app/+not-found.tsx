import { RouteScreen } from '../src/screens/route-screen';

export default function NotFoundScreen() {
  return (
    <RouteScreen
      routeId="chat"
      note="정의되지 않은 경로입니다. 현재 RN 셸은 /chat을 기준으로 수렴합니다."
    />
  );
}
