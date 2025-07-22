# 영혼(Soul) 시스템 코드 변경 가이드

## 1. 데이터베이스 변경사항

### 테이블 이름 변경
```sql
-- 기존 테이블명 → 새로운 테이블명
token_usage → soul_usage
token_balances → soul_balances
token_purchases → soul_rewards
token_usage_stats → soul_usage_stats
user_token_stats → user_soul_stats
```

### 컬럼명 변경
```sql
-- token_balances → soul_balances
balance → soul_points
total_purchased → total_earned
total_used → total_spent
tokens_used → souls_earned (운세 확인 시 획득)
tokens_consumed → souls_consumed (프리미엄 기능 사용 시)
```

### 새로운 컬럼 추가
```sql
ALTER TABLE soul_balances ADD COLUMN level INTEGER DEFAULT 1;
ALTER TABLE soul_balances ADD COLUMN experience INTEGER DEFAULT 0;
ALTER TABLE soul_usage ADD COLUMN soul_type VARCHAR(20) CHECK (soul_type IN ('earned', 'consumed'));
```

## 2. Flutter 코드 변경사항

### A. 엔티티 변경 (lib/domain/entities/token.dart → soul.dart)

```dart
// 기존
class TokenBalance extends Equatable {
  final int totalTokens;
  final int usedTokens;
  final int remainingTokens;
  ...
}

// 변경
class SoulBalance extends Equatable {
  final int soulPoints;        // 현재 보유 영혼
  final int totalEarned;       // 총 획득한 영혼
  final int totalSpent;        // 총 소비한 영혼
  final int level;             // 사용자 레벨
  final int experience;        // 경험치
  ...
}
```

### B. 서비스 변경 (token_api_service.dart → soul_api_service.dart)

```dart
// 기존
Future<TokenBalance> consumeTokens({
  required String fortuneType,
  required int amount,
}) async { ... }

// 변경
Future<SoulBalance> earnSouls({
  required String fortuneType,
  required int amount,
}) async { ... }

Future<SoulBalance> consumeSouls({
  required String fortuneType,
  required int amount,
}) async { ... }
```

### C. Provider 변경 (token_provider.dart → soul_provider.dart)

```dart
// 기존
final tokenProvider = StateNotifierProvider<TokenNotifier, TokenState>

// 변경
final soulProvider = StateNotifierProvider<SoulNotifier, SoulState>

// 상태 클래스 변경
class SoulState {
  final SoulBalance? balance;
  final bool isEarningSoul;    // 영혼 획득 중
  final bool isConsumingSoul;  // 영혼 소비 중
  ...
}
```

### D. UI 컴포넌트 변경

#### 1. token_balance_widget.dart → soul_balance_widget.dart
```dart
// 아이콘 변경
Icon(Icons.token_rounded) → Icon(Icons.auto_awesome_rounded)

// 텍스트 변경
'토큰 잔액' → '영혼 포인트'
'토큰 충전' → '영혼 상태'
'${balance.remainingTokens}' → '${balance.soulPoints} 영혼'
```

#### 2. token_insufficient_modal.dart → soul_insufficient_modal.dart
```dart
// 메시지 변경
'토큰이 부족합니다' → '영혼이 부족합니다'
'프리미엄 운세를 보려면 영혼이 필요합니다'
```

## 3. Edge Functions 변경사항

### A. token-balance → soul-balance
```typescript
// 응답 형식 변경
{
  balance → soulPoints,
  totalPurchased → totalEarned,
  totalUsed → totalSpent,
  level,
  experience
}
```

### B. 새로운 엔드포인트
```typescript
// soul-earn: 운세 확인 시 영혼 획득
POST /soul-earn
{
  fortuneType: string,
  earnedAmount: number
}

// soul-consume: 프리미엄 기능 사용 시 영혼 소비
POST /soul-consume
{
  fortuneType: string,
  consumedAmount: number
}
```

## 4. 운세별 영혼 로직

### A. 영혼 획득 운세 (SOUL_EARN_RATES)
```typescript
export const SOUL_EARN_RATES = {
  // 기본 운세 (1-2 영혼)
  'daily': 1,
  'tomorrow': 1,
  'lucky-color': 1,
  'lucky-number': 1,
  
  // 중급 운세 (3-5 영혼)
  'love': 3,
  'career': 3,
  'compatibility': 4,
  'monthly': 5,
};
```

### B. 영혼 소비 운세 (SOUL_CONSUME_RATES)
```typescript
export const SOUL_CONSUME_RATES = {
  // 프리미엄 운세 (10-20 영혼)
  'saju': 15,
  'traditional-saju': 15,
  'destiny': 20,
  
  // 울트라 프리미엄 (30-50 영혼)
  'startup': 30,
  'business': 35,
  'yearly': 50,
};
```

## 5. 마이그레이션 전략

### Phase 1: 용어 변경 (즉시)
1. UI 텍스트 모두 변경
2. 아이콘 변경
3. 변수명/함수명은 유지 (하위 호환성)

### Phase 2: 로직 변경 (1주)
1. 운세 확인 시 영혼 획득 로직 추가
2. 프리미엄 운세 분류
3. 소비/획득 분리

### Phase 3: 전체 리팩토링 (2주)
1. 데이터베이스 스키마 변경
2. API 엔드포인트 변경
3. 전체 코드베이스 리팩토링

## 6. 주의사항

1. **하위 호환성**: 기존 사용자 데이터 마이그레이션 필요
2. **캐시 처리**: 기존 토큰 관련 캐시 무효화
3. **에러 메시지**: 모든 에러 메시지 업데이트
4. **분석 이벤트**: 토큰 → 영혼 이벤트명 변경
5. **문서 업데이트**: API 문서, 사용자 가이드 수정