#!/bin/bash

# Fortune 프로젝트 웹 코드 정리 스크립트
# 이 스크립트는 Flutter 앱으로 완전히 이전하면서 웹 관련 코드를 제거합니다.
# API 엔드포인트와 서버사이드 코드는 유지됩니다.

set -e

echo "🧹 Fortune 프로젝트 웹 코드 정리 시작..."
echo "⚠️  주의: 이 스크립트는 웹 프론트엔드 관련 코드를 영구적으로 삭제합니다."
echo "백업이 fortune_flutter/backup_web_frontend/ 디렉토리에 생성되었습니다."
echo ""

# 현재 디렉토리 확인
if [ ! -f "package.json" ]; then
    echo "❌ 오류: 프로젝트 루트 디렉토리에서 실행해주세요."
    exit 1
fi

# 삭제할 디렉토리 목록
DIRECTORIES_TO_DELETE=(
    # 웹 UI 컴포넌트
    "src/components"
    "src/contexts"
    "src/hooks"
    "src/stories"
    
    # 웹 페이지 (API 제외)
    "src/app/about"
    "src/app/auth"
    "src/app/consult"
    "src/app/dashboard"
    "src/app/explore"
    "src/app/feedback"
    "src/app/fortune"
    "src/app/history"
    "src/app/home"
    "src/app/interactive"
    "src/app/membership"
    "src/app/onboarding"
    "src/app/payment"
    "src/app/physiognomy"
    "src/app/policy"
    "src/app/premium"
    "src/app/profile"
    "src/app/special"
    "src/app/subscription"
    "src/app/support"
    "src/app/test-ads"
    "src/app/wish-wall"
    "src/app/admin"  # 관리자 페이지도 Flutter로 이전
    
    # 웹 관련 테스트
    "tests"
    "test-results"
    "playwright-report"
    "__tests__"
    
    # Storybook
    ".storybook"
    
    # 웹 전용 설정
    "PRPs"
    
    # 기타 웹 관련 디렉토리
    "src/pages"  # Next.js 구버전 페이지
)

# 삭제할 파일 목록
FILES_TO_DELETE=(
    # 웹 페이지 파일
    "src/app/page.tsx"
    "src/app/layout.tsx"
    "src/app/globals.css"
    "src/app/favicon.ico"
    "src/app/actions.ts"
    
    # 웹 전용 설정 파일
    "next.config.ts"
    "next-env.d.ts"
    "middleware.ts"
    "tailwind.config.ts"
    "postcss.config.mjs"
    "components.json"
    "vitest.config.ts"
    "vitest.shims.d.ts"
    "playwright.config.ts"
    
    # 스타일 파일
    "src/globals.css"
    
    # 웹 클라이언트 유틸리티 (서버사이드는 유지)
    "src/lib/supabase-browser.ts"
    "src/components/providers.tsx"
    "src/components/client-only.tsx"
    
    # 테스트 결과
    "test-results.json"
    
    # 코드 정리 리포트 (이미 완료됨)
    "code-cleanup-report.json"
    "comprehensive-cleanup-report.json"
)

# 웹 전용 npm 패키지 목록 (package.json에서 제거할 항목)
WEB_PACKAGES=(
    # UI 라이브러리
    "@radix-ui/*"
    "@hookform/resolvers"
    "react-hook-form"
    "react-hot-toast"
    "react-day-picker"
    "framer-motion"
    "recharts"
    "class-variance-authority"
    "clsx"
    "tailwind-merge"
    "tailwindcss-animate"
    "lucide-react"
    
    # Next.js 웹 전용
    "next-themes"
    "next-google-adsense"
    "critters"
    "html2canvas"
    
    # Storybook
    "@storybook/*"
    "@chromatic-com/storybook"
    "storybook"
    
    # 테스트 도구 (웹 전용)
    "@playwright/*"
    "playwright"
    "@vitest/*"
    "vitest"
    "@axe-core/playwright"
    "wait-on"
    
    # 스타일링
    "tailwindcss"
    "postcss"
    
    # Auth UI (Flutter에서 자체 구현)
    "@supabase/auth-ui-react"
    "@supabase/auth-ui-shared"
)

echo "📁 디렉토리 삭제 중..."
for dir in "${DIRECTORIES_TO_DELETE[@]}"; do
    if [ -d "$dir" ]; then
        echo "  삭제: $dir"
        rm -rf "$dir"
    fi
done

echo ""
echo "📄 파일 삭제 중..."
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        echo "  삭제: $file"
        rm -f "$file"
    fi
done

echo ""
echo "📦 package.json 정리 중..."
# package.json 백업
cp package.json package.json.backup

# 웹 전용 스크립트 제거
echo "  웹 전용 npm 스크립트 제거..."
npm pkg delete scripts.storybook
npm pkg delete scripts.build-storybook
npm pkg delete scripts.test
npm pkg delete scripts.test:ui
npm pkg delete scripts.test:headed
npm pkg delete scripts.test:debug
npm pkg delete scripts.test:report
npm pkg delete scripts.test:coverage
npm pkg delete scripts.format:check

# package.json에서 웹 전용 패키지 제거 예고
echo ""
echo "⚠️  다음 웹 전용 패키지들을 package.json에서 제거해야 합니다:"
echo "  (수동으로 확인 후 제거를 권장합니다)"
echo ""
for package in "${WEB_PACKAGES[@]}"; do
    echo "  - $package"
done

echo ""
echo "📂 정리 후 남은 주요 디렉토리:"
echo "  - src/app/api/* (API 엔드포인트 유지)"
echo "  - src/lib/* (서버사이드 유틸리티 유지)"
echo "  - src/services/* (비즈니스 로직 유지)"
echo "  - src/ai/* (AI 서비스 유지)"
echo "  - src/middleware/* (API 미들웨어 유지)"
echo "  - scripts/* (유틸리티 스크립트 유지)"
echo "  - supabase/* (데이터베이스 마이그레이션 유지)"

echo ""
echo "🎯 다음 단계:"
echo "1. package.json에서 웹 전용 패키지 제거"
echo "2. npm install로 node_modules 정리"
echo "3. Flutter 앱 빌드 및 테스트"
echo "4. API 엔드포인트 동작 확인"

echo ""
echo "✅ 웹 코드 정리 완료!"
echo "💡 팁: package.json.backup 파일이 백업으로 생성되었습니다."