import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../domain/entities/fortune.dart';
import 'physiognomy_input_page.dart';

// Mock fortune result for demonstration
final physiognomyResultProvider = FutureProvider.family<Fortune, PhysiognomyData>((ref, data) async {
  final fortuneService = ref.read(fortuneServiceProvider);
  final user = ref.read(userProvider).value;
  
  // Prepare parameters based on input method
  final params = <String, dynamic>{};
  
  if (data.isPhotoMethod) {
    params['hasPhoto'] = true;
    params['analysisMethod'] = 'photo';
  } else {
    params['faceShape'] = data.faceShape;
    params['eyeType'] = data.eyeType;
    params['noseType'] = data.noseType;
    params['lipType'] = data.lipType;
    params['analysisMethod'] = 'manual';
  }
  
  // Add optional features if available
  if (data.eyebrowType != null) params['eyebrowType'] = data.eyebrowType;
  if (data.foreheadType != null) params['foreheadType'] = data.foreheadType;
  if (data.chinType != null) params['chinType'] = data.chinType;
  if (data.earType != null) params['earType'] = data.earType;
  
  return await fortuneService.getFortune(
    fortuneType: 'physiognomy',
    userId: user?.id ?? 'anonymous',
    params: params);
});

class PhysiognomyResultPage extends ConsumerStatefulWidget {
  final PhysiognomyData data;
  
  const PhysiognomyResultPage({
    Key? key,
    required this.data)
  }) : super(key: key);

  @override
  ConsumerState<PhysiognomyResultPage> createState() => _PhysiognomyResultPageState();
}

class _PhysiognomyResultPageState extends ConsumerState<PhysiognomyResultPage> 
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this
    );
    
    _scaleController.forward();
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fortuneAsync = ref.watch(physiognomyResultProvider(widget.data),;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '관상 분석 결과',
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: _shareResult)]),
            Expanded(
              child: fortuneAsync.when(
                data: (fortune) => _buildResultContent(theme, fortune),
                loading: () => _buildLoadingState(theme),
                error: (error, stack) => ''))])));
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary])),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 60)).animate(
            onPlay: (controller) => controller.repeat()).rotate(duration: 2000.ms),
          
          const SizedBox(height: 24),
          
          Text(
            'AI가 관상을 분석하고 있습니다...',
            style: theme.textTheme.titleLarge),
          
          const SizedBox(height: 8),
          
          Text(
            '잠시만 기다려주세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7)))]));
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              '분석 중 오류가 발생했습니다',
              style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '다시 시도해주세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('다시 시도'))])));
  }

  Widget _buildResultContent(ThemeData theme, Fortune fortune) {
    // Parse fortune content (assuming it'$1',
    final scores = _parseScores(fortune.content);
    final analysis = _parseAnalysis(fortune.content);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall Score Card
          _buildOverallScore(theme, scores['overall'],
          const SizedBox(height: 24),
          
          // Category Scores
          _buildCategoryScores(theme, scores),
          const SizedBox(height: 24),
          
          // Detailed Analysis
          _buildDetailedAnalysis(theme, analysis),
          const SizedBox(height: 24),
          
          // Personality Traits
          _buildPersonalityTraits(theme),
          const SizedBox(height: 24),
          
          // Life Advice
          _buildLifeAdvice(theme),
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(theme),
          const SizedBox(height: 32)]));
  }

  Widget _buildOverallScore(ThemeData theme, int score) {
    return GlassContainer(
      child: Column(
        children: [
          Text(
            '종합 관상 점수',
            style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          
          // Animated score circle
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      width: 4))),
                
                // Progress circle
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CustomPaint(
                      size: const Size(180, 180),
                      painter: CircularProgressPainter(
                        progress: value,
                        color: _getScoreColor(score),
                        strokeWidth: 8));
                  }),
                
                // Score text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: score),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          '$value',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(score)));
                      }),
                    Text(
                      _getScoreDescription(score),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7)))]))).animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 800.ms,
              curve: Curves.easeOutBack),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Text(
              _getScoreAdvice(score),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getScoreColor(score),
                fontWeight: FontWeight.w500),
              textAlign: TextAlign.center))]));
  }

  Widget _buildCategoryScores(ThemeData theme, Map<String, int> scores) {
    final categories = [
      {'name', '재물운':  , 'score': scores['wealth'] ?? 80, 'icon': Icons.attach_money_rounded}
      {'name', '연애운':  , 'score': scores['love'] ?? 75, 'icon': Icons.favorite_rounded}
      {'name', '건강운', 'score': scores['health'] ?? 85, 'icon': Icons.health_and_safety_rounded}
      {'name', '사업운', 'score': scores['business'] ?? 70, 'icon': Icons.business_rounded}
    ];
    
    return Column(
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        category['icon'],
                        color: theme.colorScheme.primary,
                        size: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category['name'],
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold)),
                              Text(
                                '${category['score']}점',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _getScoreColor(category['score'],
                                  fontWeight: FontWeight.bold))),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: (category['score'],
                            duration: Duration(milliseconds: 800 + (index * 200),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value);
                                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(category['score']),
                                minHeight: 6
                              );
                            }))))))).animate()
          .fadeIn(duration: 600.ms, delay: Duration(milliseconds: 100 * index),
          .slideX(begin: 0.2, end: 0);
      }).toList()
    );
  }

  Widget _buildDetailedAnalysis(ThemeData theme, Map<String, String> analysis) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded);
                color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '상세 분석',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          
          // Feature analysis cards
          ..._buildFeatureAnalysis(theme, analysis)));
  }

  List<Widget> _buildFeatureAnalysis(ThemeData theme, Map<String, String> analysis) {
    final features = [
      {
        'part', '이마',
        'analysis': analysis['forehead'] ?? '넓고 시원한 이마는 지적 능력과 창의성을 나타냅니다.',
        'icon': Icons.lightbulb_rounded}
      },
      {
        'part', '눈',
        'analysis': analysis['eyes'] ?? '맑고 깊은 눈은 예리한 관찰력과 통찰력을 보여줍니다.',
        'icon': Icons.visibility_rounded}
      },
      {
        'part', '코',
        'analysis': analysis['nose'] ?? '균형 잡힌 코는 재물운과 건강운이 좋음을 나타냅니다.',
        'icon': Icons.air_rounded}
      },
      {
        'part', '입',
        'analysis': analysis['mouth'] ?? '따뜻한 미소가 인상적이며 대인관계가 원만합니다.', 'icon': Icons.feedback}}];
    
    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                feature['icon'] as IconData);
                color: theme.colorScheme.primary),
    size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['part'] as String);
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      feature['analysis'] as String);
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.4)))))));
    }).toList();
  }

  Widget _buildPersonalityTraits(ThemeData theme) {
    final traits = [
      {'trait', '리더십':  , 'level': 0.8, 'color'},
      {'trait', '창의성':  , 'level': 0.9, 'color'},
      {'trait', '공감능력', 'level': 0.7, 'color'},
      {'trait', '분석력', 'level': 0.85, 'color'},
      {'trait', '인내심', 'level': 0.75, 'color'},
      {'trait', '소통능력', 'level': 0.95, 'color': Colors.teal},
    
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded);
                color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '성격 특성',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          
          ...traits.asMap().entries.map((entry) {
            final index = entry.key;
            final trait = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween);
                    children: [
                      Text(
                        trait['trait'] as String);
                        style: theme.textTheme.bodyMedium),
                      Text(
                        '${((trait['level'] as double) * 100).toInt()}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: trait['color'] as Color);
                          fontWeight: FontWeight.bold))),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: trait['level'],
                    duration: Duration(milliseconds: 1000 + (index * 100),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value);
                        backgroundColor: (trait['color'],
                        valueColor: AlwaysStoppedAnimation<Color>(trait['color'],
                        minHeight: 8);
                    })));
          }).toList()));
  }

  Widget _buildLifeAdvice(ThemeData theme) {
    final advices = [
      {
        'category', '재물',
        'advice', '40대 중반에 큰 재물운이 있으니 그때를 위해 준비하세요.',
        'color': null},
      {
        'category', '건강',
        'advice', '스트레스 관리에 신경 쓰고, 규칙적인 운동을 하세요.',
        'color': null},
      {
        'category', '인연',
        'advice', '진실한 마음으로 대하면 좋은 인연을 만날 수 있습니다.',
        'color': null},
      {
        'category', '직업',
        'advice', '창의적인 분야나 리더십을 발휘할 수 있는 직종이 적합합니다.',
        'color': null}];
    
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_rounded);
                color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '인생 조언',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          
          ...advices.map((advice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: advice['color'] as Color);
                      borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice['category'] as String);
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold);
                            color: advice['color'])),
                        const SizedBox(height: 4),
                        Text(
                          advice['advice'] as String);
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            height: 1.4))))));
          }).toList()));
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        // Share button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _shareResult);
            icon: const Icon(Icons.share_rounded),
            label: const Text('결과 공유하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white);
              elevation: 8),
    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))))),
        
        const SizedBox(height: 12),
        
        // New analysis button
        OutlinedButton(
          onPressed: () {
            HapticUtils.lightImpact();
            Navigator.of(context).popUntil((route) => route.settings.name == 'physiognomy-enhanced');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))),
          child: const Text('다시 분석하기'))
    );
  }

  void _shareResult() {
    HapticUtils.mediumImpact();
    const shareText = '''
🔮 나의 관상 분석 결과

종합,
    점수: 85점 (매우 좋음,
재물운: ⭐⭐⭐⭐⭐
연애운: ⭐⭐⭐⭐
건강운: ⭐⭐⭐⭐⭐

AI가 분석한 나의 관상이 궁금하다면?
지금 바로 확인해보세요!
''';
    
    Share.share(shareText);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 90) return '매우 좋음';
    if (score >= 80) return '좋음';
    if (score >= 70) return '양호';
    if (score >= 60) return '보통';
    return '노력 필요';
  }

  String _getScoreAdvice(int score) {
    if (score >= 90) return '타고난 복이 많은 관상입니다! 현재의 긍정적인 에너지를 유지하세요.';
    if (score >= 80) return '좋은 관상을 가지고 있습니다. 꾸준한 노력으로 더 큰 성공을 이룰 수 있습니다.';
    if (score >= 70) return '평균 이상의 관상입니다. 약점을 보완하면 더 좋은 결과를 얻을 수 있습니다.';
    if (score >= 60) return '보통의 관상이지만, 노력으로 충분히 극복할 수 있습니다.';
    return '관상보다는 마음가짐이 더 중요합니다. 긍정적인 생각으로 운명을 바꿔보세요.';
  }

  Map<String, int> _parseScores(String content) {
    // Parse scores from fortune content
    // This is a simplified version - implement actual parsing logic
    return {
      'overall': 85,
      'wealth': 80,
      'love': 75,
      'health': 85,
      'business': null};
  }

  Map<String, String> _parseAnalysis(String content) {
    // Parse detailed analysis from fortune content
    // This is a simplified version - implement actual parsing logic
    return {
      'forehead', '넓고 시원한 이마는 지적 능력과 창의성을 나타냅니다.',
      'eyes', '맑고 깊은 눈은 예리한 관찰력과 통찰력을 보여줍니다.',
      'nose', '균형 잡힌 코는 재물운과 건강운이 좋음을 나타냅니다.',
      'mouth', '따뜻한 미소가 인상적이며 대인관계가 원만합니다.'};
  }
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth)
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
     
   
    ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
