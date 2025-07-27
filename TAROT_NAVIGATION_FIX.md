# Tarot Navigation Animation Fix

## Problem
When users navigate to the tarot card page and press the back button to return to the fortune list page, the navigation bar wasn't animating properly (sliding up from bottom).

## Solution
Added explicit navigation visibility handling to ensure proper animation timing.

## Changes Made

### 1. Verified Navigation Method
- Confirmed that fortune_list_page.dart already uses `context.push('/fortune/tarot')` instead of `context.go()`
- This ensures proper navigation stack behavior

### 2. TarotChatPage Updates
- Added import for navigation_visibility_provider
- Added explicit `hide()` call in initState to ensure navigation is hidden when tarot page loads
- This ensures proper state for animation when returning

## How It Works

1. **Navigation to Tarot Page**:
   - User taps tarot card in fortune list
   - Navigation uses `push()` to add route to stack
   - TarotChatPage hides navigation bar on load

2. **Returning to Fortune List**:
   - User presses back button
   - Navigation pops from stack
   - MainShell detects route change to `/fortune`
   - Navigation visibility provider triggers `show()`
   - Navigation bar slides up with 300ms animation

## Key Points
- The existing navigation infrastructure already supports the animation
- The fix ensures proper timing and state management
- No changes to the animation logic were needed
- The navigation bar will consistently slide up when returning to fortune list