/// 리치 컨텐츠 타입
enum RichContentType {
  /// 이미지 + 텍스트 카드 (상단 이미지, 제목, 설명, 버튼)
  imageCard,

  /// 액션 버튼이 있는 카드 (제목, 설명, 버튼 행)
  actionCard,

  /// 캐러셀 (가로 스크롤 카드)
  carousel,

  /// 프로그레스/통계 카드 (아이콘 + 숫자 그리드)
  statsCard,

  /// 커스텀 위젯 (만세력, 차트 등 복잡한 UI)
  /// widgetType 필드로 어떤 위젯인지 지정
  customWidget,
}

/// 커스텀 위젯 타입
enum CustomWidgetType {
  /// 만세력 (사주팔자 차트)
  saju,

  /// 타로 카드 스프레드
  tarotSpread,

  /// 오행 차트
  fiveElements,

  /// 궁합 비교 차트
  compatibilityChart,

  /// 운세 그래프
  fortuneGraph,

  /// 감정 분석 차트
  emotionChart,
}

/// 리치 컨텐츠 액션 버튼
class RichContentAction {
  /// 액션 고유 ID
  final String id;

  /// 버튼 라벨
  final String label;

  /// 아이콘 이름 (lucide icon name, 선택적)
  final String? iconName;

  /// 딥링크 경로 (go_router 경로, 선택적)
  final String? deepLink;

  const RichContentAction({
    required this.id,
    required this.label,
    this.iconName,
    this.deepLink,
  });

  RichContentAction copyWith({
    String? id,
    String? label,
    String? iconName,
    String? deepLink,
  }) {
    return RichContentAction(
      id: id ?? this.id,
      label: label ?? this.label,
      iconName: iconName ?? this.iconName,
      deepLink: deepLink ?? this.deepLink,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'iconName': iconName,
        'deepLink': deepLink,
      };

  factory RichContentAction.fromJson(Map<String, dynamic> json) =>
      RichContentAction(
        id: json['id'] as String,
        label: json['label'] as String,
        iconName: json['iconName'] as String?,
        deepLink: json['deepLink'] as String?,
      );
}

/// 캐러셀 아이템 (carousel 타입에서 사용)
class CarouselItem {
  final String? imageUrl;
  final String? imageAsset;
  final String? title;
  final String? subtitle;
  final String? deepLink;

  const CarouselItem({
    this.imageUrl,
    this.imageAsset,
    this.title,
    this.subtitle,
    this.deepLink,
  });

  bool get hasImage =>
      (imageUrl?.isNotEmpty ?? false) || (imageAsset?.isNotEmpty ?? false);

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'imageAsset': imageAsset,
        'title': title,
        'subtitle': subtitle,
        'deepLink': deepLink,
      };

  factory CarouselItem.fromJson(Map<String, dynamic> json) => CarouselItem(
        imageUrl: json['imageUrl'] as String?,
        imageAsset: json['imageAsset'] as String?,
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
        deepLink: json['deepLink'] as String?,
      );
}

/// 통계 아이템 (statsCard 타입에서 사용)
class StatsItem {
  final String label;
  final String value;
  final String? iconName;
  final String? color; // hex color

  const StatsItem({
    required this.label,
    required this.value,
    this.iconName,
    this.color,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        'iconName': iconName,
        'color': color,
      };

  factory StatsItem.fromJson(Map<String, dynamic> json) => StatsItem(
        label: json['label'] as String,
        value: json['value'] as String,
        iconName: json['iconName'] as String?,
        color: json['color'] as String?,
      );
}

/// 리치 컨텐츠 데이터
class RichContentData {
  /// 컨텐츠 타입
  final RichContentType type;

  /// 제목
  final String? title;

  /// 부제목
  final String? subtitle;

  /// 설명 텍스트
  final String? description;

  /// 이미지 URL (네트워크)
  final String? imageUrl;

  /// 이미지 에셋 경로 (로컬)
  final String? imageAsset;

  /// 액션 버튼 목록
  final List<RichContentAction>? actions;

  /// 캐러셀 아이템 (carousel 타입에서 사용)
  final List<CarouselItem>? carouselItems;

  /// 통계 아이템 (statsCard 타입에서 사용)
  final List<StatsItem>? statsItems;

  /// 커스텀 위젯 타입 (customWidget 타입에서 사용)
  final CustomWidgetType? widgetType;

  /// 커스텀 위젯 데이터 (위젯별 구조화된 데이터)
  final Map<String, dynamic>? widgetData;

  /// 추가 메타데이터
  final Map<String, dynamic>? metadata;

  const RichContentData({
    required this.type,
    this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.imageAsset,
    this.actions,
    this.carouselItems,
    this.statsItems,
    this.widgetType,
    this.widgetData,
    this.metadata,
  });

  /// 이미지가 있는지 확인
  bool get hasImage =>
      (imageUrl?.isNotEmpty ?? false) || (imageAsset?.isNotEmpty ?? false);

  /// 이미지 경로 반환 (URL 우선)
  String? get imagePath => imageUrl ?? imageAsset;

  RichContentData copyWith({
    RichContentType? type,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? imageAsset,
    List<RichContentAction>? actions,
    List<CarouselItem>? carouselItems,
    List<StatsItem>? statsItems,
    CustomWidgetType? widgetType,
    Map<String, dynamic>? widgetData,
    Map<String, dynamic>? metadata,
  }) {
    return RichContentData(
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      actions: actions ?? this.actions,
      carouselItems: carouselItems ?? this.carouselItems,
      statsItems: statsItems ?? this.statsItems,
      widgetType: widgetType ?? this.widgetType,
      widgetData: widgetData ?? this.widgetData,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'imageUrl': imageUrl,
        'imageAsset': imageAsset,
        'actions': actions?.map((a) => a.toJson()).toList(),
        'carouselItems': carouselItems?.map((c) => c.toJson()).toList(),
        'statsItems': statsItems?.map((s) => s.toJson()).toList(),
        'widgetType': widgetType?.name,
        'widgetData': widgetData,
        'metadata': metadata,
      };

  factory RichContentData.fromJson(Map<String, dynamic> json) =>
      RichContentData(
        type: RichContentType.values.byName(json['type'] as String),
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        imageAsset: json['imageAsset'] as String?,
        actions: (json['actions'] as List<dynamic>?)
            ?.map((a) => RichContentAction.fromJson(a as Map<String, dynamic>))
            .toList(),
        carouselItems: (json['carouselItems'] as List<dynamic>?)
            ?.map((c) => CarouselItem.fromJson(c as Map<String, dynamic>))
            .toList(),
        statsItems: (json['statsItems'] as List<dynamic>?)
            ?.map((s) => StatsItem.fromJson(s as Map<String, dynamic>))
            .toList(),
        widgetType: json['widgetType'] != null
            ? CustomWidgetType.values.byName(json['widgetType'] as String)
            : null,
        widgetData: json['widgetData'] as Map<String, dynamic>?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  /// 이미지 카드 팩토리 생성자
  factory RichContentData.imageCard({
    required String title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? imageAsset,
    List<RichContentAction>? actions,
  }) =>
      RichContentData(
        type: RichContentType.imageCard,
        title: title,
        subtitle: subtitle,
        description: description,
        imageUrl: imageUrl,
        imageAsset: imageAsset,
        actions: actions,
      );

  /// 액션 카드 팩토리 생성자
  factory RichContentData.actionCard({
    required String title,
    String? description,
    required List<RichContentAction> actions,
  }) =>
      RichContentData(
        type: RichContentType.actionCard,
        title: title,
        description: description,
        actions: actions,
      );

  /// 캐러셀 팩토리 생성자
  factory RichContentData.carousel({
    String? title,
    required List<CarouselItem> items,
  }) =>
      RichContentData(
        type: RichContentType.carousel,
        title: title,
        carouselItems: items,
      );

  /// 통계 카드 팩토리 생성자
  factory RichContentData.statsCard({
    String? title,
    required List<StatsItem> stats,
  }) =>
      RichContentData(
        type: RichContentType.statsCard,
        title: title,
        statsItems: stats,
      );

  /// 커스텀 위젯 팩토리 생성자
  factory RichContentData.customWidget({
    required CustomWidgetType widgetType,
    required Map<String, dynamic> data,
    String? title,
  }) =>
      RichContentData(
        type: RichContentType.customWidget,
        widgetType: widgetType,
        widgetData: data,
        title: title,
      );

  /// 만세력(사주) 위젯 팩토리 생성자
  factory RichContentData.saju({
    required Map<String, dynamic> sajuData,
    String? title,
  }) =>
      RichContentData(
        type: RichContentType.customWidget,
        widgetType: CustomWidgetType.saju,
        widgetData: sajuData,
        title: title ?? '만세력',
      );

  /// 타로 스프레드 위젯 팩토리 생성자
  factory RichContentData.tarotSpread({
    required Map<String, dynamic> tarotData,
    String? title,
  }) =>
      RichContentData(
        type: RichContentType.customWidget,
        widgetType: CustomWidgetType.tarotSpread,
        widgetData: tarotData,
        title: title ?? '타로 리딩',
      );

  /// 오행 차트 위젯 팩토리 생성자
  factory RichContentData.fiveElements({
    required Map<String, dynamic> elementData,
    String? title,
  }) =>
      RichContentData(
        type: RichContentType.customWidget,
        widgetType: CustomWidgetType.fiveElements,
        widgetData: elementData,
        title: title ?? '오행 분석',
      );

  /// 궁합 차트 위젯 팩토리 생성자
  factory RichContentData.compatibilityChart({
    required Map<String, dynamic> compatibilityData,
    String? title,
  }) =>
      RichContentData(
        type: RichContentType.customWidget,
        widgetType: CustomWidgetType.compatibilityChart,
        widgetData: compatibilityData,
        title: title ?? '궁합 분석',
      );
}
