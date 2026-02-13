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

## App Overview - Entertainment & Lifestyle Application

"ZPZG" (지피지기 - Know Yourself) is an **ENTERTAINMENT app** that provides AI-generated personalized lifestyle insights and guidance.

### App Category:
- Primary: LIFESTYLE
- Secondary: ENTERTAINMENT

### Core Features:

1. **Face AI (AI 관상) - Entertainment Feature**
   - Camera-based face analysis using AI for fun personality insights
   - Provides entertaining interpretations of facial features
   - For entertainment purposes only

2. **Daily Insights**
   - AI-generated personalized daily messages
   - Lifestyle tips and guidance
   - Motivation and inspiration content

3. **Personality Analysis**
   - MBTI-based personality assessments
   - Self-discovery and reflection tools
   - Entertainment-focused personality insights

4. **Interactive Features**
   - Insight Cards (similar to mood cards)
   - Dream journal and interpretation
   - Lifestyle guidance

### Token/Soul Economy System
- Users earn "souls" (영혼) through app engagement
- Premium content can be accessed using tokens
- Creates gamified engagement experience

### Target Audience:
- Users seeking daily entertainment and inspiration
- Those interested in personality and self-discovery content
- Users looking for personalized lifestyle guidance

### Important Disclaimers:
- All content is AI-generated for ENTERTAINMENT purposes only
- App clearly states content should not be used for important life decisions
- No claims of accuracy or predictive ability

---

## Testing Instructions:

1. **Account Login**:
   - Use the provided test account credentials
   - Social login (Apple ID, Google, Kakao) also available

2. **Feature Testing**:
   - Try "Face AI" feature for entertainment face analysis
   - Check "Daily Insights" for personalized content
   - Test premium features (test account has full access)

3. **In-App Purchase Testing**:
   - Use Sandbox test environment
   - All subscription and token purchase flows work correctly

Thank you for your review.
