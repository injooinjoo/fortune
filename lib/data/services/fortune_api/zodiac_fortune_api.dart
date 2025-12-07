import '../../../domain/entities/fortune.dart';

class ZodiacFortuneApi {
  // Zodiac Fortune - delegates to generic getFortune
  Future<Fortune> getZodiacFortune({
    required String userId,
    required String zodiacSign,
    required Future<Fortune> Function({required String fortuneType, required String userId, Map<String, dynamic>? params}) getFortune}) async {
    return getFortune(
      fortuneType: 'zodiac',
      userId: userId,
      params: {'zodiacSign': zodiacSign});
  }

  // Zodiac Animal Fortune - delegates to generic getFortune
  Future<Fortune> getZodiacAnimalFortune({
    required String userId,
    required String zodiacAnimal,
    required Future<Fortune> Function({required String fortuneType, required String userId, Map<String, dynamic>? params}) getFortune}) async {
    return getFortune(
      fortuneType: 'zodiac-animal',
      userId: userId,
      params: {'zodiacAnimal': zodiacAnimal});
  }

  // Blood Type Fortune - delegates to generic getFortune
  Future<Fortune> getBloodTypeFortune({
    required String userId,
    required String bloodType,
    required Future<Fortune> Function({required String fortuneType, required String userId, Map<String, dynamic>? params}) getFortune}) async {
    return getFortune(
      fortuneType: 'blood-type',
      userId: userId,
      params: {'bloodType': bloodType});
  }
}
