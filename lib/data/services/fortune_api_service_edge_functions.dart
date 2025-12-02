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
  
  FortuneApiServiceWithEdgeFunctions(this._ref) : super(_ref.read(apiClientProvider));
  
  /// Get weather info optionally (doesn't fail if location permission denied)
  Future<WeatherInfo?> _getWeatherInfoOptional() async {
    try {
      // Check location permission without requesting
      LocationPermission permission = await Geolocator.checkPermission();
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
  Future<Fortune> getDailyFortune({
    required String userId,
    DateTime? date}) async {
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] getDailyFortune called');
    // Edge Functions are being used
    debugPrint('enabled: ${_featureFlags.isEdgeFunctionsEnabled()}');
    
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Using Edge Functions for daily fortune');
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.dailyFortune,
        userId: userId,
        fortuneType: 'daily',
        data: {
          if (date != null) 'date': date.toIso8601String()});
    }
    
    // Fall back to original implementation
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Falling back to traditional API');
    return super.getDailyFortune(userId: userId, date: date);
  }

  /// Generic method to get fortune from Edge Functions
  Future<Fortune> _getFortuneFromEdgeFunction({
    required String endpoint,
    required String userId,
    required String fortuneType,
    Map<String, dynamic>? data}) async {
    try {
      debugPrint('📡 [FortuneApiServiceWithEdgeFunctions] Calling Edge Function');
      debugPrint('endpoint: $endpoint, userId: $userId, fortuneType: $fortuneType');
      
      // Get user profile to include name
      final supabase = Supabase.instance.client;
      final userProfileResponse = await supabase
          .from('user_profiles')
          .select('name, birth_date, birth_time, gender, mbti, blood_type, zodiac_sign, chinese_zodiac, saju_calculated')
          .eq('id', userId)
          .maybeSingle();

      // 프로필 데이터 로깅
      debugPrint('👤 [PROFILE] user_profiles 데이터:');
      if (userProfileResponse != null) {
        debugPrint('👤 [PROFILE] - name: ${userProfileResponse['name']}');
        debugPrint('👤 [PROFILE] - birth_date: ${userProfileResponse['birth_date']}');
        debugPrint('👤 [PROFILE] - birth_time: ${userProfileResponse['birth_time']}');
        debugPrint('👤 [PROFILE] - gender: ${userProfileResponse['gender']}');
        debugPrint('👤 [PROFILE] - saju_calculated: ${userProfileResponse['saju_calculated']}');
        debugPrint('👤 [PROFILE] - zodiac_sign: ${userProfileResponse['zodiac_sign']}');
        debugPrint('👤 [PROFILE] - chinese_zodiac: ${userProfileResponse['chinese_zodiac']}');
      } else {
        debugPrint('👤 [PROFILE] ❌ user_profiles 데이터가 없습니다!');
      }

      // Get saju data if available
      Map<String, dynamic>? sajuData;
      try {
        final sajuResponse = await supabase
            .from('user_saju')
            .select('*')
            .eq('user_id', userId)
            .maybeSingle();

        if (sajuResponse != null) {
          sajuData = sajuResponse;
          debugPrint('✅ Saju data found for user');
          debugPrint('🔮 [SAJU] user_saju 테이블 데이터:');
          debugPrint('🔮 [SAJU] - year_pillar: ${sajuResponse['year_pillar']}');
          debugPrint('🔮 [SAJU] - month_pillar: ${sajuResponse['month_pillar']}');
          debugPrint('🔮 [SAJU] - day_pillar: ${sajuResponse['day_pillar']}');
          debugPrint('🔮 [SAJU] - hour_pillar: ${sajuResponse['hour_pillar']}');
          debugPrint('🔮 [SAJU] - day_master: ${sajuResponse['day_master']}');
          debugPrint('🔮 [SAJU] - five_elements: ${sajuResponse['five_elements']}');
        } else {
          debugPrint('⚠️ No saju data found in user_saju table for user: $userId');
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching saju data: $e');
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
          'name': (userProfileResponse['name'] != null && (userProfileResponse['name'] as String).isNotEmpty)
              ? userProfileResponse['name']
              : '사용자',  // Default to '사용자' instead of empty string
          'birthDate': userProfileResponse['birth_date'],
          'birthTime': userProfileResponse['birth_time'],
          'gender': userProfileResponse['gender'],
          'isLunar': false,  // Default to false as column doesn't exist yet
          'mbtiType': userProfileResponse['mbti'],
          'bloodType': userProfileResponse['blood_type'],
          'zodiacSign': userProfileResponse['zodiac_sign'],
          'zodiacAnimal': userProfileResponse['chinese_zodiac'],
          'sajuCalculated': userProfileResponse['saju_calculated'] ?? false},
        if (sajuData != null) 'sajuData': sajuData,
        if (userLocation != null) 'location': userLocation};

      // 📤 API 요청 데이터 상세 로깅
      debugPrint('📤 [API REQUEST] Edge Function으로 전송할 데이터:');
      debugPrint('📤 [API REQUEST] - keys: ${requestData.keys.toList()}');
      debugPrint('📤 [API REQUEST] - name: ${requestData['name']}');
      debugPrint('📤 [API REQUEST] - birthDate: ${requestData['birthDate']}');
      debugPrint('📤 [API REQUEST] - birthTime: ${requestData['birthTime']}');
      debugPrint('📤 [API REQUEST] - gender: ${requestData['gender']}');
      debugPrint('📤 [API REQUEST] - sajuCalculated: ${requestData['sajuCalculated']}');
      debugPrint('📤 [API REQUEST] - sajuData 존재: ${requestData['sajuData'] != null}');
      if (requestData['sajuData'] != null) {
        final saju = requestData['sajuData'] as Map<String, dynamic>;
        debugPrint('📤 [API REQUEST] - sajuData.year_pillar: ${saju['year_pillar']}');
        debugPrint('📤 [API REQUEST] - sajuData.day_pillar: ${saju['day_pillar']}');
        debugPrint('📤 [API REQUEST] - sajuData.hour_pillar: ${saju['hour_pillar']}');
      }
      debugPrint('📤 [API REQUEST] - date: ${requestData['date']}');
      debugPrint('📤 [API REQUEST] - period: ${requestData['period']}');

      // Create a custom Dio instance for Edge Functions
      debugPrint('URL: ${EdgeFunctionsEndpoints.currentBaseUrl}');
      // Debug info
      // Debug info
      
      // Validate Supabase anon key
      if (Environment.supabaseAnonKey.isEmpty) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] SUPABASE_ANON_KEY is missing!');
        debugPrint('❌ Please check your .env file and ensure SUPABASE_ANON_KEY is set');
        throw Exception('SUPABASE_ANON_KEY is not configured. Please check your environment settings.');
      }
      
      // Configure headers based on platform
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
        'apikey': Environment.supabaseAnonKey};
      
      // Only add XMLHttpRequest header for non-web platforms
      if (!kIsWeb) {
        headers['x-requested-with'] = 'XMLHttpRequest';
      }
      
      final edgeFunctionsDio = Dio(BaseOptions(
        baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
        headers: headers,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status! < 500));
      debugPrint('present: ${Environment.supabaseAnonKey.isNotEmpty}');
      debugPrint('prefix: ${Environment.supabaseAnonKey.substring(0, 20)}...');

      // Get auth token from Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      debugPrint('present: ${session != null}');
      
      if (session == null) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] No active session found!');
        throw Exception('No active session. Please login first.');
      }
      
      final authToken = 'Bearer ${session.accessToken}';
      edgeFunctionsDio.options.headers['Authorization'] = authToken;
      // Auth token added to headers
      
      final stopwatch = Stopwatch()..start();
      final response = await edgeFunctionsDio.post(
        endpoint,
        data: requestData);
      stopwatch.stop();

      debugPrint('📥 [API RESPONSE] Edge Function 응답 받음 (${stopwatch.elapsedMilliseconds}ms)');
      debugPrint('📥 [API RESPONSE] - status: ${response.statusCode}');

      // Edge Functions return a slightly different format
      // Extracting fortune data from response...
      
      if (response.data == null) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] Response data is null!');
        throw Exception('Empty response from Edge Function');
      }
      
      if (response.data is! Map) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] Response data is not a Map! Type: ${response.data.runtimeType}');
        throw Exception('Invalid response format from Edge Function');
      }
      
      final fortuneData = response.data['fortune'];
      final tokensUsed = response.data['tokensUsed'] ?? 0;
      
      // Fortune data validated
      
      // Debug info
      // Debug info
      
      // Convert to FortuneResponseModel format
      // Converting to FortuneData model...
      
      if (fortuneData == null) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] Fortune data is null!');
        throw Exception('No fortune data in response');
      }

      // 📥 운세 응답 데이터 상세 로깅
      debugPrint('📥 [API RESPONSE] 운세 데이터 상세:');
      debugPrint('📥 [API RESPONSE] - score: ${fortuneData['score'] ?? fortuneData['overall_score'] ?? fortuneData['overallScore']}');
      debugPrint('📥 [API RESPONSE] - content 길이: ${(fortuneData['content'] ?? fortuneData['description'] ?? '').toString().length}');
      debugPrint('📥 [API RESPONSE] - sajuPillars 존재: ${fortuneData['sajuPillars'] != null}');
      debugPrint('📥 [API RESPONSE] - todaySaju 존재: ${fortuneData['todaySaju'] != null}');
      debugPrint('📥 [API RESPONSE] - fiveElements 존재: ${fortuneData['fiveElements'] != null}');
      if (fortuneData['sajuPillars'] != null) {
        debugPrint('📥 [API RESPONSE] - sajuPillars: ${fortuneData['sajuPillars']}');
      }
      if (fortuneData['todaySaju'] != null) {
        debugPrint('📥 [API RESPONSE] - todaySaju: ${fortuneData['todaySaju']}');
      }

      // Fortune data extracted and validated
      
      final fortuneDataModel = FortuneData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: fortuneType,
        content: fortuneData['content'] ?? fortuneData['description'] ?? '',
        createdAt: DateTime.now(),
        metadata: fortuneData,
        score: fortuneData['score']?.toInt() ?? fortuneData['overall_score']?.toInt() ?? fortuneData['overallScore'],
        summary: fortuneData['summary'],
        luckyColor: fortuneData['luckyColor'] ?? fortuneData['lucky_items']?['color'] ?? fortuneData['luckyItems']?['color'],
        luckyNumber: fortuneData['luckyNumber']?.toInt() ?? fortuneData['lucky_items']?['number'] ?? fortuneData['luckyItems']?['number'],
        luckyDirection: fortuneData['lucky_items']?['direction'] ?? fortuneData['luckyItems']?['direction'],
        bestTime: fortuneData['lucky_items']?['time'] ?? fortuneData['luckyItems']?['time'],
        advice: fortuneData['advice'],
        caution: fortuneData['caution'],
        greeting: fortuneData['greeting'],
        hexagonScores: fortuneData['hexagonScores'] != null 
            ? Map<String, int>.from(fortuneData['hexagonScores']) 
            : null,
        timeSpecificFortunes: fortuneData['timeSpecificFortunes'],
        birthYearFortunes: fortuneData['birthYearFortunes'],
        fiveElements: fortuneData['fiveElements'],
        specialTip: fortuneData['special_tip'] ?? fortuneData['specialTip'],
        period: fortuneData['period']);
      
      // FortuneData model created
      
      final fortuneResponse = FortuneResponseModel(
        success: true,
        data: fortuneDataModel,
        tokensUsed: tokensUsed);

      final fortune = fortuneResponse.toEntity();
      // Fortune entity created
      
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
          debugPrint('❌ [_getFortuneFromEdgeFunction] Connection error - possible CORS issue or network problem');
          debugPrint('❌ [_getFortuneFromEdgeFunction] Make sure Edge Functions are deployed and accessible');
          // Debug info
        } else if (e.type == DioExceptionType.connectionTimeout) {
          debugPrint('❌ [_getFortuneFromEdgeFunction] Connection timeout - server may be down or slow');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          debugPrint('❌ [_getFortuneFromEdgeFunction] Receive timeout - response took too long');
        }
      }
      
      // If Edge Functions fail, fall back to traditional API
      debugPrint('⚠️ [_getFortuneFromEdgeFunction] Edge Function failed, attempting fallback...');
      
      // For web platform with CORS errors, we need special handling
      if (kIsWeb && e is DioException && e.type == DioExceptionType.connectionError) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] Web platform CORS error detected');
        debugPrint('💡 [_getFortuneFromEdgeFunction] Consider using proxy or server-side rendering for web platform');
      }
      
      // In debug mode, we might want to see the error
      if (!kReleaseMode) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] Rethrowing error in debug mode');
        rethrow;
      }
      
      // In production, throw a user-friendly error
      // We can't fall back to super.getDailyFortune here because this is a generic method
      throw Exception('운세 생성에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // Time-based fortune method - Override from parent
  @override
  Future<Fortune> getTimeFortune({
    required String userId,
    String fortuneType = 'time',
    Map<String, dynamic>? params}) async {
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] getTimeFortune called');
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Timestamp: ${DateTime.now().toIso8601String()}');
    // Edge Functions are being used
    // Debug info
    debugPrint('type: ${params.runtimeType}');
    debugPrint('params period: ${params?['period']}');
    
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Edge Functions ENABLED');
      debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Preparing data for Edge Function call');
      
      final edgeFunctionData = {
        'period': params?['period'] ?? 'today',
        ...?params};
      
      // Debug info
      debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Calling _getFortuneFromEdgeFunction...');
      
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.timeFortune,
        userId: userId,
        fortuneType: 'time_based',
        data: edgeFunctionData);
    }
    
    // Fall back to parent implementation
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Edge Functions DISABLED');
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Falling back to parent implementation');
    return super.getTimeFortune(userId: userId, fortuneType: fortuneType, params: params);
  }

  // Add methods for other fortune types
  @override
  Future<Fortune> getMbtiFortune({
    required String userId,
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
          'birthDate': birthDate ?? DateTime.now().toIso8601String().split('T')[0],
          if (categories != null && categories.isNotEmpty) 'categories': categories,
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
  Future<Fortune> getZodiacFortune({
    required String userId,
    required String zodiacSign}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.getEndpointForType('zodiac'),
        userId: userId,
        fortuneType: 'zodiac',
        data: {
          'zodiacSign': zodiacSign});
    }

    // Fall back to parent class method
    return super.getZodiacFortune(userId: userId, zodiacSign: zodiacSign);
  }

  // Token balance check using Edge Functions
  Future<Map<String, dynamic>> getTokenBalance({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      try {
        // Configure headers based on platform
        final headers = <String, dynamic>{
          'Content-Type': 'application/json',
          'apikey': Environment.supabaseAnonKey};
        
        // Only add XMLHttpRequest header for non-web platforms
        if (!kIsWeb) {
          headers['x-requested-with'] = 'XMLHttpRequest';
        }
        
        final edgeFunctionsDio = Dio(BaseOptions(
          baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
          headers: headers));

        // Add auth token from Supabase session
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          edgeFunctionsDio.options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }

        final response = await edgeFunctionsDio.get(
          EdgeFunctionsEndpoints.tokenBalance
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
  Future<Map<String, dynamic>> claimDailyTokens({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      try {
        // Configure headers based on platform
        final headers = <String, dynamic>{
          'Content-Type': 'application/json',
          'apikey': Environment.supabaseAnonKey};
        
        // Only add XMLHttpRequest header for non-web platforms
        if (!kIsWeb) {
          headers['x-requested-with'] = 'XMLHttpRequest';
        }
        
        final edgeFunctionsDio = Dio(BaseOptions(
          baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
          headers: headers));

        // Add auth token from Supabase session
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          edgeFunctionsDio.options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }

        final response = await edgeFunctionsDio.post(
          EdgeFunctionsEndpoints.tokenDailyClaim,
          data: {'userId': userId});

        return response.data;
      } catch (e) {
        // Debug info
        // Fall back to traditional API
      }
    }
    
    // Fall back to traditional API
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.post(
      '/api/token/claim-daily',
      data: {'userId': userId});
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
  Future<Fortune> getHourlyFortune({required String userId, required DateTime targetTime}) async {
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
  Future<Fortune> getSajuFortune({required String userId, required DateTime birthDate}) async {
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
  Future<Fortune> getCompatibilityFortune({
    required Map<String, dynamic> person1,
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
  Future<Fortune> getWealthFortune({required String userId, Map<String, dynamic>? financialData}) async {
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
  Future<Fortune> getFortune({
    required String userId,
    required String fortuneType,
    Map<String, dynamic>? params}) async {
    debugPrint('🎯 [FortuneApiServiceWithEdgeFunctions] getFortune called');
    debugPrint('📋 Fortune Type: $fortuneType');
    debugPrint('📊 Params keys: ${params?.keys.toList()}');
    debugPrint('🔢 Has image data: ${params?.containsKey('image') ?? false}');
    debugPrint('🔢 Has instagram URL: ${params?.containsKey('instagram_url') ?? false}');

    if (_featureFlags.isEdgeFunctionsEnabled()) {
      debugPrint('✅ [FortuneApiServiceWithEdgeFunctions] Edge Functions enabled');
      final endpoint = EdgeFunctionsEndpoints.getEndpointForType(fortuneType);
      debugPrint('📍 [FortuneApiServiceWithEdgeFunctions] Endpoint for $fortuneType: $endpoint');

      debugPrint('🚀 [FortuneApiServiceWithEdgeFunctions] Using Edge Function: $endpoint');
      try {
        return await _getFortuneFromEdgeFunction(
          endpoint: endpoint,
          userId: userId,
          fortuneType: fortuneType,
          data: params);
      } catch (e) {
        debugPrint('❌ [FortuneApiServiceWithEdgeFunctions] Edge Function failed: $e');
        debugPrint('🔄 [FortuneApiServiceWithEdgeFunctions] Falling back to traditional API');
        return super.getFortune(userId: userId, fortuneType: fortuneType, params: params);
      }
        }

    debugPrint('📡 [FortuneApiServiceWithEdgeFunctions] Using traditional API');
    return super.getFortune(userId: userId, fortuneType: fortuneType, params: params);
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
  Future<Fortune> getBloodTypeFortune({required String userId, required String bloodType}) async {
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
  Future<Fortune> getZodiacAnimalFortune({required String userId, required String zodiacAnimal}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.getEndpointForType('zodiac-animal'),
        userId: userId,
        fortuneType: 'zodiac-animal',
        data: {'zodiacAnimal': zodiacAnimal});
    }
    return super.getZodiacAnimalFortune(userId: userId, zodiacAnimal: zodiacAnimal);
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
  Future<Fortune> getLuckyItemsFortune({
    required String userId,
    String fortuneType = 'lucky_items',
    Map<String, dynamic>? params}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyItemsFortune,
        userId: userId,
        fortuneType: 'lucky-items');
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
  Future<Fortune> getPersonalityFortune({
    required String userId,
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
  Future<Fortune> getWishFortune({required String userId, required String wish}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.getEndpointForType('wish'),
        userId: userId,
        fortuneType: 'wish',
        data: {'wish': wish}
      );
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
        fortuneType: 'lucky-fishing'
      );
    }
    return super.getLuckyFishingFortune(userId: userId);
  }
}