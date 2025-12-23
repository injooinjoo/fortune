# Fortune Flutter 프로젝트 정리 보고서

> 📅 작성일: 2025-01-06
> 🎯 목적: 프로젝트 구조 최적화 및 미사용 파일 정리

---

## 📊 프로젝트 현황

### 전체 통계
- **총 Dart 파일**: 661개
- **정리 대상 식별**: 50+ 파일

---

## 🔍 발견된 정리 대상

### 1. 구형 버전 파일 (_old, _v2)

#### 완전 미사용 파일 (삭제 권장)

**`lib/data/models/celebrity_old.dart`**
- 사용처: celebrity_old.g.dart에서만 참조 (자동생성 파일)
- 대체 파일: `lib/data/models/celebrity.dart` (현재 사용 중)
- 권장 조치: **삭제**

**`lib/data/models/celebrity_old.g.dart`**
- celebrity_old.dart의 자동생성 파일
- 권장 조치: **삭제**

#### 사용 중인 _v2 파일 (유지 필요)

**`lib/features/payment/presentation/pages/token_purchase_page_v2.dart`**
- 사용처: route_config.dart → `/token-purchase` 라우트
- 상태: **현재 사용 중** (route에 등록됨)
- 권장 조치: 파일명을 `token_purchase_page.dart`로 변경

**`lib/presentation/screens/ad_loading_screen_v2.dart`**
- 확인 필요: 사용처 조사 후 결정

#### base_fortune_page_v2.dart (18개 파일에서 사용)

**`lib/features/fortune/presentation/pages/base_fortune_page_v2.dart`**
- 사용처: 18개 운세 페이지의 기반 클래스
- 사용하는 페이지들:
  - face_reading_fortune_page.dart
  - palmistry_fortune_page.dart
  - new_year_page.dart
  - network_report_page.dart
  - lucky_sidejob_fortune_page.dart
  - lucky_series_fortune_page.dart
  - lucky_investment_fortune_page.dart
  - influencer_fortune_page.dart
  - lucky_job_fortune_page.dart
  - employment_fortune_page.dart
  - lucky_stock_fortune_page.dart
  - lucky_outfit_fortune_page.dart
  - five_blessings_fortune_page.dart
  - network_report_fortune_page.dart
  - destiny_fortune_page.dart
  - ... (총 18개)
- 상태: **현재 활발히 사용 중**
- 권장 조치: 파일명을 `base_fortune_page.dart`로 변경 (v2 제거)

**`lib/features/fortune/presentation/pages/celebrity_fortune_page_v2.dart`**
- 사용처: personality_routes.dart에서 라우트 등록
- 상태: **현재 사용 중**
- 대체 파일: celebrity_fortune_enhanced_page.dart 존재
- 권장 조치: enhanced 버전으로 통합 또는 v2 제거

---

### 2. 테스트 관련 파일 (ab_test)

**AB 테스트 시스템 파일들** (정상 - 유지):
- `lib/core/constants/ab_test_events.dart` - A/B 테스트 이벤트 상수
- `lib/models/ab_test_experiment.dart` - 실험 모델
- `lib/models/ab_test_result.dart` - 결과 모델
- `lib/models/ab_test_variant.dart` - 변형 모델
- `lib/widgets/ab_test_widget.dart` - A/B 테스트 위젯
- `lib/widgets/ab_test_dashboard.dart` - 대시보드
- `lib/services/ab_test_manager.dart` - 관리자
- `lib/services/ab_test_service.dart` - 서비스

**심리 테스트 페이지** (정상 - 유지):
- `lib/features/interactive/presentation/pages/psychology_test_page.dart`

---

### 3. 미완성/폐기 기능

#### 완전 고아 파일 (import 없음)

**Core 에러 처리 중복**:
- `lib/core/error/exceptions.dart` - 중복 (core/errors/exceptions.dart 사용 중)
- `lib/core/error/failures.dart` - 미사용
- 권장 조치: **삭제** (core/errors/ 폴더 사용)

**폐기된 운세 페이지**:
- `lib/features/fortune/presentation/pages/face_reading_fortune_page.dart` - 관상 (미완성)
- `lib/features/fortune/presentation/pages/palmistry_fortune_page.dart` - 손금 (미완성)
- `lib/features/fortune/presentation/pages/saju_psychology_fortune_page.dart` - 사주 심리 (폐기)
- 권장 조치: **삭제** 또는 주석 처리

**관리자 페이지 (미완성)**:
- `lib/features/admin/pages/admin_dashboard_page.dart`
- `lib/features/admin/pages/admin_logs_page.dart`
- `lib/features/admin/pages/admin_redis_stats_page.dart`
- `lib/features/admin/pages/admin_stats_page.dart`
- `lib/features/admin/pages/admin_token_usage_page.dart`
- `lib/features/admin/pages/admin_users_page.dart`
- 권장 조치: **주석 처리** (향후 구현 예정)

---

## 🎯 정리 우선순위

### Priority 1 (즉시 실행 가능)

**삭제 권장 파일** (6개):
1. `lib/data/models/celebrity_old.dart`
2. `lib/data/models/celebrity_old.g.dart`
3. `lib/core/error/exceptions.dart`
4. `lib/core/error/failures.dart`
5. `lib/features/fortune/presentation/pages/saju_psychology_fortune_page.dart`
6. `lib/data/models/celebrity_saju.dart`

예상 절감: ~500줄 코드

### Priority 2 (파일명 변경)

**_v2 제거**:
1. `token_purchase_page_v2.dart` → `token_purchase_page.dart`
2. `ad_loading_screen_v2.dart` → `ad_loading_screen.dart`
3. `base_fortune_page_v2.dart` → `base_fortune_page.dart`

**주의**: 각 파일을 사용하는 모든 import 구문도 함께 수정 필요

### Priority 3 (검토 후 결정)

**미완성 기능 처리**:
- face_reading_fortune_page.dart (관상)
- palmistry_fortune_page.dart (손금)
- 관리자 페이지들 (6개)

**결정 필요**:
- 구현 계획이 있으면 유지
- 계획 없으면 삭제 또는 주석 처리

---

## 🚀 실행 계획

### 1단계: 안전한 파일 삭제

```bash
# 백업 브랜치 생성
git checkout -b cleanup/remove-old-files

# 구형 celebrity 모델 삭제
rm lib/data/models/celebrity_old.dart
rm lib/data/models/celebrity_old.g.dart

# 중복 에러 처리 삭제
rm lib/core/error/exceptions.dart
rm lib/core/error/failures.dart

# 폐기된 운세 페이지 삭제
rm lib/features/fortune/presentation/pages/saju_psychology_fortune_page.dart
rm lib/data/models/celebrity_saju.dart

# 빌드 테스트
flutter analyze
```

### 2단계: 파일명 변경 (Import 수정 포함)

**base_fortune_page_v2.dart 변경**:
```bash
# 1. 파일 이동
git mv lib/features/fortune/presentation/pages/base_fortune_page_v2.dart \
        lib/features/fortune/presentation/pages/base_fortune_page.dart

# 2. import 구문 일괄 수정 (18개 파일)
find lib/features/fortune/presentation/pages -name "*.dart" -exec \
  sed -i '' 's/base_fortune_page_v2.dart/base_fortune_page.dart/g' {} +

# 3. 빌드 테스트
flutter analyze
```

**token_purchase_page_v2.dart 변경**:
```bash
# 1. 파일 이동
git mv lib/features/payment/presentation/pages/token_purchase_page_v2.dart \
        lib/features/payment/presentation/pages/token_purchase_page.dart

# 2. route_config.dart 수정
# TokenPurchasePageV2 → TokenPurchasePage 클래스명도 변경 필요

# 3. 빌드 테스트
flutter analyze
```

### 3단계: 검증 및 커밋

```bash
# 전체 빌드 테스트
flutter clean
flutter pub get
flutter analyze

# 실제 디바이스에서 테스트
flutter run --release -d 00008140-00120304260B001C

# 커밋
git add .
git commit -m "🧹 CLEANUP: Remove old files and rename _v2 files

- Remove: celebrity_old.dart, core/error/ duplicates
- Remove: saju_psychology_fortune_page.dart (deprecated)
- Rename: base_fortune_page_v2.dart → base_fortune_page.dart
- Rename: token_purchase_page_v2.dart → token_purchase_page.dart
- Update all import statements

Total files cleaned: 6 deleted, 3 renamed
"
```

---

## 📋 체크리스트

### Priority 1 실행 전

- [ ] 백업 브랜치 생성
- [ ] celebrity_old.dart 사용처 최종 확인
- [ ] core/error/ vs core/errors/ 사용 현황 확인
- [ ] saju_psychology_fortune_page.dart 라우트 등록 여부 확인

### Priority 2 실행 전

- [ ] base_fortune_page_v2.dart 사용하는 18개 파일 목록 작성
- [ ] token_purchase_page_v2.dart 클래스명 변경 계획 수립
- [ ] ad_loading_screen_v2.dart 사용처 조사

### 실행 후 검증

- [ ] `flutter analyze` 에러 없음
- [ ] 실제 디바이스에서 주요 기능 테스트
  - [ ] 홈 화면 로딩
  - [ ] 운세 목록 표시
  - [ ] 사주 운세 실행
  - [ ] 토큰 구매 페이지 접근
- [ ] 테스트 계정으로 전체 플로우 확인

---

## 📈 예상 효과

### 코드 정리
- **삭제될 파일**: 6개
- **변경될 파일**: 3개 + import 수정 20개
- **예상 코드 감소**: ~500-700줄

### 가독성 향상
- _v2 파일명 제거로 최신 버전 명확화
- 중복 에러 처리 폴더 통합
- 구형 모델 제거

### 유지보수성
- 사용되지 않는 코드 제거
- 파일명 일관성 확보
- import 경로 단순화

---

## ⚠️ 주의사항

1. **반드시 백업 브랜치에서 작업**
2. **각 단계마다 `flutter analyze` 실행**
3. **실제 디바이스에서 테스트 필수**
4. **문제 발생 시 즉시 롤백**
5. **클래스명 변경은 신중하게** (route 등록 확인)

---

## 🔗 관련 문서

- [파일 의존성 맵](./FILE_DEPENDENCY_MAP.md)
- [프로젝트 개요](../getting-started/PROJECT_OVERVIEW.md)
- [Claude 자동화](./CLAUDE_AUTOMATION.md)

---

**마지막 업데이트**: 2025-01-06
**작성자**: Claude Code Cleanup Analysis
**다음 검토일**: 2025-02-06 (월 1회 정기 정리 권장)
