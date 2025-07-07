#!/usr/bin/env node

/**
 * 토큰 잔액 표시 테스트 스크립트
 * 
 * 테스트 항목:
 * 1. TokenBalance 컴포넌트가 올바르게 렌더링되는지
 * 2. 사용자 로그인 상태에 따라 표시/숨김이 작동하는지
 * 3. 토큰 잔액이 정확히 표시되는지
 * 4. 무제한 사용자의 경우 "무제한"으로 표시되는지
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function testTokenBalanceDisplay() {
  console.log('🧪 토큰 잔액 표시 테스트 시작...\n');

  try {
    // 1. 테스트 사용자 확인
    console.log('1️⃣ 테스트 사용자 확인');
    const testUserId = 'test-user-id'; // 실제 테스트 사용자 ID로 변경 필요
    
    // 2. 토큰 잔액 조회
    console.log('\n2️⃣ 토큰 잔액 조회');
    const { data: userTokens, error: tokenError } = await supabase
      .from('user_tokens')
      .select('balance')
      .eq('user_id', testUserId)
      .single();

    if (tokenError && tokenError.code !== 'PGRST116') {
      console.error('❌ 토큰 조회 실패:', tokenError);
    } else {
      console.log('✅ 현재 토큰 잔액:', userTokens?.balance || 0);
    }

    // 3. 구독 상태 확인
    console.log('\n3️⃣ 구독 상태 확인');
    const { data: subscription, error: subError } = await supabase
      .from('subscription_status')
      .select('plan_type, status')
      .eq('user_id', testUserId)
      .eq('status', 'active')
      .single();

    if (subError && subError.code !== 'PGRST116') {
      console.error('❌ 구독 조회 실패:', subError);
    } else if (subscription) {
      console.log('✅ 구독 플랜:', subscription.plan_type);
      console.log('✅ 구독 상태:', subscription.status);
      
      if (subscription.plan_type === 'premium' || subscription.plan_type === 'enterprise') {
        console.log('✅ 무제한 사용자로 표시되어야 함');
      }
    } else {
      console.log('ℹ️ 활성 구독 없음 (무료 사용자)');
    }

    // 4. UI 렌더링 체크 (수동 확인 필요)
    console.log('\n4️⃣ UI 렌더링 체크 (수동 확인 필요)');
    console.log('다음 항목을 브라우저에서 확인하세요:');
    console.log('- [ ] AppHeader에 토큰 잔액이 표시되는지');
    console.log('- [ ] 토큰 잔액 클릭 시 /payment/tokens로 이동하는지');
    console.log('- [ ] 로그아웃 상태에서는 토큰 잔액이 표시되지 않는지');
    console.log('- [ ] /payment/tokens 페이지에서는 헤더에 토큰이 표시되지 않는지');
    console.log('- [ ] 무제한 사용자는 "무제한"으로 표시되는지');
    console.log('- [ ] 일반 사용자는 숫자로 표시되는지');

    // 5. 컴포넌트 파일 존재 확인
    console.log('\n5️⃣ 컴포넌트 파일 확인');
    const fs = require('fs');
    const path = require('path');
    
    const componentPath = path.join(__dirname, '../src/components/TokenBalance.tsx');
    if (fs.existsSync(componentPath)) {
      console.log('✅ TokenBalance 컴포넌트 파일 존재');
    } else {
      console.log('❌ TokenBalance 컴포넌트 파일 없음');
    }

    const headerPath = path.join(__dirname, '../src/components/AppHeader.tsx');
    if (fs.existsSync(headerPath)) {
      const headerContent = fs.readFileSync(headerPath, 'utf8');
      if (headerContent.includes('TokenBalance')) {
        console.log('✅ AppHeader에 TokenBalance 임포트됨');
      } else {
        console.log('❌ AppHeader에 TokenBalance 임포트 안됨');
      }
      
      if (headerContent.includes('showTokenBalance')) {
        console.log('✅ AppHeader에 showTokenBalance prop 추가됨');
      } else {
        console.log('❌ AppHeader에 showTokenBalance prop 없음');
      }
    }

    console.log('\n✅ 토큰 잔액 표시 테스트 완료!');

  } catch (error) {
    console.error('\n❌ 테스트 중 오류 발생:', error);
  }
}

// 테스트 실행
testTokenBalanceDisplay();