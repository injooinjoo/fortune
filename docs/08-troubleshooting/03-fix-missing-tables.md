# Fix Missing Tables - Database Migration Guide

## Problem
The app is encountering errors because the following tables are missing from the production database:
1. `user_statistics` - Used to track user activity and achievements
2. Potential RLS issues with `user_saju` table causing save failures

## Solution

### 1. Apply Missing Migrations

Run the following command to apply all pending migrations to your Supabase database:

```bash
supabase db push
```

You'll need to enter your database password when prompted.

### 2. Manual Migration (if automatic push fails)

If the automatic migration fails, you can manually run the SQL in Supabase Dashboard:

1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Run the following migrations in order:

#### Create user_statistics table:
```sql
-- Run the contents of: supabase/migrations/20250114_create_user_statistics_table.sql
```

#### Verify user_saju table and RLS:
```sql
-- Check if user_saju table exists with proper RLS
SELECT * FROM pg_policies WHERE tablename = 'user_saju';
```

### 3. Verify Fixes

After applying migrations, verify:
1. The profile page loads without errors
2. Saju calculations save successfully
3. User statistics are tracked properly

## What Was Fixed in Code

1. **Edge Function (calculate-saju)**: Updated to use `upsert` instead of `insert` to handle duplicate entries
2. **Flutter Profile Screen**: Added error handling for missing `user_statistics` table
3. **Default Values**: Provided comprehensive default statistics when table is missing

## Notes

- The migrations include RLS policies that ensure users can only access their own data
- The `user_statistics` table tracks login counts, fortune views, tokens, and achievements
- If you continue to see errors after migration, check the Supabase logs for RLS policy violations