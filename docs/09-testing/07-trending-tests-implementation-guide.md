# 트렌딩 심리 테스트 기능 구현 가이드 🧠

## 📋 개요
Feed 페이지에 15개 이상의 트렌딩 심리 테스트를 추가하는 가이드입니다.

## 🎯 구현 목표
- 다양한 심리 테스트 제공
- 결과 공유 기능
- 통계 및 랭킹 시스템
- 토큰 사용 없는 무료 테스트

## 📝 심리 테스트 목록 (15개+)

### 1. 성격 관련 테스트
1. **내 안의 숨겨진 성격 찾기**
   - 10개 질문
   - 4가지 성격 유형 결과
   - 동물 캐릭터로 표현

2. **스트레스 지수 테스트**
   - 15개 질문
   - 스트레스 레벨 1-10
   - 맞춤형 해소법 제안

3. **리더십 스타일 진단**
   - 12개 질문
   - 6가지 리더십 유형
   - 장단점 분석

### 2. 연애 관련 테스트
4. **이상형 찾기 테스트**
   - 20개 질문
   - 이상형 프로필 생성
   - 매칭 퍼센트 표시

5. **연애 성향 분석**
   - 15개 질문
   - 4가지 연애 스타일
   - 궁합 좋은 타입 소개

6. **첫인상 매력도 테스트**
   - 10개 질문
   - 매력 포인트 분석
   - 개선 팁 제공

### 3. 직업/재능 관련 테스트
7. **숨겨진 재능 발견하기**
   - 18개 질문
   - 5가지 재능 영역
   - 개발 방법 제시

8. **미래 직업 적성 테스트**
   - 25개 질문
   - 추천 직업 5개
   - 필요 스킬 안내

9. **창업가 정신 지수**
   - 15개 질문
   - 창업 적합도 %
   - 성공 전략 제안

### 4. 심리/정서 관련 테스트
10. **감정 지능(EQ) 테스트**
    - 20개 질문
    - EQ 점수 산출
    - 향상 방법 가이드

11. **행복 지수 측정**
    - 12개 질문
    - 행복도 레벨
    - 행복 증진 팁

12. **불안 성향 진단**
    - 15개 질문
    - 불안 유형 분석
    - 대처 방법 제공

### 5. 재미/오락성 테스트
13. **전생 체험 테스트**
    - 10개 질문
    - 전생 캐릭터 결과
    - 스토리텔링 요소

14. **숨은 초능력 찾기**
    - 8개 질문
    - 초능력 타입 결정
    - 재미있는 설명

15. **나와 어울리는 색깔**
    - 12개 질문
    - 퍼스널 컬러 진단
    - 스타일링 팁

### 추가 테스트 아이디어
16. **금전운 성향 분석**
17. **우정 스타일 테스트**
18. **멘탈 강도 측정**
19. **창의력 지수 테스트**
20. **의사결정 스타일 진단**

## 🏗️ 기술 구현

### 1. 데이터 모델
```dart
// test_model.dart
class PsychologicalTest {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String category;
  final List<TestQuestion> questions;
  final List<TestResult> results;
  final int participantCount;
  final double averageRating;
  final bool isTrending;
  final DateTime createdAt;
  
  // 결과 계산 로직
  TestResult calculateResult(List<int> answers) {
    // 답변에 따른 점수 계산
    // 결과 타입 결정
  }
}

class TestQuestion {
  final String id;
  final String question;
  final List<TestOption> options;
  final String? imageUrl;
}

class TestOption {
  final String id;
  final String text;
  final int score;
  final String? emoji;
}

class TestResult {
  final String type;
  final String title;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> details;
  final List<String> recommendations;
}
```

### 2. UI 구현
```dart
// trending_test_page.dart
class TrendingTestPage extends StatefulWidget {
  final String testId;
  
  @override
  _TrendingTestPageState createState() => _TrendingTestPageState();
}

class _TrendingTestPageState extends State<TrendingTestPage> {
  int currentQuestion = 0;
  List<int> answers = [];
  bool showResult = false;
  TestResult? result;
  
  Widget _buildQuestion(TestQuestion question) {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (currentQuestion + 1) / test.questions.length,
        ),
        
        // Question
        Text(
          question.question,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        
        // Options
        ...question.options.map((option) => 
          _buildOptionCard(option)
        ),
      ],
    );
  }
  
  Widget _buildResult() {
    return Column(
      children: [
        // Result image
        Image.asset(result!.imageUrl),
        
        // Result title
        Text(
          result!.title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        
        // Description
        Text(result!.description),
        
        // Share buttons
        Row(
          children: [
            ShareButton(platform: 'kakao'),
            ShareButton(platform: 'instagram'),
            CopyLinkButton(),
          ],
        ),
        
        // Retry button
        ElevatedButton(
          onPressed: () => _resetTest(),
          child: Text('다시 해보기'),
        ),
      ],
    );
  }
}
```

### 3. 상태 관리
```dart
// test_provider.dart
final trendingTestsProvider = FutureProvider<List<PsychologicalTest>>((ref) async {
  // Supabase에서 트렌딩 테스트 가져오기
  final response = await supabase
    .from('psychological_tests')
    .select()
    .eq('is_active', true)
    .order('participant_count', ascending: false)
    .limit(20);
    
  return response.map((e) => PsychologicalTest.fromJson(e)).toList();
});

final testProgressProvider = StateNotifierProvider<TestProgressNotifier, TestProgress>(
  (ref) => TestProgressNotifier(),
);

class TestProgressNotifier extends StateNotifier<TestProgress> {
  TestProgressNotifier() : super(TestProgress.initial());
  
  void answerQuestion(int questionIndex, int answerIndex) {
    state = state.copyWith(
      currentQuestion: state.currentQuestion + 1,
      answers: [...state.answers, answerIndex],
    );
  }
  
  void calculateResult(PsychologicalTest test) {
    final result = test.calculateResult(state.answers);
    state = state.copyWith(
      isComplete: true,
      result: result,
    );
  }
}
```

### 4. 데이터베이스 스키마
```sql
-- 심리 테스트 테이블
CREATE TABLE psychological_tests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  emoji VARCHAR(10),
  category VARCHAR(50),
  questions JSONB NOT NULL,
  results JSONB NOT NULL,
  participant_count INTEGER DEFAULT 0,
  total_rating INTEGER DEFAULT 0,
  rating_count INTEGER DEFAULT 0,
  is_trending BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 테스트 참여 기록
CREATE TABLE test_participations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  test_id UUID REFERENCES psychological_tests(id),
  answers JSONB NOT NULL,
  result_type VARCHAR(50),
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 테스트 평가
CREATE TABLE test_ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  test_id UUID REFERENCES psychological_tests(id),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, test_id)
);
```

### 5. Edge Function
```typescript
// get-trending-tests
export async function handler(req: Request) {
  const { data: tests } = await supabase
    .from('psychological_tests')
    .select(`
      *,
      average_rating: total_rating / NULLIF(rating_count, 0)
    `)
    .eq('is_active', true)
    .order('participant_count', { ascending: false })
    .limit(15);
    
  // 트렌딩 마크 업데이트
  const trendingIds = tests.slice(0, 5).map(t => t.id);
  await supabase
    .from('psychological_tests')
    .update({ is_trending: true })
    .in('id', trendingIds);
    
  return new Response(JSON.stringify(tests), {
    headers: { 'Content-Type': 'application/json' },
  });
}
```

## 🎨 UI/UX 가이드라인

### 1. 목록 화면
- 카드 형태로 테스트 표시
- 참여자 수, 평점 표시
- 카테고리별 필터링
- 무한 스크롤

### 2. 테스트 진행 화면
- 진행률 표시 (Progress Bar)
- 이전 질문으로 돌아가기
- 애니메이션 전환 효과
- 시간 제한 옵션 (선택사항)

### 3. 결과 화면
- 시각적인 결과 표현
- 공유하기 쉬운 이미지 생성
- 다른 사용자들의 통계
- 관련 운세 추천

## 📊 분석 및 통계

### 1. 사용자 분석
```dart
// 인기 테스트 순위
// 카테고리별 선호도
// 완료율 통계
// 평균 소요 시간
```

### 2. A/B 테스팅
- 질문 순서 변경
- 결과 표현 방식
- UI 레이아웃

## 🚀 배포 전략

### Phase 1 (MVP)
- 5개 기본 테스트 출시
- 기본 공유 기능
- 참여 통계

### Phase 2
- 10개 추가 테스트
- 결과 이미지 커스터마이징
- 친구와 비교 기능

### Phase 3
- 사용자 제작 테스트
- 테스트 추천 알고리즘
- 보상 시스템

## ✅ 체크리스트

### 개발
- [ ] 테스트 데이터 모델 설계
- [ ] UI 컴포넌트 개발
- [ ] 상태 관리 구현
- [ ] 데이터베이스 스키마 생성
- [ ] API 엔드포인트 개발

### 콘텐츠
- [ ] 15개 테스트 기획
- [ ] 질문 및 답변 작성
- [ ] 결과 유형 정의
- [ ] 이미지/일러스트 준비

### 테스트
- [ ] 각 테스트 로직 검증
- [ ] UI/UX 사용성 테스트
- [ ] 성능 최적화
- [ ] 공유 기능 테스트

---

**Note**: 심리 테스트는 재미와 엔터테인먼트 목적으로만 제공되며, 전문적인 심리 상담을 대체할 수 없음을 명시해야 합니다.