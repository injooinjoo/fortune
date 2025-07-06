# Post-Development Mandatory Process Rules

## 📋 필수 진행 사항 (Mandatory Post-Development Checklist)

모든 개발 요청 및 작업 완료 후 아래 내용을 반드시 수행해야 합니다.

### 1. 🔍 코드 품질 검증
```bash
# 1.1 Linting - 코드 스타일 및 문법 검사
npm run lint

# 1.2 Type Check - TypeScript 타입 검증
npm run type-check

# 1.3 Format Check - 코드 포맷팅 검증
npm run format:check
```

### 2. 🧪 테스트 실행
```bash
# 2.1 Unit Tests - 단위 테스트
npm test

# 2.2 E2E Tests - 통합 테스트 (선택적)
npm run test:e2e

# 2.3 Coverage Report - 테스트 커버리지 확인
npm run test:coverage
```

### 3. 📝 문서화 업데이트
- [ ] 변경된 기능에 대한 README.md 업데이트
- [ ] API 변경사항이 있으면 docs/api-reference.md 업데이트
- [ ] 새로운 환경변수 추가 시 .env.local.example 업데이트
- [ ] 주요 변경사항은 CHANGELOG.md에 기록 (있는 경우)

### 4. 🔒 보안 검증
```bash
# 4.1 의존성 취약점 검사
npm audit

# 4.2 민감 정보 노출 검사
# - API 키나 비밀번호가 코드에 하드코딩되지 않았는지 확인
# - console.log에 민감한 정보가 출력되지 않는지 확인
```

### 5. 🚀 빌드 검증
```bash
# 5.1 Production Build - 프로덕션 빌드 성공 여부
npm run build

# 5.2 Build Size Check - 빌드 크기 확인
# 빌드 후 .next 폴더 크기 확인
```

### 6. 💾 Git 커밋 규칙
```bash
# 6.1 변경사항 확인
git status
git diff

# 6.2 단계적 커밋 (관련 파일끼리 묶어서)
git add [관련 파일들]
git commit -m "type: 간단명료한 설명"

# Commit Type 예시:
# - feat: 새로운 기능
# - fix: 버그 수정
# - docs: 문서 수정
# - style: 코드 포맷팅
# - refactor: 코드 리팩토링
# - test: 테스트 추가/수정
# - chore: 빌드, 패키지 매니저 설정 등
```

### 7. 📊 성능 영향 평가
- [ ] 새 기능이 기존 성능에 미치는 영향 확인
- [ ] API 응답 시간이 크게 증가하지 않았는지 확인
- [ ] 메모리 사용량이 적절한지 확인

### 8. 🔄 의존성 관리
```bash
# 8.1 불필요한 패키지 제거
npm prune

# 8.2 package-lock.json 동기화
npm install
```

### 9. 🐛 에러 처리 확인
- [ ] try-catch 블록이 적절히 사용되었는지
- [ ] 에러 메시지가 사용자 친화적인지
- [ ] 에러 로깅이 제대로 구현되었는지

### 10. 📱 반응형 디자인 검증
- [ ] 모바일 뷰 (320px - 768px)
- [ ] 태블릿 뷰 (768px - 1024px)  
- [ ] 데스크톱 뷰 (1024px+)

### 11. 🔐 보안 검토 (Security Review)
**"Please review all the code you just wrote and ensure it follows security best practices. Make sure there is no sensitive information in the front end and that there are no vulnerabilities that could be exploited"**

#### 체크 항목:
- [ ] 프론트엔드에 민감한 정보가 노출되지 않았는지 확인
  - API 키, 비밀번호, 토큰 등이 클라이언트 코드에 없는지
  - 환경변수가 NEXT_PUBLIC_ 접두사 없이 클라이언트에서 사용되지 않는지
- [ ] 보안 취약점 검사
  - SQL Injection 방지 (파라미터화된 쿼리 사용)
  - XSS 방지 (사용자 입력 sanitization)
  - CSRF 방지 (토큰 검증)
  - 인증/인가 적절히 구현
- [ ] API 엔드포인트 보안
  - 인증이 필요한 엔드포인트에 미들웨어 적용
  - Rate limiting 구현
  - 입력값 검증 (Zod 등 사용)
- [ ] 에러 메시지에 민감한 정보 노출 방지
  - 스택 트레이스가 프로덕션에서 노출되지 않도록
  - 데이터베이스 구조나 내부 로직 정보 숨김

### 12. 📚 코드 설명 및 교육 (Code Explanation)
**"Please explain the functionality and code you just built out in detail. Walk me through what you changed and how it works. Act like you're a senior engineer teaching me code."**

#### 설명 포함 사항:
- [ ] 전체 아키텍처 및 데이터 흐름 설명
- [ ] 각 주요 함수/컴포넌트의 목적과 작동 방식
- [ ] 사용된 디자인 패턴과 그 이유
- [ ] 성능 최적화 기법 설명
- [ ] 에러 처리 전략
- [ ] 향후 확장 가능성 및 개선점

#### 문서화 템플릿:
```markdown
## 구현 내용 상세 설명

### 1. 개요
- 구현한 기능의 목적
- 해결하려는 문제
- 선택한 접근 방식

### 2. 아키텍처
- 전체 시스템 구조
- 컴포넌트 간 상호작용
- 데이터 흐름

### 3. 핵심 코드 설명
- 주요 함수/클래스 설명
- 알고리즘 선택 이유
- 엣지 케이스 처리

### 4. 보안 고려사항
- 적용된 보안 조치
- 잠재적 위험과 대응

### 5. 성능 최적화
- 적용된 최적화 기법
- 측정된 성능 개선

### 6. 테스트 전략
- 테스트 커버리지
- 중요 테스트 케이스

### 7. 향후 개선사항
- 알려진 제한사항
- 개선 가능한 부분
```

## 🚨 중요 체크포인트

### 개발 전 확인사항
1. 현재 브랜치가 올바른지 확인 (`git branch`)
2. 최신 코드를 pull 했는지 확인 (`git pull origin main`)
3. 환경변수가 올바르게 설정되었는지 확인

### 개발 후 필수 확인사항
1. **Math.random() 사용 금지** - 서버사이드에서 결정적 값 생성
2. **API 키 노출 금지** - 환경변수 사용
3. **console.log 제거** - 프로덕션 코드에서 제거
4. **주석 정리** - 불필요한 주석 및 TODO 제거
5. **import 정리** - 사용하지 않는 import 제거

## 📋 최종 체크리스트 템플릿

```markdown
## 개발 완료 체크리스트

### 코드 품질
- [ ] ESLint 통과
- [ ] TypeScript 컴파일 성공
- [ ] Prettier 포맷팅 완료

### 테스트
- [ ] 모든 테스트 통과
- [ ] 새로운 기능에 대한 테스트 추가
- [ ] 테스트 커버리지 80% 이상 유지

### 문서화
- [ ] README.md 업데이트
- [ ] API 문서 업데이트
- [ ] 코드 주석 추가

### 보안
- [ ] 민감한 정보 노출 없음
- [ ] 의존성 취약점 없음

### 성능
- [ ] 빌드 성공
- [ ] 성능 저하 없음
- [ ] 번들 크기 적절

### Git
- [ ] 의미있는 커밋 메시지
- [ ] 관련 파일만 커밋
- [ ] PR 생성 (필요시)
```

## 🔧 자동화 스크립트

`scripts/post-dev-check.sh` 생성을 제안합니다:

```bash
#!/bin/bash
echo "🔍 Post-Development Check Starting..."

# 1. Lint
echo "📝 Running ESLint..."
npm run lint || exit 1

# 2. Type Check
echo "🔤 Running TypeScript Check..."
npm run type-check || exit 1

# 3. Test
echo "🧪 Running Tests..."
npm test || exit 1

# 4. Build
echo "🏗️ Running Build..."
npm run build || exit 1

# 5. Audit
echo "🔒 Running Security Audit..."
npm audit

# 6. Security Review Reminder
echo "🔐 Security Review Required!"
echo "Please ensure:"
echo "  - No sensitive information in frontend code"
echo "  - No API keys or secrets exposed"
echo "  - All user inputs are validated"
echo "  - Authentication is properly implemented"

# 7. Code Explanation Reminder
echo "📚 Code Documentation Required!"
echo "Please prepare:"
echo "  - Detailed explanation of implementation"
echo "  - Architecture and data flow documentation"
echo "  - Security considerations"
echo "  - Performance optimizations"

echo "✅ Automated checks passed! Please complete manual security review and code documentation."
```

이 스크립트를 실행 권한과 함께 추가:
```bash
chmod +x scripts/post-dev-check.sh
npm run postdev:check  # package.json에 스크립트 추가
```

## 🎯 목표

이러한 프로세스를 통해:
1. **코드 품질 유지** - 일관된 코드 스타일과 품질
2. **버그 최소화** - 철저한 테스트로 버그 사전 방지
3. **보안 강화** - 취약점 및 민감정보 노출 방지
4. **성능 최적화** - 빌드 크기 및 응답 시간 관리
5. **유지보수성 향상** - 명확한 문서화와 코드 구조

모든 개발자는 이 체크리스트를 완료한 후에만 코드를 머지해야 합니다.

---

*Last updated: 2025-07-06*
*Version: 1.0.0*