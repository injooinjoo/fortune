# 🌙 꿈해몽 (Dream Interpretation) 가이드

> **최종 업데이트**: 2025년 1월 17일  
> **카테고리**: 특별 운세  
> **필수 입력**: 꿈 내용

## 📋 목차
1. [개요](#개요)
2. [기능 구성](#기능-구성)
3. [구현 상세](#구현-상세)
4. [API 명세](#api-명세)
5. [음성 입력 기능](#음성-입력-기능)
6. [UI 구현 예제](#ui-구현-예제)

## 개요

꿈해몽은 사용자가 입력한 꿈 내용을 기반으로 심리적, 상징적 의미를 해석하고 실생활에 적용할 수 있는 조언을 제공하는 특별 운세입니다. **꿈 내용 입력 없이는 해석이 불가능합니다.** 텍스트와 음성 입력을 모두 지원하며, 세 가지 형태의 페이지를 제공합니다.

### 주요 특징
- 🎤 음성/텍스트 입력 지원
- 📊 심리학적 해석과 상징 분석
- 🍀 행운 요소 추천 (색상, 숫자, 방향, 아이템)
- 📔 꿈 일기 기능
- 💯 종합 운세 점수 (1-100)

## 기능 구성

### 1. 꿈 운세 페이지 (`/fortune/dream`)
**파일**: `fortune_flutter/lib/features/fortune/presentation/pages/dream_fortune_page.dart`

- 텍스트/음성 입력 모드 전환
- 꿈 카테고리 제안 (동물, 사람, 장소, 행동, 물건, 자연)
- 심리학적, 상징적, 실용적 해석
- 상징 의미 분석

### 2. 꿈 일기 (`/interactive/dream-journal`)
**파일**: `fortune_flutter/lib/features/interactive/presentation/pages/dream_page.dart`

- 꿈 기록 저장
- 카테고리별 태그 지정
- 꿈 히스토리 조회
- AI 분석 및 운세 점수

### 3. 대화형 꿈 해석 (`/interactive/dream`)
**파일**: `fortune_flutter/lib/features/interactive/presentation/pages/dream_interpretation_page.dart`

- 사용자 정보 기반 맞춤 해석
- 종합 운세 점수
- 상세 해석 및 조언
- 행운 요소 추천

## 구현 상세

### Edge Function
**경로**: `supabase/functions/fortune-dream/index.ts`

```typescript
// 주요 구조
interface DreamFortuneResponse {
  title: string;              // 꿈 제목
  overallScore: number;       // 종합 점수 (1-100)
  description: string;        // 요약 설명
  interpretation: {
    psychological: string;    // 심리학적 해석
    symbolic: string;         // 상징적 의미
    practical: string;        // 실용적 조언
  };
  symbols: Array<{
    symbol: string;          // 상징 요소
    meaning: string;         // 의미
  }>;
  luckyElements: {
    colors: string[];        // 행운의 색상
    numbers: number[];       // 행운의 숫자
    directions: string[];    // 행운의 방향
    items: string[];         // 행운의 아이템
  };
  advice: string;            // 조언
  warnings: string[];        // 주의사항
  affirmations: string[];    // 긍정 확언
}
```

### 사용 흐름
1. **꿈 내용 입력** (필수)
   - 텍스트 입력: 꿈 내용을 직접 타이핑
   - 음성 입력: 마이크를 통해 꿈 내용 녹음
2. **AI 분석**
   - 입력된 꿈 내용을 기반으로 해석
3. **결과 제공**
   - 심리학적/상징적 해석
   - 행운 요소 추천

## API 명세

### 요청
```http
POST /fortune-dream
Authorization: Bearer {token}
Content-Type: application/json

{
  "dreamContent": "높은 산을 오르는 꿈을 꾸었습니다...",
  "inputType": "text" // 또는 "voice"
}
```

### 응답
```json
{
  "success": true,
  "data": {
    "title": "도전과 성취의 꿈",
    "overallScore": 85,
    "description": "높은 목표를 향한 당신의 열망과 도전 정신을 나타냅니다.",
    "interpretation": {
      "psychological": "무의식 속의 성취욕과 자기 극복 의지...",
      "symbolic": "산은 인생의 도전과 목표를 상징...",
      "practical": "실제로 새로운 프로젝트나 목표 설정의 시기..."
    },
    "symbols": [
      {
        "symbol": "산",
        "meaning": "도전, 목표, 성취"
      },
      {
        "symbol": "오르기",
        "meaning": "노력, 진보, 성장"
      }
    ],
    "luckyElements": {
      "colors": ["초록색", "갈색"],
      "numbers": [3, 7, 9],
      "directions": ["북쪽", "동쪽"],
      "items": ["등산화", "나침반"]
    },
    "advice": "단계적인 목표 설정이 중요합니다...",
    "warnings": ["무리한 도전은 피하세요"],
    "affirmations": ["나는 모든 도전을 극복할 수 있다"]
  }
}
```

## 음성 입력 기능

### Speech Recognition Service
**파일**: `fortune_flutter/lib/services/speech_recognition_service.dart`

```dart
class SpeechRecognitionService {
  // 한국어 지원
  static const String _localeId = 'ko-KR';
  
  // 권한 처리
  Future<bool> _requestPermission() async {
    // iOS/Android 마이크 권한 요청
  }
  
  // 음성 인식 시작
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    // 실시간 음성-텍스트 변환
  }
}
```

### 권한 설정

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>꿈 내용을 음성으로 입력하기 위해 음성 인식 권한이 필요합니다.</string>
<key>NSMicrophoneUsageDescription</key>
<string>꿈 내용을 음성으로 녹음하기 위해 마이크 권한이 필요합니다.</string>
```

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

## UI 구현 예제

### 꿈 카테고리 칩
```dart
// 꿈 카테고리 제안
final dreamCategories = [
  '동물이 나오는 꿈',
  '사람을 만나는 꿈',
  '특정 장소의 꿈',
  '행동하는 꿈',
  '물건이 나오는 꿈',
  '자연 현상의 꿈',
];

Wrap(
  spacing: 8,
  runSpacing: 8,
  children: dreamCategories.map((category) => 
    ActionChip(
      label: Text(category),
      onPressed: () => _appendToDream(category),
    )
  ).toList(),
)
```

### 음성 입력 버튼
```dart
IconButton(
  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
  onPressed: _toggleVoiceInput,
  color: _isListening ? Colors.red : null,
)
```

### 결과 표시
```dart
// 심리학적 해석 카드
Card(
  child: ListTile(
    leading: Icon(Icons.psychology),
    title: Text('심리학적 해석'),
    subtitle: Text(result.interpretation.psychological),
  ),
)

// 행운 요소 표시
GridView.count(
  crossAxisCount: 2,
  children: [
    _buildLuckyElement('색상', result.luckyElements.colors),
    _buildLuckyElement('숫자', result.luckyElements.numbers),
    _buildLuckyElement('방향', result.luckyElements.directions),
    _buildLuckyElement('아이템', result.luckyElements.items),
  ],
)
```

## 사용 예시

### 1. 꿈 내용 입력 필수 확인
```dart
// 꿈 내용이 없으면 해석 불가
if (dreamContent.isEmpty) {
  showSnackBar('꿈 내용을 입력해주세요');
  return;
}

// FortuneApiService 사용
final result = await fortuneApiService.getDreamFortune(
  dreamContent: dreamContent, // 필수 입력값
);
```

### 2. 음성 입력
```dart
await speechService.startListening(
  onResult: (text) {
    setState(() => _dreamContent = text);
  },
  onError: (error) {
    showSnackBar('음성 인식 오류: $error');
  },
);
```

### 3. 꿈 일기 저장
```dart
await dreamJournalService.saveDream(
  title: "높은 산을 오르는 꿈",
  content: dreamContent,
  tags: ['도전', '성취'],
  interpretation: result,
);
```

## 꿈 입력 가이드

### 효과적인 꿈 내용 작성법
1. **구체적인 내용**: "높은 산을 오르는 꿈"보다 "가파른 바위산을 맨발로 오르며 정상에서 해가 떠오르는 것을 본 꿈"
2. **감정 포함**: 꿈에서 느낀 감정도 함께 설명
3. **주요 상징**: 꿈에 나타난 특별한 물건, 사람, 동물 등을 명시

### 음성 입력 팁
1. **녹음 시작 전**: 꿈 내용을 머릿속으로 정리
2. **천천히 말하기**: 음성 인식이 정확하게 될 수 있도록
3. **주변 소음 최소화**: 조용한 환경에서 녹음

## 관련 문서
- [FORTUNE_TYPES_LIST.md](../FORTUNE_TYPES_LIST.md) - 전체 운세 타입 목록
- [EDGE_FUNCTIONS_COMPLETE_GUIDE.md](../EDGE_FUNCTIONS_COMPLETE_GUIDE.md) - Edge Functions 가이드
- [SPEECH_RECOGNITION_GUIDE.md](./SPEECH_RECOGNITION_GUIDE.md) - 음성 인식 상세 가이드