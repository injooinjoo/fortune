import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'base_fortune_page.dart' hide Icon;
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';

class PhysiognomyFortunePage extends BaseFortunePage {
  const PhysiognomyFortunePage({Key? key})
      : super(
          key: key,
    title: '관상 운세',
          description: '얼굴에 담긴 운명과 성격 분석',
          fortuneType: 'physiognomy',
          requiresUserInfo: false);

  @override
  ConsumerState<PhysiognomyFortunePage> createState() => _PhysiognomyFortunePageState();
}

class _PhysiognomyFortunePageState extends BaseFortunePageState<PhysiognomyFortunePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  String? _faceShape;
  String? _eyebrowType;
  String? _eyeType;
  String? _noseType;
  String? _lipType;
  String? _earType;
  String? _foreheadType;
  String? _chinType;

  final Map<String, String> _faceShapes = {
    'round': '둥근형',
    'oval': '계란형',
    'square': '사각형',
    'heart': '하트형',
    'diamond': '다이아몬드형',
    'oblong': '직사각형',
  };

  final Map<String, String> _eyebrowTypes = {
    'straight': '일자 눈썹',
    'arched': '아치형 눈썹',
    'angled': '각진 눈썹',
    'rounded': '둥근 눈썹',
    'thick': '진한 눈썹',
    'thin': '얇은 눈썹',
  };

  final Map<String, String> _eyeTypes = {
    'big': '큰 눈',
    'small': '작은 눈',
    'round': '둥근 눈',
    'almond': '아몬드형 눈',
    'droopy': '처진 눈',
    'upturned': '올라간 눈',
  };

  final Map<String, String> _noseTypes = {
    'high': '높은 코',
    'low': '낮은 코',
    'straight': '곧은 코',
    'hooked': '매부리코',
    'snub': '들창코',
    'wide': '넓은 코',
  };

  final Map<String, String> _lipTypes = {
    'full': '도톰한 입술',
    'thin': '얇은 입술',
    'heart': '하트형 입술',
    'wide': '넓은 입술',
    'small': '작은 입술',
    'uneven': '비대칭 입술',
  };

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
    if (_faceShape == null || _eyebrowType == null || 
        _eyeType == null || _noseType == null || 
        _lipType == null) {
      return null;
    }

    return {
      'faceShape': _faceShape,
      'eyebrowType': _eyebrowType,
      'eyeType': _eyeType,
      'noseType': _noseType,
      'lipType': _lipType,
      'earType': _earType,
      'foreheadType': _foreheadType,
      'chinType': _chinType,
      'hasImage': _selectedImage != null
    };
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Toast.error(context, '이미지를 선택하는 중 오류가 발생했습니다.');
    }
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Photo Upload Section
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                '얼굴 사진 업로드 (선택사항)',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'AI가 더 정확한 관상 분석을 제공합니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 16),
              if (_selectedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover)),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('사진 제거'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red))
              ] else ...[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      width: 2,
                      style: BorderStyle.solid)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.face_rounded,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(height: 8),
                        Text(
                          '정면 사진을 업로드하세요',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))
                      ]
                    )
                  )
                )
              ],
              const SizedBox(height: 16),
              Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('카메라'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12)))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text('갤러리'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12))))
                  ]
                )
              ]
            )
          )
        ),
        const SizedBox(height: 16),
        
        // Face Shape Selection
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '얼굴형',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: _faceShapes.entries.map((entry) {
                  final isSelected = _faceShape == entry.key;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _faceShape = entry.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: BorderRadius.circular(12),
                      blur: 10,
                      borderColor: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                      borderWidth: isSelected ? 2 : 0,
                      child: Center(
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? theme.colorScheme.primary : null),
                          textAlign: TextAlign.center))));
                }).toList())
            ]
          )
        ),
        const SizedBox(height: 16),
        
        // Facial Features Selection
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '얼굴 특징 분석',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              // Eyebrows
              _buildFeatureDropdown(
                '눈썹',
                _eyebrowType,
                _eyebrowTypes,
                (value) => setState(() => _eyebrowType = value),
                Icons.remove_rounded),
              const SizedBox(height: 16),
              
              // Eyes
              _buildFeatureDropdown(
                '눈',
                _eyeType,
                _eyeTypes,
                (value) => setState(() => _eyeType = value),
                Icons.visibility_rounded),
              const SizedBox(height: 16),
              
              // Nose
              _buildFeatureDropdown(
                '코',
                _noseType,
                _noseTypes,
                (value) => setState(() => _noseType = value),
                Icons.air_rounded),
              const SizedBox(height: 16),
              
              // Lips
              _buildFeatureDropdown(
                '입술',
                _lipType,
                _lipTypes,
                (value) => setState(() => _lipType = value),
                Icons.mood_rounded)
            ]
          )
        ),
        const SizedBox(height: 16),
        
        // Additional Features (Optional)
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '추가 특징 (선택사항)',
                style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              
              // Ears
              _buildOptionalFeatureDropdown(
                '귀',
                _earType,
                {
                  'big': '큰 귀',
                  'small': '작은 귀',
                  'thick': '두꺼운 귀',
                  'thin': '얇은 귀',
                  'protruding': '돌출된 귀'},
                (value) => setState(() => _earType = value)),
              const SizedBox(height: 16),
              
              // Forehead
              _buildOptionalFeatureDropdown(
                '이마',
                _foreheadType,
                {
                  'wide': '넓은 이마',
                  'narrow': '좁은 이마',
                  'high': '높은 이마',
                  'low': '낮은 이마',
                  'rounded': '둥근 이마'},
                (value) => setState(() => _foreheadType = value)),
              const SizedBox(height: 16),
              
              // Chin
              _buildOptionalFeatureDropdown(
                '턱',
                _chinType,
                {
                  'pointed': '뾰족한 턱',
                  'rounded': '둥근 턱',
                  'square': '각진 턱',
                  'receding': '들어간 턱',
                  'protruding': '나온 턱'},
                (value) => setState(() => _chinType = value))
            ]
          )
        )
      ]
    );
  }

  Widget _buildFeatureDropdown(
    String label,
    String? value,
    Map<String, String> options,
    Function(String?) onChanged,
    IconData icon) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(label,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: '$label 형태를 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          items: options.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value));
          }).toList(),
          onChanged: onChanged)
      ]
    );
  }

  Widget _buildOptionalFeatureDropdown(
    String label,
    String? value,
    Map<String, String> options,
    Function(String?) onChanged) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
              style: theme.textTheme.bodyLarge),
            const SizedBox(width: 8),
            Text(
              '(선택)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))]),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: '선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('선택 안함')),
            ...options.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value));
            }).toList()],
          onChanged: onChanged)
      ]
    );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildFaceReadingAnalysis(),
        _buildPersonalityProfile(),
        _buildFortuneByFeature(),
        _buildLifeAdvice()
      ]
    );
  }

  Widget _buildFaceReadingAnalysis() {
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
                  Icons.face_retouching_natural_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '관상 종합 분석',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.1)]),
                borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전체적인 인상',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '당신의 얼굴은 강한 의지와 따뜻한 성품을 동시에 나타냅니다. 특히 눈매와 입술의 조화가 신뢰감을 주며, 이마의 형태는 지적 능력과 창의성을 암시합니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8)))
                ]
              )
            ),
            const SizedBox(height: 16),
            _buildAnalysisScore('복운', 85, '재물과 성공운이 강합니다'),
            const SizedBox(height: 12),
            _buildAnalysisScore('인연운', 75, '좋은 사람들과의 만남이 예상됩니다'),
            const SizedBox(height: 12),
            _buildAnalysisScore('건강운', 80, '타고난 건강 체질입니다'),
            const SizedBox(height: 12),
            _buildAnalysisScore('직업운', 90, '리더십과 창의성이 뛰어납니다')
          ]
        )
      )
    );
  }

  Widget _buildAnalysisScore(String label, int score, String description) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
              child: Text(
                '${score}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color))
      ]
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPersonalityProfile() {
    final theme = Theme.of(context);
    
    final traits = [
      {'name': '리더십', 'icon': Icons.star_rounded, 'color': Colors.blue},
      {'name': '창의성', 'icon': Icons.palette_rounded, 'color': Colors.blue},
      {'name': '공감능력', 'icon': Icons.favorite_rounded, 'color': Colors.blue},
      {'name': '분석력', 'icon': Icons.analytics_rounded, 'color': Colors.blue},
      {'name': '인내심', 'icon': Icons.timer_rounded, 'color': Colors.blue}
    ];
    
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
                  Icons.psychology_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '성격 프로필',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: traits.map((trait) {
                return GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  blur: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        trait['icon'] as IconData,
                        size: 28,
                        color: trait['color'] as Color),

                      const SizedBox(height: 8),
                      Text(
                        trait['name'] as String,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center)
                    ]
                  )
                );
              }).toList())
          ]
        )
      )
    );
  }

  Widget _buildFortuneByFeature() {
    final theme = Theme.of(context);
    
    final features = [
      {
        'feature': '눈',
        'interpretation': '맑고 깊은 눈은 순수한 마음과 직관력을 나타냅니다.',
        'fortune': '인간관계에서 좋은 운이 따를 것입니다.', 'icon': Icons.feedback},
      {
        'feature': '코',
        'interpretation': '균형 잡힌 코는 재물운과 건강운을 상징합니다.',
        'fortune': '경제적 안정과 성공이 예상됩니다.', 'icon': Icons.feedback},
      {
        'feature': '입',
        'interpretation': '적당한 크기의 입술은 소통 능력과 표현력을 의미합니다.',
        'fortune': '말과 글로 인한 행운이 있을 것입니다.', 'icon': Icons.feedback},
      {
        'feature': '이마',
        'interpretation': '넓은 이마는 지혜와 학업 성취를 암시합니다.',
        'fortune': '새로운 지식과 기회가 찾아올 것입니다.',
        'icon': Icons.lightbulb_rounded}
    ];
    
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
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '부위별 운세',
                  style: theme.textTheme.headlineSmall)),
            const SizedBox(height: 16),
            ...features.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          item['feature'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 8),
                    Text(
                      item['interpretation'] as String,
                      style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      '→ ${item['fortune']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary))
                  ]
                )
              )
            )).toList()
          ]
        )
      );
  }

  Widget _buildLifeAdvice() {
    final theme = Theme.of(context);
    
    final advices = [
      {
        'category': '재물',
        'advice': '40대 중반에 큰 재물운이 있으니 그때를 위해 준비하세요.',
        'color': Colors.orange},
      {
        'category': '건강',
        'advice': '스트레스 관리에 신경 쓰고, 규칙적인 운동을 하세요.',
        'color': Colors.orange},
      {
        'category': '인연',
        'advice': '진실한 마음으로 대하면 좋은 인연을 만날 수 있습니다.',
        'color': Colors.orange},
      {
        'category': '직업',
        'advice': '창의적인 분야나 리더십을 발휘할 수 있는 직종이 적합합니다.',
        'color': Colors.blue}
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
                  Icons.tips_and_updates_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '인생 조언',
                  style: theme.textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            ...advices.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    color: item['color'] as Color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['category'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item['color'] as Color)),
                        const SizedBox(height: 4),
                        Text(
                          item['advice'] as String,
                          style: theme.textTheme.bodyMedium)
                      ]
                    )
                  )
                ]
              )
            )).toList()
          ]
        )
      )
    );
  }
}