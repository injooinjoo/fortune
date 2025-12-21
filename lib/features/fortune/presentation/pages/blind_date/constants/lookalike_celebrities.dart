import 'dart:math';

/// 남자 연예인 닮은꼴 데이터
const List<Map<String, String>> maleCelebrities = [
  {'name': '차은우', 'type': '조각미남', 'trait': '압도적 비주얼'},
  {'name': '현빈', 'type': '댄디', 'trait': '성숙한 매력'},
  {'name': '공유', 'type': '따뜻한', 'trait': '포근한 눈빛'},
  {'name': '송중기', 'type': '청순', 'trait': '소년미'},
  {'name': '박서준', 'type': '훈훈한', 'trait': '친근한 인상'},
  {'name': '이종석', 'type': '청순', 'trait': '청량한 매력'},
  {'name': '김수현', 'type': '도도한', 'trait': '시크한 눈빛'},
  {'name': '박보검', 'type': '순수', 'trait': '해맑은 미소'},
  {'name': '이민호', 'type': '도시적', 'trait': '카리스마'},
  {'name': '서강준', 'type': '청량한', 'trait': '시원한 이목구비'},
  {'name': '남주혁', 'type': '매력적', 'trait': '독특한 분위기'},
  {'name': '지창욱', 'type': '훈훈한', 'trait': '반전 매력'},
  {'name': '정해인', 'type': '다정한', 'trait': '따뜻한 미소'},
  {'name': '송강', 'type': '조각같은', 'trait': '섬세한 이목구비'},
  {'name': '위하준', 'type': '독특한', 'trait': '깊은 눈빛'},
];

/// 여자 연예인 닮은꼴 데이터
const List<Map<String, String>> femaleCelebrities = [
  {'name': '수지', 'type': '청순', 'trait': '맑은 눈빛'},
  {'name': '제니', 'type': '힙한', 'trait': '시크한 매력'},
  {'name': 'IU', 'type': '청순', 'trait': '청아한 분위기'},
  {'name': '한소희', 'type': '몽환적', 'trait': '신비로운 눈빛'},
  {'name': '김태리', 'type': '자연스러운', 'trait': '독보적 아우라'},
  {'name': '전지현', 'type': '카리스마', 'trait': '압도적 존재감'},
  {'name': '손예진', 'type': '우아한', 'trait': '고급스러운 매력'},
  {'name': '김고은', 'type': '청순', 'trait': '맑고 투명한'},
  {'name': '박신혜', 'type': '사랑스러운', 'trait': '밝은 에너지'},
  {'name': '송혜교', 'type': '우아한', 'trait': '고혹적인 눈빛'},
  {'name': '아이유', 'type': '청순', 'trait': '청아한 분위기'},
  {'name': '카리나', 'type': '인형같은', 'trait': '완벽한 비율'},
  {'name': '윈터', 'type': '차가운', 'trait': '시크한 매력'},
  {'name': '장원영', 'type': '인형같은', 'trait': '생기발랄'},
  {'name': '김유정', 'type': '귀여운', 'trait': '사랑스러운'},
];

/// 관상 유형별 설명
const Map<String, String> faceTypeDescriptions = {
  '조각미남': '완벽한 이목구비와 뚜렷한 윤곽',
  '댄디': '성숙하고 세련된 인상',
  '따뜻한': '포근하고 편안한 느낌',
  '청순': '맑고 깨끗한 이미지',
  '훈훈한': '친근하고 다가가기 쉬운',
  '도도한': '고급스럽고 시크한 분위기',
  '순수': '티없이 맑은 인상',
  '도시적': '세련되고 모던한 매력',
  '청량한': '시원하고 상쾌한 느낌',
  '매력적': '독특하고 개성있는',
  '다정한': '따뜻하고 자상한 인상',
  '조각같은': '정교하고 섬세한 이목구비',
  '독특한': '개성 넘치는 분위기',
  '힙한': '트렌디하고 세련된',
  '몽환적': '신비롭고 몽글몽글한',
  '자연스러운': '꾸밈없이 아름다운',
  '카리스마': '강렬하고 압도적인',
  '우아한': '고급스럽고 기품있는',
  '사랑스러운': '귀엽고 밝은 에너지',
  '인형같은': '완벽한 비율과 이목구비',
  '차가운': '시크하고 도도한',
  '귀여운': '사랑스럽고 생기발랄한',
};

/// 랜덤 연예인 닮은꼴 선택
/// [isMale] true면 남자 연예인, false면 여자 연예인
Map<String, String> getRandomLookalike({required bool isMale}) {
  final random = Random();
  final list = isMale ? maleCelebrities : femaleCelebrities;
  return list[random.nextInt(list.length)];
}

/// 관상 유형 설명 가져오기
String getFaceTypeDescription(String type) {
  return faceTypeDescriptions[type] ?? '매력적인 인상';
}

/// 나이 추정 (생년월일 기반 + 랜덤 오차)
/// [birthDate] 실제 생년월일
/// [variance] 오차 범위 (기본 ±3세)
int estimateAge(DateTime birthDate, {int variance = 3}) {
  final now = DateTime.now();
  final actualAge = now.year - birthDate.year -
      (now.month < birthDate.month ||
       (now.month == birthDate.month && now.day < birthDate.day) ? 1 : 0);

  final random = Random();
  final offset = random.nextInt(variance * 2 + 1) - variance;

  return (actualAge + offset).clamp(18, 60);
}

/// 관상 특징 생성 (재미 요소)
List<String> generateFaceTraits({required bool isMale}) {
  final random = Random();

  final maleTraits = [
    '이마가 넓어 지혜로운 인상',
    '눈이 깊어 신비로운 매력',
    '코가 오똑해 귀족적 분위기',
    '턱선이 뚜렷해 강인한 인상',
    '입술이 두꺼워 다정한 느낌',
    '광대가 높아 복이 들어올 상',
    '귀가 커서 재물운이 좋은 상',
  ];

  final femaleTraits = [
    '이마가 둥글어 복이 많은 상',
    '눈이 커서 감성이 풍부한 상',
    '코가 오똑해 자존심이 강한 상',
    '턱선이 부드러워 포용력 있는 상',
    '입술이 도톰해 인복이 좋은 상',
    '광대가 적당해 조화로운 상',
    '귀가 귀여워 사랑받는 상',
  ];

  final traits = isMale ? maleTraits : femaleTraits;
  final shuffled = List<String>.from(traits)..shuffle(random);

  return shuffled.take(3).toList();
}
