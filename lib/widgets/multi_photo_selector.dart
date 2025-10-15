import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/theme/toss_design_system.dart';
import '../core/theme/app_theme.dart';

/// 여러 장의 사진을 선택할 수 있는 위젯
class MultiPhotoSelector extends StatefulWidget {
  final int maxPhotos;
  final String title;
  final Function(List<XFile>) onPhotosSelected;
  final List<XFile>? initialPhotos;
  final bool isRequired;

  const MultiPhotoSelector({
    Key? key,
    this.maxPhotos = 9,
    required this.title,
    required this.onPhotosSelected,
    this.initialPhotos,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<MultiPhotoSelector> createState() => _MultiPhotoSelectorState();
}

class _MultiPhotoSelectorState extends State<MultiPhotoSelector> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedPhotos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhotos != null) {
      _selectedPhotos = List.from(widget.initialPhotos!);
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (!kIsWeb && Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text('사진 선택'),
          message: Text('최대 ${widget.maxPhotos}장까지 선택 가능합니다'),
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
            if (_selectedPhotos.length < widget.maxPhotos)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickMultipleImages();
                },
                child: const Text('여러 장 선택'),
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
      // Android or Web
      showModalBottomSheet(
        context: context,
        backgroundColor: TossDesignSystem.grayDark100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: TossDesignSystem.gray600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: TossDesignSystem.tossBlue),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: TossDesignSystem.tossBlue),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedPhotos.length < widget.maxPhotos)
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: TossDesignSystem.tossBlue),
                  title: const Text('여러 장 선택'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMultipleImages();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedPhotos.length >= widget.maxPhotos) {
      _showMaxPhotosAlert();
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (photo != null) {
        setState(() {
          _selectedPhotos.add(photo);
        });
        widget.onPhotosSelected(_selectedPhotos);
      }
    } catch (e) {
      _showErrorSnackBar('사진을 선택할 수 없습니다');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultipleImages() async {
    setState(() => _isLoading = true);
    
    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (photos.isNotEmpty) {
        final remainingSlots = widget.maxPhotos - _selectedPhotos.length;
        final photosToAdd = photos.take(remainingSlots).toList();
        
        setState(() {
          _selectedPhotos.addAll(photosToAdd);
        });
        
        widget.onPhotosSelected(_selectedPhotos);
        
        if (photos.length > remainingSlots) {
          _showMaxPhotosAlert();
        }
      }
    } catch (e) {
      _showErrorSnackBar('사진을 선택할 수 없습니다');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
    widget.onPhotosSelected(_selectedPhotos);
  }

  void _showMaxPhotosAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TossDesignSystem.grayDark100,
        title: const Text('알림'),
        content: Text('최대 ${widget.maxPhotos}장까지만 선택할 수 있습니다'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: TossDesignSystem.tossBlue)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TossDesignSystem.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Icon(
              Icons.photo_camera,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: TextStyle(color: TossDesignSystem.errorRed),
              ),
            const Spacer(),
            Text(
              '${_selectedPhotos.length}/${widget.maxPhotos}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: TossDesignSystem.gray600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Photo Grid
        Container(
          height: 120,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPhotos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedPhotos.length) {
                      // Add Photo Button
                      if (_selectedPhotos.length >= widget.maxPhotos) {
                        return const SizedBox.shrink();
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: _showImageSourceDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              color: TossDesignSystem.grayDark100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: TossDesignSystem.gray300,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 32,
                                  color: TossDesignSystem.gray600,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '사진 추가',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: TossDesignSystem.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Photo Item
                    final photo = _selectedPhotos[index];
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? Image.network(
                                      photo.path,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: TossDesignSystem.grayDark100,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: TossDesignSystem.gray600,
                                          ),
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(photo.path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: TossDesignSystem.grayDark100,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: TossDesignSystem.gray600,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                          // Remove Button
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: TossDesignSystem.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: TossDesignSystem.white,
                                ),
                              ),
                            ),
                          ),
                          // Order Badge
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TossDesignSystem.tossBlue.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: TossDesignSystem.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        
        // Helper Text
        if (_selectedPhotos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '사진을 추가하면 AI가 분석하여 운세를 알려드립니다',
              style: theme.textTheme.bodySmall?.copyWith(
                color: TossDesignSystem.gray600,
              ),
            ),
          ),
      ],
    );
  }
}