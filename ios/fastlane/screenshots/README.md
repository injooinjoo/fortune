# iOS Screenshots Guide

이 디렉토리는 App Store용 스크린샷을 저장하는 곳입니다.

## 디렉토리 구조

```
screenshots/
├── ko/                    # 한국어 스크린샷
│   ├── iPhone 6.7/       # iPhone 14 Pro Max, 15 Pro Max
│   ├── iPhone 6.5/       # iPhone 11 Pro Max, 12/13/14 Plus
│   ├── iPhone 5.5/       # iPhone 8 Plus
│   └── iPad 12.9/        # iPad Pro 12.9"
└── en-US/                # 영어 스크린샷
    ├── iPhone 6.7/
    ├── iPhone 6.5/
    ├── iPhone 5.5/
    └── iPad 12.9/
```

## 스크린샷 요구사항

### iPhone 6.7" (필수)
- 크기: 1290 x 2796 픽셀
- 디바이스: iPhone 14 Pro Max, iPhone 15 Pro Max

### iPhone 6.5" (필수)
- 크기: 1242 x 2688 픽셀
- 디바이스: iPhone 11 Pro Max, iPhone 12/13/14 Plus

### iPhone 5.5" (선택)
- 크기: 1242 x 2208 픽셀
- 디바이스: iPhone 8 Plus

### iPad 12.9" (권장)
- 크기: 2048 x 2732 픽셀
- 디바이스: iPad Pro 12.9"

## 스크린샷 생성 방법

### 1. 수동으로 생성

```bash
# Simulator 실행
open -a Simulator

# 원하는 디바이스 선택 후 앱 실행
flutter run

# 스크린샷 캡처 (Cmd + S)
```

### 2. Fastlane으로 자동 생성

```bash
cd ios
fastlane screenshots
```

## 스크린샷 네이밍 규칙

- `01_main_screen.png` - 메인 화면
- `02_daily_fortune.png` - 오늘의 운세
- `03_fortune_categories.png` - 운세 카테고리
- `04_fortune_result.png` - 운세 결과
- `05_premium_features.png` - 프리미엄 기능
- `06_user_profile.png` - 사용자 프로필

## 스크린샷 최적화

1. **고화질 이미지 사용**
   - Retina 디스플레이 품질
   - PNG 형식 권장

2. **일관된 스타일**
   - 동일한 시간대 설정
   - 배터리 100% 표시
   - Wi-Fi 연결 상태

3. **콘텐츠 주의사항**
   - 실제 사용자 데이터 제거
   - 테스트 데이터 사용
   - 부적절한 콘텐츠 제거

## 프레임 추가 (선택)

[Fastlane Frameit](https://docs.fastlane.tools/actions/frameit/)을 사용하여 디바이스 프레임 추가:

```bash
fastlane frameit
```

## 검증

업로드 전 다음 사항 확인:
- [ ] 모든 필수 크기 준비
- [ ] 이미지 품질 확인
- [ ] 텍스트 가독성 확인
- [ ] 브랜드 일관성 유지
- [ ] 최신 앱 버전 반영