import 'dart:io';
import 'dart:convert';
import '../services/saju_calculation_service.dart';
import '../data/models/celebrity_saju.dart';

/// 629명의 전체 유명인사 사주 일괄 처리 시스템
/// 통합된 celebrity_consolidated_master.json 데이터를 사용하여
/// 모든 유명인의 사주를 계산하고 SQL 파일을 생성합니다.
class CompleteCelebrityBatchProcessor {
  static const String masterDataFile = 'celebrity_consolidated_master.json';
  static const int batchSize = 50; // 배치당 처리할 인원수
  
  /// 전체 629명의 유명인 사주 일괄 처리 실행
  static Future<void> processAllCelebrities() async {
    print('🚀 629명 전체 유명인 사주 일괄 처리 시작...\n');
    
    // 통합 데이터 파일 읽기
    final masterFile = File(masterDataFile);
    if (!await masterFile.exists()) {
      print('❌ 통합 데이터 파일을 찾을 수 없습니다: $masterDataFile');
      print('   먼저 complete_celebrity_data_consolidator.dart를 실행하세요.');
      return;
    }
    
    final jsonString = await masterFile.readAsString();
    final Map<String, dynamic> masterData = json.decode(jsonString);
    final List<dynamic> allCelebrities = masterData['celebrities'] as List<dynamic>;
    
    print('📋 로드된 유명인 데이터: ${allCelebrities.length}명');
    print('배치 크기: $batchSize명씩 처리\n');
    
    final List<CelebritySaju> processedCelebrities = [];
    final List<String> sqlStatements = [];
    final List<String> processingErrors = [];
    
    int totalProcessed = 0;
    int successCount = 0;
    int errorCount = 0;
    
    // 배치 단위로 처리
    for (int batchStart = 0; batchStart < allCelebrities.length; batchStart += batchSize) {
      final batchEnd = (batchStart + batchSize).clamp(0, allCelebrities.length);
      final batchNumber = (batchStart ~/ batchSize) + 1;
      final totalBatches = ((allCelebrities.length - 1) ~/ batchSize) + 1;
      
      print('📦 배치 $batchNumber/$totalBatches 처리 시작 (${batchStart + 1}-$batchEnd번째 유명인)');
      
      for (int i = batchStart; i < batchEnd; i++) {
        final celebrityData = allCelebrities[i] as Map<String, dynamic>;
        totalProcessed++;
        
        try {
          final celebrity = await _processSingleCelebrity(celebrityData);
          
          if (celebrity != null) {
            processedCelebrities.add(celebrity);
            sqlStatements.add(_generateInsertSQL(celebrity));
            successCount++;
          } else {
            errorCount++;
            processingErrors.add('${celebrityData['name'] ?? 'Unknown'}: 처리 실패');
          }
        } catch (e) {
          errorCount++;
          final errorMsg = '${celebrityData['name'] ?? 'Unknown'}: $e';
          processingErrors.add(errorMsg);
          print('❌ $errorMsg');
        }
      }
      
      print('✅ 배치 $batchNumber 완료: ${batchEnd - batchStart}명 중 ${successCount - (totalProcessed - (batchEnd - batchStart) - errorCount)}명 성공\n');
      
      // 메모리 절약을 위해 잠시 대기
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    // 결과 저장
    await _saveResults(processedCelebrities, sqlStatements, processingErrors);
    
    // 최종 통계
    _printFinalStatistics(totalProcessed, successCount, errorCount);
  }
  
  /// 개별 유명인 사주 처리
  static Future<CelebritySaju?> _processSingleCelebrity(
    Map<String, dynamic> data,
  ) async {
    try {
      final name = data['name'] as String;
      final nameEn = data['name_en'] as String? ?? '';
      final birthDate = data['birth_date'] as String?;
      final birthTime = data['birth_time'] as String? ?? '12:00';
      final gender = data['gender'] as String? ?? 'male';
      final category = data['category'] as String? ?? 'unknown';
      
      if (birthDate == null || birthDate.isEmpty) {
        return null;
      }
      
      // 생년월일 파싱
      final dateParts = birthDate.split('-');
      if (dateParts.length != 3) {
        return null;
      }
      
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      // 생시 파싱
      final timeParts = birthTime.split(':');
      final hour = timeParts.isNotEmpty ? int.parse(timeParts[0]) : 12;
      final minute = timeParts.length >= 2 ? int.parse(timeParts[1]) : 0;
      
      final birthDateTime = DateTime(year, month, day, hour, minute);
      
      // 사주 계산
      final sajuResult = SajuCalculationService.calculateSaju(
        birthDate: birthDateTime,
        birthTime: birthTime,
        isLunar: false,
      );
      
      // CelebritySaju 객체 생성
      return CelebritySaju(
        id: _generateUniqueId(name, category),
        name: name,
        nameEn: nameEn,
        birthDate: birthDate,
        birthTime: birthTime,
        gender: gender,
        birthPlace: data['birth_place'] as String? ?? '',
        category: category,
        agency: data['agency'] as String? ?? '',
        yearPillar: _extractPillar(sajuResult, 'year'),
        monthPillar: _extractPillar(sajuResult, 'month'),
        dayPillar: _extractPillar(sajuResult, 'day'),
        hourPillar: _extractPillar(sajuResult, 'hour'),
        sajuString: _generateSajuString(sajuResult),
        woodCount: _countElement(sajuResult, '목'),
        fireCount: _countElement(sajuResult, '화'),
        earthCount: _countElement(sajuResult, '토'),
        metalCount: _countElement(sajuResult, '금'),
        waterCount: _countElement(sajuResult, '수'),
        fullSajuData: sajuResult,
        dataSource: 'celebrity_batch_processed_v2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 고유 ID 생성
  static String _generateUniqueId(String name, String category) {
    final cleanName = name.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '_');
    return '${category}_$cleanName';
  }
  
  /// 사주 기둥 추출
  static String _extractPillar(Map<String, dynamic> sajuData, String pillarType) {
    final pillar = sajuData[pillarType];
    if (pillar == null) return '';
    return '${pillar['stem'] ?? ''}${pillar['branch'] ?? ''}';
  }
  
  /// 사주 문자열 생성
  static String _generateSajuString(Map<String, dynamic> sajuData) {
    final parts = <String>[];
    
    ['year', 'month', 'day', 'hour'].forEach((pillarType) {
      if (sajuData[pillarType] != null) {
        final pillar = sajuData[pillarType];
        parts.add('${pillar['stem'] ?? ''}${pillar['branch'] ?? ''}');
      }
    });
    
    return parts.join(' ');
  }
  
  /// 오행 개수 계산
  static int _countElement(Map<String, dynamic> sajuData, String element) {
    final elements = sajuData['elements'] as Map<String, dynamic>?;
    return elements?[element] as int? ?? 0;
  }
  
  /// SQL INSERT 문 생성
  static String _generateInsertSQL(CelebritySaju celebrity) {
    // SQL 문자열 이스케이프 처리
    String escapeSQL(String value) {
      return value.replaceAll("'", "''");
    }
    
    final escapedName = escapeSQL(celebrity.name);
    final escapedNameEn = escapeSQL(celebrity.nameEn);
    final escapedBirthPlace = escapeSQL(celebrity.birthPlace);
    final escapedAgency = escapeSQL(celebrity.agency);
    final escapedSajuString = escapeSQL(celebrity.sajuString);
    final escapedDataSource = escapeSQL(celebrity.dataSource);
    
    // JSON 데이터를 SQL용 문자열로 변환
    final fullSajuDataJson = escapeSQL(json.encode(celebrity.fullSajuData));
    
    return """
INSERT INTO celebrities (
  id, name, name_en, birth_date, birth_time, gender, birth_place, category, agency,
  year_pillar, month_pillar, day_pillar, hour_pillar, saju_string,
  wood_count, fire_count, earth_count, metal_count, water_count,
  full_saju_data, data_source, created_at, updated_at
) VALUES (
  '${celebrity.id}', '$escapedName', '$escapedNameEn', '${celebrity.birthDate}', '${celebrity.birthTime}',
  '${celebrity.gender}', '$escapedBirthPlace', '${celebrity.category}', '$escapedAgency',
  '${celebrity.yearPillar}', '${celebrity.monthPillar}', '${celebrity.dayPillar}', '${celebrity.hourPillar}',
  '$escapedSajuString', ${celebrity.woodCount}, ${celebrity.fireCount}, ${celebrity.earthCount},
  ${celebrity.metalCount}, ${celebrity.waterCount},
  '$fullSajuDataJson'::jsonb, '$escapedDataSource', NOW(), NOW()
) ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  birth_date = EXCLUDED.birth_date,
  birth_time = EXCLUDED.birth_time,
  gender = EXCLUDED.gender,
  birth_place = EXCLUDED.birth_place,
  category = EXCLUDED.category,
  agency = EXCLUDED.agency,
  year_pillar = EXCLUDED.year_pillar,
  month_pillar = EXCLUDED.month_pillar,
  day_pillar = EXCLUDED.day_pillar,
  hour_pillar = EXCLUDED.hour_pillar,
  saju_string = EXCLUDED.saju_string,
  wood_count = EXCLUDED.wood_count,
  fire_count = EXCLUDED.fire_count,
  earth_count = EXCLUDED.earth_count,
  metal_count = EXCLUDED.metal_count,
  water_count = EXCLUDED.water_count,
  full_saju_data = EXCLUDED.full_saju_data,
  data_source = EXCLUDED.data_source,
  updated_at = NOW();""";
  }
  
  /// 결과 저장
  static Future<void> _saveResults(
    List<CelebritySaju> celebrities, 
    List<String> sqlStatements,
    List<String> errors,
  ) async {
    final timestamp = DateTime.now().toIso8601String().substring(0, 19);
    
    try {
      // 1. JSON 파일로 사주 결과 저장
      final jsonFile = File('celebrity_saju_batch_results_$timestamp.json');
      final jsonData = celebrities.map((c) => c.toJson()).toList();
      await jsonFile.writeAsString(json.encode(jsonData, toEncodable: (obj) {
        if (obj is DateTime) return obj.toIso8601String();
        return obj;
      }));
      print('✅ JSON 결과 저장: ${jsonFile.path}');
      
      // 2. SQL 파일로 INSERT 문 저장
      final sqlFile = File('celebrity_batch_insert_$timestamp.sql');
      final sqlContent = [
        '-- 629명 전체 유명인 사주 데이터 일괄 업로드 SQL',
        '-- 생성일시: $timestamp',
        '-- 성공: ${celebrities.length}명, 실패: ${errors.length}명',
        '',
        '-- 테이블이 존재하지 않는 경우 생성',
        '''CREATE TABLE IF NOT EXISTS public.celebrities (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200) DEFAULT '',
    birth_date VARCHAR(20) NOT NULL,
    birth_time VARCHAR(10) DEFAULT '12:00',
    gender VARCHAR(10) DEFAULT 'male',
    birth_place VARCHAR(200) DEFAULT '',
    category VARCHAR(50) DEFAULT 'unknown',
    agency VARCHAR(200) DEFAULT '',
    year_pillar VARCHAR(10) DEFAULT '',
    month_pillar VARCHAR(10) DEFAULT '',
    day_pillar VARCHAR(10) DEFAULT '',
    hour_pillar VARCHAR(10) DEFAULT '',
    saju_string VARCHAR(100) DEFAULT '',
    wood_count INTEGER DEFAULT 0,
    fire_count INTEGER DEFAULT 0,
    earth_count INTEGER DEFAULT 0,
    metal_count INTEGER DEFAULT 0,
    water_count INTEGER DEFAULT 0,
    full_saju_data JSONB DEFAULT '{}',
    data_source VARCHAR(100) DEFAULT 'celebrity_batch_processed_v2',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);''',
        '',
        '-- 인덱스 생성',
        'CREATE INDEX IF NOT EXISTS idx_celebrities_name ON celebrities(name);',
        'CREATE INDEX IF NOT EXISTS idx_celebrities_category ON celebrities(category);',
        'CREATE INDEX IF NOT EXISTS idx_celebrities_birth_date ON celebrities(birth_date);',
        '',
        '-- 데이터 삽입',
        ...sqlStatements,
      ].join('\n');
      
      await sqlFile.writeAsString(sqlContent);
      print('✅ SQL 파일 저장: ${sqlFile.path}');
      
      // 3. 통계 파일 저장
      final statsFile = File('celebrity_batch_stats_$timestamp.json');
      final stats = _generateDetailedStats(celebrities, errors);
      await statsFile.writeAsString(json.encode(stats));
      print('✅ 통계 파일 저장: ${statsFile.path}');
      
      // 4. 오류 로그 저장 (오류가 있는 경우)
      if (errors.isNotEmpty) {
        final errorFile = File('celebrity_batch_errors_$timestamp.txt');
        await errorFile.writeAsString(errors.join('\n'));
        print('📝 오류 로그 저장: ${errorFile.path}');
      }
      
    } catch (e) {
      print('❌ 파일 저장 중 오류 발생: $e');
    }
  }
  
  /// 상세 통계 생성
  static Map<String, dynamic> _generateDetailedStats(
    List<CelebritySaju> celebrities, 
    List<String> errors,
  ) {
    final categoryStats = <String, int>{};
    final genderStats = <String, int>{};
    final elementStats = <String, int>{};
    final agencyStats = <String, int>{};
    
    for (final celebrity in celebrities) {
      // 카테고리별 통계
      categoryStats[celebrity.category] = (categoryStats[celebrity.category] ?? 0) + 1;
      
      // 성별 통계
      genderStats[celebrity.gender] = (genderStats[celebrity.gender] ?? 0) + 1;
      
      // 소속사 통계
      if (celebrity.agency.isNotEmpty) {
        agencyStats[celebrity.agency] = (agencyStats[celebrity.agency] ?? 0) + 1;
      }
      
      // 주요 오행 통계
      final dominantElement = _getDominantElement(
        celebrity.woodCount, celebrity.fireCount, celebrity.earthCount, 
        celebrity.metalCount, celebrity.waterCount
      );
      elementStats[dominantElement] = (elementStats[dominantElement] ?? 0) + 1;
    }
    
    return {
      'processing_summary': {
        'total_processed': celebrities.length,
        'success_count': celebrities.length,
        'error_count': errors.length,
        'success_rate': '${(celebrities.length / (celebrities.length + errors.length) * 100).toStringAsFixed(1)}%',
      },
      'category_distribution': categoryStats,
      'gender_distribution': genderStats,
      'dominant_element_distribution': elementStats,
      'top_agencies': _getTopEntries(agencyStats, 10),
      'processing_timestamp': DateTime.now().toIso8601String(),
      'data_source': 'celebrity_batch_processed_v2',
      'errors': errors.length > 0 ? errors.take(20).toList() : [],
    };
  }
  
  /// 주요 오행 결정
  static String _getDominantElement(int wood, int fire, int earth, int metal, int water) {
    final counts = {'목': wood, '화': fire, '토': earth, '금': metal, '수': water};
    String dominant = '토';
    int maxCount = 0;
    
    counts.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = element;
      }
    });
    
    return dominant;
  }
  
  /// 상위 항목 추출
  static Map<String, int> _getTopEntries(Map<String, int> data, int limit) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(entries.take(limit));
  }
  
  /// 최종 통계 출력
  static void _printFinalStatistics(int total, int success, int errors) {
    print('🎉 전체 유명인 사주 일괄 처리 완료!\n');
    print('📊 최종 처리 통계:');
    print('   총 처리: $total명');
    print('   성공: $success명');
    print('   실패: $errors명');
    print('   성공률: ${(success / total * 100).toStringAsFixed(1)}%\n');
    
    print('📁 생성된 파일들:');
    print('   - celebrity_saju_batch_results_[timestamp].json (사주 결과 데이터)');
    print('   - celebrity_batch_insert_[timestamp].sql (Supabase 업로드용 SQL)');
    print('   - celebrity_batch_stats_[timestamp].json (상세 통계)');
    if (errors > 0) {
      print('   - celebrity_batch_errors_[timestamp].txt (오류 로그)');
    }
    print('\n✨ SQL 파일을 Supabase 대시보드에서 실행하여 데이터베이스에 업로드하세요!');
  }
}

/// 실행 스크립트
void main() async {
  await CompleteCelebrityBatchProcessor.processAllCelebrities();
}