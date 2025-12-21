import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';
import '../../data/models/celebrity_saju.dart';
import '../providers/celebrity_saju_provider.dart';

class CelebritySearchWidget extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(CelebritySaju) onCelebritySelected;

  const CelebritySearchWidget({
    super.key,
    required this.controller,
    required this.onCelebritySelected,
  });

  @override
  ConsumerState<CelebritySearchWidget> createState() => _CelebritySearchWidgetState();
}

class _CelebritySearchWidgetState extends ConsumerState<CelebritySearchWidget> {
  bool _showSuggestions = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final query = widget.controller.text.trim();
    setState(() {
      _currentQuery = query;
      _showSuggestions = query.isNotEmpty;
    });
    
    if (query.isNotEmpty) {
      ref.read(searchQueryProvider.notifier).state = query;
    }
  }

  void _onCelebrityTap(CelebritySaju celebrity) {
    widget.controller.text = celebrity.name;
    widget.onCelebritySelected(celebrity);
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 입력 필드
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: '연예인 이름을 입력하세요 (예: 이효리, 박진영)',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _currentQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _showSuggestions = false;
                        _currentQuery = '';
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TossDesignSystem.gray300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TossDesignSystem.gray300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TossDesignSystem.tossBlue,
                width: 2,
              ),
            ),
          ),
          onTap: () {
            if (_currentQuery.isEmpty) {
              setState(() {
                _showSuggestions = true;
              });
            }
          },
        ),

        // 검색 결과 또는 인기 연예인 표시
        if (_showSuggestions) ...[
          const SizedBox(height: 12),
          _buildSuggestionsList(),
        ],
      ],
    );
  }

  Widget _buildSuggestionsList() {
    if (_currentQuery.isEmpty) {
      // 빈 검색어일 때 인기 연예인 표시
      final popularCelebrities = ref.watch(popularCelebritiesProvider(null));
      
      return popularCelebrities.when(
        data: (celebrities) => _buildCelebrityList(
          celebrities.take(6).toList(),
          title: '인기 연예인',
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => _buildErrorWidget(error.toString()),
      );
    } else {
      // 검색 결과 표시
      final searchResults = ref.watch(celebritySearchProvider(_currentQuery));
      
      return searchResults.when(
        data: (celebrities) => celebrities.isEmpty
            ? _buildNoResultsWidget()
            : _buildCelebrityList(celebrities, title: '검색 결과'),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => _buildErrorWidget(error.toString()),
      );
    }
  }

  Widget _buildCelebrityList(List<CelebritySaju> celebrities, {required String title}) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: TossDesignSystem.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossDesignSystem.gray300,
        ),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.gray900.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: TossDesignSystem.tossBlue,
                  ),
                ),
                const Spacer(),
                Text(
                  '${celebrities.length}명',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: TossDesignSystem.gray500,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // 연예인 목록
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: celebrities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final celebrity = celebrities[index];
                return _buildCelebrityListTile(celebrity);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrityListTile(CelebritySaju celebrity) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: TossDesignSystem.tossBlue.withValues(alpha:0.2),
        child: Text(
          celebrity.name.isNotEmpty ? celebrity.name[0] : '?',
          style: TextStyle(
            color: TossDesignSystem.tossBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        celebrity.name,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${celebrity.category} • ${celebrity.age}세'),
          const SizedBox(height: 2),
          Text(
            '사주: ${celebrity.sajuString}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: TossDesignSystem.tossBlue.withValues(alpha:0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getElementColor(celebrity.dominantElement).withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          celebrity.dominantElement,
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getElementColor(celebrity.dominantElement),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () => _onCelebrityTap(celebrity),
    );
  }

  Widget _buildNoResultsWidget() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossDesignSystem.gray300,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: TossDesignSystem.gray400,
          ),
          const SizedBox(height: 12),
          Text(
            '검색 결과가 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              color: TossDesignSystem.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 연예인 이름으로 검색해보세요',
            style: theme.textTheme.bodySmall?.copyWith(
              color: TossDesignSystem.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossDesignSystem.errorRed.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TossDesignSystem.errorRed.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: TossDesignSystem.errorRed,
          ),
          const SizedBox(height: 12),
          Text(
            '검색 중 오류가 발생했습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              color: TossDesignSystem.errorRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: TossDesignSystem.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
        return TossDesignSystem.successGreen;
      case '화':
        return TossDesignSystem.warningOrange;
      case '토':
        return TossDesignSystem.brownPrimary;
      case '금':
        return TossDesignSystem.warningOrange;
      case '수':
        return TossDesignSystem.tossBlue;
      default:
        return TossDesignSystem.gray600;
    }
  }
}