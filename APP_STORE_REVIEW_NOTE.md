# App Store Review Note - ZPZG

## Re: Guideline 2.1 - In-App Purchase Issue (Fixed)

We have fixed the in-app purchase receipt validation issue.

### What was wrong:
- Server was not properly validating Apple receipts with Apple's verifyReceipt API

### What we fixed:
- Implemented proper Apple receipt validation following Apple's recommended approach:
  1. **Production-first validation**: Receipts are now validated against `https://buy.itunes.apple.com/verifyReceipt` first
  2. **Sandbox fallback**: If status code 21007 is returned, the receipt is automatically re-validated against `https://sandbox.itunes.apple.com/verifyReceipt`
  3. **Proper error handling**: All Apple status codes are now properly handled

### Technical Details:
- Updated Edge Function: `payment-verify-purchase` (v18)
- Follows Apple's documentation: "Validating Receipts with the App Store"

---

## Re: Guideline 4.3(b) - Spam / Design Differentiation

We understand your concern about app differentiation. Here's what makes "ZPZG" (Know Yourself) unique:

### Core Differentiator: Scientific Approach to Physiognomy

Our app's name "ZPZG" (Know Yourself) reflects our unique approach - treating traditional Korean physiognomy (관상학) as an accumulated wisdom system rather than mere superstition.

### Unique Features:

1. **Face Reading (관상) - Core Feature**
   - Camera-based face analysis using traditional Korean physiognomy principles
   - Analysis of facial features: forehead (지혜), eyes (성격), nose (재물운), lips (애정운), ears (수명)
   - Based on classical Korean physiognomy texts and interpretations

2. **Traditional Korean Fortune Systems**
   - **Tojeong Bigyeol (토정비결)**: Ancient Korean fortune-telling system with authentic algorithms
   - **Saju (사주)**: Traditional Four Pillars of Destiny analysis
   - **24 Solar Terms (24절기)**: Season-based fortune guidance

3. **Soul/Token Economy System**
   - Unique gamification: Users earn "souls" (영혼) by viewing free fortunes
   - Premium readings require spending souls
   - Creates engagement beyond simple fortune reading

4. **Comprehensive Fortune Categories (50+)**
   - Dream interpretation, career, love, health, moving dates, and more
   - Each category provides personalized guidance

5. **Interactive Features**
   - Tarot card drawing with traditional card meanings
   - Worry bead meditation (염주 명상) with haptic feedback
   - Talisman (부적) generation

### Target Audience:
- Korean users interested in traditional physiognomy and fortune-telling
- Users seeking personalized life guidance based on traditional wisdom
- Those looking for cultural and spiritual exploration

Our app uniquely combines face reading (관상) as a scientific approach with traditional Korean fortune systems, creating a distinct experience not duplicated by other apps in the store.

---

## Testing Instructions:

1. **In-App Purchase Testing**:
   - Use Sandbox test account provided
   - All subscription and token purchase flows now work correctly
   - Receipt validation properly handles both production and sandbox environments

2. **App Features**:
   - Create account or login with Apple ID
   - Try "오늘의 운세" (Today's Fortune) - free feature
   - Try "사주" (Saju) - premium feature requiring tokens

Thank you for your review.
