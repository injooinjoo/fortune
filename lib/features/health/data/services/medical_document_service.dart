import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/medical_document_models.dart';
import '../../../../core/utils/logger.dart';

/// 건강 문서 분석 서비스
///
/// 건강검진표/처방전/진단서 이미지를 GPT-4 Vision으로 분석하여
/// 검사 항목 해석과 사주 기반 건강 조언을 제공합니다.
class MedicalDocumentService {
  static final MedicalDocumentService _instance = MedicalDocumentService._internal();
  factory MedicalDocumentService() => _instance;
  MedicalDocumentService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// 건강 문서 분석
  ///
  /// [uploadResult]: 업로드된 문서 정보 (Base64 이미지, 문서 유형)
  /// [birthDate]: 생년월일 (사주 분석용)
  /// [birthTime]: 출생 시간 (사주 분석용)
  /// [gender]: 성별
  Future<MedicalDocumentAnalysisResult> analyzeDocument({
    required MedicalDocumentUploadResult uploadResult,
    String? birthDate,
    String? birthTime,
    String? gender,
  }) async {
    Logger.info('[MedicalDocumentService] 문서 분석 시작');
    Logger.info('   - documentType: ${uploadResult.documentType.name}');
    Logger.info('   - imageSize: ${uploadResult.base64Data?.length ?? 0} bytes');
    Logger.info('   - hasBirthDate: ${birthDate != null}');

    try {
      // 사용자 ID 가져오기
      final userId = _supabase.auth.currentUser?.id ?? 'anonymous';

      // API Payload 구성
      final payload = {
        'userId': userId,
        'documentType': uploadResult.documentType.apiValue,
        'documentImage': uploadResult.base64Data,
        if (birthDate != null) 'birthDate': birthDate,
        if (birthTime != null) 'birthTime': birthTime,
        if (gender != null) 'gender': gender,
      };

      Logger.info('[MedicalDocumentService] Edge Function 호출 시작');

      // Edge Function 호출
      final response = await _supabase.functions.invoke(
        'fortune-health-document',
        body: payload,
      );

      if (response.status != 200) {
        final errorMessage = response.data is Map
            ? (response.data as Map)['error'] ?? 'API 호출 실패'
            : 'API 호출 실패: ${response.status}';
        throw Exception(errorMessage);
      }

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] != true) {
        throw Exception(responseData['error'] ?? '문서 분석 실패');
      }

      final data = responseData['data'] as Map<String, dynamic>;

      Logger.info('[MedicalDocumentService] 응답 파싱 시작');

      // 응답 데이터 파싱
      final result = _parseAnalysisResult(data, uploadResult.documentType);

      Logger.info('[MedicalDocumentService] 문서 분석 완료');
      Logger.info('   - healthScore: ${result.healthScore}');
      Logger.info('   - testCategories: ${result.testResults.length}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[MedicalDocumentService] 문서 분석 실패', e, stackTrace);
      rethrow;
    }
  }

  /// API 응답을 MedicalDocumentAnalysisResult로 변환
  MedicalDocumentAnalysisResult _parseAnalysisResult(
    Map<String, dynamic> data,
    MedicalDocumentType documentType,
  ) {
    // DocumentAnalysis 파싱
    final documentAnalysisData = data['documentAnalysis'] as Map<String, dynamic>?;
    final documentAnalysis = documentAnalysisData != null
        ? DocumentAnalysis(
            documentType: documentAnalysisData['documentType'] as String? ?? documentType.displayName,
            documentDate: documentAnalysisData['documentDate'] as String?,
            institution: documentAnalysisData['institution'] as String?,
            summary: documentAnalysisData['summary'] as String? ?? '',
          )
        : DocumentAnalysis(
            documentType: documentType.displayName,
            summary: '문서 분석 결과',
          );

    // TestResults 파싱
    final testResultsData = data['testResults'] as List<dynamic>? ?? [];
    final testResults = testResultsData.map((categoryData) {
      final category = categoryData as Map<String, dynamic>;
      final itemsData = category['items'] as List<dynamic>? ?? [];

      return TestCategory(
        category: category['category'] as String? ?? '기타',
        items: itemsData.map((itemData) {
          final item = itemData as Map<String, dynamic>;
          return TestItem(
            name: item['name'] as String? ?? '',
            value: item['value'] as String? ?? '',
            unit: item['unit'] as String? ?? '',
            status: _parseTestItemStatus(item['status'] as String?),
            normalRange: item['normalRange'] as String? ?? '',
            interpretation: item['interpretation'] as String? ?? '',
          );
        }).toList(),
      );
    }).toList();

    // SajuHealthAnalysis 파싱
    final sajuData = data['sajuHealthAnalysis'] as Map<String, dynamic>?;
    final sajuHealthAnalysis = sajuData != null
        ? SajuHealthAnalysis(
            dominantElement: sajuData['dominantElement'] as String? ?? '목',
            weakElement: sajuData['weakElement'] as String? ?? '금',
            elementDescription: sajuData['elementDescription'] as String? ?? '',
            vulnerableOrgans: _parseStringList(sajuData['vulnerableOrgans']),
            strengthOrgans: _parseStringList(sajuData['strengthOrgans']),
            sajuAdvice: sajuData['sajuAdvice'] as String? ?? '',
          )
        : const SajuHealthAnalysis(
            dominantElement: '목',
            weakElement: '금',
            elementDescription: '오행 균형 분석',
            vulnerableOrgans: [],
            strengthOrgans: [],
            sajuAdvice: '사주 기반 건강 조언',
          );

    // HealthRecommendations 파싱
    final recommendationsData = data['recommendations'] as Map<String, dynamic>?;
    final recommendations = recommendationsData != null
        ? HealthRecommendations(
            urgent: _parseStringList(recommendationsData['urgent']),
            general: _parseStringList(recommendationsData['general']),
            lifestyle: _parseStringList(recommendationsData['lifestyle']),
          )
        : const HealthRecommendations(
            urgent: [],
            general: [],
            lifestyle: [],
          );

    // HealthRegimen 파싱
    final regimenData = data['healthRegimen'] as Map<String, dynamic>?;
    final healthRegimen = regimenData != null
        ? HealthRegimen(
            diet: _parseDietAdvice(regimenData['diet']),
            exercise: _parseExerciseAdvice(regimenData['exercise']),
            lifestyle: _parseStringList(regimenData['lifestyle']),
          )
        : const HealthRegimen(
            diet: [],
            exercise: [],
            lifestyle: [],
          );

    return MedicalDocumentAnalysisResult(
      id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fortuneType: 'health-document',
      documentAnalysis: documentAnalysis,
      testResults: testResults,
      sajuAnalysis: sajuHealthAnalysis,
      healthScore: data['healthScore'] as int? ?? 70,
      recommendations: recommendations,
      healthRegimen: healthRegimen,
      timestamp: DateTime.tryParse(data['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  TestItemStatus _parseTestItemStatus(String? status) {
    switch (status) {
      case 'normal':
        return TestItemStatus.normal;
      case 'caution':
        return TestItemStatus.caution;
      case 'warning':
        return TestItemStatus.warning;
      case 'critical':
        return TestItemStatus.critical;
      default:
        return TestItemStatus.normal;
    }
  }

  List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  List<DietAdvice> _parseDietAdvice(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return DietAdvice(
        type: map['type'] as String? ?? 'recommend',
        items: _parseStringList(map['items']),
        reason: map['reason'] as String? ?? '',
      );
    }).toList();
  }

  List<ExerciseAdvice> _parseExerciseAdvice(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return ExerciseAdvice(
        type: map['type'] as String? ?? '운동',
        frequency: map['frequency'] as String? ?? '',
        duration: map['duration'] as String? ?? '',
        benefit: map['benefit'] as String? ?? '',
      );
    }).toList();
  }
}
