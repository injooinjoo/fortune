# 🎯 Fortune 앱 기능 요청사항

> **작성일**: 2025년 7월 7일  
> **우선순위**: 사용자 요청 기반

## 📱 코인 시스템 구현

### 개요
운세 페이지 조회 후 광고 시청 시 소액의 코인을 적립하는 게이미피케이션 시스템

### 상세 기능
1. **코인 적립**
   - 운세 + 광고 페이지 조회 완료 시 코인 지급
   - 애니메이션으로 "+4 코인" 표시
   - 일일 최대 적립 한도 설정

2. **코인 표시**
   - 광고 페이지에서 적립 애니메이션
   - 프로필 페이지에서 총 보유 코인 표시
   - 하단 네비게이션 바에 코인 아이콘 추가 고려

3. **코인 사용처**
   - 소원 빌기 (100 코인)
   - 운명 찾기 (200 코인)
   - 프리미엄 운세 1회 이용권 (500 코인)
   - 광고 제거 1일권 (1000 코인)

### 기술 구현 방안
```typescript
// 코인 시스템 스키마
interface CoinSystem {
  userId: string;
  balance: number;
  totalEarned: number;
  totalSpent: number;
  transactions: CoinTransaction[];
}

interface CoinTransaction {
  id: string;
  type: 'earn' | 'spend';
  amount: number;
  reason: string;
  timestamp: Date;
}

// 코인 적립 애니메이션
const CoinAnimation = ({ amount }: { amount: number }) => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 0 }}
      animate={{ opacity: 1, y: -50 }}
      exit={{ opacity: 0 }}
      className="text-yellow-500 font-bold text-2xl"
    >
      +{amount} 코인
    </motion.div>
  );
};
```

## 🎨 관상 분석 기능 개선

### 현재 문제점
- 기본적인 얼굴 분석만 제공
- UI가 다른 페이지들과 일관성 부족
- 사용자 참여도 낮음

### 개선 방안

1. **인스타그램 연동**
   - 인스타그램 프로필 URL 입력
   - 공개 프로필 사진 분석
   - 팔로워/팔로잉 비율로 사회성 분석
   - 게시물 분석으로 성격 추론

2. **UI 개선**
   - 미니멀한 디자인으로 통일
   - 인스타그램 스타일 카드 레이아웃
   - 스와이프 가능한 결과 카드
   - 공유하기 최적화된 이미지 생성

3. **분석 고도화**
   - 얼굴 각 부위별 상세 분석
   - AI 기반 종합 성격 분석
   - 연예인 관상 매칭
   - 관상 변화 추적 (시간별)

### UI 디자인 컨셉
```tsx
// 인스타그램 스타일 관상 분석 UI
<div className="max-w-md mx-auto">
  {/* 인스타 스타일 헤더 */}
  <div className="flex items-center p-4 border-b">
    <Avatar src={profileImage} />
    <div className="ml-3">
      <h3 className="font-semibold">@{username}</h3>
      <p className="text-sm text-gray-500">관상 분석 결과</p>
    </div>
  </div>

  {/* 스와이프 가능한 결과 카드 */}
  <Swiper>
    <SwiperSlide>
      <FaceAnalysisCard />
    </SwiperSlide>
    <SwiperSlide>
      <PersonalityCard />
    </SwiperSlide>
    <SwiperSlide>
      <CelebrityMatchCard />
    </SwiperSlide>
  </Swiper>

  {/* 인스타 스타일 액션 바 */}
  <div className="flex justify-around p-4 border-t">
    <HeartIcon />
    <ShareIcon />
    <BookmarkIcon />
  </div>
</div>
```

## 🛠️ 구현 우선순위

### Phase 1 (1-2주)
1. 코인 시스템 백엔드 구축
   - 데이터베이스 스키마 설계
   - API 엔드포인트 구현
   - 트랜잭션 로직 구현

2. 코인 UI 구현
   - 적립 애니메이션
   - 프로필 페이지 잔액 표시
   - 거래 내역 페이지

### Phase 2 (2-3주)
1. 코인 사용처 구현
   - 소원 빌기 기능
   - 운명 찾기 기능
   - 프리미엄 이용권 시스템

2. 관상 분석 UI 개선
   - 새로운 디자인 시스템 적용
   - 애니메이션 추가

### Phase 3 (3-4주)
1. 인스타그램 연동
   - OAuth 인증
   - 프로필 데이터 가져오기
   - 개인정보 처리 방침 업데이트

2. 고급 분석 기능
   - AI 모델 개선
   - 연예인 매칭 DB 구축

## 📊 예상 효과

### 코인 시스템
- **사용자 리텐션**: 일일 방문율 30% 증가 예상
- **광고 수익**: 광고 시청률 50% 증가 예상
- **참여도**: 평균 세션 시간 40% 증가 예상

### 관상 분석 개선
- **공유율**: SNS 공유 200% 증가 예상
- **신규 유저**: 인스타그램 유입 증가
- **프리미엄 전환**: 관상 분석 후 프리미엄 전환율 15% 예상

## 🚨 주의사항

1. **개인정보 보호**
   - 인스타그램 데이터는 분석 후 즉시 삭제
   - 얼굴 이미지 암호화 저장
   - GDPR/KISA 가이드라인 준수

2. **광고 정책**
   - 코인 적립이 광고 클릭 유도로 오해받지 않도록 주의
   - Google AdSense 정책 준수
   - 명확한 이용 약관 명시

3. **기술적 제약**
   - 인스타그램 API 제한 사항 확인
   - 얼굴 인식 API 비용 고려
   - 서버 부하 대비

---

**마지막 업데이트**: 2025년 7월 7일  
**상태**: 기획 단계  
**예상 개발 기간**: 4-6주