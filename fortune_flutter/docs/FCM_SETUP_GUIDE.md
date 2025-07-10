# 🔔 FCM 푸시 알림 설정 가이드

## 📋 개요

Fortune Flutter 앱은 Firebase Cloud Messaging(FCM)을 사용하여 푸시 알림을 전송합니다.

## 🔥 Firebase 프로젝트 설정

### 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com) 접속
2. "프로젝트 만들기" 클릭
3. 프로젝트 이름: `fortune-app` 입력
4. Google Analytics 활성화 (선택)

### 2. 앱 등록

#### Android 앱 등록
1. Firebase Console → 프로젝트 설정 → 앱 추가 → Android
2. Android 패키지 이름: `com.fortune.fortune_flutter`
3. 앱 닉네임: `Fortune Android`
4. `google-services.json` 다운로드
5. `android/app/` 폴더에 저장

#### iOS 앱 등록
1. Firebase Console → 프로젝트 설정 → 앱 추가 → iOS
2. iOS 번들 ID: `com.fortune.fortuneFlutter`
3. 앱 닉네임: `Fortune iOS`
4. `GoogleService-Info.plist` 다운로드
5. Xcode로 `ios/Runner/` 폴더에 추가

### 3. FlutterFire CLI 설정

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 옵션 생성
cd fortune_flutter
flutterfire configure
```

## 🤖 Android 설정

### 1. `android/build.gradle` 수정

```gradle
buildscript {
    dependencies {
        // 기존 dependencies...
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 2. `android/app/build.gradle` 수정

```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services' // 추가

android {
    defaultConfig {
        minSdkVersion 21 // FCM 최소 요구사항
    }
}
```

### 3. `android/app/src/main/AndroidManifest.xml` 수정

```xml
<manifest>
    <!-- 인터넷 권한 (이미 있을 수 있음) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        <!-- FCM 기본 알림 아이콘 설정 -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
        
        <!-- FCM 기본 알림 색상 설정 -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/colorAccent" />
        
        <!-- FCM 기본 알림 채널 설정 -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="daily_fortune" />
    </application>
</manifest>
```

## 🍎 iOS 설정

### 1. Xcode에서 Push Notifications 활성화

1. Xcode에서 프로젝트 열기
2. **Runner** 타겟 선택
3. **Signing & Capabilities** 탭
4. **+ Capability** → **Push Notifications** 추가
5. **+ Capability** → **Background Modes** 추가
   - ✅ Remote notifications
   - ✅ Background fetch

### 2. `ios/Runner/Info.plist` 수정

```xml
<dict>
    <!-- 기존 설정들... -->
    
    <!-- 백그라운드 모드 -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
    
    <!-- iOS 13+ 알림 권한 설명 -->
    <key>NSUserNotificationUsageDescription</key>
    <string>운세 알림을 받기 위해 알림 권한이 필요합니다.</string>
</dict>
```

### 3. APNs 인증서 설정

#### 방법 1: APNs 인증 키 (권장)
1. [Apple Developer](https://developer.apple.com) → Certificates, IDs & Profiles
2. Keys → + 버튼
3. Key Name: `Fortune Push Key`
4. ✅ Apple Push Notifications service (APNs) 체크
5. Continue → Register → Download
6. Firebase Console → 프로젝트 설정 → 클라우드 메시징 → iOS 앱 구성
7. APNs 인증 키 업로드

#### 방법 2: APNs 인증서
1. Keychain Access에서 인증서 요청 생성
2. Apple Developer에서 Push 인증서 생성
3. .p12 파일로 내보내기
4. Firebase Console에 업로드

### 4. `ios/Runner/AppDelegate.swift` 수정

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    
    // FCM 설정
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // APNs 토큰 처리
  override func application(_ application: UIApplication,
                          didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}

// FCM 델리게이트
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM Token: \(fcmToken ?? "")")
  }
}
```

## 🧪 테스트

### 1. FCM 토큰 확인

```dart
// 앱 실행 시 콘솔에서 확인
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

### 2. Firebase Console에서 테스트

1. Firebase Console → Cloud Messaging
2. "첫 번째 캠페인 만들기" → "Firebase 알림 메시지"
3. 알림 제목과 텍스트 입력
4. 대상: 단일 기기 → FCM 토큰 입력
5. 지금 보내기

### 3. 로컬 테스트

앱 내 설정 페이지에서 "테스트 알림 보내기" 버튼 클릭

## 📊 알림 유형

### 1. 일일 운세 알림
- 채널: `daily_fortune`
- 기본 시간: 매일 오전 7시
- 메시지: "오늘의 운세가 도착했습니다 🔮"

### 2. 토큰 부족 알림
- 채널: `token_alert`
- 트리거: 토큰 5개 이하
- 메시지: "토큰이 부족합니다. 충전하시겠습니까?"

### 3. 프로모션 알림
- 채널: `promotion`
- 토픽: `promotions`
- 예시: "50% 할인 이벤트! 오늘만 특가"

### 4. 시스템 알림
- 채널: `system`
- 중요 공지사항

## 🔧 문제 해결

### "알림이 오지 않아요"

1. **권한 확인**
   - 설정 → 앱 → Fortune → 알림 권한 확인
   - iOS: 설정 → 알림 → Fortune

2. **FCM 토큰 확인**
   - 앱 재설치 후 새 토큰 생성 확인
   - 서버에 토큰이 저장되었는지 확인

3. **네트워크 확인**
   - Wi-Fi/데이터 연결 확인
   - Firebase 서비스 상태 확인

### "iOS에서 백그라운드 알림이 안 와요"

1. Background Modes 활성화 확인
2. APNs 인증서/키 만료 확인
3. 콘텐츠 사용 가능(content-available) 플래그 확인

### "Android에서 알림 아이콘이 흰색으로 나와요"

Android 5.0+ 에서는 알림 아이콘이 단색이어야 합니다.
`android/app/src/main/res/drawable/ic_notification.png` 생성 필요

## 📚 참고 자료

- [FCM 공식 문서](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire 문서](https://firebase.flutter.dev/docs/messaging/overview)
- [iOS APNs 가이드](https://developer.apple.com/documentation/usernotifications)