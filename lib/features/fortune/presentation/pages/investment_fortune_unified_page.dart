import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

enum InvestmentType {
  wealth('재물운': 'wealth', '금전운과 재물운을 확인해보세요', Icons.account_balance_wallet_rounded, [Color(0xFFFFD600), Color(0xFFFF6D00)]),
  realestate('부동산': 'realestate', '부동산 투자 운세를 확인해보세요', Icons.home_rounded, [Color(0xFF0288D1), Color(0xFF0277BD)]),
  stock('주식': 'stock', '오늘의 주식 투자 운세를 확인해보세요', Icons.trending_up_rounded, [Color(0xFF388E3C), Color(0xFF2E7D32)]),
  crypto('암호화폐': 'crypto', '암호화폐 투자 운세를 확인해보세요', Icons.currency_bitcoin_rounded, [Color(0xFFFF9800), Color(0xFFFF6D00)]),
  lottery('로또': 'lottery', '행운의 로또 번호를 확인해보세요', Icons.confirmation_number_rounded, [Color(0xFFFFB300), Color(0xFFF57C00)]);
  
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  
  const InvestmentType(this.label, this.value, this.description, this.icon, this.gradientColors);
}

class InvestmentFortuneUnifiedPage extends BaseFortunePage {
  const InvestmentFortuneUnifiedPage({
    Key? key}) : super(
          key: key,
          title: '투자 운세',
          description: '재물, 부동산, 주식, 암호화폐, 로또 운세를 확인해보세요',
          fortuneType: 'investment',
          requiresUserInfo: true
        );

  @override
  ConsumerState<InvestmentFortuneUnifiedPage> createState() => _InvestmentFortuneUnifiedPageState();
}

class _InvestmentFortuneUnifiedPageState extends BaseFortunePageState<InvestmentFortuneUnifiedPage> {
  InvestmentType _selectedType = InvestmentType.wealth;
  final Map<InvestmentType, Fortune?> _fortuneCache = {};

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add investment-specific parameters
    params['investmentType'] = _selectedType.value;
    
    final fortune = await fortuneService.getInvestmentFortune(
      userId: params['userId'],
      fortuneType: _selectedType.value,
      params: params
    );
    
    // Cache the fortune
    setState(() {
      _fortuneCache[_selectedType] = fortune;
    });
    
    return fortune;
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selector
          _buildTypeSelector(),
          const SizedBox(height: 24),
          
          // Description Card
          _buildDescriptionCard()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          
          // Generate Button
          _buildGenerateButton(),
          
          // Fortune Result (if available),
            if (_fortuneCache[_selectedType] != null) ...[
            const SizedBox(height: 24),
            _buildFortuneResult(_fortuneCache[_selectedType]!)]]));
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '투자 유형 선택',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: InvestmentType.values.length,
            itemBuilder: (context, index) {
              final type = InvestmentType.values[index];
              final isSelected = _selectedType == type;
              
              return Padding(
                padding: EdgeInsets.only(
                  right: index < InvestmentType.values.length - 1 ? 12 : 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? type.gradientColors
                            : [Colors.grey[200]!, Colors.grey[300]!]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: type.gradientColors[0].withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4))]
                          : []),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type.icon,
                          size: 32,
                          color: isSelected ? Colors.white : Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          type.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                          textAlign: TextAlign.center)])))
                .animate(delay: (50 * index).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2, end: 0);
            }))]);
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedType.gradientColors[0].withOpacity(0.1),
            _selectedType.gradientColors[1].withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedType.gradientColors[0].withOpacity(0.3),
          width: 1)),
      child: Row(
        children: [
          Icon(
            _selectedType.icon,
            size: 40,
            color: _selectedType.gradientColors[0]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedType.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedType.gradientColors[0])),
                const SizedBox(height: 4),
                Text(
                  _selectedType.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor)])]));
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onGenerateFortune,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          backgroundColor: _selectedType.gradientColors[0]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedType.icon,
              color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${_selectedType.label} 보기',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)]);
  }

  void _onGenerateFortune() {
    final profile = userProfile;
    if (profile != null) {
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': null};
      generateFortuneAction(params: params);
    }
  }

  Widget _buildFortuneResult(Fortune fortune) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedType.gradientColors[0].withOpacity(0.1),
            _selectedType.gradientColors[1].withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedType.gradientColors[0].withOpacity(0.3),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedType.icon,
                color: _selectedType.gradientColors[0],
                size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_selectedType.label} 결과',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _selectedType.gradientColors[0])),
              if (fortune.score != null),
            Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(fortune.score!),
                    borderRadius: BorderRadius.circular(20),
                  child: Text(
                    '${fortune.score}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold))]),
          const SizedBox(height: 20),
          
          // Main message
          Text(
            fortune.message,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.textColor)),
          
          // Special content based on type
          if (_selectedType == InvestmentType.lottery && fortune.additionalInfo?['luckyNumbers'] != null) ...[
            const SizedBox(height: 20),
            _buildLotteryNumbers(List<int>.from(fortune.additionalInfo!['luckyNumbers'])),],
          
          if (_selectedType == InvestmentType.stock && fortune.additionalInfo?['stockPicks'] != null) ...[
            const SizedBox(height: 20),
            _buildStockPicks(List<Map<String, dynamic>>.from(fortune.additionalInfo!['stockPicks'])),],
          
          if (fortune.advice != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fortune.advice!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor)])]]))
      .animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLotteryNumbers(List<int> numbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '행운의 번호',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedType.gradientColors[0])),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: numbers.map((number) {
            return Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _selectedType.gradientColors),
                shape: BoxShape.circle),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)));
          }).toList()]
    );
  }

  Widget _buildStockPicks(List<Map<String, dynamic>> picks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주목할 종목',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedType.gradientColors[0])),
        const SizedBox(height: 12),
        ...picks.map((pick) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedType.gradientColors[0].withOpacity(0.2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pick['sector'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  pick['trend'] ?? '',
                  style: TextStyle(
                    color: pick['trend'] == '상승' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold)]);
        }).toList()]
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}