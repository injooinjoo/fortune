# Social Provider Icons

This directory should contain the following social provider icon images:

- `google.png` - Google logo icon
- `apple.png` - Apple logo icon
- `kakao.png` - Kakao logo icon
- `naver.png` - Naver logo icon

## Icon Requirements

- Format: PNG with transparent background
- Size: 48x48 pixels or larger (will be scaled down)
- Style: Official brand logos

## Download Links

You can download official brand assets from:

- Google: https://developers.google.com/identity/branding-guidelines
- Apple: https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple
- Kakao: https://developers.kakao.com/docs/latest/ko/kakaologin/design-guide
- Naver: https://developers.naver.com/docs/login/bi/bi.md

## Flutter Asset Configuration

Make sure to add these icons to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/icons/google.png
    - assets/icons/apple.png
    - assets/icons/kakao.png
    - assets/icons/naver.png
```