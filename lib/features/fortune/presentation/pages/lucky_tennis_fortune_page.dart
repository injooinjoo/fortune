import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class LuckyTennisFortunePage extends BaseFortunePage {
  const LuckyTennisFortunePage({Key? key})
      : super(
          key: key,
          title: '테니스 운세',
          description: '오늘의 테니스 경기를 위한 행운의 가이드',
          fortuneType: 'lucky-tennis',
          requiresUserInfo: true
        );

  @override
  ConsumerState<LuckyTennisFortunePage> createState() => _LuckyTennisFortunePageState();
}

class _LuckyTennisFortunePageState extends BaseFortunePageState<LuckyTennisFortunePage> {
  // User tennis info
  String? _skillLevel;
  String? _playFrequency;
  String? _playStyle;
  String? _courtType;
  String? _racketType;
  List<String> _weakPoints = [];
  bool _hasTournament = false;
  String? _preferredTime;
  
  final Map<String, String> _skillLevels = {
    'beginner', '초급 (NTRP 2.0-2.5)',
    'intermediate', '중급 (NTRP 3.0-3.5)',
    'advanced', '상급 (NTRP 4.0-4.5)',
    'expert', '고급 (NTRP 5.0+)',
    'professional', '프로/준프로'};
  
  final Map<String, String> _frequencies = {
    'rarely', '월 1회 미만',
    'monthly', '월 1-2회',
    'weekly', '주 1-2회',
    'frequent', '주 3-4회',
    'daily', '거의 매일'};
  
  final Map<String, String> _playStyles = {
    'baseline', '베이스라인 플레이어',
    'serve_volley', '서브앤발리',
    'all_court', '올코트 플레이어',
    'counter', '카운터 펀처',
    'aggressive', '공격적 베이스라이너'};
  
  final Map<String, String> _courtTypes = {
    'hard', '하드코트',
    'clay', '클레이코트',
    'grass', '잔디코트',
    'indoor', '실내코트',
    'any', '상관없음'};
  
  final Map<String, String> _racketTypes = {
    'power', '파워형 라켓',
    'control', '컨트롤형 라켓',
    'tweener', '올라운드형 라켓',
    'spin', '스핀형 라켓',
    'unsure', '잘 모르겠음'};
  
  final List<String> _weaknessOptions = [
    '서브',
    '리턴',
    '포핸드',
    '백핸드',
    '발리',
    '스매시',
    '드롭샷',
    '로브',
    '풋워크',
    '멘탈',
    '체력',
    '전략'];
  
  final Map<String, String> _timePreferences = {
    'early_morning', '새벽 (5-7시)',
    'morning', '오전 (7-11시)',
    'afternoon', '오후 (12-16시)',
    'evening', '저녁 (16-20시)',
    'night', '야간 (20시 이후)',
    'flexible', '시간 무관'};

  // User info form state
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _mbti;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    if (_nameController.text.isEmpty || _birthDate == null || _gender == null) {
      Toast.warning(context, '기본 정보를 입력해주세요.');
      return null;
    }

    return {
      'name': _nameController.text,
      'birthDate': _birthDate!.toIso8601String(),
      'gender': _gender,
      'mbti': null};
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    final userInfo = await getUserInfo();
    if (userInfo == null) return null;

    if (_skillLevel == null || _playFrequency == null || 
        _playStyle == null || _courtType == null ||
        _racketType == null || _preferredTime == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
    }

    return {
      ...userInfo,
      'skillLevel': _skillLevel,
      'playFrequency': _playFrequency,
      'playStyle': _playStyle,
      'courtType': _courtType,
      'racketType': _racketType,
      'weakPoints': _weakPoints,
      'hasTournament': _hasTournament,
      'preferredTime': null};
  }

  Widget buildUserInfoForm() {
    final theme = Theme.of(context);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          
          // Name Input
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          
          // Birth Date Picker
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
              if (date != null) {
                setState(() => _birthDate = date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: Text(
                _birthDate != null
                    ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                    : '생년월일을 선택하세요',
                style: TextStyle(
                  color: _birthDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6))))),
          const SizedBox(height: 16),
          
          // Gender Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '성별',
                style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('남성'),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero)),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) => setState(() => _gender = value),
                      contentPadding: EdgeInsets.zero))])])]));
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // User Info Form
        buildUserInfoForm(),
        const SizedBox(height: 16),
        
        // Tennis Skill Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_tennis, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '테니스 정보',
                    style: theme.textTheme.headlineSmall)]),
              const SizedBox(height: 16),
              
              // Skill Level
              DropdownButtonFormField<String>(
                value: _skillLevel,
                decoration: InputDecoration(
                  labelText: '실력 수준',
                  prefixIcon: const Icon(Icons.trending_up),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
                items: _skillLevels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _skillLevel = value)),
              const SizedBox(height: 16),
              
              // Play Frequency
              DropdownButtonFormField<String>(
                value: _playFrequency,
                decoration: InputDecoration(
                  labelText: '경기 빈도',
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
                items: _frequencies.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _playFrequency = value)),
              const SizedBox(height: 16),
              
              // Play Style
              DropdownButtonFormField<String>(
                value: _playStyle,
                decoration: InputDecoration(
                  labelText: '플레이 스타일',
                  prefixIcon: const Icon(Icons.sports),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
                items: _playStyles.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _playStyle = value)),
              const SizedBox(height: 16),
              
              // Preferred Time
              DropdownButtonFormField<String>(
                value: _preferredTime,
                decoration: InputDecoration(
                  labelText: '선호 시간대',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
                items: _timePreferences.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value);
                }).toList(),
                onChanged: (value) => setState(() => _preferredTime = value))])),
        const SizedBox(height: 16),
        
        // Equipment and Court Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    '장비 및 코트',
                    style: theme.textTheme.headlineSmall)]),
              const SizedBox(height: 16),
              
              // Court Type
              DropdownButtonFormField<String>(
                value: _courtType,
                decoration: InputDecoration(
                  labelText: '선호 코트',
                  prefixIcon: const Icon(Icons.square_foot),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
                items: _courtTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _courtType = value)),
              const SizedBox(height: 16),
              
              // Racket Type
              DropdownButtonFormField<String>(
                value: _racketType,
                decoration: InputDecoration(
                  labelText: '라켓 타입',
                  prefixIcon: const Icon(Icons.sports_tennis),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12))),
                items: _racketTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value));
                }).toList(),
                onChanged: (value) => setState(() => _racketType = value)),
              const SizedBox(height: 16),
              
              // Weak Points
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개선이 필요한 부분 (복수 선택 가능)',
                    style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weaknessOptions.map((weakness) {
                      final isSelected = _weakPoints.contains(weakness);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _weakPoints.remove(weakness);
                            } else {
                              _weakPoints.add(weakness);
                            }
                          });
                        },
                        child: Chip(
                          label: Text(weakness),
                          backgroundColor: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : theme.colorScheme.surface.withValues(alpha: 0.5),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.3))));
                    }).toList())]),
              const SizedBox(height: 16),
              
              // Tournament
              _buildSwitchTile(
                '대회 참가 예정',
                _hasTournament,
                (value) => setState(() => _hasTournament = value),
                Icons.emoji_events)]))]
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge)),
        Switch(
          value: value,
          onChanged: onChanged)]);
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildMatchPrediction(),
        _buildLuckyShots(),
        _buildEquipmentRecommendations(),
        _buildStrategyTips(),
        _buildPhysicalCondition(),
        _buildMentalCoaching()]);
  }

  Widget _buildMatchPrediction() {
    final theme = Theme.of(context);
    final winProbability = _calculateWinProbability();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_tennis,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오늘의 승률 예측',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 24),
            
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getWinColor(winProbability).withValues(alpha: 0.3),
                    _getWinColor(winProbability).withValues(alpha: 0.1)]),
                border: Border.all(
                  color: _getWinColor(winProbability),
                  width: 3)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${winProbability}%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getWinColor(winProbability))),
                    Text(
                      _getWinMessage(winProbability),
                      style: theme.textTheme.bodyMedium)]))).animate(,
                .scale(duration: 600.ms,
                .then(,
                .shimmer(duration: 1000.ms),
            
            const SizedBox(height: 16),
            Text(
              '오늘은 ${_getPerformanceMessage(winProbability)}',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center)])));
  }

  Widget _buildLuckyShots() {
    final theme = Theme.of(context);
    final luckyShots = _getLuckyShots();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 8),
                Text(
                  '오늘의 필살기',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            ...luckyShots.asMap().entries.map((entry) => 
              _buildShotItem(entry.value, index: entry.key).toList()])));
  }

  Widget _buildShotItem(Map<String, String> shot, {int index = 0}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle),
              child: Icon(
                _getShotIcon(shot['name'],
                color: Colors.white,
                size: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shot['name'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold)),
                  Text(
                    shot['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7)))]))])).animate(,
          .fadeIn(delay: (index * 100).ms,
          .slideX(begin: -0.1, end: 0);
  }

  Widget _buildEquipmentRecommendations() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  '오늘의 장비 팁',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            _buildEquipmentItem('스트링 텐션', '평소보다 1-2파운드 낮게',
            _buildEquipmentItem('그립 사이즈', '오버그립 추가 권장',
            _buildEquipmentItem('신발', '쿠션이 좋은 신발 추천'])));
  }

  Widget _buildEquipmentItem(String item, String recommendation, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 24, color: theme.colorScheme.secondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold)),
                Text(
                  recommendation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7)))]))]));
  }

  Widget _buildStrategyTips() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  '전략 포인트',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            _buildStrategyItem('서브 게임', '첫 서브 확률을 높이세요',
            _buildStrategyItem('랠리', '인내심을 가지고 기회를 기다리세요',
            _buildStrategyItem('네트 플레이', '오늘은 네트로 자주 나가세요',
            _buildStrategyItem('게임 운영', '중요한 포인트에서 안정적으로'])));
  }

  Widget _buildStrategyItem(String aspect, String tip) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$aspect: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: tip)])))]));
  }

  Widget _buildPhysicalCondition() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '신체 컨디션',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildConditionItem('체력': null,
                _buildConditionItem('집중력': null,
                _buildConditionItem('반응속도')])])));
  }

  Widget _buildConditionItem(String label, int value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: value / 100,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 8)),
            Icon(icon, color: color, size: 30)]),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall),
        Text(
          '$value%',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color))]).animate(,
        .scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildMentalCoaching() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.self_improvement, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  '멘탈 코칭',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withValues(alpha: 0.1),
                    Colors.blue.withValues(alpha: 0.1)]),
                borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text(
                    '"한 포인트씩 집중하라"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    '과거의 실수나 미래의 결과에 연연하지 말고,\n지금 이 순간의 플레이에만 집중하세요.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center)]))])));
  }

  int _calculateWinProbability() {
    // Calculate based on skill level and other factors
    final baseProb = switch (_skillLevel) {
      'beginner' => 45,
      'intermediate' => 55,
      'advanced' => 65,
      'expert' => 75,
      'professional': null,
      _ => 50};
    
    // Add randomness for daily variation
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    return (baseProb + random.nextInt(20) - 10).clamp(20, 95);
  }

  List<Map<String, String>> _getLuckyShots() {
    final shots = [
      {'name', '포핸드 다운더라인': 'description', '결정적인 순간에 위력을 발휘합니다'},
      {'name', '백핸드 크로스': 'description', '안정적이고 정확한 샷이 가능합니다'},
      {'name', '서브 에이스', 'description', '첫 서브 성공률이 높습니다'},
      {'name', '드롭샷', 'description', '상대를 교란시키는데 효과적입니다'}];
    
    // Return 2-3 random lucky shots
    final today = DateTime.now();
    final random = math.Random(today.day + today.month);
    final count = random.nextInt(2) + 2;
    
    shots.shuffle(random);
    return shots.take(count).toList();
  }

  Color _getWinColor(int probability) {
    if (probability >= 80) return Colors.green;
    if (probability >= 60) return Colors.blue;
    if (probability >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getWinMessage(int probability) {
    if (probability >= 80) return '최상의 컨디션!';
    if (probability >= 60) return '승리 가능성 높음';
    if (probability >= 40) return '집중력이 필요해요';
    return '신중한 플레이 필요';
  }

  String _getPerformanceMessage(int probability) {
    if (probability >= 80) return '최고의 경기력을 발휘할 수 있는 날입니다!';
    if (probability >= 60) return '좋은 플레이가 예상되는 날입니다.';
    if (probability >= 40) return '평소 실력을 발휘하면 충분합니다.';
    return '차분하게 기본에 충실한 플레이를 하세요.';
  }

  IconData _getShotIcon(String shotName) {
    if (shotName.contains('서브') return Icons.sports_tennis;
    if (shotName.contains('백핸드') return Icons.arrow_back;
    if (shotName.contains('포핸드') return Icons.arrow_forward;
    if (shotName.contains('드롭') return Icons.arrow_drop_down;
    return Icons.sports;
  }
}