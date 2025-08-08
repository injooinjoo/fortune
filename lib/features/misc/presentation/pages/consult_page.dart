import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/font_size_provider.dart';

// Expert data model
class Expert {
  final String id;
  final String name;
  final String title;
  final String imageUrl;
  final double rating;
  final int price;
  final List<String> specialties;
  final bool isAvailable;

  const Expert({
    required this.id,
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.specialties,
    required this.isAvailable});
}

// Mock data
final List<Expert> mockExperts = [
  const Expert(
    id: '1',
    name: '서현 타로마스터',
    title: '타로 상담 10년 경력',
    imageUrl: 'https://placehold.co/128x128/png',
    rating: 4.9,
    price: 50000,
    specialties: ['타로', '연애', '직장'],
    isAvailable: true),
  const Expert(
    id: '2',
    name: '김도사',
    title: '정통 사주팔자 전문',
    imageUrl: 'https://placehold.co/128x128/png',
    rating: 4.8,
    price: 80000,
    specialties: ['사주', '궁합', '작명'],
    isAvailable: true),
  const Expert(
    id: '3',
    name: '명리학 박사',
    title: '30년 전통 명리학',
    imageUrl: 'https://placehold.co/128x128/png',
    rating: 5.0,
    price: 120000,
    specialties: ['명리학', '택일', '풍수'],
    isAvailable: false),
  const Expert(
    id: '4',
    name: '신점 할머니',
    title: '40년 신점 경력',
    imageUrl: 'https://placehold.co/128x128/png',
    rating: 4.7,
    price: 60000,
    specialties: ['신점', '굿', '부적'],
    isAvailable: true)];

// Providers
final selectedExpertProvider = StateProvider<Expert?>((ref) => null);
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<TimeOfDay?>((ref) => null);

class ConsultPage extends ConsumerStatefulWidget {
  const ConsultPage({super.key});

  @override
  ConsumerState<ConsultPage> createState() => _ConsultPageState();
}

class _ConsultPageState extends ConsumerState<ConsultPage> {
  final _messageController = TextEditingController();
  final _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _messageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    }
  }

  void _submitBooking() {
    final expert = ref.read(selectedExpertProvider);
    final date = ref.read(selectedDateProvider);
    final time = ref.read(selectedTimeProvider);

    if (expert == null || date == null || time == null) {
      Toast.show(context, message: '모든 정보를 입력해주세요', type: ToastType.warning);
      return;
    }

    // TODO: Implement actual booking logic
    Toast.show(context, message: '상담 예약이 완료되었습니다', type: ToastType.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppHeader(
        title: '전문가 상담',
        showBackButton: true),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(theme),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildExpertSelection(theme, fontSize.value),
                _buildDateSelection(theme, fontSize.value),
                _buildTimeSelection(theme, fontSize.value),
                _buildConfirmation(theme, fontSize.value)])),
          
          // Navigation Buttons
          _buildNavigationButtons(theme)]));
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 4),
                  Text(
                    _getStepTitle(index),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant))])));
        })));
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return '전문가';
      case 1:
        return '날짜';
      case 2:
        return '시간';
      case 3:
        return '확인';
      default:
        return '';
    }
  }

  Widget _buildExpertSelection(ThemeData theme, double fontSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '전문가를 선택해주세요',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '원하시는 상담 분야의 전문가를 선택하세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 24),
          ...mockExperts.map((expert) => _buildExpertCard(theme, fontSize, expert))]));
  }

  Widget _buildExpertCard(ThemeData theme, double fontSize, Expert expert) {
    final isSelected = ref.watch(selectedExpertProvider) == expert;

    return GestureDetector(
      onTap: expert.isAvailable
          ? () {
              ref.read(selectedExpertProvider.notifier).state = expert;
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Opacity(
          opacity: expert.isAvailable ? 1.0 : 0.5,
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
            child: Row(
              children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHighest),
                child: const Icon(
                  Icons.person,
                  size: 32)),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          expert.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (!expert.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              '예약 불가',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: fontSize - 4,
                                fontWeight: FontWeight.bold)))]),
                    const SizedBox(height: 4),
                    Text(
                      expert.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: fontSize - 2,
                        color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              expert.rating.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: fontSize - 2,
                                fontWeight: FontWeight.bold))]),
                        const SizedBox(width: 16),
                        
                        // Price
                        Text(
                          '₩${expert.price.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},')}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary))]),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: expert.specialties.map((specialty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            specialty,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: fontSize - 4,
                              color: theme.colorScheme.onPrimaryContainer)));
                      }).toList())]))])))));
  }

  Widget _buildDateSelection(ThemeData theme, double fontSize) {
    final selectedDate = ref.watch(selectedDateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상담 날짜를 선택해주세요',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '예약 가능한 날짜를 선택하세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 24),
          
          // Calendar
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: CalendarDatePicker(
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {
                ref.read(selectedDateProvider.notifier).state = date;
              })),
          
          if (selectedDate != null) ...[
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.1)]),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.bold))]))]]));
  }

  Widget _buildTimeSelection(ThemeData theme, double fontSize) {
    final selectedTime = ref.watch(selectedTimeProvider);
    final availableTimes = [
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 17, minute: 0)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상담 시간을 선택해주세요',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '예약 가능한 시간대를 선택하세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 24),
          
          // Time Slots
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: availableTimes.map((time) {
              final isSelected = selectedTime == time;
              
              return GestureDetector(
                onTap: () {
                  ref.read(selectedTimeProvider.notifier).state = time;
                },
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : null,
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            theme.colorScheme.secondary.withOpacity(0.2)])
                      : null,
                  child: Center(
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: fontSize,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : null)))));
            }).toList()),
          
          const SizedBox(height: 24),
          
          // Message Input
          Text(
            '상담 내용',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: fontSize),
            decoration: InputDecoration(
              hintText: '상담하고 싶은 내용을 간단히 적어주세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12))))]));
  }

  Widget _buildConfirmation(ThemeData theme, double fontSize) {
    final expert = ref.watch(selectedExpertProvider);
    final date = ref.watch(selectedDateProvider);
    final time = ref.watch(selectedTimeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약 정보 확인',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '예약 정보를 확인하고 확정해주세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 24),
          
          // Booking Summary
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expert Info
                _buildConfirmationRow(
                  theme,
                  fontSize,
                  '전문가',
                  expert?.name ?? '-',
                  Icons.person_rounded),
                const SizedBox(height: 16),
                
                // Date
                _buildConfirmationRow(
                  theme,
                  fontSize,
                  '날짜',
                  date != null
                      ? '${date.year}년 ${date.month}월 ${date.day}일'
                      : '-',
                  Icons.calendar_today_rounded),
                const SizedBox(height: 16),
                
                // Time
                _buildConfirmationRow(
                  theme,
                  fontSize,
                  '시간',
                  time != null
                      ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                      : '-',
                  Icons.access_time_rounded),
                const SizedBox(height: 16),
                
                // Price
                _buildConfirmationRow(
                  theme,
                  fontSize,
                  '상담료',
                  expert != null
                      ? '₩${expert.price.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},')}'
                      : '-',
                  Icons.attach_money_rounded),
                
                if (_messageController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    '상담 내용',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _messageController.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontSize - 1,
                      color: theme.colorScheme.onSurface.withOpacity(0.8)))]])),
          
          const SizedBox(height: 24),
          
          // Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.tertiary.withOpacity(0.3))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '예약 확정 후 24시간 전까지 취소 가능합니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: fontSize - 2)))]))]));
  }

  Widget _buildConfirmationRow(
    ThemeData theme,
    double fontSize,
    String label,
    String value,
    IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: fontSize - 2,
                  color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold))]))]);
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    final canProceed = _canProceed();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2))]),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('이전'))),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (_currentStep < 3) {
                        _nextStep();
                      } else {
                        _submitBooking();
                      }
                    }
                  : null,
              child: Text(_currentStep < 3 ? '다음' : '예약 확정')))]));
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return ref.watch(selectedExpertProvider) != null;
      case 1:
        return ref.watch(selectedDateProvider) != null;
      case 2:
        return ref.watch(selectedTimeProvider) != null;
      case 3:
        return true;
      default:
        return false;
    }
  }
}