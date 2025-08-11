import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../data/models/celebrity.dart';
import '../../../../presentation/providers/celebrity_provider.dart';

class CelebrityFortuneEnhancedPage extends ConsumerWidget {
  const CelebrityFortuneEnhancedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '유명인 운세',
      fortuneType: 'celebrity',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B6B), Color(0xFFC44569)]),
      inputBuilder: (context, onSubmit) => _CelebrityGridInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _CelebrityFortuneResult(
        result: result,
        onShare: onShare),
    );
  }
}

class _CelebrityGridInputForm extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _CelebrityGridInputForm({required this.onSubmit});

  @override
  ConsumerState<_CelebrityGridInputForm> createState() => _CelebrityGridInputFormState();
}

class _CelebrityGridInputFormState extends ConsumerState<_CelebrityGridInputForm> {
  Celebrity? _selectedCelebrity;
  CelebrityCategory? _selectedCategory;
  DateTime? _birthDate;
  String? _birthTime;

  // Dummy celebrity images for demonstration
  static const Map<String, String> _celebrityImages = {
    'pol_001': 'https://via.placeholder.com/200/FF6B6B/FFFFFF?text=YS',
    'pol_002': 'https://via.placeholder.com/200/4ECDC4/FFFFFF?text=LJM',
    'pol_003': 'https://via.placeholder.com/200/F7B731/FFFFFF?text=HDH',
    'act_001': 'https://via.placeholder.com/200/9B59B6/FFFFFF?text=SJK',
    'act_002': 'https://via.placeholder.com/200/3498DB/FFFFFF?text=SYJ',
    'singer_001': 'https://via.placeholder.com/200/E74C3C/FFFFFF?text=IU',
    'singer_002': 'https://via.placeholder.com/200/1ABC9C/FFFFFF?text=GD'
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allCelebrities = ref.watch(allCelebritiesProvider);
    
    // Filter celebrities by category
    final filteredCelebrities = _selectedCategory != null
        ? allCelebrities.where((c) => c.category == _selectedCategory).toList()
        : allCelebrities;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '좋아하는 유명인을 선택하고\n오늘의 운세를 확인해보세요!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5),
          ),
          const SizedBox(height: 24),
          
          // Category Selection
          Text(
            '카테고리',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(null, '전체'),
                const SizedBox(width: 8),
                ...CelebrityCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryChip(category, category.displayName),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Celebrity Grid
          Text(
            '유명인 선택',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85),
            itemCount: filteredCelebrities.length > 30 ? 30 : filteredCelebrities.length,
            itemBuilder: (context, index) {
              final celebrity = filteredCelebrities[index];
              final isSelected = _selectedCelebrity?.id == celebrity.id;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCelebrity = celebrity;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 3 : 1),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                          ]
                        : null),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        // Celebrity Image
                        Positioned.fill(
                          child: celebrity.profileImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: celebrity.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: theme.colorScheme.surfaceVariant,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  errorWidget: (context, url, error) => _buildPlaceholderImage(celebrity, theme),
                              )
                              : _buildPlaceholderImage(celebrity, theme),
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Celebrity Info
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                celebrity.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${celebrity.category.displayName} • ${celebrity.age}세',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                        // Selection Indicator
                        if (isSelected)
            Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          if (_selectedCelebrity != null) ...[
            const SizedBox(height: 24),
            // Selected Celebrity Details
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: _selectedCelebrity!.profileImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _selectedCelebrity!.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => _buildPlaceholderImage(_selectedCelebrity!, theme))
                          : _buildPlaceholderImage(_selectedCelebrity!, theme)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCelebrity!.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedCelebrity!.category.displayName} • ${_selectedCelebrity!.age}세 • ${_selectedCelebrity!.zodiacSign}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7))),
                        if (_selectedCelebrity!.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _selectedCelebrity!.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)]]))]))],
          
          const SizedBox(height: 24),
          
          // Birth Date & Time Selection
          Text(
            '생년월일',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? DateTime(1990),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: const Locale('ko', 'KR'));
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
                      borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: theme.colorScheme.primary,
                          size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _birthDate != null
                                ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                                : '생년월일',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _birthDate != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withOpacity(0.5))))])),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now());
                    if (time != null && mounted) {
                      setState(() {
                        _birthTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: theme.colorScheme.primary,
                          size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _birthTime ?? '시간',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _birthTime != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withOpacity(0.5))))])))],
          const SizedBox(height: 32),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedCelebrity == null) {
                  Toast.error(context, '유명인을 선택해주세요');
                  return;
                }
                if (_birthDate == null) {
                  Toast.error(context, '생년월일을 선택해주세요');
                  return;
                }
                
                widget.onSubmit({
                  'celebrity_id': _selectedCelebrity!.id,
                  'celebrity_name': _selectedCelebrity!.name,
                  'category': _selectedCelebrity!.category.displayName,
                  'celebrity_age': _selectedCelebrity!.age,
                  'celebrity_zodiac': _selectedCelebrity!.zodiacSign,
                  'celebrity_chinese_zodiac': _selectedCelebrity!.chineseZodiac,
                  'celebrity_birth_date': _selectedCelebrity!.birthDate.toIso8601String(),
                  'celebrity_birth_time': _selectedCelebrity!.birthTime,
                  'user_birth_date': _birthDate!.toIso8601String(),
                  'user_birth_time': null});
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: const Text(
                '운세 보기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))))]);
  }

  Widget _buildCategoryChip(CelebrityCategory? category, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategory == category;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface));
  }

  Widget _buildPlaceholderImage(Celebrity celebrity, ThemeData theme) {
    // Use dummy image URL or generate placeholder
    final imageUrl = _celebrityImages[celebrity.id];
    
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: theme.colorScheme.primary.withOpacity(0.2),
          child: Center(
            child: Text(
              celebrity.name.substring(0, 2),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 32,
                fontWeight: FontWeight.bold))));
    }
    
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.2),
      child: Center(
        child: Text(
          celebrity.name.substring(0, 2),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 32,
            fontWeight: FontWeight.bold))));
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
    final compatibility = result.details?['compatibility'] as Map<String, dynamic>?;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Celebrity Info Card
          if (celebrityInfo != null) ...[
            GlassContainer(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05)]),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Celebrity Profile Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: celebrityInfo['profile_image'] != null
                              ? CachedNetworkImage(
                                  imageUrl: celebrityInfo['profile_image'],
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    child: Center(
                                      child: Text(
                                        celebrityInfo['name']?.substring(0, 2) ?? '?',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold))))
                              : Container(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  child: Center(
                                    child: Text(
                                      celebrityInfo['name']?.substring(0, 2) ?? '?',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold))))),
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
                                color: theme.colorScheme.primary)),
                            const SizedBox(height: 4),
                            Text(
                              '${celebrityInfo['zodiac'] ?? ''} • ${celebrityInfo['chinese_zodiac'] ?? ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7)))]))])),
                  const SizedBox(height: 16),
                  Text(
                    celebrityInfo['description'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: _getFontSize(fontSize),
                      height: 1.6))])),
            const SizedBox(height: 20)],
          
          // Score Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCard(
                context,
                '오늘',
                result.details?['todayScore'] ?? '',
                Icons.today,
                theme.colorScheme.primary),
              _buildScoreCard(
                context,
                '이번 주',
                result.details?['weeklyScore'] ?? '',
                Icons.calendar_view_week,
                theme.colorScheme.secondary),
              _buildScoreCard(
                context,
                '이번 달',
                result.details?['monthlyScore'] ?? '',
                Icons.calendar_month,
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
                      color: theme.colorScheme.primary,
                      size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '종합 운세',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                Text(
                  result.details?['summary'] ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: _getFontSize(fontSize),
                    height: 1.6))])),
          const SizedBox(height: 20),
          
          // Lucky Items Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildLuckyItemCard(
                context,
                '행운의 시간',
                result.details?['luckyTime'] ?? '',
                Icons.access_time,
                theme.colorScheme.primary.withOpacity(0.1)),
              _buildLuckyItemCard(
                context,
                '행운의 색상',
                result.details?['luckyColor'] ?? '',
                Icons.palette,
                theme.colorScheme.secondary.withOpacity(0.1)),
              _buildLuckyItemCard(
                context,
                '행운의 아이템',
                result.details?['luckyItem'] ?? '',
                Icons.diamond,
                theme.colorScheme.tertiary.withOpacity(0.1)),
              _buildLuckyItemCard(
                context,
                '행운의 방향',
                result.details?['luckyDirection'] ?? '',
                Icons.explore,
                theme.colorScheme.error.withOpacity(0.1))]),
          const SizedBox(height: 20),
          
          // Compatibility Section
          if (compatibility != null) ...[
            GlassContainer(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink.withOpacity(0.1),
                  Colors.purple.withOpacity(0.05)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, 
                        color: Colors.pink,
                        size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '궁합',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  if (compatibility['best_match'] != null) ...[
                    Text(
                      '궁합: ${compatibility['best_match']}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: _getFontSize(fontSize),
                        color: Colors.pink,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8)],
                  if (compatibility['worst_match'] != null) ...[
                    Text(
                      '궁합: ${compatibility['worst_match']}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: _getFontSize(fontSize),
                        color: theme.colorScheme.error)),
                    const SizedBox(height: 8)],
                  if (compatibility['description'] != null) ...[
                    Text(
                      compatibility['description'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: _getFontSize(fontSize),
                        height: 1.5)]])),
            const SizedBox(height: 20)],
          
          // Advice Section
          if (result.details?['advice'] != null) ...[
            GlassContainer(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.primary.withOpacity(0.02)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, 
                        color: theme.colorScheme.primary,
                        size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '조언',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  Text(
                    result.details?['advice'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: _getFontSize(fontSize),
                      height: 1.6))])),
            const SizedBox(height: 20)],
          
          // Predictions Section
          if (predictions != null) ...[
            Text(
              '분야별 운세',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPredictionCard(
              context,
              '연애운',
              predictions['love'] ?? '',
              Icons.favorite_border,
              const Color(0xFFFF6B9D),
              _getFontSize(fontSize)),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              '사업/경력운',
              predictions['career'] ?? '',
              Icons.trending_up,
              const Color(0xFF4ECDC4),
              _getFontSize(fontSize)),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              '재물운',
              predictions['wealth'] ?? '',
              Icons.attach_money,
              const Color(0xFFF7B731),
              _getFontSize(fontSize)),
            const SizedBox(height: 12),
            _buildPredictionCard(
              context,
              '건강운',
              predictions['health'] ?? '',
              Icons.favorite,
              const Color(0xFF5F27CD),
              _getFontSize(fontSize))]]));
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
      height: 100,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            score,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color)),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6)))]));
  }

  Widget _buildLuckyItemCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color backgroundColor) {
    final theme = Theme.of(context);
    return GlassContainer(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor,
          backgroundColor.withOpacity(0.5)]),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)])]));
  }

  Widget _buildPredictionCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
    double fontSize) {
    final theme = Theme.of(context);
    return GlassContainer(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
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
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color))]),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              height: 1.5))])));
  }
}