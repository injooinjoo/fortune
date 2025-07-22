# Fortune App - Landing Page Figma Design Guide

## 페이지 설정
- **Frame 이름**: Landing Page
- **크기**: iPhone 14 Pro (393 × 852)
- **배경색**: #FFFFFF (Light Mode) / #000000 (Dark Mode)

## 레이아웃 구조

### 1. Safe Area & Padding
- **Top Safe Area**: 47px
- **Bottom Safe Area**: 34px
- **좌우 패딩**: 40px

### 2. 상단 헤더 (다크모드 토글)
```
위치: Top Safe Area + 16px
정렬: 우측
```
- **컨테이너**: 40×40px 원형
- **테두리**: 1px, #E5E7EB (Light) / #374151 (Dark)
- **아이콘**: 
  - Light Mode: dark_mode_outlined (24px)
  - Dark Mode: light_mode_outlined (24px)
- **아이콘 색상**: #6B7280 (Light) / #9CA3AF (Dark)

### 3. 메인 콘텐츠 (중앙 정렬)
```
전체 높이에서 중앙 정렬
```

#### 3.1 로고
- **SVG 파일**: main_logo.svg
- **크기**: 100×100px
- **색상**: #1F2937
- **애니메이션 효과** (표시용):
  - fadeIn: 800ms
  - scale: 0.8 → 1.0 (600ms, easeOutBack)

#### 3.2 앱 이름
- **텍스트**: "Fortune"
- **폰트**: NotoSansKR Bold
- **크기**: 36px
- **색상**: #111827 (Light) / #FFFFFF (Dark)
- **letter-spacing**: -1px
- **상단 간격**: 40px
- **애니메이션**: fadeIn (300ms delay)

#### 3.3 서브타이틀
- **텍스트**: "매일 새로운 운세를 만나보세요"
- **폰트**: NotoSansKR Regular
- **크기**: 16px
- **색상**: #6B7280
- **상단 간격**: 12px
- **애니메이션**: fadeIn (400ms delay)

#### 3.4 시작하기 버튼
- **상단 간격**: 80px
- **너비**: 100% (좌우 패딩 제외)
- **높이**: 56px
- **배경색**: #000000
- **텍스트 색상**: #FFFFFF
- **텍스트**: "시작하기"
- **폰트 크기**: 18px
- **폰트 무게**: SemiBold
- **모서리 반경**: 28px
- **그림자**: 없음
- **애니메이션**: 
  - fadeIn (600ms delay)
  - scale: 0.9 → 1.0 (400ms)

### 4. 하단 안내 텍스트
```
위치: Bottom Safe Area + 20px
```
- **텍스트**: "서비스를 이용하시려면 위의 방법 중 하나를 선택해주세요"
- **폰트**: NotoSansKR Regular
- **크기**: 12px
- **색상**: #6B7280
- **정렬**: 중앙
- **애니메이션**: fadeIn (1100ms delay)

## 컴포넌트 간격 정리
```
[다크모드 토글]
      ↓
    (flex)
      ↓
   [로고]
      ↓ 40px
  [Fortune]
      ↓ 12px
 [서브타이틀]
      ↓ 80px
 [시작하기 버튼]
      ↓
    (flex)
      ↓
 [하단 안내 텍스트]
```

## 인터랙션 상태

### 시작하기 버튼
- **Default**: 배경 #000000
- **Pressed**: 배경 #1F2937
- **Disabled**: 배경 #E5E7EB, 텍스트 #9CA3AF

### 다크모드 토글
- **Hover**: 배경 #F3F4F6 (Light) / #1F2937 (Dark)
- **Pressed**: scale(0.95)

## 반응형 고려사항
- 작은 화면: 로고 크기를 80px로 축소
- 큰 화면: 최대 너비 500px로 제한

## Figma 구현 팁
1. **Auto Layout** 사용:
   - 메인 콘텐츠는 Vertical Auto Layout
   - Space between으로 간격 설정

2. **컴포넌트화**:
   - 시작하기 버튼을 컴포넌트로 생성
   - 다크모드 토글을 컴포넌트로 생성

3. **Variants**:
   - 버튼 상태 (default, pressed, disabled)
   - 테마 모드 (light, dark)

4. **프로토타입**:
   - 시작하기 버튼 클릭 → Onboarding Flow
   - 다크모드 토글 → 테마 전환

## 에셋 체크리스트
- [ ] main_logo.svg
- [ ] dark_mode_outlined 아이콘
- [ ] light_mode_outlined 아이콘
- [ ] NotoSansKR 폰트 (Regular, SemiBold, Bold)