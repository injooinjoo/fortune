# Profile Page Update Guide

## Overview
This document describes the recent updates made to the profile page and related features in the Fortune Flutter app.

## Updated Features

### 1. Profile Screen (`/lib/screens/profile/profile_screen.dart`)

#### Design Changes
- **Removed AppHeader**: Replaced with a custom header that includes a back button for better navigation
- **Enhanced Profile Image**: 
  - Displays social profile images from linked accounts (Google, Apple, Naver, Kakao)
  - Added shadow effect and premium badge for subscribers
  - Larger size (100x100) with circular border

#### New User Statistics Section
- **누적 운세 (Total Fortunes)**: Shows total number of fortunes viewed
- **연속 접속 (Consecutive Days)**: Displays login streak
- **보유 토큰 (Token Balance)**: Current token balance
- Statistics are stored in both Supabase (`user_statistics` table) and local storage

#### User Information Display
- Birth date, MBTI, zodiac signs (both Western and Chinese)
- Information chips with icons for better visual representation
- Automatic calculation of zodiac signs based on birth date

#### Achievement System (부적 시스템)
- New button for accessing achievements/badges
- Currently shows "준비 중" (In preparation) message
- Foundation laid for future achievement tracking

### 2. User Statistics Service (`/lib/services/user_statistics_service.dart`)

A new service for tracking user statistics and achievements:

```dart
// Key features:
- Track total fortunes viewed
- Monitor consecutive login days
- Count fortune types usage
- Track token usage (earned/spent)
- Achievement system with milestones
```

#### Achievement Types
- `fortuneCount`: Milestones for viewing fortunes (1, 10, 50, 100, 500, 1000)
- `consecutiveDays`: Login streak achievements (3, 7, 14, 30, 100, 365 days)
- `tokenUsage`: Token spending milestones
- `specialEvent`: Special event participation
- `social`: Social interaction achievements

### 3. Enhanced Notification Settings (`/lib/features/notification/presentation/pages/notification_settings_page.dart`)

#### New Features
1. **Notification Methods**
   - Push notifications (enabled)
   - SMS notifications (premium only)
   - Email notifications (future feature)

2. **Fortune-Specific Notifications**
   - Select specific fortune types to receive notifications
   - Options: Daily, Love, Career, Wealth, Health, Lucky

3. **Notification Schedule**
   - Morning notifications with customizable time
   - Evening notifications (future feature)
   - Time picker integration

4. **Frequency Settings**
   - Daily
   - 3 times a week (Mon/Wed/Fri)
   - Weekends only
   - Weekdays only

5. **Enhanced Categories**
   - Birthday fortune notifications
   - Token alerts
   - Event and promotion notifications

### 4. Storage Service Updates (`/lib/services/storage_service.dart`)

Added methods for user statistics persistence:

```dart
// New methods:
- getUserStatistics()
- saveUserStatistics(Map<String, dynamic> statistics)
- clearUserStatistics()
```

## Database Schema Requirements

### user_statistics table
```sql
CREATE TABLE user_statistics (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  total_fortunes INTEGER DEFAULT 0,
  consecutive_days INTEGER DEFAULT 0,
  last_login TIMESTAMP WITH TIME ZONE,
  favorite_fortune_type TEXT,
  fortune_type_count JSONB DEFAULT '{}',
  total_tokens_used INTEGER DEFAULT 0,
  total_tokens_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### user_achievements table
```sql
CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  achievement_id TEXT NOT NULL,
  achievement_data JSONB NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);
```

## Implementation Notes

### Statistics Tracking
1. Fortune count is incremented each time a user views a fortune
2. Consecutive days are calculated based on daily logins
3. Favorite fortune type is determined by the most viewed type
4. Local storage provides offline fallback

### Profile Image Priority
1. First checks for profile_image_url in user profile
2. Falls back to social auth profile images
3. Shows default gradient avatar if no image available

### Theme Support
- Full dark mode support with proper color adjustments
- Glassmorphism effects for modern UI
- Responsive design for various screen sizes

## Future Enhancements

1. **Achievement System Implementation**
   - Design achievement badges/icons
   - Create achievement detail pages
   - Add achievement notifications

2. **Advanced Statistics**
   - Fortune viewing patterns
   - Time-based analytics
   - Personalized insights

3. **Social Features**
   - Share achievements
   - Compare statistics with friends
   - Leaderboards

4. **Notification Enhancements**
   - SMS integration for premium users
   - Email notification system
   - More granular notification controls

## Testing Checklist

- [ ] Profile image loads correctly from social accounts
- [ ] Statistics update properly when viewing fortunes
- [ ] Consecutive days calculate correctly
- [ ] Notification settings save and persist
- [ ] Dark mode displays correctly
- [ ] Achievement button shows placeholder
- [ ] Back button navigation works
- [ ] Logout functionality works correctly

## Migration Guide

For existing users:
1. User statistics will start from 0
2. Profile images from social accounts will be automatically loaded
3. Notification settings will use defaults until configured
4. Achievement system will be retroactively calculated when implemented