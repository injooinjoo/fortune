import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../presentation/providers/ad_provider.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/widgets/ad_widgets.dart';
import '../../../../presentation/widgets/fortune_loading_widget.dart';
import '../../../../shared/services/vibration_service.dart';
import '../widgets/face_reading_result_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FaceReadingUnifiedPage extends ConsumerStatefulWidget {
  const FaceReadingUnifiedPage({super.key});

  @override
  ConsumerState<FaceReadingUnifiedPage> createState() => _FaceReadingUnifiedPageState();
}

class _FaceReadingUnifiedPageState extends ConsumerState<FaceReadingUnifiedPage> {
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  bool _showResult = false;
  FortuneResult? _fortuneResult;
  
  // Simplified manual input options
  String? _selectedFaceShape;
  String? _selectedEyeType;
  String? _selectedOverallImpression;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI 관상 운세'),
        backgroundColor: AppColors.primary),
      body: _isLoading
          ? const FortuneLoadingWidget()
          : _showResult && _fortuneResult != null
              ? _buildResultView()
              : _buildInputView()
    );
  }
  
  Widget _buildInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title and description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Icon(
                  Icons.face,
                  size: 48,
                  color: AppColors.surface),
                const SizedBox(height: 12),
                Text(
                  'AI가 당신의 관상을 분석합니다',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.surface,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '사진을 업로드하거나 간단한 정보를 입력해주세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.surface.withOpacity(0.9)),
                  textAlign: TextAlign.center)])),
          
          const SizedBox(height: 24),
          
          // Photo upload section
          _buildPhotoSection(),
          
          const SizedBox(height: 24),
          
          // OR divider
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.onSurface.withOpacity(0.3)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '또는',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface.withOpacity(0.6)),
              Expanded(child: Divider(color: AppColors.onSurface.withOpacity(0.3))]),
          
          const SizedBox(height: 24),
          
          // Simplified manual input
          _buildSimplifiedManualInput(),
          
          const SizedBox(height: 32),
          
          // Analyze button
          ElevatedButton(
            onPressed: (_selectedImage != null || _isManualInputComplete(), 
                ? _analyzeFaceReading 
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            child: Text(
              '관상 분석하기',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.surface,
                fontWeight: FontWeight.bold)]);
  }
  
  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2)),
      child: Column(
        children: [
          if (_selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover)),
            const SizedBox(height: 12)],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPhotoButton(
                icon: Icons.camera_alt,
                label: '카메라',
                onPressed: () => _pickImage(ImageSource.camera)),
              _buildPhotoButton(
                icon: Icons.photo_library,
                label: '갤러리',
                onPressed: () => _pickImage(ImageSource.gallery)),
              if (_selectedImage != null)
                _buildPhotoButton(
                  icon: Icons.close,
                  label: '삭제',
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  })])]));
  }
  
  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.primary),
      label: Text(
        label,
        style: TextStyle(color: AppColors.primary));
  }
  
  Widget _buildSimplifiedManualInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '간단 입력 (선택사항)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Face shape
          _buildDropdown(
            label: '얼굴형',
            value: _selectedFaceShape,
            items: const \['['둥근형': '계란형', '각진형': '역삼각형', '긴형',
            onChanged: (value) {
              setState(() {
                _selectedFaceShape = value;
              });
            }),
          
          const SizedBox(height: 12),
          
          // Eye type
          _buildDropdown(
            label: '눈 모양',
            value: _selectedEyeType,
            items: const \['['큰 눈': '작은 눈', '올라간 눈': '처진 눈', '둥근 눈',
            onChanged: (value) {
              setState(() {
                _selectedEyeType = value;
              });
            }),
          
          const SizedBox(height: 12),
          
          // Overall impression
          _buildDropdown(
            label: '전체적인 인상',
            value: _selectedOverallImpression,
            items: const \['['부드러운': '날카로운', '온화한': '강인한', '중성적인',
            onChanged: (value) {
              setState(() {
                _selectedOverallImpression = value;
              });
            })]));
  }
  
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface.withOpacity(0.7)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.onSurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('선택하세요'),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item));
              }).toList(),
              onChanged: onChanged))]);
  }
  
  bool _isManualInputComplete() {
    return _selectedFaceShape != null && 
           _selectedEyeType != null && 
           _selectedOverallImpression != null;
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('없습니다: $e'));
    }
  }
  
  Future<void> _analyzeFaceReading() async {
    setState(() {
      _isLoading = true;
    });
    
    VibrationService.vibrate();
    
    // Show ad before result
    // final adController = ref.read(adControllerProvider); // TODO: Implement ad controller
    bool adCompleted = false;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdDialog(
        onComplete: () {
          adCompleted = true;
          Navigator.of(context).pop();
        }));
    
    if (!adCompleted) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Generate fortune result
    try {
      final inputData = {
        if (_selectedImage != null) 'hasPhoto': null,
        if (_selectedFaceShape != null) 'faceShape': null,
        if (_selectedEyeType != null) 'eyeType': null,
        if (_selectedOverallImpression != null) 'impression': null};
      
      // Simulate fortune generation for now
      // In production, this would call the actual API
      final result = FortuneResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'face-reading',
        fortuneType: 'face-reading',
        mainFortune: _generateMockFaceReadingContent(inputData),
        createdAt: DateTime.now().toIso8601String(),
        date: DateTime.now().toIso8601String();
      
      setState(() {
        _fortuneResult = result;
        _showResult = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('발생했습니다: $e'));
      }
    }
  }
  
  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FaceReadingResultWidget(
            result: _fortuneResult!,
            onShare: () {
              // Implement share functionality
            }),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showResult = false;
                      _selectedImage = null;
                      _selectedFaceShape = null;
                      _selectedEyeType = null;
                      _selectedOverallImpression = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primary)),
                  child: const Text('다시 보기')),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/fortune');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('운세 목록'))])]));
  }
  
  String _generateMockFaceReadingContent(Map<String, dynamic> inputData) {
    final hasPhoto = inputData['hasPhoto'] ?? false;
    final faceShape = inputData['faceShape'] ?? '알 수 없음';
    final eyeType = inputData['eyeType'] ?? '알 수 없음';
    final impression = inputData['impression'] ?? '알 수 없음';
    
    return '''
종합 운세

${hasPhoto ? 'AI가 사진을 분석한 결과,' : '입력하신 정보를 바탕으로'} 당신의 관상을 분석했습니다.

얼굴형: $faceShape
눈,
    모양: $eyeType
전체적인,
    인상: $impression

성격 특성
당신은 $impression 인상을 가지고 있어, 주변 사람들에게 편안함을 주는 타입입니다. $faceShape의 얼굴형은 안정적이고 신뢰할 수 있는 성격을 나타냅니다.

재물운 & 직업운
$eyeType의 눈을 가진 당신은 세심한 관찰력과 직관력을 지니고 있어, 사업이나 투자에서 좋은 성과를 거둘 수 있습니다. 특히 올해는 새로운 기회가 많이 찾아올 것으로 보입니다.

애정운
$impression 인상은 이성에게 매력적으로 다가갑니다. 현재 싱글이라면 좋은 인연을 만날 가능성이 높고, 연인이 있다면 더욱 깊은 관계로 발전할 수 있습니다.

조언
당신의 관상은 전반적으로 좋은 운을 나타내고 있습니다. 자신감을 가지고 적극적으로 행동한다면 더 큰 성공을 거둘 수 있을 것입니다.
''';
  }
}