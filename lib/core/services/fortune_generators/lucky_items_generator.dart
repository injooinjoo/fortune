import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/fortune_result.dart';

/// 행운 아이템 운세 Generator
class LuckyItemsGenerator {
  /// 행운 아이템 운세 생성 (API 호출)
  static Future<FortuneResult> generate(
    Map<String, dynamic> inputConditions,
    SupabaseClient supabase,
  ) async {
    // 사용자 정보 가져오기
    final user = supabase.auth.currentUser;
    final userProfile = user != null
        ? await supabase
            .from('user_profiles')
            .select('name')
            .eq('id', user.id)
            .maybeSingle()
        : null;

    final name = userProfile?['name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        inputConditions['name'] ??
        'Guest';

    // Edge Function 호출을 위한 payload 생성
    final payload = {
      'userId': user?.id ?? 'anonymous',
      'name': name,
      'birthDate': inputConditions['birthDate'],
      if (inputConditions['birthTime'] != null)
        'birthTime': inputConditions['birthTime'],
      if (inputConditions['gender'] != null) 'gender': inputConditions['gender'],
      if (inputConditions['interests'] != null)
        'interests': inputConditions['interests'],
    };

    // fortune-lucky-items Edge Function 호출
    final response = await supabase.functions.invoke(
      'fortune-lucky-items',
      body: payload,
    );

    // 에러 체크
    if (response.data == null) {
      throw Exception('Failed to generate lucky items fortune');
    }

    // 응답 데이터 추출
    final responseData = response.data as Map<String, dynamic>;

    // FortuneResult 생성
    return FortuneResult(
      type: 'lucky_items',
      title: responseData['title'] as String? ?? '행운 아이템',
      summary: {
        'element': responseData['element'],
        'keyword': responseData['keyword'],
        'summary': responseData['summary'],
      },
      data: responseData,
      score: (responseData['score'] as num?)?.toInt() ?? 75,
      createdAt: DateTime.now(),
    );
  }
}
