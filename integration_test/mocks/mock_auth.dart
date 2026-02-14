// Mock Authentication Service for Integration Tests
// Auth Mock - 실제 인증 없이 로그인/로그아웃 플로우 테스트
//
// 사용법:
// ```dart
// final mockAuth = MockAuthService();
// await mockAuth.signInWithTestAccount();
// expect(mockAuth.isAuthenticated, isTrue);
// ```

import 'dart:async';

/// Mock 인증 상태
enum MockAuthStatus {
  /// 인증되지 않음
  unauthenticated,

  /// 인증됨
  authenticated,

  /// 인증 진행 중
  authenticating,

  /// 세션 만료됨
  sessionExpired,

  /// 에러
  error,
}

/// Mock 인증 결과
enum MockAuthResult {
  success,
  invalidCredentials,
  networkError,
  userNotFound,
  userDisabled,
  tooManyRequests,
  emailNotVerified,
  weakPassword,
  emailAlreadyInUse,
}

/// Mock 사용자 정보
class MockUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final bool isTestAccount;
  final bool isEmailVerified;
  final bool isPremium;

  MockUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    this.isTestAccount = false,
    this.isEmailVerified = true,
    this.isPremium = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        metadata = metadata ?? {};

  factory MockUser.testUser() => MockUser(
        id: 'test-user-001',
        email: 'test@zpzg.com',
        displayName: '테스트 사용자',
        isTestAccount: true,
        metadata: {
          'birthDate': '1990-01-01',
          'gender': 'male',
          'mbti': 'INTJ',
          'zodiac': 'capricorn',
        },
      );

  factory MockUser.premiumUser() => MockUser(
        id: 'premium-user-001',
        email: 'premium@zpzg.com',
        displayName: '프리미엄 사용자',
        isTestAccount: true,
        isPremium: true,
        metadata: {
          'birthDate': '1985-05-15',
          'gender': 'female',
          'mbti': 'ENFP',
          'zodiac': 'taurus',
          'subscription': 'premium_monthly',
        },
      );

  factory MockUser.newUser() => MockUser(
        id: 'new-user-001',
        email: 'new@zpzg.com',
        displayName: null,
        isTestAccount: true,
        metadata: {},
      );
}

/// Mock 세션 정보
class MockSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final MockUser user;

  MockSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory MockSession.forUser(MockUser user) => MockSession(
        accessToken:
            'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock-refresh-token-${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: user,
      );
}

/// Mock Authentication Service
class MockAuthService {
  // Singleton
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // 상태
  MockAuthStatus _status = MockAuthStatus.unauthenticated;
  MockUser? _currentUser;
  MockSession? _currentSession;
  MockAuthResult _nextResult = MockAuthResult.success;

  // 설정
  Duration _simulatedDelay = const Duration(milliseconds: 300);
  // 콜백
  void Function(MockAuthStatus)? onAuthStateChanged;
  void Function(MockUser?)? onUserChanged;

  // 스트림 컨트롤러
  final _authStateController = StreamController<MockAuthStatus>.broadcast();
  final _userController = StreamController<MockUser?>.broadcast();

  // Getters
  MockAuthStatus get status => _status;
  MockUser? get currentUser => _currentUser;
  MockSession? get currentSession => _currentSession;
  bool get isAuthenticated => _status == MockAuthStatus.authenticated;
  bool get isSessionExpired => _currentSession?.isExpired ?? true;

  // Streams
  Stream<MockAuthStatus> get authStateStream => _authStateController.stream;
  Stream<MockUser?> get userStream => _userController.stream;

  // 설정 메서드

  /// 다음 인증 결과 설정
  void setNextAuthResult(MockAuthResult result) {
    _nextResult = result;
  }

  /// 시뮬레이션 딜레이 설정
  void setSimulatedDelay(Duration delay) {
    _simulatedDelay = delay;
  }

  /// 세션 만료 시뮬레이션
  void simulateSessionExpiry() {
    if (_currentSession != null) {
      _currentSession = MockSession(
        accessToken: _currentSession!.accessToken,
        refreshToken: _currentSession!.refreshToken,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        user: _currentSession!.user,
      );
      _updateStatus(MockAuthStatus.sessionExpired);
    }
  }

  /// 모든 상태 초기화
  void reset() {
    _status = MockAuthStatus.unauthenticated;
    _currentUser = null;
    _currentSession = null;
    _nextResult = MockAuthResult.success;
    _simulatedDelay = const Duration(milliseconds: 300);
    _updateStatus(MockAuthStatus.unauthenticated);
    _updateUser(null);
  }

  // 인증 메서드

  /// 테스트 계정으로 로그인
  Future<MockAuthResult> signInWithTestAccount() async {
    return signIn('test@zpzg.com', 'Test123!@#');
  }

  /// 프리미엄 테스트 계정으로 로그인
  Future<MockAuthResult> signInWithPremiumTestAccount() async {
    _updateStatus(MockAuthStatus.authenticating);
    await Future.delayed(_simulatedDelay);

    if (_nextResult != MockAuthResult.success) {
      final result = _nextResult;
      _nextResult = MockAuthResult.success;
      _updateStatus(MockAuthStatus.error);
      return result;
    }

    final user = MockUser.premiumUser();
    _currentUser = user;
    _currentSession = MockSession.forUser(user);
    _updateStatus(MockAuthStatus.authenticated);
    _updateUser(user);

    return MockAuthResult.success;
  }

  /// 이메일/비밀번호로 로그인
  Future<MockAuthResult> signIn(String email, String password) async {
    _updateStatus(MockAuthStatus.authenticating);
    await Future.delayed(_simulatedDelay);

    if (_nextResult != MockAuthResult.success) {
      final result = _nextResult;
      _nextResult = MockAuthResult.success;
      _updateStatus(MockAuthStatus.error);
      return result;
    }

    // Mock 사용자 생성
    final user = MockUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      isTestAccount: email.contains('test'),
    );

    _currentUser = user;
    _currentSession = MockSession.forUser(user);
    _updateStatus(MockAuthStatus.authenticated);
    _updateUser(user);

    return MockAuthResult.success;
  }

  /// 소셜 로그인 (Mock)
  Future<MockAuthResult> signInWithSocial(String provider) async {
    _updateStatus(MockAuthStatus.authenticating);
    await Future.delayed(_simulatedDelay);

    if (_nextResult != MockAuthResult.success) {
      final result = _nextResult;
      _nextResult = MockAuthResult.success;
      _updateStatus(MockAuthStatus.error);
      return result;
    }

    final user = MockUser(
      id: 'social-user-${DateTime.now().millisecondsSinceEpoch}',
      email: '$provider.user@example.com',
      displayName: '$provider User',
      metadata: {'provider': provider},
    );

    _currentUser = user;
    _currentSession = MockSession.forUser(user);
    _updateStatus(MockAuthStatus.authenticated);
    _updateUser(user);

    return MockAuthResult.success;
  }

  /// 회원가입
  Future<MockAuthResult> signUp(String email, String password,
      {Map<String, dynamic>? metadata}) async {
    _updateStatus(MockAuthStatus.authenticating);
    await Future.delayed(_simulatedDelay);

    if (_nextResult != MockAuthResult.success) {
      final result = _nextResult;
      _nextResult = MockAuthResult.success;
      _updateStatus(MockAuthStatus.error);
      return result;
    }

    final user = MockUser(
      id: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      isEmailVerified: false,
      metadata: metadata ?? {},
    );

    _currentUser = user;
    _currentSession = MockSession.forUser(user);
    _updateStatus(MockAuthStatus.authenticated);
    _updateUser(user);

    return MockAuthResult.success;
  }

  /// 로그아웃
  Future<void> signOut() async {
    await Future.delayed(_simulatedDelay);

    _currentUser = null;
    _currentSession = null;
    _updateStatus(MockAuthStatus.unauthenticated);
    _updateUser(null);
  }

  /// 세션 갱신
  Future<bool> refreshSession() async {
    if (_currentSession == null) return false;

    await Future.delayed(const Duration(milliseconds: 100));

    _currentSession = MockSession.forUser(_currentUser!);
    return true;
  }

  /// 프로필 업데이트
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUser == null) return false;

    await Future.delayed(_simulatedDelay);

    _currentUser = MockUser(
      id: _currentUser!.id,
      email: _currentUser!.email,
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      createdAt: _currentUser!.createdAt,
      metadata: {..._currentUser!.metadata, ...?metadata},
      isTestAccount: _currentUser!.isTestAccount,
      isEmailVerified: _currentUser!.isEmailVerified,
      isPremium: _currentUser!.isPremium,
    );

    _updateUser(_currentUser);
    return true;
  }

  /// 비밀번호 재설정 요청
  Future<MockAuthResult> sendPasswordResetEmail(String email) async {
    await Future.delayed(_simulatedDelay);

    if (_nextResult != MockAuthResult.success) {
      final result = _nextResult;
      _nextResult = MockAuthResult.success;
      return result;
    }

    return MockAuthResult.success;
  }

  /// 이메일 인증 전송
  Future<MockAuthResult> sendEmailVerification() async {
    if (_currentUser == null) return MockAuthResult.userNotFound;

    await Future.delayed(_simulatedDelay);
    return MockAuthResult.success;
  }

  /// 계정 삭제
  Future<MockAuthResult> deleteAccount() async {
    if (_currentUser == null) return MockAuthResult.userNotFound;

    await Future.delayed(_simulatedDelay);

    _currentUser = null;
    _currentSession = null;
    _updateStatus(MockAuthStatus.unauthenticated);
    _updateUser(null);

    return MockAuthResult.success;
  }

  // Helper methods

  void _updateStatus(MockAuthStatus status) {
    _status = status;
    onAuthStateChanged?.call(status);
    _authStateController.add(status);
  }

  void _updateUser(MockUser? user) {
    onUserChanged?.call(user);
    _userController.add(user);
  }

  /// 리소스 정리
  void dispose() {
    _authStateController.close();
    _userController.close();
  }
}
