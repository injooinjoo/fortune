# Fix for 406 Not Acceptable Error in user_profiles Table

## Problem
When Flutter app tries to query the `user_profiles` table, it returns a 406 Not Acceptable error with "0 rows returned" message.

## Root Causes
1. **Missing user profile**: The user profile doesn't exist in the database
2. **RLS (Row Level Security) policies**: Restrictive policies preventing access
3. **PostgreSQL response format**: The 406 error often occurs when PostgreSQL cannot return data in the requested format

## Solution Implementation

### 1. Flutter Code Changes

#### Updated `auth_provider.dart`
- Added automatic profile creation when user signs in
- Implemented error handling for 406 errors
- Uses helper functions for safer database operations

#### Created `supabase_helper.dart`
- Centralized Supabase database operations
- Implements retry logic with RPC functions as fallback
- Handles profile creation and retrieval safely

#### Updated Social Auth Providers
- Added `ensureUserProfile()` call after successful authentication
- Ensures profile exists before redirecting to home screen

### 2. Database Changes

#### RLS Policies (`fix_user_profiles_rls.sql`)
```sql
-- Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Users can view own profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = user_id);
```

#### RPC Functions (`create_rpc_functions.sql`)
- `get_user_profile(user_id)`: Safely retrieves user profile
- `upsert_user_profile(...)`: Creates or updates user profile
- These functions use SECURITY DEFINER to bypass RLS when needed

#### Auto-creation Trigger
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, email, token_balance, created_at, updated_at)
  VALUES (NEW.id, NEW.email, 100, NOW(), NOW())
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## How to Apply the Fix

### Step 1: Update Flutter Code
The Flutter code has already been updated with the changes mentioned above.

### Step 2: Execute SQL Scripts in Supabase
1. Go to Supabase Dashboard → SQL Editor
2. Run `fix_user_profiles_rls.sql` to fix RLS policies
3. Run `create_rpc_functions.sql` to create helper functions

### Step 3: Test the Fix
1. Sign out from the app
2. Sign in again (with Google, Apple, or email/password)
3. The profile should be automatically created
4. No more 406 errors should occur

## Additional Notes

### Initial Token Balance
New users automatically receive 100 tokens as a welcome bonus.

### Profile Data Sources
- Email: From authentication provider
- Name: From OAuth provider metadata (if available)
- Profile Image: From OAuth provider (Google/Apple avatar)

### Error Handling
The implementation includes multiple fallback mechanisms:
1. Direct table query
2. RPC function fallback
3. Automatic profile creation if not exists

### Monitoring
Check logs for:
- "Creating new profile for user..."
- "406 Not Acceptable error..."
- "Failed to create user profile..."

These messages help diagnose any remaining issues.