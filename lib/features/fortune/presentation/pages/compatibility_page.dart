import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../shared/components/korean_date_picker.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';

class CompatibilityPage extends BaseFortunePage {
  const CompatibilityPage({Key? key, Map<String, dynamic>? initialParams})
      : super(
          key: key,
          title: '궁합',
          description: '두 사람의 궁합을 확인해보세요',
          fortuneType: 'compatibility',
          requiresUserInfo: true,
          initialParams: initialParams
        );

  @override
  ConsumerState<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends BaseFortunePageState<CompatibilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _person1NameController = TextEditingController();
  final _person2NameController = TextEditingController();
  DateTime? _person1BirthDate;
  DateTime? _person2BirthDate;
  
  Map<String, dynamic>? _compatibilityData;
  
  @override
  void initState() {
    super.initState();
    
    // Pre-fill first person's data with user profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userProfile != null) {
        setState(() {
          _person1NameController.text = userProfile!.name ?? '';
          _person1BirthDate = userProfile!.birthDate;
        });
      }
    });
  }

  @override
  void dispose() {
    _person1NameController.dispose();
    _person2NameController.dispose();
    super.dispose();
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_person1BirthDate == null || _person2BirthDate == null) {
        return null;
      }
      
      return {
        'person1': {}
          'name': _person1NameController.text,
          'birthDate': null},
        'person2': {
          , 'name': _person2NameController.text,
          'birthDate': null}};
    }
    return null;
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // Use actual API call
    final fortuneService = ref.read(fortuneServiceProvider);
    final fortune = await fortuneService.getCompatibilityFortune(
      person1: params['person1'],
      person2: params['person2'] as Map<String, dynamic>
    );

    // Extract compatibility data from the fortune response
    _compatibilityData = {
      'scores': fortune.scoreBreakdown ?? {}
        '전체 궁합': fortune.overallScore ?? 85,
        '사랑 궁합': 90,
        '결혼 궁합': 82,
        '일상 궁합': 78,
        '직장 궁합')},
      'person1Analysis': fortune.additionalInfo?['person1Analysis'] ?? {
        'personality', '따뜻하고 배려심이 깊은 성격',
        'loveStyle', '헌신적이고 로맨틱한 사랑',
        'strength', '상대방을 포용하는 넓은 마음'},
      'person2Analysis': fortune.additionalInfo?['person2Analysis'] ?? {
        'personality', '활발하고 긍정적인 성격',
        'loveStyle', '열정적이고 적극적인 사랑',
        'strength', '밝은 에너지로 분위기를 이끄는 힘'},
      'strengths': fortune.additionalInfo?['strengths'] ?? [
        '서로를 보완하는 완벽한 조합',
        '갈등 상황에서도 대화로 해결 가능',
        '함께 성장할 수 있는 관계'],
      'challenges': fortune.additionalInfo?['challenges'] ?? [
        '가끔 의견 차이로 인한 마찰 가능',
        '서로의 공간을 존중하는 것이 필요'],
      'luckyElements': fortune.luckyItems ?? {
        '행운의 날', '금요일',
        '행운의 장소', '자연이 있는 곳',
        '행운의 활동', '함께하는 운동',
        '행운의 색', '파란색과 초록색'}};

    return fortune;
  }

  @override
  Widget buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildPersonInputSection(
            title: '첫 번째 사람',
            nameController: _person1NameController,
            birthDate: _person1BirthDate,
            onDateSelected: (date) {
              setState(() {
                _person1BirthDate = date;
              });
            },
            gradientColors: [Colors.pink.shade300, Colors.pink.shade500],
            icon: Icons.person),
          const SizedBox(height: 24),
          _buildHeartConnector(),
          const SizedBox(height: 24),
          _buildPersonInputSection(
            title: '두 번째 사람',
            nameController: _person2NameController,
            birthDate: _person2BirthDate,
            onDateSelected: (date) {
              setState(() {
                _person2BirthDate = date;
              });
            },
            gradientColors: [Colors.blue.shade300, Colors.blue.shade500],
            icon: Icons.person)]));
  }

  Widget _buildPersonInputSection({
    required String title,
    required TextEditingController nameController,
    required DateTime? birthDate,
    required Function(DateTime) onDateSelected,
    required List<Color> gradientColors,
    required IconData icon}) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.headlineSmall)]),
          const SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.edit_rounded),
              filled: true,
              fillColor: theme.colorScheme.surface),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이름을 입력해주세요';
              }
              return null;
            }),
          const SizedBox(height: 16),
          KoreanDatePicker(
            label: '생년월일',
            initialDate: birthDate,
            onDateSelected: onDateSelected,
            showAge: true)])).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeartConnector() {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.pink.shade300,
                  Colors.red.shade400,
                  Colors.blue.shade300]))),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade600]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5)]),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 28))])).animate(onPlay: (controller) => controller.repeat(),
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: 1500.ms,
          curve: Curves.easeInOut)
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(0.9, 0.9),
          duration: 1500.ms,
          curve: Curves.easeInOut);
  }

  @override
  Widget buildFortuneResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverallCompatibility(),
          const SizedBox(height: 24),
          _buildDetailedScores(),
          const SizedBox(height: 24),
          _buildPersonalityAnalysis(),
          const SizedBox(height: 24),
          _buildStrengthsAndChallenges(),
          const SizedBox(height: 24),
          _buildLuckyElements(),
          const SizedBox(height: 32)]));
  }

  Widget _buildOverallCompatibility() {
    final overallScore = _compatibilityData!['scores']['전체 궁합'] as int;
    final theme = Theme.of(context);

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(32),
      liquidColors: [
        Colors.pink.shade200,
        Colors.red.shade200,
        Colors.purple.shade200],
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 15.0,
            animation: true,
            animationDuration: 1500,
            percent: overallScore / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$overallScore%',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600)),
                Text(
                  '전체 궁합',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))]),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.red.shade400,
            backgroundColor: Colors.red.shade100),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPersonBadge(
                _person1NameController.text,
                Colors.pink.shade400),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.red.shade400,
                  size: 32)),
              _buildPersonBadge(
                _person2NameController.text,
                Colors.blue.shade400)]),
          const SizedBox(height: 16),
          Text(
            _getCompatibilityMessage(overallScore),
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center)])).animate().fadeIn().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1));
  }

  Widget _buildPersonBadge(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold)));
  }

  Widget _buildDetailedScores() {
    final scores = _compatibilityData!['scores'] as Map<String, dynamic>;
    final detailedScores = Map<String, dynamic>.from(scores)..remove('전체 궁합');

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 궁합 점수',
            style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          ...detailedScores.entries.map((entry) {
            final icon = _getScoreIcon(entry.key);
            final color = _getScoreColor(entry.value as int);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyLarge),
                            Text(
                              '${entry.value}%',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color))]),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (entry.value as int) / 100,
                          backgroundColor: color.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8)]))]));
          }).toList()]));
  }

  Widget _buildPersonalityAnalysis() {
    final person1 = _compatibilityData!['person1Analysis'] as Map<String, dynamic>;
    final person2 = _compatibilityData!['person2Analysis'] as Map<String, dynamic>;

    return Column(
      children: [
        _buildPersonalityCard(
          name: _person1NameController.text,
          analysis: person1,
          color: Colors.pink.shade400),
        const SizedBox(height: 16),
        _buildPersonalityCard(
          name: _person2NameController.text,
          analysis: person2,
          color: Colors.blue.shade400)]);
  }

  Widget _buildPersonalityCard({
    required String name,
    required Map<String, dynamic> analysis,
    required Color color}) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                child: Center(
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)))),
              const SizedBox(width: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall)]),
          const SizedBox(height: 16),
          _buildAnalysisItem(
            icon: Icons.person_outline_rounded,
            title: '성격',
            content: analysis['personality']),
          const SizedBox(height: 12),
          _buildAnalysisItem(
            icon: Icons.favorite_outline_rounded,
            title: '연애 스타일',
            content: analysis['loveStyle']),
          const SizedBox(height: 12),
          _buildAnalysisItem(
            icon: Icons.star_outline_rounded,
            title: '강점',
            content: analysis['strength'])]));
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required String title,
    required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium)]))]);
  }

  Widget _buildStrengthsAndChallenges() {
    final strengths = _compatibilityData!['strengths'] as List<dynamic>;
    final challenges = _compatibilityData!['challenges'] as List<dynamic>;

    return Column(
      children: [
        _buildListCard(
          title: '강점',
          items: strengths.cast<String>(),
          icon: Icons.thumb_up_rounded,
          color: Colors.green.shade600),
        const SizedBox(height: 16),
        _buildListCard(
          title: '주의점',
          items: challenges.cast<String>(),
          icon: Icons.warning_rounded,
          color: Colors.orange.shade600)]);
  }

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color}) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall)]),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium))])).toList()]));
  }

  Widget _buildLuckyElements() {
    final luckyElements = _compatibilityData!['luckyElements'] as Map<String, dynamic>;

    return ShimmerGlass(
      shimmerColor: Colors.amber,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
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
                      colors: [Colors.amber.shade400, Colors.amber.shade600]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Colors.white,
                    size: 24)),
                const SizedBox(width: 12),
                Text(
                  '행운의 요소',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: luckyElements.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade50,
                        Colors.amber.shade100]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.shade300)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade800)),
                      const SizedBox(height: 2),
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900))]));
              }).toList())])));
  }

  String _getCompatibilityMessage(int score) {
    if (score >= 90) return '천생연분! 운명적인 만남입니다 💕';
    if (score >= 80) return '환상의 커플! 서로를 완벽하게 보완합니다';
    if (score >= 70) return '좋은 궁합! 노력하면 더 좋아질 수 있어요';
    if (score >= 60) return '평균적인 궁합. 서로를 이해하려 노력하세요';
    return '도전이 필요한 관계. 하지만 사랑은 기적을 만들죠!';
  }

  IconData _getScoreIcon(String type) {
    switch (type) {
      case '사랑 궁합': return Icons.favorite_rounded;
      case '결혼 궁합':
        return Icons.celebration_rounded;
      case '일상 궁합':
        return Icons.home_rounded;
      case , '직장 궁합': return Icons.work_rounded;
      default:
        return Icons.star_rounded;}
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.red.shade400;
    if (score >= 60) return Colors.orange.shade400;
    return Colors.blue.shade400;
  }
}