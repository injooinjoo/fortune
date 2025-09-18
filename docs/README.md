# Fortune App Documentation

이 폴더는 Fortune Flutter 앱의 문서들을 포함합니다.

## 유명인 데이터베이스 관련 문서

### 📋 [DB_SCHEMA.md](./DB_SCHEMA.md)
- **목적**: 새로운 Celebrity DB 스키마의 전체 구조 설명
- **내용**:
  - 테이블 구조 및 필드 상세 설명
  - 직군별 특화 정보 스키마 (JSON 구조)
  - 인덱스 및 성능 최적화 정보
  - 헬퍼 함수 및 통계 뷰
  - Flutter 모델과의 매핑 관계

### 🔄 [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
- **목적**: 기존 스키마에서 새 스키마로의 마이그레이션 가이드
- **내용**:
  - 5단계 마이그레이션 프로세스
  - 데이터 변환 규칙 및 매핑
  - 검증 및 테스트 방법
  - 롤백 계획 및 문제 해결 가이드
  - 성능 영향 분석

### 💻 [API_USAGE.md](./API_USAGE.md)
- **목적**: Flutter 앱에서 Celebrity API 사용법
- **내용**:
  - Celebrity 모델 클래스 사용법
  - Supabase 서비스 구현 예시
  - UI 컴포넌트 개발 가이드
  - 에러 처리 및 성능 최적화 팁

## 마이그레이션 파일

다음 Supabase 마이그레이션 파일들이 생성되었습니다:

1. **20250119000001_backup_existing_celebrities.sql** - 기존 데이터 백업
2. **20250119000002_create_new_celebrity_schema.sql** - 새 스키마 생성
3. **20250119000003_migrate_existing_data.sql** - 데이터 변환 마이그레이션
4. **20250119000004_create_indexes_and_functions.sql** - 인덱스 및 함수 생성
5. **20250119000005_cleanup_old_tables.sql** - 기존 테이블 정리

## Flutter 모델 변경사항

- **기존**: `lib/data/models/celebrity.dart` → `celebrity_old.dart`로 백업
- **신규**: 새로운 `Celebrity` 모델 클래스 생성
  - 8가지 직업 유형 지원 (`CelebrityType` enum)
  - 직군별 특화 정보 (`professionData` JSON 필드)
  - 외부 링크 정보 (`ExternalIds` 클래스)
  - 다국어 이름 및 별칭 지원

## 주요 개선사항

### 🎯 스키마 설계
- **유연성**: JSON 필드를 통한 직업별 특화 정보 저장
- **확장성**: 새로운 직업 유형 쉽게 추가 가능
- **성능**: 최적화된 인덱스로 빠른 검색 지원
- **국제화**: 다국어 이름 및 별칭 지원

### 📊 데이터 구조
- **8가지 직업 유형**: 프로게이머, 스트리머, 정치인, 기업인, 솔로가수, 아이돌멤버, 배우, 운동선수
- **외부 링크 통합**: Wikipedia, YouTube, Instagram, X(Twitter) 등
- **검색 최적화**: 전문 검색 및 필터링 함수 제공

### 🔧 개발자 경험
- **타입 안전성**: 강화된 Dart enum 및 모델 클래스
- **편의 함수**: 직업별 특화 검색 함수 제공
- **문서화**: 상세한 사용법 및 예시 코드
- **에러 처리**: 포괄적인 예외 처리 가이드

## 사용 방법

### 1. 마이그레이션 실행
```bash
# Supabase CLI 사용
supabase db push

# 또는 수동 실행
psql "connection_string" -f supabase/migrations/20250119000001_backup_existing_celebrities.sql
# ... 나머지 마이그레이션 파일들 순서대로 실행
```

### 2. Flutter 코드 업데이트
```dart
// 새로운 Celebrity 모델 사용
import 'package:fortune/data/models/celebrity.dart';

// 서비스 클래스에서 새로운 검색 함수 활용
final celebrities = await celebrityService.searchCelebrities('아이유');
final actors = await celebrityService.getCelebritiesByType(CelebrityType.actor);
```

### 3. 문서 참고
- 데이터베이스 구조: `DB_SCHEMA.md`
- 마이그레이션 과정: `MIGRATION_GUIDE.md`
- 개발 가이드: `API_USAGE.md`

## 주의사항

⚠️ **운영 환경 적용 전 필수 확인사항**:
1. 스테이징 환경에서 전체 마이그레이션 테스트
2. 충분한 데이터 백업 준비
3. 다운타임 최소화를 위한 배포 계획 수립
4. 롤백 계획 준비

## 지원 및 문의

- **마이그레이션 관련**: MIGRATION_GUIDE.md의 문제해결 섹션 참고
- **API 사용법**: API_USAGE.md의 예시 코드 참고
- **스키마 구조**: DB_SCHEMA.md의 상세 설명 참고

---

**최종 업데이트**: 2025년 1월 19일
**작성자**: Claude Code Assistant