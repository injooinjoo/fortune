import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/components/toss_button.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class PalmistryFortunePage extends ConsumerStatefulWidget {
  const PalmistryFortunePage({super.key});

  @override
  ConsumerState<PalmistryFortunePage> createState() => _PalmistryFortunePageState();
}

class _PalmistryFortunePageState extends ConsumerState<PalmistryFortunePage> {
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
    'fire': '불형 손 (짧은 손가락)'
  };

  final Map<String, String> _lineCharacteristics = {
    'deep': '깊고 선명함',
    'shallow': '얕고 희미함',
    'broken': '끊어진 부분 있음',
    'forked': '갈라진 부분 있음',
    'curved': '곡선형',
    'straight': '직선형'
  };

  @override
  Widget build(BuildContext context) {
    return BaseFortunePageV2(
      title: '손금 운세',
      fortuneType: 'palmistry',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)]
      ),
      inputBuilder: (context, onSubmit) => _buildInputSection(onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result)
    );
  }

  Widget _buildInputSection(Function(Map<String, dynamic>) onSubmit) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '손금 운세',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI가 당신의 손금을 분석하여 운명과 미래를 예측해드립니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Camera Capture Section
          _buildCameraCaptureSection(),
          
          const SizedBox(height: 24),
          // Dominant Hand Selection
          _buildDominantHandSection(),
          
          const SizedBox(height: 24),
          // Palm Shape Selection
          _buildPalmShapeSection(),
          
          const SizedBox(height: 24),
          // Main Lines Analysis
          _buildMainLinesSection(),
          
          const SizedBox(height: 24),
          // Additional Lines
          _buildAdditionalLinesSection(),
          
          const SizedBox(height: 24),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: TossButton(
              text: '손금 운세 확인하기',
              onPressed: _canSubmit() 
                ? () => onSubmit(_getSubmitData())
                : null,
              style: TossButtonStyle.primary,
              size: TossButtonSize.large,
              icon: Icon(Icons.pan_tool),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCaptureSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                '손 사진 촬영 (선택사항)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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
                    fit: BoxFit.cover,
                  ),
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
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          Row(
            children: [
              Expanded(
                child: TossButton(
                  text: '사진 촬영',
                  onPressed: _takePicture,
                  style: TossButtonStyle.primary,
                  size: TossButtonSize.medium,
                  icon: Icon(Icons.camera_alt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TossButton(
                  text: '갤러리',
                  onPressed: _pickFromGallery,
                  style: TossButtonStyle.primary,
                  size: TossButtonSize.medium,
                  icon: Icon(Icons.photo_library),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '밝은 곳에서 손바닥을 평평하게 펴고 촬영해주세요',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDominantHandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주로 사용하는 손',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHandOption('left', '왼손', Icons.pan_tool_alt),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHandOption('right', '오른손', Icons.pan_tool),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHandOption(String value, String label, IconData icon) {
    final isSelected = _dominantHand == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _dominantHand = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.purple : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.purple : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPalmShapeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '손 모양',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
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
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.purple : Colors.grey[700],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMainLinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주요 손금 분석',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildLineAnalysis(
          '생명선',
          _lifeLine,
          (value) => setState(() => _lifeLine = value),
          Icons.favorite,
          Colors.red,
        ),
        const SizedBox(height: 16),
        _buildLineAnalysis(
          '감정선',
          _heartLine,
          (value) => setState(() => _heartLine = value),
          Icons.volunteer_activism,
          Colors.pink,
        ),
        const SizedBox(height: 16),
        _buildLineAnalysis(
          '두뇌선',
          _headLine,
          (value) => setState(() => _headLine = value),
          Icons.psychology,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildLineAnalysis(
          '운명선',
          _fateLine,
          (value) => setState(() => _fateLine = value),
          Icons.stars,
          Colors.purple,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildLineAnalysis(
    String lineName,
    String? currentValue,
    Function(String?) onChanged,
    IconData icon,
    Color color, {
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              lineName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              const Text(
                '(선택사항)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            hintText: isOptional ? '없으면 선택하지 마세요' : '선의 특징을 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            if (isOptional)
              const DropdownMenuItem(
                value: null,
                child: Text('없음'),
              ),
            ..._lineCharacteristics.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAdditionalLinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기타 손금',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          '결혼선이 있나요?',
          _hasMarriageLine,
          (value) => setState(() => _hasMarriageLine = value),
          Icons.favorite_border,
        ),
        const SizedBox(height: 8),
        _buildSwitchTile(
          '자녀선이 있나요?',
          _hasChildrenLine,
          (value) => setState(() => _hasChildrenLine = value),
          Icons.child_care,
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.purple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  bool _canSubmit() {
    return _dominantHand != null && 
           _lifeLine != null && 
           _heartLine != null && 
           _headLine != null && 
           _palmShape != null;
  }

  Map<String, dynamic> _getSubmitData() {
    return {
      'dominant_hand': _dominantHand,
      'life_line': _lifeLine,
      'heart_line': _heartLine,
      'head_line': _headLine,
      'fate_line': _fateLine,
      'has_marriage_line': _hasMarriageLine,
      'has_children_line': _hasChildrenLine,
      'palm_shape': _palmShape,
      'has_image': _palmImage != null,
    };
  }

  Widget _buildResult(BuildContext context, FortuneResult result) {
    return Column(
      children: [
        // Main Analysis Result
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple[100]!,
                Colors.blue[100]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.pan_tool,
                size: 64,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              const Text(
                '손금 분석 완료',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (result.mainFortune != null)
                Text(
                  result.mainFortune!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Overall Score
        if (result.overallScore != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                const Text(
                  '종합 손금 점수',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: result.overallScore! / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${result.overallScore}점',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        Text(
                          '100점 만점',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Line Analysis
        if (result.sections != null && result.sections!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '손금별 상세 분석',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...result.sections!.entries.map((entry) => _buildLineDetail(
                  _translateLineKey(entry.key),
                  entry.value,
                  _getLineIcon(entry.key),
                  _getLineColor(entry.key),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Recommendations
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green[50]!,
                  Colors.blue[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '운세 개선 조언',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...result.recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLineDetail(String lineName, String analysis, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lineName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  analysis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _translateLineKey(String key) {
    const translations = {
      'life_line': '생명선',
      'heart_line': '감정선',
      'head_line': '두뇌선',
      'fate_line': '운명선',
      'marriage_line': '결혼선',
      'children_line': '자녀선',
    };
    return translations[key] ?? key;
  }

  IconData _getLineIcon(String key) {
    const icons = {
      'life_line': Icons.favorite,
      'heart_line': Icons.volunteer_activism,
      'head_line': Icons.psychology,
      'fate_line': Icons.stars,
      'marriage_line': Icons.favorite_border,
      'children_line': Icons.child_care,
    };
    return icons[key] ?? Icons.timeline;
  }

  Color _getLineColor(String key) {
    const colors = {
      'life_line': Colors.red,
      'heart_line': Colors.pink,
      'head_line': Colors.blue,
      'fate_line': Colors.purple,
      'marriage_line': Colors.orange,
      'children_line': Colors.green,
    };
    return colors[key] ?? Colors.grey;
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _palmImage = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사진 촬영에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _palmImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}