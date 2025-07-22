# Fortune App - Social Login Bottom Sheet Design Guide

## Bottom Sheet 설정
- **Frame 이름**: Social Login Bottom Sheet
- **크기**: 393 × 600 (초기 높이)
- **배경색**: #FFFFFF
- **상단 모서리**: 25px radius (top-left, top-right)
- **그림자**: 0px -4px 20px rgba(0, 0, 0, 0.1)

## 레이아웃 구조

### 1. 드래그 핸들
```
위치: 상단 중앙
상단 간격: 12px
```
- **크기**: 40 × 4px
- **배경색**: #D1D5DB
- **모서리 반경**: 2px

### 2. 콘텐츠 영역
```
좌우 패딩: 40px
상단 패딩: 20px (드래그 핸들 아래)
```

#### 2.1 타이틀
- **텍스트**: "시작하기"
- **폰트**: NotoSansKR Bold
- **크기**: 28px
- **색상**: #111827
- **letter-spacing**: -0.5px
- **정렬**: 중앙

#### 2.2 서브타이틀
- **상단 간격**: 12px
- **텍스트**: "소셜 계정으로 간편하게 시작해보세요"
- **폰트**: NotoSansKR Regular
- **크기**: 16px
- **색상**: #6B7280
- **정렬**: 중앙

#### 2.3 소셜 로그인 버튼 그룹
- **상단 간격**: 40px
- **버튼 간격**: 12px

### 3. 소셜 로그인 버튼 (공통)
- **너비**: 100%
- **높이**: 52px
- **배경색**: #FFFFFF
- **테두리**: 1px solid #E5E7EB
- **모서리 반경**: 26px
- **그림자**: 없음

#### 버튼 내부 레이아웃
```
[아이콘] [12px 간격] [텍스트]
```
- **아이콘 크기**: 24×24px
- **텍스트 폰트**: NotoSansKR SemiBold
- **텍스트 크기**: 16px
- **텍스트 색상**: #1F2937
- **정렬**: 중앙

### 4. 각 소셜 로그인 버튼 상세

#### 4.1 Google
- **아이콘**: google.svg
- **텍스트**: "Google로 계속하기"

#### 4.2 Apple
- **아이콘**: apple.svg (검은색)
- **텍스트**: "Apple로 계속하기"

#### 4.3 Kakao
- **아이콘**: kakao.svg
- **텍스트**: "카카오로 계속하기"

#### 4.4 Naver
- **아이콘**: naver.svg
- **텍스트**: "네이버로 계속하기"

#### 4.5 Instagram
- **아이콘**: instagram.svg
- **텍스트**: "Instagram으로 계속하기"

#### 4.6 TikTok
- **아이콘**: tiktok.svg
- **텍스트**: "TikTok으로 계속하기"

### 5. 구분선
- **상단 간격**: 30px
- **높이**: 1px
- **색상**: #E5E7EB

### 6. 약관 안내
- **상단 간격**: 20px
- **텍스트**: "계속하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다."
- **폰트**: NotoSansKR Regular
- **크기**: 12px
- **색상**: #6B7280
- **줄 간격**: 1.5
- **정렬**: 중앙

### 7. 하단 패딩
- **크기**: 20px

## 컴포넌트 간격 정리
```
[드래그 핸들]
    ↓ 20px
  [타이틀]
    ↓ 12px
 [서브타이틀]
    ↓ 40px
[Google 버튼]
    ↓ 12px
[Apple 버튼]
    ↓ 12px
[Kakao 버튼]
    ↓ 12px
[Naver 버튼]
    ↓ 12px
[Instagram 버튼]
    ↓ 12px
[TikTok 버튼]
    ↓ 30px
  [구분선]
    ↓ 20px
 [약관 안내]
    ↓ 20px
```

## 인터랙션 상태

### 소셜 로그인 버튼
- **Default**: 배경 #FFFFFF, 테두리 #E5E7EB
- **Hover**: 배경 #F9FAFB
- **Pressed**: 
  - 배경 #F3F4F6
  - scale(0.98)
- **Disabled**: 
  - 배경 #F9FAFB
  - 텍스트 #9CA3AF
  - opacity: 0.6

## Bottom Sheet 동작
- **초기 높이**: 70% of screen
- **최소 높이**: 50% of screen
- **최대 높이**: 90% of screen
- **드래그 가능**: Yes
- **배경 오버레이**: rgba(0, 0, 0, 0.5)

## Figma 구현 팁

### 1. Auto Layout 설정
```
Bottom Sheet Frame
├── Vertical Auto Layout
│   ├── 드래그 핸들
│   ├── 콘텐츠 영역 (Vertical Auto Layout)
│   │   ├── 타이틀
│   │   ├── 서브타이틀
│   │   ├── 버튼 그룹 (Vertical Auto Layout, 12px gap)
│   │   ├── 구분선
│   │   └── 약관 안내
```

### 2. 컴포넌트화
- **Social Login Button**: 
  - Properties: icon, text, state
  - Variants: default, hover, pressed, disabled

### 3. 프로토타입
- 각 버튼 클릭 → 로딩 상태 → 홈 화면
- 배경 클릭 → Bottom Sheet 닫기
- 드래그 제스처 → Sheet 높이 조절

## 에셋 체크리스트
- [ ] google.svg
- [ ] apple.svg
- [ ] kakao.svg
- [ ] naver.svg
- [ ] instagram.svg
- [ ] tiktok.svg

## 접근성 고려사항
- 모든 버튼에 적절한 터치 영역 확보 (최소 44×44px)
- 충분한 색상 대비 유지
- 스크린 리더를 위한 라벨 설정