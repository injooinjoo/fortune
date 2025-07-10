import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;

class CelebrityMatchPage extends ConsumerWidget {
  const CelebrityMatchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '닮은 연예인 매칭',
      fortuneType: 'celebrity-match',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
      ),
      inputBuilder: (context, onSubmit) => _CelebrityMatchInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _CelebrityMatchResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _CelebrityMatchInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _CelebrityMatchInputForm({required this.onSubmit});

  @override
  State<_CelebrityMatchInputForm> createState() => _CelebrityMatchInputFormState();
}

class _CelebrityMatchInputFormState extends State<_CelebrityMatchInputForm> {
  String? _selectedGender;
  String? _selectedAgeGroup;
  String? _selectedStyle;
  final _featuresController = TextEditingController();

  @override
  void dispose() {
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신과 닮은 연예인을 찾아보세요',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Gender Selection
        Text(
          '성별',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('남성'),
                value: '남성',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('여성'),
                value: '여성',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Age Group
        Text(
          '나이대',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedAgeGroup,
          decoration: InputDecoration(
            hintText: '나이대를 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: ['10대', '20대', '30대', '40대', '50대 이상'].map((age) {
            return DropdownMenuItem(
              value: age,
              child: Text(age),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAgeGroup = value;
            });
          },
        ),
        const SizedBox(height: 20),
        
        // Style Selection
        Text(
          '선호하는 연예인 스타일',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedStyle,
          decoration: InputDecoration(
            hintText: '스타일을 선택하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: ['귀여운', '섹시한', '시크한', '청순한', '카리스마'].map((style) {
            return DropdownMenuItem(
              value: style,
              child: Text(style),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStyle = value;
            });
          },
        ),
        const SizedBox(height: 20),
        
        // Features Description
        Text(
          '외모 특징',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _featuresController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '본인의 외모 특징을 간단히 설명해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedGender == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('성별을 선택해주세요')),
                );
                return;
              }
              if (_selectedAgeGroup == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('나이대를 선택해주세요')),
                );
                return;
              }
              if (_selectedStyle == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('스타일을 선택해주세요')),
                );
                return;
              }
              
              widget.onSubmit({
                'gender': _selectedGender,
                'ageGroup': _selectedAgeGroup,
                'style': _selectedStyle,
                'features': _featuresController.text,
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              '닮은 연예인 찾기',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CelebrityMatchResult extends ConsumerStatefulWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _CelebrityMatchResult({
    required this.result,
    required this.onShare,
  });

  @override
  ConsumerState<_CelebrityMatchResult> createState() => _CelebrityMatchResultState();
}

class _CelebrityMatchResultState extends ConsumerState<_CelebrityMatchResult> {
  double _getFontSizeOffset(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return -2.0;
      case FontSize.medium:
        return 0.0;
      case FontSize.large:
        return 2.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    final celebrityName = widget.result.additionalInfo?['celebrity_name'] ?? '알 수 없음';
    final matchPercentage = widget.result.additionalInfo?['match_percentage'] ?? 0;
    final description = widget.result.mainFortune ?? '';
    final similarities = widget.result.additionalInfo?['similarities'] as List<dynamic>? ?? [];
    final celebrityTraits = widget.result.additionalInfo?['celebrity_traits'] as List<dynamic>? ?? [];
    final advice = widget.result.additionalInfo?['advice'] ?? '당신만의 매력을 더욱 발전시켜보세요!';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match Card
        GlassContainer(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  celebrityName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28 + _getFontSizeOffset(fontSize),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$matchPercentage% 일치',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 36 + _getFontSizeOffset(fontSize),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '닮은꼴 연예인',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Description
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '매칭 분석',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontSize: 16 + _getFontSizeOffset(fontSize),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Similarities
        if (similarities.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.compare, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '공통점',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...similarities.map((similarity) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            similarity.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 14 + _getFontSizeOffset(fontSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Celebrity Traits
        if (celebrityTraits.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '연예인 특징',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: celebrityTraits.map((trait) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        trait.toString(),
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Advice
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '스타일 조언',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  advice,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontSize: 16 + _getFontSizeOffset(fontSize),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Share Button
        Center(
          child: OutlinedButton.icon(
            onPressed: widget.onShare,
            icon: const Icon(Icons.share),
            label: const Text('운세 공유하기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}