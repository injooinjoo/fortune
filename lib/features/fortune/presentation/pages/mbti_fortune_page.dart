import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'base_fortune_page.dart';
import '../widgets/cognitive_functions_radar_chart.dart';
import '../widgets/fortune_display.dart';
import '../widgets/mbti_compatibility_matrix.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../services/mbti_cognitive_functions_service.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/components/toast.dart';
import '../../../../shared/components/fortune_result_display.dart';
import '../../../../shared/glassmorphism/glass_container.dart' as glass;
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/fortune_provider.dart';

class MbtiFortunePage extends BaseFortunePage {
  const MbtiFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams}) : super(
          key: key,
          title: 'MBTI 운세',
          description: '당신의 MBTI 성격 유형에 따른 운세를 확인해보세요',
          fortuneType: 'mbti',
          requiresUserInfo: false,
          initialParams: initialParams);

  @override
  ConsumerState<MbtiFortunePage> createState() => _MbtiFortunePageState();
}

class _MbtiFortunePageState extends BaseFortunePageState<MbtiFortunePage> {
  String? _selectedMbti;
  final List<String> _selectedCategories = [];
  Map<String, double>? _cognitiveFunctions;
  late AnimationController _animationController;
  String? _selectedType1;
  String? _selectedType2;

  // MBTI Types
  static const List<String> _mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP'];

  // Fortune Categories
  static const List<String> _categories = [
    '연애운',
    '직업운',
    '재물운',
    '건강운',
    '대인관계',
    '학업운'];

  // MBTI Colors
  static const Map<String, List<Color>> _mbtiColors = {
    'INTJ': [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    'INTP': [Color(0xFF3B82F6), Color(0xFF1E40AF)],
    'ENTJ': [Color(0xFFDC2626), Color(0xFF991B1B)],
    'ENTP': [Color(0xFFF59E0B), Color(0xFFD97706)],
    'INFJ': [Color(0xFF10B981), Color(0xFF059669)],
    'INFP': [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    'ENFJ': [Color(0xFFEC4899), Color(0xFFBE185D)],
    'ENFP': [Color(0xFF14B8A6), Color(0xFF0D9488)],
    'ISTJ': [Color(0xFF6B7280), Color(0xFF4B5563)],
    'ISFJ': [Color(0xFF06B6D4), Color(0xFF0891B2)],
    'ESTJ': [Color(0xFFEF4444), Color(0xFFB91C1C)],
    'ESFJ': [Color(0xFFF472B6), Color(0xFFDB2777)],
    'ISTP': [Color(0xFF84CC16), Color(0xFF65A30D)],
    'ISFP': [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    'ESTP': [Color(0xFFF97316), Color(0xFFEA580C)],
    'ESFP': [Color(0xFFFFC107), Color(0xFFFF9800)]};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  bool get canGenerateFortune => 
      _selectedMbti != null && _selectedCategories.isNotEmpty;

  @override
  String? validateInput() {
    if (_selectedMbti == null) {
      return 'MBTI 유형을 선택해주세요';
    }
    if (_selectedCategories.isEmpty) {
      return '운세 카테고리를 하나 이상 선택해주세요';
    }
    return null;
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Set MBTI data and call API
    final mbtiNotifier = ref.read(mbtiFortuneProvider.notifier);
    mbtiNotifier.setMbtiData(
      mbtiType: _selectedMbti!,
      categories: _selectedCategories);

    await mbtiNotifier.loadFortune();
    
    final state = ref.read(mbtiFortuneProvider);
    if (state.error != null) {
      throw Exception(state.error);
    }
    
    if (state.fortune == null) {
      throw Exception('운세를 불러올 수 없습니다');
    }

    // Calculate cognitive functions for today
    _cognitiveFunctions = MbtiCognitiveFunctionsService.calculateDailyCognitiveFunctions(
      _selectedMbti!,
      DateTime.now());

    _animationController.forward();
    
    return state.fortune!;
  }

  @override
  Widget buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMbtiSelector(),
          const SizedBox(height: 24),
          _buildCategorySelector(),
          const SizedBox(height: 24),
          _buildGenerateButton()]));
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Show the base fortune result
          FortuneDisplay(
            title: fortune!.summary ?? 'MBTI 운세',
            description: fortune!.description ?? fortune!.content,
            overallScore: fortune!.score,
            luckyItems: fortune!.luckyItems,
            advice: fortune!.recommendations?.join('\n') ?? '',
            detailedFortune: {'content': null},
            warningMessage: fortune!.warnings?.join('\n')),
          const SizedBox(height: 24),
          // MBTI specific sections
          if (_cognitiveFunctions != null) ...[
            _buildCognitiveFunctionsSection(),
            const SizedBox(height: 16)],
          _buildMbtiInsights(),
          const SizedBox(height: 16),
          _buildMbtiStrengthsWeaknesses(),
          const SizedBox(height: 16),
          _buildMbtiCompatibility(),
          const SizedBox(height: 16),
          _buildEnhancedCompatibilityMatrix()]));
  }

  Widget _buildMbtiSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600]),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 24)),
            const SizedBox(width: 12),
            Text(
              'MBTI 유형 선택',
              style: theme.textTheme.headlineSmall)]),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: _mbtiTypes.map((mbti) {
            final isSelected = _selectedMbti == mbti;
            final colors = _mbtiColors[mbti]!;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMbti = mbti;
                });
                HapticUtils.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: colors)
                      : null,
                  color: isSelected ? null : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colors.first
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.first.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2))]
                      : null),
                child: Center(
                  child: Text(
                    mbti,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface)))));
          }).toList())]);
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600]),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(
                Icons.category_rounded,
                color: Colors.white,
                size: 24)),
            const SizedBox(width: 12),
            Text(
              '운세 카테고리 선택',
              style: theme.textTheme.headlineSmall)]),
        const SizedBox(height: 8),
        Text(
          '여러 개 선택 가능',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategories.contains(category);

            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
                HapticUtils.selectionClick();
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3)));
          }).toList())]);
  }

  Widget _buildGenerateButton() {
    final theme = Theme.of(context);
    final canGenerate = canGenerateFortune;

    return GlassButton(
      onPressed: canGenerate ? () => generateFortuneAction() : () {},
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: canGenerate
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8)])
              : null,
          borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(
            'MBTI 운세 보기',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: canGenerate
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.bold)))));
  }


  Widget _buildMbtiInsights() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: glass.GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.indigo.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  'MBTI 인사이트',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 20),
            ...(_selectedCategories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        category,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    Text(
                      _getMbtiCategoryInsight(_selectedMbti!, category),
                      style: theme.textTheme.bodyMedium)]));
            }).toList())])));
  }

  Widget _buildMbtiStrengthsWeaknesses() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: glass.GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8)),
                        child: Icon(
                          Icons.thumb_up_rounded,
                          color: Colors.green.shade600,
                          size: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '강점',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  ..._getMbtiStrengths(_selectedMbti!).map((strength) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: Colors.green.shade600)),
                          Expanded(
                            child: Text(
                              strength,
                              style: theme.textTheme.bodySmall))]));
                  }).toList()]))),
          const SizedBox(width: 12),
          Expanded(
            child: glass.GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8)),
                        child: Icon(
                          Icons.warning_rounded,
                          color: Colors.orange.shade600,
                          size: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '약점',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  ..._getMbtiWeaknesses(_selectedMbti!).map((weakness) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: Colors.orange.shade600)),
                          Expanded(
                            child: Text(
                              weakness,
                              style: theme.textTheme.bodySmall))]));
                  }).toList()])))]));
  }

  Widget _buildMbtiCompatibility() {
    final theme = Theme.of(context);
    final compatibleTypes = _getCompatibleMbti(_selectedMbti!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: glass.GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.pink.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.people_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '궁합이 좋은 MBTI',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: compatibleTypes.map((type) {
                final colors = _mbtiColors[type]!;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)));
              }).toList())])));
  }

  Widget _buildCognitiveFunctionsSection() {
    return glass.GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CognitiveFunctionsRadarChart(
            mbtiType: _selectedMbti!,
            functionLevels: _cognitiveFunctions!,
            showAnimation: true),
          const SizedBox(height: 16),
          _buildCognitiveInsights()]))
        .animate()
        .fadeIn(delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildCognitiveInsights() {
    final fortuneData = MbtiCognitiveFunctionsService.getDailyFortune(
      _selectedMbti!,
      DateTime.now(),
      _cognitiveFunctions!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.purple,
                size: 20),
              const SizedBox(width: 8),
              Text(
                '오늘의 인지기능 메시지',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))]),
          const SizedBox(height: 12),
          Text(
            fortuneData['message'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightChip(
                  '오늘의 행운 활동',
                  fortuneData['luckyActivity'],
                  Colors.green)),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInsightChip(
                  '주의할 점',
                  fortuneData['cautionArea'],
                  Colors.orange))])]));
  }

  Widget _buildInsightChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8)))]));
  }

  // MBTI Helper Methods
  String _getMbtiTitle(String mbti) {
    final titles = {
      'INTJ': '전략가',
      'INTP': '사색가',
      'ENTJ': '통솔자',
      'ENTP': '변론가',
      'INFJ': '옹호자',
      'INFP': '중재자',
      'ENFJ': '선도자',
      'ENFP': '활동가',
      'ISTJ': '현실주의자',
      'ISFJ': '수호자',
      'ESTJ': '경영자',
      'ESFJ': '집정관',
      'ISTP': '장인',
      'ISFP': '모험가',
      'ESTP': '사업가',
      'ESFP': '연예인'
    };
    return titles[mbti] ?? mbti;
  }

  String _getMbtiDescription(String mbti) {
    final descriptions = {
      'INTJ': '독립적이고 전략적인 사고를 가진 완벽주의자',
      'INTP': '논리적이고 창의적인 사고를 즐기는 분석가',
      'ENTJ': '대담하고 상상력이 풍부한 강한 의지의 지도자',
      'ENTP': '똑똑하고 호기심이 많은 사색가',
      'INFJ': '조용하고 신비로우며 영감을 주는 이상주의자',
      'INFP': '상냥하고 창의적이며 이상적인 중재자',
      'ENFJ': '카리스마 있고 영감을 주는 리더',
      'ENFP': '열정적이고 창의적인 사교적인 자유영혼',
      'ISTJ': '실용적이고 사실적이며 신뢰할 수 있는 사람',
      'ISFJ': '헌신적이고 따뜻한 수호자',
      'ESTJ': '탁월한 관리자이자 행정가',
      'ESFJ': '배려심이 많고 사교적인 협력자',
      'ISTP': '대담하고 실용적인 실험가',
      'ISFP': '유연하고 매력적인 예술가',
      'ESTP': '똑똑하고 에너지 넘치는 인식력이 뛰어난 사람',
      'ESFP': '자발적이고 열정적인 연예인'};
    return descriptions[mbti] ?? '';
  }

  String _getMbtiCategoryInsight(String mbti, String category) {
    // This would normally come from the API response
    // For now, return mock insights based on MBTI and category
    final insights = {
      '연애운': {
        'INTJ': '이성적인 접근보다는 감정적인 교감을 시도해보세요. 상대방의 작은 변화에도 관심을 가져주면 좋은 결과가 있을 것입니다.',
        'ENFP': '당신의 열정과 긍정적인 에너지가 상대방을 매료시킬 것입니다. 다만 너무 앞서가지 않도록 주의하세요.'},
      '직업운': {
        'INTJ': '당신의 전략적 사고가 빛을 발할 시기입니다. 장기적인 프로젝트에 집중하면 큰 성과를 얻을 수 있습니다.',
        'ENFP': '창의적인 아이디어가 샘솟는 시기입니다. 동료들과의 브레인스토밍에서 좋은 결과를 얻을 수 있습니다.'}
    };

    return insights[category]?[mbti] ?? 
        '$mbti 유형의 $category는 이번 달 긍정적인 흐름이 예상됩니다. 자신의 강점을 활용하면 좋은 결과를 얻을 수 있을 것입니다.';
  }

  List<String> _getMbtiStrengths(String mbti) {
    final strengths = {
      'INTJ': ['전략적 사고', '독립성', '결단력', '효율성'],
      'INTP': ['논리적 사고', '창의성', '객관성', '지적 호기심'],
      'ENTJ': ['리더십', '효율성', '자신감', '목표 지향성'],
      'ENTP': ['창의성', '적응력', '논리력', '도전 정신'],
      'INFJ': ['통찰력', '이상주의', '결단력', '창의성'],
      'INFP': ['이상주의', '충성심', '적응력', '열정'],
      'ENFJ': ['카리스마', '이타심', '리더십', '신뢰성'],
      'ENFP': ['열정', '창의성', '사교성', '관찰력'],
      'ISTJ': ['신뢰성', '실용성', '헌신', '정직'],
      'ISFJ': ['지원', '신뢰성', '인내', '상상력'],
      'ESTJ': ['헌신', '강인함', '직접성', '충성심'],
      'ESFJ': ['충성심', '민감성', '따뜻함', '실용성'],
      'ISTP': ['낙관주의', '창의성', '실용성', '자발성'],
      'ISFP': ['매력', '열정', '호기심', '예술성'],
      'ESTP': ['대담함', '직접성', '독창성', '사교성'],
      'ESFP': ['대담함', '독창성', '미적감각', '실용성']
    };
    return strengths[mbti] ?? [];
  }

  List<String> _getMbtiWeaknesses(String mbti) {
    final weaknesses = {
      'INTJ': ['오만함', '감정 표현 부족', '과도한 분석', '비판적'],
      'INTP': ['둔감함', '조급함', '비판적', '사생활 중시'],
      'ENTJ': ['완고함', '지배적', '편협함', '감정 억제'],
      'ENTP': ['논쟁적', '둔감함', '집중력 부족', '실용성 부족'],
      'INFJ': ['과도한 민감성', '극도로 사적', '완벽주의', '갈등 회피'],
      'INFP': ['자기비판적', '비실용적', '감정적', '사적'],
      'ENFJ': ['지나치게 이상적', '너무 이타적', '민감함', '우유부단'],
      'ENFP': ['승인 추구', '지나친 낙관', '산만함', '감정적'],
      'ISTJ': ['완고함', '둔감함', '자책', '판단적'],
      'ISFJ': ['이타적', '억압적', '수줍음', '과부하'],
      'ESTJ': ['융통성부족', '판단적', '집중곤란', '감정표현부족'],
      'ESFJ': ['걱정', '융통성부족', '취약', '이타적'],
      'ISTP': ['완고함', '둔감함', '사적', '쉽게지루함'],
      'ISFP': ['과도한경쟁심', '예측불가', '쉽게스트레스', '자존감변동'],
      'ESTP': ['둔감함', '조급함', '위험추구', '비체계적'],
      'ESFP': ['민감함', '갈등회피', '쉽게지루함', '집중력부족']
    };
    return weaknesses[mbti] ?? [];
  }

  List<String> _getCompatibleMbti(String mbti) {
    final compatibility = {
      'INTJ': ['ENFP', 'ENTP', 'INFJ'],
      'INTP': ['ENTJ', 'ENFJ', 'INTJ'],
      'ENTJ': ['INTP', 'INFP', 'INTJ'],
      'ENTP': ['INFJ', 'INTJ', 'ENFJ'],
      'INFJ': ['ENTP', 'ENFP', 'INTJ'],
      'INFP': ['ENFJ', 'ENTJ', 'INFJ'],
      'ENFJ': ['INFP', 'ISFP', 'INTP'],
      'ENFP': ['INFJ', 'INTJ', 'ENFJ'],
      'ISTJ': ['ESFP', 'ESTP', 'ISFJ'],
      'ISFJ': ['ESFJ', 'ESTP', 'ISTJ'],
      'ESTJ': ['ISTP', 'ISFP', 'ISTJ'],
      'ESFJ': ['ISFJ', 'ISTP', 'ISFP'],
      'ISTP': ['ESFJ', 'ESTJ', 'ISFP'],
      'ISFP': ['ESFJ', 'ESTJ', 'ISTP'],
      'ESTP': ['ISFJ', 'ISTJ', 'ESFP'],
      'ESFP': ['ISFJ', 'ISTJ', 'ESTP']
    };
    return compatibility[mbti] ?? [];
  }

  Widget _buildEnhancedCompatibilityMatrix() {
    if (_selectedMbti == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MbtiCompatibilityMatrix(
        selectedType1: _selectedType1 ?? _selectedMbti,
        selectedType2: _selectedType2,
        onPairSelected: (type1, type2) {
          setState(() {
            _selectedType1 = type1;
            _selectedType2 = type2;
          });
        },
        showAnimation: true));
  }
}

// Add HapticUtils if not already present
class HapticUtils {
  static void lightImpact() {
    // Implement haptic feedback
  }
  
  static void selectionClick() {
    // Implement haptic feedback
  }
}