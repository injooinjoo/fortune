import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/toss_design_system.dart';
import 'toss_button.dart';

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
  String? _instagramUrl;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Description
        Text(
          widget.title,
          style: TossDesignSystem.heading3.copyWith(
            color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
          ),
        ).animate().fadeIn(duration: 500.ms),
        
        const SizedBox(height: 8),
        
        Text(
          widget.description,
          style: TossDesignSystem.body2.copyWith(
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 50.ms),
        
        const SizedBox(height: 24),

        // Image Display or Upload Options
        if (_selectedImage != null) ...[
          _buildSelectedImage(isDark),
        ] else if (_showInstagramInput) ...[
          _buildInstagramInput(isDark),
        ] else ...[
          _buildUploadOptions(isDark),
        ],

        // Guidelines
        if (widget.guidelines.isNotEmpty && _selectedImage == null) ...[
          const SizedBox(height: 24),
          _buildGuidelines(isDark),
        ],

        // Privacy Notice
        if (_selectedImage != null || _showInstagramInput) ...[
          const SizedBox(height: 16),
          _buildPrivacyNotice(isDark),
        ],
      ],
    );
  }

  Widget _buildSelectedImage(bool isDark) {
    return Container(
      height: widget.imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                _buildImageActionButton(
                  icon: Icons.edit,
                  onTap: _changeImage,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildImageActionButton(
                  icon: Icons.close,
                  onTap: _removeImage,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          // Type indicator
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedType == ImageUploadType.camera 
                        ? Icons.camera_alt 
                        : Icons.photo_library,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedType == ImageUploadType.camera ? '촬영' : '갤러리',
                    style: TossDesignSystem.body3.copyWith(
                      color: Colors.white,
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

  Widget _buildInstagramInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TossDesignSystem.purple.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.pink, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '인스타그램 프로필 분석',
                    style: TossDesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _instagramController,
                decoration: InputDecoration(
                  hintText: 'instagram.com/username',
                  hintStyle: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                  ),
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _instagramController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _instagramController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: TossDesignSystem.purple,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              Text(
                '공개 프로필의 사진을 분석합니다',
                style: TossDesignSystem.body3.copyWith(
                  color: TossDesignSystem.purple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TossButton.secondary(
                text: '다른 방법 선택',
                onPressed: () {
                  setState(() {
                    _showInstagramInput = false;
                    _instagramController.clear();
                  });
                },
                size: TossButtonSize.medium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TossButton.primary(
                text: '확인',
                onPressed: _isValidInstagramUrl(_instagramController.text)
                    ? () {
                        widget.onImageSelected(ImageUploadResult(
                          type: ImageUploadType.instagram,
                          instagramUrl: _instagramController.text,
                        ));
                      }
                    : null,
                isEnabled: _isValidInstagramUrl(_instagramController.text),
                size: TossButtonSize.medium,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildUploadOptions(bool isDark) {
    final options = [
      ImageUploadType.camera,
      ImageUploadType.gallery,
      if (widget.showInstagramOption) ImageUploadType.instagram,
    ];

    return Column(
      children: [
        // Visual preview area
        Container(
          height: widget.imageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 64,
                color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                '분석할 사진을 선택해주세요',
                style: TossDesignSystem.body1.copyWith(
                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
        
        const SizedBox(height: 24),
        
        // Option buttons
        ...options.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildUploadOptionButton(option, isDark),
        )).toList(),
      ],
    );
  }

  Widget _buildUploadOptionButton(ImageUploadType type, bool isDark) {
    return InkWell(
      onTap: () => _handleOptionSelect(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: type == ImageUploadType.instagram
                    ? const LinearGradient(
                        colors: [Colors.purple, Colors.pink, Colors.orange],
                      ).colors.first.withOpacity(0.1)
                    : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type.icon,
                color: type == ImageUploadType.instagram
                    ? Colors.purple
                    : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: TossDesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: TossDesignSystem.body3.copyWith(
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms, delay: (type.index * 100).ms)
      .slideX(begin: 0.05, end: 0);
  }

  Widget _buildGuidelines(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TossDesignSystem.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossDesignSystem.infoBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: TossDesignSystem.infoBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '좋은 결과를 위한 가이드',
                style: TossDesignSystem.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TossDesignSystem.infoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.guidelines.map((guideline) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TossDesignSystem.body3.copyWith(
                    color: TossDesignSystem.infoBlue,
                  ),
                ),
                Expanded(
                  child: Text(
                    guideline,
                    style: TossDesignSystem.body3.copyWith(
                      color: TossDesignSystem.infoBlue,
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

  Widget _buildPrivacyNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 16,
            color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '개인정보는 안전하게 보호되며 분석 후 즉시 삭제됩니다',
              style: TossDesignSystem.body3.copyWith(
                color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
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
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: Colors.white,
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
            backgroundColor: TossDesignSystem.errorRed,
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

  bool _isValidInstagramUrl(String url) {
    if (url.isEmpty) return false;
    final regex = RegExp(
      r'^(https?://)?(www\.)?(instagram\.com|instagr\.am)/[A-Za-z0-9_\.]+/?$',
      caseSensitive: false,
    );
    return regex.hasMatch(url);
  }
}