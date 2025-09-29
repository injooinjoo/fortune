# ResilientService 사용 가이드

## 📋 개요

`ResilientService`는 Fortune Flutter 앱의 모든 서비스에서 공통적으로 사용되는 "선택적 기능" 에러 처리 패턴을 표준화한 기본 클래스입니다.

## 🎯 핵심 원칙

1. **서비스 실패가 앱 전체를 중단시키지 않음**
2. **일관된 에러 메시지 패턴 제공**
3. **적절한 fallback 값 반환**
4. **한국어 에러 메시지로 사용자 친화적 로깅**

## 🔧 기본 사용법

### 1. 서비스 클래스 생성

```dart
class MyService extends ResilientService {
  @override
  String get serviceName => 'MyService';

  // 서비스 메서드들...
}
```

### 2. 8가지 안전한 실행 패턴

#### 2.1 `safeExecute` - void 작업

```dart
await safeExecute(
  () => uploadFile(file),
  'file upload',
  '파일 업로드 기능 비활성화'
);
```

#### 2.2 `safeExecuteWithNull` - null 반환형

```dart
final result = await safeExecuteWithNull(
  () => getUserProfile(userId),
  'profile fetch',
  'null 반환'
);
```

#### 2.3 `safeExecuteWithFallback` - fallback 값

```dart
final pets = await safeExecuteWithFallback(
  () => fetchUserPets(userId),
  <PetProfile>[], // 빈 리스트 반환
  'pets fetch',
  '빈 목록 반환'
);
```

#### 2.4 `safeExecuteWithBool` - 성공/실패 bool

```dart
final success = await safeExecuteWithBool(
  () => sendNotification(message),
  'notification send',
  'false 반환'
);
```

#### 2.5 `safeExecuteWithPermission` - 권한 확인 포함

```dart
final result = await safeExecuteWithPermission(
  () => checkUserPermission(userId),
  () => performSecureOperation(),
  defaultValue,
  'secure operation',
  '권한 없음',
  'fallback 사용'
);
```

#### 2.6 `safeExecuteWithRetry` - 여러 시도

```dart
final result = await safeExecuteWithRetry(
  [
    () => tryMethod1(),
    () => tryMethod2(),
    () => tryMethod3(),
  ],
  defaultValue,
  'multi-try operation',
  'fallback 사용'
);
```

#### 2.7 `safeExecuteWithCondition` - 조건부 실행

```dart
final result = await safeExecuteWithCondition(
  isValidUser,
  () => performOperation(),
  defaultValue,
  'conditional operation',
  '조건 불만족',
  'fallback 사용'
);
```

#### 2.8 `safeExecuteSyncWithFallback` - 동기 작업

```dart
final result = await safeExecuteSyncWithFallback(
  () => calculateSomething(),
  defaultValue,
  'calculation',
  'fallback 계산값 사용'
);
```

## 📊 기존 코드 vs ResilientService 비교

### Before (기존 방식)

```dart
class PetService {
  static Future<List<PetProfile>> getUserPets(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response == null) return [];

      return (response as List)
          .map((json) => PetProfile.fromJson(json))
          .toList();
    } catch (e) {
      Logger.warning('[PetService] 사용자 반려동물 목록 조회 실패 (선택적 기능, 빈 목록 반환): $e');
      return [];
    }
  }
}
```

### After (ResilientService 사용)

```dart
class PetService extends ResilientService {
  @override
  String get serviceName => 'PetService';

  Future<List<PetProfile>> getUserPets(String userId) async {
    return await safeExecuteWithFallback(
      () async {
        final response = await _client
            .from(_tableName)
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        if (response == null) return <PetProfile>[];

        return (response as List)
            .map((json) => PetProfile.fromJson(json))
            .toList();
      },
      <PetProfile>[], // fallback value
      '사용자 반려동물 목록 조회',
      '빈 목록 반환'
    );
  }
}
```

## ✅ 장점

### 1. 코드 일관성
- 모든 서비스에서 동일한 에러 처리 패턴 사용
- 통일된 로깅 메시지 형식

### 2. 유지보수성 향상
- 반복적인 try-catch 블록 제거
- 에러 처리 로직 중앙화

### 3. 안정성 증대
- 예측 가능한 fallback 동작
- 앱 크래시 방지

### 4. 개발 효율성
- 보일러플레이트 코드 감소
- 명확한 메서드 이름으로 의도 파악 용이

## 🚀 실제 적용 예시

### SupabaseStorageService 리팩토링

```dart
class SupabaseStorageService extends ResilientService {
  @override
  String get serviceName => 'SupabaseStorageService';

  Future<bool> ensureBucketExists() async {
    return await safeExecuteWithPermission(
      () async {
        final user = _supabase.auth.currentUser;
        return user != null;
      },
      () async {
        final buckets = await _supabase.storage.listBuckets();
        return buckets.any((b) => b.name == _profileImagesBucket);
      },
      false,
      '스토리지 버킷 권한 확인',
      '사용자 인증 필요',
      '버킷 접근 불가'
    );
  }
}
```

### SocialAuthService 리팩토링

```dart
class SocialAuthService extends ResilientService {
  @override
  String get serviceName => 'SocialAuthService';

  Future<bool> signInWithKakao() async {
    return await safeExecuteWithRetry(
      [
        () => _tryKakaoSignIn(),
        () => _tryKakaoWebSignIn(),
        () => _tryFallbackAuth(),
      ],
      false,
      'Kakao 로그인',
      '로그인 실패'
    );
  }
}
```

## 📝 마이그레이션 가이드

### 1. 기존 서비스 식별
```bash
grep -r "Logger.warning.*선택적 기능" lib/services/
```

### 2. 단계별 마이그레이션

1. **서비스 클래스에 ResilientService 상속 추가**
2. **serviceName getter 구현**
3. **기존 try-catch 블록을 적절한 safeExecute* 메서드로 변경**
4. **테스트 실행 및 검증**

### 3. 우선순위

**높은 우선순위** (사용자 경험에 직접 영향):
- PetService
- SupabaseStorageService
- SocialAuthService
- NotificationService

**중간 우선순위** (기능적 중요도):
- WidgetService
- LiveActivityService
- CelebrityService

**낮은 우선순위** (내부 기능):
- NativeFeaturesInitializer
- WidgetDataManager

## 🔍 로그 메시지 표준

모든 ResilientService 사용 시 다음 형식의 로그가 자동 생성됩니다:

```
[ServiceName] operation_name 실패 (선택적 기능, fallback_message): error_details
```

**예시**:
```
[PetService] 사용자 반려동물 목록 조회 실패 (선택적 기능, 빈 목록 반환): Connection timeout
[SupabaseStorageService] 프로필 이미지 업로드 실패 (선택적 기능, null 반환): Permission denied
```

## 🎯 결론

`ResilientService`를 통해 Fortune 앱의 모든 서비스에서 일관되고 안정적인 에러 처리를 구현할 수 있습니다. 이는 사용자 경험 개선과 코드 품질 향상에 크게 기여합니다.

---

**마지막 업데이트**: 2025-09-29
**작성자**: Claude Code
**목적**: 서비스 안정성 및 코드 품질 향상