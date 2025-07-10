// MBTI 타입
const List<String> mbtiTypes = [
  "ISTJ", "ISFJ", "INFJ", "INTJ",
  "ISTP", "ISFP", "INFP", "INTP",
  "ESTP", "ESFP", "ENFP", "ENTP",
  "ESTJ", "ESFJ", "ENFJ", "ENTJ"
];

// 성별 옵션
enum Gender {
  male('male', '남성'),
  female('female', '여성'),
  other('other', '선택 안함');

  final String value;
  final String label;
  
  const Gender(this.value, this.label);
}

// 운세 타입
class FortuneTypes {
  static const String daily = "daily";
  static const String today = "today";
  static const String tomorrow = "tomorrow";
  static const String hourly = "hourly";
  static const String saju = "saju";
  static const String traditionalSaju = "traditional-saju";
  static const String sajuPsychology = "saju-psychology";
  static const String mbti = "mbti";
  static const String zodiac = "zodiac";
  static const String zodiacAnimal = "zodiac-animal";
  static const String love = "love";
  static const String career = "career";
  static const String wealth = "wealth";
  static const String biorhythm = "biorhythm";
  static const String tarot = "tarot";
  static const String compatibility = "compatibility";
}

// 구독 상태
enum SubscriptionStatus {
  free('free'),
  premium('premium'),
  premiumPlus('premium_plus'),
  enterprise('enterprise');

  final String value;
  
  const SubscriptionStatus(this.value);
  
  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.free,
    );
  }
}