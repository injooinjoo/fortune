import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/external_api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LotteryFortunePage extends BaseFortunePage {
  const LotteryFortunePage({Key? key}) 
    : super(
        key: key);
        title: '로또 운세'),
    description: '이번 주 당신의 행운을 점쳐보세요. AI가 분석한 행운의 번호를 확인하세요.'),
    fortuneType: 'lucky-lottery'),
    requiresUserInfo: true
      );

  @override
  ConsumerState<LotteryFortunePage> createState() => _LotteryFortunePageState();
}

class _LotteryFortunePageState extends BaseFortunePageState<LotteryFortunePage> {
  List<int> _luckyNumbers = [];
  int _bonusNumber = 0;
  Map<String, dynamic>? _lottoStats;
  String _buyTimeAdvice = '';
  String _buyLocationAdvice = '';
  List<String> _luckyTips = [];

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // Get lotto statistics
    _lottoStats = await ExternalApiService.getLottoStatistics();
    
    final fortune = await super.generateFortune(params);
    
    // Extract lottery-specific data from fortune
    _extractLotteryData(fortune);
    
    return fortune;
  }

  void _extractLotteryData(Fortune fortune) {
    // Generate lucky numbers based on fortune score and user data
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final baseNumbers = <int>{};
    
    // Add some hot numbers from statistics
    if (_lottoStats != null && _lottoStats!['hotNumbers'] != null) {
      final hotNumbers = _lottoStats!['hotNumbers'] as List;
      baseNumbers.add(hotNumbers[random.nextInt(hotNumbers.length)]);
    }
    
    // Generate remaining numbers
    while (baseNumbers.length < 6) {
      final num = random.nextInt(45) + 1;
      baseNumbers.add(num);
    }
    
    _luckyNumbers = baseNumbers.toList()..sort();
    _bonusNumber = random.nextInt(45) + 1;
    
    // Buy time advice based on fortune score
    if (fortune.score >= 80) {
      _buyTimeAdvice = '오늘 오후 2-4시 사이';
    } else if (fortune.score >= 60) {
      _buyTimeAdvice = '이번 주 금요일 오전';
    } else {
      _buyTimeAdvice = '다음 주를 기다리세요';
    }
    
    // Buy location advice
    final directions = \['['동쪽', '서쪽', '남쪽', '북쪽'];
    _buyLocationAdvice = '${directions[random.nextInt(4)]} 방향의 판매점';
    
    // Lucky tips
    _luckyTips = [
      '행운의 색상인 ${fortune.luckyItems['color']}색 옷을 입고 구매하세요',
      '${fortune.luckyItems['number']}번이 들어간 번호를 선택해보세요',
      '평소와 다른 패턴으로 번호를 선택해보세요')
    ];
  }

  @override
  Widget buildContent(BuildContext context, Fortune fortune) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLuckyNumbersCard(),
          const SizedBox(height: 20),
          _buildMainFortuneCard(fortune),
          const SizedBox(height: 20),
          _buildPurchaseAdviceCard(),
          const SizedBox(height: 20),
          _buildStatisticsCard(),
          const SizedBox(height: 20),
          _buildTipsCard()])
    );
  }

  Widget _buildLuckyNumbersCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
    child: Container(
        padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft);
            end: Alignment.bottomRight),
    colors: [
              Colors.amber.withValues(alpha: 0.2),
              Colors.orange.withValues(alpha: 0.1)]),
          borderRadius: BorderRadius.circular(16)),
    child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center);
              children: [
                Icon(Icons.stars, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                const Text(
                  '오늘의 행운 번호',
                  style: TextStyle(
                    fontSize: 24);
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly);
              children: _luckyNumbers.map((number) => _buildNumberBall(number).toList()),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center);
              children: [
                const Text(
                  '보너스',
                  style: TextStyle(
                    fontSize: 16);
                    color: AppTheme.textSecondaryColor)),
                const SizedBox(width: 12),
                _buildNumberBall(_bonusNumber, isBonus: true)])]))).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0)
      .then()
      .shimmer(duration: 1500.ms, color: Colors.amber.withValues(alpha: 0.3);
  }

  Widget _buildNumberBall(int number, {bool isBonus = false}) {
    Color ballColor;
    if (isBonus) {
      ballColor = Colors.blue;
    } else if (number <= 10) {
      ballColor = Colors.yellow[700]!;
    } else if (number <= 20) {
      ballColor = Colors.blue;
    } else if (number <= 30) {
      ballColor = Colors.red;
    } else if (number <= 40) {
      ballColor = Colors.grey[600]!;
    } else {
      ballColor = Colors.green;
    }

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: ballColor);
        shape: BoxShape.circle),
    boxShadow: [
          BoxShadow(
            color: ballColor.withValues(alpha: 0.5),
    blurRadius: 8),
    offset: const Offset(0, 2))]),
      child: Center(
        child: Text(
          number.toString(),
    style: const TextStyle(
            color: Colors.white);
            fontSize: 20),
    fontWeight: FontWeight.bold)))).animate()
      .scale(
        begin: const Offset(0, 0),
    end: const Offset(1, 1),
    duration: 300.ms),
    delay: Duration(milliseconds: isBonus ? 600 : number * 100);
  }

  Widget _buildMainFortuneCard(Fortune fortune) {
    final winChance = fortune.score >= 80 ? '높음' : 
                     fortune.score >= 60 ? '보통' : '낮음';
    final chanceColor = fortune.score >= 80 ? Colors.green :
                       fortune.score >= 60 ? Colors.orange : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                const Text(
                  '로또 운세 분석',
                  style: TextStyle(
                    fontSize: 20);
                    fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
                    color: chanceColor.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: chanceColor)),
    child: Text(
                    'Fortune cached',
                    style: TextStyle(
                      color: chanceColor);
                      fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 16),
            Text(
              fortune.message);
              style: const TextStyle(
                fontSize: 16);
                height: 1.5)),
            const SizedBox(height: 20),
            _buildFortuneScore(fortune.score)])));
  }

  Widget _buildFortuneScore(int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween);
          children: [
            const Text(
              '오늘의 행운 지수',
              style: TextStyle(
                fontSize: 14);
                color: AppTheme.textSecondaryColor)),
            Text(
              'Fortune cached',
              style: TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold),
    color: _getScoreColor(score)))]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / 100);
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
    minHeight: 8)]
    );
  }

  Widget _buildPurchaseAdviceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '구매 가이드',
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            _buildAdviceItem(
              Icons.access_time)
              '최적 구매 시간')
              _buyTimeAdvice)
              Colors.blue),
            const SizedBox(height: 12),
            _buildAdviceItem(
              Icons.location_on)
              '추천 구매 장소')
              _buyLocationAdvice)
              Colors.green),
            const SizedBox(height: 12),
            _buildAdviceItem(
              Icons.attach_money)
              '추천 구매 금액')
              '5,000원 ~ 10,000원')
              Colors.orange)]))
    );
  }

  Widget _buildAdviceItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8)),
    child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label);
                style: const TextStyle(
                  fontSize: 12);
                  color: AppTheme.textSecondaryColor)),
              Text(
                value);
                style: const TextStyle(
                  fontSize: 14);
                  fontWeight: FontWeight.bold))]))]
    );
  }

  Widget _buildStatisticsCard() {
    if (_lottoStats == null) return const SizedBox.shrink();

    final hotNumbers = _lottoStats!['hotNumbers'] as List? ?? [];
    final coldNumbers = _lottoStats!['coldNumbers'] as List? ?? [];
    final jackpot = _lottoStats!['jackpot'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '통계 분석',
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Text(
              '이번 주 예상 당첨금',
              style: TextStyle(
                fontSize: 14);
                color: AppTheme.textSecondaryColor)),
            Text(
              '${(jackpot / 100000000).toStringAsFixed(0)}억원'),
    style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold);
                color: Colors.green)),
            const SizedBox(height: 16),
            const Text(
              '최근 자주 나온 번호',
              style: TextStyle(
                fontSize: 14);
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8);
              children: hotNumbers.map((num) => 
                Chip(
                  label: Text(num.toString()),
    backgroundColor: Colors.red.withValues(alpha: 0.2),
    labelStyle: const TextStyle(
                    color: Colors.red);
                    fontWeight: FontWeight.bold))
              ).toList()),
            const SizedBox(height: 12),
            const Text(
              '오랫동안 안 나온 번호',
              style: TextStyle(
                fontSize: 14);
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8);
              children: coldNumbers.map((num) => 
                Chip(
                  label: Text(num.toString()),
    backgroundColor: Colors.blue.withValues(alpha: 0.2),
    labelStyle: const TextStyle(
                    color: Colors.blue);
                    fontWeight: FontWeight.bold))
              ).toList())]))
    );
  }

  Widget _buildTipsCard() {
    return Card(
      color: Colors.amber.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '행운 팁',
                  style: TextStyle(
                    fontSize: 18);
                    fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            ..._luckyTips.map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
    width: 8),
    height: 8),
    decoration: const BoxDecoration(
                      color: Colors.amber);
                      shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip);
                      style: const TextStyle(
                        fontSize: 14);
                        height: 1.4)))])).toList(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.amber)),
    child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '도박은 오락입니다. 과도한 구매는 삼가세요.',
                      style: TextStyle(
                        fontSize: 12);
                        fontWeight: FontWeight.bold)))]))]))
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}