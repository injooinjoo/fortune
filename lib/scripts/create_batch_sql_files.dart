import 'dart:convert';
import 'dart:io';

void main() async {
  print('🚀 JSON 데이터를 배치 SQL 파일로 분할 중...');
  
  // JSON 파일 읽기
  final jsonFile = File('accurate_celebrities.json');
  final jsonContent = await jsonFile.readAsString();
  final List<dynamic> celebrities = jsonDecode(jsonContent);
  
  print('📊 총 ${celebrities.length}명의 유명인 데이터 로드됨');
  
  // 배치 크기 설정 (50명씩)
  const batchSize = 50;
  final totalBatches = (celebrities.length / batchSize).ceil();
  
  print('🔄 $totalBatches개의 배치 파일로 분할 예정...');
  
  for (int i = 0; i < totalBatches; i++) {
    final startIndex = i * batchSize;
    final endIndex = ((i + 1) * batchSize).clamp(0, celebrities.length);
    final batch = celebrities.sublist(startIndex, endIndex);
    
    final fileName = 'celebrities_batch_${i + 1}_of_$totalBatches.sql';
    await createBatchSQLFile(fileName, batch, i == 0);
    
    print('✅ 배치 ${i + 1}/$totalBatches 생성: $fileName (${batch.length}명)');
  }
  
  print('🎉 모든 배치 파일 생성 완료!');
  print('');
  print('📋 업로드 순서:');
  print('1. 먼저 celebrities_batch_1_of_$totalBatches.sql 실행 (테이블 생성 포함)');
  for (int i = 1; i < totalBatches; i++) {
    print('${i + 1}. celebrities_batch_${i + 1}_of_$totalBatches.sql 실행');
  }
}

Future<void> createBatchSQLFile(String fileName, List<dynamic> batch, bool includeTableCreation) async {
  final buffer = StringBuffer();
  
  if (includeTableCreation) {
    buffer.writeln('-- 배치 1: 테이블 생성 및 첫 번째 데이터 삽입');
    buffer.writeln('-- 정확한 유명인 데이터 테이블 생성');
    buffer.writeln('');
    buffer.writeln('-- 기존 테이블 삭제 (있다면)');
    buffer.writeln('DROP TABLE IF EXISTS public.celebrities CASCADE;');
    buffer.writeln('');
    buffer.writeln('-- 새 테이블 생성');
    buffer.writeln('CREATE TABLE public.celebrities (');
    buffer.writeln('    id TEXT PRIMARY KEY,');
    buffer.writeln('    name TEXT NOT NULL,');
    buffer.writeln('    name_en TEXT DEFAULT \'\',');
    buffer.writeln('    birth_date TEXT NOT NULL,');
    buffer.writeln('    birth_time TEXT DEFAULT \'12:00\',');
    buffer.writeln('    gender TEXT NOT NULL CHECK (gender IN (\'male\', \'female\', \'mixed\')),');
    buffer.writeln('    birth_place TEXT DEFAULT \'\',');
    buffer.writeln('    category TEXT NOT NULL CHECK (category IN (\'politician\', \'actor\', \'singer\', \'streamer\', \'business_leader\', \'entertainer\', \'athlete\')),');
    buffer.writeln('    agency TEXT DEFAULT \'\',');
    buffer.writeln('    year_pillar TEXT DEFAULT \'\',');
    buffer.writeln('    month_pillar TEXT DEFAULT \'\',');
    buffer.writeln('    day_pillar TEXT DEFAULT \'\',');
    buffer.writeln('    hour_pillar TEXT DEFAULT \'\',');
    buffer.writeln('    saju_string TEXT DEFAULT \'\',');
    buffer.writeln('    wood_count INTEGER DEFAULT 0,');
    buffer.writeln('    fire_count INTEGER DEFAULT 0,');
    buffer.writeln('    earth_count INTEGER DEFAULT 0,');
    buffer.writeln('    metal_count INTEGER DEFAULT 0,');
    buffer.writeln('    water_count INTEGER DEFAULT 0,');
    buffer.writeln('    full_saju_data TEXT DEFAULT \'\',');
    buffer.writeln('    data_source TEXT DEFAULT \'accurate_manual\',');
    buffer.writeln('    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE(\'utc\', NOW()),');
    buffer.writeln('    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE(\'utc\', NOW())');
    buffer.writeln(');');
    buffer.writeln('');
    buffer.writeln('-- 인덱스 생성');
    buffer.writeln('CREATE INDEX idx_celebrities_category ON public.celebrities(category);');
    buffer.writeln('CREATE INDEX idx_celebrities_name ON public.celebrities(name);');
    buffer.writeln('CREATE INDEX idx_celebrities_birth_date ON public.celebrities(birth_date);');
    buffer.writeln('CREATE INDEX idx_celebrities_gender ON public.celebrities(gender);');
    buffer.writeln('');
    buffer.writeln('-- RLS 활성화');
    buffer.writeln('ALTER TABLE public.celebrities ENABLE ROW LEVEL SECURITY;');
    buffer.writeln('');
    buffer.writeln('-- 공개 읽기 정책');
    buffer.writeln('CREATE POLICY "Anyone can view celebrities" ON public.celebrities');
    buffer.writeln('    FOR SELECT USING (true);');
    buffer.writeln('');
  } else {
    buffer.writeln('-- 배치 데이터 삽입 (${batch.length}명)');
    buffer.writeln('');
  }
  
  buffer.writeln('-- 데이터 삽입');
  buffer.writeln('INSERT INTO public.celebrities (');
  buffer.writeln('    id, name, name_en, birth_date, birth_time, gender, birth_place,');
  buffer.writeln('    category, agency, year_pillar, month_pillar, day_pillar, hour_pillar,');
  buffer.writeln('    saju_string, wood_count, fire_count, earth_count, metal_count, water_count,');
  buffer.writeln('    full_saju_data, data_source, created_at, updated_at');
  buffer.writeln(') VALUES');
  
  for (int i = 0; i < batch.length; i++) {
    final celebrity = batch[i];
    final comma = i < batch.length - 1 ? ',' : ';';
    
    buffer.writeln('(');
    buffer.writeln('    \'${_escape(celebrity['id'])}\',');
    buffer.writeln('    \'${_escape(celebrity['name'])}\',');
    buffer.writeln('    \'${_escape(celebrity['name_en'])}\',');
    buffer.writeln('    \'${_escape(celebrity['birth_date'])}\',');
    buffer.writeln('    \'${_escape(celebrity['birth_time'])}\',');
    buffer.writeln('    \'${_escape(celebrity['gender'])}\',');
    buffer.writeln('    \'${_escape(celebrity['birth_place'])}\',');
    buffer.writeln('    \'${_escape(celebrity['category'])}\',');
    buffer.writeln('    \'${_escape(celebrity['agency'])}\',');
    buffer.writeln('    \'${_escape(celebrity['year_pillar'])}\',');
    buffer.writeln('    \'${_escape(celebrity['month_pillar'])}\',');
    buffer.writeln('    \'${_escape(celebrity['day_pillar'])}\',');
    buffer.writeln('    \'${_escape(celebrity['hour_pillar'])}\',');
    buffer.writeln('    \'${_escape(celebrity['saju_string'])}\',');
    buffer.writeln('    ${celebrity['wood_count']},');
    buffer.writeln('    ${celebrity['fire_count']},');
    buffer.writeln('    ${celebrity['earth_count']},');
    buffer.writeln('    ${celebrity['metal_count']},');
    buffer.writeln('    ${celebrity['water_count']},');
    buffer.writeln('    \'${_escape(celebrity['full_saju_data'])}\',');
    buffer.writeln('    \'${_escape(celebrity['data_source'])}\',');
    buffer.writeln('    \'${_escape(celebrity['created_at'])}\',');
    buffer.writeln('    \'${_escape(celebrity['updated_at'])}\'');
    buffer.writeln(')$comma');
  }
  
  final file = File(fileName);
  await file.writeAsString(buffer.toString());
}

String _escape(String value) {
  return value.replaceAll("'", "''");
}