import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 백엔드 API 연결 테스트 스크립트
/// 실행: dart test_payment_api.dart
void main() async {
  print('🔍 Fortune 백엔드 API 연결 테스트 시작...\n');
  
  const apiBaseUrl = 'http://localhost:3000';
  bool allTestsPassed = true;
  
  // 1. 서버 상태 확인
  print('1️⃣ 서버 상태 확인 중...');
  try {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/health'),
    ).timeout(Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      print('✅ 서버가 정상적으로 실행 중입니다.\n');
    } else {
      print('❌ 서버 응답 오류: ${response.statusCode}');
      print('   응답: ${response.body}\n');
      allTestsPassed = false;
    }
  } catch (e) {
    print('❌ 서버에 연결할 수 없습니다.');
    print('   오류: $e');
    print('   💡 웹 프로젝트에서 "npm run dev"를 실행했는지 확인하세요.\n');
    allTestsPassed = false;
  }
  
  // 2. Payment Intent 엔드포인트 확인
  print('2️⃣ Payment Intent 엔드포인트 확인 중...');
  try {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/payment/create-payment-intent'),
      headers: {
        'Content-Type': 'application/json',
        // 테스트용 임시 토큰 (실제로는 Supabase 인증 토큰 필요)
        'Authorization': 'Bearer test-token',
      },
      body: jsonEncode({
        'amount': 1000,
        'currency': 'krw',
      }),
    ).timeout(Duration(seconds: 5));
    
    if (response.statusCode == 401) {
      print('⚠️  인증이 필요합니다 (예상된 동작)');
      print('   실제 앱에서는 Supabase 인증 토큰이 자동으로 추가됩니다.\n');
    } else if (response.statusCode == 200) {
      print('✅ Payment Intent 엔드포인트가 작동합니다.\n');
    } else {
      print('❌ Payment Intent 엔드포인트 오류: ${response.statusCode}');
      print('   응답: ${response.body}\n');
      allTestsPassed = false;
    }
  } catch (e) {
    print('❌ Payment Intent 엔드포인트에 연결할 수 없습니다.');
    print('   오류: $e\n');
    allTestsPassed = false;
  }
  
  // 3. 환경 변수 확인
  print('3️⃣ Flutter 환경 변수 확인 중...');
  final envFile = File('.env');
  if (await envFile.exists()) {
    final envContent = await envFile.readAsString();
    final hasStripeKey = envContent.contains('STRIPE_PUBLISHABLE_KEY');
    final hasApiUrl = envContent.contains('API_BASE_URL');
    
    if (hasStripeKey && hasApiUrl) {
      print('✅ 필수 환경 변수가 설정되어 있습니다.\n');
    } else {
      if (!hasStripeKey) {
        print('❌ STRIPE_PUBLISHABLE_KEY가 .env 파일에 없습니다.');
      }
      if (!hasApiUrl) {
        print('❌ API_BASE_URL이 .env 파일에 없습니다.');
      }
      print('');
      allTestsPassed = false;
    }
  } else {
    print('❌ .env 파일을 찾을 수 없습니다.');
    print('   .env.example 파일을 복사하여 .env 파일을 생성하세요.\n');
    allTestsPassed = false;
  }
  
  // 결과 요약
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  if (allTestsPassed) {
    print('✅ 모든 테스트를 통과했습니다!');
    print('   Flutter 앱에서 결제 기능을 사용할 수 있습니다.');
  } else {
    print('❌ 일부 테스트가 실패했습니다.');
    print('\n📝 해결 방법:');
    print('1. 웹 프로젝트 루트에서 "npm run dev" 실행');
    print('2. .env 파일에 필요한 키 설정');
    print('3. 백엔드 API의 CORS 설정 확인');
  }
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}