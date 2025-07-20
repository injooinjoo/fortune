#!/bin/bash

# Verify Supabase Setup Script
# This script helps diagnose issues with edge functions and database tables

echo "🔍 Supabase Setup Verification Script"
echo "====================================="

# Check if user is in the correct directory
if [ ! -f "supabase/config.toml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo ""
echo "1. Checking Supabase CLI installation..."
if command -v supabase &> /dev/null; then
    echo "✅ Supabase CLI is installed"
    supabase --version
else
    echo "❌ Supabase CLI is not installed"
    echo "   Please install it: brew install supabase/tap/supabase"
    exit 1
fi

echo ""
echo "2. Checking Supabase project status..."
supabase status

echo ""
echo "3. Listing deployed edge functions..."
supabase functions list

echo ""
echo "4. Checking specific edge functions..."
FUNCTIONS=("token-balance" "subscription" "token-consumption-rates" "calculate-saju")
for func in "${FUNCTIONS[@]}"; do
    if supabase functions list | grep -q "$func"; then
        echo "✅ $func is deployed"
    else
        echo "❌ $func is NOT deployed"
    fi
done

echo ""
echo "5. To deploy missing edge functions, run:"
echo "   supabase functions deploy <function-name>"
echo ""
echo "   Or deploy all functions:"
echo "   supabase functions deploy"

echo ""
echo "6. To check function logs, run:"
echo "   supabase functions logs <function-name>"

echo ""
echo "7. Database tables check (run these queries in Supabase dashboard):"
echo ""
echo "-- Check if user_profiles exists and has data:"
echo "SELECT COUNT(*) FROM user_profiles;"
echo ""
echo "-- Check if token_balances exists:"
echo "SELECT COUNT(*) FROM token_balances;"
echo ""
echo "-- Check if user_statistics exists:"
echo "SELECT COUNT(*) FROM user_statistics;"
echo ""
echo "-- Check specific user profile:"
echo "SELECT * FROM user_profiles WHERE id = '070ceecf-774f-4ee0-bb9e-059238dcf028';"
echo ""
echo "-- Check token balance for user:"
echo "SELECT * FROM token_balances WHERE user_id = '070ceecf-774f-4ee0-bb9e-059238dcf028';"

echo ""
echo "8. To run pending migrations:"
echo "   supabase db push"

echo ""
echo "✅ Verification script complete!"