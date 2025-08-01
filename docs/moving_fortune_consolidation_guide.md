# Moving Fortune Consolidation Guide

## Overview
This document outlines the consolidation of two separate moving fortune features into a single unified solution with progressive enhancement.

## Previous State
- **Basic Moving Fortune** (`/fortune/moving`)
  - Simple form inputs
  - 3 token cost
  - Basic directional recommendations

- **Enhanced Moving Fortune** (`/fortune/moving-enhanced`)
  - Advanced 3-tab interface
  - 30 token cost
  - Map selection, auspicious days, area analysis

## New Unified Solution

### Backend Changes
1. **New Edge Function**: `fortune-moving-unified`
   - Location: `/supabase/functions/fortune-moving-unified/index.ts`
   - Dynamic token pricing:
     - Base: 3 tokens
     - +Map selection: 5 tokens
     - +Auspicious days: 7 tokens
     - +Area analysis: 15 tokens
   - Total range: 3-30 tokens

### Frontend Changes
1. **Unified Page**: `MovingFortuneUnifiedPage`
   - Location: `/lib/features/fortune/presentation/pages/moving_fortune_unified_page.dart`
   - Progressive disclosure UI
   - Real-time token cost display
   - Enhanced features in expandable section

2. **Routes Updated**:
   - `/fortune/moving` → Unified page
   - `/fortune/moving-enhanced` → Redirects to `/fortune/moving`
   - `/fortune/moving-unified` → Also points to unified page

3. **Fortune List**:
   - Single entry: "이사 운세"
   - Shows token range: "3-30 토큰"

### Migration Steps

#### Phase 1: Deploy Backend (Day 1)
1. Deploy `fortune-moving-unified` edge function
2. Update types.ts with new endpoint
3. Test all feature combinations

#### Phase 2: Update Frontend (Day 2-3)
1. Deploy unified page
2. Update routes with redirects
3. Update fortune list to single entry
4. Monitor usage patterns

#### Phase 3: Monitor & Adjust (Week 1)
1. Track feature usage:
   - Basic only: X%
   - +Map: Y%
   - +Auspicious: Z%
   - Full features: W%
2. Adjust UI based on usage
3. Gather user feedback

#### Phase 4: Deprecate Old Endpoints (Day 30)
1. Remove old edge functions
2. Clean up old page components
3. Update documentation

### User Communication

#### In-App Announcement
```
🎉 이사 운세가 더 똑똑해졌습니다!

이제 필요한 기능만 선택해서 사용하세요:
• 기본 운세 (3토큰)
• 지도 선택 추가 (+5토큰)
• 손없는날 계산 (+7토큰)  
• 지역 상세 분석 (+15토큰)

더 적은 토큰으로 원하는 정보만 받아보세요!
```

#### Push Notification
```
이사 운세 업데이트! 이제 3토큰부터 시작해요 🏠
```

### Testing Checklist

#### Basic Features (3 tokens)
- [ ] Name, birthdate, address input
- [ ] Basic fortune generation
- [ ] Result display

#### Map Selection (+5 tokens)
- [ ] Map picker loads
- [ ] Coordinates saved correctly
- [ ] Direction calculation works

#### Auspicious Days (+7 tokens)
- [ ] Calendar shows lucky days
- [ ] Lunar date calculation
- [ ] Date picker integration

#### Area Analysis (+15 tokens)
- [ ] All 5 metrics display
- [ ] Urgency level affects results
- [ ] Detailed recommendations

#### Combined Features
- [ ] All features together (30 tokens)
- [ ] Partial combinations work
- [ ] Token cost updates correctly

### Rollback Plan
If issues arise:
1. Revert route changes
2. Keep both pages active
3. Monitor and fix issues
4. Re-attempt migration

### Success Metrics
- User engagement maintained or increased
- Average token usage optimized
- Support tickets reduced
- Feature discovery improved

## Code Examples

### Calculating Token Cost
```dart
int _calculateTokenCost() {
  int cost = 3; // Base cost
  
  if (_useMapSelection && (_currentLocation != null || _targetLocation != null)) {
    cost += 5;
  }
  
  if (_useAuspiciousDays) {
    cost += 7;
  }
  
  if (_requestAreaAnalysis) {
    cost += 15;
  }
  
  return cost;
}
```

### Progressive UI Example
```dart
GlassContainer(
  child: InkWell(
    onTap: () {
      setState(() {
        _showEnhancedOptions = !_showEnhancedOptions;
      });
    },
    child: Row(
      children: [
        Text('고급 옵션'),
        Text('+${tokenCost - 3} 토큰'),
      ],
    ),
  ),
)
```

## Notes
- Old endpoints remain active for 30 days
- All existing features preserved
- No data migration needed
- Backward compatible