import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../../domain/models/face_reading_result_v2.dart';
import '../../domain/models/face_condition.dart';
import '../../domain/models/emotion_analysis.dart';

/// 관상 분석 결과 상태
enum FaceReadingStatus {
  initial,
  loading,
  analyzing,
  success,
  error,
}

/// 관상 분석 전체 상태
class FaceReadingState {
  final FaceReadingStatus status;
  final FaceReadingResultV2? result;
  final String? errorMessage;
  final double analysisProgress; // 0.0 ~ 1.0

  const FaceReadingState({
    this.status = FaceReadingStatus.initial,
    this.result,
    this.errorMessage,
    this.analysisProgress = 0.0,
  });

  FaceReadingState copyWith({
    FaceReadingStatus? status,
    FaceReadingResultV2? result,
    String? errorMessage,
    double? analysisProgress,
  }) {
    return FaceReadingState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      analysisProgress: analysisProgress ?? this.analysisProgress,
    );
  }

  bool get isLoading =>
      status == FaceReadingStatus.loading ||
      status == FaceReadingStatus.analyzing;
  bool get hasResult => result != null && status == FaceReadingStatus.success;
  bool get hasError => status == FaceReadingStatus.error;
}

/// 관상 분석 상태 Provider
final faceReadingStateProvider =
    StateNotifierProvider<FaceReadingStateNotifier, FaceReadingState>((ref) {
  return FaceReadingStateNotifier();
});

/// 관상 분석 상태 관리 클래스
class FaceReadingStateNotifier extends StateNotifier<FaceReadingState> {
  FaceReadingStateNotifier() : super(const FaceReadingState());

  final _supabase = Supabase.instance.client;

  /// 분석 시작
  Future<void> startAnalysis({
    required String gender,
    String? ageGroup,
    required String imageBase64,
  }) async {
    try {
      state = state.copyWith(
        status: FaceReadingStatus.loading,
        analysisProgress: 0.1,
      );

      developer.log('🔍 FaceReadingState: 관상 분석 시작 (gender: $gender)');

      // 진행률 업데이트 - 이미지 업로드
      state = state.copyWith(analysisProgress: 0.3);

      // Edge Function 호출
      state = state.copyWith(
        status: FaceReadingStatus.analyzing,
        analysisProgress: 0.5,
      );

      final response = await _supabase.functions.invoke(
        'fortune-face-reading',
        body: {
          'imageBase64': imageBase64,
          'gender': gender,
          'ageGroup': ageGroup,
          'includeCondition': true, // 신규: 컨디션 분석 포함
          'includeEmotion': true, // 신규: 감정 분석 포함
          'version': 'v2', // V2 응답 요청
        },
      );

      state = state.copyWith(analysisProgress: 0.8);

      if (response.status != 200) {
        throw Exception('분석 실패: ${response.data['error'] ?? '알 수 없는 오류'}');
      }

      // 결과 파싱
      final resultData = response.data as Map<String, dynamic>;
      final result = FaceReadingResultV2.fromJson(resultData);

      // 히스토리 저장
      await _saveToHistory(result);

      state = state.copyWith(
        status: FaceReadingStatus.success,
        result: result,
        analysisProgress: 1.0,
      );

      developer.log('✅ FaceReadingState: 분석 완료 - 점수: ${result.overallScore}');
    } catch (e, st) {
      developer.log('❌ FaceReadingState 분석 실패: $e\n$st');
      state = state.copyWith(
        status: FaceReadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 히스토리에 저장
  Future<void> _saveToHistory(FaceReadingResultV2 result) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('face_reading_history').insert({
        'user_id': userId,
        'result_id': result.id,
        'gender': result.gender,
        'age_group': result.ageGroup,
        'face_condition': result.faceCondition?.toJson(),
        'emotion_analysis': result.emotionAnalysis?.toJson(),
        'priority_insights':
            result.priorityInsights.map((e) => e.toJson()).toList(),
        'overall_fortune_score': result.overallScore,
        'category_scores': {
          'loveScore': (result.simplifiedSibigung?.items ?? [])
              .where((e) => e.palaceId == 'love')
              .map((e) => e.score)
              .firstOrNull ?? 50,
          // 다른 카테고리 점수들도 추가...
        },
      });

      developer.log('💾 FaceReadingState: 히스토리 저장 완료');
    } catch (e) {
      developer.log('⚠️ FaceReadingState 히스토리 저장 실패: $e');
      // 히스토리 저장 실패는 메인 플로우에 영향 주지 않음
    }
  }

  /// 블러 해제
  void removeBlur() {
    if (state.result != null) {
      state = state.copyWith(
        result: state.result!.copyWith(isBlurred: false, blurredSections: []),
      );
      developer.log('🔓 FaceReadingState: 블러 해제');
    }
  }

  /// 상태 초기화
  void reset() {
    state = const FaceReadingState();
    developer.log('🔄 FaceReadingState: 상태 초기화');
  }

  /// 기존 결과 로드 (히스토리에서)
  Future<void> loadFromHistory(String historyId) async {
    try {
      state = state.copyWith(status: FaceReadingStatus.loading);

      final response = await _supabase
          .from('face_reading_history')
          .select()
          .eq('id', historyId)
          .single();

      // 히스토리에서 결과 재구성
      final faceCondition =
          FaceCondition.fromJson(response['face_condition'] as Map<String, dynamic>);
      final emotionAnalysis = EmotionAnalysis.fromJson(
          response['emotion_analysis'] as Map<String, dynamic>);
      final priorityInsights = (response['priority_insights'] as List)
          .map((e) => PriorityInsight.fromJson(e as Map<String, dynamic>))
          .toList();

      // 간소화된 결과 생성 (히스토리 뷰용)
      final result = FaceReadingResultV2(
        id: response['result_id'] as String,
        userId: response['user_id'] as String,
        createdAt: DateTime.parse(response['created_at'] as String),
        gender: response['gender'] as String,
        ageGroup: response['age_group'] as String?,
        priorityInsights: priorityInsights,
        overallScore: response['overall_fortune_score'] as int,
        summaryMessage: '이전 분석 결과입니다',
        faceCondition: faceCondition,
        emotionAnalysis: emotionAnalysis,
        myeonggungAnalysis: const MyeonggungAnalysis(
          description: '',
          lifeFortuneMessage: '',
          score: 0,
        ),
        miganAnalysis: const MiganAnalysis(
          description: '',
          fortuneMessage: '',
          score: 0,
        ),
        simplifiedOgwan: const SimplifiedOgwan(
          items: [],
          summary: '',
          bestFeature: '',
        ),
        simplifiedSibigung: const SimplifiedSibigung(
          items: [],
          summary: '',
          strongestPalace: '',
        ),
      );

      state = state.copyWith(
        status: FaceReadingStatus.success,
        result: result,
      );

      developer.log('📂 FaceReadingState: 히스토리에서 로드 완료');
    } catch (e, st) {
      developer.log('❌ FaceReadingState 히스토리 로드 실패: $e\n$st');
      state = state.copyWith(
        status: FaceReadingStatus.error,
        errorMessage: '결과를 불러올 수 없습니다',
      );
    }
  }
}

/// 현재 분석 진행률 Provider
final faceReadingProgressProvider = Provider<double>((ref) {
  return ref.watch(faceReadingStateProvider).analysisProgress;
});

/// 분석 결과 유무 Provider
final hasFaceReadingResultProvider = Provider<bool>((ref) {
  return ref.watch(faceReadingStateProvider).hasResult;
});

/// 분석 중 여부 Provider
final isFaceReadingAnalyzingProvider = Provider<bool>((ref) {
  return ref.watch(faceReadingStateProvider).isLoading;
});
