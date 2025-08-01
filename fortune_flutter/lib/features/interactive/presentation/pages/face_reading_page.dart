import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../shared/components/token_insufficient_modal.dart';

class FaceReadingPage extends ConsumerStatefulWidget {
  const FaceReadingPage({super.key});

  @override
  ConsumerState<FaceReadingPage> createState() => _FaceReadingPageState();
}

class _FaceReadingPageState extends ConsumerState<FaceReadingPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _analysisResult;
  
  // AI 분석에 필요한 토큰 수
  static const int _requiredTokens = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'AI 관상'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInstructions(),
                    const SizedBox(height: 24),
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    if (_analysisResult != null) ...[
                      const SizedBox(height: 32),
                      _buildResultSection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.face,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'AI가 당신의 얼굴을 분석합니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '정면 사진을 업로드하면 AI가 관상을 분석해드립니다.\n'
            '개인정보는 안전하게 보호되며 분석 후 즉시 삭제됩니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.toll,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_requiredTokens 토큰 필요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _selectedImage == null ? _showImagePicker : null,
      child: GlassContainer(
        height: 300,
        child: _selectedImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (!_isAnalyzing)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _removeImage,
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '탭하여 사진 선택',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 100.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_selectedImage == null) ...[
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt),
                      const SizedBox(width: 8),
                      const Text('카메라로 촬영'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library),
                      const SizedBox(width: 8),
                      const Text('갤러리에서 선택'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          GlassButton(
            onPressed: _isAnalyzing ? null : _analyzeImage,
            width: double.infinity,
            child: _isAnalyzing 
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    const Text('분석 중...'),
                  ],
                )
              : const Text('AI 관상 분석 시작'),
          ),
          const SizedBox(height: 12),
          GlassButton(
            onPressed: _isAnalyzing ? null : _showImagePicker,
            width: double.infinity,
            child: const Text('다른 사진 선택'),
          ),
        ],
      ],
    ).animate()
      .fadeIn(duration: 600.ms, delay: 200.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildResultSection() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI 관상 분석 결과',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analysisResult!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  onPressed: _resetAnalysis,
                  child: const Text('다시 분석하기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  onPressed: _shareResult,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share),
                      const SizedBox(width: 8),
                      const Text('결과 공유'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: 0.1, end: 0);
  }

  void _showImagePicker() {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                title: const Text('취소'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // 권한 확인
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          _showPermissionDeniedDialog('카메라');
          return;
        }
      } else {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          _showPermissionDeniedDialog('사진');
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
        HapticUtils.mediumImpact();
      }
    } catch (e) {
      Logger.error('이미지 선택 실패', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 선택할 수 없습니다')),
        );
      }
    }
  }

  void _removeImage() {
    HapticUtils.lightImpact();
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
    });
  }

  Future<void> _analyzeImage() async {
    // 토큰 확인
    final tokenBalance = ref.read(tokenBalanceProvider);
    if (tokenBalance == null || (tokenBalance.remainingTokens < _requiredTokens && !tokenBalance.hasUnlimitedAccess)) {
      _showInsufficientTokensModal();
      return;
    }

    setState(() => _isAnalyzing = true);
    HapticUtils.mediumImpact();

    try {
      // TODO: 실제 API 호출로 대체
      await Future.delayed(const Duration(seconds: 3));
      
      // 토큰 차감
      await ref.read(tokenProvider.notifier).consumeTokens(
        fortuneType: 'face_reading',
        amount: _requiredTokens,
      );
      
      // 토큰 잔액 새로고침
      ref.refresh(tokenBalanceProvider);
      
      setState(() {
        _analysisResult = '''
당신의 관상 분석 결과입니다.

【이마】
넓고 시원한 이마는 지적 능력과 창의성을 나타냅니다. 당신은 논리적 사고와 직관적 통찰력을 겸비한 사람으로 보입니다.

【눈썹】
짙고 선명한 눈썹은 강한 의지력과 결단력을 상징합니다. 목표를 향해 꾸준히 노력하는 성향이 있습니다.

【눈】
맑고 깊은 눈은 예리한 관찰력과 통찰력을 보여줍니다. 사람의 마음을 잘 읽고 이해하는 능력이 있습니다.

【코】
균형 잡힌 코는 재물운과 건강운이 좋음을 나타냅니다. 꾸준한 노력으로 안정적인 성공을 이룰 수 있습니다.

【입】
따뜻한 미소가 인상적입니다. 대인관계에서 신뢰를 얻기 쉽고, 말재주가 있어 설득력이 뛰어납니다.

【전체적인 인상】
전반적으로 균형 잡힌 관상으로, 복이 많은 얼굴입니다. 특히 중년 이후 큰 성공과 행복이 기다리고 있을 것으로 보입니다.
''';
        _isAnalyzing = false;
      });
      
      HapticUtils.success();
    } catch (e) {
      Logger.error('관상 분석 실패', e);
      setState(() => _isAnalyzing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  void _resetAnalysis() {
    HapticUtils.lightImpact();
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
    });
  }

  void _shareResult() {
    HapticUtils.lightImpact();
    // TODO: 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 준비 중입니다')),
    );
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission 권한 필요'),
        content: Text('$permission 기능을 사용하려면 권한이 필요합니다.\n설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientTokensModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TokenInsufficientModal(
        requiredTokens: _requiredTokens,
        fortuneType: 'face-reading',
      ),
    );
  }
}