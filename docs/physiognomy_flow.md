# 관상 운세 페이지 플로우 개선사항

## 개요
관상 운세 페이지의 사용자 경험을 개선하고 광고 수익을 적절히 통합한 새로운 플로우를 구현했습니다.

## 새로운 페이지 구조

### 1. PhysiognomyEnhancedPage (소개 페이지)
- **경로**: `/fortune/physiognomy`
- **기능**: 
  - 관상 운세 소개
  - AI 분석 정확도 표시
  - 주요 기능 설명
  - 개인정보 보호 안내

### 2. PhysiognomyInputPage (입력 페이지)
- **경로**: `/fortune/physiognomy/input`
- **기능**:
  - 두 가지 입력 방법 제공
    - AI 사진 분석 (추천)
    - 수동 입력 (간편)
  - 간소화된 입력 폼
  - 필수 항목만 선택
  - 선택 항목은 접을 수 있는 UI

### 3. PhysiognomyResultPage (결과 페이지)
- **경로**: `/fortune/physiognomy/result`
- **기능**:
  - 종합 관상 점수 (애니메이션)
  - 카테고리별 점수 (재물운, 연애운, 건강운, 사업운)
  - 부위별 상세 분석
  - 성격 특성 차트
  - 인생 조언
  - 공유 기능

## 사용자 플로우

```
1. 운세 목록 → 관상 클릭
2. 소개 화면 (PhysiognomyEnhancedPage)
3. "시작하기" 클릭
4. 첫 번째 광고 (5초) - 프리미엄 회원은 자동 스킵
5. 입력 페이지 (PhysiognomyInputPage)
   - 방법 선택: 사진 / 수동
   - 정보 입력
6. "분석하기" 클릭
7. 두 번째 광고 (5초) - 프리미엄 회원은 자동 스킵
8. 결과 페이지 (PhysiognomyResultPage)
```

## 주요 개선사항

### 1. NavigationFlowHelper
- 광고 표시 로직 중앙화
- 프리미엄 사용자 자동 감지
- 부드러운 페이지 전환

### 2. 입력 방식 개선
- 사진 분석과 수동 입력 명확히 구분
- 필수 항목 최소화 (얼굴형, 눈, 코, 입)
- 선택 항목은 숨김 처리
- 직관적인 UI/UX

### 3. 결과 페이지 강화
- 애니메이션 효과로 몰입감 증대
- 점수 시각화 (원형 프로그레스, 막대 차트)
- 카테고리별 분석 제공
- 공유 기능으로 바이럴 효과

### 4. 광고 통합
- 자연스러운 위치에 광고 배치
- 로딩 중 광고로 대기 시간 활용
- 프리미엄 회원 혜택 강조

## 기술적 구현

### State Management
- Riverpod을 사용한 상태 관리
- PhysiognomyData 모델로 데이터 관리
- Provider를 통한 페이지 간 데이터 전달

### Route Configuration
```dart
GoRoute(
  path: 'physiognomy',
  name: 'fortune-physiognomy',
  builder: (context, state) => const PhysiognomyEnhancedPage(),
  routes: [
    GoRoute(
      path: 'input',
      name: 'physiognomy-input',
      builder: (context, state) => const PhysiognomyInputPage(),
    ),
    GoRoute(
      path: 'result',
      name: 'physiognomy-result',
      builder: (context, state) {
        final data = (state.extra as Map<String, dynamic>?)?['data'];
        return PhysiognomyResultPage(data: data);
      },
    ),
  ],
),
```

### 광고 표시 로직
```dart
NavigationFlowHelper.navigateWithAd(
  context: context,
  ref: ref,
  destinationRoute: 'physiognomy-input',
  fortuneType: 'physiognomy',
);
```

## 향후 개선 계획

1. **AI 사진 분석 실제 구현**
   - 얼굴 인식 API 통합
   - 특징점 자동 추출

2. **결과 개인화**
   - 사용자 히스토리 기반 분석
   - 시간에 따른 변화 추적

3. **소셜 기능 강화**
   - 결과 이미지 생성
   - SNS 직접 공유

4. **프리미엄 기능**
   - 상세 보고서 제공
   - 전문가 상담 연결