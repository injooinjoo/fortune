// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_saju_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PremiumSajuResultImpl _$$PremiumSajuResultImplFromJson(
        Map<String, dynamic> json) =>
    _$PremiumSajuResultImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      birthDateTime: DateTime.parse(json['birthDateTime'] as String),
      isLunar: json['isLunar'] as bool? ?? false,
      gender: json['gender'] as String,
      pillars: SajuPillars.fromJson(json['pillars'] as Map<String, dynamic>),
      elements: ElementDistribution.fromJson(
          json['elements'] as Map<String, dynamic>),
      formatAnalysis: FormatAnalysis.fromJson(
          json['formatAnalysis'] as Map<String, dynamic>),
      yongshinAnalysis: YongshinAnalysis.fromJson(
          json['yongshinAnalysis'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => PremiumChapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      purchaseInfo:
          PurchaseInfo.fromJson(json['purchaseInfo'] as Map<String, dynamic>),
      generationStatus: GenerationStatus.fromJson(
          json['generationStatus'] as Map<String, dynamic>),
      readingProgress: json['readingProgress'] == null
          ? null
          : ReadingProgress.fromJson(
              json['readingProgress'] as Map<String, dynamic>),
      bookmarks: (json['bookmarks'] as List<dynamic>?)
              ?.map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PremiumSajuResultImplToJson(
        _$PremiumSajuResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'birthDateTime': instance.birthDateTime.toIso8601String(),
      'isLunar': instance.isLunar,
      'gender': instance.gender,
      'pillars': instance.pillars,
      'elements': instance.elements,
      'formatAnalysis': instance.formatAnalysis,
      'yongshinAnalysis': instance.yongshinAnalysis,
      'chapters': instance.chapters,
      'purchaseInfo': instance.purchaseInfo,
      'generationStatus': instance.generationStatus,
      'readingProgress': instance.readingProgress,
      'bookmarks': instance.bookmarks,
    };

_$SajuPillarsImpl _$$SajuPillarsImplFromJson(Map<String, dynamic> json) =>
    _$SajuPillarsImpl(
      yearPillar: Pillar.fromJson(json['yearPillar'] as Map<String, dynamic>),
      monthPillar: Pillar.fromJson(json['monthPillar'] as Map<String, dynamic>),
      dayPillar: Pillar.fromJson(json['dayPillar'] as Map<String, dynamic>),
      hourPillar: Pillar.fromJson(json['hourPillar'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SajuPillarsImplToJson(_$SajuPillarsImpl instance) =>
    <String, dynamic>{
      'yearPillar': instance.yearPillar,
      'monthPillar': instance.monthPillar,
      'dayPillar': instance.dayPillar,
      'hourPillar': instance.hourPillar,
    };

_$PillarImpl _$$PillarImplFromJson(Map<String, dynamic> json) => _$PillarImpl(
      heavenlyStem: json['heavenlyStem'] as String,
      earthlyBranch: json['earthlyBranch'] as String,
      element: json['element'] as String,
      yinYang: json['yinYang'] as String,
      hiddenStems: json['hiddenStems'] as String?,
    );

Map<String, dynamic> _$$PillarImplToJson(_$PillarImpl instance) =>
    <String, dynamic>{
      'heavenlyStem': instance.heavenlyStem,
      'earthlyBranch': instance.earthlyBranch,
      'element': instance.element,
      'yinYang': instance.yinYang,
      'hiddenStems': instance.hiddenStems,
    };

_$ElementDistributionImpl _$$ElementDistributionImplFromJson(
        Map<String, dynamic> json) =>
    _$ElementDistributionImpl(
      wood: (json['wood'] as num).toInt(),
      fire: (json['fire'] as num).toInt(),
      earth: (json['earth'] as num).toInt(),
      metal: (json['metal'] as num).toInt(),
      water: (json['water'] as num).toInt(),
      dominant: json['dominant'] as String,
      lacking: json['lacking'] as String,
    );

Map<String, dynamic> _$$ElementDistributionImplToJson(
        _$ElementDistributionImpl instance) =>
    <String, dynamic>{
      'wood': instance.wood,
      'fire': instance.fire,
      'earth': instance.earth,
      'metal': instance.metal,
      'water': instance.water,
      'dominant': instance.dominant,
      'lacking': instance.lacking,
    };

_$FormatAnalysisImpl _$$FormatAnalysisImplFromJson(Map<String, dynamic> json) =>
    _$FormatAnalysisImpl(
      format: json['format'] as String,
      formatType: json['formatType'] as String,
      strength: json['strength'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$FormatAnalysisImplToJson(
        _$FormatAnalysisImpl instance) =>
    <String, dynamic>{
      'format': instance.format,
      'formatType': instance.formatType,
      'strength': instance.strength,
      'description': instance.description,
    };

_$YongshinAnalysisImpl _$$YongshinAnalysisImplFromJson(
        Map<String, dynamic> json) =>
    _$YongshinAnalysisImpl(
      yongshin: json['yongshin'] as String,
      heeshin: json['heeshin'] as String,
      gishin: json['gishin'] as String,
      chousin: json['chousin'] as String,
      method: json['method'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$YongshinAnalysisImplToJson(
        _$YongshinAnalysisImpl instance) =>
    <String, dynamic>{
      'yongshin': instance.yongshin,
      'heeshin': instance.heeshin,
      'gishin': instance.gishin,
      'chousin': instance.chousin,
      'method': instance.method,
      'description': instance.description,
    };

_$PremiumChapterImpl _$$PremiumChapterImplFromJson(Map<String, dynamic> json) =>
    _$PremiumChapterImpl(
      id: json['id'] as String,
      partNumber: (json['partNumber'] as num).toInt(),
      chapterNumber: (json['chapterNumber'] as num).toInt(),
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '',
      status: $enumDecode(_$ChapterStatusEnumMap, json['status']),
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => PremiumSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      estimatedPages: (json['estimatedPages'] as num?)?.toInt() ?? 0,
      actualWordCount: (json['actualWordCount'] as num?)?.toInt() ?? 0,
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$PremiumChapterImplToJson(
        _$PremiumChapterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'partNumber': instance.partNumber,
      'chapterNumber': instance.chapterNumber,
      'title': instance.title,
      'emoji': instance.emoji,
      'status': _$ChapterStatusEnumMap[instance.status]!,
      'sections': instance.sections,
      'estimatedPages': instance.estimatedPages,
      'actualWordCount': instance.actualWordCount,
      'generatedAt': instance.generatedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$ChapterStatusEnumMap = {
  ChapterStatus.pending: 'pending',
  ChapterStatus.generating: 'generating',
  ChapterStatus.completed: 'completed',
  ChapterStatus.error: 'error',
};

_$PremiumSectionImpl _$$PremiumSectionImplFromJson(Map<String, dynamic> json) =>
    _$PremiumSectionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$SectionTypeEnumMap, json['type']),
      content: json['content'] as String? ?? '',
      subsectionTitles: (json['subsectionTitles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isGenerated: json['isGenerated'] as bool? ?? false,
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$PremiumSectionImplToJson(
        _$PremiumSectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _$SectionTypeEnumMap[instance.type]!,
      'content': instance.content,
      'subsectionTitles': instance.subsectionTitles,
      'isGenerated': instance.isGenerated,
      'generatedAt': instance.generatedAt?.toIso8601String(),
    };

const _$SectionTypeEnumMap = {
  SectionType.template: 'template',
  SectionType.llm: 'llm',
  SectionType.hybrid: 'hybrid',
};

_$GenerationStatusImpl _$$GenerationStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$GenerationStatusImpl(
      totalChapters: (json['totalChapters'] as num).toInt(),
      completedChapters: (json['completedChapters'] as num?)?.toInt() ?? 0,
      currentChapterIndex: (json['currentChapterIndex'] as num?)?.toInt() ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$GenerationStatusImplToJson(
        _$GenerationStatusImpl instance) =>
    <String, dynamic>{
      'totalChapters': instance.totalChapters,
      'completedChapters': instance.completedChapters,
      'currentChapterIndex': instance.currentChapterIndex,
      'isComplete': instance.isComplete,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

_$ReadingProgressImpl _$$ReadingProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$ReadingProgressImpl(
      currentChapter: (json['currentChapter'] as num?)?.toInt() ?? 0,
      currentSection: (json['currentSection'] as num?)?.toInt() ?? 0,
      scrollPosition: (json['scrollPosition'] as num?)?.toDouble() ?? 0.0,
      totalReadingTimeSeconds:
          (json['totalReadingTimeSeconds'] as num?)?.toInt() ?? 0,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
    );

Map<String, dynamic> _$$ReadingProgressImplToJson(
        _$ReadingProgressImpl instance) =>
    <String, dynamic>{
      'currentChapter': instance.currentChapter,
      'currentSection': instance.currentSection,
      'scrollPosition': instance.scrollPosition,
      'totalReadingTimeSeconds': instance.totalReadingTimeSeconds,
      'lastReadAt': instance.lastReadAt.toIso8601String(),
    };

_$BookmarkImpl _$$BookmarkImplFromJson(Map<String, dynamic> json) =>
    _$BookmarkImpl(
      id: json['id'] as String,
      chapterIndex: (json['chapterIndex'] as num).toInt(),
      sectionIndex: (json['sectionIndex'] as num).toInt(),
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$BookmarkImplToJson(_$BookmarkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chapterIndex': instance.chapterIndex,
      'sectionIndex': instance.sectionIndex,
      'title': instance.title,
      'createdAt': instance.createdAt.toIso8601String(),
      'note': instance.note,
    };

_$PurchaseInfoImpl _$$PurchaseInfoImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseInfoImpl(
      transactionId: json['transactionId'] as String,
      productId: json['productId'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KRW',
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      isLifetimeOwnership: json['isLifetimeOwnership'] as bool? ?? true,
    );

Map<String, dynamic> _$$PurchaseInfoImplToJson(_$PurchaseInfoImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'productId': instance.productId,
      'price': instance.price,
      'currency': instance.currency,
      'purchasedAt': instance.purchasedAt.toIso8601String(),
      'isLifetimeOwnership': instance.isLifetimeOwnership,
    };

_$GrandLuckImpl _$$GrandLuckImplFromJson(Map<String, dynamic> json) =>
    _$GrandLuckImpl(
      order: (json['order'] as num).toInt(),
      startAge: (json['startAge'] as num).toInt(),
      endAge: (json['endAge'] as num).toInt(),
      heavenlyStem: json['heavenlyStem'] as String,
      earthlyBranch: json['earthlyBranch'] as String,
      element: json['element'] as String,
      summary: json['summary'] as String,
      detailedAnalysis: json['detailedAnalysis'] as String,
      keyEvents: (json['keyEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fortuneScores: (json['fortuneScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$GrandLuckImplToJson(_$GrandLuckImpl instance) =>
    <String, dynamic>{
      'order': instance.order,
      'startAge': instance.startAge,
      'endAge': instance.endAge,
      'heavenlyStem': instance.heavenlyStem,
      'earthlyBranch': instance.earthlyBranch,
      'element': instance.element,
      'summary': instance.summary,
      'detailedAnalysis': instance.detailedAnalysis,
      'keyEvents': instance.keyEvents,
      'fortuneScores': instance.fortuneScores,
    };

_$ShinSalImpl _$$ShinSalImplFromJson(Map<String, dynamic> json) =>
    _$ShinSalImpl(
      name: json['name'] as String,
      type: json['type'] as String,
      position: json['position'] as String,
      description: json['description'] as String,
      effect: json['effect'] as String,
    );

Map<String, dynamic> _$$ShinSalImplToJson(_$ShinSalImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'position': instance.position,
      'description': instance.description,
      'effect': instance.effect,
    };
