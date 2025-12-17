# Fortune App 상세 구현 기획서

**작성일**: 2025-12-17
**버전**: 1.0
**작성자**: Claude Code

---

## 1. 개요

### 1.1 목적
Fortune 앱의 남은 버그 수정 및 기능 개선을 체계적으로 수행하기 위한 상세 기획서

### 1.2 범위
- Critical 버그 4건 (1.1~1.4)
- Phase 2.3 네비게이션 개선
- Phase 3 기능 개선 9건 (3.1~3.9)

### 1.3 제외 범위
- 이미지 에셋 제작 필요 항목 (Phase 2.2 에셋 적용)
- 스플래시 화면 리뉴얼 (에셋 대기)

---

## 2. 코드베이스 패턴 분석 요약

### 2.1 블러 처리 패턴
```dart
// 표준 패턴: UnifiedBlurWrapper 사용
UnifiedBlurWrapper(
  isBlurred: fortuneResult.isBlurred,
  blurredSections: fortuneResult.blurredSections,
  sectionKey: 'advice',
  child: MyContentWidget(),
)

// 프리미엄 사용자 자동 해제 (initState에서)
if (isPremium && _fortuneResult.isBlurred) {
  setState(() {
    _fortuneResult = _fortuneResult.copyWith(
      isBlurred: false,
      blurredSections: [],
    );
  });
}
```

### 2.2 Edge Function 호출 패턴
```dart
// 요청 시 isPremium 전달 필수
final requestData = {
  ...data,
  'isPremium': ref.read(isPremiumProvider),
};

// Edge Function에서 블러 처리
const isBlurred = !isPremium;
const blurredSections = isBlurred ? ['section1', 'section2'] : [];
```

### 2.3 타로 이미지 경로 패턴
```dart
// Court Card 경로 (숫자 프리픽스 없음)
'page_of_wands.jpg'    // NOT '11_page_of_wands.jpg'
'knight_of_wands.jpg'  // NOT '12_knight_of_wands.jpg'
```

### 2.4 네비게이션 패턴
```dart
// 현재: 배지/닷 없음
// 필요: 안 본 운세에 빨간 점 표시
```

---

## 3. Critical 버그 상세 설계

### 3.1 [1.1] 해몽 기능 미작동

#### 3.1.1 현상
- 해몽 페이지에서 꿈 입력 후 결과가 표시되지 않음

#### 3.1.2 원인 분석
1. **Flutter 측**: `dream_interpretation_page.dart`
   - FloatingDreamBubbles 클릭 이벤트 확인 필요
   - DreamTopic.dreamContentForApi 데이터 전달 확인

2. **Edge Function 측**: `fortune-dream/index.ts`
   - 요청 필드명 불일치 가능성
   - 에러 핸들링 로깅 확인

#### 3.1.3 수정 계획
```
파일: lib/features/interactive/presentation/pages/dream_interpretation_page.dart
작업:
1. _onDreamTopicSelected 콜백 디버깅
2. _callDreamFortuneApi 요청 데이터 검증
3. 에러 핸들링 개선

파일: supabase/functions/fortune-dream/index.ts
작업:
1. 요청 필드 검증 로직 확인
2. 에러 로깅 강화
```

#### 3.1.4 검증 방법
- 개발 콘솔에서 네트워크 요청/응답 확인
- Edge Function 로그 확인

---

### 3.2 [1.2] MBTI 운세 일부 안됨

#### 3.2.1 현상
- 특정 MBTI 타입에서 운세 결과가 로드되지 않음

#### 3.2.2 원인 분석
1. **Flutter 측**: `mbti_fortune_page.dart`
   - MBTI 타입 전달 형식 확인
   - isPremium 상태 전달 확인

2. **Edge Function 측**: `fortune-mbti/index.ts`
   - 특정 타입 처리 예외 확인
   - LLM 프롬프트 호환성 확인

#### 3.2.3 수정 계획
```
파일: lib/features/fortune/presentation/pages/mbti_fortune/mbti_fortune_page.dart
작업:
1. MBTI 타입별 요청 데이터 검증
2. 에러 상태 UI 개선

파일: supabase/functions/fortune-mbti/index.ts
작업:
1. 16개 타입별 처리 로직 검토
2. 에러 케이스 로깅 추가
```

#### 3.2.4 검증 방법
- 16개 MBTI 타입 순차 테스트

---

### 3.3 [1.3] 타로 소드 시종 이미지 누락

#### 3.3.1 현상
- 소드의 시종(Page of Swords) 카드 이미지 404 에러

#### 3.3.2 원인 분석
**코드 경로 생성**: `swords/11_page_of_swords.jpg`
**실제 파일명**: `swords/page_of_swords.jpg`

Court Card에 숫자 프리픽스가 잘못 추가됨

#### 3.3.3 수정 계획
```dart
// 파일: lib/features/fortune/presentation/pages/tarot_summary/tarot_card_helpers.dart
// 라인: 129-135 (대략)

// 수정 전
return '$deckPath/$suit/${index}_${courtName}_of_$suit.jpg';

// 수정 후
return '$deckPath/$suit/${courtName}_of_$suit.jpg';
```

#### 3.3.4 영향 범위
- Wands: Page(11), Knight(12), Queen(13), King(14)
- Cups: Page(11), Knight(12), Queen(13), King(14)
- Swords: Page(11), Knight(12), Queen(13), King(14)
- Pentacles: Page(11), Knight(12), Queen(13), King(14)

총 16장의 Court Card 영향

#### 3.3.5 검증 방법
- 타로 결과 페이지에서 Court Card 이미지 로드 확인
- 에셋 파일 존재 여부 재확인

---

### 3.4 [1.4] 연애운 블러 오류

#### 3.4.1 현상
- 프리미엄 구독자도 블러 처리됨
- 또는 비구독자에게 블러가 적용되지 않음

#### 3.4.2 원인 분석
```dart
// 현재 문제: FortuneResult.isBlurred가 구독 상태와 무관하게 판단
// 필요: isPremiumProvider 체크 추가
```

#### 3.4.3 수정 계획
```dart
// 파일: lib/features/fortune/presentation/pages/love/love_fortune_result_page.dart
// 라인: 159 부근 (initState)

@override
void initState() {
  super.initState();
  _fortuneResult = widget.fortuneResult;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // ✅ 프리미엄 사용자 자동 블러 해제 추가
    final isPremium = ref.read(isPremiumProvider);
    if (isPremium && _fortuneResult.isBlurred) {
      setState(() {
        _fortuneResult = _fortuneResult.copyWith(
          isBlurred: false,
          blurredSections: [],
        );
      });
    }
  });
}
```

#### 3.4.4 추가 확인 사항
- Edge Function에서 isPremium 전달 여부 확인
- 다른 운세 페이지와 패턴 일치 확인

---

## 4. Phase 2.3 네비게이션 개선

### 4.1 요구사항
- 운세 탭에 "안 본 운세" 빨간 점 표시

### 4.2 설계

#### 4.2.1 상태 관리
```dart
// 새 Provider 생성
// 파일: lib/presentation/providers/unread_fortune_provider.dart

final unreadFortuneCountProvider = StateProvider<int>((ref) => 0);

final hasUnreadFortuneProvider = Provider<bool>((ref) {
  return ref.watch(unreadFortuneCountProvider) > 0;
});
```

#### 4.2.2 UI 수정
```dart
// 파일: lib/shared/components/bottom_navigation_bar.dart

// 운세 탭 아이템에 Badge 추가
_NavItem(
  icon: Icons.auto_awesome_outlined,
  selectedIcon: Icons.auto_awesome,
  label: '운세',
  route: '/fortune',
  showBadge: ref.watch(hasUnreadFortuneProvider),  // 추가
),
```

#### 4.2.3 Badge 위젯
```dart
Widget _buildNavItemWithBadge({
  required IconData icon,
  required bool isSelected,
  required bool showBadge,
}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Icon(icon, ...),
      if (showBadge)
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: DSColors.error,  // 빨간색
              shape: BoxShape.circle,
            ),
          ),
        ),
    ],
  );
}
```

### 4.3 안 본 운세 판단 로직
```dart
// 하루에 한 번 새 운세가 생성됨
// "오늘 본 운세" 목록과 비교하여 안 본 운세 카운트

// 저장 방식: SharedPreferences
// 키: 'viewed_fortunes_${today}'
// 값: ['daily', 'mbti', 'love', ...]

Future<void> checkUnreadFortunes() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final viewedFortunes = prefs.getStringList('viewed_fortunes_$today') ?? [];

  const allFortuneTypes = ['daily', 'mbti', 'love', 'tarot', ...];
  final unreadCount = allFortuneTypes.length - viewedFortunes.length;

  ref.read(unreadFortuneCountProvider.notifier).state = unreadCount;
}
```

---

## 5. Phase 3 기능 개선 상세

### 5.1 [3.1] 운세 페이지 개선

#### 5.1.1 요구사항
- 노출 순서: 인기순 > 조회수 > 즐겨찾기
- 배경: 한지 텍스처 (에셋 대기)
- 전통운세 해설 확대

#### 5.1.2 수정 계획
```dart
// 파일: lib/features/fortune/presentation/pages/fortune_list_page.dart

// 정렬 로직 추가
List<FortuneType> _sortByPriority(List<FortuneType> fortunes) {
  return fortunes.sorted((a, b) {
    // 1. 인기순 (고정 순서)
    final popularityA = _popularityOrder[a.id] ?? 999;
    final popularityB = _popularityOrder[b.id] ?? 999;
    if (popularityA != popularityB) return popularityA.compareTo(popularityB);

    // 2. 조회수
    if (a.viewCount != b.viewCount) return b.viewCount.compareTo(a.viewCount);

    // 3. 즐겨찾기
    return b.isFavorite ? 1 : -1;
  });
}

const _popularityOrder = {
  'daily': 1,      // 오늘의 운세
  'love': 2,       // 연애운
  'tarot': 3,      // 타로
  'mbti': 4,       // MBTI
  'face_reading': 5,  // 관상
  // ...
};
```

---

### 5.2 [3.2] 타로 명칭 변경

#### 5.2.1 요구사항
- "타로 덱" → "타로 카드"

#### 5.2.2 수정 계획
```dart
// Grep으로 "타로 덱" 검색 후 일괄 수정
// 예상 파일:
// - lib/features/fortune/presentation/pages/tarot_summary/*.dart
// - lib/core/constants/strings.dart (있다면)
```

---

### 5.3 [3.3] 관상 개선

#### 5.3.1 요구사항
- "AI" 문구 제거
- 시작 시 광고 삽입
- 프로필 사진 자동 세팅
- 닮은꼴 분석 기능 추가

#### 5.3.2 수정 계획

**5.3.2.1 AI 문구 제거**
```dart
// 파일: lib/features/fortune/presentation/pages/face_reading/*.dart
// "AI 관상" → "관상"
// "AI가 분석" → "분석"
```

**5.3.2.2 시작 시 광고**
```dart
// 페이지 진입 시 전면 광고 표시
@override
void initState() {
  super.initState();
  _showInterstitialAd();  // 전면 광고
}

Future<void> _showInterstitialAd() async {
  final adService = AdService.instance;
  if (adService.isInterstitialAdReady) {
    await adService.showInterstitialAd();
  }
}
```

**5.3.2.3 프로필 사진 자동 세팅**
```dart
// 프로필 Provider에서 사진 로드
final profilePhoto = ref.watch(userProfileProvider).valueOrNull?.photoUrl;

// 초기값으로 세팅
if (profilePhoto != null && _selectedImage == null) {
  _loadProfileImage(profilePhoto);
}
```

**5.3.2.4 닮은꼴 분석** (에셋 필요 가능성)
```dart
// Edge Function에서 얼굴 특징 기반 닮은꼴 연예인 매칭
// 또는 기존 celebrity_saju 로직 활용
```

---

### 5.4 [3.4] 부적 개선

#### 5.4.1 요구사항
- 첫 페이지 카드 디자인 리뉴얼 (에셋 필요)
- 유료화 (광고/복채)
- 완성 페이지 뒤로가기 버튼 추가

#### 5.4.2 수정 계획

**5.4.2.1 유료화**
```dart
// 부적 생성 전 광고 시청 필수화
Future<void> _generateAmulet() async {
  final isPremium = ref.read(isPremiumProvider);

  if (!isPremium) {
    // 광고 시청
    final watched = await _showRewardedAd();
    if (!watched) {
      _showPremiumUpsellDialog();
      return;
    }
  }

  // 부적 생성 진행
  await _createAmulet();
}
```

**5.4.2.2 뒤로가기 버튼**
```dart
// 파일: lib/features/fortune/presentation/pages/amulet/amulet_result_page.dart

AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => context.pop(),
  ),
  title: Text('부적 완성'),
)
```

---

### 5.5 [3.5] MBTI 개선

#### 5.5.1 요구사항
- 운세 선택 제거
- 궁합 표시 추가

#### 5.5.2 수정 계획

**5.5.2.1 운세 선택 제거**
```dart
// 드롭다운/선택 UI 제거
// 사용자 프로필의 MBTI 자동 사용
final userMbti = ref.watch(userProfileProvider).valueOrNull?.mbti;
```

**5.5.2.2 궁합 표시**
```dart
// MBTI 궁합 테이블 추가
const mbtiCompatibility = {
  'INTJ': {'best': ['ENFP', 'ENTP'], 'good': ['INFJ', 'INFP'], 'bad': ['ESFP', 'ESTP']},
  'INTP': {'best': ['ENTJ', 'ESTJ'], 'good': ['INTJ', 'INFJ'], 'bad': ['ESFJ', 'ENFJ']},
  // ... 16개 타입
};

// 결과 페이지에 궁합 섹션 추가
Widget _buildCompatibilitySection() {
  final compatibility = mbtiCompatibility[userMbti];
  return Column(
    children: [
      Text('찰떡궁합: ${compatibility['best'].join(', ')}'),
      Text('좋은궁합: ${compatibility['good'].join(', ')}'),
      Text('주의궁합: ${compatibility['bad'].join(', ')}'),
    ],
  );
}
```

---

### 5.6 [3.6] 궁합 개선

#### 5.6.1 요구사항
- 상대방 정보: 프로필 선택 우선

#### 5.6.2 수정 계획
```dart
// 파일: lib/features/fortune/presentation/pages/compatibility/*.dart

// 상대방 입력 UI 순서 변경
// 1. 등록된 프로필 선택 (Primary)
// 2. 직접 입력 (Secondary)

Widget _buildPartnerInput() {
  return Column(
    children: [
      // 1순위: 프로필 선택
      _buildProfileSelector(),

      // 구분선
      _buildDividerWithText('또는 직접 입력'),

      // 2순위: 직접 입력
      _buildManualInput(),
    ],
  );
}

Widget _buildProfileSelector() {
  final secondaryProfiles = ref.watch(secondaryProfilesProvider);

  return secondaryProfiles.when(
    data: (profiles) {
      if (profiles.isEmpty) return SizedBox.shrink();
      return DropdownButton<SecondaryProfile>(
        hint: Text('등록된 프로필에서 선택'),
        items: profiles.map((p) => DropdownMenuItem(
          value: p,
          child: Text(p.name),
        )).toList(),
        onChanged: (profile) {
          if (profile != null) {
            _setPartnerFromProfile(profile);
          }
        },
      );
    },
    loading: () => CircularProgressIndicator(),
    error: (_, __) => SizedBox.shrink(),
  );
}
```

---

### 5.7 [3.7] 건강 PDF 처리

#### 5.7.1 요구사항
- PDF 처리 검토

#### 5.7.2 분석 필요
```
현재 상태 파악 필요:
- 건강 운세에서 PDF가 어떻게 사용되는지?
- PDF 생성? PDF 업로드? PDF 분석?
```

---

### 5.8 [3.8] 연애 개선

#### 5.8.1 요구사항
- 기본정보 자동 입력
- 결과 페이지 디자인 개선 (에셋 필요 가능)
- 조건별 중요도 표시
- 선택 시 자동 다음 단계
- 선택값 저장 유지

#### 5.8.2 수정 계획

**5.8.2.1 기본정보 자동 입력**
```dart
@override
void initState() {
  super.initState();
  _loadUserProfile();
}

void _loadUserProfile() {
  final profile = ref.read(userProfileProvider).valueOrNull;
  if (profile != null) {
    _nameController.text = profile.name;
    _birthDateController.text = profile.birthDate;
    _genderController.text = profile.gender;
  }
}
```

**5.8.2.2 조건별 중요도 표시**
```dart
// 각 조건 옆에 중요도 아이콘/라벨
Widget _buildConditionItem(String condition, int importance) {
  return Row(
    children: [
      Text(condition),
      Spacer(),
      _buildImportanceIndicator(importance),  // 별점 또는 바
    ],
  );
}
```

**5.8.2.3 선택 시 자동 다음 단계**
```dart
void _onConditionSelected(String condition) {
  setState(() {
    _selectedConditions.add(condition);
  });

  // 자동으로 다음 단계로 이동
  if (_currentStep < _totalSteps - 1) {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
```

**5.8.2.4 선택값 저장 유지**
```dart
// SharedPreferences에 선택값 저장
Future<void> _saveSelections() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('love_conditions', _selectedConditions);
  await prefs.setString('love_partner_type', _partnerType);
}

// 페이지 진입 시 복원
Future<void> _loadSelections() async {
  final prefs = await SharedPreferences.getInstance();
  final savedConditions = prefs.getStringList('love_conditions');
  if (savedConditions != null) {
    setState(() {
      _selectedConditions = savedConditions;
    });
  }
}
```

---

### 5.9 [3.9] 성격 제목 리뉴얼

#### 5.9.1 요구사항
- 제목 리뉴얼

#### 5.9.2 수정 계획
```dart
// 현재: "성격 분석" / "성격 DNA"
// 변경: 기획 확인 필요 → 예: "나의 성격 탐구" / "성격 인사이트"

// 파일: lib/features/fortune/presentation/pages/personality_dna/*.dart
// strings.dart 또는 해당 파일에서 텍스트 수정
```

---

## 6. 구현 우선순위

### Phase 1: Critical 버그 (즉시)
```
1.3 타로 이미지 경로 수정 (5분) ⭐ 가장 쉬움
1.4 연애운 블러 오류 수정 (10분)
1.1 해몽 기능 디버깅 (30분)
1.2 MBTI 운세 디버깅 (30분)
```

### Phase 2: 네비게이션 (High)
```
2.3 운세 탭 빨간 점 (30분)
```

### Phase 3: 기능 개선 (Medium)
```
3.2 타로 명칭 변경 (5분)
3.3 관상 AI 제거 + 광고 (20분)
3.4 부적 뒤로가기 + 광고 (15분)
3.5 MBTI 선택 제거 + 궁합 (30분)
3.6 궁합 프로필 선택 (20분)
3.8 연애 자동입력 + 저장 (30분)
3.9 성격 제목 (5분)

// 에셋/추가 확인 필요
3.1 운세 정렬 (20분)
3.7 건강 PDF (분석 필요)
```

---

## 7. 테스트 계획

### 7.1 Critical 버그 테스트
| 항목 | 테스트 방법 | 예상 결과 |
|------|------------|----------|
| 1.1 해몽 | 꿈 입력 후 결과 확인 | 운세 결과 정상 표시 |
| 1.2 MBTI | 16개 타입 순차 테스트 | 모든 타입 정상 작동 |
| 1.3 타로 | Court Card 이미지 확인 | 16장 모두 로드 성공 |
| 1.4 연애 | 프리미엄/일반 유저 테스트 | 블러 정상 동작 |

### 7.2 기능 테스트
| 항목 | 테스트 방법 | 예상 결과 |
|------|------------|----------|
| 네비게이션 | 운세 보기 전/후 탭 확인 | 빨간 점 표시/숨김 |
| 관상 | 페이지 진입 시 광고 | 전면 광고 표시 |
| 부적 | 결과 페이지 뒤로가기 | 이전 페이지로 이동 |

---

## 8. 롤백 계획

각 수정 사항별 독립적 커밋으로 관리하여 문제 발생 시 개별 롤백 가능

```bash
# 커밋 구조 예시
git commit -m "fix(1.3): 타로 Court Card 이미지 경로 수정"
git commit -m "fix(1.4): 연애운 프리미엄 블러 처리 수정"
git commit -m "feat(2.3): 운세 탭 안읽음 배지 추가"
```

---

## 9. 관련 파일 인덱스

| 기능 | 주요 파일 |
|------|----------|
| 해몽 | `lib/features/interactive/presentation/pages/dream_interpretation_page.dart` |
| MBTI | `lib/features/fortune/presentation/pages/mbti_fortune/mbti_fortune_page.dart` |
| 타로 | `lib/features/fortune/presentation/pages/tarot_summary/tarot_card_helpers.dart` |
| 연애 | `lib/features/fortune/presentation/pages/love/love_fortune_result_page.dart` |
| 네비게이션 | `lib/shared/components/bottom_navigation_bar.dart` |
| 관상 | `lib/features/fortune/presentation/pages/face_reading/*.dart` |
| 부적 | `lib/features/fortune/presentation/pages/amulet/*.dart` |
| 궁합 | `lib/features/fortune/presentation/pages/compatibility/*.dart` |
| 성격 | `lib/features/fortune/presentation/pages/personality_dna/*.dart` |

---

## 10. 승인 및 시작

기획서 검토 후 구현 시작 예정

**다음 단계**: Critical 버그 1.3 (타로 이미지) → 1.4 (연애 블러) → 1.1/1.2 (해몽/MBTI)