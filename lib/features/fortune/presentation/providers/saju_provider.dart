import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Saju data state
class SajuState {
  final bool isLoading;
  final Map<String, dynamic>? sajuData;
  final String? error;
  final bool isCached;

  SajuState({
    this.isLoading = false,
    this.sajuData,
    this.error,
    this.isCached = false});

  SajuState copyWith({
    bool? isLoading,
    Map<String, dynamic>? sajuData,
    String? error,
    bool? isCached}) {
    return SajuState(
      isLoading: isLoading ?? this.isLoading,
      sajuData: sajuData ?? this.sajuData,
      error: error,
      isCached: isCached ?? this.isCached);
}
}

// Saju Provider
class SajuNotifier extends StateNotifier<SajuState> {
  final SupabaseClient _supabase;

  SajuNotifier(this._supabase) : super(SajuState());

  // Fetch user's Saju data
  Future<void> fetchUserSaju() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: '로그인이 필요합니다.'
        );
        return;
      }

      // First, try to get from database
      final response = await _supabase
          .from('user_saju')
          .select('*')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        // Format the data for display
        final formattedData = _formatSajuData(response);
        state = state.copyWith(
          isLoading: false,
          sajuData: formattedData,
          isCached: true
        );
} else {
        // No data exists, need to calculate
        state = state.copyWith(
          isLoading: false,
          sajuData: null,
          isCached: false);
}
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '실패했습니다: $e'
      );
    }
  }

  // Calculate and save user's Saju
  Future<void> calculateAndSaveSaju({
    required DateTime birthDate,
    String? birthTime,
    bool isLunar = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: '로그인이 필요합니다.');
        return;
      }

      // Call Edge Function to calculate and save Saju
      debugPrint('with:');
      debugPrint('birthDate: ${birthDate.toIso8601String().split('T')[0]}');
      debugPrint('Fortune cached');
      debugPrint('Fortune cached');
      
      final response = await _supabase.functions.invoke(
        'calculate-saju',
        body: {
          'birthDate': birthDate.toIso8601String().split('T')[0],
          'birthTime': birthTime,
          'isLunar': isLunar,
          'timezone': 'Asia/Seoul'
        }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Edge Function timeout after 30 seconds');
          throw Exception('사주 계산 시간 초과 (30초)');
        });
      
      debugPrint('=== SAJU API RESPONSE ===');
      debugPrint('type: ${response.runtimeType}');
      debugPrint('status: ${response.status}');
      debugPrint('type: ${response.data.runtimeType}');
      debugPrint('data: ${response.data}');
      
      // Log all available properties
      if (response.data is Map) {
        debugPrint('keys: ${(response.data as Map).keys.toList()}');
}

      if (response.status != 200) {
        debugPrint('=== EDGE FUNCTION ERROR RESPONSE ===');
        debugPrint('code: ${response.status}');
        
        final errorData = response.data;
        String errorMessage = '사주 계산에 실패했습니다.';
        String errorDetails = '';
        
        if (errorData is Map) {
          debugPrint('Error data is Map, keys: ${errorData.keys.toList()}');
          debugPrint('data: ${errorData}');
          
          errorMessage = errorData['error'] ?? errorMessage;
          if (errorData['details'] != null) {
            errorDetails = errorData['details'].toString();
            errorMessage += '\n상세: $errorDetails';
}
          
          // Log additional error info if available
          if (errorData['timestamp'] != null) {
            debugPrint('timestamp: ${errorData[')timestamp']}');
}
          if (errorData['reasonPhrase'] != null) {
            debugPrint('phrase: ${errorData[')reasonPhrase']}');
}
        } else {
          debugPrint('type: ${errorData.runtimeType}');
          debugPrint('Fortune cached');
}
        
        debugPrint('Fortune cached');
        throw Exception(errorMessage);
}

      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        final formattedData = _formatSajuData(data['data']);
        state = state.copyWith(
          isLoading: false,
          sajuData: formattedData,
          isCached: data['cached'] ?? false
        );
      } else if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      } else {
        throw Exception('사주 계산에 실패했습니다. 응답 형식이 올바르지 않습니다.');
      }
    } catch (e, stackTrace) {
      debugPrint('=== SAJU CALCULATION EXCEPTION ===');
      debugPrint('type: ${e.runtimeType}');
      debugPrint('Fortune cached');
      debugPrint('trace:');
      debugPrint(stackTrace.toString());
      
      // Extract cleaner error message
      String errorMessage = '사주 계산 중 오류가 발생했습니다';
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMessage += ': $e';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage
      );
    }
  }

  // Format Saju data for display
  Map<String, dynamic> _formatSajuData(Map<String, dynamic> rawData) {
    // Support both naming conventions (from API and from database)
    final yearStem = rawData['year_stem'] ?? rawData['year_cheongan'];
    final yearBranch = rawData['year_branch'] ?? rawData['year_jiji'];
    final monthStem = rawData['month_stem'] ?? rawData['month_cheongan'];
    final monthBranch = rawData['month_branch'] ?? rawData['month_jiji'];
    final dayStem = rawData['day_stem'] ?? rawData['day_cheongan'];
    final dayBranch = rawData['day_branch'] ?? rawData['day_jiji'];
    final hourStem = rawData['hour_stem'] ?? rawData['hour_cheongan'];
    final hourBranch = rawData['hour_branch'] ?? rawData['hour_jiji'];
    
    return {
      'year': {
        'cheongan': {
          'char': yearStem,
          'hanja': rawData['year_stem_hanja'] ?? _getHanjaForStem(yearStem),
          'element': _getElementForStem(yearStem)},
        'jiji': {
          'char': yearBranch,
          'hanja': rawData['year_branch_hanja'] ?? _getHanjaForBranch(yearBranch),
          'animal': _getAnimalForBranch(yearBranch),
          'element': _getElementForBranch(yearBranch)}},
      'month': {
        'cheongan': {
          'char': monthStem,
          'hanja': rawData['month_stem_hanja'] ?? _getHanjaForStem(monthStem),
          'element': _getElementForStem(monthStem)},
        'jiji': {
          'char': monthBranch,
          'hanja': rawData['month_branch_hanja'] ?? _getHanjaForBranch(monthBranch),
          'animal': _getAnimalForBranch(monthBranch),
          'element': _getElementForBranch(monthBranch)}},
      'day': {
        'cheongan': {
          'char': dayStem,
          'hanja': rawData['day_stem_hanja'] ?? _getHanjaForStem(dayStem),
          'element': _getElementForStem(dayStem)},
        'jiji': {
          'char': dayBranch,
          'hanja': rawData['day_branch_hanja'] ?? _getHanjaForBranch(dayBranch),
          'animal': _getAnimalForBranch(dayBranch),
          'element': _getElementForBranch(dayBranch)}},
      'hour': hourStem != null
          ? {
              'cheongan': {
                'char': hourStem,
                'hanja': rawData['hour_stem_hanja'] ?? _getHanjaForStem(hourStem),
                'element': _getElementForStem(hourStem)},
              'jiji': {
                'char': hourBranch,
                'hanja': rawData['hour_branch_hanja'] ?? _getHanjaForBranch(hourBranch),
                'animal': _getAnimalForBranch(hourBranch),
                'element': _getElementForBranch(hourBranch)}}
          : null,
      'elements': rawData['element_balance'] ?? {
        '목': rawData['element_wood'] ?? 0,
        '화': rawData['element_fire'] ?? 0,
        '토': rawData['element_earth'] ?? 0,
        '금': rawData['element_metal'] ?? 0,
        '수': rawData['element_water'] ?? 0,
      },
      'daeun': {
        'current': rawData['current_daeun'] ?? '',
        'currentHanja': _getDaeunHanja(rawData['current_daeun']),
        'age': rawData['daeun_info']?['startAge'] ?? 0,
        'endAge': rawData['daeun_info']?['endAge']},
      'interpretation': rawData['interpretation'] ?? '',
      'personalityAnalysis': rawData['personality_analysis'] ?? '',
      'careerGuidance': rawData['career_guidance'] ?? '',
      'relationshipAdvice': rawData['relationship_advice'] ?? '',
      'dominantElement': rawData['dominant_element'] ?? '',
      'lackingElement': rawData['lacking_element'] ?? '',
      'calculatedAt': rawData['calculated_at']};
}

  String _getElementForStem(String stem) {
    const stemElements = {
      '갑': '목', '을': '목',
      '병': '화', '정': '화',
      '무': '토', '기': '토',
      '경': '금', '신': '금',
      '임': '수', '계': '수'
    };
    return stemElements[stem] ?? '';
  }

  String _getElementForBranch(String branch) {
    const branchElements = {
      '자': '수', '축': '토', '인': '목', '묘': '목',
      '진': '토', '사': '화', '오': '화', '미': '토',
      '신': '금', '유': '금', '술': '토', '해': '수'
    };
    return branchElements[branch] ?? '';
  }

  String _getAnimalForBranch(String branch) {
    const branchAnimals = {
      '자': '쥐', '축': '소', '인': '호랑이', '묘': '토끼',
      '진': '용', '사': '뱀', '오': '말', '미': '양',
      '신': '원숭이', '유': '닭', '술': '개', '해': '돼지'
    };
    return branchAnimals[branch] ?? '';
  }

  // 천간 한자 매핑
  static const Map<String, String> stemHanjaMap = {
    '갑': '甲', '을': '乙', '병': '丙', '정': '丁', '무': '戊',
    '기': '己', '경': '庚', '신': '辛', '임': '壬', '계': '癸'
  };
  
  // 지지 한자 매핑
  static const Map<String, String> branchHanjaMap = {
    '자': '子', '축': '丑', '인': '寅', '묘': '卯', '진': '辰', '사': '巳',
    '오': '午', '미': '未', '신': '申', '유': '酉', '술': '戌', '해': '亥'
  };

  String _getDaeunHanja(String? daeun) {
    if (daeun == null || daeun.length < 2) return '';
    
    final stem = daeun[0];
    final branch = daeun[1];
    return '${stemHanjaMap[stem] ?? stem}${branchHanjaMap[branch] ?? branch}';
}

  // 천간에 대한 한자 가져오기
  String _getHanjaForStem(String? stem) {
    if (stem == null || stem.isEmpty) return '';
    return stemHanjaMap[stem] ?? '';
  }

  // 지지에 대한 한자 가져오기
  String _getHanjaForBranch(String? branch) {
    if (branch == null || branch.isEmpty) return '';
    return branchHanjaMap[branch] ?? '';
  }

  // Clear Saju data
  void clearSaju() {
    state = SajuState();
}

  // Refresh Saju data (force recalculation,
  Future<void> refreshSaju() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: '로그인이 필요합니다.'
        );
        return;
      }

      // Get user profile to get birth info
      final profile = await _supabase
          .from('user_profiles')
          .select('birth_date, birth_time')
          .eq('id', user.id)
          .single();

      if (profile['birth_date'] == null) {
        state = state.copyWith(
          isLoading: false,
          error: '생년월일 정보가 없습니다.'
        );
        return;
      }

      // TODO: Implement calculateAndSaveSaju
      // await calculateAndSaveSaju(
      //   birthDate: DateTime.parse(profile['birth_date']),
      //   birthTime: profile['birth_time'],
      //   isLunar: false, // TODO: Get from user profile
      // );
      
      // For now, just refetch the data
      await fetchUserSaju();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '발생했습니다: $e'
      );
    }
  }
}

// Provider definitions
final sajuProvider = StateNotifierProvider<SajuNotifier, SajuState>((ref) {
  final supabase = Supabase.instance.client;
  return SajuNotifier(supabase);
});

// Auto-fetch Saju when user is logged in
final userSajuProvider = FutureProvider<void>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user != null) {
    await ref.read(sajuProvider.notifier).fetchUserSaju();
}
});

// Computed provider for Saju display data
final sajuDisplayDataProvider = Provider<Map<String, dynamic>?>((ref) {
  final sajuState = ref.watch(sajuProvider);
  return sajuState.sajuData;
});

// Computed provider for element balance
final elementBalanceProvider = Provider<Map<String, int>>((ref) {
  final sajuData = ref.watch(sajuDisplayDataProvider);
  if (sajuData == null) return {};
  
  final elements = sajuData['elements'] as Map<String, dynamic>?;
  if (elements == null) return {};
  
  return Map<String, int>.from(elements);
});

// Computed provider for Daeun info
final daeunInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final sajuData = ref.watch(sajuDisplayDataProvider);
  if (sajuData == null) return {};
  
  return sajuData['daeun'] as Map<String, dynamic>? ?? {};
});