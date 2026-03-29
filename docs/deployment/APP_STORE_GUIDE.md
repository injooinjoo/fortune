# App Store & Google Play Launch Guide

Complete guide for launching the Ondo app on both iOS App Store and Google Play Store.

---

## Table of Contents

1. [Build Status](#build-status)
2. [App Store Connect Setup (iOS)](#app-store-connect-setup-ios)
3. [Google Play Console Setup (Android)](#google-play-console-setup-android)
4. [Store Content & Listing](#store-content--listing)
5. [Launch Checklist](#launch-checklist)
6. [Post-Launch Optimization](#post-launch-optimization)

---

## Build Status

### Android
- **File**: `build/app/outputs/bundle/release/app-release.aab` (123.0MB)
- **Status**: Build complete, ready for upload
- **Signing Key**: `android/app/fortune-release-key.jks`

### iOS
- **File**: `build/ios/ipa/*.ipa` (97.8MB)
- **Archive**: `build/ios/archive/Runner.xcarchive` (414.8MB)
- **Status**: Build complete, ready for upload
- **Team ID**: `5F7CN7Y54D`
- **Bundle ID**: `com.beyond.ondo`

---

## App Store Connect Setup (iOS)

### 1. Apple Developer Program Preparation

#### Prerequisites
1. **Apple Developer Program** account (Annual fee: $99)
2. **Built IPA file**: `build/ios/ipa/*.ipa` (97.8MB)
3. **Apple ID** and **Team ID**: `5F7CN7Y54D`
4. **Xcode Archive**: `build/ios/archive/Runner.xcarchive` (414.8MB)

#### Access App Store Connect
1. Visit https://appstoreconnect.apple.com
2. Sign in with Apple Developer account
3. Select "My Apps"

### 2. Create New App

#### Basic App Information
```yaml
Platform: iOS
Name: Ondo
Default Language: Korean
Bundle ID: com.beyond.ondo
SKU: fortune-ios-001
User Access: Limited (development team only)
```

#### App Information
```yaml
Category:
  Primary: Lifestyle
  Secondary: Entertainment (optional)

Content Rights:
  Third-party content: No

Age Rating:
  4+ (All ages)
```

### 3. Upload Build

#### Method 1: Apple Transporter (Recommended)
1. Download **Apple Transporter** app:
   - Search "Transporter" in Mac App Store
   - https://apps.apple.com/us/app/transporter/id1450874784

2. Upload IPA file:
   ```bash
   # Verify IPA file path
   ls -la build/ios/ipa/

   # In Transporter app:
   # 1. Click "+" button
   # 2. Select build/ios/ipa/fortune.ipa
   # 3. Click "Deliver" button
   ```

#### Method 2: Command Line Tool
```bash
# Using altool (API key required)
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/fortune.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

#### Method 3: Xcode Organizer
1. Open Xcode
2. Select **Window** > **Organizer**
3. Select Runner.xcarchive in **Archives** tab
4. Click **Distribute App**
5. Select **App Store Connect**
6. Choose **Upload** and proceed

#### Upload Processing Time
- Upload completion: 5-10 minutes
- Apple processing: 30 minutes - 2 hours
- Available in TestFlight after processing

### 4. Complete App Information

#### App Store Information
```yaml
Name: Ondo
Subtitle: AI-Powered Personalized Horoscope

Promotional Text: |
  Discover your personalized fortune with AI analysis every day!

Description: |
  🔮 Ondo - AI-Powered Personalized Horoscope Service

  Discover a new you every day with Ondo!

  ✨ Key Features

  🎯 Personalized Fortune Reading
  • Accurate analysis based on birth date, time, and location
  • AI-generated personalized fortune
  • Daily updated insights

  🌟 Comprehensive Fortune Services
  • Daily Fortune - Start your day with special messages
  • Love Fortune - Guidance for relationships
  • Career Fortune - Career and financial insights
  • Health Fortune - Wellness recommendations

  🧠 AI-Powered Analysis
  • Combines traditional astrology with modern AI
  • Deep personality analysis
  • Practical and realistic advice

  📱 Easy and Intuitive
  • User-friendly interface
  • Quick social login
  • Secure data protection

  🎨 Beautiful Design
  • Modern UI/UX
  • Dark mode support
  • Smooth animations

  Discover your potential with Ondo!

  📞 Customer Support
  • Email: support@zpzg.co.kr
  • Website: https://zpzg.co.kr

  ⚠️ Disclaimer
  For entertainment and reference only. Make important decisions carefully.

Keywords: |
  horoscope,astrology,fortune,AI,daily,love,career,health,personalized,tarot,zodiac,lifestyle
```

#### Screenshots Requirements

**Required Sizes:**

1. **iPhone 6.7"** (iPhone 14 Pro Max, 15 Pro Max)
   ```yaml
   Size: 1290x2796px (portrait), 2796x1290px (landscape)
   Count: Minimum 1, maximum 10
   Format: PNG or JPG
   ```

2. **iPhone 6.5"** (iPhone 11 Pro Max, XS Max)
   ```yaml
   Size: 1242x2688px (portrait), 2688x1242px (landscape)
   Count: Minimum 1, maximum 10
   Format: PNG or JPG
   ```

**Optional Sizes:**

3. **iPad Pro 12.9"** (3rd generation)
   ```yaml
   Size: 2048x2732px (portrait), 2732x2048px (landscape)
   Count: Maximum 10
   ```

**Recommended Screenshot Content:**
1. Landing page - First impression
2. Login screen - Social login options
3. Main dashboard - Fortune categories
4. Fortune generation - Information input
5. Fortune results - AI analysis
6. Profile settings - Personalization
7. Dark mode - Mode toggle example

### 5. Privacy Information

#### Privacy Policy
```yaml
Privacy Policy URL: https://zpzg.co.kr/privacy
Contact Information:
  Email: support@zpzg.co.kr
  Phone: +82-10-0000-0000 (optional)
```

#### Data Usage Description
```yaml
Data Types Collected:
  Contact Information:
    - Name
    - Email address

  User Content:
    - Birth date
    - Birth time and location

  Usage Data:
    - Fortune reading history
    - App usage patterns

  Diagnostics:
    - Crash data
    - Performance data

Data Usage Purpose:
  - Personalized fortune service
  - App improvement
  - Customer support
  - Service analytics

Third-party Sharing: None
Data Retention: Until user account deletion
```

### 6. TestFlight Beta Testing

#### Add Internal Testers
1. Navigate to **TestFlight** tab
2. Click "+" in **Internal Testers** section
3. Add development team email addresses:
   ```
   developer1@example.com
   developer2@example.com
   qa@example.com
   ```

#### Add External Testers (Optional)
1. Create new group in **External Testers** section
2. Fill out **Beta App Review** information:
   ```yaml
   Beta App Name: Ondo Beta
   Beta App Description: AI-powered fortune service beta test
   Feedback Email: beta@zpzg.co.kr

   Test Information:
   - Test fortune generation
   - Verify login/signup flow
   - UI/UX feedback
   - Bug reporting
   ```

#### Send Invitations to Testers
- TestFlight invitation emails sent automatically
- Testers install Ondo via TestFlight app
- Collect feedback and fix bugs

### 7. Submit for App Store Review

#### Version Information
```yaml
Version: 1.0.0
Copyright: © 2024 Ondo. All rights reserved.

What's New in This Version: |
  🎉 Official Ondo app launch!

  ✨ Key Features:
  • AI-powered personalized fortune service
  • Daily, love, career, and health fortunes
  • Easy social login (Google, Apple, Kakao, Naver)
  • Beautiful UI/UX design with dark mode

  💡 Continuous updates for better service.

  📞 Contact: support@zpzg.co.kr
```

#### App Review Information
```yaml
Contact Information:
  Name: [Developer Name]
  Phone: +82-10-0000-0000
  Email: developer@zpzg.co.kr

Demo Account (if needed):
  Username: demo@zpzg.co.kr
  Password: Demo123!

Review Notes: |
  Ondo is an AI-powered personalized horoscope service.

  Key Features:
  1. Personalized fortune based on birth information
  2. Social login support (Google, Apple, Kakao, Naver)
  3. Ad monetization (Google AdMob)

  Testing Notes:
  - Basic fortune available without signup
  - Detailed service available after login
  - Ads placed appropriately for user experience

  For entertainment/reference only. Not for major decisions.
```

#### App Category and Rating
```yaml
Primary Category: Lifestyle
Secondary Category: Entertainment

Age Rating: 4+ (All ages)
Rating Reason:
  - Educational or entertainment astrology content
  - No real gambling or cash prizes
  - No violent or sexual content
```

### 8. Review Process and Launch

#### Submit for Review
1. Verify all information on **Submit for Review** page
2. Click **Submit for Review** button
3. Confirm submission and wait for review

#### Monitor Review Status
```yaml
Review States:
  Submitted: Added to Apple review queue
  In Review: Apple reviewing app
  Approved: Approved for App Store release
  Rejected: Revision required

Average Review Time: 24-48 hours
```

#### Release Options
```yaml
Automatic Release: Publish immediately upon approval
Manual Release: Manually choose release time after approval
Phased Release: Gradual rollout at specific percentage
```

---

## Google Play Console Setup (Android)

### 1. Google Play Console Preparation

#### Prerequisites
1. **Google Play Developer Account** (One-time registration fee: $25)
2. **Built AAB file**: `build/app/outputs/bundle/release/app-release.aab` (123.0MB)
3. **App signing key**: `android/app/fortune-release-key.jks`

#### Access Google Play Console
1. Visit https://play.google.com/console
2. Sign in with Developer account
3. Click "Create app" button

### 2. Create New App

#### Basic App Information
```
App Name: Ondo
Default Language: Korean (South Korea)
App or Game: App
Free or Paid: Free
```

#### Declarations
- [ ] **Content Guidelines Compliance** check
- [ ] **US Export Law Compliance** check

### 3. Upload App Bundle

#### Internal Testing Setup (Recommended)
1. Navigate to **Internal Testing** tab
2. Click "Create new release"
3. **Upload App Bundle**:
   ```
   File Path: build/app/outputs/bundle/release/app-release.aab
   File Size: 123.0MB
   ```
4. **Version Name**: `1.0.0`
5. **Release Notes**:
   ```
   First version of Ondo app.

   Key Features:
   - AI-powered personalized fortune service
   - Daily, love, career, and health fortunes
   - Social login (Google, Apple, Kakao, Naver)
   - User profile and settings management
   - Dark mode support
   ```

#### App Signing Management
- **Use Google Play App Signing** (recommended)
- Google manages upload key certificate
- Automatic app signing

### 4. Complete Store Listing

#### Product Details
```yaml
App Name: Ondo
Short Description: AI-powered personalized horoscope - Daily insights for you!
Full Description: |
  🔮 Ondo - AI-Powered Personalized Horoscope Service

  Discover a new you every day with Ondo!

  ✨ Key Features

  🎯 Personalized Fortune Reading
  • Accurate analysis based on birth date, time, and location
  • AI-generated personalized fortune
  • Daily updated insights

  🌟 Comprehensive Fortune Services
  • Daily Fortune - Start your day with special messages
  • Love Fortune - Guidance for relationships
  • Career Fortune - Career and financial insights
  • Health Fortune - Wellness recommendations

  🧠 AI-Powered Analysis
  • Combines traditional astrology with modern AI
  • Deep personality analysis
  • Practical and realistic advice

  📱 Easy and Intuitive
  • User-friendly interface
  • Quick social login
  • Secure data protection

  Ondo helps you discover your potential every day!

  ⚠️ Disclaimer
  For entertainment and reference only. Make important decisions carefully.
```

#### Graphic Assets
1. **App Icon** (Required)
   - Size: 512x512px
   - Format: PNG (32-bit)
   - Max Size: 1MB

2. **Feature Graphic** (Required)
   - Size: 1024x500px
   - Format: JPG or PNG (24-bit)
   - Max Size: 15MB

3. **Phone Screenshots** (Required)
   - Minimum 2, maximum 8
   - Size: 16:9 (landscape) or 9:16 (portrait)
   - Recommended: 1080x1920px

4. **7-inch Tablet Screenshots** (Optional)
   - Size: 1200x1920px

5. **10-inch Tablet Screenshots** (Optional)
   - Size: 1536x2048px

#### Categorization
```yaml
App Category: Lifestyle
Tags: fortune, astrology, AI, personalized, lifestyle
Content Rating: Everyone (E)
```

#### Contact Details
```yaml
Website: https://zpzg.co.kr
Email: support@zpzg.co.kr
Phone: +82-10-0000-0000 (optional)
```

### 5. App Content Policy Compliance

#### Content Rating Setup
1. Navigate to **Content Rating** tab
2. Click **Start Questionnaire**
3. **Category**: Other (Fortune/Astrology)
4. **Target Age**: Everyone
5. **Content Characteristics**:
   - Violent content: None
   - Sexual content: None
   - Drugs/alcohol: None
   - Gambling: None

#### Data Security
1. Navigate to **Data Security** tab
2. **Data Collection**: Yes
3. **Collected Data**:
   ```yaml
   Personal Information:
     - Name
     - Email address
     - Birth date

   App Activity:
     - App interactions
     - Fortune reading history

   Device or Other IDs:
     - Device ID
   ```
4. **Data Security Practices**:
   - Encryption in transit: Yes
   - Encryption at rest: Yes
   - User data deletion: Yes

#### Target Regions and Devices
```yaml
Countries/Regions: South Korea, United States, Japan (future expansion)
Device Categories: Phone, Tablet
Android Version: API 23 (Android 6.0) or higher
```

### 6. Internal Testing

#### Add Testers
1. **Internal Testing** > **Testers** tab
2. **Create tester list**
3. Invite testers by email:
   ```
   Development team member emails...
   ```

#### Run Tests
1. Send Google Play Console link to testers
2. Testers download app from Play Store
3. Collect feedback and fix bugs

### 7. Production Release

#### Production Release Preparation
1. Navigate to **Production** tab
2. **Create new release**
3. Upload same AAB file
4. Write **Release Notes**:
   ```
   🎉 Official Ondo app launch!

   ✨ Key Features:
   • AI-powered personalized fortune
   • Daily, love, career, and health fortunes
   • Easy social login
   • Beautiful UI/UX design

   💡 Continuous updates for better service.

   📞 Contact: support@zpzg.co.kr
   ```

#### Pre-Launch Checklist
- [ ] **App bundle uploaded**
- [ ] **Store listing** all fields completed
- [ ] **Graphic assets** all uploaded
- [ ] **Content rating** setup complete
- [ ] **Data security** information entered
- [ ] **Privacy policy** URL verified
- [ ] **Internal testing** complete
- [ ] **Policy compliance** verified

### 8. Review and Launch

#### Submit and Review
1. Verify all items on **Review** page
2. Click **Release to Production** button
3. **Wait for Google review** (typically 2-24 hours)

#### Monitor Review Status
- **In Review**: Google reviewing policy compliance
- **Approved**: App published to Play Store
- **Rejected**: Revise per feedback and resubmit

#### Launch Complete
- App searchable in Play Store
- User downloads and reviews begin
- Real-time statistics and analytics available

---

## Store Content & Listing

### Korean Content (Primary)

#### App Name
```
온도
```

#### Subtitle
```
AI 기반 개인 맞춤형 운세
```

#### Short Description (80 characters max)
```
AI가 분석하는 나만의 운세 - 매일 새로운 인사이트를 만나보세요
```

#### Full Description
```
🔮 온도 - AI 기반 개인 맞춤형 운세 서비스

매일 새로운 나를 발견하는 특별한 경험, 온도와 함께 시작하세요!

✨ 주요 기능

🎯 개인 맞춤형 운세
• 생년월일, 시간, 장소를 기반으로 한 정확한 사주 분석
• AI가 분석하는 개인별 맞춤형 운세 제공
• 매일 업데이트되는 새로운 인사이트

🌟 다양한 운세 서비스
• 오늘의 운세 - 하루를 시작하는 특별한 메시지
• 연애운 - 사랑과 관계에 대한 조언
• 사업운 - 커리어와 재물에 대한 가이드
• 건강운 - 몸과 마음의 컨디션 체크

🧠 AI 기반 분석
• 최신 AI 기술로 전통 사주학과 현대적 해석을 결합
• 개인의 성향과 특성을 깊이 있게 분석
• 실용적이고 현실적인 조언 제공

📱 쉽고 간편한 사용
• 직관적인 인터페이스로 누구나 쉽게 사용
• 소셜 로그인으로 간편한 회원가입
• 개인정보 보호를 위한 안전한 데이터 관리

🎨 아름다운 디자인
• 세련되고 모던한 UI/UX
• 다크모드 지원으로 언제든 편안한 사용
• 부드러운 애니메이션과 직관적인 네비게이션

온도와 함께 매일 새로운 자신을 발견하고, 더 나은 선택을 위한 영감을 얻어보세요!

📞 고객지원
문의사항이나 건의사항이 있으시면 언제든 연락해 주세요.
• 이메일: support@zpzg.co.kr
• 웹사이트: https://zpzg.co.kr

⚠️ 주의사항
본 서비스는 참고용으로만 사용하시고, 중요한 결정은 신중히 하시기 바랍니다.
```

#### Keywords
```
운세, 사주, 타로, 점술, AI, 오늘의운세, 연애운, 사업운, 건강운,
개인맞춤, 무료운세, 사주팔자, 궁합, 이름풀이, 관상, 손금,
라이프스타일, 엔터테인먼트, 자기계발, 힐링
```

### English Content (International)

#### App Name
```
Ondo - AI Personalized Horoscope
```

#### Subtitle (30 characters max)
```
AI-Powered Daily Fortune Reading
```

#### Promotional Text (170 characters max)
```
Discover your personalized fortune with AI analysis! Traditional astrology meets modern technology for daily insights tailored just for you.
```

#### Description (4000 characters max)
```
🔮 Ondo - AI-Powered Personalized Horoscope Service

Discover a new you every day with Ondo's unique blend of traditional wisdom and cutting-edge AI technology!

✨ Key Features

🎯 Personalized Fortune Reading
• Accurate analysis based on your birth date, time, and location
• AI-generated personalized fortune readings
• Daily updated insights and guidance

🌟 Comprehensive Fortune Services
• Daily Fortune - Start your day with special messages
• Love Fortune - Guidance for relationships and romance
• Career Fortune - Insights for work and financial success
• Health Fortune - Wellness and lifestyle recommendations

🧠 AI-Powered Analysis
• Combines traditional astrology with modern AI technology
• Deep analysis of your personality and characteristics
• Practical and realistic advice for daily life

📱 Easy and Intuitive
• User-friendly interface for everyone
• Quick social login options
• Secure data protection and privacy

🎨 Beautiful Design
• Modern and elegant UI/UX
• Dark mode support for comfortable viewing
• Smooth animations and intuitive navigation

Discover your true potential and gain inspiration for better choices with Ondo!

📞 Customer Support
For any questions or suggestions, please contact us:
• Email: support@zpzg.co.kr
• Website: https://zpzg.co.kr

⚠️ Disclaimer
This service is for entertainment and reference purposes only. Please make important decisions carefully.
```

#### Keywords (100 characters max)
```
horoscope,astrology,fortune,AI,daily,love,career,health,personalized,tarot,zodiac,lifestyle,wellness
```

### Screenshot Content Recommendations

**For Both Platforms:**

1. **Landing Page** - App's first impression
2. **Login Screen** - Social login options
3. **Main Dashboard** - Fortune categories
4. **Fortune Generation** - Information input screen
5. **Fortune Results** - AI analysis display
6. **Profile Settings** - Personalization features
7. **Dark Mode** - Mode toggle example

**Tips:**
- Capture from actual device or simulator
- Set status bar time to 9:41 (Apple recommendation)
- Remove bezels/device frames, show pure screen only
- Use high-resolution, clear images

### Categories and Keywords

#### App Store (iOS)
- **Primary Category**: Lifestyle
- **Secondary Category**: Entertainment

#### Google Play (Android)
- **Category**: Lifestyle
- **Tags**: fortune, astrology, AI, personalized, lifestyle

### ASO (App Store Optimization) Keywords

```yaml
Primary Keywords:
  - horoscope
  - astrology
  - fortune telling
  - daily horoscope
  - personalized astrology

Secondary Keywords:
  - AI fortune
  - birth chart
  - zodiac signs
  - tarot reading
  - spiritual guidance

Long-tail Keywords:
  - personalized horoscope app
  - AI astrology reading
  - daily fortune prediction
  - birth chart analysis
  - zodiac compatibility
```

---

## Launch Checklist

### Pre-Launch (Both Platforms)

#### Assets Preparation
- [ ] **App Icon** 1024x1024px (iOS), 512x512px (Android)
- [ ] **Screenshots** for all required device sizes
- [ ] **Feature Graphic** 1024x500px (Android only)
- [ ] **Promotional images** (optional)

#### Legal and Policy
- [ ] **Privacy Policy URL** https://zpzg.co.kr/privacy
- [ ] **Terms of Service URL** https://zpzg.co.kr/terms
- [ ] **Support Email** support@zpzg.co.kr
- [ ] **Website URL** https://zpzg.co.kr

#### App Information
- [ ] **App description** written in primary language
- [ ] **Keywords** optimized for ASO
- [ ] **Category** selected
- [ ] **Age rating** determined
- [ ] **Content rating** questionnaire completed

#### Technical Requirements
- [ ] **Builds tested** on real devices
- [ ] **All features working** properly
- [ ] **No critical bugs** remaining
- [ ] **Performance optimized** (load times, memory usage)
- [ ] **Ads integration tested** (AdMob)
- [ ] **Analytics configured** (Firebase)

#### Beta Testing
- [ ] **Internal testing** completed
- [ ] **External testing** completed (optional)
- [ ] **Feedback collected** and addressed
- [ ] **Crash reports** reviewed and fixed

### iOS Specific

- [ ] **Apple Developer Program** enrollment complete
- [ ] **IPA file** built and ready
- [ ] **App Store Connect** app created
- [ ] **Build uploaded** via Transporter/Xcode
- [ ] **TestFlight** testing complete
- [ ] **App Review Information** filled
- [ ] **Demo account** provided (if needed)
- [ ] **Screenshots** for iPhone 6.7" and 6.5"
- [ ] **App privacy** questionnaire completed

### Android Specific

- [ ] **Google Play Developer** account created
- [ ] **AAB file** built and signed
- [ ] **Google Play Console** app created
- [ ] **Bundle uploaded** successfully
- [ ] **Internal testing** completed
- [ ] **Data security** information provided
- [ ] **Content rating** obtained
- [ ] **Target countries** selected
- [ ] **Screenshots** for phones (minimum 2)

### Post-Submission

- [ ] **Review status** monitored daily
- [ ] **Response ready** for potential rejection
- [ ] **Support channels** prepared (email, website)
- [ ] **Marketing materials** prepared
- [ ] **Social media** announcement ready
- [ ] **Analytics dashboard** set up
- [ ] **User feedback monitoring** system ready

---

## Post-Launch Optimization

### Performance Monitoring

#### App Store Connect Analytics (iOS)
```yaml
Key Metrics:
  - Downloads and installations
  - Revenue and proceeds
  - User ratings and reviews
  - App Store impressions
  - Product page views
  - App Store conversion rate
```

#### Google Play Console Analytics (Android)
```yaml
Key Metrics:
  - Installs and uninstalls
  - Active users (DAU, MAU)
  - User ratings and reviews
  - Crash rate and ANR rate
  - Store listing performance
```

#### Firebase Analytics (Both Platforms)
```yaml
User Behavior:
  - User engagement metrics
  - Session length and frequency
  - Screen flow analysis
  - User demographics
  - Conversion funnels
  - Custom event tracking
```

### ASO (App Store Optimization)

#### Optimization Elements
```yaml
App Name:
  - Include relevant keywords
  - Keep it memorable and brandable
  - Consider localization

Subtitle/Short Description:
  - Highlight key features
  - Include primary keywords
  - Emphasize unique value proposition

Keywords:
  - Research competitor keywords
  - Monitor keyword rankings
  - Update regularly based on performance

Description:
  - Clear and compelling
  - Highlight benefits, not just features
  - Include call-to-action

Screenshots:
  - Show core functionality
  - Add text overlays explaining features
  - Update seasonally or for major features

Ratings Management:
  - Respond to user reviews
  - Implement feedback actively
  - Prompt satisfied users to rate
```

### Update Strategy

#### Version Release Cycle
```yaml
Version 1.1.0 (2-4 weeks after launch):
  - Bug fixes from user feedback
  - Minor UI/UX improvements
  - Performance optimizations
  - Analytics improvements

Version 1.2.0 (6-8 weeks):
  - New fortune categories
  - Enhanced AI analysis
  - UI refinements
  - Requested features

Version 2.0.0 (3-4 months):
  - Community features
  - Social sharing
  - Premium subscriptions
  - Major UI overhaul
```

#### Phased Rollout Strategy
```yaml
Stage 1 (10%):
  - Release to small percentage
  - Monitor crash rates and reviews
  - Fix critical issues quickly

Stage 2 (50%):
  - Expand to half of users
  - Validate stability
  - Monitor performance metrics

Stage 3 (100%):
  - Full rollout
  - Continue monitoring
  - Prepare for next version
```

### User Engagement

#### Review Management
```yaml
Respond to Reviews:
  - Thank positive reviewers
  - Address negative feedback constructively
  - Explain fixes or planned improvements
  - Maintain professional tone

Encourage Reviews:
  - Prompt after positive experiences
  - After completing fortune reading
  - After 5+ app sessions
  - Never be pushy or annoying
```

#### Customer Support
```yaml
Support Channels:
  - Email: support@zpzg.co.kr
  - Website: https://zpzg.co.kr/support
  - FAQ: https://zpzg.co.kr/faq
  - In-app feedback form

Response Time:
  - Critical issues: Within 24 hours
  - General inquiries: Within 48 hours
  - Feature requests: Acknowledge receipt
  - Bug reports: Acknowledge and track
```

### Marketing and Growth

#### Launch Marketing
```yaml
Announcement Channels:
  - Social media (Twitter, Facebook, Instagram)
  - Blog post on website
  - Email to beta testers
  - Press release (optional)
  - Product Hunt launch (optional)

Initial Promotions:
  - Limited-time premium trial
  - Referral incentives
  - Social sharing rewards
  - Launch week special features
```

#### Growth Strategies
```yaml
Organic Growth:
  - ASO optimization
  - Quality user experience
  - Word-of-mouth referrals
  - Influencer outreach

Paid Acquisition:
  - Apple Search Ads
  - Google Ads (App campaigns)
  - Social media ads
  - Retargeting campaigns

Retention:
  - Daily fortune notifications
  - Personalized content
  - Gamification elements
  - Regular feature updates
```

### Monetization Optimization

#### Ad Revenue (Current)
```yaml
Google AdMob Integration:
  - Banner ads (non-intrusive placement)
  - Interstitial ads (between readings)
  - Rewarded ads (bonus features)

Optimization:
  - Test different ad placements
  - Monitor user retention vs. ad frequency
  - A/B test ad formats
  - Optimize eCPM
```

#### Future Monetization
```yaml
Premium Subscriptions:
  - Monthly: $4.99
  - Yearly: $39.99 (33% savings)
  - Lifetime: $99.99

Premium Features:
  - Ad-free experience
  - Unlimited fortune readings
  - Detailed birth chart analysis
  - Priority customer support
  - Exclusive themes
  - Advanced AI insights

In-App Purchases:
  - Single fortune reading credits
  - Special theme packs
  - Premium report downloads
```

### Continuous Improvement

#### Data-Driven Decisions
```yaml
Track Metrics:
  - User acquisition cost (UAC)
  - Lifetime value (LTV)
  - Retention rates (D1, D7, D30)
  - Conversion rates
  - Feature usage statistics

Analyze Patterns:
  - Which features are most used
  - Where users drop off
  - Peak usage times
  - Geographic performance
  - Device and OS distribution
```

#### Feature Roadmap
```yaml
Q1 2025:
  - Bug fixes and stability
  - UI/UX improvements
  - New fortune categories
  - Performance optimization

Q2 2025:
  - Social features
  - Community discussions
  - Premium subscriptions
  - Advanced AI features

Q3 2025:
  - Localization (Japanese, Chinese)
  - Integration with calendar
  - Widget support
  - Apple Watch/Wear OS app

Q4 2025:
  - Partnership features
  - Celebrity fortunes
  - Astrology courses
  - Marketplace for astrologers
```

### Compliance and Security

#### Regular Audits
```yaml
Privacy Compliance:
  - Review data collection practices
  - Update privacy policy as needed
  - Monitor GDPR/CCPA compliance
  - Regular security audits

Platform Policy:
  - Stay updated on store policies
  - Review content guidelines
  - Monitor advertising policies
  - Check API usage compliance
```

#### Security Updates
```yaml
Regular Tasks:
  - Update dependencies
  - Patch security vulnerabilities
  - Review third-party SDKs
  - Monitor crash reports
  - Test on new OS versions
  - Maintain API security
```

---

## Support Resources

### URLs
- **Website**: https://zpzg.co.kr
- **Support**: https://zpzg.co.kr/support
- **Privacy Policy**: https://zpzg.co.kr/privacy
- **Terms of Service**: https://zpzg.co.kr/terms
- **FAQ**: https://zpzg.co.kr/faq

### Contact Information
- **Support Email**: support@zpzg.co.kr
- **Developer Email**: developer@zpzg.co.kr
- **Beta Feedback**: beta@zpzg.co.kr

### Developer Accounts
- **Apple Developer**: https://developer.apple.com
- **App Store Connect**: https://appstoreconnect.apple.com
- **Google Play Console**: https://play.google.com/console
- **Firebase Console**: https://console.firebase.google.com

---

## Appendix

### Required Asset Sizes Reference

#### iOS
| Asset Type | Size | Format | Required |
|------------|------|--------|----------|
| App Icon | 1024x1024px | PNG | Yes |
| iPhone 6.7" Screenshot | 1290x2796px | PNG/JPG | Yes |
| iPhone 6.5" Screenshot | 1242x2688px | PNG/JPG | Yes |
| iPad Pro 12.9" Screenshot | 2048x2732px | PNG/JPG | Optional |

#### Android
| Asset Type | Size | Format | Required |
|------------|------|--------|----------|
| App Icon | 512x512px | PNG (32-bit) | Yes |
| Feature Graphic | 1024x500px | PNG/JPG | Yes |
| Phone Screenshot | 1080x1920px | PNG/JPG | Yes (min 2) |
| 7" Tablet Screenshot | 1200x1920px | PNG/JPG | Optional |
| 10" Tablet Screenshot | 1536x2048px | PNG/JPG | Optional |

### Useful Commands

#### iOS Build Commands
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build IPA
flutter build ipa --release

# View archive
open build/ios/archive/
```

#### Android Build Commands
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build AAB
flutter build appbundle --release

# View bundle
open build/app/outputs/bundle/release/
```

### Common Issues and Solutions

#### iOS
```yaml
Issue: Build failed with provisioning profile error
Solution:
  - Update provisioning profile in Xcode
  - Verify Team ID is correct
  - Check bundle identifier matches

Issue: Upload rejected due to ITMS-90xxx error
Solution:
  - Check Apple's specific error documentation
  - Verify Info.plist configurations
  - Update Xcode to latest version

Issue: TestFlight build not appearing
Solution:
  - Wait 30-60 minutes for processing
  - Check email for missing compliance info
  - Verify export options are correct
```

#### Android
```yaml
Issue: Upload failed validation
Solution:
  - Verify version code is higher than previous
  - Check signing configuration
  - Ensure all required permissions are declared

Issue: Content rating incomplete
Solution:
  - Complete questionnaire fully
  - Review all checkbox requirements
  - Submit for IARC certification

Issue: Data safety section not complete
Solution:
  - Declare all data collection practices
  - Specify data sharing policies
  - Add security measures information
```

---

**Last Updated**: 2024
**Version**: 1.0.0
**Author**: Ondo Development Team

For questions or updates to this guide, contact developer@zpzg.co.kr
