import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page_v2.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../presentation/providers/providers.dart';

class ChemistryFortunePage extends ConsumerStatefulWidget {
  const ChemistryFortunePage({super.key});

  @override
  ConsumerState<ChemistryFortunePage> createState() => _ChemistryFortunePageState();
}

class _ChemistryFortunePageState extends ConsumerState<ChemistryFortunePage> {
  final TextEditingController _name1Controller = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  DateTime? _birthdate1;
  DateTime? _birthdate2;
  String? _gender1;
  String? _gender2;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }
  
  void _loadCurrentUserProfile() {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile != null) {
      setState(() {
        _name1Controller.text = profile.name ?? '';
        _birthdate1 = profile.birthDate;
        _gender1 = profile.gender;
      });
    }
  }
  
  @override
  void dispose() {
    _name1Controller.dispose();
    _name2Controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseFortunePageV2(
      title: '케미스트리 운세',
      fortuneType: 'chemistry',
      headerGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)]),
      inputBuilder: (context, onSubmit) => _buildInputSection(onSubmit),
      resultBuilder: (context, result, onShare) => _buildResult(context, result));
  }
  
  Widget _buildInputSection(Function(Map<String, dynamic>) onSubmit) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '두 사람의 케미스트리 확인하기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            '두 사람의 정보를 입력하면 서로의 성격, 관계의 강점과 보완점을 분석해드립니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey)),
          const SizedBox(height: 24),
          
          // Person 1 Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink.withValues(alpha: 0.2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.pink),
                    SizedBox(width: 8),
                    Text(
                      '첫 번째 사람',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink))]),
                const SizedBox(height: 16),
                
                // Name input
                TextFormField(
                  controller: _name1Controller,
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '이름을 입력해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.edit))),
                const SizedBox(height: 12),
                
                // Birthdate input
                InkWell(
                  onTap: () => _selectDate(context, 1),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '생년월일',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.calendar_today)),
                    child: Text(
                      _birthdate1 != null
                          ? '${_birthdate1!.year}년 ${_birthdate1!.month}월 ${_birthdate1!.day}일'
                          : '생년월일을 선택해주세요',
                      style: TextStyle(
                        color: _birthdate1 != null ? null : Colors.grey)))),
                const SizedBox(height: 12),
                
                // Gender selection
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('남성'),
                        value: 'male',
                        groupValue: _gender1,
                        onChanged: (value) {
                          setState(() {
                            _gender1 = value;
                          });
                        })),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('여성'),
                        value: 'female',
                        groupValue: _gender1,
                        onChanged: (value) {
                          setState(() {
                            _gender1 = value;
                          });
                        }))])])),
          
          const SizedBox(height: 20),
          
          // Connection icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle),
              child: const Icon(
                Icons.favorite,
                color: Colors.orange,
                size: 32))),
          
          const SizedBox(height: 20),
          
          // Person 2 Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '두 번째 사람',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue))]),
                const SizedBox(height: 16),
                
                // Name input
                TextFormField(
                  controller: _name2Controller,
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '이름을 입력해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.edit))),
                const SizedBox(height: 12),
                
                // Birthdate input
                InkWell(
                  onTap: () => _selectDate(context, 2),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '생년월일',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.calendar_today)),
                    child: Text(
                      _birthdate2 != null
                          ? '${_birthdate2!.year}년 ${_birthdate2!.month}월 ${_birthdate2!.day}일'
                          : '생년월일을 선택해주세요',
                      style: TextStyle(
                        color: _birthdate2 != null ? null : Colors.grey)))),
                const SizedBox(height: 12),
                
                // Gender selection
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('남성'),
                        value: 'male',
                        groupValue: _gender2,
                        onChanged: (value) {
                          setState(() {
                            _gender2 = value;
                          });
                        })),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('여성'),
                        value: 'female',
                        groupValue: _gender2,
                        onChanged: (value) {
                          setState(() {
                            _gender2 = value;
                          });
                        }))])])),
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canSubmit()
                  ? () => onSubmit({
                        'person1': {}
                          'name': _name1Controller.text),
                          'birthdate': _birthdate1!.toIso8601String(),
                          'gender': null},
                        'person2': {
                          , 'name': _name2Controller.text,
                          'birthdate': _birthdate2!.toIso8601String(),
                          'gender': null}})
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '케미스트리 분석하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold))])))]));
  }
  
  bool _canSubmit() {
    return _name1Controller.text.isNotEmpty &&
        _name2Controller.text.isNotEmpty &&
        _birthdate1 != null &&
        _birthdate2 != null &&
        _gender1 != null &&
        _gender2 != null;
  }
  
  Future<void> _selectDate(BuildContext context, int person) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: person == 1 ? (_birthdate1 ?? DateTime.now(), : (_birthdate2 ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        if (person == 1) {
          _birthdate1 = picked;
        } else {
          _birthdate2 = picked;
        }
      });
    }
  }
  
  Widget _buildResult(BuildContext context, FortuneResult result) {
    final score = result.overallScore ?? 0;
    
    return Column(
      children: [
        // Chemistry Score
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getScoreColor(score).withValues(alpha: 0.1),
                _getScoreColor(score).withValues(alpha: 0.2)]),
            borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text(
                '케미스트리 점수',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600])),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score.toDouble(),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Text(
                    '${value.toInt()}점',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(value.toInt()));
                }),
              const SizedBox(height: 8),
              Text(
                _getScoreMessage(score),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getScoreColor(score)))])),
        
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
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '종합 분석',
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
        
        // Score Breakdown
        if (result.scoreBreakdown != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '항목별 점수',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                ...result.scoreBreakdown!.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _translateScoreKey(entry.key),
                            style: const TextStyle(fontSize: 14)),
                          Text(
                            '${entry.value}점',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(entry.value)))]),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: entry.value / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(entry.value)))]))])),
          const SizedBox(height: 20)],
        
        // Sections
        if (result.sections != null && result.sections!.isNotEmpty) ...[
          ...result.sections!.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
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
                      Icon(
                        _getSectionIcon(entry.key),
                        color: _getSectionColor(entry.key)),
                      const SizedBox(width: 8),
                      Text(
                        _translateSectionKey(entry.key),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6))])))],
        
        // Recommendations
        if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[50]!,
                  Colors.pink[50]!]),
              borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      '관계 발전을 위한 조언',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold))]),
                const SizedBox(height: 12),
                ...result.recommendations!.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 14)))]))]))]]);
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  String _getScoreMessage(int score) {
    if (score >= 80) return '환상의 케미스트리!';
    if (score >= 60) return '좋은 케미스트리';
    if (score >= 40) return '노력이 필요한 케미스트리';
    return '도전적인 케미스트리';
  }
  
  String _translateScoreKey(String key) {
    final translations = {
      'communication', '의사소통',
      'emotional', '감정적 교감',
      'values', '가치관',
      'lifestyle', '라이프스타일',
      'physical', '신체적 매력',
      'intellectual', '지적 교감',
      'trust', '신뢰도',
      'compatibility', '전반적 호환성'};
    return translations[key] ?? key;
  }
  
  String _translateSectionKey(String key) {
    final translations = {
      'strengths', '관계의 강점',
      'challenges', '주의할 점',
      'communication', '소통 스타일',
      'emotional_connection', '감정적 연결',
      'growth_areas', '성장 가능성',
      'advice', '종합 조언'};
    return translations[key] ?? key;
  }
  
  IconData _getSectionIcon(String key) {
    final icons = {
      'strengths': Icons.star,
      'challenges': Icons.warning,
      'communication': Icons.chat,
      'emotional_connection': Icons.favorite,
      'growth_areas': Icons.trending_up,
      'advice': null};
    return icons[key] ?? Icons.info;
  }
  
  Color _getSectionColor(String key) {
    final colors = {
      'strengths': Colors.green,
      'challenges': Colors.orange,
      'communication': Colors.blue,
      'emotional_connection': Colors.pink,
      'growth_areas': Colors.purple,
      'advice': null};
    return colors[key] ?? Colors.grey;
  }
}