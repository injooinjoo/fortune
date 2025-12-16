import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/design_system/design_system.dart';
import '../../core/widgets/unified_button.dart';
import '../../core/widgets/unified_button_enums.dart';

/// 이미지 업로드 옵션 타입
enum ImageUploadType {
  camera('카메라', Icons.camera_alt, '사진 촬영'),
  gallery('갤러리', Icons.photo_library, '사진 선택'),
  instagram('인스타그램', Icons.link, 'URL 입력');

  final String label;
  final IconData icon;
  final String description;

  const ImageUploadType(this.label, this.icon, this.description);
}

/// 이미지 업로드 결과
class ImageUploadResult {
  final ImageUploadType type;
  final File? imageFile;
  final String? instagramUrl;

  ImageUploadResult({
    required this.type,
    this.imageFile,
    this.instagramUrl,
  });
}

/// 통합 이미지 업로드 선택자
class ImageUploadSelector extends StatefulWidget {
  final String title;
  final String description;
  final Function(ImageUploadResult) onImageSelected;
  final bool showInstagramOption;
  final List<String> guidelines;
  final double imageHeight;

  const ImageUploadSelector({
    super.key,
    required this.title,
    required this.description,
    required this.onImageSelected,
    this.showInstagramOption = true,
    this.guidelines = const [],
    this.imageHeight = 300,
  });

  @override
  State<ImageUploadSelector> createState() => _ImageUploadSelectorState();
}

class _ImageUploadSelectorState extends State<ImageUploadSelector> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  ImageUploadType? _selectedType;
  final _instagramController = TextEditingController();
  bool _showInstagramInput = false;

  @override
  void dispose() {
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Description
        Text(
          widget.title,
          style: typography.headingSmall.copyWith(
            color: colors.textPrimary,
          ),
        ).animate().fadeIn(duration: 500.ms),

        const SizedBox(height: DSSpacing.sm),

        Text(
          widget.description,
          style: typography.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 50.ms),

        const SizedBox(height: DSSpacing.lg),

        // Image Display or Upload Options
        if (_selectedImage != null) ...[
          _buildSelectedImage(colors, typography),
        ] else if (_showInstagramInput) ...[
          _buildInstagramInput(colors, typography),
        ] else ...[
          _buildUploadOptions(colors, typography),
        ],

        // Guidelines
        if (widget.guidelines.isNotEmpty && _selectedImage == null) ...[
          const SizedBox(height: DSSpacing.lg),
          _buildGuidelines(colors, typography),
        ],

        // Privacy Notice
        if (_selectedImage != null || _showInstagramInput) ...[
          const SizedBox(height: DSSpacing.md),
          _buildPrivacyNotice(colors, typography),
        ],
      ],
    );
  }

  Widget _buildSelectedImage(DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      height: widget.imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DSRadius.lg - 1),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: DSSpacing.sm,
            right: DSSpacing.sm,
            child: Row(
              children: [
                _buildImageActionButton(
                  icon: Icons.edit,
                  onTap: _changeImage,
                  colors: colors,
                ),
                const SizedBox(width: DSSpacing.sm),
                _buildImageActionButton(
                  icon: Icons.close,
                  onTap: _removeImage,
                  colors: colors,
                ),
              ],
            ),
          ),
          // Type indicator
          Positioned(
            bottom: DSSpacing.sm,
            left: DSSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs),
              decoration: BoxDecoration(
                color: colors.textPrimary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(DSRadius.xl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedType == ImageUploadType.camera
                        ? Icons.camera_alt
                        : Icons.photo_library,
                    size: 16,
                    color: colors.surface,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    _selectedType == ImageUploadType.camera ? '촬영' : '갤러리',
                    style: typography.labelSmall.copyWith(
                      color: colors.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildInstagramInput(DSColorScheme colors, DSTypographyScheme typography) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(DSSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.accent, colors.accentSecondary, colors.accentTertiary],
                      ),
                      borderRadius: BorderRadius.circular(DSRadius.sm),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: colors.surface,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Text(
                    '인스타그램 프로필 분석',
                    style: typography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(DSRadius.md),
                        bottomLeft: Radius.circular(DSRadius.md),
                      ),
                      border: Border.all(
                        color: colors.border,
                      ),
                    ),
                    child: Text(
                      'instagram.com/',
                      style: typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _instagramController,
                      style: typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'username',
                        hintStyle: typography.bodyMedium.copyWith(
                          color: colors.textTertiary,
                        ),
                        suffixIcon: _instagramController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: colors.textTertiary),
                                onPressed: () {
                                  setState(() {
                                    _instagramController.clear();
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(DSRadius.md),
                            bottomRight: Radius.circular(DSRadius.md),
                          ),
                          borderSide: BorderSide(
                            color: colors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(DSRadius.md),
                            bottomRight: Radius.circular(DSRadius.md),
                          ),
                          borderSide: BorderSide(
                            color: colors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(DSRadius.md),
                            bottomRight: Radius.circular(DSRadius.md),
                          ),
                          borderSide: BorderSide(
                            color: colors.accent,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: DSSpacing.md, vertical: DSSpacing.sm + 2),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                '공개 프로필의 사진을 분석합니다',
                style: typography.labelSmall.copyWith(
                  color: colors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Row(
          children: [
            Expanded(
              child: UnifiedButton.secondary(
                text: '다른 방법 선택',
                onPressed: () {
                  setState(() {
                    _showInstagramInput = false;
                    _instagramController.clear();
                  });
                },
                size: UnifiedButtonSize.medium,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: UnifiedButton.primary(
                text: '확인',
                onPressed: _instagramController.text.trim().isNotEmpty
                    ? () {
                        final input = _instagramController.text.trim();

                        // URL 유효성 검증
                        String? errorMessage = _validateInstagramInput(input);

                        if (errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: colors.error,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        // Username 또는 URL을 표준 형식으로 변환
                        final fullUrl = _normalizeInstagramUrl(input);

                        widget.onImageSelected(ImageUploadResult(
                          type: ImageUploadType.instagram,
                          instagramUrl: fullUrl,
                        ));
                      }
                    : null,
                isEnabled: _instagramController.text.trim().isNotEmpty,
                size: UnifiedButtonSize.medium,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildUploadOptions(DSColorScheme colors, DSTypographyScheme typography) {
    final options = [
      ImageUploadType.camera,
      ImageUploadType.gallery,
      if (widget.showInstagramOption) ImageUploadType.instagram,
    ];

    return Column(
      children: [
        // Visual preview area - Make it clickable
        InkWell(
          onTap: () {
            // Show bottom sheet with options
            _showImageSelectionBottomSheet(context, colors, typography);
          },
          borderRadius: BorderRadius.circular(DSRadius.lg),
          child: Container(
            height: widget.imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(DSRadius.lg),
              border: Border.all(
                color: colors.border,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 64,
                  color: colors.textTertiary,
                ),
                const SizedBox(height: DSSpacing.md),
                Text(
                  '분석할 사진을 선택해주세요',
                  style: typography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: DSSpacing.sm),
                Text(
                  '탭하여 선택',
                  style: typography.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: DSSpacing.lg),

        // Option buttons
        ...options.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.sm),
          child: _buildUploadOptionButton(option, colors, typography),
        )),
      ],
    );
  }

  Widget _buildUploadOptionButton(ImageUploadType type, DSColorScheme colors, DSTypographyScheme typography) {
    return InkWell(
      onTap: () => _handleOptionSelect(type),
      borderRadius: BorderRadius.circular(DSRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(DSRadius.lg),
          border: Border.all(
            color: colors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: type == ImageUploadType.instagram
                    ? colors.accent.withValues(alpha: 0.1)
                    : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(DSRadius.md),
              ),
              child: Icon(
                type.icon,
                color: type == ImageUploadType.instagram
                    ? colors.accent
                    : colors.textSecondary,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: typography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    type.description,
                    style: typography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: (type.index * 100).ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildGuidelines(DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colors.accent,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                '좋은 결과를 위한 가이드',
                style: typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.sm),
          ...widget.guidelines.map((guideline) => Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: typography.labelSmall.copyWith(
                    color: colors.accent,
                  ),
                ),
                Expanded(
                  child: Text(
                    guideline,
                    style: typography.labelSmall.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Widget _buildPrivacyNotice(DSColorScheme colors, DSTypographyScheme typography) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 16,
            color: colors.textSecondary,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Text(
              '개인정보는 안전하게 보호되며 분석 후 즉시 삭제됩니다',
              style: typography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required DSColorScheme colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: colors.textPrimary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(DSRadius.xl),
        ),
        child: Icon(
          icon,
          color: colors.surface,
          size: 20,
        ),
      ),
    );
  }

  void _handleOptionSelect(ImageUploadType type) {
    if (type == ImageUploadType.instagram) {
      setState(() {
        _showInstagramInput = true;
      });
    } else {
      _pickImage(type == ImageUploadType.camera
          ? ImageSource.camera
          : ImageSource.gallery);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final colors = context.colors;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _selectedType = source == ImageSource.camera
              ? ImageUploadType.camera
              : ImageUploadType.gallery;
        });

        widget.onImageSelected(ImageUploadResult(
          type: _selectedType!,
          imageFile: _selectedImage,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  void _changeImage() {
    setState(() {
      _selectedImage = null;
      _selectedType = null;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedType = null;
    });
  }

  void _showImageSelectionBottomSheet(BuildContext context, DSColorScheme colors, DSTypographyScheme typography) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadius.xl)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: DSSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              Text(
                '사진 선택 방법',
                style: typography.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: colors.textSecondary,
                ),
                title: Text(
                  '카메라로 촬영',
                  style: typography.bodyLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: colors.textSecondary,
                ),
                title: Text(
                  '갤러리에서 선택',
                  style: typography.bodyLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (widget.showInstagramOption)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.accent, colors.accentSecondary, colors.accentTertiary],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: colors.surface,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    '인스타그램 URL 입력',
                    style: typography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _showInstagramInput = true;
                    });
                  },
                ),
              const SizedBox(height: DSSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  /// Instagram URL 또는 username 유효성 검증
  String? _validateInstagramInput(String input) {
    // 빈 값 체크
    if (input.isEmpty) {
      return '인스타그램 사용자명 또는 URL을 입력해주세요.';
    }

    // 게시물 URL 제외
    if (input.contains('/p/') || input.contains('/reel/') || input.contains('/tv/')) {
      return '프로필 URL을 입력해주세요. 게시물 URL은 사용할 수 없습니다.';
    }

    // Username 패턴 검증 (instagram.com이 포함된 경우)
    if (input.contains('instagram.com/')) {
      // URL 형식인 경우 프로필 URL 패턴 확인
      final urlPattern = RegExp(r'instagram\.com\/([a-zA-Z0-9._]+)\/?$');
      if (!urlPattern.hasMatch(input)) {
        return '올바른 인스타그램 프로필 URL을 입력해주세요.\n예: instagram.com/username';
      }
    } else {
      // Username만 입력된 경우 패턴 확인
      final usernamePattern = RegExp(r'^[a-zA-Z0-9._]+$');
      if (!usernamePattern.hasMatch(input.replaceAll('@', ''))) {
        return '올바른 인스타그램 사용자명을 입력해주세요.\n영문, 숫자, 마침표(.), 밑줄(_)만 사용 가능합니다.';
      }
    }

    return null; // 유효함
  }

  /// Instagram URL 정규화 (표준 형식으로 변환)
  String _normalizeInstagramUrl(String input) {
    // 이미 전체 URL인 경우
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }

    // instagram.com/username 형식인 경우
    if (input.contains('instagram.com/')) {
      return 'https://$input';
    }

    // Username만 입력된 경우 (@ 제거 후)
    final username = input.replaceAll('@', '');
    return 'https://instagram.com/$username';
  }
}
