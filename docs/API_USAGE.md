# Celebrity API 사용 가이드

## 개요

이 문서는 새로운 Celebrity DB 스키마를 Flutter 앱에서 사용하는 방법을 설명합니다.

## 모델 클래스 사용법

### 1. Celebrity 모델

```dart
import 'package:fortune/data/models/celebrity.dart';

// 기본 Celebrity 객체 생성
final celebrity = Celebrity(
  id: 'singer_아이유',
  name: '아이유',
  birthDate: DateTime(1993, 5, 16),
  gender: Gender.female,
  celebrityType: CelebrityType.soloSinger,
  stageName: 'IU',
  legalName: '이지은',
  aliases: ['아이유', 'IU', '이지은'],
  nationality: '한국',
  birthPlace: '서울특별시 종로구',
  birthTime: DateTime(1970, 1, 1, 14, 30), // 14:30
  activeFrom: 2008,
  agencyManagement: 'EDAM 엔터테인먼트',
  languages: ['한국어', '영어', '일본어'],
  externalIds: ExternalIds(
    wikipedia: 'https://ko.wikipedia.org/wiki/아이유',
    youtube: 'https://www.youtube.com/@dlwlrma',
    instagram: 'https://instagram.com/dlwlrma',
  ),
  professionData: {
    'debut_date': '2008-09',
    'label': 'EDAM 엔터테인먼트',
    'genres': ['발라드', '팝', 'R&B'],
    'fandom_name': '유애나',
    'notable_tracks': ['좋은 날', 'Through the Night', 'Celebrity'],
  },
  notes: '대한민국의 대표적인 솔로 가수',
);
```

### 2. CelebrityType Enum 사용

```dart
// 직업 유형별 처리
switch (celebrity.celebrityType) {
  case CelebrityType.proGamer:
    print('프로게이머: ${celebrity.name}');
    break;
  case CelebrityType.soloSinger:
    print('솔로 가수: ${celebrity.name}');
    break;
  case CelebrityType.idolMember:
    print('아이돌 멤버: ${celebrity.name}');
    break;
  // ... 기타 케이스들
}

// 직업별 필터링
final singers = celebrities.where((c) =>
  c.celebrityType == CelebrityType.soloSinger ||
  c.celebrityType == CelebrityType.idolMember
).toList();
```

### 3. 헬퍼 메서드 활용

```dart
// 나이 계산
print('${celebrity.name}의 나이: ${celebrity.age}세');

// 별자리
print('별자리: ${celebrity.zodiacSign}');

// 띠
print('띠: ${celebrity.chineseZodiac}');

// 표시용 이름 (예명 우선)
print('표시명: ${celebrity.displayName}');

// 모든 이름 목록 (검색용)
print('검색 가능한 이름들: ${celebrity.allNames}');
```

## Supabase 서비스 사용법

### 1. 기본 조회

```dart
class CelebrityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 모든 유명인 조회
  Future<List<Celebrity>> getAllCelebrities() async {
    final response = await _supabase
        .from('celebrities')
        .select()
        .order('name');

    return response.map((json) => Celebrity.fromJson(json)).toList();
  }

  // ID로 조회
  Future<Celebrity?> getCelebrityById(String id) async {
    final response = await _supabase
        .from('celebrities')
        .select()
        .eq('id', id)
        .single();

    return Celebrity.fromJson(response);
  }

  // 직업별 조회
  Future<List<Celebrity>> getCelebritiesByType(CelebrityType type) async {
    final response = await _supabase
        .from('celebrities')
        .select()
        .eq('celebrity_type', type.name)
        .order('name');

    return response.map((json) => Celebrity.fromJson(json)).toList();
  }
}
```

### 2. 검색 및 필터링

```dart
// 이름으로 검색
Future<List<Celebrity>> searchCelebrities(String query) async {
  final response = await _supabase.rpc('search_celebrities', params: {
    'search_query': query,
    'limit_count': 50,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}

// 복합 조건 검색
Future<List<Celebrity>> searchWithFilters({
  String? query,
  CelebrityType? type,
  Gender? gender,
  String? nationality,
}) async {
  final response = await _supabase.rpc('search_celebrities', params: {
    'search_query': query,
    'celebrity_type_filter': type?.name,
    'gender_filter': gender?.name,
    'nationality_filter': nationality,
    'limit_count': 100,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}

// 연령대별 검색
Future<List<Celebrity>> getCelebritiesByAgeRange(
  int startYear,
  int endYear,
  {CelebrityType? type}
) async {
  final response = await _supabase.rpc('get_celebrities_by_birth_year_range', params: {
    'start_year': startYear,
    'end_year': endYear,
    'celebrity_type_filter': type?.name,
    'limit_count': 100,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}
```

### 3. 직업별 특화 검색

```dart
// 프로게이머 (게임별)
Future<List<Celebrity>> getProGamersByGame(String gameTitle) async {
  final response = await _supabase.rpc('get_pro_gamers_by_game', params: {
    'game_title': gameTitle,
    'limit_count': 50,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}

// 스트리머 (플랫폼별)
Future<List<Celebrity>> getStreamersByPlatform(String platform) async {
  final response = await _supabase.rpc('get_streamers_by_platform', params: {
    'platform': platform,
    'limit_count': 50,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}

// 정치인 (정당별)
Future<List<Celebrity>> getPoliticiansByParty(String party) async {
  final response = await _supabase.rpc('get_politicians_by_party', params: {
    'party_name': party,
    'limit_count': 50,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}

// 아이돌 (그룹별)
Future<List<Celebrity>> getIdolMembersByGroup(String groupName) async {
  final response = await _supabase.rpc('get_idol_members_by_group', params: {
    'group_name': groupName,
    'limit_count': 50,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}
```

### 4. 랜덤 선택 및 추천

```dart
// 랜덤 유명인 선택
Future<List<Celebrity>> getRandomCelebrities({
  int count = 10,
  CelebrityType? type,
}) async {
  final response = await _supabase.rpc('get_random_celebrities', params: {
    'limit_count': count,
    'type_filter': type?.name,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}

// 생일이 같은 유명인 찾기
Future<List<Celebrity>> getCelebritiesWithSameBirthday(DateTime birthDate) async {
  final response = await _supabase
      .from('celebrities')
      .select()
      .eq('birth_date', birthDate.toIso8601String().split('T')[0])
      .order('name');

  return response.map((json) => Celebrity.fromJson(json)).toList();
}

// 같은 나이대 유명인
Future<List<Celebrity>> getCelebritiesOfSameAge(int age) async {
  final currentYear = DateTime.now().year;
  final birthYear = currentYear - age;

  final response = await _supabase.rpc('get_celebrities_by_birth_year_range', params: {
    'start_year': birthYear - 1,
    'end_year': birthYear + 1,
    'limit_count': 50,
  });

  return response.map((json) => Celebrity.fromJson(json)).toList();
}
```

## Profession Data 활용

### 1. 직업별 데이터 접근

```dart
// 프로게이머 데이터 접근
if (celebrity.celebrityType == CelebrityType.proGamer) {
  final profData = celebrity.professionData;
  final gameTitle = profData?['game_title'] as String?;
  final team = profData?['team'] as String?;
  final ign = profData?['ign'] as String?; // In-Game Name

  print('$gameTitle 프로게이머 ${celebrity.name} (${team})');
  print('게임 내 닉네임: $ign');
}

// 솔로 가수 데이터 접근
if (celebrity.celebrityType == CelebrityType.soloSinger) {
  final profData = celebrity.professionData;
  final debutDate = profData?['debut_date'] as String?;
  final genres = profData?['genres'] as List<dynamic>?;
  final fandomName = profData?['fandom_name'] as String?;

  print('데뷔: $debutDate');
  print('장르: ${genres?.join(', ')}');
  print('팬덤: $fandomName');
}

// 아이돌 멤버 데이터 접근
if (celebrity.celebrityType == CelebrityType.idolMember) {
  final profData = celebrity.professionData;
  final groupName = profData?['group_name'] as String?;
  final positions = profData?['position'] as List<dynamic>?;

  print('그룹: $groupName');
  print('포지션: ${positions?.join(', ')}');
}
```

### 2. 동적 타입 변환 헬퍼

```dart
extension ProfessionDataExtension on Map<String, dynamic>? {
  String? getString(String key) => this?[key] as String?;

  List<String>? getStringList(String key) {
    final list = this?[key] as List<dynamic>?;
    return list?.cast<String>();
  }

  int? getInt(String key) => this?[key] as int?;

  bool? getBool(String key) => this?[key] as bool?;
}

// 사용 예시
final gameTitle = celebrity.professionData.getString('game_title');
final genres = celebrity.professionData.getStringList('genres');
final retired = celebrity.professionData.getBool('retired') ?? false;
```

## External IDs 활용

### 1. 외부 링크 처리

```dart
// Instagram 링크 확인
if (celebrity.externalIds?.instagram != null) {
  final instagramUrl = celebrity.externalIds!.instagram!;
  // 링크 열기 로직
  launchUrl(Uri.parse(instagramUrl));
}

// YouTube 채널 확인
if (celebrity.externalIds?.youtube != null) {
  final youtubeUrl = celebrity.externalIds!.youtube!;
  print('YouTube: $youtubeUrl');
}

// 모든 외부 링크 목록
List<ExternalLink> getExternalLinks(Celebrity celebrity) {
  final links = <ExternalLink>[];
  final ids = celebrity.externalIds;

  if (ids?.wikipedia != null) {
    links.add(ExternalLink('Wikipedia', ids!.wikipedia!, Icons.article));
  }
  if (ids?.youtube != null) {
    links.add(ExternalLink('YouTube', ids!.youtube!, Icons.play_circle));
  }
  if (ids?.instagram != null) {
    links.add(ExternalLink('Instagram', ids!.instagram!, Icons.camera_alt));
  }
  // ... 기타 링크들

  return links;
}

class ExternalLink {
  final String name;
  final String url;
  final IconData icon;

  ExternalLink(this.name, this.url, this.icon);
}
```

## UI 컴포넌트 예시

### 1. Celebrity Card 위젯

```dart
class CelebrityCard extends StatelessWidget {
  final Celebrity celebrity;
  final VoidCallback? onTap;

  const CelebrityCard({
    Key? key,
    required this.celebrity,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름 및 직업
              Row(
                children: [
                  Expanded(
                    child: Text(
                      celebrity.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Chip(
                    label: Text(celebrity.celebrityType.displayName),
                    backgroundColor: _getTypeColor(celebrity.celebrityType),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // 기본 정보
              Text('나이: ${celebrity.age}세'),
              Text('국적: ${celebrity.nationality}'),

              // 직업별 특화 정보
              if (celebrity.professionData != null)
                ..._buildProfessionInfo(celebrity),

              SizedBox(height: 8),

              // 외부 링크
              if (celebrity.externalIds != null)
                _buildExternalLinks(celebrity.externalIds!),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(CelebrityType type) {
    switch (type) {
      case CelebrityType.proGamer:
        return Colors.purple.shade100;
      case CelebrityType.soloSinger:
      case CelebrityType.idolMember:
        return Colors.pink.shade100;
      case CelebrityType.actor:
        return Colors.blue.shade100;
      case CelebrityType.athlete:
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  List<Widget> _buildProfessionInfo(Celebrity celebrity) {
    final widgets = <Widget>[];
    final data = celebrity.professionData!;

    switch (celebrity.celebrityType) {
      case CelebrityType.proGamer:
        if (data['game_title'] != null) {
          widgets.add(Text('게임: ${data['game_title']}'));
        }
        if (data['team'] != null) {
          widgets.add(Text('팀: ${data['team']}'));
        }
        break;

      case CelebrityType.soloSinger:
        if (data['debut_date'] != null) {
          widgets.add(Text('데뷔: ${data['debut_date']}'));
        }
        if (data['genres'] != null) {
          final genres = (data['genres'] as List).join(', ');
          widgets.add(Text('장르: $genres'));
        }
        break;

      // ... 기타 직업들
    }

    return widgets;
  }

  Widget _buildExternalLinks(ExternalIds externalIds) {
    return Row(
      children: [
        if (externalIds.youtube != null)
          IconButton(
            icon: Icon(Icons.play_circle, color: Colors.red),
            onPressed: () => launchUrl(Uri.parse(externalIds.youtube!)),
          ),
        if (externalIds.instagram != null)
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.purple),
            onPressed: () => launchUrl(Uri.parse(externalIds.instagram!)),
          ),
        // ... 기타 링크들
      ],
    );
  }
}
```

### 2. 검색 및 필터 위젯

```dart
class CelebritySearchDelegate extends SearchDelegate<Celebrity?> {
  final CelebrityService _service = CelebrityService();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Celebrity>>(
      future: _service.searchCelebrities(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('검색 결과가 없습니다.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final celebrity = snapshot.data![index];
            return CelebrityCard(
              celebrity: celebrity,
              onTap: () => close(context, celebrity),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('유명인 이름을 입력해주세요.'));
    }

    return buildResults(context);
  }
}
```

## 에러 처리 및 예외 상황

### 1. 네트워크 에러 처리

```dart
Future<List<Celebrity>> getCelebritiesWithErrorHandling() async {
  try {
    final response = await _supabase
        .from('celebrities')
        .select()
        .order('name');

    return response.map((json) => Celebrity.fromJson(json)).toList();
  } on PostgrestException catch (e) {
    print('Database error: ${e.message}');
    throw CelebrityServiceException('데이터를 불러올 수 없습니다: ${e.message}');
  } on SocketException catch (e) {
    print('Network error: $e');
    throw CelebrityServiceException('네트워크 연결을 확인해주세요.');
  } catch (e) {
    print('Unknown error: $e');
    throw CelebrityServiceException('알 수 없는 오류가 발생했습니다.');
  }
}

class CelebrityServiceException implements Exception {
  final String message;
  CelebrityServiceException(this.message);

  @override
  String toString() => 'CelebrityServiceException: $message';
}
```

### 2. JSON 파싱 에러 처리

```dart
Celebrity? safeParseCelebrity(Map<String, dynamic> json) {
  try {
    return Celebrity.fromJson(json);
  } catch (e) {
    print('Failed to parse celebrity: $e');
    print('JSON: $json');
    return null;
  }
}

List<Celebrity> parseMultipleCelebrities(List<dynamic> jsonList) {
  final celebrities = <Celebrity>[];

  for (final json in jsonList) {
    if (json is Map<String, dynamic>) {
      final celebrity = safeParseCelebrity(json);
      if (celebrity != null) {
        celebrities.add(celebrity);
      }
    }
  }

  return celebrities;
}
```

## 성능 최적화 팁

### 1. 페이지네이션

```dart
class CelebrityPagination {
  static const int pageSize = 20;

  Future<List<Celebrity>> getCelebritiesPaginated({
    required int page,
    CelebrityType? type,
    String? searchQuery,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = _supabase
        .from('celebrities')
        .select()
        .range(from, to)
        .order('name');

    if (type != null) {
      query = query.eq('celebrity_type', type.name);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    final response = await query;
    return response.map((json) => Celebrity.fromJson(json)).toList();
  }
}
```

### 2. 캐싱

```dart
class CelebrityCacheService {
  static final Map<String, Celebrity> _cache = {};
  static final Map<String, List<Celebrity>> _listCache = {};
  static const Duration cacheExpiry = Duration(minutes: 10);

  Future<Celebrity?> getCachedCelebrity(String id) async {
    if (_cache.containsKey(id)) {
      return _cache[id];
    }

    final celebrity = await _service.getCelebrityById(id);
    if (celebrity != null) {
      _cache[id] = celebrity;
    }

    return celebrity;
  }

  Future<List<Celebrity>> getCachedCelebritiesByType(CelebrityType type) async {
    final key = 'type_${type.name}';

    if (_listCache.containsKey(key)) {
      return _listCache[key]!;
    }

    final celebrities = await _service.getCelebritiesByType(type);
    _listCache[key] = celebrities;

    return celebrities;
  }

  void clearCache() {
    _cache.clear();
    _listCache.clear();
  }
}
```

이 가이드를 통해 새로운 Celebrity DB 스키마를 효율적으로 활용할 수 있습니다. 추가 질문이나 특정 사용 사례에 대한 도움이 필요하시면 언제든 문의해 주세요.