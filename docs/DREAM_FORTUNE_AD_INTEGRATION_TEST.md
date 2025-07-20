# Dream Fortune Ad Integration Test Checklist

## Test Environment Setup
- [ ] User is logged in
- [ ] User is NOT premium (to see ads)
- [ ] User has sufficient souls for dream fortune

## Test Flow

### 1. Fortune List Navigation
- [ ] Navigate to Fortune List page
- [ ] Find "꿈 해몽" (Dream Fortune) in Traditional category
- [ ] Tap on the dream fortune card

### 2. Ad Loading Screen
- [ ] Verify AdLoadingScreen appears with dream-specific messages:
  - '🌙 꿈의 세계로 들어가고 있습니다...'
  - '✨ 무의식의 메시지를 해독하고 있습니다...'
  - '🔮 꿈속 상징들의 의미를 찾고 있습니다...'
  - '💫 심리학적 통찰을 준비하고 있습니다...'
  - '🌟 당신의 꿈이 전하는 메시지를 분석합니다...'
  - '🎭 꿈의 비밀이 곧 밝혀집니다...'
- [ ] Verify 5-second countdown timer appears
- [ ] Verify premium upgrade button is shown
- [ ] After 5 seconds, verify "운세 확인하기" button appears

### 3. Dream Fortune Page
- [ ] Click "운세 확인하기" button
- [ ] Verify navigation to Dream Fortune page
- [ ] Verify auto-generation flag is passed (fortune should start generating automatically)
- [ ] Enter dream content (text or voice)
- [ ] Submit dream for interpretation
- [ ] Verify soul consumption animation
- [ ] Verify dream analysis results appear

### 4. Premium User Flow
- [ ] Login as premium user
- [ ] Navigate to dream fortune
- [ ] Verify NO ad screen appears
- [ ] Verify direct navigation to dream fortune page
- [ ] Verify no soul consumption for premium users

### 5. Interactive Dream Interpretation Page
- [ ] Navigate to Interactive section
- [ ] Find "Dream Interpretation" page
- [ ] Verify this page works independently (doesn't show ads)
- [ ] Verify soul consumption works correctly

## Error Cases
- [ ] Test with insufficient souls
- [ ] Test network error during ad loading
- [ ] Test closing ad screen before completion

## Success Criteria
✅ Ad screen shows for non-premium users
✅ Dream-specific loading messages appear
✅ Navigation flows correctly after ad
✅ Fortune auto-generates after ad completion
✅ Soul system works correctly
✅ Premium users skip ads entirely