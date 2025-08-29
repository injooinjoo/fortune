# 나무위키 덤프 처리 가이드

## 개요

나무위키에서 연예인 정보를 안전하고 효율적으로 수집하기 위해 공식 덤프 파일을 활용합니다.  
직접 크롤링 대신 덤프를 사용함으로써 서버 부하를 주지 않고 법적 안전성을 확보합니다.

## 📥 1. 나무위키 덤프 다운로드

### 공식 덤프 사이트
- **URL**: https://dumps.namu.wiki/
- **업데이트**: 월 1회 정도
- **파일 형식**: XML (MediaWiki 호환)
- **압축**: 7z, gzip 등

### 다운로드 과정
1. https://dumps.namu.wiki/ 방문
2. 최신 덤프 파일 선택 (보통 `namuwiki-{날짜}.xml.7z` 형식)
3. 다운로드 (약 10-20GB, 압축 해제 시 더 큼)
4. 압축 해제하여 XML 파일 추출

### 권장 저장 위치
```
/Users/username/Downloads/namuwiki/
├── namuwiki-20231201.xml.7z  (압축 파일)
└── namuwiki-20231201.xml     (압축 해제된 XML 파일)
```

## 🔧 2. 환경 설정

### 필수 환경변수
```bash
# Supabase 연결 정보
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key

# 덤프 파일 경로
DUMP_PATH=/Users/username/Downloads/namuwiki/namuwiki-20231201.xml
```

### 시스템 요구사항
- **RAM**: 최소 8GB, 권장 16GB 이상
- **저장공간**: 50GB 이상 여유 공간
- **처리시간**: 약 2-4시간 (연예인 400명 기준)

## 🚀 3. 실행 방법

### 기본 실행
```bash
# 프로젝트 루트에서 실행
flutter run lib/scripts/run_namuwiki_dump_processing.dart \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=DUMP_PATH=/path/to/namuwiki.xml
```

### 단계별 실행 예시
```bash
# 1. 연예인 목록 먼저 업로드 (이미 완료된 경우 생략)
flutter run lib/scripts/upload_celebrity_lists.dart

# 2. 덤프 처리 실행
flutter run lib/scripts/run_namuwiki_dump_processing.dart \
  --dart-define=DUMP_PATH=/Users/jacobmac/Downloads/namuwiki.xml
```

## 📊 4. 처리 과정

### 4.1 덤프 파일 분석
- XML 파일을 스트리밍 방식으로 읽기
- 메모리 효율적인 처리
- 연예인 이름으로 해당 페이지 검색

### 4.2 정보 추출
각 연예인 페이지에서 다음 정보를 추출합니다:

```yaml
기본 정보:
  - 이름 (한글/영문)
  - 생년월일
  - 성별
  - 카테고리 (가수, 배우, 스트리머 등)

상세 정보:
  - 프로필 이미지 URL
  - 설명 (첫 번째 문단)
  - 키워드 목록
  - 데뷔 정보
  - 소속사
  - 직업
  - 별명/예명
```

### 4.3 데이터 저장
- **celebrities 테이블**: 상세 연예인 정보
- **celebrity_master_list**: 크롤링 상태 업데이트 (`is_crawled = true`)

## ⚡ 5. 성능 최적화

### 배치 처리
- 50명씩 배치로 처리
- 배치 간 2초 딜레이
- 메모리 정리를 위한 가비지 컬렉션

### 메모리 관리
- 스트림 기반 XML 파싱
- 대용량 파일을 메모리에 전체 로드하지 않음
- 처리 완료된 데이터는 즉시 해제

## 📈 6. 모니터링 및 로깅

### 실시간 진행 상황
```
🔄 배치 처리 시작 (8개 배치, 배치당 50명)

📦 배치 1/8 처리 중 (50명)...
  ✅ BTS
  ✅ 블랙핑크
  ❌ 아이유: 덤프에서 찾을 수 없음
📊 배치 1 완료: 성공 48명, 실패 2명

📦 배치 2/8 처리 중 (50명)...
...
```

### 최종 결과
```
🎉 덤프 처리 완료!
📊 최종 결과:
  총 처리: 400명
  성공: 362명 (90.5%)
  실패: 38명 (9.5%)
```

## 🔍 7. 문제 해결

### 자주 발생하는 오류

#### 메모리 부족
```bash
# 해결: 배치 크기 줄이기
# run_namuwiki_dump_processing.dart에서 batchSize = 25로 수정
```

#### 파일 경로 오류
```bash
❌ 덤프 파일이 존재하지 않습니다
# 해결: DUMP_PATH 환경변수 확인
```

#### Supabase 연결 오류
```bash
❌ SUPABASE_URL과 SUPABASE_ANON_KEY 환경변수를 설정해주세요
# 해결: 환경변수 올바르게 설정
```

### 성능 개선 팁

#### 1. SSD 사용
- 덤프 파일을 SSD에 저장
- 더 빠른 읽기 성능

#### 2. 병렬 처리 비활성화
- 다른 무거운 작업 중단
- 시스템 리소스 집중

#### 3. 부분 처리
```dart
// 특정 카테고리만 처리하고 싶을 때
final targetCelebrities = await listService.getNextCelebritiesToCrawl(
  limit: 100,
  category: 'singer', // 가수만
);
```

## 📝 8. 결과 확인

### 데이터베이스 확인
```sql
-- 처리 완료된 연예인 수 확인
SELECT COUNT(*) FROM celebrities WHERE additional_info->>'processed_from_dump' = 'true';

-- 카테고리별 통계
SELECT category, COUNT(*) as count 
FROM celebrities 
GROUP BY category 
ORDER BY count DESC;

-- 마스터 리스트 상태 확인
SELECT 
  category,
  COUNT(*) as total,
  COUNT(CASE WHEN is_crawled THEN 1 END) as crawled
FROM celebrity_master_list 
GROUP BY category;
```

### 데이터 품질 검증
```dart
// 생년월일이 있는 연예인 비율
// 프로필 이미지가 있는 연예인 비율  
// 설명이 충분한 연예인 비율
```

## 🚨 9. 주의사항

### 법적 고려사항
- ✅ **허용**: 공식 덤프 파일 사용
- ❌ **금지**: 직접 웹사이트 크롤링
- ✅ **권장**: 출처 명시 및 적절한 사용

### 데이터 업데이트
- 덤프는 월 1회 업데이트
- 최신 정보가 필요한 경우 새 덤프 다운로드 필요
- 기존 데이터와 충돌 시 덤프 데이터 우선

### 저작권
- 추출된 정보는 나무위키 라이선스 준수
- 상업적 사용 시 라이선스 검토 필요
- 이미지 URL은 원본 서버에 의존

## 📞 10. 지원

### 문제 신고
- GitHub Issues에 문제 신고
- 로그와 함께 상세한 설명 제공

### 개선 제안
- 더 효율적인 파싱 방법
- 새로운 정보 필드 추가
- 성능 최적화 아이디어

---

이 가이드를 따라 진행하면 400명의 연예인 정보를 안전하고 효율적으로 수집할 수 있습니다! 🎉