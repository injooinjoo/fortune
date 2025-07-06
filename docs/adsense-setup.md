# Google AdSense 설정 가이드

## 개요
Fortune 앱은 Google AdSense를 통해 광고를 표시합니다. 단순화된 2-슬롯 시스템을 사용하여 효율적인 광고 관리가 가능합니다.

## 환경 변수 설정

`.env.local` 파일에 다음 변수들을 설정하세요:

```env
# Google AdSense 설정
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-2803643717997352
NEXT_PUBLIC_ADSENSE_SLOT_ID=6492585646         # 기본 슬롯
NEXT_PUBLIC_ADSENSE_DISPLAY_SLOT=9285984534    # 보조 슬롯
```

## 슬롯 구성

### 1. 기본 슬롯 (Slot ID: 6492585646)
- **사용처**: InFeedAd, FortunePageAd
- **목적**: 주요 콘텐츠 영역의 광고

### 2. 보조 슬롯 (Slot ID: 9285984534)  
- **사용처**: DisplayAd, NativeAd
- **목적**: 디스플레이 및 네이티브 형식의 광고

## 광고 컴포넌트

### GoogleAdsense (코어 컴포넌트)
기본 AdSense 통합을 담당하는 핵심 컴포넌트입니다.

```typescript
// 기본 슬롯 사용
<GoogleAdsense useSecondarySlot={false} />

// 보조 슬롯 사용
<GoogleAdsense useSecondarySlot={true} />

// 직접 슬롯 지정
<GoogleAdsense slot="custom-slot-id" />
```

### 광고 타입별 컴포넌트

1. **DisplayAd**: 디스플레이 광고 (보조 슬롯)
2. **InFeedAd**: 인피드 광고 (기본 슬롯)
3. **NativeAd**: 네이티브 광고 (보조 슬롯)
4. **FortunePageAd**: 운세 페이지 전용 광고 (기본 슬롯)

## 테스트

### 테스트 페이지
`/test-ads` 페이지에서 모든 광고 컴포넌트를 테스트할 수 있습니다.

```bash
npm run dev
# http://localhost:3000/test-ads 접속
```

### 테스트 모드
개발 중에는 테스트 모드를 활성화하여 실제 광고 대신 테스트 광고를 표시할 수 있습니다:

```typescript
<DisplayAd testMode={true} />
```

## 주의사항

1. **광고 차단기**: 광고 차단기가 감지되면 대체 콘텐츠가 표시됩니다.
2. **개발 환경**: 개발 환경에서는 `data-ad-test="on"` 속성이 자동으로 추가됩니다.
3. **응답성**: 모든 광고는 반응형으로 구현되어 있습니다.

## 배포 전 체크리스트

- [ ] 환경 변수가 올바르게 설정되었는지 확인
- [ ] 테스트 모드가 비활성화되었는지 확인
- [ ] 광고가 올바른 위치에 표시되는지 확인
- [ ] 모바일/데스크톱 반응형 동작 확인