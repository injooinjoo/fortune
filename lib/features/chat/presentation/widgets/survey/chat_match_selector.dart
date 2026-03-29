import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../features/fortune/domain/models/sports_schedule.dart';
import '../../../../../services/sports_schedule_service.dart';
import '../../../../../core/constants/sports_teams.dart';

/// 지역 타입
enum SportsRegion {
  korea,
  usa,
  europe,
}

extension SportsRegionExtension on SportsRegion {
  String get displayName {
    switch (this) {
      case SportsRegion.korea:
        return '한국';
      case SportsRegion.usa:
        return '미국';
      case SportsRegion.europe:
        return '유럽';
    }
  }

  String get emoji {
    switch (this) {
      case SportsRegion.korea:
        return '🇰🇷';
      case SportsRegion.usa:
        return '🇺🇸';
      case SportsRegion.europe:
        return '🇪🇺';
    }
  }

  List<LeagueInfo> get leagues {
    switch (this) {
      case SportsRegion.korea:
        return const [
          LeagueInfo('KBO', '야구', SportType.baseball, '⚾'),
          LeagueInfo('K리그1', '축구', SportType.soccer, '⚽'),
          LeagueInfo('KBL', '농구', SportType.basketball, '🏀'),
          LeagueInfo('V리그 남자', '배구', SportType.volleyball, '🏐'),
          LeagueInfo('V리그 여자', '배구', SportType.volleyball, '🏐'),
          LeagueInfo('LCK', 'e스포츠', SportType.esports, '🎮'),
        ];
      case SportsRegion.usa:
        return const [
          LeagueInfo('MLB', '야구', SportType.baseball, '⚾'),
          LeagueInfo('NBA', '농구', SportType.basketball, '🏀'),
          LeagueInfo('NFL', '미식축구', SportType.americanFootball, '🏈'),
        ];
      case SportsRegion.europe:
        return const [
          LeagueInfo('EPL', '프리미어리그', SportType.soccer, '⚽'),
          LeagueInfo('La Liga', '라리가', SportType.soccer, '⚽'),
          LeagueInfo('Bundesliga', '분데스리가', SportType.soccer, '⚽'),
          LeagueInfo('Serie A', '세리에A', SportType.soccer, '⚽'),
        ];
    }
  }

  /// 특정 종목에 해당하는 리그만 반환
  List<LeagueInfo> leaguesForSport(SportType? sportType) {
    if (sportType == null) return leagues;
    return leagues.where((l) => l.sportType == sportType).toList();
  }

  /// 특정 종목의 리그가 있는지 확인
  bool hasLeaguesForSport(SportType? sportType) {
    if (sportType == null) return true;
    return leagues.any((l) => l.sportType == sportType);
  }
}

/// String을 SportType으로 변환
SportType? sportTypeFromString(String? sportId) {
  if (sportId == null) return null;
  switch (sportId) {
    case 'baseball':
      return SportType.baseball;
    case 'soccer':
      return SportType.soccer;
    case 'basketball':
      return SportType.basketball;
    case 'volleyball':
      return SportType.volleyball;
    case 'esports':
      return SportType.esports;
    case 'american_football':
      return SportType.americanFootball;
    case 'fighting':
      return SportType.fighting;
    default:
      return null;
  }
}

/// 리그 정보
class LeagueInfo {
  final String id;
  final String displayName;
  final SportType sportType;
  final String emoji;

  const LeagueInfo(this.id, this.displayName, this.sportType, this.emoji);
}

/// 리그별 경기 목록 Provider
final matchListByLeagueProvider =
    FutureProvider.family<List<SportsGame>, String>((ref, league) async {
  return await SportsScheduleService.instance.getScheduleByLeague(league);
});

/// 채팅 경기 선택 위젯 (3단계: 지역 → 리그 → 경기)
class ChatMatchSelector extends ConsumerStatefulWidget {
  final String? selectedSport; // 하위 호환성
  final void Function(SportsGame game, String league) onSelect;

  const ChatMatchSelector({
    super.key,
    this.selectedSport,
    required this.onSelect,
  });

  @override
  ConsumerState<ChatMatchSelector> createState() => _ChatMatchSelectorState();
}

class _ChatMatchSelectorState extends ConsumerState<ChatMatchSelector> {
  // 선택 상태
  SportsRegion? _selectedRegion;
  LeagueInfo? _selectedLeague;
  SportsGame? _selectedGame;

  /// 선택된 종목 (String → SportType)
  SportType? get _selectedSportType =>
      sportTypeFromString(widget.selectedSport);

  /// 필터링된 지역 목록 (선택된 종목의 리그가 있는 지역만)
  List<SportsRegion> get _filteredRegions {
    return SportsRegion.values
        .where((r) => r.hasLeaguesForSport(_selectedSportType))
        .toList();
  }

  /// 필터링된 리그 목록 (선택된 종목의 리그만)
  List<LeagueInfo> get _filteredLeagues {
    return _selectedRegion?.leaguesForSport(_selectedSportType) ?? [];
  }

  // 현재 단계 (1: 지역, 2: 리그, 3: 경기)
  int get _currentStep {
    if (_selectedRegion == null) return 1;
    if (_selectedLeague == null) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 420),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 + 단계 표시
          _buildHeader(colors, typography),

          const SizedBox(height: DSSpacing.sm),

          // 현재 단계 콘텐츠
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildCurrentStepContent(colors, typography),
            ),
          ),

          // 선택 버튼 (경기 선택 후)
          if (_selectedGame != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSelectButton(colors, typography),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(DSColorScheme colors, DSTypographyScheme typography) {
    return Row(
      children: [
        // 뒤로 가기 버튼 (2단계, 3단계에서)
        if (_currentStep > 1)
          GestureDetector(
            onTap: _goBack,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: colors.textSecondary,
              ),
            ),
          ),
        if (_currentStep > 1) const SizedBox(width: DSSpacing.xs),

        // 현재 선택 표시
        Expanded(
          child: _buildBreadcrumb(colors, typography),
        ),

        // 단계 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DSRadius.sm),
          ),
          child: Text(
            '$_currentStep/3',
            style: typography.labelSmall.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb(DSColorScheme colors, DSTypographyScheme typography) {
    final parts = <String>[];

    if (_selectedRegion != null) {
      parts.add('${_selectedRegion!.emoji} ${_selectedRegion!.displayName}');
    }
    if (_selectedLeague != null) {
      parts.add('${_selectedLeague!.emoji} ${_selectedLeague!.id}');
    }

    if (parts.isEmpty) {
      return Text(
        '🏟️ 경기 선택',
        style: typography.headingSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      );
    }

    return Text(
      parts.join(' > '),
      style: typography.bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCurrentStepContent(
      DSColorScheme colors, DSTypographyScheme typography) {
    switch (_currentStep) {
      case 1:
        return _buildRegionSelection(colors, typography);
      case 2:
        return _buildLeagueSelection(colors, typography);
      case 3:
        return _buildMatchSelection(colors, typography);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Step 1: 지역 선택
  Widget _buildRegionSelection(
      DSColorScheme colors, DSTypographyScheme typography) {
    return Column(
      key: const ValueKey('region'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어느 지역 경기를 볼까요?',
          style: typography.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredRegions.length,
            itemBuilder: (context, index) {
              final region = _filteredRegions[index];
              return _buildRegionCard(region, colors, typography);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegionCard(
    SportsRegion region,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    // 선택된 종목에 해당하는 리그만 표시
    final filteredLeaguesForRegion = region.leaguesForSport(_selectedSportType);
    final leagueNames = filteredLeaguesForRegion.map((l) => l.id).join(', ');

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRegion = region;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DSSpacing.sm),
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Text(
              region.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region.displayName,
                    style: typography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    leagueNames,
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: 리그 선택
  Widget _buildLeagueSelection(
      DSColorScheme colors, DSTypographyScheme typography) {
    // 선택된 종목에 해당하는 리그만 표시
    final leagues = _filteredLeagues;

    return Column(
      key: const ValueKey('league'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어느 리그 경기를 볼까요?',
          style: typography.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Expanded(
          child: ListView.builder(
            itemCount: leagues.length,
            itemBuilder: (context, index) {
              final league = leagues[index];
              return _buildLeagueCard(league, colors, typography);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueCard(
    LeagueInfo league,
    DSColorScheme colors,
    DSTypographyScheme typography,
  ) {
    final teamCount = getTeamsByLeague(league.id).length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLeague = league;
          _selectedGame = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DSSpacing.sm),
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: colors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Text(
              league.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    league.id,
                    style: typography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${league.displayName} · $teamCount팀',
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Step 3: 경기 선택
  Widget _buildMatchSelection(
      DSColorScheme colors, DSTypographyScheme typography) {
    if (_selectedLeague == null) return const SizedBox.shrink();

    final matchListAsync =
        ref.watch(matchListByLeagueProvider(_selectedLeague!.id));
    final isDark = context.isDark;

    return Column(
      key: const ValueKey('match'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${_selectedLeague!.emoji} ${_selectedLeague!.id}',
              style: typography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                '이번 주',
                style: typography.labelSmall.copyWith(
                  color: colors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        Expanded(
          child: matchListAsync.when(
            data: (games) {
              if (games.isEmpty) {
                return _buildEmptyState(colors, typography);
              }

              // 날짜별 그룹핑
              final groupedGames = _groupByDate(games);

              return ListView.builder(
                itemCount: groupedGames.length,
                itemBuilder: (context, index) {
                  final entry = groupedGames.entries.toList()[index];
                  return _buildDateGroup(
                    context,
                    entry.key,
                    entry.value,
                    colors,
                    typography,
                    isDark,
                  );
                },
              );
            },
            loading: () => _buildLoading(colors),
            error: (e, _) => _buildError(colors, typography, e),
          ),
        ),
      ],
    );
  }

  Map<String, List<SportsGame>> _groupByDate(List<SportsGame> games) {
    final grouped = <String, List<SportsGame>>{};

    for (final game in games) {
      final dateKey = _formatDateKey(game.gameTime);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(game);
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDay = DateTime(date.year, date.month, date.day);

    if (gameDay == today) {
      return '오늘 (${date.month}/${date.day} $weekday)';
    } else if (gameDay == today.add(const Duration(days: 1))) {
      return '내일 (${date.month}/${date.day} $weekday)';
    } else {
      return '${date.month}/${date.day} ($weekday)';
    }
  }

  Widget _buildDateGroup(
    BuildContext context,
    String dateLabel,
    List<SportsGame> games,
    DSColorScheme colors,
    DSTypographyScheme typography,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 라벨
        Padding(
          padding: const EdgeInsets.only(
            top: DSSpacing.sm,
            bottom: DSSpacing.xs,
          ),
          child: Text(
            dateLabel,
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 경기 카드들
        ...games.map((game) => _buildGameCard(
              context,
              game,
              colors,
              typography,
              isDark,
            )),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    SportsGame game,
    DSColorScheme colors,
    DSTypographyScheme typography,
    bool isDark,
  ) {
    final isSelected = _selectedGame?.id == game.id;
    final hour = game.gameTime.hour.toString().padLeft(2, '0');
    final minute = game.gameTime.minute.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGame = isSelected ? null : game;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DSSpacing.xs),
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.selectionBackground
              : isDark
                  ? colors.backgroundSecondary
                  : colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.md),
          border: Border.all(
            color: isSelected
                ? colors.selectionBorder
                : colors.textPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 시간
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Text(
                '$hour:$minute',
                textAlign: TextAlign.center,
                style: typography.labelMedium.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(width: DSSpacing.sm),

            // 팀 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.matchTitle,
                    style: typography.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.venue,
                    style: typography.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 선택 체크
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.selectionMutedForeground,
                size: 22,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: colors.textSecondary.withValues(alpha: 0.3),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectButton(
      DSColorScheme colors, DSTypographyScheme typography) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedGame != null && _selectedLeague != null) {
            widget.onSelect(_selectedGame!, _selectedLeague!.id);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.ctaForeground,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
        ),
        child: Text(
          '이 경기로 선택',
          style: typography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.ctaForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(DSColorScheme colors, DSTypographyScheme typography) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_outlined,
            size: 48,
            color: colors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: DSSpacing.md),
          Text(
            '예정된 경기가 없어요',
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(DSColorScheme colors) {
    return Center(
      child: CircularProgressIndicator(
        color: colors.accent,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildError(
      DSColorScheme colors, DSTypographyScheme typography, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: colors.error,
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '경기 정보를 불러올 수 없어요',
            style: typography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    setState(() {
      if (_selectedLeague != null) {
        _selectedLeague = null;
        _selectedGame = null;
      } else if (_selectedRegion != null) {
        _selectedRegion = null;
      }
    });
  }
}
