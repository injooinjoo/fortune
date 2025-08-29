import 'dart:io';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/celebrity_list_service.dart';

/// 연예인 목록을 Supabase에 업로드하는 스크립트
/// 
/// 실행 방법:
/// flutter run lib/scripts/upload_celebrity_lists.dart
class CelebrityUploadScript {
  static Future<void> main() async {
    print('🚀 연예인 목록 업로드를 시작합니다...\n');
    
    try {
      // Supabase 초기화 (환경변수에서 가져와야 함)
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        print('❌ SUPABASE_URL과 SUPABASE_ANON_KEY 환경변수를 설정해주세요.');
        print('예시: flutter run lib/scripts/upload_celebrity_lists.dart --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
        return;
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      
      print('✅ Supabase 연결 완료');
      
      // CelebrityListService 인스턴스 생성
      final service = CelebrityListService();
      
      // 기존 데이터 확인
      print('\n📊 기존 데이터 확인 중...');
      final stats = await service.getCrawlingStats();
      print('기존 연예인 수: ${stats.totalCelebrities}명');
      
      if (stats.totalCelebrities > 0) {
        print('\n⚠️  이미 데이터가 존재합니다. 계속 진행하시겠습니까? (기존 데이터는 업데이트됩니다)');
        print('계속하려면 y, 취소하려면 n을 입력하세요:');
        
        final input = stdin.readLineSync();
        if (input?.toLowerCase() != 'y') {
          print('업로드를 취소합니다.');
          return;
        }
      }
      
      // 모든 카테고리 업로드
      print('\n🔄 모든 카테고리 업로드 시작...\n');
      await service.uploadAllCategoriesToSupabase();
      
      // 최종 통계 확인
      print('\n📈 업로드 완료 후 통계:');
      final finalStats = await service.getCrawlingStats();
      print('총 연예인 수: ${finalStats.totalCelebrities}명');
      print('크롤링 완료: ${finalStats.crawledCelebrities}명');
      print('크롤링 진행률: ${finalStats.crawlingPercentage.toStringAsFixed(1)}%');
      
      // 카테고리별 통계
      print('\n📋 카테고리별 통계:');
      final categoryStats = await service.getCategoryStats();
      for (final entry in categoryStats.entries) {
        final stat = entry.value;
        print('${entry.key}: ${stat.total}명 (크롤링: ${stat.crawled}명, ${stat.crawledPercentage.toStringAsFixed(1)}%)');
      }
      
      print('\n🎉 업로드가 성공적으로 완료되었습니다!');
      print('이제 크롤링을 시작할 수 있습니다.');
      
    } catch (e, stackTrace) {
      print('❌ 업로드 중 오류가 발생했습니다: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

/// 스크립트 실행 진입점
void main() async {
  await CelebrityUploadScript.main();
}