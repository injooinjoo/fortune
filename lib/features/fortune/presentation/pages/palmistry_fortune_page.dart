import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class PalmistryFortunePage extends BaseFortunePage {
  const PalmistryFortunePage({Key? key})
      : super(
          key: key,
          title: '손금 운세',
          description: '손금으로 보는 당신의 운명과 미래',
          fortuneType: 'palmistry',
          requiresUserInfo: false
        );

  @override
  ConsumerState<PalmistryFortunePage> createState() => _PalmistryFortunePageState();
}

class _PalmistryFortunePageState extends BaseFortunePageState<PalmistryFortunePage> {
  String? _dominantHand;
  String? _lifeLine;
  String? _heartLine;
  String? _headLine;
  String? _fateLine;
  bool _hasMarriageLine = false;
  bool _hasChildrenLine = false;
  String? _palmShape;
  File? _palmImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _palmShapes = {
    'earth': '땅형 손 (사각형)',
    'air': '공기형 손 (긴 손가락)',
    'water': '물형 손 (긴 손바닥)',
    'fire': '불형 손 (짧은 손가락)'};

  final Map<String, String> _lineCharacteristics = {
    'deep': '깊고 선명함',
    'shallow': '얕고 희미함',
    'broken': '끊어진 부분 있음',
    'forked': '갈라진 부분 있음',
    'curved': '곡선형',
    'straight': '직선형'};

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_dominantHand == null || _lifeLine == null || 
        _heartLine == null || _headLine == null || 
        _palmShape == null) {
      return null;
    }

    return {
      'dominantHand': _dominantHand,
      'lifeLine': _lifeLine,
      'heartLine': _heartLine,
      'headLine': _headLine,
      'fateLine': _fateLine,
      'hasMarriageLine': _hasMarriageLine,
      'hasChildrenLine': _hasChildrenLine,
      'palmShape': _palmShape};
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Camera Capture Section
        _buildCameraCaptureSection(),
        const SizedBox(height: 16),
        // Palm Guide Illustration
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                '손금 가이드',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: CustomPaint(
                  painter: PalmGuidePainter(theme),
                  size: const Size(double.infinity, 250))),
              const SizedBox(height: 16),
              _buildPalmLegend()])),
        const SizedBox(height: 16),
        
        // Dominant Hand Selection
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '주로 사용하는 손',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildHandOption('left', '왼손', Icons.pan_tool_alt_rounded)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHandOption('right', '오른손', Icons.pan_tool_rounded))]
            ])
          )
        ),
        const SizedBox(height: 16),
        
        // Palm Shape Selection
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '손 모양',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: _palmShapes.entries.map((entry) {
                  final isSelected = _palmShape == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _palmShape = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Center(
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? theme.colorScheme.primary : null),
                          textAlign: TextAlign.center))));
                }).toList())])),
        const SizedBox(height: 16),
        
        // Main Lines Analysis
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '주요 손금 분석',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              // Life Line
              _buildLineAnalysis(
                '생명선',
                _lifeLine,
                (value) => setState(() => _lifeLine = value),
                Icons.favorite_rounded,
                Colors.red),
              const SizedBox(height: 16),
              
              // Heart Line
              _buildLineAnalysis(
                '감정선',
                _heartLine,
                (value) => setState(() => _heartLine = value),
                Icons.volunteer_activism_rounded,
                Colors.pink),
              const SizedBox(height: 16),
              
              // Head Line
              _buildLineAnalysis(
                '두뇌선',
                _headLine,
                (value) => setState(() => _headLine = value),
                Icons.psychology_rounded,
                Colors.blue),
              const SizedBox(height: 16),
              
              // Fate Line (Optional)
              _buildLineAnalysis(
                '운명선',
                _fateLine,
                (value) => setState(() => _fateLine = value),
                Icons.stars_rounded,
                Colors.purple,
                isOptional: true)])),
        const SizedBox(height: 16),
        
        // Additional Lines
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기타 손금',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              _buildSwitchTile(
                '결혼선이 있나요?',
                _hasMarriageLine,
                (value) => setState(() => _hasMarriageLine = value),
                Icons.favorite_border_rounded),
              const SizedBox(height: 8),
              _buildSwitchTile(
                '자녀선이 있나요?',
                _hasChildrenLine,
                (value) => setState(() => _hasChildrenLine = value),
                Icons.child_care_rounded)]))]
    );
  }

  Widget _buildHandOption(String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _dominantHand == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _dominantHand = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        blur: 10,
        borderColor: isSelected
            ? theme.colorScheme.primary.withOpacity(0.5)
            : Colors.transparent,
        borderWidth: isSelected ? 2 : 0,
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null))])));
  }

  Widget _buildPalmLegend() {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('생명선', Colors.red),
        _buildLegendItem('감정선', Colors.blue),
        _buildLegendItem('두뇌선', Colors.green),
        _buildLegendItem('운명선', Colors.orange)]
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall)]
    );
  }

  Widget _buildLineAnalysis(
    String lineName,
    String? currentValue,
    Function(String?) onChanged,
    IconData icon,
    Color color, {
    bool isOptional = false}) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              lineName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold)),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Text(
                '(선택사항)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6)))]]),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            hintText: isOptional ? '없으면 선택하지 마세요' : '선의 특징을 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surface.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          items: [
            if (isOptional)
              const DropdownMenuItem(
                value: null,
                child: Text('없음')),
            ..._lineCharacteristics.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value));
            }).toList()],
          onChanged: onChanged)]
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
        _buildPalmReadingResult(),
        _buildLineInterpretation(),
        _buildPersonalityTraits(),
        _buildLifePathGuidance()]
    );
  }

  Widget _buildPalmReadingResult() {
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
                Icon(
                  Icons.pan_tool_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '손금 분석 결과',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 24),
            _buildAnalysisItem(
              '전체적인 운명',
              '당신의 손금은 강한 의지와 끈기를 나타냅니다. 인생의 중요한 전환점이 다가오고 있으며, 새로운 기회가 열릴 것입니다.',
              Icons.auto_awesome_rounded),
            const SizedBox(height: 16),
            _buildAnalysisItem(
              '재물운',
              '운명선과 태양선이 교차하는 지점에서 큰 재물운이 예상됩니다. 특히 40대 중반에 경제적 안정을 찾을 것입니다.',
              Icons.monetization_on_rounded),
            const SizedBox(height: 16),
            _buildAnalysisItem(
              '건강운',
              '생명선이 깊고 선명하여 전반적으로 건강한 삶을 살 것입니다. 다만 스트레스 관리에 주의가 필요합니다.',
              Icons.favorite_rounded)])));
  }

  Widget _buildAnalysisItem(String title, String description, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8)))]))]
    );
  }

  Widget _buildLineInterpretation() {
    final theme = Theme.of(context);
    
    final interpretations = [
      {
        'line': '생명선',
        'meaning': '활력과 생명력',
        'interpretation': '깊고 선명한 생명선은 강한 체력과 활력을 의미합니다.',
        'color': Colors.red},
      {
        'line': '감정선',
        'meaning': '사랑과 감정',
        'interpretation': '곡선형 감정선은 따뜻하고 표현력이 풍부한 성격을 나타냅니다.',
        'color': Colors.pink},
      {
        'line': '두뇌선',
        'meaning': '지성과 사고력',
        'interpretation': '직선형 두뇌선은 논리적이고 분석적인 사고를 의미합니다.',
        'color': Colors.blue},
      {
        'line': '운명선',
        'meaning': '인생의 방향',
        'interpretation': '선명한 운명선은 명확한 인생 목표와 강한 의지를 나타냅니다.',
        'color': Colors.purple}];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '손금별 해석',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            ...interpretations.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (item['color'] as Color).withOpacity(0.1),
                      (item['color'] as Color).withOpacity(0.2)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (item['color'] as Color).withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          color: item['color'] as Color),
                        const SizedBox(width: 8),
                        Text(
                          item['line'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item['color'] as Color)),
                        const Text(' - '),
                        Text(
                          item['meaning'] as String,
                          style: theme.textTheme.bodyMedium)]),
                    const SizedBox(height: 8),
                    Text(
                      item['interpretation'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8)))]))))).toList()]))))));
  }

  Widget _buildPersonalityTraits() {
    final theme = Theme.of(context);
    
    final traits = [
      {'trait': '리더십', 'score': 85},
      {'trait': '창의성', 'score': 90},
      {'trait': '인내심', 'score': 75},
      {'trait': '직관력', 'score': 80},
      {'trait': '소통능력', 'score': 85}];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '성격 특성',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            ...traits.map((trait) {
              final score = trait['score'] as int;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trait['trait'] as String,
                          style: theme.textTheme.bodyMedium),
                        Text(
                          '$score%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary))]),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(score)))]));
            }).toList()])));
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLifePathGuidance() {
    final theme = Theme.of(context);
    
    final guidances = [
      {
        'age': '20대',
        'guidance': '학업과 자기계발에 집중하세요. 인맥 형성이 중요한 시기입니다.',
        'icon': Icons.feedback},
      {
        'age': '30대',
        'guidance': '경력 개발과 가정 형성의 균형을 맞추세요. 큰 도약의 기회가 있습니다.',
        'icon': Icons.feedback},
      {
        'age': '40대',
        'guidance': '안정적인 성장기입니다. 투자와 재테크에 관심을 가지세요.',
        'icon': Icons.feedback},
      {
        'age': '50대 이후',
        'guidance': '지혜를 나누고 후진 양성에 힘쓰세요. 건강 관리가 중요합니다.',
        'icon': Icons.feedback}
    ];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.explore_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '인생 가이드',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            ...guidances.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: theme.colorScheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['age'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          item['guidance'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8)))]))]))).toList()])));
  }
}

// Custom painter for palm guide
class PalmGuidePainter extends CustomPainter {
  final ThemeData theme;

  PalmGuidePainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw palm outline
    paint.color = theme.colorScheme.onSurface.withOpacity(0.3);
    final palmPath = Path();
    palmPath.moveTo(size.width * 0.3, size.height * 0.9);
    palmPath.quadraticBezierTo(
      size.width * 0.1, size.height * 0.6,
      size.width * 0.2, size.height * 0.3
    );
    palmPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.5, size.height * 0.05
    );
    palmPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.1,
      size.width * 0.8, size.height * 0.3
    );
    palmPath.quadraticBezierTo(
      size.width * 0.9, size.height * 0.6,
      size.width * 0.7, size.height * 0.9
    );
    palmPath.close();
    canvas.drawPath(palmPath, paint);

    // Draw life line (red)
    paint.color = Colors.red;
    final lifeLine = Path();
    lifeLine.moveTo(size.width * 0.3, size.height * 0.2);
    lifeLine.quadraticBezierTo(
      size.width * 0.5, size.height * 0.5,
      size.width * 0.4, size.height * 0.8
    );
    canvas.drawPath(lifeLine, paint);

    // Draw heart line (pink)
    paint.color = Colors.pink;
    final heartLine = Path();
    heartLine.moveTo(size.width * 0.2, size.height * 0.3);
    heartLine.quadraticBezierTo(
      size.width * 0.5, size.height * 0.25,
      size.width * 0.8, size.height * 0.3
    );
    canvas.drawPath(heartLine, paint);

    // Draw head line (blue)
    paint.color = Colors.blue;
    final headLine = Path();
    headLine.moveTo(size.width * 0.25, size.height * 0.4);
    headLine.lineTo(size.width * 0.7, size.height * 0.45);
    canvas.drawPath(headLine, paint);

    // Draw fate line (purple)
    paint.color = Colors.purple;
    paint.strokeWidth = 1.5;
    // Note: Dashed lines not directly supported in Flutter Canvas
    final fateLine = Path();
    fateLine.moveTo(size.width * 0.5, size.height * 0.8);
    fateLine.lineTo(size.width * 0.5, size.height * 0.4);
    canvas.drawPath(fateLine, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on _PalmistryFortunePageState {
  Widget _buildCameraCaptureSection() {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt_rounded,
                color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '손 사진 촬영',
                style: theme.textTheme.headlineSmall)]),
          const SizedBox(height: 16),
          if (_palmImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    _palmImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _palmImage = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white))]),
            const SizedBox(height: 16)],
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _takePicture,
                  borderRadius: BorderRadius.circular(12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    blur: 10,
                    borderColor: theme.colorScheme.primary.withOpacity(0.3),
                    borderWidth: 1,
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          '사진 촬영',
                          style: theme.textTheme.bodyMedium)])))),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickFromGallery,
                  borderRadius: BorderRadius.circular(12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(12),
                    blur: 10,
                    borderColor: theme.colorScheme.primary.withOpacity(0.3),
                    borderWidth: 1,
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 32,
                          color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          '갤러리에서 선택',
                          style: theme.textTheme.bodyMedium)]))))]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3))),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '밝은 곳에서 손바닥을 평평하게 펴고 촬영해주세요',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8))))])]));
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85);
      
      if (photo != null) {
        setState(() {
          _palmImage = File(photo.path);
        });
      }
    } catch (e) {
      Toast.show(
        context,
        message: '없습니다: $e',
        type: ToastType.error);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85);
      
      if (image != null) {
        setState(() {
          _palmImage = File(image.path);
        });
      }
    } catch (e) {
      Toast.show(
        context,
        message: '없습니다: $e',
        type: ToastType.error
      );
    }
  }
}