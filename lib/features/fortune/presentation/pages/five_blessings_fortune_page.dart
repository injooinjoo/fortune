import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/providers.dart';

class FiveBlessingsFortunePage extends ConsumerStatefulWidget {
  const FiveBlessingsFortunePage({super.key});

  @override
  ConsumerState<FiveBlessingsFortunePage> createState() => _FiveBlessingsFortunePageState();
}

class _FiveBlessingsFortunePageState extends ConsumerState<FiveBlessingsFortunePage> {
  String? _selectedGoal;
  DateTime? _birthdate;
  
  final List<Map<String, dynamic>> blessingGoals = [
    {
      'id', 'longevity',
      'title', '수(壽) - 장수',
      'subtitle', '건강하고 오래 사는 삶',
      'icon': Icons.favorite,
      'color': Colors.green,
      'description', '무병장수하며 건강한 노년을 보내는 축복'},
    {
      'id', 'wealth',
      'title', '부(富) - 재물',
      'subtitle', '풍족하고 넉넉한 삶',
      'icon': Icons.monetization_on,
      'color': Colors.amber,
      'description', '경제적으로 풍요롭고 여유로운 삶의 축복'},
    {
      'id', 'health',
      'title', '강녕(康寧) - 건강',
      'subtitle', '몸과 마음이 편안한 삶',
      'icon': Icons.spa,
      'color': Colors.blue,
      'description', '심신이 건강하고 평온한 상태를 유지하는 축복'},
    {
      'id', 'virtue',
      'title', '유호덕(攸好德) - 덕행',
      'subtitle', '덕을 쌓고 베푸는 삶',
      'icon': Icons.volunteer_activism,
      'color': Colors.purple,
      'description', '선행을 쌓고 타인에게 존경받는 삶의 축복'},
    {
      'id', 'peaceful_death',
      'title', '고종명(考終命) - 편안한 임종',
      'subtitle', '평화롭게 마무리하는 삶',
      'icon': Icons.nature_people,
      'color': Colors.indigo,
      'description', '천수를 다하고 편안하게 생을 마감하는 축복'}];
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  void _loadUserProfile() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile?.birthDate != null) {
      setState(() {
        _birthdate = profile!.birthDate;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseFortunePageV2(
      title: '오복(五福) 운세',
      fortuneType: 'five-blessings',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]),
      inputBuilder: (context, onSubmit) => _buildInputSection(onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result);
  }
  
  Widget _buildInputSection(Function(Map<String, dynamic>) onSubmit) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오복(五福) 운세',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            '전통 오복 중 당신이 가장 원하는 복을 선택하면, 그 복을 받을 수 있는 방법을 알려드립니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey)),
          const SizedBox(height: 24),
          
          // Birth date input
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _birthdate != null
                          ? '${_birthdate!.year}년 ${_birthdate!.month}월 ${_birthdate!.day}일생'
                          : '생년월일을 선택해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: _birthdate != null ? Colors.black : Colors.grey))),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey)]))),
          
          const SizedBox(height: 24),
          
          // Five Blessings Selection
          const Text(
            '원하시는 복을 선택하세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          ...blessingGoals.map((blessing) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedGoal = blessing['id'];
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedGoal == blessing['id']
                      ? (blessing['color'] as Color).withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedGoal == blessing['id']
                        ? blessing['color'],
    Color
                        : Colors.grey[300]!,
                    width: _selectedGoal == blessing['id'])),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (blessing['color'],
                        shape: BoxShape.circle),
                      child: Icon(
                        blessing['icon'],
                        color: blessing['color'],
                        size: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blessing['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedGoal == blessing['id']
                                  ? blessing['color'],
    Color
                                  : Colors.black)),
                          Text(
                            blessing['subtitle'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600]))])),
                    if (_selectedGoal == blessing['id'])
                      Icon(
                        Icons.check_circle,
                        color: blessing['color'])])))),
          
          // Selected blessing description
          if (_selectedGoal != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      blessingGoals.firstWhere((b) => b['id'] == _selectedGoal)['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4)))]))],
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedGoal != null && _birthdate != null
                  ? () => onSubmit({
                        'blessing_type': _selectedGoal,
                        'birthdate': null},
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '오복 운세 확인하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold))])))]));
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now();
    if (picked != null) {
      setState(() {
        _birthdate = picked;
      });
    }
  }
  
  Widget _buildResult(BuildContext context, FortuneResult result) {
    final data = result.details ?? {};
    final selectedBlessing = blessingGoals.firstWhere(
      (b) => b['id'] == (_selectedGoal ?? data['blessing_type'],
      orElse: () => blessingGoals.first
    );
    
    return Column(
      children: [
        // Selected Blessing Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (selectedBlessing['color'],
                (selectedBlessing['color']]),
            borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Icon(
                selectedBlessing['icon'],
                size: 64,
                color: selectedBlessing['color']),
              const SizedBox(height: 16),
              Text(
                selectedBlessing['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                selectedBlessing['subtitle'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700]))])),
        
        const SizedBox(height: 20),
        
        // Main Fortune
        if (result.mainFortune != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: selectedBlessing['color'],
                    const SizedBox(width: 8),
                    const Text(
                      '당신의 오복 운세',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                Text(
                  result.mainFortune!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6))])),
          const SizedBox(height: 20)],
        
        // Blessing Score
        if (result.overallScore != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              children: [
                Text(
                  '${selectedBlessing['title']} 달성 가능성',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: result.overallScore! / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          selectedBlessing['color']))),
                    Column(
                      children: [
                        Text(
                          '${result.overallScore}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: selectedBlessing['color'])),
                        Text(
                          '달성 가능성',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600]))])])])),
          const SizedBox(height: 20)],
        
        // Methods to Achieve Blessing
        if (result.sections != null && result.sections!['methods'] != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_list_numbered, color: selectedBlessing['color'],
                    const SizedBox(width: 8),
                    const Text(
                      '복을 받는 방법',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                Text(
                  result.sections!['methods'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6))])),
          const SizedBox(height: 20)],
        
        // Lucky Elements
        if (result.luckyItems != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.yellow[50]!,
                  Colors.orange[50]!]),
              borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.stars, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '행운을 부르는 요소',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: result.luckyItems!.entries.map((entry) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange[200]!)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getLuckyItemIcon(entry.key),
                          size: 16,
                          color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          '${_translateLuckyItem(entry.key)}: ${entry.value.toString()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500))])).toList())])),
          const SizedBox(height: 20)],
        
        // Daily Practice
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.event_repeat, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      '매일 실천하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                ...result.recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.2),
                          shape: BoxShape.circle),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.purple)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 14)))]))]))]]
    );
  }
  
  IconData _getLuckyItemIcon(String key) {
    final icons = {
      'color': Icons.palette,
      'direction': Icons.explore,
      'number': Icons.looks_one,
      'time': Icons.access_time,
      'element': null};
    return icons[key] ?? Icons.star;
  }
  
  String _translateLuckyItem(String key) {
    final translations = {
      'color', '색상',
      'direction', '방향',
      'number', '숫자',
      'time', '시간',
      'element', '원소'};
    return translations[key] ?? key;
  }
}