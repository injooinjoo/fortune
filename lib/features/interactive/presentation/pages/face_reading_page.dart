import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../shared/components/token_insufficient_modal.dart';
import '../../../fortune/presentation/widgets/face_reading/celebrity_match_carousel.dart'; // ✅ 닮은꼴 캐러셀

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

  // ✅ 프로필 사진 관련 상태
  bool _isLoadingProfileImage = false;

  // ✅ 닮은꼴 유명인 데이터
  List<Map<String, dynamic>>? _similarCelebrities;

  // 분석에 필요한 토큰 수
  static const int _requiredTokens = 5;

  @override
  void initState() {
    super.initState();
    // ✅ 로그인 사용자 프로필 사진 자동 로드
    _loadDefaultProfileImage();
  }

  /// 로그인 사용자 프로필 사진 자동 로드
  Future<void> _loadDefaultProfileImage() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final userProfileAsync = ref.read(userProfileProvider);
    final profileImageUrl = userProfileAsync.valueOrNull?.profileImageUrl;

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      await _useProfileImage(profileImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '관상'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInstructions(),
                    const SizedBox(height: DSSpacing.lg),
                    _buildImageSection(),
                    const SizedBox(height: DSSpacing.lg),
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
          const SizedBox(height: DSSpacing.md),
          Text(
            '당신의 얼굴을 분석합니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            '정면 사진을 업로드하면 관상을 분석해드립니다.\n'
            '개인정보는 안전하게 보호되며 분석 후 즉시 삭제됩니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.md),
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
                const SizedBox(width: DSSpacing.xs),
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
                          color: Colors.black.withValues(alpha: 0.54),
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
                const SizedBox(height: DSSpacing.md),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text('카메라로 촬영'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library),
                      SizedBox(width: 8),
                      Text('갤러리에서 선택'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        if (_selectedImage != null) ...[
          GlassButton(
            onPressed: _isAnalyzing ? null : _analyzeImage,
            width: double.infinity,
            child: _isAnalyzing 
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('분석 중...'),
                  ],
                )
              : const Text('관상 분석 시작'),
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
              const SizedBox(width: DSSpacing.sm),
              Text(
                '관상 분석 결과',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // ✅ 닮은꼴 유명인 캐러셀
          if (_similarCelebrities != null && _similarCelebrities!.isNotEmpty) ...[
            CelebrityMatchCarousel(
              celebrities: _similarCelebrities!,
            ),
            const SizedBox(height: DSSpacing.lg),
          ],

          Text(
            _analysisResult!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('결과 공유'),
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

    // ✅ 프로필 사진 정보 가져오기
    final userProfileAsync = ref.read(userProfileProvider);
    final profileImageUrl = userProfileAsync.valueOrNull?.profileImageUrl;
    final hasProfileImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: DSColors.overlay,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ 프로필 사진 옵션 (있을 때만 표시)
              if (hasProfileImage)
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  title: const Text('내 프로필 사진 사용'),
                  subtitle: Text(
                    '빠르게 분석을 시작해보세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  onTap: _isLoadingProfileImage
                      ? null
                      : () {
                          Navigator.pop(context);
                          _useProfileImage(profileImageUrl);
                        },
                ),
              if (hasProfileImage)
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
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
                leading: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
        imageQuality: 85);

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
          const SnackBar(content: Text('이미지를 선택할 수 없습니다')));
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

  /// ✅ 프로필 사진 다운로드 후 사용
  Future<void> _useProfileImage(String imageUrl) async {
    setState(() {
      _isLoadingProfileImage = true;
    });

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
            '${tempDir.path}/profile_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _selectedImage = file;
            _analysisResult = null;
            _isLoadingProfileImage = false;
          });
          HapticUtils.mediumImpact();
        }
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      Logger.error('프로필 이미지 다운로드 실패', e);
      if (mounted) {
        setState(() {
          _isLoadingProfileImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 사진을 불러올 수 없습니다')),
        );
      }
    }
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
        amount: _requiredTokens);

      // 토큰 잔액 새로고침
      ref.invalidate(tokenBalanceProvider);
      
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

        // ✅ 닮은꼴 유명인 mock 데이터
        _similarCelebrities = [
          {
            'celebrity_name': '아이유',
            'celebrity_type': 'solo_singer',
            'similarity_score': 87,
            'matched_features': ['눈매', '웃는 모습', '이목구비 비율'],
            'reason': '맑고 또렷한 눈매가 매우 유사합니다',
          },
          {
            'celebrity_name': '수지',
            'celebrity_type': 'actress',
            'similarity_score': 82,
            'matched_features': ['얼굴형', '코 라인', '입술'],
            'reason': '부드러운 얼굴 윤곽과 코 라인이 닮았습니다',
          },
          {
            'celebrity_name': '차은우',
            'celebrity_type': 'idol_actor',
            'similarity_score': 78,
            'matched_features': ['눈썹', '전체 인상'],
            'reason': '선명한 눈썹과 시원한 인상이 유사합니다',
          },
        ];

        _isAnalyzing = false;
      });
      
      HapticUtils.success();
    } catch (e) {
      Logger.error('관상 분석 실패', e);
      setState(() => _isAnalyzing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석에 실패했습니다. 다시 시도해주세요.')));
      }
    }
  }

  void _resetAnalysis() {
    HapticUtils.lightImpact();
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
      _similarCelebrities = null; // ✅ 닮은꼴 데이터도 초기화
    });
  }

  void _shareResult() {
    HapticUtils.lightImpact();
    // TODO: 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 준비 중입니다')));
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
      barrierColor: DSColors.overlay,
      builder: (context) => const TokenInsufficientModal(
        requiredTokens: _requiredTokens,
        fortuneType: 'face-reading',
      ),
    );
  }
}