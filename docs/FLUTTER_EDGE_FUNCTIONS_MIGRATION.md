# Flutter App - Edge Functions Migration Guide

## 🎉 Edge Functions 배포 완료!

모든 Edge Functions가 프로덕션에 성공적으로 배포되었습니다.

### 배포된 Edge Functions (총 77개)
- ✅ Token Management: `token-balance`, `token-daily-claim`
- ✅ Payment: `payment-verify-purchase`
- ✅ Fortune Generation: 74개 운세 타입 모두 배포 완료

## 📱 Flutter 앱 업데이트 가이드

### 1. 환경 변수 설정

`fortune_flutter/.env` 파일에 Edge Functions URL 추가:
```env
# Supabase Edge Functions
EDGE_FUNCTIONS_URL=https://hayjukwfcsdmppairazc.supabase.co/functions/v1
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhheWp1a3dmY3NkbXBwYWlyYXpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxMDIyNzUsImV4cCI6MjA2MzY3ODI3NX0.nV--LlLk8VOUyz0Vmu_26dRn1vRD9WFxPg0BIYS7ct0
```

### 2. API Service Provider 업데이트

`lib/presentation/providers/providers.dart`에서:
```dart
import '../../data/services/fortune_api_service_edge_functions.dart';

// Fortune API Service Provider 수정
final fortuneApiServiceProvider = Provider<FortuneApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // Edge Functions 버전 사용
  return FortuneApiServiceWithEdgeFunctions(apiClient);
});
```

### 3. Feature Flag 초기화

`lib/main.dart`에서:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Feature Flags 초기화
  final user = Supabase.instance.client.auth.currentUser;
  FeatureFlags().initialize(userId: user?.id);
  
  // 테스트를 위해 Edge Functions 활성화
  // FeatureFlags().enableEdgeFunctions(); // 테스트 시에만 사용
  
  runApp(MyApp());
}
```

### 4. 점진적 롤아웃 설정

관리자 화면이나 원격 설정에서:
```dart
// 10%의 사용자에게만 Edge Functions 활성화
FeatureFlags().setEdgeFunctionsRolloutPercentage(10);

// 특정 테스터 추가
FeatureFlags().addEdgeFunctionsTestUser('test-user-id-1');
FeatureFlags().addEdgeFunctionsTestUser('test-user-id-2');
```

## 🧪 테스트 체크리스트

### 1. 토큰 관리 테스트
- [ ] 토큰 잔액 조회
- [ ] 일일 토큰 수령
- [ ] 토큰 차감 확인

### 2. 운세 생성 테스트
- [ ] 일일 운세
- [ ] MBTI 운세
- [ ] 별자리 운세
- [ ] 캐싱 동작 확인

### 3. 결제 테스트
- [ ] 인앱 구매 검증
- [ ] 토큰 충전 확인

### 4. 오류 처리 테스트
- [ ] 네트워크 오류
- [ ] 인증 실패
- [ ] 토큰 부족

## 🔍 모니터링

### Supabase Dashboard에서 확인
1. [Functions 대시보드](https://supabase.com/dashboard/project/hayjukwfcsdmppairazc/functions)
2. 각 함수별 호출 수, 오류율, 응답 시간 확인
3. 로그 확인

### CLI로 로그 확인
```bash
# 특정 함수 로그 확인
supabase functions list  # 함수 목록 확인

# 실시간 로그는 Dashboard에서 확인
```

## 📊 성능 기대치

### Edge Functions 응답 시간
- 토큰 조회: < 100ms
- 운세 생성 (캐시): < 200ms  
- 운세 생성 (신규): < 2000ms
- 결제 검증: < 500ms

### vs 기존 API Server
- 콜드 스타트 개선: 3-5초 → 0.5-1초
- 자동 스케일링
- 글로벌 엣지 배포

## 🚨 롤백 계획

문제 발생 시:
```dart
// 1. 즉시 Edge Functions 비활성화
FeatureFlags().disableEdgeFunctions();

// 2. 또는 롤아웃 비율을 0으로
FeatureFlags().setEdgeFunctionsRolloutPercentage(0);
```

## 🎯 다음 단계

1. **현재**: Flutter 앱에서 Edge Functions 테스트
2. **1주차**: 10% 사용자 롤아웃 → 모니터링
3. **2주차**: 50% 확대 → 성능 최적화
4. **3주차**: 100% 전환 → 기존 API 서버 종료

## 💡 팁

- Edge Functions는 이미 프로덕션에 배포되어 있음
- CORS 설정 완료
- OpenAI API 키 설정 완료
- 모든 운세 타입 사용 가능

문제가 있으면 언제든 문의해주세요!