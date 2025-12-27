---
name: "sc:feature-fortune"
description: "운세 기능 전체 생성. Edge Function, 모델, 서비스, 페이지, 라우트를 한 번에 생성합니다. 운세/궁합/타로/사주 등 새 기능 추가 시 사용."
---

# Fortune Feature Builder

운세 관련 기능을 처음부터 끝까지 완전하게 생성하는 워크플로우 스킬입니다.

---

## 사용법

```
/sc:feature-fortune 펫궁합
/sc:feature-fortune 연애운세
/sc:feature-fortune 타로3장
```

---

## 생성 파일 (8개)

| 순서 | 파일 | 설명 |
|------|------|------|
| 1 | `supabase/functions/fortune-{type}/index.ts` | Edge Function |
| 2 | `lib/features/fortune/domain/models/{type}_conditions.dart` | 입력 조건 모델 |
| 3 | `lib/features/fortune/domain/models/{type}_result.dart` | 결과 모델 |
| 4 | `lib/features/fortune/data/services/{type}_api_service.dart` | API 서비스 |
| 5 | `lib/features/fortune/presentation/pages/{type}_fortune_page.dart` | UI 페이지 |
| 6 | `lib/routes/routes/fortune_routes/{type}_routes.dart` | GoRouter 라우트 |
| 7 | `lib/core/constants/edge_functions_endpoints.dart` | 엔드포인트 상수 (추가) |
| 8 | `lib/core/constants/fortune_type_names.dart` | 타입 이름 (추가) |

---

## 워크플로우

```
1️⃣ 사용자 입력 수집
   - 운세 이름 (한글/영문)
   - 토큰 소비 레벨 (Simple/Medium/Complex/Premium)
   - 필수 입력 필드
   - 블러 섹션 4개

2️⃣ fortune-specialist 협업
   - 도메인 결정 검토
   - 비즈니스 로직 확인

3️⃣ 템플릿 기반 파일 생성
   - templates/ 폴더의 .template 파일 사용
   - 변수 치환 ({{type}}, {{typeName}}, 등)

4️⃣ 자동 검증
   - deno check (Edge Function)
   - dart run build_runner build
   - flutter analyze

5️⃣ quality-guardian 호출
   - 전체 품질 검증

6️⃣ 완료 보고
   - 생성된 파일 목록
   - 다음 단계 안내
```

---

## 사용자 질문

스킬 실행 시 다음을 질문합니다:

### 1. 운세 이름
```
운세 이름을 입력해주세요:
- 한글: 펫 궁합
- 영문 (snake_case): pet_compatibility
```

### 2. 토큰 소비 레벨
```
토큰 소비 레벨을 선택해주세요:
1. Simple (1토큰) - 단순 결과
2. Medium (2토큰) - 분석 포함
3. Complex (3토큰) - 심층 분석
4. Premium (5토큰) - 고급 분석
```

### 3. 입력 필드
```
필요한 입력 필드를 선택해주세요 (복수 선택):
- birthDate (생년월일) [필수]
- gender (성별) [필수]
- birthTime (태어난 시간)
- partnerBirthDate (상대방 생년월일)
- 기타 (직접 입력)
```

### 4. 블러 섹션
```
프리미엄이 아닌 사용자에게 블러 처리할 섹션 4개:
1. advice (조언)
2. future_outlook (미래 전망)
3. luck_items (행운 아이템)
4. warnings (주의사항)
5. 기타 (직접 입력)
```

---

## 템플릿 변수

| 변수 | 설명 | 예시 |
|------|------|------|
| `{{type}}` | 영문 snake_case | `pet_compatibility` |
| `{{typeCamel}}` | camelCase | `petCompatibility` |
| `{{typePascal}}` | PascalCase | `PetCompatibility` |
| `{{typeKebab}}` | kebab-case | `pet-compatibility` |
| `{{typeName}}` | 한글 이름 | `펫 궁합` |
| `{{tokenCost}}` | 토큰 비용 | `2` |
| `{{inputFields}}` | 입력 필드 목록 | `birthDate, petType` |
| `{{blurredSections}}` | 블러 섹션 | `advice, future_outlook` |

---

## 검증 단계

### 1. Edge Function 검증
```bash
deno check supabase/functions/fortune-{type}/index.ts
```

### 2. Dart 코드 생성
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Flutter 분석
```bash
flutter analyze lib/features/fortune/
```

### 4. 품질 검증
- quality-guardian 자동 호출

---

## 완료 메시지

```
✅ 펫 궁합 운세 기능이 생성되었습니다!

📁 생성된 파일:
1. supabase/functions/fortune-pet-compatibility/index.ts
2. lib/features/fortune/domain/models/pet_compatibility_conditions.dart
3. lib/features/fortune/domain/models/pet_compatibility_result.dart
4. lib/features/fortune/data/services/pet_compatibility_api_service.dart
5. lib/features/fortune/presentation/pages/pet_compatibility_fortune_page.dart
6. lib/routes/routes/fortune_routes/pet_compatibility_routes.dart
7. lib/core/constants/edge_functions_endpoints.dart (업데이트)
8. lib/core/constants/fortune_type_names.dart (업데이트)

🔧 다음 단계:
1. Edge Function 배포: supabase functions deploy fortune-pet-compatibility
2. 앱 테스트: localhost:3000/fortune/pet-compatibility

채팅에 추천 칩도 추가할까요? (Y/n)
```

---

## 연계 스킬

- 완료 후 `/sc:feature-chat` 제안 (추천 칩 추가)
- 완료 후 `quality-guardian` 자동 호출