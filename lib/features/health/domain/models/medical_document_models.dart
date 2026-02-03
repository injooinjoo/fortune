// 의료 문서 분석 관련 모델들
import 'dart:io';
import 'package:flutter/material.dart';

/// 의료 문서 유형
enum MedicalDocumentType {
  checkup('건강검진표', 'checkup', '정기 건강검진 결과'),
  prescription('처방전', 'prescription', '의사 처방 약물 정보'),
  diagnosis('진단서', 'diagnosis', '질환 진단 및 소견서');

  const MedicalDocumentType(this.displayName, this.apiValue, this.description);
  final String displayName;
  final String apiValue;
  final String description;
}

/// 의료 문서 업로드 결과
class MedicalDocumentUploadResult {
  final MedicalDocumentType documentType;
  final File? file;
  final String? base64Data;
  final String mimeType;
  final String? fileName;
  final int? fileSizeBytes;

  const MedicalDocumentUploadResult({
    required this.documentType,
    this.file,
    this.base64Data,
    required this.mimeType,
    this.fileName,
    this.fileSizeBytes,
  });

  bool get isValid => base64Data != null && base64Data!.isNotEmpty;

  String get fileSizeDisplay {
    if (fileSizeBytes == null) return '';
    if (fileSizeBytes! < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes! < 1024 * 1024) return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 검사 항목 상태
enum TestItemStatus {
  normal('정상', Color(0xFF4CAF50), '정상 범위 내'), // 고유 색상 - 의료 정상
  caution('주의', Color(0xFFFF9800), '경계 수준'), // 고유 색상 - 의료 주의
  warning('경고', Color(0xFFFF5722), '관리 필요'), // 고유 색상 - 의료 경고
  critical('위험', Color(0xFFF44336), '즉시 조치 필요'); // 고유 색상 - 의료 위험

  const TestItemStatus(this.displayName, this.color, this.description);
  final String displayName;
  final Color color;
  final String description;

  static TestItemStatus fromString(String value) {
    return TestItemStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TestItemStatus.normal,
    );
  }
}

/// 검사 항목
class TestItem {
  final String name;
  final String value;
  final String unit;
  final TestItemStatus status;
  final String normalRange;
  final String interpretation;

  const TestItem({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.normalRange,
    required this.interpretation,
  });

  factory TestItem.fromJson(Map<String, dynamic> json) {
    return TestItem(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
      status: TestItemStatus.fromString(json['status'] ?? 'normal'),
      normalRange: json['normalRange'] ?? json['normal_range'] ?? '',
      interpretation: json['interpretation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'status': status.name,
    'normalRange': normalRange,
    'interpretation': interpretation,
  };
}

/// 검사 카테고리
class TestCategory {
  final String category;
  final List<TestItem> items;

  const TestCategory({
    required this.category,
    required this.items,
  });

  factory TestCategory.fromJson(Map<String, dynamic> json) {
    return TestCategory(
      category: json['category'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => TestItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'items': items.map((e) => e.toJson()).toList(),
  };

  /// 카테고리 내 주의/경고 항목 수
  int get cautionCount => items.where((e) =>
    e.status == TestItemStatus.caution ||
    e.status == TestItemStatus.warning ||
    e.status == TestItemStatus.critical
  ).length;
}

/// 사주 건강 분석
class SajuHealthAnalysis {
  final String dominantElement;
  final String weakElement;
  final String elementDescription;
  final List<String> vulnerableOrgans;
  final List<String> strengthOrgans;
  final String sajuAdvice;

  const SajuHealthAnalysis({
    required this.dominantElement,
    required this.weakElement,
    required this.elementDescription,
    required this.vulnerableOrgans,
    required this.strengthOrgans,
    required this.sajuAdvice,
  });

  factory SajuHealthAnalysis.fromJson(Map<String, dynamic> json) {
    final elementBalance = json['elementBalance'] ?? json;
    return SajuHealthAnalysis(
      dominantElement: elementBalance['dominant'] ?? json['dominantElement'] ?? '',
      weakElement: elementBalance['weak'] ?? json['weakElement'] ?? '',
      elementDescription: elementBalance['description'] ?? json['elementDescription'] ?? '',
      vulnerableOrgans: List<String>.from(json['vulnerableOrgans'] ?? []),
      strengthOrgans: List<String>.from(json['strengthOrgans'] ?? []),
      sajuAdvice: json['sajuAdvice'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'dominantElement': dominantElement,
    'weakElement': weakElement,
    'elementDescription': elementDescription,
    'vulnerableOrgans': vulnerableOrgans,
    'strengthOrgans': strengthOrgans,
    'sajuAdvice': sajuAdvice,
  };
}

/// 건강 권장사항
class HealthRecommendations {
  final List<String> urgent;
  final List<String> general;
  final List<String> lifestyle;

  const HealthRecommendations({
    required this.urgent,
    required this.general,
    required this.lifestyle,
  });

  factory HealthRecommendations.fromJson(Map<String, dynamic> json) {
    return HealthRecommendations(
      urgent: List<String>.from(json['urgent'] ?? []),
      general: List<String>.from(json['general'] ?? []),
      lifestyle: List<String>.from(json['lifestyle'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'urgent': urgent,
    'general': general,
    'lifestyle': lifestyle,
  };

  bool get hasUrgent => urgent.isNotEmpty;
}

/// 식이 조언
class DietAdvice {
  final String type; // 'recommend' | 'avoid'
  final List<String> items;
  final String reason;

  const DietAdvice({
    required this.type,
    required this.items,
    required this.reason,
  });

  factory DietAdvice.fromJson(Map<String, dynamic> json) {
    return DietAdvice(
      type: json['type'] ?? 'recommend',
      items: List<String>.from(json['items'] ?? []),
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'items': items,
    'reason': reason,
  };

  bool get isRecommend => type == 'recommend';
}

/// 운동 조언
class ExerciseAdvice {
  final String type;
  final String frequency;
  final String duration;
  final String benefit;

  const ExerciseAdvice({
    required this.type,
    required this.frequency,
    required this.duration,
    required this.benefit,
  });

  factory ExerciseAdvice.fromJson(Map<String, dynamic> json) {
    return ExerciseAdvice(
      type: json['type'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      benefit: json['benefit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'frequency': frequency,
    'duration': duration,
    'benefit': benefit,
  };
}

/// 양생법
class HealthRegimen {
  final List<DietAdvice> diet;
  final List<ExerciseAdvice> exercise;
  final List<String> lifestyle;

  const HealthRegimen({
    required this.diet,
    required this.exercise,
    required this.lifestyle,
  });

  factory HealthRegimen.fromJson(Map<String, dynamic> json) {
    return HealthRegimen(
      diet: (json['diet'] as List<dynamic>?)
          ?.map((e) => DietAdvice.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      exercise: (json['exercise'] as List<dynamic>?)
          ?.map((e) => ExerciseAdvice.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      lifestyle: List<String>.from(json['lifestyle'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'diet': diet.map((e) => e.toJson()).toList(),
    'exercise': exercise.map((e) => e.toJson()).toList(),
    'lifestyle': lifestyle,
  };
}

/// 문서 분석 정보
class DocumentAnalysis {
  final String documentType;
  final String? documentDate;
  final String? institution;
  final String summary;

  const DocumentAnalysis({
    required this.documentType,
    this.documentDate,
    this.institution,
    required this.summary,
  });

  factory DocumentAnalysis.fromJson(Map<String, dynamic> json) {
    return DocumentAnalysis(
      documentType: json['documentType'] ?? json['document_type'] ?? '',
      documentDate: json['documentDate'] ?? json['document_date'],
      institution: json['institution'],
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'documentType': documentType,
    'documentDate': documentDate,
    'institution': institution,
    'summary': summary,
  };
}

/// 의료 문서 분석 결과
class MedicalDocumentAnalysisResult {
  final String id;
  final String fortuneType;
  final DocumentAnalysis documentAnalysis;
  final List<TestCategory> testResults;
  final SajuHealthAnalysis sajuAnalysis;
  final int healthScore;
  final HealthRecommendations recommendations;
  final HealthRegimen healthRegimen;
  final DateTime timestamp;
  final bool isBlurred;
  final List<String> blurredSections;

  const MedicalDocumentAnalysisResult({
    required this.id,
    required this.fortuneType,
    required this.documentAnalysis,
    required this.testResults,
    required this.sajuAnalysis,
    required this.healthScore,
    required this.recommendations,
    required this.healthRegimen,
    required this.timestamp,
    this.isBlurred = false,
    this.blurredSections = const [],
  });

  factory MedicalDocumentAnalysisResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return MedicalDocumentAnalysisResult(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fortuneType: data['fortuneType'] ?? 'health-document',
      documentAnalysis: DocumentAnalysis.fromJson(data['documentAnalysis'] ?? {}),
      testResults: (data['testResults'] as List<dynamic>?)
          ?.map((e) => TestCategory.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      sajuAnalysis: SajuHealthAnalysis.fromJson(data['sajuHealthAnalysis'] ?? data['sajuAnalysis'] ?? {}),
      healthScore: data['healthScore'] ?? 70,
      recommendations: HealthRecommendations.fromJson(data['recommendations'] ?? {}),
      healthRegimen: HealthRegimen.fromJson(data['healthRegimen'] ?? {}),
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      isBlurred: data['isBlurred'] ?? false,
      blurredSections: List<String>.from(data['blurredSections'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fortuneType': fortuneType,
    'documentAnalysis': documentAnalysis.toJson(),
    'testResults': testResults.map((e) => e.toJson()).toList(),
    'sajuAnalysis': sajuAnalysis.toJson(),
    'healthScore': healthScore,
    'recommendations': recommendations.toJson(),
    'healthRegimen': healthRegimen.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'isBlurred': isBlurred,
    'blurredSections': blurredSections,
  };

  /// 총 검사 항목 수
  int get totalTestItems => testResults.fold(0, (sum, cat) => sum + cat.items.length);

  /// 주의/경고 항목 수
  int get cautionItemCount => testResults.fold(0, (sum, cat) => sum + cat.cautionCount);

  /// 건강 점수 등급
  String get scoreGrade {
    if (healthScore >= 90) return '매우 좋음';
    if (healthScore >= 70) return '양호';
    if (healthScore >= 50) return '주의';
    return '관리 필요';
  }

  /// 건강 점수 색상
  Color get scoreColor {
    if (healthScore >= 90) return const Color(0xFF4CAF50); // 고유 색상 - 건강 매우좋음
    if (healthScore >= 70) return const Color(0xFF2196F3); // 고유 색상 - 건강 양호
    if (healthScore >= 50) return const Color(0xFFFF9800); // 고유 색상 - 건강 주의
    return const Color(0xFFF44336); // 고유 색상 - 건강 관리필요
  }
}
