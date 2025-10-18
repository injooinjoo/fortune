/// 캐시된 운세 결과 모델 (최적화 시스템 전용)
///
/// fortune_results 테이블의 데이터를 담는 클래스
class CachedFortuneResult {
  /// DB ID
  final String id;

  /// 사용자 ID
  final String userId;

  /// 운세 종류
  final String fortuneType;

  /// 결과 데이터 (JSON)
  final Map<String, dynamic> resultData;

  /// 조건 해시
  final String conditionsHash;

  /// 조건 데이터
  final Map<String, dynamic> conditionsData;

  /// 생성 시간
  final DateTime createdAt;

  /// 수정 시간
  final DateTime updatedAt;

  /// 결과 소스
  /// - 'api': OpenAI API 호출
  /// - 'personal_cache': 개인 캐시에서 조회
  /// - 'db_pool': DB 풀에서 랜덤 선택 (1000개 이상)
  /// - 'random_selection': DB에서 30% 확률 랜덤 선택
  final String source;

  /// API 호출 여부
  final bool apiCall;

  const CachedFortuneResult({
    required this.id,
    required this.userId,
    required this.fortuneType,
    required this.resultData,
    required this.conditionsHash,
    required this.conditionsData,
    required this.createdAt,
    required this.updatedAt,
    this.source = 'api',
    this.apiCall = true,
  });

  /// DB JSON에서 생성
  factory CachedFortuneResult.fromJson(Map<String, dynamic> json) {
    return CachedFortuneResult(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fortuneType: json['fortune_type'] as String,
      resultData: Map<String, dynamic>.from(json['result_data'] as Map),
      conditionsHash: json['conditions_hash'] as String,
      conditionsData: Map<String, dynamic>.from(json['conditions_data'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      source: json['source'] as String? ?? 'api',
      apiCall: json['api_call'] as bool? ?? true,
    );
  }

  /// DB 저장용 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fortune_type': fortuneType,
      'result_data': resultData,
      'conditions_hash': conditionsHash,
      'conditions_data': conditionsData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'source': source,
      'api_call': apiCall,
    };
  }

  /// 결과 복사
  CachedFortuneResult copyWith({
    String? id,
    String? userId,
    String? fortuneType,
    Map<String, dynamic>? resultData,
    String? conditionsHash,
    Map<String, dynamic>? conditionsData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    bool? apiCall,
  }) {
    return CachedFortuneResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fortuneType: fortuneType ?? this.fortuneType,
      resultData: resultData ?? this.resultData,
      conditionsHash: conditionsHash ?? this.conditionsHash,
      conditionsData: conditionsData ?? this.conditionsData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      apiCall: apiCall ?? this.apiCall,
    );
  }

  /// 캐시된 결과인지 확인
  bool get isCached => !apiCall;

  /// 소스 표시 문자열
  String get sourceLabel {
    switch (source) {
      case 'personal_cache':
        return '개인 캐시';
      case 'db_pool':
        return 'DB 풀';
      case 'random_selection':
        return '랜덤 선택';
      case 'api':
      default:
        return 'API 호출';
    }
  }

  /// 디버그 표시
  @override
  String toString() {
    return 'CachedFortuneResult(fortuneType: $fortuneType, source: $source, apiCall: $apiCall, created: $createdAt)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedFortuneResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
