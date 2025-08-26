import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toast.dart';
import 'physiognomy_loading_page.dart';

class PhysiognomyCameraInputPage extends StatefulWidget {
  const PhysiognomyCameraInputPage({super.key});

  @override
  State<PhysiognomyCameraInputPage> createState() => _PhysiognomyCameraInputPageState();
}

class _PhysiognomyCameraInputPageState extends State<PhysiognomyCameraInputPage>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 버튼 애니메이션 반복
    _buttonAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.lightImpact();
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.front,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // 이미지를 선택하면 바로 분석 페이지로 이동
        _navigateToAnalysis();
      }
    } catch (e) {
      Toast.error(context, '이미지를 선택하는 중 오류가 발생했습니다.');
    }
  }

  void _navigateToAnalysis() {
    if (_selectedImage != null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PhysiognomyLoadingPage(imageFile: _selectedImage!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: TossTheme.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: TossTheme.textBlack,
              size: 20,
            ),
          ),
        ),
        title: Text(
          '관상 분석',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 제목과 설명
              Text(
                'AI가 당신의 얼굴을\n분석해드릴게요',
                style: TossTheme.heading1.copyWith(
                  color: TossTheme.textBlack,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                '정면을 바라본 셀카를 찍어주세요\n더 정확한 분석이 가능합니다',
                style: TossTheme.subtitle1.copyWith(
                  color: TossTheme.textGray600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // 메인 카메라 프리뷰 영역
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        offset: const Offset(0, 2),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: _selectedImage != null 
                      ? _buildSelectedImagePreview()
                      : _buildCameraPlaceholder(),
                ),
              ),
              const SizedBox(height: 24),
              
              // 액션 버튼들
              Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _selectedImage == null ? _buttonAnimation.value : 1.0,
                        child: _buildCameraButton(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGalleryButton(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_selectedImage != null)
                SizedBox(
                  width: double.infinity,
                  child: _buildAnalyzeButton(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '완벽해요! 이제 분석을 시작할 수 있어요',
          style: TossTheme.body2.copyWith(
            color: TossTheme.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCameraPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: TossTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: TossTheme.primaryBlue.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.face_rounded,
            size: 60,
            color: TossTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '사진을 촬영하거나\n갤러리에서 선택해주세요',
          style: TossTheme.body2.copyWith(
            color: TossTheme.textGray600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCameraButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: TossTheme.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossTheme.primaryBlue.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _pickImage(ImageSource.camera),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '카메라',
                style: TossTheme.body2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: TossTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TossTheme.borderGray300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _pickImage(ImageSource.gallery),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_rounded,
                color: TossTheme.textBlack,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '갤러리',
                style: TossTheme.body2.copyWith(
                  color: TossTheme.textBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: TossTheme.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TossTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _navigateToAnalysis,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI 분석 시작하기',
                style: TossTheme.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}