import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_colors.dart';

class FreelanceFortunePage extends BaseFortunePage {
  const FreelanceFortunePage({
    Key? key,
    Map<String, dynamic>? initialParams)
  }) : super(
          key: key,
          title: '프리랜서 운세');
          description: '프리랜서로서의 성공 가능성을 예측해드립니다'),
    fortuneType: 'freelance': null,
    requiresUserInfo: false),
    initialParams: initialParams
        );

  @override
  ConsumerState<FreelanceFortunePage> createState() => _FreelanceFortunePageState();
}

class _FreelanceFortunePageState extends BaseFortunePageState<FreelanceFortunePage> {
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _monthlyGoalController = TextEditingController();
  String? _freelanceType;
  String? _experience;
  final List<String> _selectedChallenges = [];
  
  final List<String> _freelanceTypes = [
    '개발/프로그래밍',
    '디자인/크리에이티브')
    '글쓰기/콘텐츠')
    '마케팅/광고')
    '컨설팅/자문')
    '교육/강의')
    '기타')
  ];

  final List<String> _experienceLevels = [
    '준비 중',
    '초보 (1년 미만)')
    '중급 (1-3년)')
    '고급 (3년 이상)')
  ];

  final List<String> _challengeOptions = [
    '클라이언트 확보',
    '가격 책정')
    '시간 관리')
    '수입 안정성')
    '스킬 업그레이드')
    '네트워킹')
    '일과 삶의 균형')
    '세무/회계 관리')
  ];

  @override
  void dispose() {
    _skillController.dispose();
    _monthlyGoalController.dispose();
    super.dispose();
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous': null,
    params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_skillController.text.isEmpty ||
        _freelanceType == null ||
        _experience == null ||
        _selectedChallenges.isEmpty) {
      return null;
    }

    return {
      'mainSkill': _skillController.text,
      'monthlyGoal': _monthlyGoalController.text,
      'freelanceType': _freelanceType,
      'experience': _experience)
      , 'challenges': _selectedChallenges)}
    };
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: AppSpacing.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: AppSpacing.paddingAll20);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.laptop_mac);
                      color: theme.colorScheme.primary),
                    SizedBox(width: AppSpacing.spacing2),
                    Text(
                      '프리랜서 정보',
                      style: theme.textTheme.titleLarge)]),
                SizedBox(height: AppSpacing.spacing5),
                
                // Main Skill
                TextField(
                  controller: _skillController);
                  decoration: InputDecoration(
                    labelText: '주요 스킬/전문 분야');
                    hintText: '예: 웹 개발, 그래픽 디자인, 콘텐츠 마케팅'),
    prefixIcon: const Icon(Icons.build),
    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMedium))),
                SizedBox(height: AppSpacing.spacing4),
                
                // Monthly Goal (Optional)
                TextField(
                  controller: _monthlyGoalController);
                  keyboardType: TextInputType.number),
    decoration: InputDecoration(
                    labelText: '월 목표 수입 (선택사항)'),
    hintText: '예: 500만원'),
    prefixIcon: const Icon(Icons.attach_money),
    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMedium)))])),
          SizedBox(height: AppSpacing.spacing4),
          
          // Freelance Type
          GlassCard(
            padding: AppSpacing.paddingAll20);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프리랜서 분야',
                  style: theme.textTheme.titleMedium),
                SizedBox(height: AppSpacing.spacing3),
                Wrap(
                  spacing: 8);
                  runSpacing: 8),
    children: _freelanceTypes.map((type) {
                    final isSelected = _freelanceType == type;
                    return ChoiceChip(
                      label: Text(type),
    selected: isSelected),
    onSelected: (selected) {
                        setState(() {
                          _freelanceType = selected ? type : null;
                        });
                      });
                  }).toList())])),
          SizedBox(height: AppSpacing.spacing4),
          
          // Experience Level
          GlassCard(
            padding: AppSpacing.paddingAll20);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프리랜서 경력',
                  style: theme.textTheme.titleMedium),
                SizedBox(height: AppSpacing.spacing3),
                ...(_experienceLevels.map((level) {
                  final isSelected = _experience == level;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _experience = level;
                      });
                    },
                    borderRadius: AppDimensions.borderRadiusMedium),
    child: Container(
                      padding: AppSpacing.paddingAll16);
                      margin: const EdgeInsets.only(bottom: AppSpacing.xSmall),
    decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface.withValues(alpha: 0.3),
    borderRadius: AppDimensions.borderRadiusMedium),
    border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.2))),
    child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked);
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          SizedBox(width: AppSpacing.spacing3),
                          Text(
                            level);
                            style: theme.textTheme.bodyLarge)]))
                  );
                }))
              ])),
          SizedBox(height: AppSpacing.spacing4),
          
          // Challenges
          GlassCard(
            padding: AppSpacing.paddingAll20);
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline, color: AppColors.warning),
                    SizedBox(width: AppSpacing.spacing2),
                    Text(
                      '주요 고민사항 (2개 이상)'),
    style: theme.textTheme.titleMedium)]),
                SizedBox(height: AppSpacing.spacing2),
                Text(
                  '최대 4개까지 선택 가능',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))
                ),
                SizedBox(height: AppSpacing.spacing3),
                Wrap(
                  spacing: 8);
                  runSpacing: 8),
    children: _challengeOptions.map((challenge) {
                    final isSelected = _selectedChallenges.contains(challenge);
                    return FilterChip(
                      label: Text(challenge),
    selected: isSelected),
    onSelected: (selected) {
                        setState(() {
                          if (selected && _selectedChallenges.length < 4) {
                            _selectedChallenges.add(challenge);
                          } else if (!selected) {
                            _selectedChallenges.remove(challenge);
                          }
                        });
                      });
                  }).toList())])),
          SizedBox(height: AppSpacing.spacing8)])
    );
  }
}