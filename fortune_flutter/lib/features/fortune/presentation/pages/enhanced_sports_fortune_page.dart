import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// Sport category enum
enum SportCategory {
  ballGames('구기 종목', Icons.sports_soccer),
  leisure('레저 스포츠', Icons.directions_bike),
  indoor('실내 운동', Icons.fitness_center),
  eSports('e스포츠', Icons.sports_esports);

  final String label;
  final IconData icon;
  const SportCategory(this.label, this.icon);
}

// Sport item model
class SportItem {
  final String name;
  final String id;
  final IconData icon;
  final List<Color> gradientColors;
  final SportCategory category;
  final List<String>? teams; // For ball games
  final bool hasWeatherInfo;

  const SportItem({
    required this.name,
    required this.id,
    required this.icon,
    required this.gradientColors,
    required this.category,
    this.teams,
    this.hasWeatherInfo = true,
  });
}

class EnhancedSportsFortunePage extends BaseFortunePage {
  const EnhancedSportsFortunePage({
    Key? key,
  }) : super(
          key: key,
          title: '스포츠 운세',
          description: '오늘의 스포츠 운세를 확인하고 최고의 경기력을 발휘하세요',
          fortuneType: 'sports',
          requiresUserInfo: true,
        );

  @override
  ConsumerState<EnhancedSportsFortunePage> createState() => _EnhancedSportsFortunePageState();
}

class _EnhancedSportsFortunePageState extends BaseFortunePageState<EnhancedSportsFortunePage> 
    with TickerProviderStateMixin {
  
  // All sports items
  final List<SportItem> allSports = [
    // Ball Games
    SportItem(
      name: '야구 (국내)',
      id: 'baseball_kr',
      icon: Icons.sports_baseball,
      gradientColors: [Color(0xFFE53E3E), Color(0xFFC53030)],
      category: SportCategory.ballGames,
      teams: ['LG', '두산', 'KT', '삼성', 'SSG', '롯데', 'NC', '한화', 'KIA', '키움'],
    ),
    SportItem(
      name: '야구 (해외)',
      id: 'baseball_intl',
      icon: Icons.sports_baseball,
      gradientColors: [Color(0xFF2B6CB0), Color(0xFF1E4E8C)],
      category: SportCategory.ballGames,
      teams: ['양키스', '다저스', '레드삭스', '자이언츠', '컵스'],
    ),
    SportItem(
      name: '축구 (국내)',
      id: 'soccer_kr',
      icon: Icons.sports_soccer,
      gradientColors: [Color(0xFF48BB78), Color(0xFF38A169)],
      category: SportCategory.ballGames,
      teams: ['울산', '전북', '포항', '인천', '서울', '수원', '대구', '강원', '제주', '광주'],
    ),
    SportItem(
      name: '축구 (해외)',
      id: 'soccer_intl',
      icon: Icons.sports_soccer,
      gradientColors: [Color(0xFF805AD5), Color(0xFF6B46C1)],
      category: SportCategory.ballGames,
      teams: ['맨유', '맨시티', '첼시', '리버풀', '아스날', '토트넘', '바르샤', '레알'],
    ),
    SportItem(
      name: '농구 (국내)',
      id: 'basketball_kr',
      icon: Icons.sports_basketball,
      gradientColors: [Color(0xFFED8936), Color(0xFFDD6B20)],
      category: SportCategory.ballGames,
      teams: ['서울SK', 'LG', '삼성', 'KT', '현대모비스', 'KCC', '한국가스공사', '원주DB', '안양정관장'],
    ),
    SportItem(
      name: '농구 (해외)',
      id: 'basketball_intl',
      icon: Icons.sports_basketball,
      gradientColors: [Color(0xFF9F7AEA), Color(0xFF805AD5)],
      category: SportCategory.ballGames,
      teams: ['레이커스', '셀틱스', '워리어스', '불스', '히트', '넷츠'],
    ),
    SportItem(
      name: '배구',
      id: 'volleyball',
      icon: Icons.sports_volleyball,
      gradientColors: [Color(0xFF4299E1), Color(0xFF3182CE)],
      category: SportCategory.ballGames,
      teams: ['현대건설', '흥국생명', 'GS칼텍스', 'IBK', '한국도로공사', 'KGC인삼공사', '페퍼저축은행'],
    ),
    SportItem(
      name: '테니스',
      id: 'tennis',
      icon: Icons.sports_tennis,
      gradientColors: [Color(0xFFF56565), Color(0xFFE53E3E)],
      category: SportCategory.ballGames,
    ),
    SportItem(
      name: '골프',
      id: 'golf',
      icon: Icons.golf_course,
      gradientColors: [Color(0xFF48BB78), Color(0xFF38A169)],
      category: SportCategory.ballGames,
    ),
    
    // Leisure Sports
    SportItem(
      name: '낚시',
      id: 'fishing',
      icon: Icons.phishing,
      gradientColors: [Color(0xFF4299E1), Color(0xFF3182CE)],
      category: SportCategory.leisure,
    ),
    SportItem(
      name: '자전거',
      id: 'cycling',
      icon: Icons.directions_bike,
      gradientColors: [Color(0xFFED8936), Color(0xFFDD6B20)],
      category: SportCategory.leisure,
    ),
    SportItem(
      name: '등산',
      id: 'hiking',
      icon: Icons.terrain,
      gradientColors: [Color(0xFF38B2AC), Color(0xFF319795)],
      category: SportCategory.leisure,
    ),
    SportItem(
      name: '수영',
      id: 'swimming',
      icon: Icons.pool,
      gradientColors: [Color(0xFF63B3ED), Color(0xFF4299E1)],
      category: SportCategory.leisure,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '요가',
      id: 'yoga',
      icon: Icons.self_improvement,
      gradientColors: [Color(0xFF9F7AEA), Color(0xFF805AD5)],
      category: SportCategory.leisure,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '러닝',
      id: 'running',
      icon: Icons.directions_run,
      gradientColors: [Color(0xFFF687B3), Color(0xFFED64A6)],
      category: SportCategory.leisure,
    ),
    
    // Indoor Sports
    SportItem(
      name: '헬스/피트니스',
      id: 'fitness',
      icon: Icons.fitness_center,
      gradientColors: [Color(0xFFFC8181), Color(0xFFF56565)],
      category: SportCategory.indoor,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '배드민턴',
      id: 'badminton',
      icon: Icons.sports_tennis,
      gradientColors: [Color(0xFF4FD1C5), Color(0xFF38B2AC)],
      category: SportCategory.indoor,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '탁구',
      id: 'table_tennis',
      icon: Icons.sports_tennis,
      gradientColors: [Color(0xFFFBB6CE), Color(0xFFF687B3)],
      category: SportCategory.indoor,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '볼링',
      id: 'bowling',
      icon: Icons.sports,
      gradientColors: [Color(0xFFB794F4), Color(0xFF9F7AEA)],
      category: SportCategory.indoor,
      hasWeatherInfo: false,
    ),
    
    // E-Sports
    SportItem(
      name: '리그오브레전드',
      id: 'lol',
      icon: Icons.sports_esports,
      gradientColors: [Color(0xFF667EEA), Color(0xFF5A67D8)],
      category: SportCategory.eSports,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '오버워치',
      id: 'overwatch',
      icon: Icons.sports_esports,
      gradientColors: [Color(0xFFF6AD55), Color(0xFFED8936)],
      category: SportCategory.eSports,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '배틀그라운드',
      id: 'pubg',
      icon: Icons.sports_esports,
      gradientColors: [Color(0xFF68D391), Color(0xFF48BB78)],
      category: SportCategory.eSports,
      hasWeatherInfo: false,
    ),
    SportItem(
      name: '발로란트',
      id: 'valorant',
      icon: Icons.sports_esports,
      gradientColors: [Color(0xFFFC8181), Color(0xFFF56565)],
      category: SportCategory.eSports,
      hasWeatherInfo: false,
    ),
  ];

  SportCategory _selectedCategory = SportCategory.ballGames;
  SportItem? _selectedSport;
  String? _selectedTeam;
  late TabController _tabController;
  final Map<String, Fortune?> _fortuneCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: SportCategory.values.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = SportCategory.values[_tabController.index];
        _selectedSport = null;
        _selectedTeam = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SportItem> get filteredSports =>
      allSports.where((sport) => sport.category == _selectedCategory).toList();

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add sport-specific parameters
    params['sportType'] = _selectedSport?.id ?? 'general';
    if (_selectedTeam != null) {
      params['team'] = _selectedTeam;
    }
    
    final cacheKey = '${_selectedSport?.id}_${_selectedTeam ?? 'personal'}';
    
    final fortune = await fortuneService.getSportsFortune(
      userId: params['userId'],
      fortuneType: _selectedSport?.id ?? 'general',
      params: params,
    );
    
    // Cache the fortune
    setState(() {
      _fortuneCache[cacheKey] = fortune;
    });
    
    return fortune;
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // Header with gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                tabs: SportCategory.values.map((category) {
                  return Tab(
                    icon: Icon(category.icon),
                    text: category.label,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category description
                _buildCategoryDescription()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 20),
                
                // Sports grid
                _buildSportsGrid(),
                
                // Selected sport details
                if (_selectedSport != null) ...[
                  const SizedBox(height: 24),
                  _buildSelectedSportSection(),
                ],
                
                // Fortune result
                if (_fortuneCache.isNotEmpty && 
                    _fortuneCache['${_selectedSport?.id}_${_selectedTeam ?? 'personal'}'] != null) ...[
                  const SizedBox(height: 24),
                  _buildFortuneResult(_fortuneCache['${_selectedSport?.id}_${_selectedTeam ?? 'personal'}']!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDescription() {
    String description;
    switch (_selectedCategory) {
      case SportCategory.ballGames:
        description = '팀별 승부운과 개인 운동 운세를 확인하세요';
        break;
      case SportCategory.leisure:
        description = '날씨와 컨디션에 맞는 최적의 운동 시간을 찾아보세요';
        break;
      case SportCategory.indoor:
        description = '오늘의 운동 효율과 부상 예방 지수를 확인하세요';
        break;
      case SportCategory.eSports:
        description = '게임 승률과 최적의 플레이 시간을 알아보세요';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _selectedCategory.icon,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCategory.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: filteredSports.length,
      itemBuilder: (context, index) {
        final sport = filteredSports[index];
        return _buildSportCard(sport, index);
      },
    );
  }

  Widget _buildSportCard(SportItem sport, int index) {
    final isSelected = _selectedSport == sport;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSport = sport;
          _selectedTeam = null; // Reset team selection
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? sport.gradientColors
                : [Colors.grey[200]!, Colors.grey[300]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: sport.gradientColors[0].withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
          border: Border.all(
            color: isSelected
                ? sport.gradientColors[0]
                : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            if (isSelected)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  sport.icon,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    sport.icon,
                    size: 36,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sport.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (sport.teams != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${sport.teams!.length}개 팀',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (50 * index).ms)
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildSelectedSportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedSport!.gradientColors[0].withValues(alpha: 0.1),
            _selectedSport!.gradientColors[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedSport!.gradientColors[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedSport!.icon,
                color: _selectedSport!.gradientColors[0],
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                _selectedSport!.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _selectedSport!.gradientColors[0],
                ),
              ),
            ],
          ),
          
          // Team selection for ball games
          if (_selectedSport!.teams != null) ...[
            const SizedBox(height: 20),
            Text(
              '팀 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildTeamSelection(),
          ],
          
          const SizedBox(height: 20),
          
          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onGenerateFortune,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: _selectedSport!.gradientColors[0],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedSport!.icon,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedTeam != null
                        ? '$_selectedTeam 운세 보기'
                        : '${_selectedSport!.name} 운세 보기',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTeamSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Personal fortune option
        _buildTeamChip('개인', isPersonal: true),
        // Team options
        ..._selectedSport!.teams!.map((team) => _buildTeamChip(team)),
      ],
    );
  }

  Widget _buildTeamChip(String team, {bool isPersonal = false}) {
    final isSelected = isPersonal ? _selectedTeam == null : _selectedTeam == team;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTeam = isPersonal ? null : team;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _selectedSport!.gradientColors[0]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _selectedSport!.gradientColors[0]
                : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          team,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildFortuneResult(Fortune fortune) {
    final isTeamFortune = _selectedTeam != null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedSport!.gradientColors[0].withValues(alpha: 0.1),
            _selectedSport!.gradientColors[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedSport!.gradientColors[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedSport!.icon,
                color: _selectedSport!.gradientColors[0],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isTeamFortune
                      ? '$_selectedTeam 운세'
                      : '${_selectedSport!.name} 개인 운세',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _selectedSport!.gradientColors[0],
                  ),
                ),
              ),
              if (fortune.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(fortune.score!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${fortune.score}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Main message
          Text(
            fortune.message,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.textColor,
            ),
          ),
          
          // Team-specific content
          if (isTeamFortune && fortune.additionalInfo != null) ...[
            const SizedBox(height: 20),
            _buildTeamFortuneDetails(fortune.additionalInfo!),
          ],
          
          // Personal sport fortune content
          if (!isTeamFortune && fortune.additionalInfo != null) ...[
            const SizedBox(height: 20),
            _buildPersonalSportDetails(fortune.additionalInfo!),
          ],
          
          // Advice
          if (fortune.advice != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fortune.advice!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTeamFortuneDetails(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Win probability
        if (details['winProbability'] != null)
          _buildDetailItem(
            '승리 확률',
            '${details['winProbability']}%',
            Icons.emoji_events,
            Colors.amber,
          ),
        
        // Key players
        if (details['keyPlayers'] != null)
          _buildDetailItem(
            '주목할 선수',
            details['keyPlayers'].join(', '),
            Icons.star,
            Colors.orange,
          ),
        
        // Lucky inning/time
        if (details['luckyTime'] != null)
          _buildDetailItem(
            '행운의 시간',
            details['luckyTime'],
            Icons.access_time,
            Colors.blue,
          ),
        
        // Strategy
        if (details['strategy'] != null)
          _buildDetailItem(
            '추천 전략',
            details['strategy'],
            Icons.psychology,
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildPersonalSportDetails(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Best time
        if (details['bestTime'] != null)
          _buildDetailItem(
            '최적 시간',
            details['bestTime'],
            Icons.access_time,
            Colors.blue,
          ),
        
        // Condition
        if (details['condition'] != null)
          _buildDetailItem(
            '컨디션',
            details['condition'],
            Icons.favorite,
            Colors.red,
          ),
        
        // Weather advice
        if (details['weatherAdvice'] != null && _selectedSport!.hasWeatherInfo)
          _buildDetailItem(
            '날씨 조언',
            details['weatherAdvice'],
            Icons.wb_sunny,
            Colors.orange,
          ),
        
        // Performance tips
        if (details['tips'] != null) ...[
          const SizedBox(height: 16),
          Text(
            '운동 팁',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _selectedSport!.gradientColors[0],
            ),
          ),
          const SizedBox(height: 8),
          ...List<String>.from(details['tips']).map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: _selectedSport!.gradientColors[0],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onGenerateFortune() {
    final profile = userProfile;
    if (profile != null && _selectedSport != null) {
      final cacheKey = '${_selectedSport!.id}_${_selectedTeam ?? 'personal'}';
      setState(() {
        _fortuneCache[cacheKey] = null;
      });
      
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
      };
      generateFortuneAction(params: params);
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}