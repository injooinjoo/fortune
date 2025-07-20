# 🔐 Google 인증 완전 가이드

> **최종 업데이트**: 2025년 7월 15일  
> **대상**: Flutter + Supabase Google OAuth

## 📋 개요

Fortune 앱의 Google 로그인 구현, 설정, 성능 최적화 및 문제 해결을 위한 완전한 가이드입니다.

---

## 🛠️ 초기 설정

### 1. Google Cloud Console 설정

#### OAuth 2.0 클라이언트 생성
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 프로젝트 선택 또는 생성
3. **API 및 서비스** → **사용자 인증 정보**
4. **사용자 인증 정보 만들기** → **OAuth 클라이언트 ID**

#### 클라이언트 ID 설정
```
애플리케이션 유형: 웹 애플리케이션
이름: Fortune App OAuth

승인된 JavaScript 원본:
- https://hayjukwfcsdmppairazc.supabase.co

승인된 리디렉션 URI:
- https://hayjukwfcsdmppairazc.supabase.co/auth/v1/callback
```

#### iOS 설정 (추가)
```
애플리케이션 유형: iOS
번들 ID: com.fortune.app
앱스토어 ID: (출시 후 입력)
```

#### Android 설정 (추가)
```
애플리케이션 유형: Android
패키지 이름: com.fortune.app
SHA-1 인증서 지문: (디버그/릴리즈 키 지문)
```

### 2. Supabase 설정

#### Auth Providers 활성화
1. Supabase 대시보드 → Authentication → Providers
2. Google 활성화
3. Client ID와 Client Secret 입력
4. **Skip nonce checks** 활성화 (중요!)

### 3. Flutter 프로젝트 설정

#### pubspec.yaml
```yaml
dependencies:
  google_sign_in: ^6.1.5
  supabase_flutter: ^2.0.0
  flutter_secure_storage: ^9.0.0
```

#### iOS 설정 (Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.fortune.app</string>
        </array>
    </dict>
</array>
```

#### Android 설정
`android/app/google-services.json` 파일 추가

---

## 💻 구현 코드

### 1. Google Sign-In 서비스
```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // iOS 클라이언트 ID 설정
    clientId: Platform.isIOS 
      ? 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com'
      : null,
  );
  
  final _supabase = Supabase.instance.client;
  
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // 1. Google 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google 로그인 취소됨');
      }
      
      // 2. 인증 토큰 획득
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      
      if (idToken == null) {
        throw Exception('Google ID 토큰을 가져올 수 없습니다');
      }
      
      // 3. Supabase 인증
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      // 4. 프로필 확인 및 생성
      await _ensureUserProfile(response.user);
      
      return response;
      
    } catch (error) {
      print('Google 로그인 에러: $error');
      rethrow;
    }
  }
  
  Future<void> _ensureUserProfile(User? user) async {
    if (user == null) return;
    
    // 프로필 확인
    final profile = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    
    // 프로필이 없으면 생성
    if (profile == null) {
      await _supabase.from('user_profiles').insert({
        'id': user.id,
        'email': user.email,
        'username': user.userMetadata?['name'] ?? user.email?.split('@')[0],
        'avatar_url': user.userMetadata?['avatar_url'],
        'provider': 'google',
        'tokens': 100, // 신규 가입 보너스
      });
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}
```

### 2. 성능 최적화된 구현

```dart
class OptimizedGoogleAuth {
  static final _instance = OptimizedGoogleAuth._internal();
  factory OptimizedGoogleAuth() => _instance;
  OptimizedGoogleAuth._internal();
  
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  // 캐시된 인증 상태
  User? _cachedUser;
  DateTime? _lastAuthCheck;
  
  // 성능 최적화: Silent Sign-In
  Future<bool> trySilentSignIn() async {
    try {
      // 캐시 확인 (5분 유효)
      if (_cachedUser != null && 
          _lastAuthCheck != null &&
          DateTime.now().difference(_lastAuthCheck!) < Duration(minutes: 5)) {
        return true;
      }
      
      // Google Silent Sign-In
      final account = await _googleSignIn.signInSilently();
      if (account == null) return false;
      
      // Supabase 세션 확인
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && !session.isExpired) {
        _cachedUser = session.user;
        _lastAuthCheck = DateTime.now();
        return true;
      }
      
      // 세션 갱신 필요
      return await _refreshSession(account);
      
    } catch (e) {
      print('Silent sign-in 실패: $e');
      return false;
    }
  }
  
  // 병렬 처리로 로그인 속도 개선
  Future<AuthResponse?> fastSignIn() async {
    try {
      // Google 로그인
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      // 병렬로 처리
      final results = await Future.wait([
        googleUser.authentication,
        _preloadUserData(),
        _warmUpSupabase(),
      ]);
      
      final googleAuth = results[0] as GoogleSignInAuthentication;
      
      // Supabase 인증
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      // 프로필 생성/업데이트 (백그라운드)
      unawaited(_updateProfile(response.user));
      
      return response;
      
    } catch (e) {
      print('Fast sign-in 에러: $e');
      rethrow;
    }
  }
  
  // 프리로딩 최적화
  Future<void> _preloadUserData() async {
    // 필요한 데이터 미리 로드
  }
  
  Future<void> _warmUpSupabase() async {
    // Supabase 연결 웜업
    await Supabase.instance.client.from('user_profiles').select().limit(0);
  }
}
```

### 3. UI 구현

```dart
class GoogleSignInButton extends StatefulWidget {
  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: _isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                height: 24,
                width: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Google로 계속하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
    );
  }
  
  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = GoogleAuthService();
      final response = await authService.signInWithGoogle();
      
      if (response?.user != null) {
        // 로그인 성공
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

---

## 🚀 성능 최적화

### 1. 초기 로딩 최적화
```dart
class AppStartup {
  static Future<void> initialize() async {
    // 병렬 초기화
    await Future.wait([
      Supabase.initialize(
        url: Config.supabaseUrl,
        anonKey: Config.supabaseAnonKey,
      ),
      GoogleSignIn().signInSilently(),
      _preloadAssets(),
    ]);
  }
  
  static Future<void> _preloadAssets() async {
    // Google 로고 등 미리 로드
    await precacheImage(
      AssetImage('assets/images/google_logo.png'),
      navigatorKey.currentContext!,
    );
  }
}
```

### 2. 토큰 캐싱
```dart
class TokenCache {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveTokens(GoogleSignInAuthentication auth) async {
    await Future.wait([
      _storage.write(key: 'google_id_token', value: auth.idToken),
      _storage.write(key: 'google_access_token', value: auth.accessToken),
      _storage.write(
        key: 'token_expiry',
        value: DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      ),
    ]);
  }
  
  static Future<Map<String, String?>?> getCachedTokens() async {
    final expiry = await _storage.read(key: 'token_expiry');
    if (expiry != null && DateTime.parse(expiry).isAfter(DateTime.now())) {
      return {
        'idToken': await _storage.read(key: 'google_id_token'),
        'accessToken': await _storage.read(key: 'google_access_token'),
      };
    }
    return null;
  }
}
```

### 3. 연결 풀링
```dart
class ConnectionPool {
  static final _supabase = Supabase.instance.client;
  static Timer? _keepAliveTimer;
  
  static void startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(Duration(minutes: 5), (_) {
      // 연결 유지
      _supabase.from('_health').select().limit(1).then((_) {
        print('Supabase 연결 유지됨');
      });
    });
  }
  
  static void stopKeepAlive() {
    _keepAliveTimer?.cancel();
  }
}
```

---

## 🐛 문제 해결

### 1. 일반적인 오류

#### PlatformException(sign_in_failed)
```dart
// 해결: Google Play 서비스 업데이트 확인
try {
  await GoogleSignIn().signIn();
} on PlatformException catch (e) {
  if (e.code == 'sign_in_failed') {
    // Google Play 서비스 업데이트 필요
    _showUpdateDialog();
  }
}
```

#### 10 (Developer Error)
- SHA-1 지문이 Google Console에 등록되지 않음
- 해결: 디버그/릴리즈 SHA-1 모두 등록

#### 403 Forbidden
- Supabase URL이 승인된 도메인에 없음
- 해결: Google Console에서 리디렉션 URI 추가

### 2. 프로필 생성 실패
```dart
// 재시도 로직
Future<void> ensureProfileWithRetry(User user, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final exists = await checkProfileExists(user.id);
      if (exists) return;
      
      await createProfile(user);
      return;
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: i + 1));
    }
  }
}
```

### 3. 세션 만료 처리
```dart
class SessionManager {
  static StreamSubscription? _authSubscription;
  
  static void startListening() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange
      .listen((data) {
        final event = data.event;
        
        switch (event) {
          case AuthChangeEvent.tokenRefreshed:
            print('토큰 갱신됨');
            break;
          case AuthChangeEvent.signedOut:
            _handleSignOut();
            break;
          case AuthChangeEvent.userUpdated:
            _refreshUserData();
            break;
        }
      });
  }
}
```

---

## 📊 모니터링

### 성능 메트릭
```dart
class AuthMetrics {
  static void trackSignInTime() {
    final stopwatch = Stopwatch()..start();
    
    GoogleAuthService().signInWithGoogle().then((_) {
      stopwatch.stop();
      analytics.logEvent(
        name: 'google_sign_in_duration',
        parameters: {
          'duration_ms': stopwatch.elapsedMilliseconds,
        },
      );
    });
  }
  
  static void trackSignInError(String error) {
    analytics.logEvent(
      name: 'google_sign_in_error',
      parameters: {
        'error_type': error,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

### 성공률 추적
```dart
// 일일 로그인 성공률
// 평균 로그인 시간
// 에러 발생 빈도
// Silent Sign-In 성공률
```

---

## ✅ 체크리스트

### 개발 환경
- [ ] Google Cloud Console 프로젝트 생성
- [ ] OAuth 2.0 클라이언트 ID 생성 (웹, iOS, Android)
- [ ] SHA-1 지문 등록 (디버그, 릴리즈)
- [ ] Supabase Google Provider 활성화
- [ ] Skip nonce checks 활성화

### Flutter 설정
- [ ] google_sign_in 패키지 추가
- [ ] iOS: Info.plist URL Schemes 설정
- [ ] Android: google-services.json 추가
- [ ] 에러 핸들링 구현
- [ ] 로딩 상태 UI

### 프로덕션
- [ ] 릴리즈 SHA-1 등록
- [ ] 프로덕션 OAuth 클라이언트
- [ ] 에러 로깅 설정
- [ ] 성능 모니터링
- [ ] 세션 관리

---

## 🔗 유용한 링크

- [Google Sign-In Flutter 문서](https://pub.dev/packages/google_sign_in)
- [Supabase Auth 문서](https://supabase.com/docs/guides/auth)
- [Google Cloud Console](https://console.cloud.google.com)
- [SHA-1 생성 가이드](https://developers.google.com/android/guides/client-auth)

---

*이 가이드는 Fortune 앱의 Google 인증 구현을 위한 완전한 가이드입니다.*