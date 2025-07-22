#!/bin/bash

echo "🔍 Supabase API 키 테스트 중..."
echo ""

# .env 파일에서 값 읽기
SUPABASE_URL=$(grep "^SUPABASE_URL=" fortune_flutter/.env | cut -d'=' -f2)
SUPABASE_ANON_KEY=$(grep "^SUPABASE_ANON_KEY=" fortune_flutter/.env | cut -d'=' -f2)

echo "📍 URL: $SUPABASE_URL"
echo "🔑 Key prefix: ${SUPABASE_ANON_KEY:0:50}..."
echo ""

# API 테스트
echo "🧪 API 연결 테스트..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  "$SUPABASE_URL/rest/v1/")

echo "📊 응답 코드: $RESPONSE"
echo ""

if [ "$RESPONSE" = "401" ]; then
  echo "❌ API 키가 유효하지 않습니다!"
  echo ""
  echo "🔧 해결 방법:"
  echo "1. Supabase 대시보드 접속:"
  echo "   https://supabase.com/dashboard/project/hayjukwfcsdmppairazc/settings/api"
  echo ""
  echo "2. 'anon' public 키 복사"
  echo ""
  echo "3. fortune_flutter/.env 파일 수정:"
  echo "   SUPABASE_ANON_KEY=<복사한 키>"
  echo ""
  echo "4. Flutter 앱 재시작:"
  echo "   cd fortune_flutter"
  echo "   flutter clean && flutter pub get && flutter run"
elif [ "$RESPONSE" = "200" ]; then
  echo "✅ API 키가 유효합니다!"
else
  echo "⚠️  예상치 못한 응답 코드: $RESPONSE"
fi