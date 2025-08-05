import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

enum HealthSportsType {
  health('건강운', 'health', '오늘의 건강 상태와 조언', Icons.favorite_rounded, [Color(0xFFEC4899), Color(0xFFDB2777)]),
  fitness('피트니스', 'fitness', '운동 효과와 최적의 운동법', Icons.fitness_center_rounded, [Color(0xFFF97316), Color(0xFFEA580C)]),
  yoga('요가', 'yoga', '요가 수행과 명상 가이드', Icons.self_improvement_rounded, [Color(0xFFA78BFA), Color(0xFF8B5CF6)]),
  golf('골프', 'golf', '골프 경기 운세와 스코어 예측', Icons.golf_course_rounded, [Color(0xFF22C55E), Color(0xFF16A34A)]),
  tennis('테니스', 'tennis', '테니스 경기 운세와 플레이 팁', Icons.sports_tennis_rounded, [Color(0xFFFFD600), Color(0xFFFFB300)]),
  running('런닝', 'running', '러닝 컨디션과 최적의 코스', Icons.directions_run_rounded, [Color(0xFF3B82F6), Color(0xFF2563EB)]),
  fishing('낚시', 'fishing', '낚시 운세와 포인트 추천', Icons.phishing_rounded, [Color(0xFF0EA5E9), Color(0xFF0284C7)]);
  
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  
  const HealthSportsType(this.label, this.value, this.description, this.icon, this.gradientColors);
}

class HealthSportsUnifiedPage extends BaseFortunePage {
  const HealthSportsUnifiedPage({
    Key? key}) : super(
          key: key,
          title: '건강 & 운동',
          description: '건강, 피트니스, 요가, 스포츠 운세를 확인하세요',
          fortuneType: 'health_sports',
          requiresUserInfo: true
        );

  @override
  ConsumerState<HealthSportsUnifiedPage> createState() => _HealthSportsUnifiedPageState();
}

class _HealthSportsUnifiedPageState extends BaseFortunePageState<HealthSportsUnifiedPage> {
  HealthSportsType _selectedType = HealthSportsType.health;
  final Map<HealthSportsType, Fortune?> _fortuneCache = {};

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Add health/sports-specific parameters
    params['healthSportsType'] = _selectedType.value;
    
    final fortune = await fortuneService.getSportsFortune(
      userId: params['userId'],
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
          // Header Card
          _buildHeaderCard()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          
          // Type Grid
          Text(
            '운세 유형 선택',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTypeGrid(),
          const SizedBox(height: 24),
          
          // Generate Button
          if (_fortuneCache[_selectedType] == null)
            _buildGenerateButton(),
          
          // Fortune Result
          if (_fortuneCache[_selectedType] != null) ...[
            _buildFortuneResult(_fortuneCache[_selectedType]!),
            const SizedBox(height: 16),
            _buildRefreshButton()]]));
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981).withValues(alpha: 0.1),
            Color(0xFFE91E63).withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1)),
      child: Column(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            size: 48,
            color: Color(0xFF10B981)),
          const SizedBox(height: 12),
          Text(
            '건강 & 운동',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981))),
          const SizedBox(height: 8),
          Text(
            '오늘의 건강 상태와 최적의 운동 방법을 알아보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center)]));
  }

  Widget _buildTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0),
      itemCount: HealthSportsType.values.length,
      itemBuilder: (context, index) {
        final type = HealthSportsType.values[index];
        return _buildTypeCard(type, index);
      }
    );
  }

  Widget _buildTypeCard(HealthSportsType type, int index) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? type.gradientColors
                : [Colors.grey[200]!, Colors.grey[300]!]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.gradientColors[0].withValues(alpha: 0.4),
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
              textAlign: TextAlign.center)]))).animate(delay: (50 * index).ms)
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onGenerateFortune,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
          backgroundColor: _selectedType.gradientColors[0]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedType.icon,
              color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${_selectedType.label} 확인하기',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white))])));
  }

  Widget _buildRefreshButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _onGenerateFortune,
        icon: const Icon(Icons.refresh),
        label: const Text('다시 보기'),
        style: TextButton.styleFrom(
          foregroundColor: _selectedType.gradientColors[0])));
  }

  void _onGenerateFortune() {
    final profile = userProfile;
    if (profile != null) {
      setState(() {
        _fortuneCache[_selectedType] = null;
      });
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedType.gradientColors[0].withValues(alpha: 0.1),
            _selectedType.gradientColors[1].withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedType.gradientColors[0].withValues(alpha: 0.3),
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
                    color: _selectedType.gradientColors[0]))),
              if (fortune.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(fortune.score!),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${fortune.score}점',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 20),
          
          // Main message
          Text(
            fortune.message,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.textColor)),
          
          // Health tips for health type
          if (_selectedType == HealthSportsType.health && fortune.additionalInfo?['healthTips'] != null) ...[
            const SizedBox(height: 20),
            _buildHealthTips(List<String>.from(fortune.additionalInfo!['healthTips']],
          
          // Exercise recommendations for fitness/sports types
          if ((_selectedType == HealthSportsType.fitness || 
               _selectedType.value.contains('golf') || 
               _selectedType.value.contains('tennis') ||
               _selectedType.value.contains('running'), && 
              fortune.additionalInfo?['exerciseTips'] != null) ...[
            const SizedBox(height: 20),
            _buildExerciseTips(List<String>.from(fortune.additionalInfo!['exerciseTips']],
          
          // Advice
          if (fortune.advice != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8)),
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
                        color: AppTheme.textColor)))]))]])).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildHealthTips(List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '건강 팁',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedType.gradientColors[0])),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 18,
                color: _selectedType.gradientColors[0]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(fontSize: 14)))])).toList()]);
  }

  Widget _buildExerciseTips(List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운동 추천',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedType.gradientColors[0])),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedType.gradientColors[0].withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(
                Icons.fitness_center,
                size: 18,
                color: _selectedType.gradientColors[0]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(fontSize: 14)))])).toList()]);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}