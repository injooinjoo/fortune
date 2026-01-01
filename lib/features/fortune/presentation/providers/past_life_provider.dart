import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../../domain/models/past_life_result.dart';

/// 전생 운세 상태
enum PastLifeStatus {
  initial,
  loading,
  generating,
  success,
  error,
}

/// 전생 운세 전체 상태
class PastLifeState {
  final PastLifeStatus status;
  final PastLifeResult? result;
  final String? errorMessage;
  final double progress; // 0.0 ~ 1.0

  const PastLifeState({
    this.status = PastLifeStatus.initial,
    this.result,
    this.errorMessage,
    this.progress = 0.0,
  });

  PastLifeState copyWith({
    PastLifeStatus? status,
    PastLifeResult? result,
    String? errorMessage,
    double? progress,
  }) {
    return PastLifeState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  bool get isLoading =>
      status == PastLifeStatus.loading || status == PastLifeStatus.generating;
  bool get hasResult => result != null && status == PastLifeStatus.success;
  bool get hasError => status == PastLifeStatus.error;
}

/// 전생 운세 Provider
final pastLifeProvider =
    StateNotifierProvider<PastLifeNotifier, PastLifeState>((ref) {
  return PastLifeNotifier();
});

/// 전생 운세 상태 관리 클래스
class PastLifeNotifier extends StateNotifier<PastLifeState> {
  PastLifeNotifier() : super(const PastLifeState());

  final _supabase = Supabase.instance.client;

  /// 전생 운세 생성
  Future<void> generatePastLife({
    required String userName,
    required String birthDate, // YYYY-MM-DD
    required String birthTime, // HH:mm or 'unknown'
    required String gender,
    String? lunarSolar, // 'lunar' or 'solar'
  }) async {
    try {
      state = state.copyWith(
        status: PastLifeStatus.loading,
        progress: 0.1,
        errorMessage: null,
      );

      developer.log('🔮 PastLifeNotifier: 전생 운세 생성 시작 (user: $userName)');

      // 진행률 업데이트 - 사주 분석 중
      state = state.copyWith(progress: 0.2);

      // Edge Function 호출
      state = state.copyWith(
        status: PastLifeStatus.generating,
        progress: 0.4,
      );

      final response = await _supabase.functions.invoke(
        'fortune-past-life',
        body: {
          'userName': userName,
          'birthDate': birthDate,
          'birthTime': birthTime,
          'gender': gender,
          'lunarSolar': lunarSolar ?? 'solar',
        },
      );

      state = state.copyWith(progress: 0.8);

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        throw Exception(
            errorData?['error'] ?? '전생 운세 생성에 실패했습니다');
      }

      // 결과 파싱
      final resultData = response.data as Map<String, dynamic>;
      final result = PastLifeResult.fromJson(resultData);

      state = state.copyWith(
        status: PastLifeStatus.success,
        result: result,
        progress: 1.0,
      );

      developer.log(
          '✅ PastLifeNotifier: 전생 운세 완료 - 신분: ${result.pastLifeStatus}');
    } catch (e, st) {
      developer.log('❌ PastLifeNotifier 생성 실패: $e\n$st');
      state = state.copyWith(
        status: PastLifeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// 블러 해제
  void removeBlur() {
    if (state.result != null) {
      state = state.copyWith(
        result: state.result!.copyWith(isBlurred: false, blurredSections: []),
      );
      developer.log('🔓 PastLifeNotifier: 블러 해제');
    }
  }

  /// 상태 초기화
  void reset() {
    state = const PastLifeState();
    developer.log('🔄 PastLifeNotifier: 상태 초기화');
  }

  /// 기존 결과 로드 (히스토리에서)
  Future<void> loadFromHistory(String resultId) async {
    try {
      state = state.copyWith(status: PastLifeStatus.loading);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final response = await _supabase
          .from('past_life_results')
          .select()
          .eq('id', resultId)
          .eq('user_id', userId)
          .single();

      final result = PastLifeResult.fromJson({
        'id': response['id'],
        'pastLifeStatus': response['past_life_status'],
        'pastLifeStatusEn': response['past_life_status_en'],
        'pastLifeGender': response['past_life_gender'],
        'pastLifeEra': response['past_life_era'],
        'pastLifeName': response['past_life_name'],
        'story': response['story_text'],
        'summary': response['story_summary'],
        'portraitUrl': response['portrait_url'],
        'advice': response['advice'],
        'score': response['score'],
        'createdAt': response['created_at'],
        'isBlurred': false,
      });

      state = state.copyWith(
        status: PastLifeStatus.success,
        result: result,
      );

      developer.log('📂 PastLifeNotifier: 히스토리에서 로드 완료');
    } catch (e, st) {
      developer.log('❌ PastLifeNotifier 히스토리 로드 실패: $e\n$st');
      state = state.copyWith(
        status: PastLifeStatus.error,
        errorMessage: '결과를 불러올 수 없습니다',
      );
    }
  }

  /// 히스토리 목록 조회
  Future<List<PastLifeResult>> getHistory({int limit = 10}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('past_life_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((item) {
        return PastLifeResult.fromJson({
          'id': item['id'],
          'pastLifeStatus': item['past_life_status'],
          'pastLifeStatusEn': item['past_life_status_en'],
          'pastLifeGender': item['past_life_gender'],
          'pastLifeEra': item['past_life_era'],
          'pastLifeName': item['past_life_name'],
          'story': item['story_text'],
          'summary': item['story_summary'],
          'portraitUrl': item['portrait_url'],
          'advice': item['advice'],
          'score': item['score'],
          'createdAt': item['created_at'],
          'isBlurred': false,
        });
      }).toList();
    } catch (e) {
      developer.log('❌ PastLifeNotifier 히스토리 조회 실패: $e');
      return [];
    }
  }
}

/// 전생 운세 진행률 Provider
final pastLifeProgressProvider = Provider<double>((ref) {
  return ref.watch(pastLifeProvider).progress;
});

/// 전생 운세 결과 유무 Provider
final hasPastLifeResultProvider = Provider<bool>((ref) {
  return ref.watch(pastLifeProvider).hasResult;
});

/// 전생 운세 생성 중 여부 Provider
final isPastLifeGeneratingProvider = Provider<bool>((ref) {
  return ref.watch(pastLifeProvider).isLoading;
});
