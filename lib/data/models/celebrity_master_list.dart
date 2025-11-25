import 'package:json_annotation/json_annotation.dart';

part 'celebrity_master_list.g.dart';

/// 확장된 연예인/유명인 카테고리
enum CelebrityMasterCategory {
  singer('가수', 'singer'),
  actor('배우', 'actor'),
  streamer('스트리머', 'streamer'),
  youtuber('유튜버', 'youtuber'),
  politician('정치인', 'politician'),
  business('기업인', 'business'),
  comedian('코미디언', 'comedian'),
  athlete('운동선수', 'athlete'),
  influencer('인플루언서', 'influencer'),
  broadcaster('방송인', 'broadcaster'),
  model('모델', 'model'),
  author('작가', 'author'),
  musician('음악가', 'musician'),
  professor('교수/학자', 'professor'),
  chef('요리사', 'chef'),
  proGamer('프로게이머', 'pro_gamer'),
  other('기타', 'other');

  const CelebrityMasterCategory(this.displayName, this.code);
  
  final String displayName;
  final String code;
  
  static CelebrityMasterCategory fromCode(String code) {
    return CelebrityMasterCategory.values.firstWhere(
      (category) => category.code == code,
      orElse: () => CelebrityMasterCategory.other,
    );
  }
}

/// 세부 카테고리 (서브카테고리)
enum CelebritySubcategory {
  // 가수 세부 카테고리
  soloSinger('솔로 가수', 'solo_singer'),
  idolGroup('아이돌 그룹', 'idol_group'),
  hiphopRapper('힙합/래퍼', 'hiphop_rapper'),
  ballad('발라드', 'ballad'),
  trot('트로트', 'trot'),
  rock('록/메탈', 'rock'),
  indie('인디', 'indie'),
  
  // 배우 세부 카테고리
  movieActor('영화배우', 'movie_actor'),
  dramaActor('드라마배우', 'drama_actor'),
  musicalActor('뮤지컬배우', 'musical_actor'),
  voiceActor('성우', 'voice_actor'),
  childActor('아역배우', 'child_actor'),
  
  // 스트리머 세부 카테고리
  twitchStreamer('트위치 스트리머', 'twitch_streamer'),
  afreecaTVStreamer('아프리카TV BJ', 'afreecatv_streamer'),
  chzzkStreamer('치지직 스트리머', 'chzzk_streamer'),
  gameStreamer('게임 스트리머', 'game_streamer'),
  talkStreamer('토크 스트리머', 'talk_streamer'),
  
  // 유튜버 세부 카테고리
  entertainmentYoutuber('엔터테인먼트 유튜버', 'entertainment_youtuber'),
  gameYoutuber('게임 유튜버', 'game_youtuber'),
  mukbangYoutuber('먹방 유튜버', 'mukbang_youtuber'),
  educationYoutuber('교육 유튜버', 'education_youtuber'),
  beautyYoutuber('뷰티 유튜버', 'beauty_youtuber'),
  fashionYoutuber('패션 유튜버', 'fashion_youtuber'),
  techYoutuber('테크 유튜버', 'tech_youtuber'),
  
  // 정치인 세부 카테고리
  president('대통령', 'president'),
  primeMinister('총리', 'prime_minister'),
  minister('장관', 'minister'),
  assemblyman('국회의원', 'assemblyman'),
  partyLeader('당대표', 'party_leader'),
  governor('시도지사', 'governor'),
  mayor('시장/구청장', 'mayor'),
  
  // 기업인 세부 카테고리
  chaeboCEO('대기업 회장/CEO', 'chaebo_ceo'),
  startupFounder('스타트업 대표', 'startup_founder'),
  techCEO('IT기업 CEO', 'tech_ceo'),
  
  // 운동선수 세부 카테고리
  footballPlayer('축구선수', 'football_player'),
  baseballPlayer('야구선수', 'baseball_player'),
  basketballPlayer('농구선수', 'basketball_player'),
  golfPlayer('골프선수', 'golf_player'),
  tennisPlayer('테니스선수', 'tennis_player'),
  figureSkater('피겨스케이팅', 'figure_skater'),
  swimmer('수영선수', 'swimmer'),
  trackAthlete('육상선수', 'track_athlete'),
  martialArtist('격투기선수', 'martial_artist'),
  esportsPlayer('E스포츠선수', 'esports_player'),
  
  // 기타
  none('없음', 'none');

  const CelebritySubcategory(this.displayName, this.code);
  
  final String displayName;
  final String code;
  
  static CelebritySubcategory fromCode(String code) {
    return CelebritySubcategory.values.firstWhere(
      (subcategory) => subcategory.code == code,
      orElse: () => CelebritySubcategory.none,
    );
  }
}

@JsonSerializable()
class CelebrityMasterListItem {
  final String id;
  final String name;
  final String? nameEn;
  final CelebrityMasterCategory category;
  final CelebritySubcategory? subcategory;
  final int popularityRank;
  final int? searchVolume;
  final String? lastActive;  // 최근 활동 시기
  final bool isCrawled;      // 상세정보 크롤링 여부
  final int crawlPriority;   // 크롤링 우선순위
  final String? description; // 간단한 설명
  final List<String>? keywords; // 검색 키워드
  final String? platform;    // 주요 활동 플랫폼 (유튜브, 트위치 등)
  final DateTime createdAt;
  final DateTime updatedAt;

  CelebrityMasterListItem({
    required this.id,
    required this.name,
    this.nameEn,
    required this.category,
    this.subcategory,
    required this.popularityRank,
    this.searchVolume,
    this.lastActive,
    this.isCrawled = false,
    this.crawlPriority = 0,
    this.description,
    this.keywords,
    this.platform,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CelebrityMasterListItem.fromJson(Map<String, dynamic> json) => 
      _$CelebrityMasterListItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$CelebrityMasterListItemToJson(this);

  CelebrityMasterListItem copyWith({
    String? id,
    String? name,
    String? nameEn,
    CelebrityMasterCategory? category,
    CelebritySubcategory? subcategory,
    int? popularityRank,
    int? searchVolume,
    String? lastActive,
    bool? isCrawled,
    int? crawlPriority,
    String? description,
    List<String>? keywords,
    String? platform,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CelebrityMasterListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      popularityRank: popularityRank ?? this.popularityRank,
      searchVolume: searchVolume ?? this.searchVolume,
      lastActive: lastActive ?? this.lastActive,
      isCrawled: isCrawled ?? this.isCrawled,
      crawlPriority: crawlPriority ?? this.crawlPriority,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 카테고리별 목록 데이터 구조
@JsonSerializable()
class CelebrityCategoryList {
  final CelebrityMasterCategory category;
  final String categoryDisplayName;
  final int totalCount;
  final DateTime lastUpdated;
  final List<CelebrityMasterListItem> celebrities;

  CelebrityCategoryList({
    required this.category,
    required this.categoryDisplayName,
    required this.totalCount,
    required this.lastUpdated,
    required this.celebrities,
  });

  factory CelebrityCategoryList.fromJson(Map<String, dynamic> json) => 
      _$CelebrityCategoryListFromJson(json);
  
  Map<String, dynamic> toJson() => _$CelebrityCategoryListToJson(this);
}

/// 크롤링 우선순위 계산기
class CrawlPriorityCalculator {
  static int calculatePriority(CelebrityMasterListItem celebrity) {
    int priority = 0;
    
    // 카테고리별 가중치
    final categoryWeight = {
      CelebrityMasterCategory.singer: 1.5,
      CelebrityMasterCategory.actor: 1.5,
      CelebrityMasterCategory.streamer: 1.3,
      CelebrityMasterCategory.youtuber: 1.2,
      CelebrityMasterCategory.politician: 1.0,
      CelebrityMasterCategory.business: 1.1,
      CelebrityMasterCategory.comedian: 1.2,
      CelebrityMasterCategory.athlete: 1.4,
      CelebrityMasterCategory.influencer: 1.1,
      CelebrityMasterCategory.broadcaster: 1.2,
    };
    
    // 인기도 순위 기반 점수 (1위=100점, 100위=1점)
    priority += (101 - celebrity.popularityRank) * 10;
    
    // 카테고리 가중치 적용
    final weight = categoryWeight[celebrity.category] ?? 1.0;
    priority = (priority * weight).round();
    
    // 검색량 보너스
    if (celebrity.searchVolume != null) {
      if (celebrity.searchVolume! > 1000000) {
        priority += 100;
      } else if (celebrity.searchVolume! > 500000) {
        priority += 50;
      } else if (celebrity.searchVolume! > 100000) {
        priority += 20;
      }
    }
    
    // 최근 활동 보너스
    if (celebrity.lastActive != null) {
      final now = DateTime.now();
      final lastActiveYear = int.tryParse(celebrity.lastActive!);
      if (lastActiveYear != null) {
        final yearsDiff = now.year - lastActiveYear;
        if (yearsDiff <= 1) {
          priority += 30;
        } else if (yearsDiff <= 3) {
          priority += 15;
        }
      }
    }
    
    return priority;
  }
}