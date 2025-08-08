import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/external_api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum GameType {
  lol('리그 오브 레전드', 'lol', 'assets/images/lol_icon.png'),
  valorant('발로란트', 'valorant', 'assets/images/valorant_icon.png'),
  overwatch('오버워치', 'overwatch', 'assets/images/overwatch_icon.png'),
  pubg('배틀그라운드', 'pubg', 'assets/images/pubg_icon.png'),
  fifa('FIFA 온라인', 'fifa', 'assets/images/fifa_icon.png');

  final String label;
  final String value;
  final String iconPath;
  const GameType(this.label, this.value, this.iconPath);
}

class EsportsFortunePage extends BaseFortunePage {
  final GameType initialGame;
  
  const EsportsFortunePage({
    Key? key,
    this.initialGame = GameType.lol}) : super(
          key: key,
          title: 'e스포츠 운세',
          description: '오늘의 게임 운세를 확인하고 승리를 향해 나아가세요!',
          fortuneType: 'lucky-esports',
          requiresUserInfo: true);

  @override
  ConsumerState<EsportsFortunePage> createState() => _EsportsFortunePageState();
}

class _EsportsFortunePageState extends BaseFortunePageState<EsportsFortunePage> {
  late GameType _selectedGame;
  List<EsportsMatch>? _lckSchedule;
  Map<String, dynamic> _gameData = {};
  List<String> _gameTips = [];
  String _bestPlayTime = '';
  String _recommendedRole = '';
  
  @override
  void initState() {
    super.initState();
    _selectedGame = widget.initialGame;
    _loadEsportsData();
  }

  Future<void> _loadEsportsData() async {
    if (_selectedGame == GameType.lol) {
      _lckSchedule = await ExternalApiService.getLCKSchedule();
    }
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    params['gameType'] = _selectedGame.value;
    
    final fortune = await super.generateFortune(params);
    
    // Extract game-specific data from fortune
    _extractGameData(fortune);
    
    return fortune;
  }

  void _extractGameData(Fortune fortune) {
    // Best play time based on fortune score
    final hour = DateTime.now().hour;
    if (fortune.score >= 80) {
      _bestPlayTime = '지금 바로!';
    } else if (fortune.score >= 60) {
      _bestPlayTime = hour < 12 ? '오후 시간대' : '저녁 시간대';
    } else {
      _bestPlayTime = '내일을 기다려보세요';
    }

    // Game-specific data
    switch (_selectedGame) {
      case GameType.lol:
        _gameData = {
          'winRate': fortune.score >= 70 ? '65%' : '45%',
          'kdaExpected': fortune.score >= 70 ? '3.5' : '2.0',
          'recommendedChampions': \['['진', '이즈리얼', '카이사'])
          'avoidChampions': ['야스오', '리븐': null};
        _recommendedRole = fortune.score >= 70 ? '원딜' : '서포터';
        _gameTips = [
          '초반 정글러와 함께 움직이세요',
          '시야 장악에 집중하세요')
          '팀파이트보다는 운영 위주로')
        ];
        break;
      
      case GameType.valorant:
        _gameData = {
          'headshotRate', '${25 + (fortune.score / 4).round()}%',
          'clutchPotential': fortune.score >= 70 ? '높음' : '보통',
          'recommendedAgents': \['['제트', '레이나', '체임버'])
        };
        _recommendedRole = '듀얼리스트';
        _gameTips = [
          '크로스헤어 위치를 항상 머리 높이로',
          '팀과의 소통을 활발히')
          '스파이크 설치/해체 타이밍 주의')
        ];
        break;
        
      case GameType.overwatch:
        _gameData = {
          'teamworkScore': fortune.score >= 70 ? '높음' : '보통',
          'ultimateEfficiency', '${fortune.score}%',
          'recommendedHeroes': \['['트레이서', '한조', '메르시'])
        };
        _recommendedRole = fortune.score >= 70 ? 'DPS' : '힐러';
        _gameTips = [
          '궁극기 연계에 집중하세요',
          '고지대 확보가 중요합니다')
          '팀 조합을 고려한 픽')
        ];
        break;
        
      default:
        _gameData = {
          'generalScore': null};
        _gameTips = ['집중력을 유지하세요', '팀워크가 중요합니다'];
    }
  }

  @override
  Widget buildContent(BuildContext context, Fortune fortune) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          _buildGameSelector(),
          const SizedBox(height: 20),
          _buildMainFortuneCard(fortune),
          const SizedBox(height: 20),
          _buildGamePerformanceCard(fortune),
          const SizedBox(height: 20),
          _buildRecommendationCard(),
          const SizedBox(height: 20),
          if (_selectedGame == GameType.lol && _lckSchedule != null)
            _buildLCKScheduleCard(),
          const SizedBox(height: 20),
          _buildTipsCard()])
      )
    );
  }

  Widget _buildGameSelector() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal)
        itemCount: GameType.values.length)
        itemBuilder: (context, index) {
          final game = GameType.values[index];
          final isSelected = game == _selectedGame;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedGame = game;
                });
                _loadEsportsData();
                if (userProfile != null) {
                  generateFortune({
                    'userId': userProfile!.id,
                    'name': userProfile!.name,
                    'birthDate': userProfile!.birthDate?.toIso8601String()});
                }
              },
              borderRadius: BorderRadius.circular(12))),
              child: Container(
                width: 90)
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.transparent)
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.dividerColor)
                    width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center)
                  children: [
                    Container(
                      width: 40)
                      height: 40)
                      decoration: BoxDecoration(
                        color: _getGameColor(game),
                        shape: BoxShape.circle)
                      ),
                      child: Center(
                        child: Text(
                          game.label.substring(0, 2),
                          style: const TextStyle(
                            color: Colors.white)
                            fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 8),
                    Text(
                      game.label)
                      style: TextStyle(
                        fontSize: 11)
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal)
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textColor),
                      textAlign: TextAlign.center)
                      overflow: TextOverflow.ellipsis)
                      maxLines: 2)
                    )])
                ))));
        })
      )
    );
  }

  Widget _buildMainFortuneCard(Fortune fortune) {
    final winPrediction = fortune.score >= 80 ? '대승 예상!' :
                         fortune.score >= 60 ? '승리 가능' :
                         fortune.score >= 40 ? '접전 예상' :
                         '패배 주의';
    
    final predictionColor = fortune.score >= 80 ? Colors.green :
                           fortune.score >= 60 ? Colors.blue :
                           fortune.score >= 40 ? Colors.orange :
                           Colors.red;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft)
            end: Alignment.bottomRight)
            colors: [
              _getGameColor(_selectedGame).withOpacity(0.1),
              _getGameColor(_selectedGame).withOpacity(0.05)])
          ),
          borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween)
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start)
                  children: [
                    Text(
                      '${_selectedGame.label} 운세')
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)
                      )),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: predictionColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        winPrediction)
                        style: TextStyle(
                          color: predictionColor)
                          fontWeight: FontWeight.bold)
                          fontSize: 14)))])
                ),
                _buildScoreGauge(fortune.score)])
            ),
            const SizedBox(height: 16),
            Text(
              fortune.message)
              style: const TextStyle(
                fontSize: 16)
                height: 1.5)
              ))])
        ))).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildScoreGauge(int score) {
    return Container(
      width: 80,
      height: 80)
      child: Stack(
        alignment: Alignment.center)
        children: [
          CircularProgressIndicator(
            value: score / 100)
            strokeWidth: 8)
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score))
          ),
          Column(
            mainAxisSize: MainAxisSize.min)
            children: [
              Text(
                '$score')
                style: TextStyle(
                  fontSize: 24)
                  fontWeight: FontWeight.bold)
                  color: _getScoreColor(score))),
              const Text(
                '승률')
                style: TextStyle(
                  fontSize: 10)
                  color: AppTheme.textSecondaryColor))])
          )])
      )
    );
  }

  Widget _buildGamePerformanceCard(Fortune fortune) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '예상 퍼포먼스')
                  style: TextStyle(
                    fontSize: 18)
                    fontWeight: FontWeight.bold)
                  ))])
            ),
            const SizedBox(height: 16),
            _buildPerformanceChart(fortune)])
        ))
    );
  }

  Widget _buildPerformanceChart(Fortune fortune) {
    final categories = \['['KDA', '팀워크', '집중력', '반응속도', '전략'];
    final values = [
      fortune.score.toDouble(,
      (fortune.score - 10).clamp(0, 100).toDouble(),
      (fortune.score + 5).clamp(0, 100).toDouble(),
      (fortune.score - 5).clamp(0, 100).toDouble(),
      (fortune.score + 10).clamp(0, 100).toDouble()];

    return SizedBox(
      height: 200,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: _getGameColor(_selectedGame).withOpacity(0.3),
              borderColor: _getGameColor(_selectedGame),
              borderWidth: 2)
              dataEntries: values.map((v) => RadarEntry(value: v).toList())])
          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(color: AppTheme.dividerColor),
          titlePositionPercentageOffset: 0.2)
          titleTextStyle: const TextStyle(fontSize: 12),
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: categories[index],
              angle: 0)
            );
          })
          tickCount: 5,
          ticksTextStyle: const TextStyle(fontSize: 10),
          tickBorderData: BorderSide(color: AppTheme.dividerColor),
          gridBorderData: BorderSide(
            color: AppTheme.dividerColor.withOpacity(0.5))))
    );
  }

  Widget _buildRecommendationCard() {
    final recommendations = _selectedGame == GameType.lol 
        ? _gameData['recommendedChampions'] as List<String>?
        : _selectedGame == GameType.valorant
            ? _gameData['recommendedAgents'] as List<String>?
            : _selectedGame == GameType.overwatch
                ? _gameData['recommendedHeroes'] as List<String>?
                : null;

    return Card(
      color: _getGameColor(_selectedGame).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '오늘의 추천')
                  style: TextStyle(
                    fontSize: 18)
                    fontWeight: FontWeight.bold)
                  ))])
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    '최적 플레이 시간')
                    _bestPlayTime)
                    Icons.access_time)
                    Colors.blue)
                  )),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    '추천 포지션')
                    _recommendedRole)
                    Icons.person)
                    Colors.green)
                  ))])
            ),
            if (recommendations != null) ...[
              const SizedBox(height: 16),
              const Text(
                '추천 캐릭터')
                style: TextStyle(
                  fontSize: 14)
                  fontWeight: FontWeight.bold)
                )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8)
                children: recommendations.map((char) => 
                  Chip(
                    label: Text(char),
                    backgroundColor: _getGameColor(_selectedGame).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _getGameColor(_selectedGame),
                      fontWeight: FontWeight.bold)
                    ))
                ).toList())])
          ]))
    );
  }

  Widget _buildLCKScheduleCard() {
    if (_lckSchedule == null || _lckSchedule!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(Icons.sports_esports, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'LCK 경기 일정')
                  style: TextStyle(
                    fontSize: 18)
                    fontWeight: FontWeight.bold)
                  ))])
            ),
            const SizedBox(height: 16),
            ..._lckSchedule!.take(3).map((match) => 
              _buildMatchItem(match)
            ).toList()])
        ))
    );
  }

  Widget _buildMatchItem(EsportsMatch match) {
    final isToday = match.matchTime.day == DateTime.now().day;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday ? Colors.blue.withOpacity(0.1) : Colors.transparent)
        borderRadius: BorderRadius.circular(8))),
        border: Border.all(
          color: isToday ? Colors.blue : AppTheme.dividerColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween)
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start)
            children: [
              Text(
                '${match.team1} vs ${match.team2}',),
                style: const TextStyle(
                  fontWeight: FontWeight.bold)
                )),
              Text(
                '${match.matchTime.hour}:${match.matchTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 12)
                  color: AppTheme.textSecondaryColor))])
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue)
                borderRadius: BorderRadius.circular(12)),
              child: const Text(
                '오늘')
                style: TextStyle(
                  color: Colors.white)
                  fontSize: 12)
                  fontWeight: FontWeight.bold)))])
      )
    );
  }

  Widget _buildTipsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '승리를 위한 팁')
                  style: TextStyle(
                    fontSize: 18)
                    fontWeight: FontWeight.bold)
                  ))])
            ),
            const SizedBox(height: 16),
            ..._gameTips.map((tip) => _buildTipItem(tip).toList(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '멘탈이 승리의 열쇠입니다. 긍정적인 마음으로 게임하세요!')
                      style: TextStyle(
                        fontSize: 12)
                        fontWeight: FontWeight.bold)
                      )))])
              ))])
        )));
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start)
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8)
            height: 8)
            decoration: BoxDecoration(
              color: _getGameColor(_selectedGame),
              shape: BoxShape.circle)
            )),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip)
              style: const TextStyle(
                fontSize: 14)
                height: 1.4)
              )))])
      )
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label)
            style: const TextStyle(
              fontSize: 12)
              color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 4),
          Text(
            value)
            style: const TextStyle(
              fontSize: 14)
              fontWeight: FontWeight.bold)
            ))])
      )
    );
  }

  Color _getGameColor(GameType game) {
    switch (game) {
      case GameType.lol:
        return Colors.blue;
      case GameType.valorant:
        return Colors.red;
      case GameType.overwatch:
        return Colors.orange;
      case GameType.pubg:
        return Colors.green;
      case GameType.fifa:
        return Colors.purple;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}