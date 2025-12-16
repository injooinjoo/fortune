# Fortune App - Product Requirements Document

## 1. Product Overview

**Product Name**: Fortune - AI 운세 서비스
**Platform**: Flutter (iOS, Android, Web)
**Target Users**: Korean-speaking users interested in fortune telling, saju, tarot, and personality analysis

## 2. Core User Flows

### 2.1 Authentication Flow
**Goal**: User can sign up and log in to access personalized fortune services

**Steps**:
1. User opens app and sees Landing page
2. User selects login method (Kakao, Naver, Google, Apple, or Email)
3. OAuth flow completes and redirects to callback
4. If new user, redirects to Onboarding
5. If existing user, redirects to Home

**Acceptance Criteria**:
- All OAuth providers work correctly
- Session persists after app restart
- Error messages shown for failed login attempts

### 2.2 Onboarding Flow
**Goal**: New user completes profile setup for personalized fortunes

**Steps**:
1. User enters name
2. User selects birth date (solar/lunar)
3. User selects birth time (optional)
4. User selects gender
5. User selects MBTI (optional)
6. Profile saved and redirected to Home

**Acceptance Criteria**:
- All fields validate correctly
- Profile saved to database
- Saju pillars calculated from birth info

### 2.3 Home Dashboard Flow
**Goal**: User views daily fortune summary and navigates to features

**Steps**:
1. Home screen loads with fortune cards
2. User swipes through 11 different card types
3. User can tap cards for details
4. Bottom navigation shows: Home, Fortune, Trend, Premium, Profile

**Acceptance Criteria**:
- All 11 card types render correctly
- Cards show personalized data based on user profile
- Navigation works between all main sections

### 2.4 Fortune List & Query Flow
**Goal**: User browses and selects fortune types to get readings

**Steps**:
1. User navigates to Fortune tab
2. User sees list of 30+ fortune categories
3. User selects a fortune type
4. User enters required inputs
5. Loading animation plays
6. Result page shows fortune reading
7. Premium content blurred for free users

**Acceptance Criteria**:
- All fortune types accessible
- Input forms validate correctly
- Results render within 15 seconds
- Blur/unlock works for premium content

### 2.5 Payment Flow
**Goal**: User purchases premium subscription or tokens

**Steps**:
1. User navigates to Premium tab
2. User sees subscription plans or token packages
3. User selects a purchase option
4. In-App Purchase flow initiates
5. Purchase verified and balance updated
6. Premium features unlocked

**Acceptance Criteria**:
- IAP products load correctly
- Purchase flow completes
- User balance/status updated immediately
- Receipt verified on server

### 2.6 Profile Management Flow
**Goal**: User views and edits their profile and history

**Steps**:
1. User navigates to Profile tab
2. User sees profile summary with saju info
3. User can edit profile information
4. User can view fortune history
5. User can access settings

**Acceptance Criteria**:
- Profile data displays correctly
- Edit saves to database
- History shows past fortune readings
- Settings changes persist

## 3. Key Features

### 3.1 Traditional Saju (사주)
- Four pillars calculation from birth date/time
- Yearly, monthly, daily fortune predictions
- Five elements balance analysis
- Lucky directions, colors, numbers

### 3.2 Tarot Reading
- Multiple deck selection
- Card spread options
- AI-generated interpretations
- Card detail modal with meanings

### 3.3 Compatibility Analysis
- Two-person saju comparison
- Overall compatibility score
- Category breakdowns (love, work, friendship)
- Advice and warnings

### 3.4 MBTI Fortune
- MBTI-based daily predictions
- Cognitive function analysis
- Compatible MBTI matches
- Lucky items and activities

### 3.5 Premium Features
- Blur/unlock system for detailed readings
- Token-based consumption model
- Ad-watch for free unlocks
- Subscription for unlimited access

## 4. Technical Requirements

### 4.1 Performance
- App launch < 3 seconds
- Fortune generation < 15 seconds
- Smooth 60fps animations
- Offline mode for basic features

### 4.2 Reliability
- 99% uptime for API services
- Graceful error handling
- Data persistence across sessions
- Crash recovery

### 4.3 Security
- Secure OAuth implementation
- API key protection
- User data encryption
- Payment security compliance

## 5. Test Scenarios

### Critical (P0)
1. User can complete OAuth login
2. User can complete onboarding
3. Home dashboard loads correctly
4. Fortune results display
5. Payment flow completes
6. Profile saves correctly

### High (P1)
1. All 30+ fortune types work
2. Card swipe interactions smooth
3. History records correctly
4. Settings persist
5. Offline mode works

### Medium (P2)
1. All animations play correctly
2. Dark mode works
3. Font scaling works
4. Deep links work
5. Share functionality works
