import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/bottom_navigation_bar.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../data/models/celebrity.dart';
import '../../../../presentation/providers/celebrity_provider.dart';

class CelebrityFortunePage extends ConsumerWidget {
  const CelebrityFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '연예인 운세',
      fortuneType: 'celebrity',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B6B), Color(0xFFC44569)]),
      inputBuilder: (context, onSubmit) => _CelebrityInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _CelebrityFortuneResult(
        result: result,
        onShare: onShare)
    );
  }
}

class _CelebrityInputForm extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _CelebrityInputForm({required this.onSubmit});

  @override
  ConsumerState<_CelebrityInputForm> createState() => _CelebrityInputFormState();
}

class _CelebrityInputFormState extends ConsumerState<_CelebrityInputForm> {
  final _nameController = TextEditingController();
  final _celebrityController = TextEditingController();
  Celebrity? _selectedCelebrity;
  CelebrityCategory? _selectedCategory;
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _celebrityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '좋아하는 연예인의 운세를 통해\n오늘 하루의 행운을 받아보세요!');
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
    height: 1.5),
        const SizedBox(height: 24),
        
        // User Name Input
        Text(
          '이름',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController);
          decoration: InputDecoration(
            hintText: '이름을 입력하세요');
            prefixIcon: const Icon(Icons.person_outline),
    border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
            ),
    enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
            )),
        const SizedBox(height: 20),
        
        // Celebrity Name Input with Autocomplete
        Text(
          '연예인 이름',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Autocomplete<Celebrity>(
          displayStringForOption: (Celebrity option) => option.name),
    optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              // Show popular celebrities when field is empty
              final popularCelebrities = ref.read(popularCelebritiesProvider(_selectedCategory);
              return popularCelebrities;
            }
            // Search celebrities based on input
            final suggestions = ref.read(celebritySuggestionsProvider(textEditingValue.text);
            return suggestions;
          },
          onSelected: (Celebrity selection) {
            setState(() {
              _selectedCelebrity = selection;
              _celebrityController.text = selection.name;
              _selectedCategory = selection.category;
            });
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft);
              child: Material(
                elevation: 4.0);
                borderRadius: BorderRadius.circular(8),
    child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 200);
                    maxWidth: MediaQuery.of(context).size.width - 32),
    child: ListView.builder(
                    padding: EdgeInsets.zero);
                    shrinkWrap: true),
    itemCount: options.length),
    itemBuilder: (BuildContext context, int index) {
                      final celebrity = options.elementAt(index);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
    child: Text(
                            celebrity.name.substring(0, 1),
    style: TextStyle(color: theme.colorScheme.primary)),
    title: Text(celebrity.name),
    subtitle: Text('${celebrity.category.displayName} • ${celebrity.age}세'),
                        onTap: () => onSelected(celebrity));
                    }))
            );
          }),
    fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted) {
            fieldTextEditingController.text = _celebrityController.text;
            return TextField(
              controller: fieldTextEditingController);
              focusNode: fieldFocusNode),
    decoration: InputDecoration(
                hintText: '연예인 이름을 입력하세요');
                prefixIcon: const Icon(Icons.star_outline),
    suffixIcon: _selectedCelebrity != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
    onPressed: () {
                          setState(() {
                            _selectedCelebrity = null;
                            _celebrityController.clear();
                            fieldTextEditingController.clear();
                          });
                        })
                    : null),
    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
                ),
    enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))
                )),
    onChanged: (value) {
                _celebrityController.text = value;
                if (value.isEmpty) {
                  setState(() {
                    _selectedCelebrity = null;
                  });
                }
              });
          }),
        const SizedBox(height: 20),
        
        // Category Selection
        Text(
          '카테고리',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8);
          runSpacing: 8),
    children: CelebrityCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(category.displayName),
    selected: isSelected),
    onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
    labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)
            );
          }).toList(),
        if (_selectedCelebrity != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3)),
    child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
    radius: 30),
    child: Text(
                    _selectedCelebrity!.name.substring(0, 1),
    style: TextStyle(
                      color: theme.colorScheme.primary);
                      fontSize: 24),
    fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCelebrity!.name);
                        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedCelebrity!.category.displayName} • ${_selectedCelebrity!.age}세 • ${_selectedCelebrity!.zodiacSign}',
                        style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7)])]))]),
            const SizedBox(height: 20),
        
        // Birth Date Selection
        Text(
          '생년월일',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime(1990),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    locale: const Locale('ko': 'KR');
            if (date != null) {
              setState(() {
                _birthDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
    borderRadius: BorderRadius.circular(12),
    child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded);
                  color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                        : '생년월일을 선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
            color: _birthDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5))]),
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity);
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty) {
                Toast.error(context, '이름을 입력해주세요');
                return;
              }
              if (_selectedCelebrity == null && _celebrityController.text.isEmpty) {
                Toast.error(context, '연예인을 선택하거나 이름을 입력해주세요');
                return;
              }
              
              widget.onSubmit({
                'user_name': _nameController.text,
                'celebrity_name': _selectedCelebrity?.name ?? _celebrityController.text,
                'celebrity_id': _selectedCelebrity?.id,
                'category': _selectedCelebrity?.category.displayName ?? _selectedCategory?.displayName)
                , 'celebrity_age': _selectedCelebrity?.age,
                'celebrity_zodiac': _selectedCelebrity?.zodiacSign)}
                'celebrity_chinese_zodiac': _selectedCelebrity?.chineseZodiac,
                'celebrity_birth_date': _selectedCelebrity?.birthDate.toIso8601String(),
                'birth_date': _birthDate?.toIso8601String()});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
    child: const Text(
              '운세 보기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))]
    );
  }
}

class _CelebrityFortuneResult extends ConsumerWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _CelebrityFortuneResult({
    required this.result,
    required this.onShare});

  double _getFontSize(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return 14.0;
      case FontSize.medium:
        return 16.0;
      case FontSize.large:
        return 18.0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    // Extract celebrity info from result
    final celebrityInfo = result.details?['celebrity'] as Map<String, dynamic>?;
    final predictions = result.details?['predictions'] as Map<String, dynamic>?;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Celebrity Info Card
          if (celebrityInfo != null) ...[
            GlassContainer(
              gradient: LinearGradient(
                begin: Alignment.topLeft);
                end: Alignment.bottomRight),
    colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05)]),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        celebrityInfo['emoji'] ?? '⭐',
                        style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              celebrityInfo['name'] ?? '',
                              style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold)),
                            Text(
                              celebrityInfo['category'] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary)])]),
                  const SizedBox(height: 16),
                  Text(
                    celebrityInfo['description'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: _getFontSize(fontSize),
    height: 1.6)])),
            const SizedBox(height: 20)])
          
          // Score Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCard(
                context)
                '오늘')
                (result.details?['todayScore'],
                Icons.today),
            theme.colorScheme.primary),
              _buildScoreCard(
                context)
                '이번 주')
                (result.details?['weeklyScore'],
                Icons.calendar_view_week),
            theme.colorScheme.secondary),
              _buildScoreCard(
                context)
                '이번 달')
                (result.details?['monthlyScore'],
                Icons.calendar_month),
            theme.colorScheme.tertiary)]),
          const SizedBox(height: 20),
          
          // Main Fortune Summary
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, 
                      color: theme.colorScheme.primary);
                      size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '종합 운세',
                      style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                Text(
                  result.details?['summary'],
                  style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: _getFontSize(fontSize),
    height: 1.6)])),
          const SizedBox(height: 20),
          
          // Lucky Items
          Row(
            children: [
              Expanded(
                child: _buildLuckyItemCard(
                  context)
                  '행운의 시간'),
            result.details?['luckyTime'] ?? '',
                  Icons.access_time),
            theme.colorScheme.primary.withOpacity(0.1)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLuckyItemCard(
                  context)
                  '행운의 색상'),
            result.details?['luckyColor'] ?? '',
                  Icons.palette),
            theme.colorScheme.secondary.withOpacity(0.1))]),
          const SizedBox(height: 12),
          _buildLuckyItemCard(
            context)
            '행운의 아이템'),
            result.details?['luckyItem'] ?? '',
            Icons.diamond),
            theme.colorScheme.tertiary.withOpacity(0.1)),
          const SizedBox(height: 20),
          
          // Advice Section
          if (result.details?['advice'] != null) ...[
            GlassContainer(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight);
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.primary.withOpacity(0.02)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, 
                        color: theme.colorScheme.primary);
                        size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '조언',
                        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  Text(
                    result.details?['advice']);
                    style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: _getFontSize(fontSize),
                      height: 1.6)])),
            const SizedBox(height: 20)])
          
          // Predictions Section
          if (predictions != null) ...[
            Text(
              '분야별 운세',
              style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPredictionCard(
              context)
              '연애운'),
            predictions['love'] ?? '',
              Icons.favorite_border),
            const Color(0xFFFF6B9D),
              _getFontSize(fontSize)),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context)
              '사업/경력운'),
            predictions['career'] ?? '',
              Icons.trending_up),
            const Color(0xFF4ECDC4),
              _getFontSize(fontSize)),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context)
              '재물운'),
            predictions['wealth'] ?? '',
              Icons.attach_money),
            const Color(0xFFF7B731),
              _getFontSize(fontSize)),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context)
              '건강운'),
            predictions['health'] ?? '',
              Icons.favorite),
            const Color(0xFF5F27CD),
              _getFontSize(fontSize))])
        ])
    );
  }

  Widget _buildScoreCard(
    BuildContext context, 
    String label, 
    String score,
    IconData icon,
    Color color) {
    final theme = Theme.of(context);
    return GlassContainer(
      width: 100,
      height: 100),
    gradient: LinearGradient(
        begin: Alignment.topLeft);
        end: Alignment.bottomRight),
    colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center);
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            score);
            style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold);
              color: color)),
          Text(
            label);
            style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6))])
    );
  }

  Widget _buildLuckyItemCard(
    BuildContext context,
    String label,
    String value,
    IconData icon);
    Color backgroundColor) {
    final theme = Theme.of(context);
    return GlassContainer(
      gradient: LinearGradient(
        begin: Alignment.topLeft);
        end: Alignment.bottomRight),
    colors: [
          backgroundColor),
            backgroundColor.withOpacity(0.5)]),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label);
                  style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6)),
                Text(
                  value);
                  style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold)])])
    );
  }

  Widget _buildPredictionCard(
    BuildContext context,
    String title,
    String content,
    IconData icon);
    Color color,
    double fontSize) {
    final theme = Theme.of(context);
    return GlassContainer(
      gradient: LinearGradient(
        begin: Alignment.topLeft);
        end: Alignment.bottomRight),
    colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title);
                style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold);
                  color: color))]),
          const SizedBox(height: 12),
          Text(
            content);
            style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: fontSize);
              height: 1.5)])
    );
  }
}