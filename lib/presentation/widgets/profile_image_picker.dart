import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/toss_design_system.dart';
import '../../services/supabase_storage_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? currentImageUrl;
  final Function(XFile) onImageSelected;
  final bool isLoading;
  
  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.isLoading = false,
  });
  
  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  XFile? _selectedImage;
  
  Future<void> _showImageSourceDialog() async {
    if (!kIsWeb && Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('프로필 사진 선택'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: const Text('카메라로 촬영'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: const Text('갤러리에서 선택'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    XFile? image;
    
    if (source == ImageSource.camera) {
      image = await SupabaseStorageService.pickImageFromCamera();
    } else {
      image = await SupabaseStorageService.pickImageFromGallery();
    }
    
    if (image != null && SupabaseStorageService.validateImageFile(image)) {
      setState(() {
        _selectedImage = image;
      });
      widget.onImageSelected(image);
    } else if (image != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지 파일이 유효하지 않습니다. JPG, PNG, WEBP 형식만 가능합니다.'),
            backgroundColor: TossDesignSystem.errorRed,
          ),
        );
      }
    }
  }
  
  Widget _buildProfileImage() {
    final theme = Theme.of(context);
    
    // If there's a selected image, show it
    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          File(_selectedImage!.path),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }
    
    // If there's a current image URL, show it
    if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.currentImageUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    TossDesignSystem.tossBlue,
                    TossDesignSystem.gray600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: TossDesignSystem.grayDark900,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    }
    
    // Default profile icon
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.tossBlue,
            TossDesignSystem.gray600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: TossDesignSystem.grayDark900,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Stack(
        children: [
          _buildProfileImage(),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TossDesignSystem.grayDark900,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: TossDesignSystem.grayDark900,
                      ),
                onPressed: widget.isLoading ? null : _showImageSourceDialog,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}