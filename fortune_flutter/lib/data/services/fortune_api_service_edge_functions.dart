import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/environment.dart';
import '../../core/config/feature_flags.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/edge_functions_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/fortune.dart';
import '../models/fortune_response_model.dart';
import '../../presentation/providers/providers.dart';
import 'fortune_api_service.dart';

/// Extended FortuneApiService that supports Edge Functions
class FortuneApiServiceWithEdgeFunctions extends FortuneApiService {
  final FeatureFlags _featureFlags = FeatureFlags.instance;
  final Ref _ref;
  
  FortuneApiServiceWithEdgeFunctions(this._ref) : super(_ref.read(apiClientProvider));

  /// Override the base method to use Edge Functions when enabled
  @override
  Future<Fortune> getDailyFortune({
    required String userId,
    DateTime? date,
  }) async {
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] getDailyFortune called');
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] userId: $userId');
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] date: $date');
    debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Edge Functions enabled: ${_featureFlags.isEdgeFunctionsEnabled()}');
    
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      debugPrint('🔍 [FortuneApiServiceWithEdgeFunctions] Using Edge Functions for daily fortune');
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.dailyFortune,
        userId: userId,
        fortuneType: 'daily',
        data: {
          if (date != null) 'date': date.toIso8601String(),
        },
      );
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
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Using Edge Function for $fortuneType fortune');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Endpoint: $endpoint');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] UserId: $userId');
      
      // Get user profile to include name
      final supabase = Supabase.instance.client;
      final userProfileResponse = await supabase
          .from('user_profiles')
          .select('name, birth_date, birth_time, gender, mbti, blood_type, zodiac_sign, chinese_zodiac')
          .eq('id', userId)
          .maybeSingle();
      
      debugPrint('🔍 [_getFortuneFromEdgeFunction] User profile: $userProfileResponse');
      
      // Prepare request data
      final requestData = {
        ...?data,
        'userId': userId,
        if (userProfileResponse != null) ...{
          'name': userProfileResponse['name'] ?? '',
          'birthDate': userProfileResponse['birth_date'],
          'birthTime': userProfileResponse['birth_time'],
          'gender': userProfileResponse['gender'],
          'mbtiType': userProfileResponse['mbti'],
          'bloodType': userProfileResponse['blood_type'],
          'zodiacSign': userProfileResponse['zodiac_sign'],
        },
      };
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Request data: $requestData');

      // Create a custom Dio instance for Edge Functions
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Base URL: ${EdgeFunctionsEndpoints.currentBaseUrl}');
      
      // Validate Supabase anon key
      if (Environment.supabaseAnonKey.isEmpty) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] SUPABASE_ANON_KEY is missing!');
        debugPrint('❌ Please check your .env file and ensure SUPABASE_ANON_KEY is set');
        throw Exception('SUPABASE_ANON_KEY is not configured. Please check your environment settings.');
      }
      
      final edgeFunctionsDio = Dio(BaseOptions(
        baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'apikey': Environment.supabaseAnonKey,
        },
      ));
      debugPrint('🔍 [_getFortuneFromEdgeFunction] SUPABASE_ANON_KEY present: ${Environment.supabaseAnonKey.isNotEmpty}');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] SUPABASE_ANON_KEY prefix: ${Environment.supabaseAnonKey.substring(0, 20)}...');

      // Get auth token from Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Session present: ${session != null}');
      
      if (session == null) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] No active session found!');
        throw Exception('No active session. Please login first.');
      }
      
      final authToken = 'Bearer ${session.accessToken}';
      edgeFunctionsDio.options.headers['Authorization'] = authToken;
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Auth token added to headers');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Auth token prefix: ${authToken.substring(0, 30)}...');

      debugPrint('🔍 [_getFortuneFromEdgeFunction] Making POST request to: ${EdgeFunctionsEndpoints.currentBaseUrl}$endpoint');
      final response = await edgeFunctionsDio.post(
        endpoint,
        data: requestData,
      );
      
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Response status: ${response.statusCode}');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Response data: ${response.data}');

      // Edge Functions return a slightly different format
      final fortuneData = response.data['fortune'];
      final tokensUsed = response.data['tokensUsed'] ?? 0;
      
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Fortune data: $fortuneData');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Tokens used: $tokensUsed');
      
      // Convert to FortuneResponseModel format
      final fortuneDataModel = FortuneData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: fortuneType,
        content: fortuneData['content'] ?? fortuneData['description'] ?? '',
        createdAt: DateTime.now(),
        metadata: fortuneData,
        score: fortuneData['score']?.toInt() ?? fortuneData['overallScore']?.toInt(),
        summary: fortuneData['summary'],
        luckyColor: fortuneData['luckyColor'] ?? fortuneData['luckyItems']?['color'],
        luckyNumber: fortuneData['luckyNumber']?.toInt() ?? fortuneData['luckyItems']?['number'],
        luckyDirection: fortuneData['luckyItems']?['direction'],
        bestTime: fortuneData['luckyItems']?['time'],
        advice: fortuneData['advice'],
        caution: fortuneData['caution'],
        greeting: fortuneData['greeting'],
        hexagonScores: fortuneData['hexagonScores'] != null 
            ? Map<String, int>.from(fortuneData['hexagonScores']) 
            : null,
        timeSpecificFortunes: fortuneData['timeSpecificFortunes'],
        birthYearFortunes: fortuneData['birthYearFortunes'],
        fiveElements: fortuneData['fiveElements'],
        specialTip: fortuneData['specialTip'],
        period: fortuneData['period'],
      );
      
      final fortuneResponse = FortuneResponseModel(
        success: true,
        data: fortuneDataModel,
        tokensUsed: tokensUsed,
      );

      final fortune = fortuneResponse.toEntity();
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Fortune entity created successfully');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Fortune ID: ${fortune.id}');
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Fortune type: ${fortune.type}');
      
      return fortune;
      
    } catch (e, stackTrace) {
      debugPrint('❌ [_getFortuneFromEdgeFunction] Edge Function error: $e');
      debugPrint('❌ [_getFortuneFromEdgeFunction] Stack trace: $stackTrace');
      
      if (e is DioException) {
        debugPrint('❌ [_getFortuneFromEdgeFunction] DioException type: ${e.type}');
        debugPrint('❌ [_getFortuneFromEdgeFunction] Response data: ${e.response?.data}');
        debugPrint('❌ [_getFortuneFromEdgeFunction] Status code: ${e.response?.statusCode}');
        debugPrint('❌ [_getFortuneFromEdgeFunction] Headers: ${e.response?.headers}');
      }
      
      // If Edge Functions fail, fall back to traditional API
      if (!kReleaseMode) {
        // In debug mode, we might want to see the error
        debugPrint('❌ [_getFortuneFromEdgeFunction] Rethrowing error in debug mode');
        rethrow;
      }
      
      // In production, silently fall back
      debugPrint('🔍 [_getFortuneFromEdgeFunction] Falling back to traditional API');
      return super.getDailyFortune(userId: userId);
    }
  }

  // Add methods for other fortune types
  @override
  Future<Fortune> getMbtiFortune({
    required String userId,
    required String mbtiType,
    List<String>? categories,
  }) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.mbtiFortune,
        userId: userId,
        fortuneType: 'mbti',
        data: {
          'mbtiType': mbtiType,
        },
      );
    }
    
    // Fall back to parent class method
    return super.getMbtiFortune(userId: userId, mbtiType: mbtiType, categories: categories);
  }

  @override
  Future<Fortune> getZodiacFortune({
    required String userId,
    required String zodiacSign,
  }) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.zodiacFortune,
        userId: userId,
        fortuneType: 'zodiac',
        data: {
          'zodiacSign': zodiacSign,
        },
      );
    }
    
    // Fall back to parent class method
    return super.getZodiacFortune(userId: userId, zodiacSign: zodiacSign);
  }

  // Token balance check using Edge Functions
  Future<Map<String, dynamic>> getTokenBalance({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      try {
        final edgeFunctionsDio = Dio(BaseOptions(
          baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'apikey': Environment.supabaseAnonKey,
          },
        ));

        // Add auth token from Supabase session
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          edgeFunctionsDio.options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }

        final response = await edgeFunctionsDio.get(
          EdgeFunctionsEndpoints.tokenBalance,
        );

        return response.data;
      } catch (e) {
        debugPrint('Edge Function token balance error: $e');
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
        final edgeFunctionsDio = Dio(BaseOptions(
          baseUrl: EdgeFunctionsEndpoints.currentBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'apikey': Environment.supabaseAnonKey,
          },
        ));

        // Add auth token from Supabase session
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          edgeFunctionsDio.options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }

        final response = await edgeFunctionsDio.post(
          EdgeFunctionsEndpoints.tokenDailyClaim,
          data: {'userId': userId},
        );

        return response.data;
      } catch (e) {
        debugPrint('Edge Function daily claim error: $e');
        // Fall back to traditional API
      }
    }
    
    // Fall back to traditional API
    final apiClient = _ref.read(apiClientProvider);
    final response = await apiClient.post(
      '/api/token/claim-daily',
      data: {'userId': userId},
    );
    return response;
  }

  // Tomorrow Fortune
  @override
  Future<Fortune> getTomorrowFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.tomorrowFortune,
        userId: userId,
        fortuneType: 'tomorrow',
      );
    }
    return super.getTomorrowFortune(userId: userId);
  }

  // Hourly Fortune
  @override
  Future<Fortune> getHourlyFortune({required String userId, required DateTime targetTime}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.hourlyFortune,
        userId: userId,
        fortuneType: 'hourly',
        data: {'targetTime': targetTime.toIso8601String()},
      );
    }
    return super.getHourlyFortune(userId: userId, targetTime: targetTime);
  }

  // Weekly Fortune
  @override
  Future<Fortune> getWeeklyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.weeklyFortune,
        userId: userId,
        fortuneType: 'weekly',
      );
    }
    return super.getWeeklyFortune(userId: userId);
  }

  // Monthly Fortune
  @override
  Future<Fortune> getMonthlyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.monthlyFortune,
        userId: userId,
        fortuneType: 'monthly',
      );
    }
    return super.getMonthlyFortune(userId: userId);
  }

  // Yearly Fortune
  @override
  Future<Fortune> getYearlyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.yearlyFortune,
        userId: userId,
        fortuneType: 'yearly',
      );
    }
    return super.getYearlyFortune(userId: userId);
  }

  // Traditional Fortunes
  @override
  Future<Fortune> getSajuFortune({required String userId, required DateTime birthDate}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.sajuFortune,
        userId: userId,
        fortuneType: 'saju',
        data: {'birthDate': birthDate.toIso8601String()},
      );
    }
    return super.getSajuFortune(userId: userId, birthDate: birthDate);
  }

  @override
  Future<Fortune> getTojeongFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.tojeongFortune,
        userId: userId,
        fortuneType: 'tojeong',
      );
    }
    return super.getTojeongFortune(userId: userId);
  }

  @override
  Future<Fortune> getPalmistryFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.palmistryFortune,
        userId: userId,
        fortuneType: 'palmistry',
      );
    }
    return super.getPalmistryFortune(userId: userId);
  }

  @override
  Future<Fortune> getPhysiognomyFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.physiognomyFortune,
        userId: userId,
        fortuneType: 'physiognomy',
      );
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
        fortuneType: 'love',
      );
    }
    return super.getLoveFortune(userId: userId);
  }

  @override
  Future<Fortune> getMarriageFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.marriageFortune,
        userId: userId,
        fortuneType: 'marriage',
      );
    }
    return super.getMarriageFortune(userId: userId);
  }

  @override
  Future<Fortune> getCompatibilityFortune({
    required Map<String, dynamic> person1,
    required Map<String, dynamic> person2,
  }) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.compatibilityFortune,
        userId: person1['userId'] ?? '',
        fortuneType: 'compatibility',
        data: {'person1': person1, 'person2': person2},
      );
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
        fortuneType: 'career',
      );
    }
    return super.getCareerFortune(userId: userId);
  }

  @override
  Future<Fortune> getBusinessFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.businessFortune,
        userId: userId,
        fortuneType: 'business',
      );
    }
    return super.getBusinessFortune(userId: userId);
  }

  @override
  Future<Fortune> getEmploymentFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.employmentFortune,
        userId: userId,
        fortuneType: 'employment',
      );
    }
    return super.getEmploymentFortune(userId: userId);
  }

  @override
  Future<Fortune> getStartupFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.startupFortune,
        userId: userId,
        fortuneType: 'startup',
      );
    }
    return super.getStartupFortune(userId: userId);
  }

  // Wealth & Investment Fortunes
  @override
  Future<Fortune> getWealthFortune({required String userId, Map<String, dynamic>? financialData}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.wealthFortune,
        userId: userId,
        fortuneType: 'wealth',
        data: financialData,
      );
    }
    return super.getWealthFortune(userId: userId, financialData: financialData);
  }

  // Generic Fortune method
  @override
  Future<Fortune> getFortune({
    required String userId,
    required String fortuneType,
    Map<String, dynamic>? params,
  }) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      final endpoint = EdgeFunctionsEndpoints.getEndpointForType(fortuneType);
      if (endpoint != null) {
        return _getFortuneFromEdgeFunction(
          endpoint: endpoint,
          userId: userId,
          fortuneType: fortuneType,
          data: params,
        );
      }
    }
    return super.getFortune(userId: userId, fortuneType: fortuneType, params: params);
  }

  // Today Fortune
  @override
  Future<Fortune> getTodayFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.todayFortune,
        userId: userId,
        fortuneType: 'today',
      );
    }
    return super.getTodayFortune(userId: userId);
  }

  // Blood Type Fortune
  @override
  Future<Fortune> getBloodTypeFortune({required String userId, required String bloodType}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.bloodTypeFortune,
        userId: userId,
        fortuneType: 'blood-type',
        data: {'bloodType': bloodType},
      );
    }
    return super.getBloodTypeFortune(userId: userId, bloodType: bloodType);
  }

  // Zodiac Animal Fortune
  @override
  Future<Fortune> getZodiacAnimalFortune({required String userId, required String zodiacAnimal}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.zodiacAnimalFortune,
        userId: userId,
        fortuneType: 'zodiac-animal',
        data: {'zodiacAnimal': zodiacAnimal},
      );
    }
    return super.getZodiacAnimalFortune(userId: userId, zodiacAnimal: zodiacAnimal);
  }

  // Lucky Color Fortune
  @override
  Future<Fortune> getLuckyColorFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyColorFortune,
        userId: userId,
        fortuneType: 'lucky-color',
      );
    }
    return super.getLuckyColorFortune(userId: userId);
  }

  // Lucky Number Fortune
  @override
  Future<Fortune> getLuckyNumberFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyNumberFortune,
        userId: userId,
        fortuneType: 'lucky-number',
      );
    }
    return super.getLuckyNumberFortune(userId: userId);
  }

  // Lucky Items Fortune
  @override
  Future<Fortune> getLuckyItemsFortune({
    required String userId,
    String fortuneType = 'lucky_items',
    Map<String, dynamic>? params,
  }) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyItemsFortune,
        userId: userId,
        fortuneType: 'lucky-items',
      );
    }
    return super.getLuckyItemsFortune(userId: userId);
  }

  // Lucky Food Fortune
  @override
  Future<Fortune> getLuckyFoodFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyFoodFortune,
        userId: userId,
        fortuneType: 'lucky-food',
      );
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
        fortuneType: 'biorhythm',
      );
    }
    return super.getBiorhythmFortune(userId: userId);
  }

  // Past Life Fortune
  @override
  Future<Fortune> getPastLifeFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.pastLifeFortune,
        userId: userId,
        fortuneType: 'past-life',
      );
    }
    return super.getPastLifeFortune(userId: userId);
  }

  // New Year Fortune
  @override
  Future<Fortune> getNewYearFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.newYearFortune,
        userId: userId,
        fortuneType: 'new-year',
      );
    }
    return super.getNewYearFortune(userId: userId);
  }

  // Personality Fortune
  @override
  Future<Fortune> getPersonalityFortune({
    required String userId,
    String fortuneType = 'personality',
    Map<String, dynamic>? params,
  }) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.personalityFortune,
        userId: userId,
        fortuneType: 'personality',
      );
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
        fortuneType: 'health',
      );
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
        fortuneType: 'moving',
      );
    }
    return super.getMovingFortune(userId: userId);
  }

  // Wish Fortune
  @override
  Future<Fortune> getWishFortune({required String userId, required String wish}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.wishFortune,
        userId: userId,
        fortuneType: 'wish',
        data: {'wish': wish},
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
        fortuneType: 'talent',
      );
    }
    return super.getTalentFortune(userId: userId);
  }

  // Lucky Sports Fortunes
  @override
  Future<Fortune> getLuckyBaseballFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyBaseballFortune,
        userId: userId,
        fortuneType: 'lucky-baseball',
      );
    }
    return super.getLuckyBaseballFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyGolfFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyGolfFortune,
        userId: userId,
        fortuneType: 'lucky-golf',
      );
    }
    return super.getLuckyGolfFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyTennisFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyTennisFortune,
        userId: userId,
        fortuneType: 'lucky-tennis',
      );
    }
    return super.getLuckyTennisFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyRunningFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyRunningFortune,
        userId: userId,
        fortuneType: 'lucky-running',
      );
    }
    return super.getLuckyRunningFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyCyclingFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyCyclingFortune,
        userId: userId,
        fortuneType: 'lucky-cycling',
      );
    }
    return super.getLuckyCyclingFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckySwimFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckySwimFortune,
        userId: userId,
        fortuneType: 'lucky-swim',
      );
    }
    return super.getLuckySwimFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyHikingFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyHikingFortune,
        userId: userId,
        fortuneType: 'lucky-hiking',
      );
    }
    return super.getLuckyHikingFortune(userId: userId);
  }

  @override
  Future<Fortune> getLuckyFishingFortune({required String userId}) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.luckyFishingFortune,
        userId: userId,
        fortuneType: 'lucky-fishing',
      );
    }
    return super.getLuckyFishingFortune(userId: userId);
  }

  // Time-based Fortune (Enhanced)
  @override
  Future<Fortune> getTimeFortune({
    required String userId,
    String fortuneType = 'time',
    Map<String, dynamic>? params,
  }) async {
    if (_featureFlags.isEdgeFunctionsEnabled()) {
      // Extract period from params or default to 'today'
      final period = params?['period'] ?? 'today';
      
      return _getFortuneFromEdgeFunction(
        endpoint: EdgeFunctionsEndpoints.timeFortune,
        userId: userId,
        fortuneType: 'time',
        data: {
          'period': period,
          ...?params,
        },
      );
    }
    
    // Fall back to parent class method
    return super.getTimeFortune(userId: userId, fortuneType: fortuneType, params: params);
  }
}