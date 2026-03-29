# 부적 이미지 생성 시스템 통합 가이드

## 📚 목차

1. [시스템 개요](#시스템-개요)
2. [아키텍처](#아키텍처)
3. [Supabase 설정](#supabase-설정)
4. [Edge Function 배포](#edge-function-배포)
5. [Flutter 통합](#flutter-통합)
6. [사용 예시](#사용-예시)
7. [비용 및 성능](#비용-및-성능)
8. [트러블슈팅](#트러블슈팅)

---

## 🎯 시스템 개요

### 목적
Gemini Imagen 3 API를 사용하여 **전통 한국 부적(符籍)** 이미지를 자동 생성하는 시스템입니다.

### 주요 기능
- ✅ 7개 카테고리별 부적 생성 (질병 퇴치, 사랑 성취, 재물 운 등)
- ✅ 학술 자료 기반 전통 디자인 (황색 한지 + 적색 주사)
- ✅ AI 프롬프트 엔지니어링 최적화
- ✅ Supabase Storage 자동 저장
- ✅ 사용자별 부적 히스토리 관리

### 기술 스택
- **AI 이미지 생성**: Gemini Imagen 3 API
- **백엔드**: Supabase Edge Functions (Deno)
- **스토리지**: Supabase Storage (talisman-images bucket)
- **데이터베이스**: Supabase PostgreSQL (talisman_images 테이블)
- **프론트엔드**: Flutter (TalismanGenerationService)

---

## 🏗️ 아키텍처

### 시스템 흐름도
```
[Flutter App]
    ↓ 1. generateTalisman(category)
[TalismanGenerationService]
    ↓ 2. HTTP POST
[Supabase Edge Function: generate-talisman]
    ↓ 3. Build prompt
[Prompt Builder]
    ↓ 4. Generate image
[Gemini Imagen 3 API]
    ↓ 5. Return base64 image
[Edge Function]
    ↓ 6. Upload image
[Supabase Storage: talisman-images/]
    ↓ 7. Save metadata
[PostgreSQL: talisman_images]
    ↓ 8. Return imageUrl
[Flutter App] → Display image
```

### 데이터 구조

#### talisman_images 테이블 스키마
```sql
CREATE TABLE talisman_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  image_url TEXT NOT NULL,
  prompt_used TEXT NOT NULL,
  characters TEXT[] NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 인덱스
  INDEX idx_user_id_created_at (user_id, created_at DESC),
  INDEX idx_category (category)
);

-- RLS 정책
ALTER TABLE talisman_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own talismans"
  ON talisman_images FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own talismans"
  ON talisman_images FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own talismans"
  ON talisman_images FOR DELETE
  USING (auth.uid() = user_id);
```

#### Storage Bucket 설정
```sql
-- talisman-images 버킷 생성
INSERT INTO storage.buckets (id, name, public)
VALUES ('talisman-images', 'talisman-images', true);

-- RLS 정책
CREATE POLICY "Users can upload own talismans"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'talisman-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Anyone can view talisman images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'talisman-images');

CREATE POLICY "Users can delete own talismans"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'talisman-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

---

## ⚙️ Supabase 설정

### 1. 환경 변수 설정
```bash
# Gemini API Key 설정
supabase secrets set GEMINI_API_KEY=your_gemini_api_key_here

# 확인
supabase secrets list | grep GEMINI_API_KEY
```

### 2. DB 마이그레이션 실행
```bash
# 마이그레이션 파일 생성
cat > supabase/migrations/$(date +%Y%m%d%H%M%S)_create_talisman_images.sql << 'EOF'
-- talisman_images 테이블 생성
CREATE TABLE talisman_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  image_url TEXT NOT NULL,
  prompt_used TEXT NOT NULL,
  characters TEXT[] NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_talisman_user_id_created_at ON talisman_images(user_id, created_at DESC);
CREATE INDEX idx_talisman_category ON talisman_images(category);

-- RLS 활성화
ALTER TABLE talisman_images ENABLE ROW LEVEL SECURITY;

-- RLS 정책
CREATE POLICY "Users can view own talismans"
  ON talisman_images FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own talismans"
  ON talisman_images FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own talismans"
  ON talisman_images FOR DELETE
  USING (auth.uid() = user_id);
EOF

# 마이그레이션 실행
supabase db push
```

### 3. Storage Bucket 생성
```bash
# Supabase Dashboard에서:
# 1. Storage > New Bucket
# 2. Name: talisman-images
# 3. Public: ✅ (체크)
# 4. File size limit: 5 MB
# 5. Allowed MIME types: image/png, image/jpeg
```

---

## 🚀 Edge Function 배포

### 1. Edge Function 구조 확인
```
supabase/functions/
└── generate-talisman/
    └── index.ts
```

### 2. 배포 명령어
```bash
# 함수 배포
supabase functions deploy generate-talisman

# 로그 확인
supabase functions logs generate-talisman --limit 50
```

### 3. 로컬 테스트
```bash
# 로컬 Edge Function 실행
supabase functions serve generate-talisman

# 테스트 요청
curl -X POST http://localhost:54321/functions/v1/generate-talisman \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-id",
    "category": "disease_prevention",
    "characters": ["病退散", "藥神降臨"]
  }'
```

---

## 📱 Flutter 통합

### 1. 의존성 추가
```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.0.0
  cached_network_image: ^3.3.0  # 이미지 캐싱
  path_provider: ^2.1.0  # 다운로드용
```

### 2. 서비스 사용법
```dart
import 'package:ondo/core/services/talisman_generation_service.dart';

// 서비스 인스턴스 생성
final talismanService = TalismanGenerationService();

// 부적 생성
final result = await talismanService.generateTalisman(
  category: TalismanCategory.diseasePrevention,
);

print('Image URL: ${result.imageUrl}');
```

### 3. Riverpod Provider 설정
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talisman_providers.g.dart';

@riverpod
TalismanGenerationService talismanGenerationService(TalismanGenerationServiceRef ref) {
  return TalismanGenerationService();
}

@riverpod
Future<TalismanGenerationResult> generateTalisman(
  GenerateTalismanRef ref,
  TalismanCategory category,
) async {
  final service = ref.watch(talismanGenerationServiceProvider);
  return service.generateTalisman(category: category);
}

@riverpod
Future<List<TalismanGenerationResult>> userTalismans(UserTalismansRef ref) async {
  final service = ref.watch(talismanGenerationServiceProvider);
  return service.getUserTalismans();
}
```

---

## 🎨 사용 예시

### 예시 1: 질병 퇴치 부적 생성
```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ondo/core/services/talisman_generation_service.dart';

class TalismanGenerationPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerating = useState(false);
    final generatedImageUrl = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(title: Text('부적 생성')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (generatedImageUrl.value != null)
              Image.network(
                generatedImageUrl.value!,
                width: 300,
                height: 420,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isGenerating.value
                  ? null
                  : () async {
                      isGenerating.value = true;
                      try {
                        final service = TalismanGenerationService();
                        final result = await service.generateTalisman(
                          category: TalismanCategory.diseasePrevention,
                        );
                        generatedImageUrl.value = result.imageUrl;
                      } finally {
                        isGenerating.value = false;
                      }
                    },
              child: isGenerating.value
                  ? CircularProgressIndicator()
                  : Text('질병 퇴치 부적 생성'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 예시 2: 사용자 지정 문구로 생성
```dart
final result = await talismanService.generateTalisman(
  category: TalismanCategory.loveRelationship,
  customCharacters: ['百年偕老', '琴瑟和鳴'],  // 사용자 지정 한자
);
```

### 예시 3: 부적 목록 조회
```dart
final talismans = await talismanService.getUserTalismans(limit: 10);

ListView.builder(
  itemCount: talismans.length,
  itemBuilder: (context, index) {
    final talisman = talismans[index];
    return ListTile(
      leading: Image.network(talisman.imageUrl, width: 50),
      title: Text(talisman.category),
      subtitle: Text(talisman.characters.join(', ')),
      trailing: Text(talisman.createdAt.toString()),
    );
  },
);
```

---

## 💰 비용 및 성능

### Gemini Imagen 3 API 비용 (2025년 1월 기준)
```
이미지 생성: $0.04 / image (2000x2800px)
```

### 예상 사용량 (월별)
```
일일 사용자: 1,000명
평균 부적 생성: 2개/사용자
월별 총 생성: 1,000 × 2 × 30 = 60,000 images
월별 비용: 60,000 × $0.04 = $2,400/월
```

### 성능 지표
```yaml
평균 생성 시간: 8-12초
  - Prompt 빌드: ~0.1초
  - Gemini API 호출: 6-10초
  - Supabase 업로드: 1-2초

이미지 크기: 2000x2800px (2:3 비율)
파일 크기: 1-3 MB (PNG)
```

### 최적화 전략
1. **캐싱**: 동일 카테고리 + 동일 문구 → DB에서 재사용
2. **배치 생성**: 여러 이미지 동시 생성 시 병렬 처리
3. **이미지 압축**: WebP 포맷 전환 (50-70% 크기 절감)
4. **CDN 사용**: Supabase Storage + CloudFlare CDN

---

## 🐛 트러블슈팅

### 에러 1: Gemini API Key 없음
```
Error: GEMINI_API_KEY not found
```
**해결**:
```bash
supabase secrets set GEMINI_API_KEY=your_key
supabase functions deploy generate-talisman
```

### 에러 2: Storage 업로드 실패
```
Error: Upload failed: permission denied
```
**해결**:
1. Storage Bucket이 public인지 확인
2. RLS 정책 확인:
```sql
SELECT * FROM storage.policies WHERE bucket_id = 'talisman-images';
```

### 에러 3: 이미지 생성 실패
```
Error: Gemini API failed: safety filter triggered
```
**해결**:
1. 프롬프트에서 민감한 키워드 제거
2. `safetySetting: 'block_some'` → `'block_few'`로 변경 (주의!)

### 에러 4: DB 삽입 실패
```
Error: duplicate key value violates unique constraint
```
**해결**:
- `id` 필드를 UUID 자동 생성으로 변경 (이미 적용됨)

---

## 📋 체크리스트

### 배포 전 확인사항
- [ ] Gemini API Key 설정 완료
- [ ] talisman_images 테이블 생성
- [ ] talisman-images Storage Bucket 생성 (public)
- [ ] RLS 정책 설정 완료
- [ ] Edge Function 배포 성공
- [ ] 로컬 테스트 성공
- [ ] Flutter 서비스 통합 완료

### 운영 모니터링
- [ ] Gemini API 호출 횟수 모니터링
- [ ] Supabase Storage 사용량 확인
- [ ] Edge Function 에러 로그 확인
- [ ] 사용자 생성 이미지 품질 검토

---

## 🎉 다음 단계

### Phase 1: 기본 구현 (완료)
- ✅ Edge Function 구현
- ✅ Flutter Service 구현
- ✅ DB/Storage 설정
- ✅ 문서 작성

### Phase 2: UI 개발 (예정)
- [ ] 부적 생성 페이지 UI
- [ ] 카테고리 선택 화면
- [ ] 생성 로딩 애니메이션
- [ ] 부적 갤러리 화면
- [ ] 공유 기능 (SNS, 다운로드)

### Phase 3: 고급 기능 (예정)
- [ ] 사용자 지정 문구 입력
- [ ] 부적 편집 기능 (색상, 크기 조정)
- [ ] 부적 프리셋 (인기 조합 저장)
- [ ] 부적 효과 통계 (사용자 피드백)

### Phase 4: 최적화 (예정)
- [ ] 이미지 캐싱 시스템
- [ ] WebP 포맷 전환
- [ ] CDN 통합
- [ ] 배치 생성 병렬 처리

---

**작성일**: 2025-01-08
**버전**: 1.0.0
**작성자**: Ondo Development Team
**참고 문서**: `KOREAN_TALISMAN_DESIGN_GUIDE.md`
