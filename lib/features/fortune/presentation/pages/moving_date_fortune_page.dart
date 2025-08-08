import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../shared/components/app_header.dart' show FontSize;
import 'package:table_calendar/table_calendar.dart';

class MovingDateFortunePage extends ConsumerWidget {
  const MovingDateFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseFortunePageV2(
      title: '이사 날짜 운세',
      fortuneType: 'moving-date',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
      inputBuilder: (context, onSubmit) => _MovingDateInputForm(onSubmit: onSubmit),
      resultBuilder: (context, result, onShare) => _MovingDateFortuneResult(
        result: result,
        onShare: onShare));
  }
}

class _MovingDateInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const _MovingDateInputForm({required this.onSubmit});

  @override
  State<_MovingDateInputForm> createState() => _MovingDateInputFormState();
}

class _MovingDateInputFormState extends State<_MovingDateInputForm> {
  final _nameController = TextEditingController();
  final _fromAddressController = TextEditingController();
  final _toAddressController = TextEditingController();
  DateTime? _birthDate;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedUrgency;
  
  final List<String> _urgencyLevels = [
    '매우 급함 (1개월 이내)',
    '급함 (2개월 이내)',
    '보통 (3개월 이내)',
    '여유 있음 (6개월 이내)',
    '매우 여유 있음 (1년 이내)'];

  @override
  void dispose() {
    _nameController.dispose();
    _fromAddressController.dispose();
    _toAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF667EEA))),
          child: child!);
      }
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이사 가능한 날짜를 선택하시면\n최적의 이사 날짜를 추천해드립니다.',),
          style: theme.textTheme.bodyLarge?.copyWith()
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5),
        const SizedBox(height: 24),
        
        // Name Input
        Text(
          '이름',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '이름을 입력하세요',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)))),
        const SizedBox(height: 20),
        
        // Birth Date Selection
        Text(
          '생년월일',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectBirthDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16) vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary.withOpacity(0.7),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                      : '생년월일을 선택하세요',
                  style: theme.textTheme.bodyLarge?.copyWith()
                    color: _birthDate != null 
                        ? theme.colorScheme.onSurface 
                        : theme.colorScheme.onSurface.withOpacity(0.5)))]))),
        const SizedBox(height: 20),
        
        // From Address
        Text(
          '출발지 (현재 거주지)',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _fromAddressController,
          decoration: InputDecoration(
            hintText: '예: 서울시 강남구',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)))),
        const SizedBox(height: 20),
        
        // To Address
        Text(
          '도착지 (이사할 지역)',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _toAddressController,
          decoration: InputDecoration(
            hintText: '예: 경기도 성남시',
            prefixIcon: const Icon(Icons.location_searching),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12))),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)))),
        const SizedBox(height: 20),
        
        // Urgency Selection
        Text(
          '이사 급한 정도',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Column(
          children: _urgencyLevels.map((urgency) {
            final isSelected = _selectedUrgency == urgency;
            return RadioListTile<String>(
              title: Text(urgency),
              value: urgency,
              groupValue: _selectedUrgency,
              onChanged: (value) {
                setState(() {
                  _selectedUrgency = value;
                });
              },
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero);
          }).toList()),
        const SizedBox(height: 20),
        
        // Date Range Selection
        Text(
          '이사 가능 기간',),
          style: theme.textTheme.titleMedium?.copyWith()
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedStartDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365));
                  if (picked != null) {
                    setState(() {
                      _selectedStartDate = picked;
                      if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked), {
                        _selectedEndDate = null;
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    _selectedStartDate != null
                        ? '${_selectedStartDate!.month}/${_selectedStartDate!.day}'
                        : '시작일',
                    style: theme.textTheme.bodyMedium),
                    textAlign: TextAlign.center)))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('~')),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now(),
                    firstDate: _selectedStartDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365));
                  if (picked != null) {
                    setState(() {
                      _selectedEndDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    _selectedEndDate != null
                        ? '${_selectedEndDate!.month}/${_selectedEndDate!.day}'
                        : '종료일',
                    style: theme.textTheme.bodyMedium),
                    textAlign: TextAlign.center))))]),
        const SizedBox(height: 32),
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이름을 입력해주세요'));
                return;
              }
              if (_birthDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('생년월일을 선택해주세요'));
                return;
              }
              if (_fromAddressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('출발지를 입력해주세요'));
                return;
              }
              if (_toAddressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('도착지를 입력해주세요'));
                return;
              }
              
              widget.onSubmit({
                'name': _nameController.text,
                'birthDate': _birthDate!.toIso8601String(),
                'fromAddress': _fromAddressController.text,
                'toAddress': _toAddressController.text,
                'urgency': _selectedUrgency ?? '보통 (3개월 이내)',
                'startDate': _selectedStartDate?.toIso8601String(),
                'endDate': null});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              backgroundColor: theme.colorScheme.primary),
            child: Text(
              '최적의 이사 날짜 확인하기',),
              style: theme.textTheme.titleMedium?.copyWith()
                color: Colors.white,
                fontWeight: FontWeight.bold))))]
    );
  }
}

class _MovingDateFortuneResult extends ConsumerStatefulWidget {
  final FortuneResult result;
  final VoidCallback onShare;

  const _MovingDateFortuneResult({
    required this.result,
    required this.onShare});

  @override
  ConsumerState<_MovingDateFortuneResult> createState() => _MovingDateFortuneResultState();
}

class _MovingDateFortuneResultState extends ConsumerState<_MovingDateFortuneResult> {
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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Sample lucky dates from result
  late final Map<DateTime, int> _luckyDates;
  
  @override
  void initState() {
    super.initState();
    _luckyDates = _extractLuckyDates();
  }
  
  Map<DateTime, int> _extractLuckyDates() {
    final Map<DateTime, int> dates = {};
    final luckyDatesInfo = widget.result.additionalInfo?['luckyDates'] ?? {};
    
    // Convert from API response to DateTime map
    if (luckyDatesInfo is Map) {
      luckyDatesInfo.forEach((dateStr, score) {
        try {
          final date = DateTime.parse(dateStr);
          dates[DateTime(date.year, date.month, date.day)] = score;
        } catch (e) {
          // Handle parsing error
        }
      });
    }
    
    return dates;
  }
  
  int? _getDateScore(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _luckyDates[normalizedDay];
  }
  
  Color _getScoreColor(int? score) {
    if (score == null) return Colors.grey.withOpacity(0.3)
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    
    // Extract best dates from result
    final bestDate = widget.result.additionalInfo?['bestDate'] ?? {};
    final goodDates = widget.result.additionalInfo?['goodDates'] ?? [];
    final avoidDates = widget.result.additionalInfo?['avoidDates'] ?? [];
    final monthlyAnalysis = widget.result.additionalInfo?['monthlyAnalysis'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Best Date Card
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                      child: Icon(
                        Icons.star,
                        color: theme.colorScheme.primary,
                        size: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '최고의 이사 날짜',),
                            style: theme.textTheme.titleMedium?.copyWith()
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            bestDate['date'] ?? '날짜 미정',
                            style: theme.textTheme.headlineSmall?.copyWith()
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20 + _getFontSizeOffset(fontSize)))]))]),
                if (bestDate['reason'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    bestDate['reason'],
                    style: theme.textTheme.bodyLarge?.copyWith()
                      height: 1.6,
                      fontSize: 14 + _getFontSizeOffset(fontSize)))],
                if (bestDate['score'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '적합도:',),
                        style: theme.textTheme.bodyMedium?.copyWith()
                          fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(bestDate['score'],
                          borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${bestDate['score']}점',
                          style: TextStyle(
                            color: _getScoreColor(bestDate['score'],
                            fontWeight: FontWeight.bold)))])]]))),
        const SizedBox(height: 20),
        
        // Calendar View
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '월별 이사 운세 캘린더',),
                  style: theme.textTheme.titleMedium?.copyWith()
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final score = _getDateScore(day);
                      if (score != null) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(score).withOpacity(0.3),
                            shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: _getScoreColor(score),
                                fontWeight: FontWeight.bold))));
                      }
                      return null;
                    }),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: theme.colorScheme.error),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle)),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem('최고': null,
                    _buildLegendItem('좋음': null,
                    _buildLegendItem('보통': null,
                    _buildLegendItem('피함')])]))),
        const SizedBox(height: 20),
        
        // Good Dates List
        if (goodDates.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        color: Colors.blue,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '추천 날짜들',),
                        style: theme.textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  ...goodDates.map((date) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.blue,
                          size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            date['date'] ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith()
                              fontSize: 14 + _getFontSizeOffset(fontSize)))),
                        if (date['score'] != null)
                          Text(
                            '${date['score']}점',
                            style: theme.textTheme.bodyMedium?.copyWith()
                              color: Colors.blue,
                              fontWeight: FontWeight.bold))])).toList()]))),
          const SizedBox(height: 20)],
        
        // Dates to Avoid
        if (avoidDates.isNotEmpty) ...[
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.orange,
                        size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '피해야 할 날짜',),
                        style: theme.textTheme.titleMedium?.copyWith()
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  ...avoidDates.map((date) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date['date'] ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith()
                                  fontSize: 14 + _getFontSizeOffset(fontSize))),
                              if (date['reason'] != null)
                                Text(
                                  date['reason'],
                                  style: theme.textTheme.bodySmall?.copyWith()
                                    color: theme.colorScheme.onSurface.withOpacity(0.7)))]))])).toList()]))),
          const SizedBox(height: 20)],
        
        // Share Button
        Center(
          child: OutlinedButton.icon(
            onPressed: widget.onShare,
            icon: const Icon(Icons.share),
            label: const Text('운세 공유하기'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)))))]
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600))]
    );
  }
}