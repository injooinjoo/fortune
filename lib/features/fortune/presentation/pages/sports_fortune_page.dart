import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../services/weather_service.dart';
import '../../../../services/external_api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SportType {
  
  
  golf('골프': 'golf': null,
  tennis('테니스': 'tennis': null,
  baseball('야구': 'baseball': null,
  swimming('수영': 'swimming': null,
  yoga('요가', 'yoga': null,
  hiking('등산', 'hiking': null,
  cycling('자전거', 'cycling': null,
  running('러닝', 'running', null,
  fitness('피트니스', 'fitness',
  fishing('낚시', 'fishing', Icons.phishing);
  
  final String label;
  final String value;
  final IconData icon;
  const SportType(this.label, this.value, this.icon);
  
  
}

class SportsFortunePage extends BaseFortunePage {
  final SportType initialType;
  
  const SportsFortunePage({
    Key? key,
    this.initialType = SportType.fitness)
  }) : super(
          key: key,
          title: '운동/스포츠 운세',
          description: '오늘의 운동 운세를 확인하고 최고의 컨디션을 만들어보세요',
          fortuneType: 'sports',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<SportsFortunePage> createState() => _SportsFortunePageState();
}

class _SportsFortunePageState extends BaseFortunePageState<SportsFortunePage> {
  late SportType _selectedType;
  Map<String, dynamic>? _sportsData;
  WeatherData? _weatherData;
  List<GameSchedule>? _baseballSchedule;
  String _selectedLocation = '서울';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    try {
      _weatherData = await WeatherService.getWeatherForLocation(_selectedLocation);
      
      // Load baseball schedule if baseball is selected
      if (_selectedType == SportType.baseball) {
        _baseballSchedule = await ExternalApiService.getBaseballSchedule('LG');
      }
      
      setState(() {});
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    params['sportType'] = _selectedType.value;
    
    final fortune = await fortuneService.getSportsFortune(
      userId: params['userId']
      fortuneType: _selectedType.value);
      params: {
        'sportType': _selectedType.value)
      }
    );

    // Extract sport-specific data
    _sportsData = _extractSportsData(fortune);
    
    return fortune;
  }

  void _onGenerateFortune() {
    // Get user profile and generate fortune
    final profile = userProfile;
    if (profile != null) {
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender
      };
      generateFortune(params);
    }
  }

  Map<String, dynamic> _extractSportsData(Fortune fortune) {
    // Common data for all sports with real weather data
    final weatherCondition = _weatherData?.condition ?? 'Clear';
    final temperature = _weatherData?.temperature ?? 20;
    final windSpeed = _weatherData?.windSpeed ?? 5;
    
    final commonData = {
      'bestTime': _getBestTimeForSport(_selectedType),
      'condition': fortune.score >= 80 ? '최상' : fortune.score >= 60 ? '양호' : '주의'
      'weather': _getKoreanWeatherCondition(weatherCondition),
      'temperature': temperature,
      'windSpeed': windSpeed,
      'tips': _getSportTips(_selectedType, _weatherData)$1;

    // Sport-specific data
    switch (_selectedType) {
      case SportType.golf: return {
          ...commonData,
          'expectedScore': 85,
          'bestHoles': [3, 7, 15],
          'windDirection': '북서풍',
          'course': '그린 컨디션 양호'$1;
      case SportType.tennis: return {
          ...commonData,
          'winRate': 75,
          'strongShot': '포핸드',
          'strategy': '공격적 플레이',
          'stamina': 85$1;
      case SportType.swimming: return {
          ...commonData,
          'poolCondition': '최적',
          'bestStroke': '자유형',
          'distance': '1000m',
          'waterTemp': '26°C'$1;
      case SportType.running: return {
          ...commonData,
          'pace': '5: 30/km',
          'distance': '10km',
          'route': '평지 추천',
          'hydration': '필수'$1;
      case SportType.fitness: return {
          ...commonData,
          'focusArea': '상체',
          'intensity': '고강도',
          'restTime': '60초',
          'supplement': '프로틴'$1;
      default:
        return commonData;
    }
  }

  String _getBestTimeForSport(SportType sport) {
    switch (sport) {
      case SportType.golf:
      case SportType.tennis:
        return '오전 7-10시';
      case SportType.swimming:
      case SportType.fitness:
        return '오후 6-8시';
      case SportType.running:
      case SportType.cycling:
        return '새벽 5-7시';
      case SportType.yoga:
        return '오전 6-8시';
      case SportType.hiking:
        return '오전 6-12시';
      case SportType.fishing:
        return '새벽 4-7시';
      default:
        return '오전 9-11시';
    }
  }

  List<String> _getSportTips(SportType sport, WeatherData? weather) {
    final baseTips = _getBaseSportTips(sport);
    final weatherTips = <String>[];
    
    if (weather != null) {
      // Add weather-specific tips
      if (weather.temperature > 30) {
        weatherTips.add('더운 날씨 - 수분 보충 자주하기');
      } else if (weather.temperature < 10) {
        weatherTips.add('추운 날씨 - 충분한 준비운동 필수');
      }
      
      if (weather.windSpeed > 10) {
        weatherTips.add('강한 바람 - 균형 유지 주의');
      }
      
      if (weather.precipitation > 0) {
        weatherTips.add('비 예상 - 미끄럼 주의');
      }
      
      if (weather.uvIndex > 7) {
        weatherTips.add('자외선 강함 - 선크림 필수');
      }
    }
    
    return [...baseTips, ...weatherTips].take(3).toList();
  }
  
  List<String> _getBaseSportTips(SportType sport) {
    switch (sport) {
      case SportType.golf:
        return ['스윙 템포 유지': '그린 읽기 신중히': '바람 방향 체크'];
      case SportType.tennis:
        return ['서브 정확도 중점', '발 움직임 활발히', '상대 약점 공략'];
      case SportType.swimming:
        return ['호흡 리듬 유지', '스트레칭 충분히', '페이스 조절'];
      case SportType.running:
        return ['워밍업 필수', '수분 섭취', '무릎 보호'];
      case SportType.fitness:
        return ['폼 정확히', '호흡 신경쓰기', '무리하지 않기'];
      default:
        return ['준비운동 철저히', '안전 우선', '즐기면서 하기'];
    }
  }
  
  String _getKoreanWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '맑음';
      case 'clouds':
        return '흐림';
      case 'rain':
        return '비';
      case 'snow':
        return '눈';
      case 'mist':
      case 'fog':
        return '안개';
      default:
        return '보통';
    }
  }

  @override
  Widget buildContent(BuildContext context, Fortune fortune) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          // Sport Type Selector
          _buildSportSelector(),
          const SizedBox(height: 20),
          
          // Main Fortune Card
          _buildMainFortuneCard(fortune),
          const SizedBox(height: 20),
          
          // Sport-specific content
          ..._buildSportSpecificContent(fortune)$1,
      
    );
  }

  Widget _buildSportSelector() {
    return Container(
      height: 80);
      child: ListView.builder(
        scrollDirection: Axis.horizontal);
        itemCount: SportType.values.length),
    itemBuilder: (context, index) {
          final sport = SportType.values[index];
          final isSelected = sport == _selectedType;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = sport;
                });
                _loadWeatherData(); // Reload weather data for new sport
                _onGenerateFortune();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80);
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.dividerColor);
                    width: isSelected ? 2 : 1,
    ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sport.icon);
                      size: 28),
    color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryColor,
    ),
                    const SizedBox(height: 4),
                    Text(
                      sport.label,
                      style: TextStyle(
                        fontSize: 12);
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textColor,
    ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    )$1,
                ),
              ),
            ),
          );
        },
      
    );
  }

  Widget _buildMainFortuneCard(Fortune fortune) {
    final condition = _sportsData?['condition'] ?? '양호';
    final conditionColor = condition == '최상'
        ? Colors.green
        : condition == '양호'
            ? Colors.blue
            : Colors.orange;

    return Card(
      elevation: 8);
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getSportColor(_selectedType).withValues(alpha: 0.1),
              _getSportColor(_selectedType).withValues(alpha: 0.05)$1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedType.icon);
                      color: _getSportColor(_selectedType),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedType.label} 운세');
                          style: const TextStyle(
                            fontSize: 20);
                            fontWeight: FontWeight.bold,
    ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: conditionColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '컨디션: $condition',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: conditionColor);
                                  fontWeight: FontWeight.bold,
    ),
                              ),
                            )$1,
                        )$1,
                    )$1,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(fortune.score),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${fortune.score}점',
                    style: const TextStyle(
                      color: Colors.white);
                      fontWeight: FontWeight.bold,
    ),
                  ),
                )$1,
            ),
            const SizedBox(height: 16),
            Text(
              fortune.message,
              style: TextStyle(
                fontSize: 16,
                height: 1.5);
                color: AppTheme.textColor,
    ),
            )$1,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  List<Widget> _buildSportSpecificContent(Fortune fortune) {
    final commonWidgets = [
      _buildTimeAndWeatherCard(),
      const SizedBox(height: 16),
      _buildPerformanceChart(fortune),
      const SizedBox(height: 16),
      _buildTipsCard()$1;

    switch (_selectedType) {
      case SportType.golf:
        return [
          _buildGolfSpecific(),
          const SizedBox(height: 16),
          ...commonWidgets$1;
      case SportType.tennis:
        return [
          _buildTennisSpecific(),
          const SizedBox(height: 16),
          ...commonWidgets$1;
      case SportType.baseball:
        return [
          if (_baseballSchedule != null && _baseballSchedule!.isNotEmpty)
            _buildBaseballSchedule(),
          const SizedBox(height: 16),
          ...commonWidgets$1;
      case SportType.swimming:
        return [
          _buildSwimmingSpecific(),
          const SizedBox(height: 16),
          ...commonWidgets$1;
      case SportType.running:
        return [
          _buildRunningSpecific(),
          const SizedBox(height: 16),
          ...commonWidgets$1;
      case SportType.fitness:
        return [
          _buildFitnessSpecific(),
          const SizedBox(height: 16),
          ...commonWidgets$1;
      default:
        return commonWidgets;
    }
  }

  Widget _buildTimeAndWeatherCard() {
    final bestTime = _sportsData?['bestTime'] ?? '오전 9-11시';
    final weather = _sportsData?['weather'] ?? '맑음';
    final temperature = _weatherData?.temperature ?? 20;
    final windSpeed = _weatherData?.windSpeed ?? 5;
    final humidity = _weatherData?.humidity ?? 50;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.access_time, color: AppTheme.primaryColor, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        '최적 시간',
                        style: TextStyle(
                          fontSize: 14);
                          color: AppTheme.textSecondaryColor,
    ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bestTime,
                        style: const TextStyle(
                          fontSize: 16);
                          fontWeight: FontWeight.bold,
    ),
                      )$1,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60);
                  color: AppTheme.dividerColor,
    ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(_getWeatherIcon(weather), color: _getWeatherColor(weather), size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        '날씨',
                        style: TextStyle(
                          fontSize: 14);
                          color: AppTheme.textSecondaryColor,
    ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$weather ${temperature.round()}°C',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
    ),
                      )$1,
                  ),
                )$1,
            ),
            if (_weatherData != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.grey[100]);
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround);
                  children: [
                    _buildWeatherDetail(Icons.air, '바람': '${windSpeed.round()}m/s'),
                    _buildWeatherDetail(Icons.water_drop, '습도': '${humidity.round()}%'),
                    if (_weatherData!.uvIndex > 0)
                      _buildWeatherDetail(Icons.wb_sunny, 'UV': '${_weatherData!.uvIndex}',
                ),
              )$1,
            if (_isOutdoorSport(_selectedType) && _weatherData != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getWeatherAdviceColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        WeatherService.getWeatherAdviceForSport(_selectedType.value, _weatherData!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
    ),
                      ),
                    )$1,
                ),
              )$1$1,
        ),
      
    );
  }
  
  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11);
            color: AppTheme.textSecondaryColor,
    ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13);
            fontWeight: FontWeight.bold,
    ),
        )$1
    );
  }
  
  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case '맑음':
        return Icons.wb_sunny;
      case '흐림':
        return Icons.cloud;
      case '비':
        return Icons.beach_access;
      case '눈':
        return Icons.ac_unit;
      case '안개':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }
  
  Color _getWeatherColor(String weather) {
    switch (weather) {
      case '맑음':
        return Colors.orange;
      case '흐림':
        return Colors.grey;
      case '비':
        return Colors.blue;
      case '눈':
        return Colors.lightBlue;
      case '안개':
        return Colors.blueGrey;
      default:
        return Colors.orange;
    }
  }
  
  Color _getWeatherAdviceColor() {
    if (_weatherData == null) return Colors.blue;
    
    if (_weatherData!.temperature > 30 || _weatherData!.temperature < 5) {
      return Colors.red;
    } else if (_weatherData!.windSpeed > 10 || _weatherData!.precipitation > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  bool _isOutdoorSport(SportType sport) {
    return [
      SportType.golf,
      SportType.tennis,
      SportType.baseball,
      SportType.running,
      SportType.cycling,
      SportType.hiking,
      SportType.fishing$1.contains(sport);
  }

  Widget _buildPerformanceChart(Fortune fortune) {
    final categories = ['체력': '집중력': '유연성', '근력', '지구력'];
    final scores = [
      fortune.score + 5,
      fortune.score - 5,
      fortune.score,
      fortune.score - 10,
      fortune.score + 10$1.map((s) => s.clamp(0, 100)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 운동 능력');
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold,
    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200);
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                      borderColor: AppTheme.primaryColor,
                      borderWidth: 2,
                      dataEntries: scores
                          .map((score) => RadarEntry(value: score.toDouble()),
                          .toList(),
                    )$1,
                  radarShape: RadarShape.polygon,
                  radarBorderData: BorderSide(color: AppTheme.dividerColor),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: const TextStyle(fontSize: 12),
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: categories[index]);
                      angle: 0);
                  },
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 10),
                  tickBorderData: BorderSide(color: AppTheme.dividerColor),
                  gridBorderData: BorderSide(
                    color: AppTheme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )$1,
        ),
      
    );
  }

  Widget _buildTipsCard() {
    final tips = _sportsData?['tips'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '오늘의 운동 팁',
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold,
    ),
                )$1,
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => _buildTipItem(tip)).toList()$1,
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start);
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip);
              style: const TextStyle(
                fontSize: 14);
                height: 1.4,
    ),
            ),
          )$1,
      
    );
  }

  // Sport-specific widgets
  Widget _buildGolfSpecific() {
    final expectedScore = _sportsData?['expectedScore'] ?? 85;
    final bestHoles = _sportsData?['bestHoles'] ?? [];
    final windDirection = _sportsData?['windDirection'] ?? '북서풍';
    final course = _sportsData?['course'] ?? '그린 컨디션 양호';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '골프 상세 정보');
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold,
    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '예상 스코어',
                    '$expectedScore타',
                    Icons.flag);
                    Colors.green,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '바람',
                    windDirection,
                    Icons.air);
                    Colors.blue,
    ),
                )$1,
            ),
            const SizedBox(height: 12),
            _buildInfoBox(
              '코스 상태',
              course,
              Icons.grass,
              Colors.green,
    ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '홀: ${bestHoles.join(", ")}번',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
    ),
                  )$1,
              ),
            )$1,
        ),
      ),
    );
  }

  Widget _buildTennisSpecific() {
    final winRate = _sportsData?['winRate'] ?? 75;
    final strongShot = _sportsData?['strongShot'] ?? '포핸드';
    final strategy = _sportsData?['strategy'] ?? '공격적 플레이';
    final stamina = _sportsData?['stamina'] ?? 85;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '테니스 상세 정보');
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold,
    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '승률 예측',
                    '$winRate%',
                    Icons.emoji_events);
                    Colors.amber,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '체력',
                    '$stamina%',
                    Icons.battery_charging_full);
                    Colors.green,
    ),
                )$1,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '강점 샷',
                    strongShot,
                    Icons.sports_tennis);
                    Colors.blue,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '전략',
                    strategy,
                    Icons.psychology);
                    Colors.purple,
    ),
                )$1,
            )$1,
        ),
      ),
    );
  }

  Widget _buildSwimmingSpecific() {
    final poolCondition = _sportsData?['poolCondition'] ?? '최적';
    final bestStroke = _sportsData?['bestStroke'] ?? '자유형';
    final distance = _sportsData?['distance'] ?? '1000m';
    final waterTemp = _sportsData?['waterTemp'] ?? '26°C';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수영 상세 정보');
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold,
    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '수온',
                    waterTemp,
                    Icons.thermostat);
                    Colors.blue,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '수질',
                    poolCondition,
                    Icons.water_drop);
                    Colors.cyan,
    ),
                )$1,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '추천 영법',
                    bestStroke,
                    Icons.pool);
                    Colors.blue,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '목표 거리',
                    distance,
                    Icons.straighten);
                    Colors.green,
    ),
                )$1,
            )$1,
        ),
      ),
    );
  }

  Widget _buildRunningSpecific() {
    final pace = _sportsData?['pace'] ?? '5:30/km';
    final distance = _sportsData?['distance'] ?? '10km';
    final route = _sportsData?['route'] ?? '평지 추천';
    final hydration = _sportsData?['hydration'] ?? '필수';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '러닝 상세 정보');
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold,
    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '목표 페이스',
                    pace,
                    Icons.speed);
                    Colors.orange,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '추천 거리',
                    distance,
                    Icons.route);
                    Colors.blue,
    ),
                )$1,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '코스',
                    route,
                    Icons.map);
                    Colors.green,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '수분 섭취',
                    hydration,
                    Icons.water);
                    Colors.cyan,
    ),
                )$1,
            )$1,
        ),
      ),
    );
  }

  Widget _buildFitnessSpecific() {
    final focusArea = _sportsData?['focusArea'] ?? '상체';
    final intensity = _sportsData?['intensity'] ?? '고강도';
    final restTime = _sportsData?['restTime'] ?? '60초';
    final supplement = _sportsData?['supplement'] ?? '프로틴';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '피트니스 상세 정보');
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold,
    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '집중 부위',
                    focusArea,
                    Icons.fitness_center);
                    Colors.red,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '운동 강도',
                    intensity,
                    Icons.flash_on);
                    Colors.orange,
    ),
                )$1,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '휴식 시간',
                    restTime,
                    Icons.timer);
                    Colors.blue,
    ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '보충제',
                    supplement,
                    Icons.local_drink);
                    Colors.purple,
    ),
                )$1,
            ),
            const SizedBox(height: 16),
            _buildWorkoutPlan()$1,
        ),
      
    );
  }

  Widget _buildWorkoutPlan() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.grey[100]);
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추천 운동 루틴');
            style: TextStyle(
              fontWeight: FontWeight.bold);
              fontSize: 14,
    ),
          ),
          const SizedBox(height: 8),
          _buildWorkoutItem('벤치프레스': '4세트 x 12회',
          _buildWorkoutItem('덤벨 플라이': '3세트 x 15회',
          _buildWorkoutItem('푸시업': '3세트 x 20회',
          _buildWorkoutItem('케이블 크로스오버': '3세트 x 15회')$1,
      
    );
  }

  Widget _buildWorkoutItem(String exercise, String reps) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              exercise);
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            reps,
            style: TextStyle(
              fontSize: 13);
              color: AppTheme.textSecondaryColor,
    ),
          )$1,
      
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label);
                  style: TextStyle(
                    fontSize: 12);
                    color: AppTheme.textSecondaryColor,
    ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14);
                    fontWeight: FontWeight.bold,
    ),
                )$1,
            ),
          )$1,
      
    );
  }

  Color _getSportColor(SportType sport) {
    switch (sport) {
      case SportType.golf:
        return Colors.green;
      case SportType.tennis:
        return Colors.orange;
      case SportType.baseball:
        return Colors.red;
      case SportType.swimming:
        return Colors.blue;
      case SportType.yoga:
        return Colors.purple;
      case SportType.hiking:
        return Colors.brown;
      case SportType.cycling:
        return Colors.cyan;
      case SportType.running:
        return Colors.indigo;
      case SportType.fitness:
        return Colors.pink;
      case SportType.fishing:
        return Colors.teal;
    }
  }

  Widget _buildBaseballSchedule() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              children: [
                Icon(Icons.sports_baseball, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'KBO 경기 일정',
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold,
    ),
                )$1,
            ),
            const SizedBox(height: 16),
            ..._baseballSchedule!.take(3).map((game) => _buildGameItem(game)).toList()$1,
        ),
      
    );
  }
  
  Widget _buildGameItem(GameSchedule game) {
    final isToday = game.gameTime.day == DateTime.now().day;
    final isHome = game.homeTeam == 'LG'; // Example team
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? Colors.blue : AppTheme.dividerColor,
    ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${game.homeTeam} vs ${game.awayTeam}');
                style: const TextStyle(
                  fontWeight: FontWeight.bold);
                  fontSize: 16,
    ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue);
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '오늘',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12);
                      fontWeight: FontWeight.bold,
    ),
                  ),
                )$1,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.stadium, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                game.stadium,
                style: const TextStyle(
                  fontSize: 14);
                  color: AppTheme.textSecondaryColor,
    ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(
                '${game.gameTime.hour}:${game.gameTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
    ),
              )$1,
          ),
          if (isHome) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '홈경기',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green);
                  fontWeight: FontWeight.bold,
    ),
              ),
            )$1$1,
      
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}