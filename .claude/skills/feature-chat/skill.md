---
name: "sc:feature-chat"
description: "채팅 기능 통합. 추천 칩 추가, 운세 결과 → 채팅 메시지 변환, 채팅 UI 수정 시 사용."
---

# Chat Feature Builder

채팅 관련 기능을 추가하거나 수정하는 워크플로우 스킬입니다.

---

## 사용법

```
/sc:feature-chat 추천 칩에 펫궁합 추가
/sc:feature-chat 운세 결과 메시지 형식 변경
/sc:feature-chat 채팅 홈 레이아웃 수정
```

---

## 주요 작업 유형

### 1. 추천 칩 추가
새로운 운세 유형을 추천 칩에 추가

**수정 파일**:
- `lib/features/chat/domain/models/recommendation_chip.dart`
- `lib/features/chat/presentation/providers/chat_recommendations_provider.dart`

### 2. 운세 결과 변환기 추가
운세 결과를 채팅 메시지로 변환하는 로직 추가

**생성 파일**:
- `lib/features/chat/domain/converters/{type}_converter.dart`

### 3. 채팅 UI 수정
채팅 화면 레이아웃, 스타일 변경

**수정 파일**:
- `lib/features/chat/presentation/pages/chat_home_page.dart`
- `lib/features/chat/presentation/widgets/`

---

## 워크플로우

```
1️⃣ 작업 유형 파악
   - 추천 칩 추가?
   - 변환기 추가?
   - UI 수정?

2️⃣ 기존 패턴 분석
   - 현재 추천 칩 목록 확인
   - 기존 변환기 패턴 확인

3️⃣ 파일 생성/수정
   - 템플릿 기반 생성
   - 기존 파일에 추가

4️⃣ quality-guardian 호출
```

---

## 추천 칩 추가 예시

### 입력
```
/sc:feature-chat 추천 칩에 펫궁합 추가
```

### 수정 내용

**recommendation_chip.dart**:
```dart
enum FortuneChipType {
  // ... 기존 칩들
  petCompatibility,  // 추가
}
```

**chat_recommendations_provider.dart**:
```dart
RecommendationChip(
  type: FortuneChipType.petCompatibility,
  label: '펫 궁합',
  icon: Icons.pets,
  route: '/fortune/pet-compatibility',
),
```

---

## 변환기 패턴

### 템플릿 (converter.dart.template)
```dart
import '../models/chat_message.dart';
import '../../../fortune/domain/models/{{type}}_result.dart';

class {{typePascal}}Converter {
  static List<ChatMessage> convert({{typePascal}}Result result) {
    return [
      ChatMessage.fortuneResult(
        fortuneType: '{{typeName}}',
        result: result,
        isBlurred: result.isBlurred,
        blurredSections: result.blurredSections,
      ),
    ];
  }
}
```

---

## Chat-First 아키텍처 규칙

### 메시지 타입
```dart
enum ChatMessageType {
  user,           // 사용자 입력
  ai,             // AI 응답 텍스트
  fortuneResult,  // 운세 결과 카드
  loading,        // 로딩 상태
  system,         // 시스템 메시지
}
```

### 상태 관리
```dart
class ChatMessagesNotifier extends StateNotifier<ChatState> {
  void addMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }
}
```

---

## 완료 메시지

```
✅ 채팅 기능이 업데이트되었습니다!

📁 수정된 파일:
1. lib/features/chat/domain/models/recommendation_chip.dart
2. lib/features/chat/presentation/providers/chat_recommendations_provider.dart

🔧 다음 단계:
- 앱에서 채팅 홈 화면 확인
- 추천 칩 동작 테스트
```