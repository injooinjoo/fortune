import 'dart:convert';
import 'dart:io';
import 'accurate_celebrity_data_processor.dart';

void main() async {
  print('🚀 정확한 유명인 데이터를 JSON으로 변환 중...');
  
  final celebrities = <Map<String, dynamic>>[];
  
  // accurateCelebrityData에서 각 셀러브리티 정보를 JSON 형태로 변환
  AccurateCelebrityDataProcessor.accurateCelebrityData.forEach((name, data) {
    final id = _generateId(data['category']!, name);
    
    celebrities.add({
      'id': id,
      'name': name,
      'name_en': '',
      'birth_date': data['birth_date']!,
      'birth_time': '12:00',
      'gender': data['gender']!,
      'birth_place': '',
      'category': data['category']!,
      'agency': '',
      'year_pillar': '',
      'month_pillar': '',
      'day_pillar': '',
      'hour_pillar': '',
      'saju_string': '',
      'wood_count': 0,
      'fire_count': 0,
      'earth_count': 0,
      'metal_count': 0,
      'water_count': 0,
      'full_saju_data': '',
      'data_source': 'accurate_manual',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  });
  
  print('📊 총 ${celebrities.length}명의 유명인 데이터 변환 완료');
  
  // JSON 파일로 저장
  final jsonFile = File('accurate_celebrities.json');
  await jsonFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(celebrities),
  );
  
  print('✅ JSON 파일 저장 완료: accurate_celebrities.json');
  print('📁 파일 크기: ${await jsonFile.length()} bytes');
}

String _generateId(String category, String name) {
  final cleanName = name
      .replaceAll(' ', '')
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('-', '_');
  return '${category}_$cleanName';
}