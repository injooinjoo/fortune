import 'package:fortune/data/models/celebrity.dart';

/// Sample celebrity data for testing and development
class CelebritySampleData {

  /// Get sample celebrities for each type
  static List<Celebrity> getSampleCelebrities() {
    return [
      // Pro Gamer
      Celebrity(
        id: 'pro_gamer_faker',
        name: 'Faker',
        birthDate: DateTime(1996, 5, 7),
        gender: Gender.male,
        celebrityType: CelebrityType.proGamer,
        legalName: '이상혁',
        nationality: '한국',
        activeFrom: 2013,
        agencyManagement: 'T1',
        professionData: {
          'game_title': 'League of Legends',
          'primary_role': 'Mid',
          'team': 'T1',
          'league_region': 'LCK',
          'jersey_number': '1',
          'career_highlights': ['2023 월드 챔피언십 우승', '2022 월드 챔피언십 우승'],
          'ign': 'Faker',
          'pro_debut': '2013-02',
          'retired': false,
        },
        externalIds: const ExternalIds(
          youtube: 'https://www.youtube.com/@faker',
          instagram: 'https://instagram.com/faker',
        ),
      ),

      // Streamer
      Celebrity(
        id: 'streamer_jokbaltan',
        name: '족발탄',
        birthDate: DateTime(1990, 3, 15),
        gender: Gender.male,
        celebrityType: CelebrityType.streamer,
        nationality: '한국',
        activeFrom: 2018,
        professionData: {
          'main_platform': 'twitch',
          'channel_url': 'https://twitch.tv/jokbaltan',
          'affiliation': '파트너',
          'content_genres': ['게임', '토크'],
          'stream_schedule': '평일 오후 2-8시',
          'first_stream_date': '2018-01',
          'avg_viewers_bucket': 'large',
        },
        externalIds: const ExternalIds(
          twitch: 'https://twitch.tv/jokbaltan',
          youtube: 'https://www.youtube.com/@jokbaltan',
        ),
      ),

      // Solo Singer
      Celebrity(
        id: 'solo_singer_iu',
        name: '아이유',
        birthDate: DateTime(1993, 5, 16),
        gender: Gender.female,
        celebrityType: CelebrityType.soloSinger,
        stageName: 'IU',
        legalName: '이지은',
        aliases: ['아이유', 'IU', '이지은'],
        nationality: '한국',
        birthPlace: '서울특별시 종로구',
        birthTime: DateTime(1970, 1, 1, 14, 30),
        activeFrom: 2008,
        agencyManagement: 'EDAM 엔터테인먼트',
        languages: ['한국어', '영어', '일본어'],
        professionData: {
          'debut_date': '2008-09',
          'label': 'EDAM 엔터테인먼트',
          'genres': ['발라드', '팝', 'R&B'],
          'fandom_name': '유애나',
          'vocal_range': '소프라노',
          'notable_tracks': ['좋은 날', 'Through the Night', 'Celebrity'],
        },
        externalIds: const ExternalIds(
          wikipedia: 'https://ko.wikipedia.org/wiki/아이유',
          youtube: 'https://www.youtube.com/@dlwlrma',
          instagram: 'https://instagram.com/dlwlrma',
        ),
      ),

      // Idol Member
      Celebrity(
        id: 'idol_member_rm',
        name: 'RM',
        birthDate: DateTime(1994, 9, 12),
        gender: Gender.male,
        celebrityType: CelebrityType.idolMember,
        legalName: '김남준',
        aliases: ['RM', '랩몬스터', 'Rap Monster'],
        nationality: '한국',
        activeFrom: 2013,
        agencyManagement: 'HYBE 엔터테인먼트',
        professionData: {
          'group_name': 'BTS',
          'position': ['rap', 'leader'],
          'debut_date': '2013-06-13',
          'label': 'HYBE 엔터테인먼트',
          'fandom_name': 'ARMY',
          'sub_units': [],
          'solo_activities': ['Indigo 앨범', 'Right Place, Wrong Person'],
        },
        externalIds: const ExternalIds(
          instagram: 'https://instagram.com/rkive',
          youtube: 'https://www.youtube.com/@bts',
        ),
      ),

      // Actor
      Celebrity(
        id: 'actor_song_kang_ho',
        name: '송강호',
        birthDate: DateTime(1967, 1, 17),
        gender: Gender.male,
        celebrityType: CelebrityType.actor,
        nationality: '한국',
        activeFrom: 1996,
        agencyManagement: '매니지먼트 숲',
        professionData: {
          'acting_debut': '1996',
          'agency': '매니지먼트 숲',
          'specialties': ['film', 'tv'],
          'notable_works': ['기생충', '옥자', '살인의 추억', '괴물'],
          'awards': ['아카데미 작품상', '칸 영화제 남우주연상'],
        },
        externalIds: const ExternalIds(
          wikipedia: 'https://ko.wikipedia.org/wiki/송강호',
          imdb: 'https://www.imdb.com/name/nm0814280/',
        ),
      ),

      // Athlete
      Celebrity(
        id: 'athlete_son_heung_min',
        name: '손흥민',
        birthDate: DateTime(1992, 7, 8),
        gender: Gender.male,
        celebrityType: CelebrityType.athlete,
        nationality: '한국',
        activeFrom: 2008,
        professionData: {
          'sport': '축구',
          'position_role': '공격수',
          'team': '토트넘 홋스퍼',
          'league': '프리미어리그',
          'dominant_hand_foot': 'both',
          'pro_debut': '2008',
          'career_highlights': ['2018 월드컵 16강', 'EPL 골든부트'],
          'records_personal_bests': ['EPL 시즌 최다골 23골'],
        },
        externalIds: const ExternalIds(
          instagram: 'https://instagram.com/hm_son7',
          wikipedia: 'https://ko.wikipedia.org/wiki/손흥민',
        ),
      ),

      // Politician
      Celebrity(
        id: 'politician_lee_jae_myung',
        name: '이재명',
        birthDate: DateTime(1964, 12, 22),
        gender: Gender.male,
        celebrityType: CelebrityType.politician,
        nationality: '한국',
        activeFrom: 2006,
        professionData: {
          'party': '더불어민주당',
          'current_office': '국회의원',
          'constituency': '경기 성남시 분당구 을',
          'term_start': '2020-05-30',
          'term_end': '2024-05-29',
          'previous_offices': ['경기도지사', '성남시장'],
          'ideology_tags': ['진보'],
        },
        externalIds: const ExternalIds(
          wikipedia: 'https://ko.wikipedia.org/wiki/이재명',
        ),
      ),

      // Business Leader
      Celebrity(
        id: 'business_lee_jae_yong',
        name: '이재용',
        birthDate: DateTime(1968, 6, 23),
        gender: Gender.male,
        celebrityType: CelebrityType.business,
        nationality: '한국',
        activeFrom: 1991,
        professionData: {
          'company_name': '삼성전자',
          'title': '회장',
          'industry': '전자/반도체',
          'founded_year': '',
          'board_memberships': ['삼성물산', '삼성SDS'],
          'notable_ventures': ['삼성 바이오로직스', '삼성전기'],
        },
        externalIds: const ExternalIds(
          wikipedia: 'https://ko.wikipedia.org/wiki/이재용_(기업인)',
        ),
      ),
    ];
  }

  /// Get celebrities by type
  static List<Celebrity> getCelebritiesByType(CelebrityType type) {
    return getSampleCelebrities()
        .where((celebrity) => celebrity.celebrityType == type)
        .toList();
  }

  /// Get celebrity by ID
  static Celebrity? getCelebrityById(String id) {
    try {
      return getSampleCelebrities()
          .firstWhere((celebrity) => celebrity.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search celebrities by name
  static List<Celebrity> searchCelebrities(String query) {
    final lowerQuery = query.toLowerCase();
    return getSampleCelebrities()
        .where((celebrity) =>
            celebrity.allNames.any((name) =>
                name.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Get profession data examples for each type
  static Map<CelebrityType, Map<String, dynamic>> getProfessionDataExamples() {
    return {
      CelebrityType.proGamer: {
        'game_title': 'League of Legends',
        'primary_role': 'Mid',
        'team': 'T1',
        'league_region': 'LCK',
        'jersey_number': '1',
        'career_highlights': ['2023 월드 챔피언십 우승'],
        'ign': 'Faker',
        'pro_debut': '2013-02',
        'retired': false,
      },
      CelebrityType.streamer: {
        'main_platform': 'twitch',
        'channel_url': 'https://twitch.tv/username',
        'affiliation': '파트너',
        'content_genres': ['게임', '토크'],
        'stream_schedule': '평일 오후 2-8시',
        'first_stream_date': '2020-01',
        'avg_viewers_bucket': 'large',
      },
      CelebrityType.politician: {
        'party': '더불어민주당',
        'current_office': '국회의원',
        'constituency': '서울 종로구',
        'term_start': '2020-05-30',
        'term_end': '2024-05-29',
        'previous_offices': ['서울시장'],
        'ideology_tags': ['진보'],
      },
      CelebrityType.business: {
        'company_name': '삼성전자',
        'title': 'CEO',
        'industry': '전자/반도체',
        'founded_year': '1969',
        'board_memberships': ['삼성물산'],
        'notable_ventures': ['삼성 바이오로직스'],
      },
      CelebrityType.soloSinger: {
        'debut_date': '2008-09',
        'label': 'EDAM 엔터테인먼트',
        'genres': ['발라드', '팝', 'R&B'],
        'fandom_name': '유애나',
        'vocal_range': '소프라노',
        'notable_tracks': ['좋은 날', 'Through the Night'],
      },
      CelebrityType.idolMember: {
        'group_name': 'BTS',
        'position': ['vocal', 'leader'],
        'debut_date': '2013-06-13',
        'label': 'HYBE 엔터테인먼트',
        'fandom_name': 'ARMY',
        'sub_units': [],
        'solo_activities': ['Indigo 앨범'],
      },
      CelebrityType.actor: {
        'acting_debut': '2011',
        'agency': '매니지먼트 숲',
        'specialties': ['film', 'tv'],
        'notable_works': ['기생충', '옥자'],
        'awards': ['아카데미 작품상'],
      },
      CelebrityType.athlete: {
        'sport': '축구',
        'position_role': '미드필더',
        'team': '토트넘 홋스퍼',
        'league': '프리미어리그',
        'dominant_hand_foot': 'right',
        'pro_debut': '2008',
        'career_highlights': ['2018 월드컵 16강'],
        'records_personal_bests': ['EPL 시즌 최다골 23골'],
      },
    };
  }

  /// Create test data insertion SQL
  static String generateInsertSQL() {
    final celebrities = getSampleCelebrities();
    final buffer = StringBuffer();

    buffer.writeln('-- Sample celebrity data for testing');
    buffer.writeln('-- Generated by CelebritySampleData');
    buffer.writeln('');

    for (final celebrity in celebrities) {
      buffer.writeln('INSERT INTO public.celebrities (');
      buffer.writeln('  id, name, birth_date, gender, celebrity_type,');
      buffer.writeln('  stage_name, legal_name, aliases, nationality, birth_place, birth_time,');
      buffer.writeln('  active_from, agency_management, languages, external_ids, profession_data, notes');
      buffer.writeln(') VALUES (');
      buffer.writeln("  '${celebrity.id}',");
      buffer.writeln("  '${celebrity.name}',");
      buffer.writeln("  '${celebrity.birthDate.toIso8601String().split('T')[0]}',");
      buffer.writeln("  '${celebrity.gender.name}',");
      buffer.writeln("  '${celebrity.celebrityType.name}',");
      buffer.writeln("  ${celebrity.stageName != null ? "'${celebrity.stageName}'" : 'NULL'},");
      buffer.writeln("  ${celebrity.legalName != null ? "'${celebrity.legalName}'" : 'NULL'},");
      buffer.writeln("  ARRAY[${celebrity.aliases.map((a) => "'$a'").join(', ')}],");
      buffer.writeln("  '${celebrity.nationality}',");
      buffer.writeln("  ${celebrity.birthPlace != null ? "'${celebrity.birthPlace}'" : 'NULL'},");
      if (celebrity.birthTime != null) {
        buffer.writeln("  '${celebrity.birthTime!.hour.toString().padLeft(2, '0')}:${celebrity.birthTime!.minute.toString().padLeft(2, '0')}',");
      } else {
        buffer.writeln("  '12:00',");
      }
      buffer.writeln('  ${celebrity.activeFrom},');
      buffer.writeln("  ${celebrity.agencyManagement != null ? "'${celebrity.agencyManagement}'" : 'NULL'},");
      buffer.writeln("  ARRAY[${celebrity.languages.map((l) => "'$l'").join(', ')}],");
      buffer.writeln("  '${celebrity.externalIds?.toJson() ?? {}}'::jsonb,");
      buffer.writeln("  '${celebrity.professionData ?? {}}'::jsonb,");
      buffer.writeln("  '샘플 데이터'");
      buffer.writeln(') ON CONFLICT (id) DO UPDATE SET');
      buffer.writeln('  name = EXCLUDED.name,');
      buffer.writeln('  updated_at = NOW();');
      buffer.writeln('');
    }

    return buffer.toString();
  }
}