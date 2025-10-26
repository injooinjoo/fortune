import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';
import '../../utils/logger.dart';

/// 소개팅 운세 생성기
///
/// Edge Function을 통해 소개팅 운세를 생성합니다.
/// - 만남 정보 (날짜, 시간, 장소 유형, 소개자)
/// - 선호도 (중요 자질, 나이 선호, 이상적인 첫 데이트)
/// - 자기 평가 (자신감, 걱정, 과거 경험)
/// - 사진 분석 (본인/상대방 사진)
/// - 채팅 분석
class BlindDateGenerator {
  /// 소개팅 운세 생성
  ///
  /// **input_conditions 형식**:
  /// ```json
  /// {
  ///   // Meeting Info
  ///   "meeting_date": "2025-01-15",
  ///   "meeting_time": "evening",  // morning, lunch, afternoon, evening, night
  ///   "meeting_type": "coffee",   // coffee, meal, activity, walk, online
  ///   "introducer": "friend",     // friend, family, colleague, app, matchmaker, other
  ///
  ///   // Preferences
  ///   "important_qualities": ["성격", "유머감각", "가치관"],
  ///   "age_preference": "similar",  // younger, similar, older, any
  ///   "ideal_first_date": "카페에서 편하게 이야기",
  ///
  ///   // Self Assessment
  ///   "confidence": "medium",  // high, medium, low
  ///   "concerns": ["말이 잘 안 통할까봐", "침묵이 어색할까봐"],
  ///   "past_experience": "positive",  // positive, negative, none
  ///   "is_first_blind_date": false,
  ///
  ///   // Photo Analysis
  ///   "my_photos": ["base64..."],  // 본인 사진 (선택)
  ///   "partner_photos": ["base64..."],  // 상대방 사진 (선택)
  ///
  ///   // Chat Analysis
  ///   "chat_content": "카톡 내용...",  // 선택
  ///   "chat_platform": "kakao"  // kakao, line, other
  /// }
  /// ```
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    // userId와 name 가져오기
    final user = supabase.auth.currentUser;
    final userProfile = user != null
        ? await supabase
            .from('profiles')
            .select('name')
            .eq('id', user.id)
            .maybeSingle()
        : null;

    final userId = user?.id ?? 'anonymous';
    final userName = userProfile?['name'] as String? ?? user?.userMetadata?['name'] as String? ?? inputConditions['name'] as String? ?? 'Guest';

    // 📤 API 요청 준비
    Logger.info('[BlindDateGenerator] 📤 API 요청 준비');
    Logger.info('[BlindDateGenerator]   🌐 Edge Function: fortune-blind-date');
    Logger.info('[BlindDateGenerator]   👤 user_id: $userId');
    Logger.info('[BlindDateGenerator]   👤 name: $userName');
    Logger.info('[BlindDateGenerator]   📅 meeting_date: ${inputConditions['meeting_date']}');
    Logger.info('[BlindDateGenerator]   ⏰ meeting_time: ${inputConditions['meeting_time']}');
    Logger.info('[BlindDateGenerator]   📍 meeting_type: ${inputConditions['meeting_type']}');
    Logger.info('[BlindDateGenerator]   🤝 introducer: ${inputConditions['introducer']}');

    try {
      final requestBody = {
        'fortune_type': 'blind_date',
        'name': userName,
        'meeting_date': inputConditions['meeting_date'],
        'meeting_time': inputConditions['meeting_time'],
        'meeting_type': inputConditions['meeting_type'],
        'introducer': inputConditions['introducer'],
        'important_qualities': inputConditions['important_qualities'],
        'age_preference': inputConditions['age_preference'],
        'ideal_first_date': inputConditions['ideal_first_date'],
        'confidence': inputConditions['confidence'],
        'concerns': inputConditions['concerns'],
        'past_experience': inputConditions['past_experience'],
        'is_first_blind_date': inputConditions['is_first_blind_date'],
        'my_photos': inputConditions['my_photos'],
        'partner_photos': inputConditions['partner_photos'],
        'chat_content': inputConditions['chat_content'],
        'chat_platform': inputConditions['chat_platform'],
      };

      Logger.info('[BlindDateGenerator] 📡 API 호출 중...');

      // Edge Function 호출
      final response = await supabase.functions.invoke(
        'fortune-blind-date',
        body: utf8.encode(jsonEncode(requestBody)),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // 📥 응답 수신
      Logger.info('[BlindDateGenerator] 📥 API 응답 수신');
      Logger.info('[BlindDateGenerator]   ✅ Status: ${response.status}');

      if (response.status != 200) {
        Logger.error('[BlindDateGenerator] ❌ API 호출 실패: ${response.data}');
        throw Exception('Failed to generate blind date fortune: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      Logger.info('[BlindDateGenerator]   📦 Response data keys: ${data.keys.toList()}');

      // 🔄 파싱
      Logger.info('[BlindDateGenerator] 🔄 응답 데이터 파싱 중...');
      final result = _convertToFortuneResult(data, inputConditions);

      Logger.info('[BlindDateGenerator] ✅ 파싱 완료');
      Logger.info('[BlindDateGenerator]   📝 Title: ${result.title}');
      Logger.info('[BlindDateGenerator]   ⭐ Score: ${result.score}');

      return result;
    } catch (e, stackTrace) {
      Logger.error('[BlindDateGenerator] ❌ 소개팅 운세 생성 실패', e, stackTrace);
      rethrow;
    }
  }

  /// Edge Function 응답을 FortuneResult로 변환
  static FortuneResult _convertToFortuneResult(
    Map<String, dynamic> data,
    Map<String, dynamic> inputConditions,
  ) {
    // Edge Function에서 반환된 데이터 구조
    final fortuneData = data['fortune_data'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as String? ?? '';
    final summary = data['summary'] as String? ?? '';
    final score = data['score'] as int?;

    return FortuneResult(
      type: 'blind_date',
      title: '소개팅 운세',
      summary: {
        'message': summary,
        'score': score,
        'meeting_info': {
          'date': inputConditions['meeting_date'],
          'time': inputConditions['meeting_time'],
          'type': inputConditions['meeting_type'],
        },
      },
      data: {
        'content': content,
        'fortune_data': fortuneData,
        'meeting_date': inputConditions['meeting_date'],
        'meeting_time': inputConditions['meeting_time'],
        'meeting_type': inputConditions['meeting_type'],
        'confidence': inputConditions['confidence'],
        'has_photo_analysis': inputConditions['my_photos'] != null ||
                             inputConditions['partner_photos'] != null,
        'has_chat_analysis': inputConditions['chat_content'] != null,
      },
      score: score,
      createdAt: DateTime.now(),
    );
  }
}
