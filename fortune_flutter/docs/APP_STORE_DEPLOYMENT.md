# Fortune App - App Store Deployment Guide

이 문서는 Fortune 앱을 iOS App Store와 Google Play Store에 배포하기 위한 종합 가이드입니다.

## 목차

1. [사전 준비사항](#사전-준비사항)
2. [iOS App Store 배포](#ios-app-store-배포)
3. [Google Play Store 배포](#google-play-store-배포)
4. [스크린샷 가이드라인](#스크린샷-가이드라인)
5. [앱 설명 템플릿](#앱-설명-템플릿)
6. [체크리스트](#체크리스트)

## 사전 준비사항

### 필수 계정
- [ ] Apple Developer 계정 ($99/년)
- [ ] Google Play Developer 계정 ($25 일회성)
- [ ] 도메인 및 호스팅 (개인정보 처리방침, 서비스 약관용)

### 필수 정보
- [ ] 앱 이름 (한국어/영어)
- [ ] 앱 설명 (짧은 설명, 긴 설명)
- [ ] 키워드 (ASO 최적화)
- [ ] 개인정보 처리방침 URL
- [ ] 서비스 약관 URL
- [ ] 지원 이메일
- [ ] 지원 전화번호

### 법적 요구사항 (한국)
- [ ] 통신판매업 신고 (필요시)
- [ ] 정보통신망법 준수
- [ ] 개인정보보호법 준수
- [ ] 전자상거래법 준수 (인앱 결제 있을 경우)

## iOS App Store 배포

### 1. 인증서 및 프로비저닝 프로파일 설정

```bash
# Fastlane match 설정 (권장)
cd ios
fastlane match init

# 인증서 생성 및 동기화
fastlane match appstore
fastlane match development
```

### 2. App Store Connect 설정

1. [App Store Connect](https://appstoreconnect.apple.com)에 로그인
2. 새 앱 생성:
   - Bundle ID: `com.fortune.app`
   - 기본 언어: 한국어
   - 앱 이름: 포춘 - AI 운세

### 3. 앱 정보 입력

#### 일반 정보
- **카테고리**: 라이프스타일 (주), 엔터테인먼트 (부)
- **콘텐츠 등급**: 4+ (점술/운세 콘텐츠)
- **가격**: 무료 (인앱 구매 있음)

#### 앱 개인정보 처리방침
- 데이터 수집 항목 명시
- 데이터 사용 목적 설명
- 제3자 공유 여부

### 4. 빌드 및 업로드

```bash
# Flutter 빌드
flutter build ios --release

# Fastlane으로 업로드
cd ios
fastlane release
```

### 5. TestFlight 베타 테스트

```bash
# TestFlight에 업로드
cd ios
fastlane beta
```

## Google Play Store 배포

### 1. 서명 키 생성

```bash
# 키스토어 생성
keytool -genkey -v -keystore ~/fortune-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias fortune
```

### 2. key.properties 설정

```properties
storePassword=<비밀번호>
keyPassword=<비밀번호>
keyAlias=fortune
storeFile=/Users/username/fortune-release-key.jks
```

### 3. Google Play Console 설정

1. [Google Play Console](https://play.google.com/console)에 로그인
2. 새 앱 만들기:
   - 앱 이름: 포춘 - AI 운세
   - 기본 언어: 한국어
   - 앱 또는 게임: 앱
   - 무료 또는 유료: 무료

### 4. 스토어 등록정보

#### 앱 세부정보
- **앱 이름**: 포춘 - AI 운세
- **간단한 설명**: AI가 읽어주는 당신의 운세! 사주, 타로, 궁합까지
- **자세한 설명**: [full_description.txt 참조]

#### 그래픽 자산
- 앱 아이콘: 512x512 PNG
- 그래픽 이미지: 1024x500 PNG
- 스크린샷: 최소 2개, 최대 8개

### 5. 빌드 및 업로드

```bash
# Flutter 빌드 (AAB 권장)
flutter build appbundle --release

# Fastlane으로 업로드
cd android
fastlane deploy
```

### 6. 출시 전 보고서 검토

- 충돌 및 ANR 확인
- 보안 취약점 검토
- 성능 문제 확인

## 스크린샷 가이드라인

### iOS 스크린샷 요구사항

| 디바이스 | 크기 | 필수 여부 |
|---------|------|----------|
| iPhone 6.7" | 1290 x 2796 | 필수 |
| iPhone 6.5" | 1242 x 2688 | 필수 |
| iPhone 5.5" | 1242 x 2208 | 선택 |
| iPad 12.9" | 2048 x 2732 | 권장 |

### Android 스크린샷 요구사항

| 유형 | 크기 | 수량 |
|-----|------|-----|
| 휴대전화 | 1080 x 1920 ~ 3840 x 7680 | 2-8개 |
| 7인치 태블릿 | 1080 x 1920 이상 | 선택 |
| 10인치 태블릿 | 1080 x 1920 이상 | 선택 |

### 스크린샷 내용 권장사항

1. **메인 화면**: 앱의 첫인상
2. **오늘의 운세**: 핵심 기능
3. **운세 카테고리**: 다양성 표현
4. **운세 결과**: 상세 정보
5. **프리미엄 기능**: 수익 모델
6. **사용자 프로필**: 개인화

### 스크린샷 제작 도구

```bash
# iOS Simulator에서 스크린샷
xcrun simctl io booted screenshot screenshot.png

# Android Emulator에서 스크린샷
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Fastlane Screenshots (자동화)
cd ios && fastlane screenshots
cd android && fastlane screengrab
```

## 앱 설명 템플릿

### 앱 이름 최적화
- 주요 키워드 포함
- 30자 이내 (iOS)
- 브랜드명 + 기능 설명

예시:
- 한국어: "포춘 - AI 운세, 사주, 타로"
- 영어: "Fortune - AI Fortune Teller"

### 키워드 최적화 (ASO)

#### 한국어 키워드
```
운세,사주,타로,토정비결,오늘의운세,띠별운세,별자리,궁합,연애운,재물운,AI운세,점,운명,행운
```

#### 영어 키워드
```
fortune,astrology,tarot,horoscope,daily fortune,zodiac,compatibility,love,wealth,AI fortune,destiny,luck,divination
```

### 앱 설명 구조

1. **후크 (첫 문장)**
   - 앱의 핵심 가치 전달
   - 사용자의 관심 유도

2. **주요 기능**
   - 불릿 포인트 사용
   - 구체적인 기능 나열

3. **차별화 요소**
   - AI 기술 강조
   - 독특한 기능 설명

4. **사회적 증거**
   - 사용자 수 (있을 경우)
   - 평점 (있을 경우)

5. **콜투액션**
   - 앱 다운로드 유도
   - 긴급성 생성

## 체크리스트

### iOS 제출 전 체크리스트

- [ ] Xcode에서 Archive 생성 성공
- [ ] 앱 아이콘 모든 사이즈 준비
- [ ] Launch Screen 준비
- [ ] Info.plist 권한 설명 추가
- [ ] 앱 심사 정보 준비
- [ ] 테스트 계정 정보 제공
- [ ] 연령 등급 설문 완료
- [ ] 암호화 준수 문서 (필요시)

### Android 제출 전 체크리스트

- [ ] 서명된 AAB/APK 생성
- [ ] 64비트 지원 확인
- [ ] targetSdkVersion 최신 확인
- [ ] ProGuard 규칙 설정
- [ ] 권한 최소화
- [ ] 콘텐츠 등급 설문 완료
- [ ] 데이터 보안 설문 완료
- [ ] 광고 ID 선언 (있을 경우)

### 공통 체크리스트

- [ ] 개인정보 처리방침 URL 활성화
- [ ] 서비스 약관 URL 활성화
- [ ] 지원 이메일 응답 가능
- [ ] 모든 기능 정상 작동 확인
- [ ] 결제 시스템 테스트
- [ ] 오류 처리 확인
- [ ] 네트워크 오류 처리
- [ ] 다국어 지원 (선택)

## 심사 거절 대응

### 일반적인 거절 사유

1. **메타데이터 문제**
   - 스크린샷과 실제 앱 불일치
   - 부적절한 키워드 사용
   - 오해의 소지가 있는 설명

2. **기능 문제**
   - 충돌 또는 버그
   - 불완전한 기능
   - 네트워크 오류

3. **콘텐츠 문제**
   - 부적절한 콘텐츠
   - 저작권 침해
   - 사용자 생성 콘텐츠 관리 부재

4. **비즈니스 문제**
   - 불명확한 비즈니스 모델
   - 부적절한 결제 방식
   - 필수 기능의 유료화

### 재심사 요청 방법

1. 거절 사유 상세 분석
2. 문제 해결 및 수정
3. 상세한 설명과 함께 재제출
4. 필요시 전화 상담 요청

## 유지보수

### 정기 업데이트
- 최소 3개월마다 업데이트 권장
- OS 업데이트 대응
- 사용자 피드백 반영
- 버그 수정 및 성능 개선

### 모니터링
- 충돌 보고서 확인
- 사용자 리뷰 응답
- 다운로드 및 수익 추적
- 경쟁 앱 분석

## 마케팅 팁

### App Store Optimization (ASO)
1. 키워드 리서치 및 최적화
2. A/B 테스트 (Google Play)
3. 지역화 (다국어 지원)
4. 정기적인 업데이트

### 사용자 획득
1. 소셜 미디어 마케팅
2. 인플루언서 협업
3. 앱 리뷰 사이트 제출
4. 프레스 릴리스

### 사용자 유지
1. 푸시 알림 전략
2. 인앱 이벤트
3. 로열티 프로그램
4. 커뮤니티 구축

## 참고 자료

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policy](https://play.google.com/about/developer-content-policy/)
- [Flutter 배포 가이드](https://docs.flutter.dev/deployment)
- [Fastlane 문서](https://docs.fastlane.tools/)

---

이 가이드는 지속적으로 업데이트됩니다. 최신 정보는 공식 문서를 참조하세요.