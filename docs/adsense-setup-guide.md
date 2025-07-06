# Google AdSense 설정 가이드

## 개요
Fortune 앱에서 Google AdSense를 통해 수익을 창출하는 방법을 안내합니다.

## 필요한 정보

### 1. AdSense 계정 정보
- **게시자 ID**: `pub-2803643717997352` (이미 설정됨)
- **고객 ID**: `2102286371`

### 2. 광고 슬롯 ID
각 광고 유형별로 별도의 슬롯 ID가 필요합니다:
- 기본 광고 슬롯
- 디스플레이 광고 슬롯
- 인피드 광고 슬롯
- 네이티브 광고 슬롯

## 광고 슬롯 ID 얻는 방법

### 1단계: AdSense 관리자 페이지 접속
1. [Google AdSense](https://www.google.com/adsense)에 로그인
2. 좌측 메뉴에서 "광고" → "광고 단위별" 클릭

### 2단계: 새 광고 단위 만들기
1. "새 광고 단위" 버튼 클릭
2. 광고 유형 선택:
   - **디스플레이 광고**: 일반적인 배너 광고
   - **인피드 광고**: 콘텐츠 사이에 자연스럽게 삽입
   - **네이티브 광고**: 사이트 디자인과 일치

### 3단계: 광고 설정
1. **광고 단위 이름** 입력 (예: "Fortune 앱 - 디스플레이 광고")
2. **광고 크기** 선택:
   - 디스플레이: 반응형 권장
   - 인피드: 자동
   - 네이티브: 유동적
3. "만들기" 클릭

### 4단계: 광고 코드에서 슬롯 ID 확인
생성된 코드에서 `data-ad-slot="숫자"` 부분의 숫자가 슬롯 ID입니다.

```html
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-2803643717997352"
     data-ad-slot="1234567890"  <!-- 이 숫자가 슬롯 ID -->
     data-ad-format="auto"
     data-full-width-responsive="true"></ins>
```

## 환경 변수 설정

`.env.local` 파일에 다음 정보를 추가하세요:

```env
# Google AdSense 설정
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-2803643717997352
NEXT_PUBLIC_ADSENSE_SLOT_ID=기본슬롯ID
NEXT_PUBLIC_ADSENSE_DISPLAY_SLOT=디스플레이광고슬롯ID
NEXT_PUBLIC_ADSENSE_INFEED_SLOT=인피드광고슬롯ID  
NEXT_PUBLIC_ADSENSE_NATIVE_SLOT=네이티브광고슬롯ID
```

## 광고 컴포넌트 사용법

### 1. 디스플레이 광고
```tsx
import DisplayAd from '@/components/ads/DisplayAd';

// 반응형 광고
<DisplayAd size="responsive" />

// 고정 크기 광고
<DisplayAd size="rectangle" />  // 300x250
<DisplayAd size="leaderboard" /> // 728x90
```

### 2. 인피드 광고
```tsx
import InFeedAd from '@/components/ads/InFeedAd';

// 콘텐츠 사이에 삽입
<InFeedAd 
  title="추천 운세" 
  description="당신을 위한 맞춤 운세"
/>
```

### 3. 네이티브 광고
```tsx
import NativeAd from '@/components/ads/NativeAd';

// 사이드바나 추천 영역에 사용
<NativeAd title="인기 콘텐츠" />
```

### 4. 기존 FortunePageAd
```tsx
import FortunePageAd from '@/components/ads/FortunePageAd';

// 운세 페이지 하단에 사용
<FortunePageAd className="mt-6" />
```

## 테스트 모드

개발 중에는 테스트 모드를 사용하세요:

```tsx
<DisplayAd testMode={true} />
<InFeedAd testMode={true} />
<NativeAd testMode={true} />
```

## 주의사항

### 1. AdSense 정책 준수
- ❌ 자동 클릭이나 클릭 유도 금지
- ❌ "광고를 클릭해주세요" 같은 문구 사용 금지
- ✅ 광고임을 명확히 표시
- ✅ 콘텐츠와 광고 구분 명확히

### 2. 테스트 시 주의
- ❌ 실제 광고 클릭하지 마세요 (계정 정지 위험)
- ✅ 개발 환경에서는 `data-ad-test="on"` 자동 적용
- ✅ 테스트 모드 사용 권장

### 3. 광고 배치 가이드라인
- 스크롤 없이 보이는 영역에 광고 3개 이하
- 콘텐츠보다 광고가 많으면 안 됨
- 모바일에서 화면 대부분을 광고가 차지하면 안 됨

## 광고 차단기 대응

광고 차단기가 감지되면 자동으로 대체 콘텐츠가 표시됩니다:
- 정중한 메시지로 광고 차단 해제 요청
- 대체 콘텐츠나 후원 안내 표시

## 수익 확인

1. [AdSense 관리자](https://www.google.com/adsense)에서 확인
2. 보고서 → 수익 확인
3. 광고 단위별 실적 분석

## 문제 해결

### 광고가 표시되지 않는 경우
1. 슬롯 ID가 올바른지 확인
2. 도메인이 AdSense에 승인되었는지 확인
3. 광고 차단기가 켜져있는지 확인
4. 콘솔에서 에러 메시지 확인

### 광고 승인 대기 중
- 새 사이트는 승인까지 24-48시간 소요
- 승인 전에는 빈 공간으로 표시됨

## 추가 리소스
- [AdSense 도움말](https://support.google.com/adsense)
- [AdSense 정책 센터](https://support.google.com/adsense/topic/1307438)
- [광고 배치 권장사항](https://support.google.com/adsense/answer/1346295)