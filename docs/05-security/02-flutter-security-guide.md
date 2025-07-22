# Flutter 앱 보안 가이드

## 📋 목차
1. [API 키 관리](#api-키-관리)
2. [환경 변수 설정](#환경-변수-설정)
3. [Git 보안](#git-보안)
4. [코드 레벨 보안](#코드-레벨-보안)
5. [보안 체크리스트](#보안-체크리스트)

## 🔐 API 키 관리

### 1. 환경 변수 사용
모든 API 키와 민감한 정보는 `.env` 파일로 관리합니다.

```bash
# .env 파일 생성
cp .env.example .env

# 실제 키 값 입력
nano .env
```

### 2. 환경 변수 구조
```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Firebase (FCM용)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_WEB_API_KEY=your-web-api-key
# ... 기타 플랫폼별 키

# Google OAuth
GOOGLE_WEB_CLIENT_ID=your-client-id
GOOGLE_IOS_CLIENT_ID=your-ios-client-id
```

### 3. 코드에서 사용
```dart
// ✅ 올바른 방법
import 'core/config/environment.dart';

final supabaseUrl = Environment.supabaseUrl;
final apiKey = Environment.supabaseAnonKey;

// ❌ 잘못된 방법
final apiKey = "AIzaSy..."; // 절대 하드코딩 금지!
```

## 🛡️ 환경 변수 설정

### 개발 환경
1. `.env` 파일 생성 (`.env.example` 참고)
2. 실제 키 값 입력
3. `.gitignore`에 `.env` 포함 확인

### 프로덕션 환경
1. CI/CD 환경 변수 설정
2. 빌드 시 환경 변수 주입
3. 서버 환경 변수 사용

### Flutter에서 환경 변수 읽기
```dart
// Environment 클래스 사용
class Environment {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // 환경별 설정
  static String get apiBaseUrl {
    if (kReleaseMode) {
      return 'https://api.fortune.com';
    }
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  }
}
```

## 📁 Git 보안

### .gitignore 필수 항목
```gitignore
# 환경 변수
.env
.env.*
!.env.example

# Firebase 설정
google-services.json
GoogleService-Info.plist
firebase_options.dart

# 빌드 파일
*.keystore
*.jks
key.properties
```

### Git 히스토리 정리
민감한 정보가 커밋된 경우:
```bash
# Git 히스토리 정리 스크립트 실행
./scripts/clean-git-history.sh

# 또는 수동으로
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all
```

### git-secrets 설치 및 설정
```bash
# macOS
brew install git-secrets

# Linux
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets
make install

# 설치 후 설정
cd /path/to/your/project
git secrets --install
git secrets --register-aws  # AWS 패턴 등록

# 커스텀 패턴 추가
git secrets --add 'sk-[a-zA-Z0-9]{48}'  # OpenAI API 키
git secrets --add 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'  # Supabase 키
```

## 🔒 코드 레벨 보안

### 1. 보안 저장소 사용
```dart
// 민감한 정보는 flutter_secure_storage 사용
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// 저장
await storage.write(key: 'auth_token', value: token);

// 읽기
final token = await storage.read(key: 'auth_token');
```

### 2. API 호출 보안
```dart
// 항상 HTTPS 사용
final url = Uri.https('api.fortune.com', '/endpoint');

// 인증 헤더 추가
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

### 3. 입력 검증
```dart
// 사용자 입력 검증
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

// SQL 인젝션 방지 (Supabase 사용 시)
final result = await supabase
  .from('users')
  .select()
  .eq('email', email); // 파라미터화된 쿼리
```

## ✅ 보안 체크리스트

### 개발 시작 전
- [ ] `.env.example` 파일 확인
- [ ] `.env` 파일 생성 및 키 입력
- [ ] `.gitignore` 확인

### 코드 작성 시
- [ ] API 키 하드코딩 금지
- [ ] 환경 변수 사용
- [ ] HTTPS 통신만 사용
- [ ] 사용자 입력 검증

### 커밋 전
- [ ] 민감한 정보 포함 여부 확인
- [ ] `.env` 파일이 staging에 없는지 확인
- [ ] `git status`로 추적 파일 확인

### 배포 전
- [ ] 프로덕션 환경 변수 설정
- [ ] API 키 권한 최소화
- [ ] 도메인/IP 제한 설정
- [ ] 사용량 제한 설정

### 정기 점검
- [ ] API 키 정기 교체 (3개월마다)
- [ ] 노출된 키 확인 (GitHub 알림)
- [ ] 보안 업데이트 적용
- [ ] 의존성 취약점 검사

## 🚨 긴급 대응

### API 키 노출 시 대응 절차
1. **즉시 키 비활성화**
   ```bash
   # Supabase Dashboard에서 키 비활성화
   # 또는 CLI 사용
   supabase projects api-keys revoke --project-ref=xqgkckkvcyufhpdqgdxj
   ```

2. **새 키 발급**
   ```bash
   # 새 API 키 생성
   supabase projects api-keys create --project-ref=xqgkckkvcyufhpdqgdxj
   ```

3. **환경 변수 업데이트**
   ```bash
   # 모든 환경의 .env 파일 업데이트
   echo "SUPABASE_ANON_KEY=new-key-here" >> .env
   ```

4. **Git 히스토리 정리**
   ```bash
   # 노출된 키가 포함된 커밋 제거
   ./scripts/clean-git-secrets.sh
   
   # Force push (주의!)
   git push --force-with-lease origin main
   ```

5. **영향 범위 확인 및 팀원 공지**
   - 노출된 키로 접근 가능했던 데이터 확인
   - 의심스러운 활동 로그 검토
   - 팀원들에게 키 교체 알림

### 보안 도구
- [git-secrets](https://github.com/awslabs/git-secrets): 커밋 시 민감한 정보 검사
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/): Git 히스토리 정리
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage): 안전한 로컬 저장소

## 📚 참고 자료
- [Flutter Security Best Practices](https://flutter.dev/docs/development/data-and-backend/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Supabase Security](https://supabase.com/docs/guides/auth/security)