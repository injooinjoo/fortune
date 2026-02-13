import '../../../domain/entities/fortune.dart';

class CareerFortuneApi {
  // Career Fortune - delegates to generic getFortune
  Future<Fortune> getCareerFortune(
      {required String userId,
      required Future<Fortune> Function(
              {required String fortuneType, required String userId})
          getFortune}) async {
    return getFortune(fortuneType: 'career', userId: userId);
  }

  // Business Fortune - delegates to generic getFortune
  Future<Fortune> getBusinessFortune(
      {required String userId,
      required Future<Fortune> Function(
              {required String fortuneType, required String userId})
          getFortune}) async {
    return getFortune(fortuneType: 'business', userId: userId);
  }

  // Employment Fortune - delegates to generic getFortune
  Future<Fortune> getEmploymentFortune(
      {required String userId,
      required Future<Fortune> Function(
              {required String fortuneType, required String userId})
          getFortune}) async {
    return getFortune(fortuneType: 'employment', userId: userId);
  }

  // Startup Fortune - delegates to generic getFortune
  Future<Fortune> getStartupFortune(
      {required String userId,
      required Future<Fortune> Function(
              {required String fortuneType, required String userId})
          getFortune}) async {
    return getFortune(fortuneType: 'startup', userId: userId);
  }

  // Career Coaching Fortune - delegates to generic getFortune
  Future<Fortune> getCareerCoachingFortune(
      {required String userId,
      Map<String, dynamic>? careerData,
      required Future<Fortune> Function(
              {required String fortuneType,
              required String userId,
              Map<String, dynamic>? params})
          getFortune}) async {
    return getFortune(
        fortuneType: 'career-coaching', userId: userId, params: careerData);
  }
}
