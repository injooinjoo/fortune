import '../models/celebrity.dart';

class CelebrityDatabase {
  static final List<Celebrity> politicians = [
    // Korean Politicians
    Celebrity(
      id: 'pol_001',
      name: '윤석열',
      birthDate: DateTime(1960, 12, 18),
      gender: Gender.male,
      celebrityType: CelebrityType.politician,
      stageName: '윤석열',
      aliases: ['대통령', '윤 대통령'],
      agencyManagement: '대한민국 정부',
      professionData: {
        'party': '국민의힘',
        'currentOffice': '대한민국 제20대 대통령',
        'termStart': '2022-05-10',
        'previousOffices': ['검찰총장'],
        'ideologyTags': ['보수', '법치주의']
      },
    ),
    Celebrity(
      id: 'pol_002',
      name: '이재명',
      birthDate: DateTime(1964, 12, 22),
      gender: Gender.male,
      celebrityType: CelebrityType.politician,
      stageName: '이재명',
      aliases: ['이 대표', '더불어민주당 대표'],
      professionData: {
        'party': '더불어민주당',
        'currentOffice': '더불어민주당 대표',
        'previousOffices': ['경기도지사', '성남시장'],
        'ideologyTags': ['진보', '민주주의']
      },
    ),
    Celebrity(
      id: 'pol_003',
      name: '한동훈',
      birthDate: DateTime(1973, 4, 15),
      gender: Gender.male,
      celebrityType: CelebrityType.politician,
      stageName: '한동훈',
      aliases: ['한 대표', '국민의힘 대표'],
      professionData: {
        'party': '국민의힘',
        'currentOffice': '국민의힘 대표',
        'previousOffices': ['법무부장관', '검사'],
        'ideologyTags': ['보수', '법치주의']
      },
    ),
    Celebrity(
      id: 'pol_004',
      name: '안철수',
      birthDate: DateTime(1962, 2, 26),
      gender: Gender.male,
      celebrityType: CelebrityType.politician,
      stageName: '안철수',
      aliases: ['안 대표'],
      professionData: {
        'previousOffices': ['국민의당 대표'],
        'ideologyTags': ['중도', '혁신']
      },
      notes: '의사, 기업인 출신 정치인',
    ),
  ];

  static final List<Celebrity> entertainers = [
    // Korean Entertainers
    Celebrity(
      id: 'ent_001',
      name: '아이유',
      birthDate: DateTime(1993, 5, 16),
      gender: Gender.female,
      celebrityType: CelebrityType.soloSinger,
      stageName: '아이유',
      legalName: '이지은',
      aliases: ['IU', '지은이'],
      activeFrom: 2008,
      agencyManagement: 'EDAM엔터테인먼트',
      professionData: {
        'debutDate': '2008-09-18',
        'label': 'EDAM엔터테인먼트',
        'genres': ['발라드', 'K-POP', '인디'],
        'fandomName': '유애나',
        'notableTracks': ['좋은 날', '스물셋', 'Celebrity', 'strawberry moon']
      },
    ),
    Celebrity(
      id: 'ent_002',
      name: 'BTS',
      birthDate: DateTime(1997, 9, 12), // RM's birthday as representative
      gender: Gender.male,
      celebrityType: CelebrityType.idolMember,
      stageName: 'BTS',
      aliases: ['방탄소년단', '방탄', 'Bangtan'],
      activeFrom: 2013,
      agencyManagement: 'BIGHIT MUSIC',
      professionData: {
        'groupName': 'BTS',
        'debutDate': '2013-06-13',
        'label': 'BIGHIT MUSIC',
        'fandomName': 'ARMY',
        'soloActivities': ['개별 솔로 활동']
      },
    ),
  ];

  static final List<Celebrity> athletes = [
    // Korean Athletes
    Celebrity(
      id: 'ath_001',
      name: '손흥민',
      birthDate: DateTime(1992, 7, 8),
      gender: Gender.male,
      celebrityType: CelebrityType.athlete,
      stageName: '손흥민',
      aliases: ['Son', '손 캡틴', '토트넘 에이스'],
      activeFrom: 2010,
      professionData: {
        'sport': '축구',
        'positionRole': '윙어/공격수',
        'team': '토트넘 홋스퍼',
        'league': '프리미어리그',
        'dominantHandFoot': 'right',
        'proDebut': '2010',
        'careerHighlights': ['프리미어리그 득점왕', '아시안컵 우승', '올림픽 금메달'],
        'recordsPersonalBests': ['프리미어리그 시즌 23골']
      },
    ),
  ];

  // Get all celebrities
  static List<Celebrity> getAllCelebrities() {
    return [
      ...politicians,
      ...entertainers,
      ...athletes,
    ];
  }

  // Get celebrities by category
  static List<Celebrity> getCelebritiesByCategory(CelebrityType celebrityType) {
    return getAllCelebrities()
        .where((celebrity) => celebrity.celebrityType == celebrityType)
        .toList();
  }

  // Search celebrities by name
  static List<Celebrity> searchCelebrities(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllCelebrities().where((celebrity) {
      return celebrity.name.toLowerCase().contains(lowercaseQuery) ||
          celebrity.allNames
              .any((name) => name.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}
