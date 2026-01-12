# On-Demand 자산 딜리버리 시스템 설정 가이드

> 최종 업데이트: 2025.01

## 개요

앱 용량 최적화를 위한 On-Demand 자산 딜리버리 시스템입니다.

### 목표
| 지표 | 기존 | 목표 |
|------|------|------|
| 초기 다운로드 (App Store) | ~400 MB | **< 50 MB** |
| 첫 실행 후 필수 다운로드 | - | ~30 MB |
| 전체 기능 사용 시 | ~467 MB | ~200 MB (WebP 변환) |

### Tier 시스템
| Tier | 설명 | 다운로드 시점 |
|------|------|--------------|
| **Tier 1** | 앱 번들 필수 | 앱 설치 시 |
| **Tier 2** | 첫 실행 시 다운로드 | 온보딩 완료 후 |
| **Tier 3** | On-Demand | 기능 접근 시 |

---

## 1. Supabase Storage 버킷 설정

### 1.1 버킷 생성

Supabase Dashboard → Storage → New Bucket

```
버킷 이름: fortune-assets
Public bucket: ✅ (체크)
File size limit: 50MB
Allowed MIME types: image/webp, image/png, image/jpeg
```

### 1.2 폴더 구조 생성

```
fortune-assets/
├── tarot/                    # 타로 덱 (Tier 3)
│   ├── rider_waite/
│   │   ├── 00_fool.webp
│   │   ├── 01_magician.webp
│   │   └── ...
│   ├── thoth/
│   ├── ancient_italian/
│   ├── before_tarot/
│   ├── after_tarot/
│   ├── golden_dawn_cicero/
│   ├── golden_dawn_wang/
│   └── grand_etteilla/
├── heroes/                   # 히어로 이미지 (Tier 3)
│   ├── love/
│   ├── career/
│   ├── health/
│   ├── investment/
│   └── exam/
├── category/                 # 카테고리별 자산 (Tier 3)
│   ├── mbti/
│   ├── zodiac/
│   ├── saju/
│   ├── pets/
│   ├── talisman/
│   ├── lucky/
│   └── infographic/
├── icons/                    # 아이콘 (Tier 2)
│   └── categories/
├── minhwa/                   # 민화 (Tier 2)
├── chat/                     # 채팅 배경 (Tier 2)
│   └── backgrounds/
└── videos/                   # 비디오 (Tier 3)
```

### 1.3 RLS 정책 설정

```sql
-- Storage RLS 정책: 공개 읽기
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'fortune-assets');

-- 인증된 사용자만 업로드 (관리용)
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'fortune-assets');
```

---

## 2. WebP 변환

### 2.1 cwebp 설치

```bash
# macOS
brew install webp

# Linux
apt-get install webp
```

### 2.2 변환 스크립트 실행

```bash
# 변환 대상 확인 (dry-run)
./scripts/convert_to_webp.sh --dry-run --report

# 실제 변환 (원본 삭제)
./scripts/convert_to_webp.sh --quality 80 --report

# 원본 유지하면서 변환
./scripts/convert_to_webp.sh --quality 80 --keep-orig

# 특정 폴더만 변환
./scripts/convert_to_webp.sh --dir assets/images/tarot --quality 75
```

### 2.3 예상 용량 절감

| 포맷 | 변환 전 | 변환 후 | 절감률 |
|------|---------|---------|--------|
| JPG → WebP | ~250 MB | ~150 MB | 30-40% |
| PNG → WebP | ~100 MB | ~40 MB | 50-70% |
| **합계** | ~350 MB | ~190 MB | **~45%** |

---

## 3. 자산 업로드

### 3.1 Supabase CLI 설치

```bash
npm install -g supabase
supabase login
```

### 3.2 자산 업로드 스크립트

```bash
#!/bin/bash
# scripts/upload_assets.sh

BUCKET="fortune-assets"
PROJECT_REF="your-project-ref"

# 타로 덱 업로드
for deck in rider_waite thoth ancient_italian before_tarot after_tarot golden_dawn_cicero golden_dawn_wang grand_etteilla; do
  echo "Uploading tarot/$deck..."
  supabase storage cp -r assets/images/tarot/decks/$deck/ storage/$BUCKET/tarot/$deck/ \
    --project-ref $PROJECT_REF
done

# 카테고리 자산 업로드
echo "Uploading category assets..."
supabase storage cp -r assets/images/fortune/mbti/ storage/$BUCKET/category/mbti/ \
  --project-ref $PROJECT_REF

# ... 나머지 카테고리
```

### 3.3 수동 업로드 (Dashboard)

1. Supabase Dashboard → Storage → fortune-assets
2. 폴더 생성: `tarot/rider_waite`
3. 파일 드래그 앤 드롭으로 업로드
4. 각 덱별로 반복

---

## 4. 환경 변수 설정

### 4.1 .env 파일 업데이트

```env
# Supabase Storage
SUPABASE_STORAGE_URL=https://your-project-ref.supabase.co/storage/v1
SUPABASE_STORAGE_BUCKET=fortune-assets
```

### 4.2 AssetDeliveryService URL 업데이트

`lib/core/constants/asset_pack_config.dart` 수정:

```dart
static String getStorageUrl(String storagePath) {
  // 환경 변수에서 읽거나, 직접 설정
  const baseUrl = String.fromEnvironment(
    'SUPABASE_STORAGE_URL',
    defaultValue: 'https://your-project-ref.supabase.co/storage/v1',
  );
  const bucket = String.fromEnvironment(
    'SUPABASE_STORAGE_BUCKET',
    defaultValue: 'fortune-assets',
  );
  return '$baseUrl/object/public/$bucket/$storagePath';
}
```

---

## 5. pubspec.yaml 정리

### 5.1 Tier 1만 번들에 포함

```yaml
flutter:
  assets:
    # Tier 1: 앱 번들 필수 (15-20 MB)
    - assets/images/zpzg_logo.png
    - assets/images/zpzg_logo_light.png
    - assets/images/zpzg_logo_dark.png
    - assets/fonts/
    - assets/sounds/

    # 일일 운세 기본
    - assets/images/fortune/heroes/daily/
    - assets/images/fortune/icons/section/
    - assets/images/fortune/mascot/daily/

    # 채팅 기본
    - assets/images/chat/

    # ❌ 아래는 제거 (On-Demand로 전환)
    # - assets/images/tarot/
    # - assets/images/fortune/mbti/
    # - assets/images/minhwa/
```

### 5.2 제거할 자산 (Tier 2, 3)

번들에서 제거하고 Supabase Storage로 이동:
- `assets/images/tarot/decks/` (전체)
- `assets/images/fortune/mbti/characters/`
- `assets/images/fortune/zodiac/`
- `assets/images/fortune/saju/`
- `assets/images/fortune/pets/`
- `assets/images/fortune/talisman/`
- `assets/images/minhwa/`
- `assets/videos/`

---

## 6. 저장소 관리 UI 연동

### 6.1 설정 페이지에 추가

```dart
// lib/features/settings/presentation/pages/settings_page.dart

import '../widgets/storage_management_widget.dart';

// 설정 목록에 추가
ListTile(
  leading: Icon(Icons.storage),
  title: Text('저장소 관리'),
  subtitle: Text('다운로드된 자산 관리'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const StorageManagementPage(),
    ),
  ),
),
```

### 6.2 전체 페이지로 사용

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const StorageManagementPage(),
  ),
);
```

---

## 7. 타로 칩 연동

### 7.1 타로 칩 탭 시 다운로드 트리거

```dart
// 타로 칩 onTap 핸들러
Future<void> _onTarotChipTap() async {
  final service = AssetDeliveryService();
  await service.initialize();

  // 오늘의 덱 다운로드 (또는 이미 다운로드됨)
  final todaysDeck = await service.prepareTodaysTarotDeck();

  if (todaysDeck != null) {
    // 다운로드 완료 → 타로 페이지로 이동
    Navigator.push(context, ...);
  } else {
    // 다운로드 중 UI 표시
    _showDownloadingDialog();
  }
}
```

### 7.2 다운로드 진행률 UI

```dart
StreamBuilder<DownloadProgress>(
  stream: AssetDeliveryService().downloadProgress,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final progress = snapshot.data!;
      return LinearProgressIndicator(
        value: progress.progress,
      );
    }
    return const SizedBox.shrink();
  },
)
```

---

## 8. 테스트 체크리스트

### 8.1 오프라인 테스트
- [ ] 앱 설치 후 기본 기능 동작 확인
- [ ] 타로 덱 다운로드 후 비행기 모드에서 사용
- [ ] 캐시된 자산 로드 속도 확인

### 8.2 다운로드 테스트
- [ ] 타로 칩 탭 → 다운로드 시작
- [ ] 다운로드 진행률 UI 표시
- [ ] 다운로드 완료 후 자동 진행
- [ ] 네트워크 중단 후 재시도

### 8.3 저장소 관리 테스트
- [ ] 저장소 사용량 정확히 표시
- [ ] 개별 팩 삭제 기능
- [ ] 전체 삭제 후 재다운로드

---

## 9. 빌드 크기 확인

```bash
# Android APK 분석
flutter build apk --release --analyze-size

# iOS IPA 분석
flutter build ipa --release --analyze-size
```

### 예상 결과
- **변환 전**: ~400 MB
- **Tier 분리 후**: ~50 MB (초기 다운로드)
- **WebP 변환 후**: ~35 MB (추가 절감)

---

## 관련 파일

| 파일 | 역할 |
|------|------|
| `lib/core/models/asset_pack.dart` | 자산 팩 모델 |
| `lib/core/constants/asset_pack_config.dart` | 자산 매핑 설정 |
| `lib/core/services/asset_delivery_service.dart` | 다운로드/캐싱 서비스 |
| `lib/shared/widgets/smart_image.dart` | 스마트 이미지 위젯 |
| `lib/features/settings/presentation/widgets/storage_management_widget.dart` | 저장소 관리 UI |
| `scripts/convert_to_webp.sh` | WebP 변환 스크립트 |