import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../data/models/celebrity_saju.dart';
import '../../../../presentation/providers/celebrity_saju_provider.dart';
import '../../../../presentation/widgets/celebrity_search_widget.dart';
import '../../../../presentation/widgets/celebrity_saju_info_widget.dart';

class CelebrityFortunePageV2 extends ConsumerWidget {
  const CelebrityFortunePageV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '연예인 운세',
      fortuneType: 'celebrity-saju',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B6B), Color(0xFFC44569)],
      ),
      inputBuilder: (context, onSubmit) => _CelebritySajuInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _CelebritySajuFortuneResult(
        result: result,
        onShare: onShare,
      ),
    );
  }
}

class _CelebritySajuInputForm extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _CelebritySajuInputForm({required this.onSubmit});

  @override
  ConsumerState<_CelebritySajuInputForm> createState() => _CelebritySajuInputFormState();
}

class _CelebritySajuInputFormState extends ConsumerState<_CelebritySajuInputForm> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  CelebritySaju? _selectedCelebrity;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onCelebritySelected(CelebritySaju celebrity) {
    setState(() {
      _selectedCelebrity = celebrity;
      _searchController.text = celebrity.name;
    });
  }

  void _submitFortune() {
    if (_nameController.text.trim().isEmpty) {
      Toast.show(context, message: '이름을 입력해주세요.');
      return;
    }

    if (_selectedCelebrity == null) {
      Toast.show(context, message: '연예인을 선택해주세요.');
      return;
    }

    widget.onSubmit({
      'userName': _nameController.text.trim(),
      'celebrity': _selectedCelebrity!.toJson(),
      'fortuneType': 'celebrity-saju',
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 설명 텍스트
        Text(
          '좋아하는 연예인의 사주를 통해\n오늘 하루의 행운을 받아보세요!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
            fontSize: fontSize.value,
          ),
        ),
        const SizedBox(height: 24),

        // 사용자 이름 입력
        Text(
          '이름',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: fontSize.value,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '이름을 입력하세요',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 연예인 검색
        Text(
          '연예인 검색',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: fontSize.value,
          ),
        ),
        const SizedBox(height: 12),

        // 연예인 검색 위젯
        CelebritySearchWidget(
          controller: _searchController,
          onCelebritySelected: _onCelebritySelected,
        ),
        const SizedBox(height: 20),

        // 선택된 연예인 정보
        if (_selectedCelebrity != null) ...[
          Text(
            '선택된 연예인',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: fontSize.value,
            ),
          ),
          const SizedBox(height: 12),
          CelebritySajuInfoWidget(celebrity: _selectedCelebrity!),
          const SizedBox(height: 24),
        ],

        // 운세 보기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitFortune,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '${_selectedCelebrity?.name ?? '연예인'} 운세 보기',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
                fontSize: fontSize.value,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CelebritySajuFortuneResult extends ConsumerWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _CelebritySajuFortuneResult({
    required this.result,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);

    // result.additionalInfo에서 celebrity 정보 추출
    final celebrityData = result.additionalInfo?['celebrity'] as Map<String, dynamic>?;
    final celebrity = celebrityData != null ? CelebritySaju.fromJson(celebrityData) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 연예인 사주 정보 카드
        if (celebrity != null) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${celebrity.name}의 사주',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize.value + 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CelebritySajuInfoWidget(
                    celebrity: celebrity,
                    showDetailedInfo: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 운세 결과
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 운세',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize.value + 4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  result.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: fontSize.value,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 공유하기 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            label: Text(
              '운세 공유하기',
              style: TextStyle(fontSize: fontSize.value),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}