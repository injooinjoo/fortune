import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config/environment.dart';
import '../../core/config/feature_flags.dart';
import '../../core/constants/edge_functions_endpoints.dart';
import '../../domain/entities/fortune.dart';
import '../models/fortune_response_model.dart';
import '../../presentation/providers/providers.dart';
import '../../services/weather_service.dart';
import 'fortune_api_service.dart';

/// Extended FortuneApiService that supports Edge Functions
class FortuneApiServiceWithEdgeFunctions extends FortuneApiService {
  final FeatureFlags _featureFlags = FeatureFlags.instance;
  final Ref _ref;

  /// 복잡한 LLM 프롬프트로 인해 더 긴 타임아웃이 필요한 운세 타입들
  /// 이 타입들은 8192+ 토큰 출력 또는 복잡한 JSON 구조를 생성함
  static const _complexFortuneTypes = [
    'talent', // 8192 토큰, 주간 계획 + 성장 로드맵
    'blind-date', // 상세 분석 + 대화 주제 + 패션 조언
    'career', // 커리어 분석 + 추천 사항
    'investment', // 투자 분석 + 예측
    'ex-lover', // 감정 분석 + 조언
    'celebrity', // 유명인 궁합: 사주분석 + 전생인연 + 속궁합 등 상세 콘텐츠
    'love', // 23초 소요 확인됨 (경계 수준)
    'avoid-people', // 15-18초 소요 확인됨
    'new-year', // 22-28초 소요, 12개월 월별 운세 + 목표별 분석
    'yearly', // new-year와 동일 (getYearlyFortune에서 사용)
    'face-reading', // 이미지 업로드 + AI 관상 분석 (Vision API 호출)
    'past-life', // 이미지 업로드 + 전생 분석
  ];

  FortuneApiServiceWithEdgeFunctions(this._ref)
      : super(_ref.read(apiClientProvider));

  late final Dio _edgeFunctionsDio = _createEdgeFunctionsDio();

  Dio _createEdgeFunctionsDio() {
    return Dio(
      BaseOptions(
        baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  Map<String, dynamic> _buildEdgeHeaders() {
    if (Environment.supabaseAnonKey.isEmpty) {
      debugPrint('❌ [_buildEdgeHeaders] SUPABASE_ANON_KEY is missing!');
      throw Exception(
        'SUPABASE_ANON_KEY is not configured. Please check your environment settings.',
      );
    }

    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'apikey': Environment.supabaseAnonKey,
    };

    if (!kIsWeb) {
      headers['x-requested-with'] = 'XMLHttpRequest';
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    return headers;
  }

  Options _buildEdgeRequestOptions({Duration? timeout}) {
    return Options(
      headers: _buildEdgeHeaders(),
      sendTimeout: timeout,
      receiveTimeout: timeout,
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// 안전한 int 파싱 - int, num, String 모두 처리
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// 이름 유효성 검사 - "undefined", "null", 빈 문자열 등 처리
  static String _sanitizeName(dynamic name) {
    const invalidNames = ['undefined', 'null', 'Unknown', ''];
    if (name == null) return '회원';
    final nameStr = name.toString().trim();
    if (invalidNames.contains(nameStr)) return '회원';
    return nameStr;
  }

  /// Get weather info optionally (doesn't fail if location permission denied)
  Future<WeatherInfo?> _getWeatherInfoOptional() async {
    try {
      // Check location permission without requesting
      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Don't request permission, just return null
        debugPrint('📍 Location permission not granted, skipping location');
        return null;
      }

      // If permission is granted, try to get weather
      return await WeatherService.getCurrentWeather();
    } catch (e) {
      debugPrint('📍 Could not get location/weather: $e');
      return null;
    }
  }

  /// Override the base method to use Edge Functions when enabled
  @override
  Future<Fortune> getDailyFortune(
      {required String userId, DateTime? date}) async {
    debugPrint(
        '🔍 [FortuneApiServiceWithEdgeFunctions] getDailyFortune called');
    // Edge Functions are being used
    debugPrint('enabled: ${_featureFlags.isEdgeFunctionsEnabled()}');

    if (_featureFlags.isEdgeFunctionsEnabled()) {
      debugPrint(
          '🔍 [FortuneApiServiceWithEdgeFunctions] Using Edge Functions for daily fortune');
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.dailyFortune,
          userId: userId,
          fortuneType: 'daily',
          data: {if (date != null) 'date': date.toIso8601String()});
    }

    // Fall back to original implementation
    debugPrint(
        '🔍 [FortuneApiServiceWithEdgeFunctions] Falling back to traditional API');
    return super.getDailyFortune(userId: userId, date: date);
  }

  /// Generic method to get fortune from Edge Functions
  Future<Fortune> _getFortuneFromEdgeFunction(
      {required String endpoint,
      required String userId,
      required String fortuneType,
      Map<String, dynamic>? data}) async {
    try {
      debugPrint(
          '📡 [FortuneApiServiceWithEdgeFunctions] Calling Edge Function');
      debugPrint(
          'endpoint: $endpoint, userId: $userId, fortuneType: $fortuneType');

      // 게스트 사용자 체크 - guest_ 접두사가 있으면 DB 쿼리 스킵
      final isGuest = userId.startsWith('guest_');
      if (isGuest) {
        debugPrint('👤 [GUEST] 게스트 사용자 감지 - DB 쿼리 스킵');
      }

      // Get user profile and saju data in parallel (게스트는 스킵)
      final supabase = Supabase.instance.client;
      Map<String, dynamic>? userProfileResponse;
      Map<String, dynamic>? sajuData;

      if (!isGuest) {
        // 🚀 병렬 쿼리 실행 (성능 최적화: ~300ms 절약)
        final queryResults = await Future.wait([
          supabase
              .from('user_profiles')
              .select(
                  'name, birth_date, birth_time, gender, mbti, blood_type, zodiac_sign, chinese_zodiac, saju_calculated')
              .eq('id', userId)
              .maybeSingle(),
          supabase
              .from('user_saju')
              .select('*')
              .eq('user_id', userId)
              .maybeSingle(),
        ]);

        userProfileResponse = queryResults[0];
        final sajuResponse = queryResults[1];

        debugPrint(
            '👤 [PROFILE] user_profiles: ${userProfileResponse != null ? '✅' : '❌'}, user_saju: ${sajuResponse != null ? '✅' : '❌'}');

        // Saju 데이터 변환
        if (sajuResponse != null) {
          sajuData = {
            ...sajuResponse,
            // 천간(stem) + 지지(branch) 결합하여 pillar 형태 추가
            'year_pillar':
                '${sajuResponse['year_stem'] ?? ''}${sajuResponse['year_branch'] ?? ''}',
            'month_pillar':
                '${sajuResponse['month_stem'] ?? ''}${sajuResponse['month_branch'] ?? ''}',
            'day_pillar':
                '${sajuResponse['day_stem'] ?? ''}${sajuResponse['day_branch'] ?? ''}',
            'hour_pillar':
                '${sajuResponse['hour_stem'] ?? ''}${sajuResponse['hour_branch'] ?? ''}',
            // 일간 (day master) = 일주의 천간
            'day_master': sajuResponse['day_stem'],
            // 오행 균형 데이터 매핑
            'five_elements': {
              '목': sajuResponse['element_wood'] ?? 0,
              '화': sajuResponse['element_fire'] ?? 0,
              '토': sajuResponse['element_earth'] ?? 0,
              '금': sajuResponse['element_metal'] ?? 0,
              '수': sajuResponse['element_water'] ?? 0,
            },
            // 부족/강한 오행
            'weak_element': sajuResponse['weak_element'],
            'strong_element': sajuResponse['strong_element'],
          };
        }
      } else {
        debugPrint('👤 [GUEST] 게스트 사용자 - DB 쿼리 스킵');
      }

      // Debug info

      // Get location info if available (optional)
      String? userLocation;
      try {
        final weatherInfo = await _getWeatherInfoOptional();
        userLocation = weatherInfo?.cityName;
      } catch (e) {
        // Location is optional, continue without it
        debugPrint('📍 Location not available (optional): $e');
      }

      // Prepare request data
      final requestData = {
        ...?data,
        'userId': userId,
        if (userProfileResponse != null) ...{
          'name': _sanitizeName(userProfileResponse['name']),
          'birthDate': userProfileResponse['birth_date'],
          'birthTime': userProfileResponse['birth_time'],
          'gender': userProfileResponse['gender'],
          'isLunar': false, // Default to false as column doesn't exist yet
          'mbtiType': userProfileResponse['mbti'],
          'bloodType': userProfileResponse['blood_type'],
          'zodiacSign': userProfileResponse['zodiac_sign'],
          'zodiacAnimal': userProfileResponse['chinese_zodiac'],
          'sajuCalculated': userProfileResponse['saju_calculated'] ?? false
        },
        if (sajuData != null) 'sajuData': sajuData,
        if (userLocation != null) 'location': userLocation,
        'isSubscriber': true,
      };

      // 📤 API 요청 요약 (개인정보 제외)
      debugPrint('📤 [API REQUEST] keys: ${requestData.keys.toList()}');
      debugPrint(
          '📤 [API REQUEST] sajuData: ${requestData['sajuData'] != null ? '✅' : '❌'}, isSubscriber: ${requestData['isSubscriber']}');

      // Create a custom Dio instance for Edge Functions
      debugPrint('URL: ${EdgeFunctionsEndpoints.currentBaseUrl}');
      // Debug info
      // Debug info

      // 복잡한 운세 타입은 더 긴 타임아웃 필요 (LLM 응답 시간이 길음)
      final isComplexFortune = _complexFortuneTypes.contains(fortuneType);
      final timeout = isComplexFortune
          ? const Duration(
              seconds:
                  90) // 복잡한 운세: 90초 (fortune-love가 23초, fortune-talent는 25-40초 예상)
          : const Duration(seconds: 30); // 일반 운세: 30초

      if (isComplexFortune) {
        debugPrint(
            '⏱️ [_getFortuneFromEdgeFunction] Complex fortune type detected: $fortuneType');
        debugPrint(
            '⏱️ [_getFortuneFromEdgeFunction] Using extended timeout: ${timeout.inSeconds}s');
      }
      // API 키 존재 확인 (보안상 키 값은 로깅하지 않음)
      debugPrint(
          '📡 [API] Supabase key: ${Environment.supabaseAnonKey.isNotEmpty ? '✅' : '❌'}');

      // Get auth token from Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      debugPrint('present: ${session != null}');

      if (session == null) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] No active session found!');
        throw Exception('No active session. Please login first.');
      }

      final stopwatch = Stopwatch()..start();
      final response = await _edgeFunctionsDio.post(
        endpoint,
        data: requestData,
        options: _buildEdgeRequestOptions(timeout: timeout),
      );
      stopwatch.stop();

      debugPrint(
          '📥 [API RESPONSE] Edge Function 응답 받음 (${stopwatch.elapsedMilliseconds}ms)');
      debugPrint('📥 [API RESPONSE] - status: ${response.statusCode}');

      // 📥 RAW 응답 데이터 로깅 (디버깅용)
      debugPrint(
          '📥 [API RESPONSE RAW] 전체 응답 키: ${response.data?.keys?.toList()}');
      if (response.data != null && response.data is Map) {
        final rawData = response.data as Map<String, dynamic>;
        debugPrint('📥 [API RESPONSE RAW] success: ${rawData['success']}');
        if (rawData['data'] != null) {
          final data = rawData['data'];
          debugPrint(
              '📥 [API RESPONSE RAW] data 키: ${data is Map ? data.keys.toList() : 'Not a Map'}');
          if (data is Map) {
            debugPrint(
                '📥 [API RESPONSE RAW] data.overallScore: ${data['overallScore']}');
            debugPrint(
                '📥 [API RESPONSE RAW] data.content: ${(data['content'] ?? '').toString().substring(0, (data['content']?.toString().length ?? 0).clamp(0, 100))}...');
          }
        }
        if (rawData['fortune'] != null) {
          final fortune = rawData['fortune'];
          debugPrint(
              '📥 [API RESPONSE RAW] fortune 키: ${fortune is Map ? fortune.keys.toList() : 'Not a Map'}');
        }
        if (rawData['error'] != null) {
          debugPrint('📥 [API RESPONSE RAW] ❌ error: ${rawData['error']}');
        }
      }

      // Edge Functions return different formats depending on the function
      // Extracting fortune data from response...

      if (response.data == null) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] Response data is null!');
        throw Exception('Empty response from Edge Function');
      }

      if (response.data is! Map) {
        debugPrint(
            '❌ [_getFortuneFromEdgeFunction] Response data is not a Map! Type: ${response.data.runtimeType}');
        throw Exception('Invalid response format from Edge Function');
      }

      // Edge Functions return different formats:
      // 1. { success: true, data: {...} } - Standard format
      // 2. { fortune: {...} } - Legacy format
      // 3. Direct data: { sections, summary, ... } - New format (no wrapper)
      Map<String, dynamic> fortuneData;
      int tokensUsed = 0;

      final responseMap = response.data as Map<String, dynamic>;

      if (responseMap.containsKey('fortune')) {
        // Format 2: { fortune: {...} }
        fortuneData = responseMap['fortune'] as Map<String, dynamic>;
        tokensUsed = responseMap['tokensUsed'] ?? 0;
        debugPrint(
            '✅ [_getFortuneFromEdgeFunction] Fortune data extracted with key: fortune');
      } else if (responseMap.containsKey('success') &&
          responseMap.containsKey('data')) {
        // Format 1: { success: true, data: {...} }
        fortuneData = responseMap['data'] as Map<String, dynamic>;
        tokensUsed = responseMap['tokensUsed'] ?? 0;
        debugPrint(
            '✅ [_getFortuneFromEdgeFunction] Fortune data extracted with key: data');
      } else if (responseMap.containsKey('sections') ||
          responseMap.containsKey('summary') ||
          responseMap.containsKey('overallScore') ||
          responseMap.containsKey('content')) {
        // Format 3: Direct data (response itself is the fortune data)
        fortuneData = responseMap;
        tokensUsed = responseMap['tokensUsed'] ?? 0;
        debugPrint(
            '✅ [_getFortuneFromEdgeFunction] Fortune data is direct response (no wrapper)');
      } else {
        debugPrint('❌ [_getFortuneFromEdgeFunction] Unknown response format!');
        debugPrint(
            '📥 [_getFortuneFromEdgeFunction] Response keys: ${responseMap.keys.toList()}');
        throw Exception('Unknown response format from Edge Function');
      }

      // 📥 운세 응답 데이터 상세 로깅
      debugPrint('📥 [API RESPONSE] 운세 데이터 상세:');
      final extractedScore = fortuneData['score'] ??
          fortuneData['overall_score'] ??
          fortuneData['overallScore'];
      final extractedContent =
          fortuneData['content'] ?? fortuneData['description'] ?? '';
      debugPrint('📥 [API RESPONSE] - score: $extractedScore');
      debugPrint(
          '📥 [API RESPONSE] - content 길이: ${extractedContent.toString().length}');
      debugPrint(
          '📥 [API RESPONSE] - content 미리보기: ${extractedContent.toString().substring(0, extractedContent.toString().length.clamp(0, 100))}...');
      debugPrint(
          '📥 [API RESPONSE] - sajuPillars 존재: ${fortuneData['sajuPillars'] != null}');
      debugPrint(
          '📥 [API RESPONSE] - todaySaju 존재: ${fortuneData['todaySaju'] != null}');
      debugPrint(
          '📥 [API RESPONSE] - fiveElements 존재: ${fortuneData['fiveElements'] != null}');
      debugPrint(
          '📥 [API RESPONSE] - successPrediction 존재: ${fortuneData['successPrediction'] != null}');
      debugPrint(
          '📥 [API RESPONSE] - firstImpressionTips 존재: ${fortuneData['firstImpressionTips'] != null}');
      if (fortuneData['sajuPillars'] != null) {
        debugPrint(
            '📥 [API RESPONSE] - sajuPillars: ${fortuneData['sajuPillars']}');
      }
      if (fortuneData['todaySaju'] != null) {
        debugPrint(
            '📥 [API RESPONSE] - todaySaju: ${fortuneData['todaySaju']}');
      }
      if (fortuneData['successPrediction'] != null) {
        debugPrint(
            '📥 [API RESPONSE] - successPrediction: ${fortuneData['successPrediction']}');
      }

      // Fortune data extracted and validated
      // ✅ 표준화됨: 모든 Edge Function은 이제 'score' 필드 사용
      // 하위 호환성을 위한 fallback 유지 (캐시된 데이터용)
      final extractedScoreValue = fortuneData['score'] // ✅ 표준 필드
          ??
          fortuneData['overall_score'] // 하위 호환: fortune-daily 레거시
          ??
          fortuneData['overallScore'] // 하위 호환: fortune-blind-date 레거시
          ??
          fortuneData['loveScore'] // 하위 호환: fortune-love 레거시
          ??
          fortuneData['careerScore'] // 하위 호환: fortune-career 레거시
          ??
          fortuneData['healthScore'] // 하위 호환: fortune-health 레거시
          ??
          fortuneData['compatibilityScore'] ??
          fortuneData['successScore'];

      // Convert sections/detailedAnalysis to content if needed
      String contentText = fortuneData['content'] ??
          fortuneData['description'] ??
          fortuneData['mainMessage'] // fortune-love
          ??
          '';

      if (contentText.isEmpty && fortuneData['detailedAnalysis'] != null) {
        // detailedAnalysis를 content로 변환 (fortune-love 등)
        final analysis = fortuneData['detailedAnalysis'];
        if (analysis is Map) {
          contentText =
              analysis.entries.map((e) => '${e.key}: ${e.value}').join('\n');
        } else if (analysis is String) {
          contentText = analysis;
        }
        debugPrint(
            '📝 [_getFortuneFromEdgeFunction] Converted detailedAnalysis to content');
      }

      if (contentText.isEmpty && fortuneData['sections'] != null) {
        // sections를 content로 변환
        final sections = fortuneData['sections'];
        if (sections is List) {
          contentText = sections.map((s) {
            if (s is Map) {
              return '${s['title'] ?? ''}\n${s['content'] ?? s['description'] ?? ''}';
            }
            return s.toString();
          }).join('\n\n');
        }
        debugPrint(
            '📝 [_getFortuneFromEdgeFunction] Converted sections to content (${contentText.length} chars)');
      }

      // Use summary as fallback
      if (contentText.isEmpty && fortuneData['summary'] != null) {
        final summary = fortuneData['summary'];
        if (summary is Map) {
          // summary 객체에서 의미 있는 텍스트 필드 추출
          final oneLine = summary['one_line'] ?? summary['oneLine'];
          final finalMessage =
              summary['final_message'] ?? summary['finalMessage'];
          final statusMessage =
              summary['status_message'] ?? summary['statusMessage'];
          final greeting = summary['greeting'];

          // 우선순위: one_line > final_message > status_message > greeting
          if (oneLine != null && oneLine.toString().isNotEmpty) {
            contentText = oneLine.toString();
            if (finalMessage != null && finalMessage.toString().isNotEmpty) {
              contentText += '\n\n$finalMessage';
            }
          } else if (finalMessage != null &&
              finalMessage.toString().isNotEmpty) {
            contentText = finalMessage.toString();
          } else if (statusMessage != null &&
              statusMessage.toString().isNotEmpty) {
            contentText = statusMessage.toString();
          } else if (greeting != null && greeting.toString().isNotEmpty) {
            contentText = greeting.toString();
          } else {
            // 모든 필드가 없으면 Map의 값들을 조합
            contentText = summary.values
                .where(
                    (v) => v != null && v is! List && v.toString().isNotEmpty)
                .join('\n\n');
          }
          debugPrint(
              '📝 [_getFortuneFromEdgeFunction] Extracted summary content from Map');
        } else {
          contentText = summary.toString();
        }
        debugPrint(
            '📝 [_getFortuneFromEdgeFunction] Using summary as content fallback (${contentText.length} chars)');
      }

      // Compatibility fortune: build rich content from detailed fields
      if (fortuneType == 'compatibility' &&
          fortuneData['overall_compatibility'] != null) {
        final contentParts = <String>[];

        if (fortuneData['overall_compatibility'] != null) {
          contentParts
              .add('💕 전반적인 궁합\n${fortuneData['overall_compatibility']}');
        }

        final zodiacAnimal = fortuneData['zodiac_animal'];
        if (zodiacAnimal != null && zodiacAnimal is Map) {
          contentParts.add(
              '\n\n🐉 띠 궁합\n${zodiacAnimal['person1']} ♥ ${zodiacAnimal['person2']}: ${zodiacAnimal['message']} (${zodiacAnimal['score']}점)');
        }

        final starSign = fortuneData['star_sign'];
        if (starSign != null && starSign is Map) {
          contentParts.add(
              '\n\n⭐ 별자리 궁합\n${starSign['person1']} ♥ ${starSign['person2']}: ${starSign['message']} (${starSign['score']}점)');
        }

        final destinyNumber = fortuneData['destiny_number'];
        if (destinyNumber != null && destinyNumber is Map) {
          contentParts.add(
              '\n\n🔮 운명수: ${destinyNumber['number']} - ${destinyNumber['meaning']}');
        }

        final ageDiff = fortuneData['age_difference'];
        if (ageDiff != null && ageDiff is Map) {
          contentParts.add(
              '\n\n👫 나이 차이: ${ageDiff['years']}살 - ${ageDiff['message']}');
        }

        if (fortuneData['personality_match'] != null) {
          contentParts.add('\n\n💜 성격 궁합\n${fortuneData['personality_match']}');
        }

        if (fortuneData['love_match'] != null) {
          contentParts.add('\n\n💘 애정 궁합\n${fortuneData['love_match']}');
        }

        if (fortuneData['marriage_match'] != null) {
          contentParts.add('\n\n💍 결혼 궁합\n${fortuneData['marriage_match']}');
        }

        if (fortuneData['communication_match'] != null) {
          contentParts
              .add('\n\n💬 소통 궁합\n${fortuneData['communication_match']}');
        }

        final loveStyle = fortuneData['love_style'];
        if (loveStyle != null && loveStyle is Map) {
          contentParts.add(
              '\n\n💝 연애 스타일\n${loveStyle['person1']} × ${loveStyle['person2']}\n${loveStyle['조합분석'] ?? ''}');
        }

        final strengths = fortuneData['strengths'];
        if (strengths != null && strengths is List && strengths.isNotEmpty) {
          contentParts.add('\n\n✨ 강점\n• ${strengths.join('\n• ')}');
        }

        final cautions = fortuneData['cautions'];
        if (cautions != null && cautions is List && cautions.isNotEmpty) {
          contentParts.add('\n\n⚠️ 주의점\n• ${cautions.join('\n• ')}');
        }

        if (fortuneData['detailed_advice'] != null) {
          contentParts.add('\n\n💡 조언\n${fortuneData['detailed_advice']}');
        }

        if (contentParts.isNotEmpty) {
          contentText = contentParts.join('');
          debugPrint(
              '📝 [_getFortuneFromEdgeFunction] Built compatibility content (${contentText.length} chars)');
        }
      }

      // Blind-date fortune: build rich content from detailed fields
      if (fortuneType == 'blind-date' &&
          fortuneData['successPrediction'] != null) {
        final contentParts = <String>[];

        // successPrediction - object에서 추출
        final successPred = fortuneData['successPrediction'];
        if (successPred != null) {
          if (successPred is Map) {
            final message = successPred['message'] ?? '';
            final advice = successPred['advice'] ?? '';
            contentParts.add(
                '🎯 성공 예측\n$message${advice.isNotEmpty ? '\n💡 $advice' : ''}');
          } else {
            contentParts.add('🎯 성공 예측\n$successPred');
          }
        }

        // firstImpressionTips - array 처리
        final tips = fortuneData['firstImpressionTips'];
        if (tips != null) {
          if (tips is List && tips.isNotEmpty) {
            contentParts.add('\n\n✨ 첫인상 팁\n• ${tips.join('\n• ')}');
          } else if (tips is String && tips.isNotEmpty) {
            contentParts.add('\n\n✨ 첫인상 팁\n$tips');
          }
        }

        // conversationTopics - object 또는 array 처리
        final topics = fortuneData['conversationTopics'];
        if (topics != null) {
          if (topics is Map) {
            final recommended = topics['recommended'];
            final avoid = topics['avoid'];
            if (recommended is List && recommended.isNotEmpty) {
              contentParts
                  .add('\n\n💬 추천 대화 주제\n• ${recommended.join('\n• ')}');
            }
            if (avoid is List && avoid.isNotEmpty) {
              contentParts.add('\n\n🚫 피해야 할 주제\n• ${avoid.join('\n• ')}');
            }
          } else if (topics is List && topics.isNotEmpty) {
            contentParts.add('\n\n💬 대화 주제\n• ${topics.join('\n• ')}');
          }
        }

        // outfitAdvice - object에서 추출
        final outfit = fortuneData['outfitAdvice'];
        if (outfit != null) {
          if (outfit is Map) {
            final style = outfit['style'] ?? '';
            final colors = outfit['colors'];
            final colorText = colors is List && colors.isNotEmpty
                ? ' (추천 색상: ${colors.join(', ')})'
                : '';
            if (style.toString().isNotEmpty) {
              contentParts.add('\n\n👔 패션 조언\n$style$colorText');
            }
          } else if (outfit is String && outfit.isNotEmpty) {
            contentParts.add('\n\n👔 패션 조언\n$outfit');
          }
        }

        // locationAdvice - array 처리
        final locations = fortuneData['locationAdvice'];
        if (locations != null) {
          if (locations is List && locations.isNotEmpty) {
            contentParts.add('\n\n📍 장소 추천\n• ${locations.join('\n• ')}');
          } else if (locations is String && locations.isNotEmpty) {
            contentParts.add('\n\n📍 장소 추천\n$locations');
          }
        }

        final dosList = fortuneData['dosList'];
        if (dosList != null && dosList is List && dosList.isNotEmpty) {
          contentParts.add('\n\n✅ 이렇게 하세요\n• ${dosList.join('\n• ')}');
        }

        final dontsList = fortuneData['dontsList'];
        if (dontsList != null && dontsList is List && dontsList.isNotEmpty) {
          contentParts.add('\n\n❌ 이건 피하세요\n• ${dontsList.join('\n• ')}');
        }

        if (fortuneData['finalMessage'] != null) {
          contentParts.add('\n\n💝 마무리 메시지\n${fortuneData['finalMessage']}');
        }

        if (contentParts.isNotEmpty) {
          contentText = contentParts.join('');
          debugPrint(
              '📝 [_getFortuneFromEdgeFunction] Built blind-date content (${contentText.length} chars)');
        }
      }

      // Ex-lover fortune: build rich content from detailed fields
      // API 응답 필드: hardTruth, theirPerspective, strategicAdvice, emotionalPrescription,
      // reunionAssessment, closingMessage, personalizedAnalysis, newBeginning, milestones
      if (fortuneType == 'ex-lover') {
        final contentParts = <String>[];

        // 1. 개인화된 분석 (Opening)
        final personalizedAnalysis = fortuneData['personalizedAnalysis'];
        if (personalizedAnalysis is Map) {
          final opening = personalizedAnalysis['opening'];
          if (opening != null && opening.toString().isNotEmpty) {
            contentParts.add('💜 $opening');
          }
          final insights = personalizedAnalysis['insights'];
          if (insights is List && insights.isNotEmpty) {
            contentParts.add('\n\n📌 핵심 인사이트\n• ${insights.join('\n• ')}');
          }
          final callout = personalizedAnalysis['callout'];
          if (callout != null && callout.toString().isNotEmpty) {
            contentParts.add('\n\n⚡ $callout');
          }
        }

        // 2. 냉정한 진실 (Hard Truth) - 가장 중요한 섹션
        final hardTruth = fortuneData['hardTruth'];
        if (hardTruth is Map) {
          contentParts.add('\n\n💔 냉정한 진실');
          if (hardTruth['headline'] != null) {
            contentParts.add('\n\n"${hardTruth['headline']}"');
          }
          if (hardTruth['diagnosis'] != null) {
            contentParts.add('\n\n${hardTruth['diagnosis']}');
          }
          if (hardTruth['realityCheck'] != null) {
            contentParts.add('\n\n🔍 현실 체크\n${hardTruth['realityCheck']}');
          }
          if (hardTruth['mostImportantAdvice'] != null) {
            contentParts
                .add('\n\n💡 가장 중요한 조언\n${hardTruth['mostImportantAdvice']}');
          }
        } else if (hardTruth is String && hardTruth.isNotEmpty) {
          contentParts.add('\n\n💔 냉정한 진실\n$hardTruth');
        }

        // 3. 재회 가능성 분석 (Reunion Assessment)
        final reunionAssessment = fortuneData['reunionAssessment'];
        if (reunionAssessment is Map) {
          final score = reunionAssessment['score'];
          contentParts.add('\n\n📊 재회 가능성 분석');
          if (score != null) {
            contentParts.add('\n\n재회 가능성: $score%');
          }
          final keyFactors = reunionAssessment['keyFactors'];
          if (keyFactors is List && keyFactors.isNotEmpty) {
            contentParts.add('\n\n핵심 요인:\n• ${keyFactors.join('\n• ')}');
          }
          if (reunionAssessment['timing'] != null) {
            contentParts.add('\n\n⏰ 타이밍\n${reunionAssessment['timing']}');
          }
          if (reunionAssessment['approach'] != null) {
            contentParts.add('\n\n🎯 접근 방법\n${reunionAssessment['approach']}');
          }
          final neverDo = reunionAssessment['neverDo'];
          if (neverDo is List && neverDo.isNotEmpty) {
            contentParts.add('\n\n🚫 절대 하지 말아야 할 것\n• ${neverDo.join('\n• ')}');
          }
        }

        // 4. 상대방 관점 (Their Perspective)
        final theirPerspective = fortuneData['theirPerspective'];
        if (theirPerspective is Map) {
          contentParts.add('\n\n💭 상대방의 마음');
          if (theirPerspective['likelyThoughts'] != null) {
            contentParts
                .add('\n\n그 사람의 감정:\n${theirPerspective['likelyThoughts']}');
          }
          if (theirPerspective['doTheyThinkOfYou'] != null) {
            contentParts.add(
                '\n\n나를 생각하고 있을까?\n${theirPerspective['doTheyThinkOfYou']}');
          }
          if (theirPerspective['unspokenWords'] != null) {
            contentParts
                .add('\n\n말하지 못한 것들:\n${theirPerspective['unspokenWords']}');
          }
        } else if (theirPerspective is String && theirPerspective.isNotEmpty) {
          contentParts.add('\n\n💭 상대방의 마음\n$theirPerspective');
        }

        // 5. 감정 처방전 (Emotional Prescription)
        final emotionalPrescription = fortuneData['emotionalPrescription'];
        if (emotionalPrescription is Map) {
          contentParts.add('\n\n💊 감정 처방전');
          if (emotionalPrescription['currentStateAnalysis'] != null) {
            contentParts.add(
                '\n\n현재 상태 분석:\n${emotionalPrescription['currentStateAnalysis']}');
          }
          if (emotionalPrescription['healingFocus'] != null) {
            contentParts
                .add('\n\n치유 포인트:\n${emotionalPrescription['healingFocus']}');
          }
          final dailyPractice = emotionalPrescription['dailyPractice'];
          if (dailyPractice is List && dailyPractice.isNotEmpty) {
            contentParts.add('\n\n매일 실천하기:\n• ${dailyPractice.join('\n• ')}');
          } else if (dailyPractice is String && dailyPractice.isNotEmpty) {
            contentParts.add('\n\n매일 실천하기:\n$dailyPractice');
          }
        } else if (emotionalPrescription is String &&
            emotionalPrescription.isNotEmpty) {
          contentParts.add('\n\n💊 감정 처방전\n$emotionalPrescription');
        }

        // 6. 전략적 조언 (Strategic Advice)
        final strategicAdvice = fortuneData['strategicAdvice'];
        if (strategicAdvice is Map) {
          contentParts.add('\n\n🎯 전략적 조언');
          final shortTerm = strategicAdvice['shortTerm'];
          if (shortTerm is List && shortTerm.isNotEmpty) {
            contentParts.add('\n\n📅 1주일 내 할 일:\n• ${shortTerm.join('\n• ')}');
          } else if (shortTerm is String && shortTerm.isNotEmpty) {
            contentParts.add('\n\n📅 1주일 내 할 일:\n$shortTerm');
          }
          if (strategicAdvice['midTerm'] != null) {
            contentParts.add('\n\n📆 1개월 목표:\n${strategicAdvice['midTerm']}');
          }
          if (strategicAdvice['critical'] != null) {
            contentParts
                .add('\n\n⚠️ 가장 중요한 것:\n${strategicAdvice['critical']}');
          }
        } else if (strategicAdvice is String && strategicAdvice.isNotEmpty) {
          contentParts.add('\n\n🎯 전략적 조언\n$strategicAdvice');
        }

        // 7. 새로운 시작 (New Beginning) - new_start 목표인 경우
        final newBeginning = fortuneData['newBeginning'];
        if (newBeginning is Map) {
          contentParts.add('\n\n🌱 새로운 시작 준비');
          if (newBeginning['readinessScore'] != null) {
            contentParts.add('\n\n준비도: ${newBeginning['readinessScore']}%');
          }
          if (newBeginning['unresolvedEmotions'] != null) {
            contentParts
                .add('\n\n미해결 감정:\n${newBeginning['unresolvedEmotions']}');
          }
          if (newBeginning['growthOpportunity'] != null) {
            contentParts
                .add('\n\n성장 기회:\n${newBeginning['growthOpportunity']}');
          }
          if (newBeginning['nextRelationshipFocus'] != null) {
            contentParts.add(
                '\n\n다음 연애에서 중요한 것:\n${newBeginning['nextRelationshipFocus']}');
          }
        }

        // 8. 이정표 (Milestones)
        final milestones = fortuneData['milestones'];
        if (milestones is Map) {
          contentParts.add('\n\n🚩 회복 이정표');
          if (milestones['shortTerm'] != null) {
            contentParts.add('\n\n1주 후: ${milestones['shortTerm']}');
          }
          if (milestones['midTerm'] != null) {
            contentParts.add('\n1개월 후: ${milestones['midTerm']}');
          }
          if (milestones['longTerm'] != null) {
            contentParts.add('\n3개월 후: ${milestones['longTerm']}');
          }
        }

        // 9. 마무리 메시지 (Closing Message)
        final closingMessage = fortuneData['closingMessage'];
        if (closingMessage is Map) {
          contentParts.add('\n\n💝 마무리');
          if (closingMessage['empathy'] != null) {
            contentParts.add('\n\n${closingMessage['empathy']}');
          }
          if (closingMessage['todayAction'] != null) {
            contentParts.add('\n\n오늘 할 일: ${closingMessage['todayAction']}');
          }
          if (closingMessage['reminder'] != null) {
            contentParts.add('\n\n기억하세요: ${closingMessage['reminder']}');
          }
        } else if (closingMessage is String && closingMessage.isNotEmpty) {
          contentParts.add('\n\n💝 $closingMessage');
        }

        // comfort_message fallback
        if (fortuneData['comfort_message'] != null && closingMessage == null) {
          contentParts.add('\n\n💝 ${fortuneData['comfort_message']}');
        }

        if (contentParts.isNotEmpty) {
          contentText = contentParts.join('');
          debugPrint(
              '📝 [_getFortuneFromEdgeFunction] Built ex-lover content (${contentText.length} chars)');
        }
      }

      // Wish fortune: build content from analyze-wish response fields
      // 응답 필드: empathy_message, hope_message, advice (List), encouragement, special_words
      if (fortuneType == 'wish' && fortuneData['empathy_message'] != null) {
        final contentParts = <String>[];

        // 공감 메시지
        if (fortuneData['empathy_message'] != null) {
          contentParts.add('💝 공감 메시지\n${fortuneData['empathy_message']}');
        }

        // 희망 메시지
        if (fortuneData['hope_message'] != null) {
          contentParts.add('\n\n🌟 희망\n${fortuneData['hope_message']}');
        }

        // 조언 (List<String> 처리)
        final advice = fortuneData['advice'];
        if (advice != null) {
          if (advice is List && advice.isNotEmpty) {
            contentParts.add('\n\n💡 조언\n• ${advice.join('\n• ')}');
          } else if (advice is String && advice.isNotEmpty) {
            contentParts.add('\n\n💡 조언\n$advice');
          }
        }

        // 응원 메시지
        if (fortuneData['encouragement'] != null) {
          contentParts.add('\n\n🔥 응원\n${fortuneData['encouragement']}');
        }

        // 신의 한마디
        if (fortuneData['special_words'] != null) {
          contentParts.add('\n\n✨ 신의 한마디\n${fortuneData['special_words']}');
        }

        if (contentParts.isNotEmpty) {
          contentText = contentParts.join('');
          debugPrint(
              '📝 [_getFortuneFromEdgeFunction] Built wish content (${contentText.length} chars)');
        }
      }

      // Moving fortune: build content from detailed fields
      if (fortuneType == 'moving') {
        final contentParts = <String>[];

        // 1. 제목 및 전체 운세
        final title = fortuneData['title'];
        if (title != null && title.toString().isNotEmpty) {
          contentParts.add('🏠 $title');
        }

        final overallFortune =
            fortuneData['overall_fortune'] ?? fortuneData['overallFortune'];
        if (overallFortune != null && overallFortune.toString().isNotEmpty) {
          contentParts.add('\n\n$overallFortune');
        }

        // 2. 방향 분석
        final directionAnalysis = fortuneData['direction_analysis'] ??
            fortuneData['directionAnalysis'];
        if (directionAnalysis is Map) {
          contentParts.add('\n\n🧭 방향 분석');
          final direction = directionAnalysis['direction'];
          final directionMeaning = directionAnalysis['direction_meaning'] ??
              directionAnalysis['directionMeaning'];
          final element = directionAnalysis['element'];
          final elementEffect = directionAnalysis['element_effect'] ??
              directionAnalysis['elementEffect'];
          final compatibility = directionAnalysis['compatibility'];
          final compatibilityReason =
              directionAnalysis['compatibility_reason'] ??
                  directionAnalysis['compatibilityReason'];

          if (direction != null) contentParts.add('\n• 이사 방향: $direction 방향');
          if (directionMeaning != null) {
            contentParts.add('\n• 방위 의미: $directionMeaning');
          }
          if (element != null) contentParts.add('\n• 오행: $element');
          if (elementEffect != null) {
            contentParts.add('\n• 오행 영향: $elementEffect');
          }
          if (compatibility != null) {
            contentParts.add('\n• 궁합 점수: $compatibility점');
          }
          if (compatibilityReason != null) {
            contentParts.add('\n• 궁합 판단: $compatibilityReason');
          }
        }

        // 3. 시기 분석
        final timingAnalysis =
            fortuneData['timing_analysis'] ?? fortuneData['timingAnalysis'];
        if (timingAnalysis is Map) {
          contentParts.add('\n\n📅 시기 분석');
          final seasonLuck =
              timingAnalysis['season_luck'] ?? timingAnalysis['seasonLuck'];
          final seasonMeaning = timingAnalysis['season_meaning'] ??
              timingAnalysis['seasonMeaning'];
          final monthLuck =
              timingAnalysis['month_luck'] ?? timingAnalysis['monthLuck'];
          final recommendation = timingAnalysis['recommendation'];

          if (seasonLuck != null) contentParts.add('\n• 계절 운: $seasonLuck');
          if (seasonMeaning != null) {
            contentParts.add('\n• 계절 의미: $seasonMeaning');
          }
          if (monthLuck != null) contentParts.add('\n• 월 운세: $monthLuck점');
          if (recommendation != null) {
            contentParts.add('\n• 추천: $recommendation');
          }
        }

        // 4. 길일/흉일
        final luckyDates =
            fortuneData['lucky_dates'] ?? fortuneData['luckyDates'];
        if (luckyDates is Map) {
          contentParts.add('\n\n🗓️ 이사 길일');
          final recommendedDates =
              luckyDates['recommended_dates'] ?? luckyDates['recommendedDates'];
          final avoidDates =
              luckyDates['avoid_dates'] ?? luckyDates['avoidDates'];
          final bestTime = luckyDates['best_time'] ?? luckyDates['bestTime'];
          final reason = luckyDates['reason'];

          if (recommendedDates is List && recommendedDates.isNotEmpty) {
            contentParts.add('\n• 좋은 날: ${recommendedDates.join(', ')}');
          }
          if (avoidDates is List && avoidDates.isNotEmpty) {
            contentParts.add('\n• 피할 날: ${avoidDates.join(', ')}');
          }
          if (bestTime != null) contentParts.add('\n• 최적 시간: $bestTime');
          if (reason != null) contentParts.add('\n• 이유: $reason');
        }

        // 5. 풍수 팁
        final fengShuiTips =
            fortuneData['feng_shui_tips'] ?? fortuneData['fengShuiTips'];
        if (fengShuiTips is Map) {
          contentParts.add('\n\n🌿 풍수 인테리어 팁');
          final entrance = fengShuiTips['entrance'];
          final livingRoom =
              fengShuiTips['living_room'] ?? fengShuiTips['livingRoom'];
          final bedroom = fengShuiTips['bedroom'];
          final kitchen = fengShuiTips['kitchen'];

          if (entrance != null) contentParts.add('\n• 현관: $entrance');
          if (livingRoom != null) contentParts.add('\n• 거실: $livingRoom');
          if (bedroom != null) contentParts.add('\n• 침실: $bedroom');
          if (kitchen != null) contentParts.add('\n• 부엌: $kitchen');
        }

        // 6. 지형 분석 (terrain_analysis)
        final terrainAnalysis =
            fortuneData['terrain_analysis'] ?? fortuneData['terrainAnalysis'];
        if (terrainAnalysis is Map) {
          contentParts.add('\n\n🏔️ 지형 풍수 분석');
          final terrainType =
              terrainAnalysis['terrain_type'] ?? terrainAnalysis['terrainType'];
          final fengShuiQuality = terrainAnalysis['feng_shui_quality'] ??
              terrainAnalysis['fengShuiQuality'];
          final qualityDescription = terrainAnalysis['quality_description'] ??
              terrainAnalysis['qualityDescription'];
          final waterEnergy =
              terrainAnalysis['water_energy'] ?? terrainAnalysis['waterEnergy'];
          final mountainEnergy = terrainAnalysis['mountain_energy'] ??
              terrainAnalysis['mountainEnergy'];
          final energyFlow =
              terrainAnalysis['energy_flow'] ?? terrainAnalysis['energyFlow'];

          if (terrainType != null) contentParts.add('\n• 지형: $terrainType');
          if (fengShuiQuality != null) {
            contentParts.add('\n• 풍수 점수: $fengShuiQuality점');
          }
          if (qualityDescription != null) {
            contentParts.add('\n• 평가: $qualityDescription');
          }
          if (waterEnergy != null) contentParts.add('\n• 수기(水氣): $waterEnergy');
          if (mountainEnergy != null) {
            contentParts.add('\n• 산기(山氣): $mountainEnergy');
          }
          if (energyFlow != null) contentParts.add('\n• 기운 흐름: $energyFlow');

          // 사신사 (Four Guardians)
          final fourGuardians = terrainAnalysis['four_guardians'] ??
              terrainAnalysis['fourGuardians'];
          if (fourGuardians is Map) {
            final leftDragon = fourGuardians['left_azure_dragon'] ??
                fourGuardians['leftAzureDragon'];
            final rightTiger = fourGuardians['right_white_tiger'] ??
                fourGuardians['rightWhiteTiger'];
            final frontPhoenix = fourGuardians['front_red_phoenix'] ??
                fourGuardians['frontRedPhoenix'];
            final backTurtle = fourGuardians['back_black_turtle'] ??
                fourGuardians['backBlackTurtle'];

            if (leftDragon != null ||
                rightTiger != null ||
                frontPhoenix != null ||
                backTurtle != null) {
              contentParts.add('\n\n🐉 사신사(四神砂) 분석');
              if (leftDragon != null) {
                contentParts.add('\n• 좌청룡(東): $leftDragon');
              }
              if (rightTiger != null) {
                contentParts.add('\n• 우백호(西): $rightTiger');
              }
              if (frontPhoenix != null) {
                contentParts.add('\n• 전주작(南): $frontPhoenix');
              }
              if (backTurtle != null) {
                contentParts.add('\n• 후현무(北): $backTurtle');
              }
            }
          }
        }

        // 7. 주의사항
        final cautions = fortuneData['cautions'];
        if (cautions is Map) {
          contentParts.add('\n\n⚠️ 주의사항');
          final movingDay = cautions['moving_day'] ?? cautions['movingDay'];
          final firstWeek = cautions['first_week'] ?? cautions['firstWeek'];
          final thingsToAvoid =
              cautions['things_to_avoid'] ?? cautions['thingsToAvoid'];

          if (movingDay is List && movingDay.isNotEmpty) {
            contentParts.add('\n\n📦 이사 당일');
            for (final item in movingDay) {
              contentParts.add('\n• $item');
            }
          }
          if (firstWeek is List && firstWeek.isNotEmpty) {
            contentParts.add('\n\n🏡 입주 첫 주');
            for (final item in firstWeek) {
              contentParts.add('\n• $item');
            }
          }
          if (thingsToAvoid is List && thingsToAvoid.isNotEmpty) {
            contentParts.add('\n\n🚫 절대 금지');
            for (final item in thingsToAvoid) {
              contentParts.add('\n• $item');
            }
          }
        }

        // 8. 추천 사항
        final recommendations = fortuneData['recommendations'];
        if (recommendations is Map) {
          contentParts.add('\n\n✨ 추천 사항');
          final beforeMoving = recommendations['before_moving'] ??
              recommendations['beforeMoving'];
          final movingDayRitual = recommendations['moving_day_ritual'] ??
              recommendations['movingDayRitual'];
          final afterMoving =
              recommendations['after_moving'] ?? recommendations['afterMoving'];

          if (beforeMoving is List && beforeMoving.isNotEmpty) {
            contentParts.add('\n\n📋 이사 전 준비');
            for (final item in beforeMoving) {
              contentParts.add('\n• $item');
            }
          }
          if (movingDayRitual is List && movingDayRitual.isNotEmpty) {
            contentParts.add('\n\n🎊 이사 당일 행운 의식');
            for (final item in movingDayRitual) {
              contentParts.add('\n• $item');
            }
          }
          if (afterMoving is List && afterMoving.isNotEmpty) {
            contentParts.add('\n\n🌟 입주 후 실천');
            for (final item in afterMoving) {
              contentParts.add('\n• $item');
            }
          }
        }

        // 9. 행운 아이템
        final luckyItems =
            fortuneData['lucky_items'] ?? fortuneData['luckyItems'];
        if (luckyItems is Map) {
          contentParts.add('\n\n🍀 행운 아이템');
          final items = luckyItems['items'];
          final colors = luckyItems['colors'];
          final plants = luckyItems['plants'];

          if (items is List && items.isNotEmpty) {
            contentParts.add('\n• 행운 물건: ${items.join(', ')}');
          }
          if (colors is List && colors.isNotEmpty) {
            contentParts.add('\n• 행운 색상: ${colors.join(', ')}');
          }
          if (plants is List && plants.isNotEmpty) {
            contentParts.add('\n• 추천 식물: ${plants.join(', ')}');
          }
        }

        // 10. 마무리 메시지
        final summary = fortuneData['summary'];
        if (summary is Map) {
          final keywords = summary['keywords'];
          final finalMessage =
              summary['final_message'] ?? summary['finalMessage'];

          if (keywords is List && keywords.isNotEmpty) {
            contentParts.add('\n\n🏷️ 핵심 키워드: ${keywords.join(', ')}');
          }
          if (finalMessage != null && finalMessage.toString().isNotEmpty) {
            contentParts.add('\n\n💝 마무리\n$finalMessage');
          }
        }

        if (contentParts.isNotEmpty) {
          contentText = contentParts.join('');
          debugPrint(
              '📝 [_getFortuneFromEdgeFunction] Built moving content (${contentText.length} chars)');
        }
      }

      debugPrint(
          '📝 [_getFortuneFromEdgeFunction] Final content length: ${contentText.length}');
      debugPrint(
          '📝 [_getFortuneFromEdgeFunction] extractedScoreValue: $extractedScoreValue (type: ${extractedScoreValue.runtimeType})');

      final fortuneDataModel = FortuneData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          type: fortuneType,
          content: contentText,
          createdAt: DateTime.now(),
          metadata: fortuneData,
          score: extractedScoreValue is int
              ? extractedScoreValue
              : (extractedScoreValue is num
                  ? extractedScoreValue.toInt()
                  : null),
          summary: fortuneData['summary'] is Map
              ? (fortuneData['summary']['one_line'] ??
                  fortuneData['summary']['oneLine'] ??
                  fortuneData['summary']['status_message'] ??
                  fortuneData['summary']['statusMessage'] ??
                  fortuneData['summary']['greeting'] ??
                  fortuneData['summary']['final_message'] ??
                  fortuneData['summary']['finalMessage'])
              : fortuneData['summary'],
          // luckyItems가 Map일 때만 안전하게 접근 (Array일 경우 에러 방지)
          luckyColor: fortuneData['luckyColor'] ??
              (fortuneData['lucky_items'] is Map
                  ? fortuneData['lucky_items']['color']
                  : null) ??
              (fortuneData['luckyItems'] is Map
                  ? fortuneData['luckyItems']['color']
                  : null),
          luckyNumber: _parseToInt(fortuneData['luckyNumber']) ??
              (fortuneData['lucky_items'] is Map
                  ? _parseToInt(fortuneData['lucky_items']['number'])
                  : null) ??
              (fortuneData['luckyItems'] is Map
                  ? _parseToInt(fortuneData['luckyItems']['number'])
                  : null),
          luckyDirection: (fortuneData['lucky_items'] is Map
                  ? fortuneData['lucky_items']['direction']
                  : null) ??
              (fortuneData['luckyItems'] is Map
                  ? fortuneData['luckyItems']['direction']
                  : null),
          bestTime: (fortuneData['lucky_items'] is Map
                  ? fortuneData['lucky_items']['time']
                  : null) ??
              (fortuneData['luckyItems'] is Map
                  ? fortuneData['luckyItems']['time']
                  : null),
          advice: fortuneData['advice'] is List
              ? (fortuneData['advice'] as List)
                  .join('\n') // List → String 변환 (wish fortune 대응)
              : fortuneData['advice'],
          caution: fortuneData['caution'],
          greeting: fortuneData['greeting'],
          // hexagonScores가 Map이고 값이 int 또는 String일 때 안전하게 변환
          hexagonScores: (fortuneData['hexagonScores'] != null &&
                  fortuneData['hexagonScores'] is Map)
              ? Map<String, int>.fromEntries(
                  (fortuneData['hexagonScores'] as Map).entries.map((e) {
                  final value = e.value;
                  final intValue = value is int
                      ? value
                      : (value is String ? int.tryParse(value) : null);
                  return intValue != null
                      ? MapEntry(e.key.toString(), intValue)
                      : null;
                }).whereType<MapEntry<String, int>>())
              : null,
          timeSpecificFortunes: fortuneData['timeSpecificFortunes'],
          birthYearFortunes: fortuneData['birthYearFortunes'],
          fiveElements: fortuneData['fiveElements'],
          specialTip: fortuneData['special_tip'] ?? fortuneData['specialTip'],
          period: fortuneData['period']);

      debugPrint(
          '📝 [_getFortuneFromEdgeFunction] FortuneData.score: ${fortuneDataModel.score}');

      final fortuneResponse = FortuneResponseModel(
          success: true, data: fortuneDataModel, tokensUsed: tokensUsed);

      final fortune = fortuneResponse.toEntity();
      debugPrint(
          '📝 [_getFortuneFromEdgeFunction] Fortune.overallScore: ${fortune.overallScore}');

      return fortune;
    } catch (e) {
      // Debug info
      // Debug info

      if (e is DioException) {
        debugPrint('type: ${e.type}');
        debugPrint('data: ${e.requestOptions.data}');
        debugPrint('headers: ${e.requestOptions.headers}');
        debugPrint('URL: ${e.requestOptions.uri}');
        debugPrint('data: ${e.response?.data}');
        debugPrint('code: ${e.response?.statusCode}');
        debugPrint('headers: ${e.response?.headers}');

        // Handle specific error types
        if (e.type == DioExceptionType.connectionError) {
          debugPrint(
              '❌ [_getFortuneFromEdgeFunction] Connection error - possible CORS issue or network problem');
          debugPrint(
              '❌ [_getFortuneFromEdgeFunction] Make sure Edge Functions are deployed and accessible');
          // Debug info
        } else if (e.type == DioExceptionType.connectionTimeout) {
          debugPrint(
              '❌ [_getFortuneFromEdgeFunction] Connection timeout - server may be down or slow');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          debugPrint(
              '❌ [_getFortuneFromEdgeFunction] Receive timeout - response took too long');
        }
      }

      // If Edge Functions fail, fall back to traditional API
      debugPrint(
          '⚠️ [_getFortuneFromEdgeFunction] Edge Function failed, attempting fallback...');

      // For web platform with CORS errors, we need special handling
      if (kIsWeb &&
          e is DioException &&
          e.type == DioExceptionType.connectionError) {
        debugPrint(
            '❌ [_getFortuneFromEdgeFunction] Web platform CORS error detected');
        debugPrint(
            '💡 [_getFortuneFromEdgeFunction] Consider using proxy or server-side rendering for web platform');
      }

      // In debug mode, we might want to see the error
      if (!kReleaseMode) {
        debugPrint(
            '❌ [_getFortuneFromEdgeFunction] Rethrowing error in debug mode');
        rethrow;
      }

      // In production, throw a user-friendly error
      // We can't fall back to super.getDailyFortune here because this is a generic method
      throw Exception('운세 생성에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // Time-based fortune method - Override from parent
  @override
  Future<Fortune> getTimeFortune(
      {required String userId,
      String fortuneType = 'time',
      Map<String, dynamic>? params}) async {
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] getTimeFortune called');
    debugPrint(
        '🔍 [FortuneApiServiceWithEdgeFunctions] Timestamp: ${DateTime.now().toIso8601String()}');
    // Edge Functions are being used
    // Debug info
    debugPrint('type: ${params.runtimeType}');
    debugPrint('params period: ${params?['period']}');

    if (_featureFlags.isEdgeFunctionsEnabled()) {
      debugPrint(
          '🔍 [FortuneApiServiceWithEdgeFunctions] Edge Functions ENABLED');
      debugPrint(
          '🔍 [FortuneApiServiceWithEdgeFunctions] Preparing data for Edge Function call');

      final edgeFunctionData = {
        'period': params?['period'] ?? 'today',
        ...?params
      };

      // Debug info
      debugPrint(
          '🔍 [FortuneApiServiceWithEdgeFunctions] Calling _getFortuneFromEdgeFunction...');

      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.timeFortune,
          userId: userId,
          fortuneType: 'time_based',
          data: edgeFunctionData);
    }

    // Fall back to parent implementation
    debugPrint(
        '🔍 [FortuneApiServiceWithEdgeFunctions] Edge Functions DISABLED');
    debugPrint(
        '🔍 [FortuneApiServiceWithEdgeFunctions] Falling back to parent implementation');
    return super.getTimeFortune(
        userId: userId, fortuneType: fortuneType, params: params);
  }

  // Add methods for other fortune types
  @override
  Future<Fortune> getMbtiFortune(
      {required String userId,
      required String mbtiType,
      List<String>? categories,
      String? name,
      String? birthDate}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.mbtiFortune,
          userId: userId,
          fortuneType: 'mbti',
          data: {
            'mbti': mbtiType,
            'name': name ?? 'Unknown',
            'birthDate':
                birthDate ?? DateTime.now().toIso8601String().split('T')[0],
            if (categories != null && categories.isNotEmpty)
              'categories': categories,
          });
    }

    // Fall back to parent class method
    return super.getMbtiFortune(
        userId: userId,
        mbtiType: mbtiType,
        categories: categories,
        name: name,
        birthDate: birthDate);
  }

  @override
  Future<Fortune> getZodiacFortune(
      {required String userId, required String zodiacSign}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('zodiac'),
          userId: userId,
          fortuneType: 'zodiac',
          data: {'zodiacSign': zodiacSign});
    }

    // Fall back to parent class method
    return super.getZodiacFortune(userId: userId, zodiacSign: zodiacSign);
  }

  // Token balance check using Edge Functions
  Future<Map<String, dynamic>> getTokenBalance({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      try {
        final response = await _edgeFunctionsDio.get(
          EdgeFunctionsEndpoints.tokenBalance,
          options: _buildEdgeRequestOptions(),
        );

        return response.data;
      } catch (e) {
        // Debug info
        // Fall back to traditional API
      }
    }

    // Fall back to traditional API
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.get('/api/token/balance');
    return response;
  }

  // Daily token claim using Edge Functions
  Future<Map<String, dynamic>> claimDailyTokens(
      {required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      try {
        final response = await _edgeFunctionsDio.post(
          EdgeFunctionsEndpoints.tokenDailyClaim,
          data: {'userId': userId},
          options: _buildEdgeRequestOptions(),
        );

        return response.data;
      } catch (e) {
        // Debug info
        // Fall back to traditional API
      }
    }

    // Fall back to traditional API
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient
        .post('/api/token/claim-daily', data: {'userId': userId});
    return response;
  }

  // Tomorrow Fortune
  @override
  Future<Fortune> getTomorrowFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('tomorrow'),
          userId: userId,
          fortuneType: 'tomorrow');
    }
    return super.getTomorrowFortune(userId: userId);
  }

  // Hourly Fortune
  @override
  Future<Fortune> getHourlyFortune(
      {required String userId, required DateTime targetTime}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('hourly'),
          userId: userId,
          fortuneType: 'hourly',
          data: {'targetTime': targetTime.toIso8601String()});
    }
    return super.getHourlyFortune(userId: userId, targetTime: targetTime);
  }

  // Weekly Fortune
  @override
  Future<Fortune> getWeeklyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('weekly'),
          userId: userId,
          fortuneType: 'weekly');
    }
    return super.getWeeklyFortune(userId: userId);
  }

  // Monthly Fortune
  @override
  Future<Fortune> getMonthlyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('monthly'),
          userId: userId,
          fortuneType: 'monthly');
    }
    return super.getMonthlyFortune(userId: userId);
  }

  // Yearly Fortune
  @override
  Future<Fortune> getYearlyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('yearly'),
          userId: userId,
          fortuneType: 'yearly');
    }
    return super.getYearlyFortune(userId: userId);
  }

  // Traditional Fortunes
  @override
  Future<Fortune> getSajuFortune(
      {required String userId, required DateTime birthDate}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('saju'),
          userId: userId,
          fortuneType: 'saju',
          data: {'birthDate': birthDate.toIso8601String()});
    }
    return super.getSajuFortune(userId: userId, birthDate: birthDate);
  }

  @override
  Future<Fortune> getTojeongFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('tojeong'),
          userId: userId,
          fortuneType: 'tojeong');
    }
    return super.getTojeongFortune(userId: userId);
  }

  @override
  Future<Fortune> getPalmistryFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('palmistry'),
          userId: userId,
          fortuneType: 'palmistry');
    }
    return super.getPalmistryFortune(userId: userId);
  }

  @override
  Future<Fortune> getPhysiognomyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('physiognomy'),
          userId: userId,
          fortuneType: 'physiognomy');
    }
    return super.getPhysiognomyFortune(userId: userId);
  }

  // Love & Relationship Fortunes
  @override
  Future<Fortune> getLoveFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.loveFortune,
          userId: userId,
          fortuneType: 'love');
    }
    return super.getLoveFortune(userId: userId);
  }

  @override
  Future<Fortune> getMarriageFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('marriage'),
          userId: userId,
          fortuneType: 'marriage');
    }
    return super.getMarriageFortune(userId: userId);
  }

  @override
  Future<Fortune> getCompatibilityFortune(
      {required Map<String, dynamic> person1,
      required Map<String, dynamic> person2}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.compatibilityFortune,
          userId: person1['userId'] ?? '',
          fortuneType: 'compatibility',
          data: {'person1': person1, 'person2': person2});
    }
    return super.getCompatibilityFortune(person1: person1, person2: person2);
  }

  // Career & Business Fortunes
  @override
  Future<Fortune> getCareerFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.careerFortune,
          userId: userId,
          fortuneType: 'career');
    }
    return super.getCareerFortune(userId: userId);
  }

  @override
  Future<Fortune> getBusinessFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('business'),
          userId: userId,
          fortuneType: 'business');
    }
    return super.getBusinessFortune(userId: userId);
  }

  @override
  Future<Fortune> getEmploymentFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('employment'),
          userId: userId,
          fortuneType: 'employment');
    }
    return super.getEmploymentFortune(userId: userId);
  }

  @override
  Future<Fortune> getStartupFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('startup'),
          userId: userId,
          fortuneType: 'startup');
    }
    return super.getStartupFortune(userId: userId);
  }

  // Wealth & Investment Fortunes
  @override
  Future<Fortune> getWealthFortune(
      {required String userId, Map<String, dynamic>? financialData}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('wealth'),
          userId: userId,
          fortuneType: 'wealth',
          data: financialData);
    }
    return super.getWealthFortune(userId: userId, financialData: financialData);
  }

  // Generic Fortune method
  @override
  Future<Fortune> getFortune(
      {required String userId,
      required String fortuneType,
      Map<String, dynamic>? params}) async {
    debugPrint('🎯 [FortuneApiServiceWithEdgeFunctions] getFortune called');
    debugPrint('📋 Fortune Type: $fortuneType');
    debugPrint('📊 Params keys: ${params?.keys.toList()}');
    debugPrint('🔢 Has image data: ${params?.containsKey('image') ?? false}');
    debugPrint(
        '🔢 Has instagram URL: ${params?.containsKey('instagram_url') ?? false}');

    if (_featureFlags.isEdgeFunctionsEnabled()) {
      debugPrint(
          '✅ [FortuneApiServiceWithEdgeFunctions] Edge Functions enabled');
      final endpoint = EdgeFunctionsEndpoints.getEndpointForType(fortuneType);
      debugPrint(
          '📍 [FortuneApiServiceWithEdgeFunctions] Endpoint for $fortuneType: $endpoint');

      debugPrint(
          '🚀 [FortuneApiServiceWithEdgeFunctions] Using Edge Function: $endpoint');
      try {
        // ✅ 'wish' 타입은 analyze-wish 형식으로 변환
        Map<String, dynamic>? transformedParams = params;
        if (fortuneType == 'wish' && params != null) {
          transformedParams = {
            ...params,
            'wish_text': params['wish'] ?? params['wish_text'] ?? '',
            'category': params['category'] ?? 'other',
          };
          // 중복 필드 제거
          transformedParams.remove('wish');
          debugPrint(
              '📝 [FortuneApiServiceWithEdgeFunctions] Transformed wish params: wish_text=${transformedParams['wish_text']}, category=${transformedParams['category']}');
        }

        return await _getFortuneFromEdgeFunction(
            endpoint: endpoint,
            userId: userId,
            fortuneType: fortuneType,
            data: transformedParams);
      } catch (e) {
        debugPrint(
            '❌ [FortuneApiServiceWithEdgeFunctions] Edge Function failed: $e');
        debugPrint(
            '🔄 [FortuneApiServiceWithEdgeFunctions] Falling back to traditional API');
        return super.getFortune(
            userId: userId, fortuneType: fortuneType, params: params);
      }
    }

    debugPrint('📡 [FortuneApiServiceWithEdgeFunctions] Using traditional API');
    return super
        .getFortune(userId: userId, fortuneType: fortuneType, params: params);
  }

  // Today Fortune
  @override
  Future<Fortune> getTodayFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('today'),
          userId: userId,
          fortuneType: 'today');
    }
    return super.getTodayFortune(userId: userId);
  }

  // Blood Type Fortune
  @override
  Future<Fortune> getBloodTypeFortune(
      {required String userId, required String bloodType}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('blood-type'),
          userId: userId,
          fortuneType: 'blood-type',
          data: {'bloodType': bloodType});
    }
    return super.getBloodTypeFortune(userId: userId, bloodType: bloodType);
  }

  // Zodiac Animal Fortune
  @override
  Future<Fortune> getZodiacAnimalFortune(
      {required String userId, required String zodiacAnimal}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('zodiac-animal'),
          userId: userId,
          fortuneType: 'zodiac-animal',
          data: {'zodiacAnimal': zodiacAnimal});
    }
    return super
        .getZodiacAnimalFortune(userId: userId, zodiacAnimal: zodiacAnimal);
  }

  // Lucky Color Fortune
  @override
  Future<Fortune> getLuckyColorFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-color'),
          userId: userId,
          fortuneType: 'lucky-color');
    }
    return super.getLuckyColorFortune(userId: userId);
  }

  // Lucky Number Fortune
  @override
  Future<Fortune> getLuckyNumberFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-number'),
          userId: userId,
          fortuneType: 'lucky-number');
    }
    return super.getLuckyNumberFortune(userId: userId);
  }

  // Lucky Items Fortune
  @override
  Future<Fortune> getLuckyItemsFortune(
      {required String userId,
      String fortuneType = 'lucky_items',
      Map<String, dynamic>? params}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.luckyItemsFortune,
          userId: userId,
          fortuneType: 'lucky-items',
          data: {
            if (params?['interests'] != null) 'interests': params!['interests'],
          });
    }
    return super.getLuckyItemsFortune(userId: userId);
  }

  // Lucky Food Fortune
  @override
  Future<Fortune> getLuckyFoodFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-food'),
          userId: userId,
          fortuneType: 'lucky-food');
    }
    return super.getLuckyFoodFortune(userId: userId);
  }

  // Biorhythm Fortune
  @override
  Future<Fortune> getBiorhythmFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.biorhythmFortune,
          userId: userId,
          fortuneType: 'biorhythm');
    }
    return super.getBiorhythmFortune(userId: userId);
  }

  // Past Life Fortune
  @override
  Future<Fortune> getPastLifeFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('past-life'),
          userId: userId,
          fortuneType: 'past-life');
    }
    return super.getPastLifeFortune(userId: userId);
  }

  // New Year Fortune
  @override
  Future<Fortune> getNewYearFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('new-year'),
          userId: userId,
          fortuneType: 'new-year');
    }
    return super.getNewYearFortune(userId: userId);
  }

  // Personality Fortune
  @override
  Future<Fortune> getPersonalityFortune(
      {required String userId,
      String fortuneType = 'personality',
      Map<String, dynamic>? params}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('personality'),
          userId: userId,
          fortuneType: 'personality');
    }
    return super.getPersonalityFortune(userId: userId);
  }

  // Health Fortune
  @override
  Future<Fortune> getHealthFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.healthFortune,
          userId: userId,
          fortuneType: 'health');
    }
    return super.getHealthFortune(userId: userId);
  }

  // Moving Fortune
  @override
  Future<Fortune> getMovingFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.movingFortune,
          userId: userId,
          fortuneType: 'moving');
    }
    return super.getMovingFortune(userId: userId);
  }

  // Wish Fortune
  @override
  Future<Fortune> getWishFortune(
      {required String userId, required String wish, String? category}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('wish'),
          userId: userId,
          fortuneType: 'wish',
          data: {
            'wish_text': wish, // ✅ analyze-wish가 기대하는 필드명
            'category': category ?? 'other', // ✅ 기본 카테고리
          });
    }
    return super.getWishFortune(userId: userId, wish: wish);
  }

  // Talent Fortune
  @override
  Future<Fortune> getTalentFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.talentFortune,
          userId: userId,
          fortuneType: 'talent');
    }
    return super.getTalentFortune(userId: userId);
  }

  // Lucky Sports Fortunes
  @override
  Future<Fortune> getLuckyBaseballFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-baseball'),
          userId: userId,
          fortuneType: 'lucky-baseball');
    }
    return super.getLuckyBaseballFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyGolfFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-golf'),
          userId: userId,
          fortuneType: 'lucky-golf');
    }
    return super.getLuckyGolfFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyTennisFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-tennis'),
          userId: userId,
          fortuneType: 'lucky-tennis');
    }
    return super.getLuckyTennisFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyRunningFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-running'),
          userId: userId,
          fortuneType: 'lucky-running');
    }
    return super.getLuckyRunningFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyCyclingFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-cycling'),
          userId: userId,
          fortuneType: 'lucky-cycling');
    }
    return super.getLuckyCyclingFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckySwimFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-swim'),
          userId: userId,
          fortuneType: 'lucky-swim');
    }
    return super.getLuckySwimFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyHikingFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-hiking'),
          userId: userId,
          fortuneType: 'lucky-hiking');
    }
    return super.getLuckyHikingFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyFishingFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
          endpoint: EdgeFunctionsEndpoints.getEndpointForType('lucky-fishing'),
          userId: userId,
          fortuneType: 'lucky-fishing');
    }
    return super.getLuckyFishingFortune(userId: userId);
  }
}
