# Chat-First Architecture Guide

> 최종 업데이트: 2025.01.03

## 통계

| 항목 | 수치 |
|------|------|
| 총 파일 수 | 46개 |
| 모델 | 6개 |
| Provider | 3개 |
| 페이지 | 1개 |
| 위젯 | 17개 |
| Survey 위젯 | 18개 |
| 결과 카드 | 8개 (NEW) |

## 개요

Fortune 앱의 핵심 진입점을 채팅 인터페이스로 전환하는 아키텍처 가이드.

**핵심 원칙**:
1. 모든 인사이트 → 채팅 인터페이스로 통합 진입
2. 인사이트 결과 → 채팅 메시지로 변환 표시
3. 추천 칩 → 컨텍스트 기반 동적 큐레이션

---

## 네비게이션 구조

### 5탭 구조
```
Home(채팅) | 인사이트 | 탐구 | 트렌드 | 프로필
    0          1         2        3        4
```

| 탭 | 경로 | 역할 |
|----|------|------|
| Home | `/chat` | 통합 채팅 진입점 (NEW) |
| 인사이트 | `/home` | 일일 인사이트 대시보드 |
| 탐구 | `/fortune` | 인사이트 카테고리 + Face AI |
| 트렌드 | `/trend` | 트렌드 콘텐츠 |
| 프로필 | `/profile` | 설정 + Premium |

### 변경 사항
- Face AI: `/face-ai` → `/fortune/face-ai` (탐구 내 카드)
- Premium: 독립 탭 → 프로필 내부 이동

---

## Chat Feature 구조

```
lib/features/chat/                      # 46개 파일
├── data/
│   └── services/
│       └── fortune_recommend_service.dart  # 인사이트 추천 서비스
├── domain/
│   ├── models/
│   │   ├── chat_message.dart           # ChatMessage 모델
│   │   ├── chat_state.dart             # ChatState 모델
│   │   ├── recommendation_chip.dart    # 추천 칩 모델
│   │   ├── ai_recommendation.dart      # AI 추천 모델
│   │   └── fortune_survey_config.dart  # 설문 설정 모델
│   ├── configs/
│   │   └── survey_configs.dart         # 39개 인사이트 설문 설정
│   └── services/
│       └── intent_detector.dart        # 의도 분석 서비스
├── presentation/
│   ├── providers/
│   │   ├── chat_messages_provider.dart     # 메인 StateNotifier
│   │   ├── chat_survey_provider.dart       # 설문 상태 관리
│   │   └── onboarding_chat_provider.dart   # 온보딩 채팅
│   ├── pages/
│   │   └── chat_home_page.dart         # 메인 채팅 페이지
│   └── widgets/
│       ├── chat_message_bubble.dart    # 메시지 버블
│       ├── chat_message_list.dart      # 메시지 리스트
│       ├── fortune_chip_grid.dart      # 추천 칩 그리드
│       ├── chat_welcome_view.dart      # 환영 화면
│       ├── chat_blur_overlay.dart      # 블러 오버레이
│       ├── guest_login_banner.dart     # 게스트 로그인 배너
│       ├── profile_bottom_sheet.dart   # 프로필 바텀시트
│       ├── month_highlight_detail_bottom_sheet.dart  # 월별 하이라이트
│       │
│       ├── # 인사이트별 결과 카드 (8개) ─────────────────
│       ├── chat_fortune_result_card.dart   # 범용 결과 카드
│       ├── chat_tarot_result_card.dart     # 타로 결과
│       ├── chat_saju_result_card.dart      # 사주 결과
│       ├── chat_career_result_card.dart    # 커리어 결과
│       ├── chat_celebrity_result_card.dart # 셀럽 매칭 결과
│       ├── chat_past_life_result_card.dart # 전생 분석 결과
│       ├── chat_ootd_result_card.dart      # 오늘의 코디 결과
│       ├── chat_match_insight_card.dart    # 매칭 인사이트 결과
│       │
│       └── survey/                     # 설문 위젯 (18개)
│           ├── fortune_type_chips.dart         # 인사이트 타입 칩
│           ├── chat_survey_chips.dart          # 설문 칩
│           ├── chat_survey_slider.dart         # 슬라이더
│           ├── chat_date_picker.dart           # 날짜 선택
│           ├── chat_birth_datetime_picker.dart # 생년월일 선택
│           ├── chat_profile_selector.dart      # 프로필 선택
│           ├── chat_match_selector.dart        # 매칭 선택
│           ├── chat_celebrity_selector.dart    # 셀럽 선택
│           ├── chat_pet_profile_selector.dart  # 펫 프로필 선택
│           ├── chat_pet_registration_form.dart # 펫 등록 폼
│           ├── chat_investment_category_selector.dart  # 투자 카테고리
│           ├── chat_investment_ticker_selector.dart    # 티커 선택
│           ├── chat_tarot_flow.dart            # 타로 플로우
│           ├── chat_face_reading_flow.dart     # 관상 플로우
│           ├── chat_voice_input.dart           # 음성 입력
│           ├── chat_image_input.dart           # 이미지 입력
│           ├── chat_inline_calendar.dart       # 인라인 캘린더
│           └── chat_onboarding_inputs.dart     # 온보딩 입력
```

---

## 핵심 모델

### ChatMessage

```dart
enum ChatMessageType {
  user,           // 사용자 입력
  ai,             // AI 텍스트 응답
  fortuneResult,  // 운세 결과 (섹션별)
  loading,        // 로딩 표시
  system,         // 시스템 메시지
}

class ChatMessage {
  final String id;
  final ChatMessageType type;
  final String? text;
  final FortuneResult? fortuneResult;
  final DateTime timestamp;

  // 블러 처리
  final bool isBlurred;
  final List<String> blurredSections;

  // 인사이트 결과용
  final String? fortuneType;
  final String? sectionKey;

  // 추천 칩
  final List<RecommendationChip>? chips;

  const ChatMessage({...});
  ChatMessage copyWith({...});
}
```

### ChatState

```dart
class ChatState {
  final List<ChatMessage> messages;
  final bool isProcessing;
  final bool isTyping;
  final String? currentFortuneType;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isProcessing = false,
    this.isTyping = false,
    this.currentFortuneType,
    this.error,
  });

  ChatState copyWith({...});
}
```

### RecommendationChip

```dart
class RecommendationChip {
  final String id;
  final String label;
  final String fortuneType;
  final IconData icon;
  final Color color;

  const RecommendationChip({...});
}
```

---

## ChatMessagesNotifier (StateNotifier)

```dart
class ChatMessagesNotifier extends StateNotifier<ChatState> {
  final Ref ref;

  ChatMessagesNotifier(this.ref) : super(const ChatState());

  // 사용자 메시지 추가
  void addUserMessage(String text) {
    final message = ChatMessage(
      id: uuid.v4(),
      type: ChatMessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  // 타이핑 표시
  void showTypingIndicator() {
    state = state.copyWith(isTyping: true);
  }

  void hideTypingIndicator() {
    state = state.copyWith(isTyping: false);
  }

  // 인사이트 결과 → 채팅 메시지 변환 후 추가
  Future<void> addFortuneResult(FortuneResult result) async {
    final messages = FortuneResultConverter.convert(result);

    // 순차적 애니메이션 표시
    for (final message in messages) {
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        messages: [...state.messages, message],
      );
    }
  }

  // 블러 해제
  void unblurMessage(String messageId) {
    final updated = state.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(isBlurred: false);
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updated);
  }

  // 대화 초기화
  void clearConversation() {
    state = const ChatState();
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, ChatState>(
  (ref) => ChatMessagesNotifier(ref),
);
```

---

## FortuneResult → ChatMessage 변환

### 변환 규칙

1. **요약 메시지**: 항상 공개 (점수, 제목)
2. **상세 섹션**: 개별 메시지로 분리, 블러 적용
3. **후속 추천**: 마지막에 추천 칩 표시

### FortuneResultConverter (인사이트 결과 변환)

```dart
class FortuneResultConverter {
  static List<ChatMessage> convert(FortuneResult result) {
    final messages = <ChatMessage>[];

    // 1. 요약 메시지 (공개)
    messages.add(ChatMessage(
      id: uuid.v4(),
      type: ChatMessageType.fortuneResult,
      sectionKey: 'summary',
      text: _buildSummaryText(result),
      fortuneType: result.type,
      isBlurred: false,
      timestamp: DateTime.now(),
    ));

    // 2. 상세 섹션들
    final sections = _getSections(result);
    for (final section in sections) {
      final isBlurred = result.isBlurred &&
                       result.blurredSections.contains(section.key);

      messages.add(ChatMessage(
        id: uuid.v4(),
        type: ChatMessageType.fortuneResult,
        sectionKey: section.key,
        text: section.content,
        fortuneType: result.type,
        isBlurred: isBlurred,
        timestamp: DateTime.now(),
      ));
    }

    // 3. 후속 추천 칩
    messages.add(ChatMessage(
      id: uuid.v4(),
      type: ChatMessageType.system,
      chips: _generateFollowUpChips(result),
      timestamp: DateTime.now(),
    ));

    return messages;
  }

  static List<_Section> _getSections(FortuneResult result) {
    switch (result.type) {
      case 'investment':
        return [
          _Section('ticker', result.data['ticker']),
          _Section('content', result.data['content']),
          _Section('luckyItems', result.data['luckyItems']),
          _Section('timing', result.data['timing']),      // 블러
          _Section('outlook', result.data['outlook']),    // 블러
          _Section('risks', result.data['risks']),        // 블러
          _Section('advice', result.data['advice']),      // 블러
        ];
      case 'tarot':
        return [
          _Section('cards', result.data['cards']),
          _Section('interpretation', result.data['interpretation']),
          _Section('advice', result.data['advice']),      // 블러
        ];
      // ... 다른 운세 타입
      default:
        return [_Section('content', result.data['content'])];
    }
  }
}
```

---

## 추천 칩 큐레이션

### 원칙

1. **관련성**: 현재 인사이트와 연관된 유형 우선
2. **컨텍스트**: 시간대, 사용자 프로필 반영
3. **인기도**: 인기 인사이트 보조 추천
4. **제한**: 최대 5개 칩 표시

### 큐레이션 로직

```dart
List<RecommendationChip> curateChips({
  FortuneResult? currentResult,
  UserProfile? profile,
  required DateTime now,
}) {
  final chips = <RecommendationChip>[];

  // 1. 관련성 기반 (최대 2개)
  if (currentResult != null) {
    chips.addAll(_getRelatedChips(currentResult));
  }

  // 2. 프로필 기반 (최대 1개)
  if (profile?.mbti != null) {
    chips.add(RecommendationChip(
      label: 'MBTI 분석',
      fortuneType: 'mbti',
      icon: Icons.psychology,
    ));
  }

  // 3. 시간 기반 (최대 1개)
  if (_isNightTime(now)) {
    chips.add(RecommendationChip(
      label: '내일 인사이트',
      fortuneType: 'tomorrow',
      icon: Icons.nights_stay,
    ));
  }

  // 4. 인기 기반 (부족 시)
  while (chips.length < 3) {
    chips.add(_getPopularChip());
  }

  return chips.take(5).toList();
}
```

### 기본 추천 칩 목록

```dart
const List<RecommendationChip> defaultChips = [
  RecommendationChip(
    label: '오늘의 메시지',
    fortuneType: 'daily',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFF7C3AED),
  ),
  RecommendationChip(
    label: '연애 인사이트',
    fortuneType: 'love',
    icon: Icons.favorite_outline,
    color: Color(0xFFEC4899),
  ),
  RecommendationChip(
    label: '재물 인사이트',
    fortuneType: 'money',
    icon: Icons.attach_money,
    color: Color(0xFF16A34A),
  ),
  RecommendationChip(
    label: '타로',
    fortuneType: 'tarot',
    icon: Icons.style_outlined,
    color: Color(0xFF9333EA),
  ),
  RecommendationChip(
    label: '꿈 분석',
    fortuneType: 'dream',
    icon: Icons.cloud_outlined,
    color: Color(0xFF2563EB),
  ),
];
```

---

## 채팅 UI 흐름

### 환영 상태 (메시지 없음)

```
+----------------------------------+
|           Fortune Chat           |
+----------------------------------+
|                                  |
|        [AI 아바타 아이콘]          |
|                                  |
|   "오늘 무엇이 궁금하세요?"        |
|                                  |
|   [오늘 운세] [연애운] [재물운]     |
|   [타로] [꿈해몽]                  |
|                                  |
+----------------------------------+
|  [메시지 입력...]         [전송]   |
+----------------------------------+
```

### 대화 상태

```
+----------------------------------+
|           Fortune Chat           |
+----------------------------------+
| 나: 오늘 연애운 알려줘             |
|                                  |
| AI: [타이핑 중...]                |
|                                  |
| AI: +------------------------+   |
|     | 연애 점수: 85점         |   |
|     | 오늘은 좋은 만남이...   |   |
|     +------------------------+   |
|                                  |
| AI: +------------------------+   |
|     | 상세 조언              |   |
|     | [블러 처리됨]           |   |
|     | [잠금 해제]            |   |
|     +------------------------+   |
|                                  |
|     [궁합 보기] [내일 인사이트]    |
+----------------------------------+
|        [광고 보고 잠금 해제]        |
+----------------------------------+
|  [메시지 입력...]         [전송]   |
+----------------------------------+
```

---

## Edge Function 연동

### 채팅 → Edge Function 라우팅

```dart
Future<FortuneResult> requestFortune({
  required String fortuneType,
  required Map<String, dynamic> userInfo,
}) async {
  final response = await apiService.post(
    ApiEndpoints.generateFortune,
    data: {
      'type': fortuneType,
      'userInfo': userInfo,
    },
  );

  return FortuneResult.fromJson(response['data']);
}
```

### 의도 분석 (로컬)

```dart
String? analyzeIntent(String message) {
  final lower = message.toLowerCase();

  final patterns = {
    'daily': ['오늘', '운세', '하루'],
    'love': ['연애', '사랑', '애인', '결혼'],
    'money': ['재물', '돈', '금전', '투자'],
    'tarot': ['타로', '카드'],
    'dream': ['꿈', '해몽'],
    'faceReading': ['얼굴', '관상', '인상'],
  };

  for (final entry in patterns.entries) {
    if (entry.value.any((k) => lower.contains(k))) {
      return entry.key;
    }
  }

  return null; // 불명확 → 추천 칩 표시
}
```

---

## 블러/프리미엄 처리

### 채팅 내 블러

```dart
class ChatFortuneSection extends ConsumerWidget {
  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: _bubbleDecoration(context),
      child: UnifiedBlurWrapper(
        isBlurred: message.isBlurred,
        sectionKey: message.sectionKey ?? 'content',
        fortuneType: message.fortuneType,
        onUnlock: () => _handleUnlock(ref),
        child: _buildContent(context),
      ),
    );
  }

  void _handleUnlock(WidgetRef ref) {
    // 광고 시청 후 블러 해제
    ref.read(chatMessagesProvider.notifier)
       .unblurMessage(message.id);
  }
}
```

---

## 관련 파일 참조

| 파일 | 용도 |
|------|------|
| [02-architecture.md](02-architecture.md) | 전체 아키텍처 |
| [03-ui-design-system.md](03-ui-design-system.md) | 채팅 UI 스타일 |
| [04-state-management.md](04-state-management.md) | StateNotifier 패턴 |
| [05-fortune-system.md](05-fortune-system.md) | 인사이트 조회 프로세스 |

---

## 금지 사항

| 금지 | 이유 | 대안 |
|------|------|------|
| `@riverpod` 어노테이션 | 프로젝트 표준 | `StateNotifier` |
| 하드코딩 추천 칩 | 동적 큐레이션 필요 | `curateChips()` 사용 |
| `ImageFilter.blur` 직접 | 일관성 | `UnifiedBlurWrapper` |
| 채팅에서 직접 페이지 이동 | 채팅 흐름 유지 | 결과를 채팅으로 표시 |
