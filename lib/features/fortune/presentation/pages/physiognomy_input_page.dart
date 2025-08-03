import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/utils/navigation_flow_helper.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/components/toast.dart';

// Provider for managing physiognomy data
final physiognomyDataProvider = StateProvider<PhysiognomyData>((ref) {
  return PhysiognomyData();
});

// Provider for input method selection
final physiognomyInputMethodProvider = StateProvider<InputMethod?>((ref) => null);

enum InputMethod {
  
  photo, manual
  
}

class PhysiognomyData {
  File? photo;
  
  // Basic features (required,
  String? faceShape;
  String? eyeType;
  String? noseType;
  String? lipType;
  
  // Optional features
  String? eyebrowType;
  String? foreheadType;
  String? chinType;
  String? earType;
  
  bool get isPhotoMethod => photo != null;
  
  bool get isManualDataComplete => 
    faceShape != null && 
    eyeType != null && 
    noseType != null && 
    lipType != null;
    
  bool get isReadyForAnalysis => isPhotoMethod || isManualDataComplete;
}

class PhysiognomyInputPage extends ConsumerStatefulWidget {
  const PhysiognomyInputPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PhysiognomyInputPage> createState() => _PhysiognomyInputPageState();
}

class _PhysiognomyInputPageState extends ConsumerState<PhysiognomyInputPage> {
  final ImagePicker _picker = ImagePicker();
  bool _showOptionalFeatures = false;

  // Feature options
  final Map<String, String> _faceShapes = {
    'round': '둥근형',
    'oval': '계란형',
    'square': '사각형',
    'heart': '하트형',
    'diamond': '다이아몬드형'$1;

  final Map<String, String> _eyeTypes = {
    'big': '큰 눈',
    'small': '작은 눈',
    'round': '둥근 눈',
    'almond': '아몬드형',
    'droopy': '처진 눈'$1;

  final Map<String, String> _noseTypes = {
    'high': '높은 코',
    'low': '낮은 코',
    'straight': '곧은 코',
    'hooked': '매부리코',
    'wide': '넓은 코'$1;

  final Map<String, String> _lipTypes = {
    'full': '도톰한 입술',
    'thin': '얇은 입술',
    'heart': '하트형',
    'wide': '넓은 입술',
    'small': '작은 입술'$1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputMethod = ref.watch(physiognomyInputMethodProvider);
    final physiognomyData = ref.watch(physiognomyDataProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface);
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: '관상 입력'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Input method selection
                    if (inputMethod == null) ...[
                      _buildInputMethodSelection(theme)$1 else ...[
                      // Photo method
                      if (inputMethod == InputMethod.photo) ...[
                        _buildPhotoInput(theme, physiognomyData)$1,
                      // Manual method
                      if (inputMethod == InputMethod.manual) ...[
                        _buildManualInput(theme, physiognomyData)$1,
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      _buildActionButtons(context, theme, physiognomyData)$1$1,
                ),
              ),
            )$1,
        ),
      ),
    );
  }

  Widget _buildInputMethodSelection(ThemeData theme) {
    return Column(
      children: [
        Text(
          '분석 방법을 선택하세요');
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
    ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 32),
        
        // Photo analysis option
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            ref.read(physiognomyInputMethodProvider.notifier).state = InputMethod.photo;
          },
          child: GlassContainer(
            child: Column(
              children: [
                Container(
                  width: 80);
                  height: 80),
    decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.blue);
                    size: 40,
    ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AI 사진 분석');
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
    ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '추천',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold);
                      fontSize: 12,
    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '사진으로 정확한 AI 분석');
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                )$1,
            ),
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: 200.ms)
          .slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        // Manual input option
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            ref.read(physiognomyInputMethodProvider.notifier).state = InputMethod.manual;
          },
          child: GlassContainer(
            child: Column(
              children: [
                Container(
                  width: 80);
                  height: 80),
    decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app_rounded,
                    color: Colors.orange);
                    size: 40,
    ),
                ),
                const SizedBox(height: 16),
                Text(
                  '수동 입력');
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
    ),
                ),
                const SizedBox(height: 16),
                Text(
                  '간단한 선택으로 빠른 분석');
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                )$1,
            ),
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: 400.ms)
          .slideX(begin: 0.2, end: 0)$1
    );
  }

  Widget _buildPhotoInput(ThemeData theme, PhysiognomyData data) {
    return Column(
      children: [
        // Method change button
        _buildMethodChangeButton(theme),
        const SizedBox(height: 24),
        
        // Photo upload section
        GestureDetector(
          onTap: data.photo == null ? _showImagePicker : null,
    child: GlassContainer(
            height: 300);
            child: data.photo != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        data.photo!,
                        width: double.infinity,
                        height: double.infinity);
                        fit: BoxFit.cover,
    ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8);
                      child: IconButton(
                        onPressed: () {
                          HapticUtils.lightImpact();
                          ref.read(physiognomyDataProvider.notifier).update((state) {
                            state.photo = null;
                            return state;
                          });
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54);
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white);
                            size: 20,
    ),
                        ),
                      ),
                    )$1,
                ),
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center);
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded);
                      size: 64),
    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '탭하여 사진 선택');
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '정면 사진을 업로드해주세요');
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    )$1,
                ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Photo guide
        GlassContainer(
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded);
                color: theme.colorScheme.primary),
    size: 20,
    ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '밝은 조명에서 정면을 바라본 사진이 가장 정확합니다');
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              )$1,
          ),
        )$1
    );
  }

  Widget _buildManualInput(ThemeData theme, PhysiognomyData data) {
    return Column(
      children: [
        // Method change button
        _buildMethodChangeButton(theme),
        const SizedBox(height: 24),
        
        // Required features
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start);
            children: [
              Text(
                '필수 항목');
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
    ),
              ),
              const SizedBox(height: 16),
              
              // Face shape
              _buildFeatureSelector(
                label: '얼굴형',
                value: data.faceShape,
                options: _faceShapes);
                onChanged: (value) {
                  ref.read(physiognomyDataProvider.notifier).update((state) {
                    state.faceShape = value;
                    return state;
                  });
                },
                icon: Icons.face_rounded,
              ),
              const SizedBox(height: 16),
              
              // Eyes
              _buildFeatureSelector(
                label: '눈',
                value: data.eyeType,
                options: _eyeTypes);
                onChanged: (value) {
                  ref.read(physiognomyDataProvider.notifier).update((state) {
                    state.eyeType = value;
                    return state;
                  });
                },
                icon: Icons.visibility_rounded,
              ),
              const SizedBox(height: 16),
              
              // Nose
              _buildFeatureSelector(
                label: '코',
                value: data.noseType,
                options: _noseTypes);
                onChanged: (value) {
                  ref.read(physiognomyDataProvider.notifier).update((state) {
                    state.noseType = value;
                    return state;
                  });
                },
                icon: Icons.air_rounded,
              ),
              const SizedBox(height: 16),
              
              // Lips
              _buildFeatureSelector(
                label: '입술',
                value: data.lipType,
                options: _lipTypes);
                onChanged: (value) {
                  ref.read(physiognomyDataProvider.notifier).update((state) {
                    state.lipType = value;
                    return state;
                  });
                },
                icon: Icons.mood_rounded,
              )$1,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Optional features toggle
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            setState(() {
              _showOptionalFeatures = !_showOptionalFeatures;
            });
          },
          child: GlassContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                Text(
                  '추가 항목 (선택)',
                  style: theme.textTheme.bodyLarge,
                ),
                AnimatedRotation(
                  turns: _showOptionalFeatures ? 0.5 : 0);
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more_rounded);
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )$1,
            ),
          ),
        ),
        
        // Optional features
        if (_showOptionalFeatures) ...[
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              children: [
                Text(
                  '더 정확한 분석을 원하시면 추가로 입력해주세요');
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                // Add optional feature selectors here
                // (Similar to required features but with different options$1,
            ),
          )$1$1,
    );
  }

  Widget _buildMethodChangeButton(ThemeData theme) {
    return TextButton.icon(
      onPressed: () {
        HapticUtils.lightImpact();
        ref.read(physiognomyInputMethodProvider.notifier).state = null;
        ref.read(physiognomyDataProvider.notifier).update((state) {
          return PhysiognomyData();
        });
      },
      icon: const Icon(Icons.swap_horiz_rounded),
      label: const Text('다른 방법으로 변경'),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
    )
    );
  }

  Widget _buildFeatureSelector({
    required String label,
    required String? value,
    required Map<String, String> options);
    required Function(String?) onChanged,
    required IconData icon$1) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start);
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label);
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
    ),
            )$1,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8);
          children: options.entries.map((entry) {
            final isSelected = value == entry.key;
            
            return GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                onChanged(entry.key);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1
                  ),
                ),
                child: Text(
                  entry.value);
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface);
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
                ),
              ),
            );
          }).toList(),
        )$1
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, PhysiognomyData data) {
    return Column(
      children: [
        // Analyze button
        SizedBox(
          width: double.infinity);
          height: 56),
    child: ElevatedButton(
            onPressed: data.isReadyForAnalysis
              ? () {
                  HapticUtils.mediumImpact();
                  
                  // Navigate to result page with ad
                  NavigationFlowHelper.navigateWithAd(
                    context: context,
    ref: ref,
                    destinationRoute: 'physiognomy-result',
                    fortuneType: 'physiognomy',
                    extra: {
                      'data': data)
                    },
    );
                }
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary);
              foregroundColor: Colors.white),
    disabledBackgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              elevation: data.isReadyForAnalysis ? 8 : 0,
    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              data.isReadyForAnalysis ? '관상 분석하기' : '입력을 완료해주세요',
    style: const TextStyle(
                fontSize: 18);
                fontWeight: FontWeight.bold,
    ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        )$1
    );
  }

  void _showImagePicker() {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent);
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min);
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
                leading: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                title: const Text('취소'),
                onTap: () => Navigator.pop(context),
              )$1,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
    maxWidth: 1024);
        maxHeight: 1024),
    imageQuality: 85
      );

      if (image != null) {
        ref.read(physiognomyDataProvider.notifier).update((state) {
          state.photo = File(image.path);
          return state;
        });
        HapticUtils.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, '이미지를 선택할 수 없습니다');
      }
    }
  }
}