# Celebrity Notion-Style Avatar System Implementation Plan

## Overview
700+ 유명인에게 고유한 Notion 스타일 아바타를 생성하고 관리하는 시스템

## Architecture

### 1. Avatar Generation Pipeline

```
[Celebrity Data] → [Face Analysis Prompt] → [Part Selection/Generation] → [SVG Composition] → [PNG Export] → [Supabase Storage] → [Update DB]
```

### 2. Components

#### A. Notion Avatar Assets (로컬 저장)
- 경로: `assets/avatar/parts/`
- 카테고리: Face(16), Hair(58), Eyes(14), Eyebrows(16), Nose(14), Mouth(20), Glasses(14), Beard(16), Accessories(14), Details(13)
- 소스: https://github.com/Mayandev/notion-avatar (CC0 License)

#### B. Avatar Generation Script (Node.js)
- 위치: `scripts/generate_celebrity_avatars.js`
- 기능:
  1. Supabase에서 `character_image_url`이 없는 유명인 조회
  2. OpenAI GPT-4 Vision으로 유명인 특징 분석 (기존 사진 또는 이름 기반)
  3. 분석 결과로 파츠 조합 결정
  4. SVG 파츠 합성 → PNG 변환
  5. Supabase Storage 업로드
  6. DB `character_image_url` 업데이트

#### C. Face Analysis Prompt
```
당신은 유명인의 외모 특징을 분석하여 Notion 스타일 아바타 파츠를 추천하는 전문가입니다.

유명인: {name} ({celebrity_type}, {gender})

다음 카테고리별로 가장 적합한 파츠 번호를 JSON으로 응답하세요:
- face: 1-16 (얼굴형)
- hair: 1-58 (헤어스타일)
- eyes: 1-14 (눈 모양)
- eyebrows: 1-16 (눈썹)
- nose: 1-14 (코)
- mouth: 1-20 (입)
- glasses: 0-14 (안경, 0=없음)
- beard: 0-16 (수염, 0=없음)
- accessories: 0-14 (액세서리, 0=없음)
- details: 0-13 (세부사항, 0=없음)

고려사항:
- 성별에 맞는 헤어/수염 선택
- 유명인 타입(운동선수, 가수, 배우 등)에 맞는 스타일
- 특징적인 외모 요소 반영 (안경, 수염 등)

JSON 형식으로만 응답:
{"face": N, "hair": N, "eyes": N, ...}
```

### 3. Implementation Steps

#### Step 1: Asset Download
```bash
# Notion Avatar 레포 클론 및 파츠 복사
git clone https://github.com/Mayandev/notion-avatar.git /tmp/notion-avatar
cp -r /tmp/notion-avatar/public/avatar/part/* assets/avatar/parts/
```

#### Step 2: Generation Script
```javascript
// scripts/generate_celebrity_avatars.js
const { createClient } = require('@supabase/supabase-js');
const OpenAI = require('openai');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');

// 1. 아바타 없는 유명인 조회
// 2. GPT로 파츠 추천 받기
// 3. SVG 합성
// 4. PNG 변환 및 업로드
// 5. DB 업데이트
```

#### Step 3: SVG Composition
- 각 파츠 SVG를 레이어로 합성
- 순서: Face → Hair → Eyes → Eyebrows → Nose → Mouth → Glasses → Beard → Accessories → Details
- 최종 크기: 200x200 PNG

#### Step 4: Storage Structure
```
Supabase Storage: celebrities/avatars/
├── {celebrity_id}.png
└── ...
```

#### Step 5: Flutter Integration
- 기존 `character_image_url` 필드 그대로 사용
- 새 아바타 URL: `https://[project].supabase.co/storage/v1/object/public/celebrities/avatars/{id}.png`

### 4. Batch Execution Plan

```bash
# 1차: 테스트 (10명)
node scripts/generate_celebrity_avatars.js --limit 10

# 2차: 전체 실행 (700명)
node scripts/generate_celebrity_avatars.js --all

# 실패 재시도
node scripts/generate_celebrity_avatars.js --retry-failed
```

### 5. Fallback Strategy
- 생성 실패 시: 기본 아바타 (성별/타입별 프리셋)
- API 에러 시: 이름 이니셜 기반 단순 아바타

### 6. File Changes Required

1. **새 파일 생성**:
   - `scripts/generate_celebrity_avatars.js` - 아바타 생성 스크립트
   - `assets/avatar/parts/` - Notion 아바타 파츠 (다운로드)

2. **DB 업데이트**:
   - `celebrities` 테이블의 `character_image_url` 필드 업데이트

3. **Flutter 코드 변경 없음**:
   - 기존 Image.network 로직 그대로 사용
   - URL만 새 아바타로 변경됨

### 7. Dependencies
```json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.x",
    "openai": "^4.x",
    "sharp": "^0.33.x"
  }
}
```

### 8. Estimated Work
- Asset 다운로드: 10분
- Generation Script 작성: 1시간
- 테스트 실행 (10명): 5분
- 전체 실행 (700명): ~2시간 (API rate limit 고려)
- 검증: 30분

## Execution Order

1. [ ] Notion Avatar 에셋 다운로드
2. [ ] scripts/generate_celebrity_avatars.js 작성
3. [ ] Supabase Storage 버킷 생성 (celebrities)
4. [ ] 테스트 실행 (10명)
5. [ ] 결과 검증
6. [ ] 전체 배치 실행
7. [ ] Flutter 앱에서 확인