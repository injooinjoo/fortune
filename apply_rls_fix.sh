#!/bin/bash

# RLS 정책 수정 스크립트
# 이 스크립트는 user_profiles 테이블의 중복된 RLS 정책을 수정합니다

echo "🔧 User Profiles RLS 정책 수정 시작..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Supabase 프로젝트 확인
if [ ! -f "supabase/config.toml" ]; then
    echo -e "${RED}❌ Supabase 프로젝트가 아닙니다. fortune 디렉토리에서 실행해주세요.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 다음 작업을 수행합니다:${NC}"
echo "1. 중복된 RLS 정책 확인"
echo "2. 모든 기존 정책 삭제"
echo "3. 올바른 정책 재생성"
echo ""

read -p "계속하시겠습니까? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "작업을 취소했습니다."
    exit 1
fi

echo -e "\n${GREEN}✅ SQL 파일이 생성되었습니다: fix_user_profiles_rls.sql${NC}"
echo ""
echo -e "${YELLOW}🚀 다음 단계:${NC}"
echo ""
echo "1. Supabase Dashboard에서 SQL 실행 (권장):"
echo "   - https://app.supabase.com 접속"
echo "   - SQL Editor 열기"
echo "   - fix_user_profiles_rls.sql 내용 복사하여 실행"
echo ""
echo "2. 또는 Supabase CLI 사용:"
echo "   supabase db push"
echo ""
echo -e "${GREEN}💡 팁: SQL 실행 후 앱에서 로그아웃하고 다시 로그인하여 테스트하세요.${NC}"