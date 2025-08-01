import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class TraditionalCompatibilityPage extends BaseFortunePage {
  const TraditionalCompatibilityPage({Key? key})
      : super(
          key: key,
          title: '전통 궁합',
          description: '사주와 오행으로 보는 천생연분',
          fortuneType: 'traditional-compatibility',
          requiresUserInfo: false, // We'll handle user info manually for two people
        );

  @override
  ConsumerState<TraditionalCompatibilityPage> createState() => _TraditionalCompatibilityPageState();
}

class _TraditionalCompatibilityPageState extends BaseFortunePageState<TraditionalCompatibilityPage> {
  // Person 1 Info
  String? _person1Name;
  DateTime? _person1BirthDate;
  String? _person1BirthTime;
  String? _person1Gender;
  bool _person1IsLunar = false;

  // Person 2 Info
  String? _person2Name;
  DateTime? _person2BirthDate;
  String? _person2BirthTime;
  String? _person2Gender;
  bool _person2IsLunar = false;

  // Relationship Info
  String? _relationshipType;
  String? _relationshipDuration;
  List<String> _concernAreas = [];

  final Map<String, String> _birthTimes = {
    'ja': '자시 (23:00-01:00)',
    'chuk': '축시 (01:00-03:00)',
    'in': '인시 (03:00-05:00)',
    'myo': '묘시 (05:00-07:00)',
    'jin': '진시 (07:00-09:00)',
    'sa': '사시 (09:00-11:00)',
    'o': '오시 (11:00-13:00)',
    'mi': '미시 (13:00-15:00)',
    'sin': '신시 (15:00-17:00)',
    'yu': '유시 (17:00-19:00)',
    'sul': '술시 (19:00-21:00)',
    'hae': '해시 (21:00-23:00)';

  final Map<String, String> _relationshipTypes = {
    'couple': '연인',
    'married': '부부',
    'potential': '썸',
    'friend': '친구에서 연인으로',
    'arranged': '선/소개팅';

  final Map<String, String> _durations = {
    'new': '1개월 미만',
    'short': '1-6개월',
    'medium': '6개월-1년',
    'long': '1-3년',
    'verylong': '3년 이상';

  final List<String> _concernAreaOptions = [
    '성격 차이',
    '가치관 차이',
    '의사소통',
    '미래 계획',
    '경제관념',
    '가족 관계',
    '생활 습관',
    '종교/신념';

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType),
                  userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
}

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_person1Name == null || _person1BirthDate == null || 
        _person1BirthTime == null || _person1Gender == null ||
        _person2Name == null || _person2BirthDate == null || 
        _person2BirthTime == null || _person2Gender == null ||
        _relationshipType == null) {
      Toast.warning(context, '모든 필수 정보를 입력해주세요.');
      return null;
}

    return {
      'person1': {
        'name': _person1Name
        'birthDate': _person1BirthDate!.toIso8601String(),
        'birthTime': _person1BirthTime,
        'gender': _person1Gender,
        'isLunar': _person1IsLunar,
      'person2': {
        'name': _person2Name,
        'birthDate': _person2BirthDate!.toIso8601String(),
        'birthTime': _person2BirthTime,
        'gender': _person2Gender,
        'isLunar': _person2IsLunar,
      'relationshipType': _relationshipType,
      'relationshipDuration': _relationshipDuration,
      'concernAreas': _concernAreas;
}

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Person 1 Info
        _buildPersonInfoCard(
          title: '첫 번째 사람 정보',
          icon: Icons.person,
          color: theme.colorScheme.primary),
                  name: _person1Name),
                  onNameChanged: (value) => setState(() => _person1Name = value),
          birthDate: _person1BirthDate,
          onBirthDateChanged: (date) => setState(() => _person1BirthDate = date),
          birthTime: _person1BirthTime,
          onBirthTimeChanged: (value) => setState(() => _person1BirthTime = value),
          gender: _person1Gender,
          onGenderChanged: (value) => setState(() => _person1Gender = value),
          isLunar: _person1IsLunar,
          onLunarChanged: (value) => setState(() => _person1IsLunar = value),
        const SizedBox(height: 16),
        
        // Connection Icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle),
                  gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.favorite,
              color: theme.colorScheme.primary),
                  size: 32)
            ),
        ),
        const SizedBox(height: 16),
        
        // Person 2 Info
        _buildPersonInfoCard(
          title: '두 번째 사람 정보',
          icon: Icons.person,
          color: theme.colorScheme.secondary,
          name: _person2Name),
                  onNameChanged: (value) => setState(() => _person2Name = value),
          birthDate: _person2BirthDate,
          onBirthDateChanged: (date) => setState(() => _person2BirthDate = date),
          birthTime: _person2BirthTime,
          onBirthTimeChanged: (value) => setState(() => _person2BirthTime = value),
          gender: _person2Gender,
          onGenderChanged: (value) => setState(() => _person2Gender = value),
          isLunar: _person2IsLunar,
          onLunarChanged: (value) => setState(() => _person2IsLunar = value),
        const SizedBox(height: 16),
        
        // Relationship Info
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
              Text(
                '관계 정보'),
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              // Relationship Type
              Text(
                '관계 유형'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8),
                  children: _relationshipTypes.entries.map((entry) {
                  final isSelected = _relationshipType == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _relationshipType = entry.key;
});
},
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(entry.value),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.surface.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ));
}).toList(),
              const SizedBox(height: 16),
              
              // Relationship Duration
              if (_relationshipType == 'couple' || _relationshipType == 'married') ...[
                Text(
                  '교제/결혼 기간'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold)
                  ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _relationshipDuration,
                  decoration: InputDecoration(
                    hintText: '기간을 선택하세요'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                  items: _durations.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key),
                  child: Text(entry.value));
}).toList(),
                  onChanged: (value) {
                    setState(() {
                      _relationshipDuration = value;
});
},
                ),
                const SizedBox(height: 16),
              
              // Concern Areas
              Text(
                '궁금한 부분 (선택사항)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8),
                  children: _concernAreaOptions.map((area) {
                  final isSelected = _concernAreas.contains(area);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _concernAreas.remove(area);
} else {
                          _concernAreas.add(area);
}
                      });
},
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(area),
                      backgroundColor: isSelected
                          ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                          : theme.colorScheme.surface.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ));
}).toList(),
          ))
    );
}

  Widget _buildPersonInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required String? name)
    required Function(String) onNameChanged,
    required DateTime? birthDate,
    required Function(DateTime) onBirthDateChanged,
    required String? birthTime,
    required Function(String?) onBirthTimeChanged,
    required String? gender,
    required Function(String?) onGenderChanged,
    required bool isLunar,
    required Function(bool) onLunarChanged) {
    final theme = Theme.of(context);
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title),
                  style: theme.textTheme.headlineSmall)
              ),
          const SizedBox(height: 16),
          
          // Name
          TextField(
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요'),
                  border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              filled: true,
              fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 16),
          
          // Gender
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onGenderChanged('male'),
                  borderRadius: BorderRadius.circular(12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    blur: 10,
                    borderColor: gender == 'male'
                        ? color.withValues(alpha: 0.5)
                        : Colors.transparent,
                    borderWidth: gender == 'male' ? 2 : 0
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center),
                  children: [
                        Icon(
                          Icons.male),
                  color: gender == 'male' ? color : theme.colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text('남성'),
                  ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => onGenderChanged('female'),
                  borderRadius: BorderRadius.circular(12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    blur: 10,
                    borderColor: gender == 'female'
                        ? color.withValues(alpha: 0.5)
                        : Colors.transparent,
                    borderWidth: gender == 'female' ? 2 : 0
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center),
                  children: [
                        Icon(
                          Icons.female),
                  color: gender == 'female' ? color : theme.colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text('여성'),
                  ),
              ),
          const SizedBox(height: 16),
          
          // Birth Date
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context),
                  initialDate: birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now());
              if (date != null) {
                onBirthDateChanged(date);
}
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '생년월일'),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                suffixIcon: const Icon(Icons.calendar_today),
              child: Text(
                birthDate != null
                    ? '${birthDate.year}년 ${birthDate.month}월 ${birthDate.day}일'
                    : '생년월일을 선택하세요')
              ),
          ),
          const SizedBox(height: 8),
          
          // Lunar Calendar Switch
          Row(
            children: [
              Checkbox(
                value: isLunar),
                  onChanged: (value) => onLunarChanged(value ?? false),
              Text('음력'),
          const SizedBox(height: 16),
          
          // Birth Time
          DropdownButtonFormField<String>(
            value: birthTime,
            decoration: InputDecoration(
              labelText: '태어난 시간',
              hintText: '시간을 선택하세요'),
                  border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              filled: true,
              fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            items: _birthTimes.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key),
                  child: Text(entry.value));
}).toList(),
            onChanged: onBirthTimeChanged,
          ),
    );
}

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildCompatibilityScore(),
        _buildSajuAnalysis(),
        _buildElementalHarmony(),
        _buildRelationshipDynamics(),
        _buildFutureOutlook(),
        _buildAdviceForSuccess());
}

  Widget _buildCompatibilityScore() {
    final theme = Theme.of(context);
    final overallScore = 82; // Mock score
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '전체 궁합 점수'),
                  style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: overallScore / 100),
                  strokeWidth: 20),
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(overallScore),
                  ),
                Column(
                  children: [
                    Text(
                      '$overallScore'),
                  style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                  color: _getScoreColor(overallScore),
                    ),
                    Text(
                      '천생연분'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary)
                      ),
                ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              child: Text(
                '두 분은 서로를 보완하는 환상적인 궁합입니다. 특히 정서적 교감과 가치관의 일치도가 높아 장기적인 관계 발전이 기대됩니다.',
                style: theme.textTheme.bodyLarge),
                  textAlign: TextAlign.center)
              ),
        ));
}

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
}

  Widget _buildSajuAnalysis() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
            Row(
              children: [
                Icon(
                  Icons.balance),
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '사주 분석'),
                  style: theme.textTheme.headlineSmall)
                ),
            const SizedBox(height: 16),
            _buildSajuComparison('천간', '갑목(甲木)', '을목(乙木)', '상생관계', Colors.green),
            const SizedBox(height: 12),
            _buildSajuComparison('지지', '자수(子水)', '축토(丑土)', '합충관계', Colors.orange),
            const SizedBox(height: 12),
            _buildSajuComparison('일주', '갑자(甲子)', '을축(乙丑)', '천을합', Colors.green),
            const SizedBox(height: 12),
            _buildSajuComparison('대운', '상승기', '안정기', '조화로움', Colors.blue),
      
    );
}

  Widget _buildSajuComparison(String category, String person1, String person2, String relation, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60),
                  child: Text(
              category),
                  style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold)
              ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    person1),
                  style: theme.textTheme.bodySmall),
                  textAlign: TextAlign.center)
                  ),
                Icon(
                  Icons.compare_arrows,
                  size: 16),
                  color: theme.colorScheme.primary),
                Expanded(
                  child: Text(
                    person2),
                  style: theme.textTheme.bodySmall),
                  textAlign: TextAlign.center)
                  ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            child: Text(
              relation),
                  style: theme.textTheme.bodySmall?.copyWith(
                color: color),
                  fontWeight: FontWeight.bold)
              ),
          ));
}

  Widget _buildElementalHarmony() {
    final theme = Theme.of(context);
    
    final elements = ['목(木)', '화(火)', '토(土)', '금(金)', '수(水)'];
    final person1Values = [70, 85, 60, 40, 90];
    final person2Values = [80, 60, 75, 85, 50];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
            Row(
              children: [
                Icon(
                  Icons.pentagon_outlined),
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오행 조화'),
                  style: theme.textTheme.headlineSmall)
                ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  radarBackgroundColor: Colors.transparent),
                  borderData: FlBorderData(show: false),
                  radarBorderData: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: theme.textTheme.bodySmall,
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 0),
                  tickBorderData: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  gridBorderData: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  dataSets: [
                    RadarDataSet(
                      fillColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderColor: theme.colorScheme.primary,
                      dataEntries: person1Values.map((v) => RadarEntry(value: v.toDouble())).toList(),
                      borderWidth: 2,
                    ),
                    RadarDataSet(
                      fillColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      borderColor: theme.colorScheme.secondary,
                      dataEntries: person2Values.map((v) => RadarEntry(value: v.toDouble())).toList(),
                      borderWidth: 2,
                    ),
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: elements[index]),
                  angle: 0
                    );
},
                ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center),
                  children: [
                _buildLegendItem(_person1Name ?? '첫 번째 사람', theme.colorScheme.primary),
                const SizedBox(width: 24),
                _buildLegendItem(_person2Name ?? '두 번째 사람', theme.colorScheme.secondary),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              child: Text(
                '목(木)과 수(水)의 조화가 뛰어나 서로의 성장을 돕는 관계입니다. 화(火) 기운의 균형을 맞추면 더욱 완벽한 조화를 이룰 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
        ));
}

  Widget _buildLegendItem(String label, Color color) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 3),
                  color: color),
        const SizedBox(width: 8),
        Text(
          label),
                  style: theme.textTheme.bodySmall)
        )
    );
}

  Widget _buildRelationshipDynamics() {
    final theme = Theme.of(context);
    
    final dynamics = [
      {
        'aspect': '정서적 교감',
        'score': 90,
        'description': '깊은 이해와 공감으로 연결된 관계',
      {
        'aspect': '의사소통',
        'score': 85,
        'description': '솔직하고 열린 대화가 가능',
      {
        'aspect': '가치관 일치',
        'score': 88,
        'description': '인생의 중요한 가치를 공유',
      {
        'aspect': '생활 리듬',
        'score': 75,
        'description': '약간의 조율이 필요하지만 맞출 수 있음',
      {
        'aspect': '미래 비전',
        'score': 82,
        'description': '함께 그리는 미래가 조화로움';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
            Row(
              children: [
                Icon(
                  Icons.sync_alt_rounded),
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '관계 역학'),
                  style: theme.textTheme.headlineSmall)
                ),
            const SizedBox(height: 16),
            ...dynamics.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['aspect'] as String),
                  style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold)
                          ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                  vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(item['score'] as int).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        child: Text(
                          '${item['score']}%'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getScoreColor(item['score'] as int),
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] as String),
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (item['score'] as int) / 100,
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(item['score'] as int),
                  ),
            )).toList(),
      
    );
}

  Widget _buildFutureOutlook() {
    final theme = Theme.of(context);
    
    final milestones = [
      {'period': '3개월', 'event': '깊은 신뢰 형성', 'advice': '서로의 개인 시간 존중하기'},
      {'period': '6개월', 'event': '안정적인 관계 확립', 'advice': '미래 계획 공유하기'},
      {'period': '1년', 'event': '중요한 결정의 시기', 'advice': '가족과의 만남 준비'},
      {'period': '2년', 'event': '더 깊은 결합', 'advice': '공동의 목표 설정'};
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded),
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '미래 전망'),
                  style: theme.textTheme.headlineSmall)
                ),
            const SizedBox(height: 16),
            ...milestones.map((milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12),
                  vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    child: Text(
                      milestone['period'] as String),
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold),
                  color: theme.colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
                        Text(
                          milestone['event'] as String),
                  style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold)
                          ),
                        const SizedBox(height: 2),
                        Text(
                          milestone['advice'] as String),
                  style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
            )).toList(),
      
    );
}

  Widget _buildAdviceForSuccess() {
    final theme = Theme.of(context);
    
    final adviceCategories = [
      {
        'title': 'DO - 관계 발전을 위한 행동',
        'items': [
          '서로의 개성과 차이점을 존중하고 받아들이기',
          '정기적인 데이트와 특별한 추억 만들기',
          '감사와 애정 표현을 아끼지 않기',
          '함께 성장할 수 있는 공동의 목표 세우기',
        'icon': Icons.thumb_up,
        'color': Colors.green,
      {
        'title': "DON'T - 피해야 할 행동",
        'items': [
          '과거의 상처나 실수를 반복해서 언급하지 않기',
          '상대방을 다른 사람과 비교하지 않기',
          '중요한 결정을 혼자서 내리지 않기',
          '감정적일 때 충동적인 말이나 행동 피하기',
        'icon': Icons.thumb_down,
        'color': Colors.red;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded),
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '성공적인 관계를 위한 조언'),
                  style: theme.textTheme.headlineSmall)
                ),
            const SizedBox(height: 16),
            ...adviceCategories.map((category) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (category['color'] as Color).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category['icon'] as IconData),
                  size: 20),
                  color: category['color'] as Color),
                          const SizedBox(width: 8),
                          Text(
                            category['title'] as String),
                  style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold),
                  color: category['color'] as Color)
                            ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: (category['items'] as List).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline),
                  size: 16),
                  color: category['color'] as Color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item as String),
                  style: theme.textTheme.bodyMedium)
                                ),
                          ))).toList(),
                    ),
              ))).toList(),
      
    );
}
}