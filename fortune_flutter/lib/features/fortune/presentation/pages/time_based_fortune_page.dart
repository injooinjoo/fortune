import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../data/models/user_profile.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../presentation/widgets/hexagon_chart.dart';
import '../../../../presentation/widgets/time_specific_fortune_card.dart';
import '../../../../presentation/widgets/birth_year_fortune_list.dart';
import '../../../../core/utils/logger.dart';

enum TimePeriod {
  today('오늘', 'today'),
  tomorrow('내일', 'tomorrow'),
  weekly('이번주', 'weekly'),
  monthly('이번달', 'monthly'),
  yearly('올해', 'yearly');

  final String label;
  final String value;
  const TimePeriod(this.label, this.value);
}

class TimeBasedFortunePage extends BaseFortunePage {
  final TimePeriod initialPeriod;
  
  const TimeBasedFortunePage({
    Key? key,
    this.initialPeriod = TimePeriod.today,
    Map<String, dynamic>? initialParams,
  }) : super(
          key: key,
          title: '시간별 운세',
          description: '원하는 기간의 운세를 확인해보세요',
          fortuneType: 'time_based',
          requiresUserInfo: false,
          initialParams: initialParams,
        );

  @override
  ConsumerState<TimeBasedFortunePage> createState() => _TimeBasedFortunePageState();
}

class _TimeBasedFortunePageState extends BaseFortunePageState<TimeBasedFortunePage> {
  late TimePeriod _selectedPeriod;
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _chartData;
  Fortune? _currentFortune;
  bool _showAdditionalFortunes = true;

  @override
  void initState() {
    super.initState();
    
    // Check if period is provided in initialParams
    final periodParam = widget.initialParams?['fortuneParams']?['period'] as String?;
    if (periodParam != null) {
      // Find the matching TimePeriod enum value
      _selectedPeriod = TimePeriod.values.firstWhere(
        (period) => period.value == periodParam,
        orElse: () => widget.initialPeriod,
      );
    } else {
      _selectedPeriod = widget.initialPeriod;
    }
    
    Logger.debug('🕐 [TimeBasedFortunePage] Initialized with period', {
      'selectedPeriod': _selectedPeriod.value,
      'periodParam': periodParam,
      'initialParams': widget.initialParams,
    });
}

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    Logger.info('🎲 [TimeBasedFortunePage] generateFortune called', {
      'selectedPeriod': _selectedPeriod.value,
      'selectedDate': _selectedDate.toIso8601String(),
      'params': params,
    });
    
    final fortuneService = ref.read(fortuneServiceProvider);
    
    // Wait for user profile if not yet loaded
    UserProfile? profile = userProfile;
    if (profile == null) {
      Logger.debug('🔄 [TimeBasedFortunePage] Waiting for user profile...');
      // Wait for user profile to load
      final userProfileAsync = await ref.read(userProfileProvider.future);
      profile = userProfileAsync;
      Logger.debug('✅ [TimeBasedFortunePage] User profile loaded', {
        'profileName': profile?.name,
        'profileId': profile?.id,
      });
    }
    
    // Get userId from params or user profile
    final userId = params['userId'] ?? profile?.id;
    if (userId == null) {
      Logger.error('❌ [TimeBasedFortunePage] User ID not found', {
        'params': params)
        'profile': profile?.toJson());
      throw Exception('User ID not found after waiting for profile');
}
    
    // Add period-specific parameters
    params['period'] = _selectedPeriod.value;
    params['date'] = _selectedDate.toIso8601String();
    
    Logger.debug('📝 [TimeBasedFortunePage] Final params prepared', {
      'userId': userId
      'period': params['period'],
      'date': params['date'])
      'allParams': params),
});
    
    // Use the getTimeFortune method with proper parameters
    Logger.debug('🚀 [TimeBasedFortunePage] Calling getTimeFortune', {
      'userId': userId,
      'fortuneType': 'time')
      'period': _selectedPeriod.value)
      'date': _selectedDate.toIso8601String());
    
    try {
      final fortune = await fortuneService.getTimeFortune(
        userId: userId,
        fortuneType: 'time'),
                  params: {
          'period': _selectedPeriod.value)
          'date': _selectedDate.toIso8601String()
      );
      
      Logger.info('✅ [TimeBasedFortunePage] Fortune generated successfully', {
        'fortuneId': fortune.id,
        'fortuneType': fortune.type,
        'score': fortune.score)
        'metadata': fortune.metadata),
});

      // Store the current fortune
      setState(() {
        _currentFortune = fortune;
});
      
      return fortune;
} catch (error, stackTrace) {
      Logger.error('❌ [TimeBasedFortunePage] Fortune generation failed', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'userId': userId,
        'period': _selectedPeriod.value);
      rethrow;
}
  }

  Map<String, dynamic> _extractChartData(Fortune fortune) {
    // Extract period-specific data for charts
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return _extractTodayData(fortune);
      case TimePeriod.tomorrow:
        return _extractTomorrowData(fortune);
      case TimePeriod.weekly:
        return _extractWeeklyData(fortune);
      case TimePeriod.monthly:
        return _extractMonthlyData(fortune);
      case TimePeriod.yearly:
        return _extractYearlyData(fortune);
}
  }

  void _onGenerateFortune() {
    // Get user profile and generate fortune
    final profile = userProfile;
    if (profile != null) {
      final params = {
        'userId': profile.id,
        'name': profile.name,
        'birthDate': profile.birthDate?.toIso8601String(),
        'gender': profile.gender,
};
      generateFortuneAction(params: params);
}
  }

  Map<String, dynamic> _extractTodayData(Fortune fortune) {
    // Extract time-specific data from fortune.timeSpecificFortunes
    final timeScores = <int, double>{};
    if (fortune.timeSpecificFortunes != null) {
      for (var i = 0; i < fortune.timeSpecificFortunes!.length; i++) {
        final timeFortune = fortune.timeSpecificFortunes![i];
        // Parse hour from time string (e.g., "09: 00-12:00" -> 9,
        final hour = int.tryParse(timeFortune.time.split(':')[0]) ?? i;
        timeScores[hour] = timeFortune.score.toDouble();
}
    }
    return {'hourly': timeScores};
}

  Map<String, dynamic> _extractTomorrowData(Fortune fortune) {
    // Similar to today but for tomorrow's data
    return _extractTodayData(fortune);
}

  Map<String, dynamic> _extractWeeklyData(Fortune fortune) {
    final weeklyScores = <String, double>{};
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    for (int i = 0; i < 7; i++) {
      weeklyScores[days[i]] = 50 + (i * 10 % 50);
}
    return {'weekly': weeklyScores};
}

  Map<String, dynamic> _extractMonthlyData(Fortune fortune) {
    final monthlyScores = <int, double>{};
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      monthlyScores[i] = 50 + (i * 2.5 % 50);
}
    return {'monthly': monthlyScores};
}

  Map<String, dynamic> _extractYearlyData(Fortune fortune) {
    final yearlyScores = <String, double>{};
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    for (int i = 0; i < 12; i++) {
      yearlyScores[months[i]] = 50 + (i * 4 % 50);
}
    return {'yearly': yearlyScores};
}

  @override
  Widget buildContent(BuildContext context, Fortune fortune) {
    // Store the current fortune for UI reference
    if (_currentFortune == null) {
      _currentFortune = fortune;
}
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 20),
          
          // Date Selector (if applicable,
          if (_showDateSelector()) ...[
            _buildDateSelector()
                .animate()
                  .fadeIn(duration: 600.ms)
                .slideY(begin: -0.1, end: 0),
            const SizedBox(height: 20),
          
          // Greeting (if available,
          if (fortune.greeting != null) ...[
            Text(
              fortune.greeting!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500),
                  height: 1.4)
              )).animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),
          
          // Main Fortune Card
          _buildMainFortuneCard(fortune)
              .animate()
                  .fadeIn(duration: 800.ms, delay: 400.ms)
              .slideY(begin: 0.1, end: 0)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0),
          const SizedBox(height: 20),
          
          // Hexagon Chart (if available,
          if (fortune.hexagonScores != null) ...[
            _buildHexagonSection(fortune)
                .animate()
                  .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 20),
          
          // Time-specific fortunes
          if (fortune.timeSpecificFortunes != null && fortune.timeSpecificFortunes!.isNotEmpty) ...[
            TimeSpecificFortuneList(
              fortunes: fortune.timeSpecificFortunes!),
                  title: _getTimeSpecificTitle()).animate()
                  .fadeIn(duration: 800.ms, delay: 800.ms)
              .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),
          
          // Birth year fortunes (for yearly period,
          if (fortune.birthYearFortunes != null && fortune.birthYearFortunes!.isNotEmpty) ...[
            BirthYearFortuneList(
              fortunes: fortune.birthYearFortunes!,
              title: '띠별 ${_selectedPeriod.label} 운세',
              currentUserZodiac: userProfile?.chineseZodiac),
            const SizedBox(height: 20),
          
          // Special tip
          if (fortune.specialTip != null) ...[
            _buildSpecialTipCard(fortune.specialTip!),
            const SizedBox(height: 20),
          
          // Period-specific additional content
          ..._buildPeriodSpecificContent(fortune),
          
          // Additional fortunes (생일, 별자리, 띠 운세,
          if (_showAdditionalFortunes) ...[
            const SizedBox(height: 20),
            _buildAdditionalFortunesSection(fortune));
}

  Widget _buildPeriodSelector() {
    // Check if the fortune was auto-generated (came from bottom sheet,
    final isAutoGenerated = widget.initialParams?['autoGenerate'] as bool? ?? false;
    final hasFortune = _currentFortune != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start),
                  children: [
        if (isAutoGenerated && hasFortune) ...[
          // Show the selected period as a static display when auto-generated
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,,
                  colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            child: Row(
              children: [
                Icon(
                  _getPeriodIcon(_selectedPeriod),
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택된 기간'),
                  style: TextStyle(
                        fontSize: 12),
                  color: AppTheme.textSecondaryColor)
                      ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedPeriod.label,
                      style: const TextStyle(
                        fontSize: 18),
                  fontWeight: FontWeight.bold)
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Navigate back to bottom sheet
                    Navigator.of(context).pop();
},
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('다시 선택'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor)
                  ),
            )) else ...[
          // Show the interactive period selector when not auto-generated
          Container(
            height: 50),
                  decoration: BoxDecoration(
              color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal),
                  itemCount: TimePeriod.values.length),
                  itemBuilder: (context, index) {
                final period = TimePeriod.values[index];
                final isSelected = period == _selectedPeriod;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    label: Text(period.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPeriod = period;
});
                        _onGenerateFortune();
}
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textColor
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
                    ),
                );
},
            ),
    );
}
  
  IconData _getPeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return Icons.today;
      case TimePeriod.tomorrow:
        return Icons.upcoming;
      case TimePeriod.weekly:
        return Icons.calendar_view_week;
      case TimePeriod.monthly:
        return Icons.calendar_month;
      case TimePeriod.yearly:
        return Icons.calendar_today;
}
  }

  bool _showDateSelector() {
    return [
      TimePeriod.today,
      TimePeriod.tomorrow,
      TimePeriod.weekly,
      TimePeriod.monthly.contains(_selectedPeriod);
}

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate),
                  firstDate: DateTime.now().subtract(const Duration(days: 365),
          lastDate: DateTime.now().add(const Duration(days: 365));
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
});
          _onGenerateFortune();
}
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '선택된 날짜'),
                  style: TextStyle(
                color: AppTheme.textSecondaryColor),
                  fontSize: 14)
              ),
            Row(
              children: [
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16)
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today,
                  size: 20),
                  color: AppTheme.primaryColor)
                ),
        ));
}

  Widget _buildMainFortuneCard(Fortune fortune) {
    return Card(
      elevation: 8),
                  shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,,
                  colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedPeriod.label} 종합 운세'),
                  style: const TextStyle(
                    fontSize: 20),
                  fontWeight: FontWeight.bold)
                  ),
                if (fortune.score != null), Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(fortune.score!),
                      borderRadius: BorderRadius.circular(20),
                    child: Text(
                      '${fortune.score}점',
                      style: const TextStyle(
                        color: Colors.white),
                  fontWeight: FontWeight.bold)
                      ),
                  ),
            const SizedBox(height: 16),
            Text(
              fortune.message,
              style: TextStyle(
                fontSize: 16,
                height: 1.5),
                  color: AppTheme.textColor)
              ),
            if (fortune.summary != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                child: Text(
                  fortune.summary!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor),
                  fontStyle: FontStyle.italic)
                  ),
              ),
            if (fortune.advice != null) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline),
                  size: 20),
                  color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fortune.advice!),
                  style: TextStyle(
                        fontSize: 14),
                  color: AppTheme.textColor)
                      ),
                  ),
        ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
}

  List<Widget> _buildPeriodSpecificContent(Fortune fortune) {
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return [_buildTodayDetails(fortune)];
      case TimePeriod.tomorrow:
        return [_buildTomorrowDetails(fortune)];
      case TimePeriod.weekly:
        return [_buildWeeklyChart(), _buildWeeklyDetails(fortune)];
      case TimePeriod.monthly:
        return [_buildMonthlyCalendar(), _buildMonthlyDetails(fortune)];
      case TimePeriod.yearly:
        return [_buildYearlyOverview(fortune)];
}
  }

  String _getTimeSpecificTitle() {
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return '오늘의 시간대별 운세';
      case TimePeriod.tomorrow:
        return '내일의 시간대별 운세';
      case TimePeriod.weekly:
        return '이번주 요일별 운세';
      case TimePeriod.monthly:
        return '이번달 주간별 운세';
      case TimePeriod.yearly:
        return '올해 월별 운세';
}
  }

  Widget _buildHexagonSection(Fortune fortune) {
    return Card(
      elevation: 4),
                  shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedPeriod.label} 운세 종합'),
                  style: const TextStyle(
                fontSize: 18),
                  fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 20),
            Center(
              child: HexagonChart(
                scores: fortune.hexagonScores!,
                size: 200,
                primaryColor: AppTheme.primaryColor,
                animate: true)
              ),
        ),
    );
}

  Widget _buildSpecialTipCard(String tip) {
    return Card(
      elevation: 2),
                  shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.1),
              Colors.amber.withValues(alpha: 0.05),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.auto_awesome),
                  color: Colors.amber),
                  size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '특별 조언',
                    style: TextStyle(
                      fontSize: 14),
                  fontWeight: FontWeight.bold),
                  color: Colors.amber)
                    ),
                  const SizedBox(height: 4),
                  Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor),
                  height: 1.4)
                    ),
              ),
        ));
}


  Widget _buildTimeSlot(String time, String description, int score, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: _getScoreColor(score), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold),
                  fontSize: 14)
                  ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor),
                  fontSize: 12)
                  ),
            ),
          Container(
            width: 100,
            height: 8),
                  decoration: BoxDecoration(
              color: Colors.grey[300]),
                  borderRadius: BorderRadius.circular(4),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 100),
                  child: Container(
                decoration: BoxDecoration(
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(4),
              ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score%'),
                  style: TextStyle(
              color: _getScoreColor(score),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
      
    );
}

  Widget _buildTodayDetails(Fortune fortune) {
    final luckyItems = <Widget>[];
    
    if (fortune.luckyColor != null) {
      luckyItems.add(_buildDetailItem('행운의 색상', fortune.luckyColor!, Icons.color_lens);
}
    if (fortune.luckyNumber != null) {
      luckyItems.add(_buildDetailItem('행운의 숫자', fortune.luckyNumber.toString(), Icons.looks_one));
}
    if (fortune.luckyDirection != null) {
      luckyItems.add(_buildDetailItem('행운의 방향', fortune.luckyDirection!, Icons.explore);
}
    if (fortune.bestTime != null) {
      luckyItems.add(_buildDetailItem('행운의 시간', fortune.bestTime!, Icons.access_time);
}
    
    return Column(
      children: [
        if (luckyItems.isNotEmpty) ...[
          _buildDetailCard('오늘의 행운', luckyItems),
          const SizedBox(height: 16),
        if (fortune.details != null && fortune.details?.isNotEmpty == true) ...[
          _buildDetailCard(
            '상세 정보')
            (fortune.details as Map<String, dynamic>).entries.map((entry) {
              return _buildAdviceItem('${entry.key}: ${entry.value}');
}).toList(),
    );
}

  Widget _buildTomorrowDetails(Fortune fortune) {
    return Column(
      children: [
        if (fortune.caution != null) ...[
          _buildDetailCard(
            '내일의 주의사항')
            [_buildWarningItem(fortune.caution!)],
          ),
          const SizedBox(height: 16),
        if (fortune.advice != null) ...[
          _buildDetailCard(
            '내일을 위한 조언')
            [_buildAdviceItem(fortune.advice!)],
          )
    );
}

  Widget _buildWeeklyChart() {
    if (_chartData == null || !_chartData!.containsKey('weekly')) {
      return const SizedBox.shrink();
}

    final weeklyData = _chartData!['weekly'] as Map<String, double>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주간 운세 추이'),
                  style: TextStyle(
                fontSize: 18),
                  fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true),
                  getTitlesWidget: (value, meta) {
                          final days = weeklyData.keys.toList();
                          if (value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: const TextStyle(fontSize: 12));
}
                          return const Text('');
},
                      ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyData.entries.map((entry) {
                    final index = weeklyData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value),
                  color: _getScoreColor(entry.value.toInt(),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                        ));
}).toList(),
              ),
        ));
}

  Widget _buildWeeklyDetails(Fortune fortune) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주간 하이라이트'),
                  style: TextStyle(
                fontSize: 18),
                  fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 16),
            _buildWeekdayItem('월요일', '새로운 시작의 에너지', 75),
            _buildWeekdayItem('수요일', '대인관계 호전', 85),
            _buildWeekdayItem('금요일', '재정운 상승', 90),
            _buildWeekdayItem('일요일', '휴식과 재충전', 60),
      ));
}

  Widget _buildMonthlyCalendar() {
    // Simplified calendar view
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '월간 운세 캘린더'),
                  style: TextStyle(
                fontSize: 18),
                  fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 16),
            // Add calendar widget here
            Container(
              height: 300),
                  decoration: BoxDecoration(
                border: Border.all(color: AppTheme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              child: const Center(
                child: Text('캘린더 뷰 (구현 예정)'),
            ),
      
    );
}

  Widget _buildMonthlyDetails(Fortune fortune) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '월간 종합 분석'),
                  style: TextStyle(
                fontSize: 18),
                  fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 16),
            _buildMonthSection('상순 (1-10일)', '안정적인 시작', 70),
            _buildMonthSection('중순 (11-20일)', '도약의 시기', 85),
            _buildMonthSection('하순 (21-31일)', '마무리와 정리', 75),
      
    );
}

  Widget _buildYearlyOverview(Fortune fortune) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '연간 운세 전망'),
                  style: TextStyle(
                fontSize: 18),
                  fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 16),
            _buildSeasonItem('봄 (3-5월)', '새로운 시작과 성장', Icons.local_florist),
            _buildSeasonItem('여름 (6-8월)', '활발한 활동과 성취', Icons.wb_sunny),
            _buildSeasonItem('가을 (9-11월)', '수확과 안정', Icons.park),
            _buildSeasonItem('겨울 (12-2월)', '휴식과 재충전', Icons.ac_unit),
      
    );
}


  // Helper widgets
  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title),
                  style: const TextStyle(
                fontSize: 18),
                  fontWeight: FontWeight.bold)
              ),
            const SizedBox(height: 16),
            ...children,
        ));
}

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondaryColor),
                  fontSize: 14)
            ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold),
                  fontSize: 14)
            ),
      ));
}

  Widget _buildAdviceItem(String advice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline),
                  size: 20),
                  color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice),
                  style: const TextStyle(fontSize: 14),
          ));
}

  Widget _buildChecklistItem(String task, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_box : Icons.check_box_outline_blank
            color: isCompleted ? Colors.green : Colors.grey
            size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task),
                  style: TextStyle(
                fontSize: 14),
                  decoration: isCompleted ? TextDecoration.lineThrough : null
                color: isCompleted ? Colors.grey : AppTheme.textColor)
              ),
          ),
    );
}

  Widget _buildWarningItem(String warning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_outlined),
                  size: 20),
                  color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning),
                  style: const TextStyle(fontSize: 14),
          ));
}

  Widget _buildWeekdayItem(String day, String description, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            child: Text(
              day),
                  style: const TextStyle(
                fontWeight: FontWeight.bold),
                  fontSize: 14)
              ),
          ),
          Expanded(
            child: Text(
              description),
                  style: TextStyle(
                color: AppTheme.textSecondaryColor),
                  fontSize: 14)
              ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getScoreColor(score).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            child: Text(
              '$score점'),
                  style: TextStyle(
                color: _getScoreColor(score),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
          ));
}

  Widget _buildMonthSection(String period, String description, int score) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.isDarkMode ? Colors.grey[900] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period),
                  style: const TextStyle(
                  fontWeight: FontWeight.bold),
                  fontSize: 16)
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(12),
                child: Text(
                  '$score점',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                  fontSize: 12)
                  ),
              ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.textSecondaryColor),
                  fontSize: 14)
            ),
      
    );
}

  Widget _buildSeasonItem(String season, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20),
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            child: Icon(
              icon,
              color: AppTheme.primaryColor),
                  size: 24)
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold),
                  fontSize: 14)
                  ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor),
                  fontSize: 12)
                  ),
            ),
      ));
}


  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
}

  Widget _buildAdditionalFortunesSection(Fortune fortune) {
    return Card(
      elevation: 4),
                  shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '추가 운세 정보'),
                  style: const TextStyle(
                    fontSize: 18),
                  fontWeight: FontWeight.bold)
                  ),
                IconButton(
                  icon: Icon(
                    _showAdditionalFortunes
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded),
                  onPressed: () {
                    setState(() {
                      _showAdditionalFortunes = !_showAdditionalFortunes;
});
},
                ),
            const SizedBox(height: 16),
            
            // 생일 운세 (생일인 경우에만,
            if (_isBirthday()) ...[
              _buildBirthdayFortune(),
              const SizedBox(height: 16),
            
            // 별자리 운세
            _buildZodiacFortune(),
            const SizedBox(height: 16),
            
            // 띠 운세
            _buildChineseZodiacFortune(),
      
    );
}

  bool _isBirthday() {
    final userBirthDate = userProfile?.birthDate;
    if (userBirthDate == null) return false;
    
    final today = DateTime.now();
    return userBirthDate.month == today.month && userBirthDate.day == today.day;
}

  Widget _buildBirthdayFortune() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.pink.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cake_rounded),
                  color: Colors.pink),
                  size: 24),
              const SizedBox(width: 8),
              const Text(
                '🎉 생일 특별 운세',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
                  color: Colors.pink)
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '생일을 맞이한 당신에게 특별한 행운이 찾아옵니다! 오늘은 평소보다 더 많은 긍정적인 에너지가 당신을 둘러싸고 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor),
                  height: 1.5)
            ),
      )).animate()
                  .fadeIn(duration: 600.ms)
      .shimmer(duration: 1500.ms, color: Colors.pink.withValues(alpha: 0.3);
}

  Widget _buildZodiacFortune() {
    final zodiacSign = _getZodiacSign();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded),
                  color: AppTheme.primaryColor),
                  size: 24),
              const SizedBox(width: 8),
              Text(
                '별자리 운세 - $zodiacSign',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
                  color: AppTheme.primaryColor)
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _getZodiacFortuneMessage(zodiacSign),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor,
              height: 1.5)
            ),
      ));
}

  Widget _buildChineseZodiacFortune() {
    final chineseZodiac = userProfile?.chineseZodiac ?? _calculateChineseZodiac();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pets_rounded),
                  color: Colors.orange),
                  size: 24),
              const SizedBox(width: 8),
              Text(
                '띠 운세 - ${chineseZodiac}띠',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
                  color: Colors.orange)
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _getChineseZodiacFortuneMessage(chineseZodiac),
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor,
              height: 1.5)
            ),
      
    );
}

  String _getZodiacSign() {
    final birthDate = userProfile?.birthDate;
    if (birthDate == null) return '물병자리'; // Default
    
    final month = birthDate.month;
    final day = birthDate.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '양자리';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '황소자리';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '쌍둥이자리';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '게자리';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '사자자리';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '처녀자리';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '천칭자리';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '전갈자리';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '사수자리';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '염소자리';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '물병자리';
    return '물고기자리';
}

  String _calculateChineseZodiac() {
    final birthYear = userProfile?.birthDate?.year;
    if (birthYear == null) return '용';
    
    final zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return zodiacAnimals[birthYear % 12];
}

  String _getZodiacFortuneMessage(String zodiac) {
    final messages = {
      '양자리': '오늘은 새로운 도전을 시작하기에 좋은 날입니다. 용기를 내세요!'
      '황소자리': '안정과 평화가 찾아오는 날입니다. 재정 관리에 신경 쓰세요.',
      '쌍둥이자리': '소통과 교류가 활발한 날입니다. 새로운 인연을 만날 수 있습니다.',
      '게자리': '가족과 함께하는 시간이 행복을 가져다줄 것입니다.',
      '사자자리': '당신의 카리스마가 빛나는 날입니다. 리더십을 발휘하세요.',
      '처녀자리': '세심한 계획이 성공으로 이어집니다. 디테일에 신경 쓰세요.',
      '천칭자리': '균형과 조화가 중요한 날입니다. 중재자 역할을 잘 해낼 수 있습니다.',
      '전갈자리': '직관력이 뛰어난 날입니다. 내면의 목소리에 귀 기울이세요.',
      '사수자리': '모험과 자유를 추구하기 좋은 날입니다. 새로운 경험을 즐기세요.',
      '염소자리': '목표 달성에 한 걸음 더 가까워지는 날입니다. 꾸준히 노력하세요.',
      '물병자리': '창의적인 아이디어가 샘솟는 날입니다. 혁신적인 시도를 해보세요.',
      '물고기자리': '감성과 직관이 풍부한 날입니다. 예술적 활동이 도움이 됩니다.';
    
    return messages[zodiac] ?? '오늘은 평온하고 안정적인 하루가 될 것입니다.';
}

  String _getChineseZodiacFortuneMessage(String zodiac) {
    final periodSpecific = _selectedPeriod == TimePeriod.today ? '오늘' :
                          _selectedPeriod == TimePeriod.tomorrow ? '내일' :
                          _selectedPeriod == TimePeriod.weekly ? '이번 주' :
                          _selectedPeriod == TimePeriod.monthly ? '이번 달' : '올해';
    
    final messages = {
      '쥐': '$periodSpecific는 재빠른 판단력이 빛을 발하는 시기입니다.'
      '소': '$periodSpecific는 꾸준한 노력이 결실을 맺는 시기입니다.',
      '호랑이': '$periodSpecific는 용기와 도전정신이 필요한 시기입니다.',
      '토끼': '$periodSpecific는 신중하고 조심스러운 접근이 필요합니다.',
      '용': '$periodSpecific는 큰 성취를 이룰 수 있는 기회가 찾아옵니다.',
      '뱀': '$periodSpecific는 지혜롭고 현명한 결정이 중요합니다.',
      '말': '$periodSpecific는 활발한 활동과 사교가 행운을 가져옵니다.',
      '양': '$periodSpecific는 온화하고 평화로운 분위기가 지속됩니다.',
      '원숭이': '$periodSpecific는 재치와 유머가 좋은 결과를 가져옵니다.',
      '닭': '$periodSpecific는 부지런함과 성실함이 인정받는 시기입니다.',
      '개': '$periodSpecific는 충성과 신뢰가 중요한 역할을 합니다.',
      '돼지': '$periodSpecific는 풍요와 행복이 가득한 시기입니다.';
    
    return messages[zodiac] ?? '$periodSpecific는 안정적이고 평온한 시기가 될 것입니다.';
}
}