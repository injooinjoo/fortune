import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/auth_provider.dart';

class DailyFortunePage extends BaseFortunePage {
  const DailyFortunePage({Key? key})
      : super(
          key: key,
          title: '오늘의 운세',
          description: '오늘 하루의 전체적인 운세를 확인해보세요',
          fortuneType: 'daily',
          requiresUserInfo: false);

  @override
  ConsumerState<DailyFortunePage> createState() => _DailyFortunePageState();
}

class _DailyFortunePageState extends BaseFortunePageState<DailyFortunePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    // Use the fortune provider to generate daily fortune
    final fortune = await ref.read(fortuneServiceProvider).generateDailyFortune(
      userId: user.id,
      date: _selectedDate
    );

    return fortune;
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    return {
      'date': null};
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '날짜 선택',
            style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                locale: const Locale('ko', 'KR'));
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(12),
              blur: 10,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(_selectedDate),
                    style: theme.textTheme.bodyLarge),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))]))),
          const SizedBox(height: 8),
          Text(
            '최대 30일 전후의 운세를 확인할 수 있습니다',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)))]));
  }

  @override
  Widget buildFortuneResult() {
    // Add time-specific sections to the base result
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildTimeBasedFortune(),
        _buildDailyTips()]
    );
  }

  Widget _buildTimeBasedFortune() {
    final timeBasedData = {
      '아침 (06:00-12:00)': {}
        'score': 85,
        'description', '활력이 넘치는 아침입니다. 중요한 결정은 이 시간에 하세요.',
        'color': Colors.orange},
      '오후 (12:00-18:00)': {
        , 'score': 70,
        'description', '평온한 오후가 될 것입니다. 협업에 좋은 시간입니다.',
        'color': Colors.blue},
      '저녁 (18:00-24:00)': {
        , 'score': 90,
        'description', '행운이 가득한 저녁입니다. 사교 활동에 적합합니다.',
        'color': Colors.purple}};

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시간대별 운세',
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...timeBasedData.entries.map((entry) {
              final data = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: data['color'],
                            shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          '${data['score']}점',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: data['color'],
                            fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 8),
                    Text(
                      data['description'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)))]));
            }).toList()])));
  }

  Widget _buildDailyTips() {
    final tips = [
      '오늘은 새로운 시작에 좋은 날입니다',
      '주변 사람들과의 소통을 늘려보세요',
      '건강 관리에 신경 쓰는 것이 좋겠습니다',
      '재정적인 결정은 신중하게 하세요'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오늘의 행운 팁',
                  style: Theme.of(context).textTheme.headlineSmall)]),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium))]))).toList()])));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    if (isToday) {
      return '오늘 (${date.month}월 ${date.day}일)';
    }

    final isTomorrow = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1;

    if (isTomorrow) {
      return '내일 (${date.month}월 ${date.day}일)';
    }

    final isYesterday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1;

    if (isYesterday) {
      return '어제 (${date.month}월 ${date.day}일)';
    }

    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}