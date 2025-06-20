# 데일리 운세 시스템

사용자의 운세를 데이터베이스에 저장하고 관리하는 시스템입니다. 같은 날에 같은 운세 타입에 접속하면 기존에 생성된 운세를 불러오고, 처음 접속하는 경우 새로운 운세를 생성합니다.

## 📋 주요 기능

- **데일리 운세 저장**: 사용자별, 날짜별, 운세 타입별로 운세 결과 저장
- **자동 복원**: 같은 날 재접속 시 기존 운세 자동 복원
- **재생성 기능**: 같은 날 운세를 다시 생성할 수 있는 기능
- **게스트 지원**: 로그인하지 않은 사용자도 로컬 스토리지 기반으로 운세 저장
- **운세 기록**: 사용자의 과거 운세 기록 조회

## 🏗️ 시스템 구조

### 1. 데이터베이스 스키마

```sql
-- Supabase 테이블: daily_fortunes
CREATE TABLE daily_fortunes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  fortune_type TEXT NOT NULL,
  fortune_data JSONB NOT NULL,
  created_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, fortune_type, created_date)
);
```

### 2. 타입 정의

```typescript
// 데일리 운세 데이터 타입
interface DailyFortuneData {
  id?: string;
  user_id: string;
  fortune_type: string;
  fortune_data: FortuneResult;
  created_date: string;
  created_at?: string;
  updated_at?: string;
}

// 공통 운세 결과 타입
interface FortuneResult {
  user_info: {
    name: string;
    birth_date: string;
  };
  fortune_scores?: Record<string, number>;
  insights?: Record<string, string>;
  recommendations?: string[];
  warnings?: string[];
  lucky_items?: Record<string, string>;
  metadata?: Record<string, any>;
}
```

### 3. 서비스 클래스

```typescript
import { DailyFortuneService } from '@/lib/daily-fortune-service';

// 오늘 운세 조회
const fortune = await DailyFortuneService.getTodayFortune(userId, fortuneType);

// 새 운세 저장
const saved = await DailyFortuneService.saveTodayFortune(userId, fortuneType, fortuneData);

// 운세 업데이트
const updated = await DailyFortuneService.updateTodayFortune(id, fortuneData);

// 운세 기록 조회
const history = await DailyFortuneService.getFortuneHistory(userId, fortuneType, 10);
```

### 4. 커스텀 훅

```typescript
import { useDailyFortune } from '@/hooks/use-daily-fortune';

const {
  todayFortune,        // 오늘의 운세 데이터
  isLoading,           // 로딩 상태
  isGenerating,        // 생성/재생성 중 상태
  hasTodayFortune,     // 오늘 운세 존재 여부
  saveFortune,         // 새 운세 저장
  regenerateFortune,   // 운세 재생성
  canRegenerate        // 재생성 가능 여부
} = useDailyFortune({ fortuneType: 'lucky-hiking' });
```

## 🚀 운세 페이지에 적용하기

### 1. 기본 설정

```typescript
import { useDailyFortune } from '@/hooks/use-daily-fortune';
import { FortuneResult } from '@/lib/schemas';

export default function YourFortunePage() {
  const [result, setResult] = useState(null);
  
  // 데일리 운세 훅 추가
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'your-fortune-type' });
  
  // ... 기존 코드
}
```

### 2. 운세 분석 함수 수정

```typescript
const handleAnalyze = async () => {
  try {
    // 기존 운세가 있으면 불러오기
    if (hasTodayFortune && todayFortune) {
      const savedResult = todayFortune.fortune_data.metadata?.complete_result;
      if (savedResult) {
        setResult(savedResult);
        return;
      }
    }

    // 새로운 운세 생성
    const fortuneResult = await generateFortune();
    
    // FortuneResult 형식으로 변환
    const fortuneData: FortuneResult = {
      user_info: {
        name: formData.name,
        birth_date: formData.birth_date,
      },
      fortune_scores: {
        // 점수들...
      },
      insights: {
        // 인사이트들...
      },
      lucky_items: {
        // 행운의 요소들...
      },
      metadata: {
        // 기타 데이터와 완전한 결과
        complete_result: fortuneResult
      }
    };

    // DB에 저장
    const success = await saveFortune(fortuneData);
    if (success) {
      setResult(fortuneResult);
    }
  } catch (error) {
    console.error('분석 중 오류:', error);
  }
};
```

### 3. 자동 복원 기능

```typescript
// 기존 운세가 있으면 자동으로 복원
useEffect(() => {
  if (hasTodayFortune && todayFortune && !result) {
    const savedData = todayFortune.fortune_data as any;
    const metadata = savedData.metadata || {};
    
    // 폼 데이터 복원
    setFormData({
      name: savedData.user_info?.name || '',
      birth_date: savedData.user_info?.birth_date || '',
      // 기타 필드들...
    });
    
    // 운세 결과 복원
    if (metadata.complete_result) {
      setResult(metadata.complete_result);
    }
  }
}, [hasTodayFortune, todayFortune, result]);
```

### 4. 버튼 상태 업데이트

```typescript
<Button
  onClick={handleAnalyze}
  disabled={isGenerating || isDailyLoading}
>
  {(isGenerating || isDailyLoading) ? (
    <div className="flex items-center gap-2">
      <Spinner />
      {hasTodayFortune ? '불러오는 중...' : '분석 중...'}
    </div>
  ) : (
    <div className="flex items-center gap-2">
      {hasTodayFortune ? (
        <>
          <CheckCircle />
          오늘의 운세 보기
        </>
      ) : (
        <>
          <Star />
          운세 분석하기
        </>
      )}
    </div>
  )}
</Button>
```

### 5. 재생성 버튼 추가

```typescript
{canRegenerate && (
  <Button
    onClick={async () => {
      const newFortune = await generateFortune();
      const fortuneData = convertToFortuneResult(newFortune);
      const success = await regenerateFortune(fortuneData);
      if (success) {
        setResult(newFortune);
      }
    }}
    disabled={isGenerating}
  >
    {isGenerating ? '재생성 중...' : '오늘 운세 다시 생성하기'}
  </Button>
)}
```

## 📊 데이터베이스 설정

### Supabase 테이블 생성

```sql
-- sql/create_daily_fortunes_table.sql 파일 실행
-- 또는 Supabase 대시보드에서 직접 생성
```

### 환경 변수 설정

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 🔐 보안 및 권한

- **RLS (Row Level Security)** 활성화로 사용자별 데이터 접근 제어
- **게스트 사용자** 지원으로 로그인 없이도 운세 저장 가능
- **UNIQUE 제약조건**으로 중복 저장 방지

## 🎯 운세 타입별 적용 현황

- ✅ **lucky-hiking**: 행운의 등산 (완료)
- ✅ **lucky-color**: 행운의 색깔 (완료)
- ⏳ **daily**: 데일리 운세 (예정)
- ⏳ **saju**: 사주팔자 (예정)
- ⏳ **mbti**: MBTI 운세 (예정)

## 📈 향후 개선사항

1. **캐싱 시스템**: Redis 등을 활용한 캐싱
2. **운세 비교**: 과거 운세와의 비교 기능
3. **알림 시스템**: 새로운 운세 생성 알림
4. **통계 대시보드**: 운세 트렌드 분석
5. **공유 기능**: 운세 결과 소셜 공유

## 🐛 문제 해결

### 일반적인 문제들

1. **Supabase 연결 오류**
   ```typescript
   // .env 파일의 환경 변수 확인
   // Supabase 프로젝트 URL과 키가 올바른지 확인
   ```

2. **RLS 정책 오류**
   ```sql
   -- 정책이 올바르게 설정되었는지 확인
   SELECT * FROM auth.users; -- 사용자 ID 확인
   ```

3. **타입 오류**
   ```typescript
   // FortuneResult 인터페이스와 실제 데이터 구조가 일치하는지 확인
   ```

## 📝 예시 코드

완전한 구현 예시는 다음 파일들을 참고하세요:
- `src/app/fortune/lucky-hiking/page.tsx`
- `src/app/fortune/lucky-color/page.tsx` 