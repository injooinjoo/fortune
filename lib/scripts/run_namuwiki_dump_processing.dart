import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/namuwiki_dump_processor.dart';
import '../services/celebrity_list_service.dart';
import '../data/models/celebrity_master_list.dart';

/// 나무위키 덤프를 처리하여 연예인 정보를 추출하고 데이터베이스에 저장하는 스크립트
/// 
/// 실행 방법:
/// 1. 나무위키 덤프 다운로드: https://dumps.namu.wiki/
/// 2. 덤프 파일 경로 설정
/// 3. flutter run lib/scripts/run_namuwiki_dump_processing.dart --dart-define=DUMP_PATH=/path/to/dump.xml
class NamuWikiDumpProcessingScript {
  static Future<void> main() async {
    print('🚀 나무위키 덤프 처리를 시작합니다...\n');

    try {
      // 1. 환경변수 및 설정 확인
      final dumpPath = const String.fromEnvironment('DUMP_PATH');
      if (dumpPath.isEmpty) {
        print('❌ 덤프 파일 경로가 지정되지 않았습니다.');
        print('사용법: flutter run lib/scripts/run_namuwiki_dump_processing.dart --dart-define=DUMP_PATH=/path/to/dump.xml');
        print('\n📥 나무위키 덤프 다운로드: https://dumps.namu.wiki/');
        return;
      }

      // 2. Supabase 초기화
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        print('❌ SUPABASE_URL과 SUPABASE_ANON_KEY 환경변수를 설정해주세요.');
        return;
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase 연결 완료');

      // 3. 서비스 초기화
      final dumpProcessor = NamuWikiDumpProcessor(dumpFilePath: dumpPath);
      final listService = CelebrityListService();

      // 4. 덤프 파일 정보 확인
      print('\n📁 덤프 파일 정보 확인 중...');
      final dumpInfo = await dumpProcessor.getDumpFileInfo();
      print('파일 경로: ${dumpInfo.filePath}');
      print('파일 크기: ${dumpInfo.fileSizeFormatted}');
      print('수정 날짜: ${dumpInfo.lastModified}');

      // 5. 처리할 연예인 목록 가져오기
      print('\n📋 처리할 연예인 목록 조회 중...');
      final targetCelebrities = await listService.getNextCelebritiesToCrawl(
        limit: 400, // 전체 목록
      );

      if (targetCelebrities.isEmpty) {
        print('처리할 연예인이 없습니다. 먼저 연예인 목록을 업로드해주세요.');
        return;
      }

      print('총 처리 대상: ${targetCelebrities.length}명');

      // 6. 사용자 확인
      print('\n⚠️  덤프 처리를 시작하시겠습니까? 시간이 오래 걸릴 수 있습니다.');
      print('계속하려면 y, 취소하려면 n을 입력하세요:');
      
      final input = stdin.readLineSync();
      if (input?.toLowerCase() != 'y') {
        print('덤프 처리를 취소합니다.');
        return;
      }

      // 7. 배치 처리 실행
      await _processCelebritiesBatch(
        dumpProcessor,
        listService,
        targetCelebrities,
      );

    } catch (e, stackTrace) {
      print('❌ 덤프 처리 중 오류가 발생했습니다: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// 연예인들을 배치로 처리합니다
  static Future<void> _processCelebritiesBatch(
    NamuWikiDumpProcessor dumpProcessor,
    CelebrityListService listService,
    List<CelebrityMasterListItem> celebrities,
  ) async {
    const batchSize = 50; // 한 번에 처리할 연예인 수
    final totalBatches = (celebrities.length / batchSize).ceil();
    
    int totalProcessed = 0;
    int totalSuccessful = 0;
    int totalFailed = 0;

    print('\n🔄 배치 처리 시작 (${totalBatches}개 배치, 배치당 $batchSize명)');

    for (int batchIndex = 0; batchIndex < totalBatches; batchIndex++) {
      final startIndex = batchIndex * batchSize;
      final endIndex = (startIndex + batchSize).clamp(0, celebrities.length);
      final batch = celebrities.sublist(startIndex, endIndex);

      print('\n📦 배치 ${batchIndex + 1}/$totalBatches 처리 중 (${batch.length}명)...');

      // 현재 배치의 연예인 이름들
      final celebrityNames = batch.map((c) => c.name).toList();

      try {
        // 덤프에서 정보 추출
        final extractedInfo = await dumpProcessor.extractMultipleCelebrities(celebrityNames);
        
        int batchSuccessful = 0;
        int batchFailed = 0;

        // 각 연예인별로 처리
        for (final celebrity in batch) {
          final info = extractedInfo[celebrity.name];
          
          if (info != null) {
            try {
              // celebrities 테이블에 저장
              await _saveCelebrityInfo(celebrity, info);
              
              // master list 상태 업데이트
              await listService.markCelebrityAsCrawled(celebrity.id);
              
              batchSuccessful++;
              print('  ✅ ${celebrity.name}');
              
            } catch (e) {
              batchFailed++;
              print('  ❌ ${celebrity.name}: 저장 실패 - $e');
            }
          } else {
            batchFailed++;
            print('  ❌ ${celebrity.name}: 덤프에서 찾을 수 없음');
          }
        }

        totalProcessed += batch.length;
        totalSuccessful += batchSuccessful;
        totalFailed += batchFailed;

        print('📊 배치 ${batchIndex + 1} 완료: 성공 $batchSuccessful명, 실패 $batchFailed명');
        
        // 배치 간 딜레이 (메모리 정리를 위해)
        if (batchIndex < totalBatches - 1) {
          await Future.delayed(Duration(seconds: 2));
        }

      } catch (e) {
        print('❌ 배치 ${batchIndex + 1} 처리 중 오류: $e');
        totalFailed += batch.length;
      }
    }

    // 최종 결과
    print('\n🎉 덤프 처리 완료!');
    print('📊 최종 결과:');
    print('  총 처리: ${totalProcessed}명');
    print('  성공: ${totalSuccessful}명 (${(totalSuccessful / totalProcessed * 100).toStringAsFixed(1)}%)');
    print('  실패: ${totalFailed}명 (${(totalFailed / totalProcessed * 100).toStringAsFixed(1)}%)');

    if (totalSuccessful > 0) {
      print('\n✨ 성공적으로 처리된 연예인들의 정보가 데이터베이스에 저장되었습니다!');
      print('이제 앱에서 운세 생성에 활용할 수 있습니다.');
    }
  }

  /// 연예인 정보를 celebrities 테이블에 저장
  static Future<void> _saveCelebrityInfo(
    CelebrityMasterListItem masterItem,
    CelebrityInfo info,
  ) async {
    final supabase = Supabase.instance.client;

    await supabase.from('celebrities').upsert({
      'name': info.name,
      'name_en': masterItem.nameEn, // 마스터 리스트의 영어 이름 사용
      'category': _mapCategoryToTable(masterItem.category),
      'gender': info.gender,
      'birth_date': info.birthDate,
      'birth_time': info.birthTime ?? '12:00',
      'description': info.description,
      'profile_image_url': info.profileImageUrl,
      'keywords': info.keywords,
      'additional_info': {
        'debut': info.debut,
        'agency': info.agency,
        'occupation': info.occupation,
        'aliases': info.aliases,
        'master_list_id': masterItem.id,
        'master_category': masterItem.category.code,
        'master_subcategory': masterItem.subcategory?.code,
        'popularity_rank': masterItem.popularityRank,
        'search_volume': masterItem.searchVolume,
        'processed_from_dump': true,
        'processed_at': DateTime.now().toIso8601String(),
      },
      'popularity_score': _calculatePopularityScore(masterItem),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// celebrity_master_list 카테고리를 celebrities 테이블 카테고리로 매핑
  static String _mapCategoryToTable(CelebrityMasterCategory category) {
    switch (category) {
      case CelebrityMasterCategory.singer:
        return 'singer';
      case CelebrityMasterCategory.actor:
        return 'actor';
      case CelebrityMasterCategory.streamer:
        return 'streamer';
      case CelebrityMasterCategory.youtuber:
        return 'youtuber';
      case CelebrityMasterCategory.politician:
        return 'politician';
      case CelebrityMasterCategory.business:
        return 'business_leader';
      case CelebrityMasterCategory.comedian:
        return 'entertainer';
      case CelebrityMasterCategory.athlete:
        return 'sports';
      case CelebrityMasterCategory.proGamer:
        return 'pro_gamer';
      default:
        return 'entertainer';
    }
  }

  /// 인기 점수 계산
  static int _calculatePopularityScore(CelebrityMasterListItem item) {
    int score = (101 - item.popularityRank) * 10; // 기본 순위 점수
    
    if (item.searchVolume != null) {
      if (item.searchVolume! > 2000000) score += 100;
      else if (item.searchVolume! > 1000000) score += 80;
      else if (item.searchVolume! > 500000) score += 50;
      else if (item.searchVolume! > 100000) score += 20;
    }
    
    return score;
  }
}

/// 스크립트 실행 진입점
void main() async {
  await NamuWikiDumpProcessingScript.main();
}