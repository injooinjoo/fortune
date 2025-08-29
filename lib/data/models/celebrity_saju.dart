class CelebritySaju {
  final String id;
  final String name;
  final String nameEn;
  final String birthDate;
  final String birthTime;
  final String gender;
  final String birthPlace;
  final String category;
  final String agency;
  
  // 사주 기둥들
  final String yearPillar;
  final String monthPillar;
  final String dayPillar;
  final String hourPillar;
  final String sajuString;
  
  // 오행 개수
  final int woodCount;
  final int fireCount;
  final int earthCount;
  final int metalCount;
  final int waterCount;
  
  // 전체 사주 데이터
  final Map<String, dynamic>? fullSajuData;
  final String dataSource;
  final DateTime createdAt;
  final DateTime updatedAt;

  CelebritySaju({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.birthDate,
    required this.birthTime,
    required this.gender,
    required this.birthPlace,
    required this.category,
    required this.agency,
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    required this.hourPillar,
    required this.sajuString,
    required this.woodCount,
    required this.fireCount,
    required this.earthCount,
    required this.metalCount,
    required this.waterCount,
    this.fullSajuData,
    required this.dataSource,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CelebritySaju.fromJson(Map<String, dynamic> json) {
    return CelebritySaju(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      birthDate: json['birth_date'] ?? '',
      birthTime: json['birth_time'] ?? '',
      gender: json['gender'] ?? '',
      birthPlace: json['birth_place'] ?? '',
      category: json['category'] ?? '',
      agency: json['agency'] ?? '',
      yearPillar: json['year_pillar'] ?? '',
      monthPillar: json['month_pillar'] ?? '',
      dayPillar: json['day_pillar'] ?? '',
      hourPillar: json['hour_pillar'] ?? '',
      sajuString: json['saju_string'] ?? '',
      woodCount: json['wood_count']?.toInt() ?? 0,
      fireCount: json['fire_count']?.toInt() ?? 0,
      earthCount: json['earth_count']?.toInt() ?? 0,
      metalCount: json['metal_count']?.toInt() ?? 0,
      waterCount: json['water_count']?.toInt() ?? 0,
      fullSajuData: json['full_saju_data'],
      dataSource: json['data_source'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'gender': gender,
      'birth_place': birthPlace,
      'category': category,
      'agency': agency,
      'year_pillar': yearPillar,
      'month_pillar': monthPillar,
      'day_pillar': dayPillar,
      'hour_pillar': hourPillar,
      'saju_string': sajuString,
      'wood_count': woodCount,
      'fire_count': fireCount,
      'earth_count': earthCount,
      'metal_count': metalCount,
      'water_count': waterCount,
      'full_saju_data': fullSajuData,
      'data_source': dataSource,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 나이 계산
  int get age {
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  /// 주요 오행 (가장 많은 오행)
  String get dominantElement {
    final elements = {
      '목': woodCount,
      '화': fireCount,
      '토': earthCount,
      '금': metalCount,
      '수': waterCount,
    };
    
    final maxEntry = elements.entries.reduce((a, b) => a.value > b.value ? a : b);
    return maxEntry.key;
  }

  /// 오행 분포 (백분율)
  Map<String, double> get elementDistribution {
    final total = woodCount + fireCount + earthCount + metalCount + waterCount;
    if (total == 0) return {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};
    
    return {
      '목': (woodCount / total * 100).roundToDouble(),
      '화': (fireCount / total * 100).roundToDouble(),
      '토': (earthCount / total * 100).roundToDouble(),
      '금': (metalCount / total * 100).roundToDouble(),
      '수': (waterCount / total * 100).roundToDouble(),
    };
  }

  /// 십신 정보 (fullSajuData에서 추출)
  Map<String, dynamic>? get tenGods {
    return fullSajuData?['tenGods'];
  }

  /// 대운 정보 (fullSajuData에서 추출)  
  Map<String, dynamic>? get daeunInfo {
    return fullSajuData?['daeunInfo'];
  }

  /// 현재 대운 나이대
  String get currentDaeunPeriod {
    final daeun = daeunInfo;
    if (daeun == null) return '정보 없음';
    
    final startAge = daeun['startAge']?.toString() ?? '';
    final endAge = daeun['endAge']?.toString() ?? '';
    return '$startAge-${endAge}세';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CelebritySaju && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CelebritySaju{name: $name, category: $category, sajuString: $sajuString}';
  }
}