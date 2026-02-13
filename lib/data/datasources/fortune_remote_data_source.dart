import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/fortune_response_model.dart';

abstract class FortuneRemoteDataSource {
  Future<FortuneResponseModel> getDailyFortune();
  Future<FortuneResponseModel> getTodayFortune();
  Future<FortuneResponseModel> getTomorrowFortune();
  Future<FortuneResponseModel> getHourlyFortune();
  Future<FortuneResponseModel> getWeeklyFortune();
  Future<FortuneResponseModel> getMonthlyFortune();
  Future<FortuneResponseModel> getYearlyFortune();

  Future<FortuneResponseModel> getTraditionalSajuFortune();
  Future<FortuneResponseModel> getTojeongFortune();
  Future<FortuneResponseModel> getPalmistryFortune();

  Future<FortuneResponseModel> getMBTIFortune();
  Future<FortuneResponseModel> getZodiacFortune();
  Future<FortuneResponseModel> getZodiacAnimalFortune();

  Future<FortuneResponseModel> getLoveFortune();
  Future<FortuneResponseModel> getMarriageFortune();
  Future<FortuneResponseModel> getCompatibilityFortune(String partnerId);

  Future<FortuneResponseModel> getCareerFortune();
  Future<FortuneResponseModel> getWealthFortune();
  Future<FortuneResponseModel> getBusinessFortune();

  Future<Map<String, FortuneResponseModel>> getBatchFortune(List<String> types);
  Stream<String> generateFortuneStream(
      String type, Map<String, dynamic> params);

  Future<List<FortuneResponseModel>> getFortuneHistory(
      {int? limit, String? type});
}

class FortuneRemoteDataSourceImpl implements FortuneRemoteDataSource {
  final ApiClient _apiClient;

  FortuneRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<FortuneResponseModel> getDailyFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.dailyFortune);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getTodayFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.today);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getTomorrowFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.tomorrow);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getHourlyFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.hourly);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getWeeklyFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.weekly);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getMonthlyFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.monthly);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getYearlyFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.yearly);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getTraditionalSajuFortune() async {
    try {
      final response = await _apiClient
          .get<Map<String, dynamic>>(ApiEndpoints.traditionalSaju);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getTojeongFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.tojeong);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getPalmistryFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.palmistry);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getMBTIFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.mbtiFortune);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getZodiacFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.zodiac);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getZodiacAnimalFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.zodiacAnimal);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getLoveFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.loveFortune);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getMarriageFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.marriage);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getCompatibilityFortune(String partnerId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.compatibilityFortune,
          data: {'partnerId': partnerId});
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getCareerFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.career);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getWealthFortune() async {
    try {
      final response = await _apiClient
          .get<Map<String, dynamic>>(ApiEndpoints.wealthFortune);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FortuneResponseModel> getBusinessFortune() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.business);
      return FortuneResponseModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, FortuneResponseModel>> getBatchFortune(
      List<String> types) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.batchFortune,
          data: {'fortuneTypes': types});

      final Map<String, FortuneResponseModel> result = {};
      response.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          result[key] = FortuneResponseModel.fromJson(value);
        }
      });

      return result;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Stream<String> generateFortuneStream(
      String type, Map<String, dynamic> params) {
    return _apiClient
        .getStream(ApiEndpoints.generate, data: {'type': type, ...params});
  }

  @override
  Future<List<FortuneResponseModel>> getFortuneHistory(
      {int? limit, String? type}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
          ApiEndpoints.fortuneHistory,
          queryParameters: {
            if (limit != null) 'limit': null,
            if (type != null) 'type': null
          });

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => FortuneResponseModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ServerException ||
        error is TokenException ||
        error is NetworkException ||
        error is AuthException) {
      return error;
    }
    return ServerException(message: error.toString());
  }
}
