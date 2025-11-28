import '../../../domain/entities/fortune.dart';
import '../../../core/utils/logger.dart';

class LuckyFortuneApi {
  // Lucky Color Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyColorFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-color', userId: userId);
  }

  // Lucky Number Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyNumberFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-number', userId: userId);
  }

  // Lucky Food Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyFoodFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-food', userId: userId);
  }

  // Lucky Baseball Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyBaseballFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-baseball', userId: userId);
  }

  // Lucky Golf Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyGolfFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-golf', userId: userId);
  }

  // Lucky Tennis Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyTennisFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-tennis', userId: userId);
  }

  // Lucky Running Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyRunningFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-running', userId: userId);
  }

  // Lucky Cycling Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyCyclingFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-cycling', userId: userId);
  }

  // Lucky Swim Fortune - delegates to generic getFortune
  Future<Fortune> getLuckySwimFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-swim', userId: userId);
  }

  // Lucky Hiking Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyHikingFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-hiking', userId: userId);
  }

  // Lucky Fishing Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyFishingFortune({
    required String userId,
    required Future<Fortune> Function({required String fortuneType, required String userId}) getFortune}) async {
    return getFortune(fortuneType: 'lucky-fishing', userId: userId);
  }

  // Lucky Exam Fortune - delegates to generic getFortune
  Future<Fortune> getLuckyExamFortune({
    required String userId,
    Map<String, dynamic>? examData,
    required Future<Fortune> Function({required String fortuneType, required String userId, Map<String, dynamic>? params}) getFortune}) async {
    return getFortune(
      fortuneType: 'lucky-exam',
      userId: userId,
      params: examData);
  }
}
