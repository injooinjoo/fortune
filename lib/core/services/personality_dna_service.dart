import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/personality_dna_model.dart';
import '../utils/logger.dart';
import 'unified_fortune_service.dart';

/// 성격 DNA 생성 및 분석 서비스
///
/// ✅ 최적화 플로우 통합 (2025.01.04)
/// - 직접 Edge Function 호출 → UnifiedFortuneService 경유
/// - 캐시/Cohort Pool/DB 풀 자동 적용
class PersonalityDNAService {

  /// API를 통한 DNA 조합 생성
  ///
  /// ✅ 최적화 플로우:
  /// 1. UnifiedFortuneService.getFortune() 호출
  /// 2. 개인 캐시 → Cohort Pool → DB 풀 → API 순서
  /// 3. FortuneResult → PersonalityDNA 변환
  static Future<PersonalityDNA> generateDNA({
    required String userId,
    required String name,
    required String mbti,
    required String bloodType,
    required String zodiac,
    required String zodiacAnimal,
  }) async {
    try {
      Logger.info('[PersonalityDNAService] 🔮 성격 DNA 생성 시작 (최적화 플로우)');

      // ✅ 최적화 플로우를 통한 API 호출
      final supabase = Supabase.instance.client;
      final fortuneService = UnifiedFortuneService(supabase);

      final result = await fortuneService.getFortune(
        fortuneType: 'personality-dna',
        dataSource: FortuneDataSource.api, // API 호출 → 최적화 플로우 적용
        inputConditions: {
          'userId': userId,
          'name': name,
          'mbti': mbti,
          'bloodType': bloodType,
          'zodiac': zodiac,
          'zodiacAnimal': zodiacAnimal,
        },
        isPremium: false, // 프리미엄 상태는 호출하는 곳에서 처리
      );

      if (result.data.isEmpty) {
        throw Exception('API 응답이 비어있습니다.');
      }

      Logger.info('[PersonalityDNAService] ✅ 최적화 플로우 완료');

      // 그라데이션 색상 생성 (기존 로직 활용)
      final gradientColors = _getGradientColors(mbti, zodiacAnimal);

      // 기존 점수 시스템 활용 (호환성을 위해)
      final scores = _generateScores(mbti, bloodType, zodiacAnimal);

      // FortuneResult.data를 PersonalityDNA 객체로 변환
      final personalityDNA = PersonalityDNA.fromApiResponse(
        result.data,
        mbti: mbti,
        bloodType: bloodType,
        zodiac: zodiac,
        zodiacAnimal: zodiacAnimal,
        gradientColors: gradientColors,
        scores: scores,
      );

      // dailyFortune이 API 응답에 포함되어 있지 않으면 수동으로 파싱
      if (personalityDNA.dailyFortune == null && result.data['dailyFortune'] != null) {
        final dailyFortuneData = result.data['dailyFortune'] as Map<String, dynamic>;
        return personalityDNA.copyWith(
          dailyFortune: DailyFortune.fromJson(dailyFortuneData),
        );
      }

      return personalityDNA;
    } catch (e) {
      Logger.error('[PersonalityDNAService] API 오류, 로컬 폴백: $e');
      // API 오류 시 기존 로컬 로직으로 폴백
      return _generateLocalDNA(
        mbti: mbti,
        bloodType: bloodType,
        zodiac: zodiac,
        zodiacAnimal: zodiacAnimal,
      );
    }
  }

  /// 로컬 DNA 생성 (폴백용)
  static PersonalityDNA _generateLocalDNA({
    required String mbti,
    required String bloodType,
    required String zodiac,
    required String zodiacAnimal,
  }) {
    final combinationKey = '$mbti-$bloodType-$zodiacAnimal';
    final dnaCode = PersonalityDNA.generateDNACode(
      mbti: mbti,
      bloodType: bloodType,
      zodiac: zodiac,
      zodiacAnimal: zodiacAnimal,
    );
    
    // 조합에 따른 DNA 정보 가져오기
    final dnaInfo = _getDNAInfo(combinationKey, mbti, bloodType, zodiacAnimal);
    
    // 새로운 재미있는 콘텐츠 생성
    final loveStyle = _generateLoveStyle(mbti);
    final workStyle = _generateWorkStyle(mbti);
    final dailyMatching = _generateDailyMatching(mbti);
    final compatibility = _generateCompatibility(mbti);
    final celebrity = _generateCelebrity(mbti);
    
    return PersonalityDNA(
      mbti: mbti,
      bloodType: bloodType,
      zodiac: zodiac,
      zodiacAnimal: zodiacAnimal,
      dnaCode: dnaCode,
      title: dnaInfo['title'],
      emoji: dnaInfo['emoji'],
      description: dnaInfo['description'],
      traits: List<String>.from(dnaInfo['traits']),
      gradientColors: List<Color>.from(dnaInfo['colors']),
      scores: Map<String, int>.from(dnaInfo['scores']),
      todaysFortune: dnaInfo['todaysFortune'],
      todayHighlight: '오늘은 $mbti의 특별한 매력이 빛나는 날입니다!',
      loveStyle: loveStyle,
      workStyle: workStyle,
      dailyMatching: dailyMatching,
      compatibility: compatibility,
      celebrity: celebrity,
      funnyFact: '$mbti는 전체 인구의 ${_getMBTIPopulation(mbti)}%를 차지합니다!',
      popularityRank: _getMBTIPopularityRank(mbti),
    );
  }

  /// 그라데이션 색상 생성
  static List<Color> _getGradientColors(String mbti, String zodiacAnimal) {
    final mbtiColors = _getMBTIInfo(mbti)['color'] as Color;
    final animalColors = _getZodiacAnimalInfo(zodiacAnimal)['color'] as Color;
    return [mbtiColors, animalColors];
  }

  /// 점수 생성
  static Map<String, int> _generateScores(String mbti, String bloodType, String zodiacAnimal) {
    final mbtiInfo = _getMBTIInfo(mbti);
    final bloodInfo = _getBloodTypeInfo(bloodType);
    final animalInfo = _getZodiacAnimalInfo(zodiacAnimal);
    
    return <String, int>{
      mbtiInfo['primaryStat']: 80 + (DateTime.now().millisecond % 20),
      bloodInfo['primaryStat']: 75 + (DateTime.now().microsecond % 25),
      animalInfo['primaryStat']: 70 + (DateTime.now().second % 30),
    };
  }
  
  /// 조합에 따른 DNA 정보 생성
  static Map<String, dynamic> _getDNAInfo(String combinationKey, String mbti, String bloodType, String zodiacAnimal) {
    // 특정 조합에 대한 정의
    final specificCombinations = _getSpecificCombinations();
    
    if (specificCombinations.containsKey(combinationKey)) {
      return specificCombinations[combinationKey]!;
    }
    
    // 일반적인 조합 규칙으로 생성
    return _generateGenericDNA(mbti, bloodType, zodiacAnimal);
  }
  
  /// 특별한 조합들 정의
  static Map<String, Map<String, dynamic>> _getSpecificCombinations() {
    return {
      'ENTJ-O-용': {
        'title': '황제 리더형 DNA',
        'emoji': '👑',
        'description': '타고난 카리스마와 용의 기운으로 무장한 천생 리더!',
        'traits': ['절대 카리스마', '강력한 추진력', '천부적 리더십'],
        'colors': [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
        'scores': {'리더십': 98, '결단력': 95, '야망': 97, '자신감': 94},
        'todaysFortune': '용의 기운이 당신을 감싸며 모든 도전에서 승리할 것입니다. 오늘은 중대한 결정을 내리기 최적의 날입니다.'
      },
      'INFP-A-토끼': {
        'title': '몽상가 예술가 DNA',
        'emoji': '🎨',
        'description': '섬세한 감성과 토끼의 순수함이 만드는 완벽한 예술혼!',
        'traits': ['순수한 감성', '무한 창의력', '깊은 공감력'],
        'colors': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
        'scores': {'창의력': 96, '공감력': 94, '직관력': 92, '예술성': 98},
        'todaysFortune': '토끼의 영감이 당신에게 새로운 창작 아이디어를 가져다줄 것입니다. 예술적 활동에 집중하세요.'
      },
      'ESTP-B-호랑이': {
        'title': '모험가 전사 DNA',
        'emoji': '🐅',
        'description': 'B형의 자유로운 영혼과 호랑이의 용맹함이 만든 완벽한 모험가!',
        'traits': ['무한 에너지', '순간 판단력', '도전 정신'],
        'colors': [const Color(0xFFFF9800), const Color(0xFFFF5722)],
        'scores': {'행동력': 97, '모험심': 95, '순발력': 94, '용기': 96},
        'todaysFortune': '호랑이의 용맹함이 당신을 새로운 모험으로 이끌 것입니다. 두려움 없이 도전하세요!'
      },
      'INTJ-AB-뱀': {
        'title': '전략가 현자 DNA',
        'emoji': '🧙‍♂️',
        'description': 'AB형의 이성적 판단력과 뱀의 지혜가 만든 완벽한 전략가!',
        'traits': ['천재적 전략', '냉철한 판단', '미래 통찰력'],
        'colors': [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
        'scores': {'지능': 98, '전략력': 97, '분석력': 96, '통찰력': 95},
        'todaysFortune': '뱀의 지혜가 복잡한 문제의 해답을 제시할 것입니다. 장기적 관점에서 계획을 세우세요.'
      },
    };
  }
  
  /// 일반적인 조합 규칙으로 DNA 생성
  static Map<String, dynamic> _generateGenericDNA(String mbti, String bloodType, String zodiacAnimal) {
    final mbtiInfo = _getMBTIInfo(mbti);
    final bloodInfo = _getBloodTypeInfo(bloodType);
    final animalInfo = _getZodiacAnimalInfo(zodiacAnimal);
    
    // 조합 제목 생성
    final title = '${mbtiInfo['adjective']} ${animalInfo['adjective']}형 DNA';
    
    // 특성 조합
    final traits = <String>[
      mbtiInfo['trait'],
      bloodInfo['trait'],
      animalInfo['trait'],
    ];
    
    // 색상 조합
    final colors = <Color>[
      mbtiInfo['color'],
      animalInfo['color'],
    ];
    
    // 점수 생성 (랜덤 + 특성 보정)
    final scores = <String, int>{
      mbtiInfo['primaryStat']: 80 + (DateTime.now().millisecond % 20),
      bloodInfo['primaryStat']: 75 + (DateTime.now().microsecond % 25),
      animalInfo['primaryStat']: 70 + (DateTime.now().second % 30),
    };
    
    // 운세 메시지 생성
    final todaysFortune = '${animalInfo['name']}의 기운과 $mbti의 특성이 조화롭게 어우러져 ${bloodInfo['personality']} 하루를 만들어갈 것입니다.';
    
    return {
      'title': title,
      'emoji': animalInfo['emoji'],
      'description': '${mbtiInfo['description']}과 ${animalInfo['description']}의 완벽한 조화!',
      'traits': traits,
      'colors': colors,
      'scores': scores,
      'todaysFortune': todaysFortune,
    };
  }
  
  /// MBTI별 정보
  static Map<String, dynamic> _getMBTIInfo(String mbti) {
    final mbtiMap = {
      'ENTJ': {
        'adjective': '황제',
        'trait': '강력한 리더십',
        'description': '타고난 지휘관의 기질',
        'color': const Color(0xFFE91E63),
        'primaryStat': '리더십'
      },
      'ENTP': {
        'adjective': '발명가',
        'trait': '창의적 사고력',
        'description': '혁신적인 아이디어 메이커',
        'color': const Color(0xFFFF9800),
        'primaryStat': '창의력'
      },
      'INTJ': {
        'adjective': '전략가',
        'trait': '냉철한 분석력',
        'description': '미래를 내다보는 현자',
        'color': const Color(0xFF673AB7),
        'primaryStat': '전략력'
      },
      'INTP': {
        'adjective': '사상가',
        'trait': '논리적 사고력',
        'description': '진리를 탐구하는 학자',
        'color': const Color(0xFF3F51B5),
        'primaryStat': '지능'
      },
      'ENFJ': {
        'adjective': '선도자',
        'trait': '카리스마적 영향력',
        'description': '사람을 이끄는 천성',
        'color': const Color(0xFF4CAF50),
        'primaryStat': '카리스마'
      },
      'ENFP': {
        'adjective': '활동가',
        'trait': '열정적 에너지',
        'description': '끝없는 가능성의 추구자',
        'color': const Color(0xFF8BC34A),
        'primaryStat': '열정'
      },
      'INFJ': {
        'adjective': '옹호자',
        'trait': '깊은 통찰력',
        'description': '신비로운 이상주의자',
        'color': const Color(0xFF009688),
        'primaryStat': '통찰력'
      },
      'INFP': {
        'adjective': '중재자',
        'trait': '순수한 감성',
        'description': '예술가적 영혼',
        'color': const Color(0xFF00BCD4),
        'primaryStat': '감성'
      },
      'ESTJ': {
        'adjective': '경영자',
        'trait': '실행 능력',
        'description': '체계적인 관리자',
        'color': const Color(0xFF795548),
        'primaryStat': '실행력'
      },
      'ESTP': {
        'adjective': '모험가',
        'trait': '순간 판단력',
        'description': '현재를 즐기는 행동파',
        'color': const Color(0xFFFF5722),
        'primaryStat': '행동력'
      },
      'ISTJ': {
        'adjective': '관리자',
        'trait': '신뢰성',
        'description': '책임감 있는 수호자',
        'color': const Color(0xFF607D8B),
        'primaryStat': '신뢰도'
      },
      'ISTP': {
        'adjective': '장인',
        'trait': '실용적 기술',
        'description': '조용한 완벽주의자',
        'color': const Color(0xFF9E9E9E),
        'primaryStat': '기술력'
      },
      'ESFJ': {
        'adjective': '집정관',
        'trait': '배려심',
        'description': '따뜻한 마음의 소유자',
        'color': const Color(0xFFE91E63),
        'primaryStat': '배려'
      },
      'ESFP': {
        'adjective': '연예인',
        'trait': '사교성',
        'description': '무대 위의 스타',
        'color': const Color(0xFFF44336),
        'primaryStat': '사교력'
      },
      'ISFJ': {
        'adjective': '수호자',
        'trait': '헌신성',
        'description': '조용한 봉사자',
        'color': const Color(0xFF2196F3),
        'primaryStat': '헌신'
      },
      'ISFP': {
        'adjective': '탐험가',
        'trait': '예술적 감각',
        'description': '자유로운 예술가',
        'color': const Color(0xFF03A9F4),
        'primaryStat': '예술성'
      },
    };
    
    return mbtiMap[mbti] ?? mbtiMap['ENTJ']!;
  }
  
  /// 혈액형별 정보
  static Map<String, dynamic> _getBloodTypeInfo(String bloodType) {
    final bloodMap = {
      'A': {
        'trait': '꼼꼼한 완벽주의',
        'personality': '신중하고 계획적인',
        'primaryStat': '꼼꼼함'
      },
      'B': {
        'trait': '자유로운 창의성',
        'personality': '독창적이고 자유분방한',
        'primaryStat': '창의력'
      },
      'O': {
        'trait': '열정적 추진력',
        'personality': '활발하고 적극적인',
        'primaryStat': '열정'
      },
      'AB': {
        'trait': '이성적 균형감',
        'personality': '논리적이고 냉철한',
        'primaryStat': '균형감'
      },
    };
    
    return bloodMap[bloodType] ?? bloodMap['O']!;
  }
  
  /// 띠별 정보
  static Map<String, dynamic> _getZodiacAnimalInfo(String animal) {
    final animalMap = {
      '쥐': {
        'name': '쥐',
        'adjective': '영리한',
        'trait': '기민한 적응력',
        'description': '똑똑하고 재빠른 생존 본능',
        'emoji': '🐭',
        'color': const Color(0xFF9C27B0),
        'primaryStat': '적응력'
      },
      '소': {
        'name': '소',
        'adjective': '성실한',
        'trait': '끈기와 인내력',
        'description': '묵묵히 걷는 신뢰의 상징',
        'emoji': '🐂',
        'color': const Color(0xFF795548),
        'primaryStat': '끈기'
      },
      '호랑이': {
        'name': '호랑이',
        'adjective': '용맹한',
        'trait': '강인한 용기',
        'description': '두려움 없는 백수의 왕',
        'emoji': '🐅',
        'color': const Color(0xFFFF9800),
        'primaryStat': '용기'
      },
      '토끼': {
        'name': '토끼',
        'adjective': '순수한',
        'trait': '섬세한 감수성',
        'description': '온화하고 평화로운 마음',
        'emoji': '🐰',
        'color': const Color(0xFFE91E63),
        'primaryStat': '감수성'
      },
      '용': {
        'name': '용',
        'adjective': '위대한',
        'trait': '절대적 카리스마',
        'description': '하늘을 나는 신성한 존재',
        'emoji': '🐉',
        'color': const Color(0xFFFF5722),
        'primaryStat': '카리스마'
      },
      '뱀': {
        'name': '뱀',
        'adjective': '지혜로운',
        'trait': '신비한 직감력',
        'description': '깊은 사색과 통찰의 상징',
        'emoji': '🐍',
        'color': const Color(0xFF4CAF50),
        'primaryStat': '직감'
      },
      '말': {
        'name': '말',
        'adjective': '자유로운',
        'trait': '거침없는 활력',
        'description': '바람처럼 자유로운 영혼',
        'emoji': '🐴',
        'color': const Color(0xFF2196F3),
        'primaryStat': '활력'
      },
      '양': {
        'name': '양',
        'adjective': '온순한',
        'trait': '따뜻한 배려심',
        'description': '부드럽고 친근한 마음씨',
        'emoji': '🐑',
        'color': const Color(0xFF00BCD4),
        'primaryStat': '배려'
      },
      '원숭이': {
        'name': '원숭이',
        'adjective': '똑똑한',
        'trait': '빠른 기지력',
        'description': '재치 있고 유머러스한 성격',
        'emoji': '🐒',
        'color': const Color(0xFFCDDC39),
        'primaryStat': '기지'
      },
      '닭': {
        'name': '닭',
        'adjective': '부지런한',
        'trait': '성실한 근면함',
        'description': '새벽을 여는 성실한 일꾼',
        'emoji': '🐓',
        'color': const Color(0xFFFF9800),
        'primaryStat': '성실'
      },
      '개': {
        'name': '개',
        'adjective': '충직한',
        'trait': '진실한 충성심',
        'description': '변하지 않는 의리와 충성',
        'emoji': '🐕',
        'color': const Color(0xFF8BC34A),
        'primaryStat': '충성'
      },
      '돼지': {
        'name': '돼지',
        'adjective': '관대한',
        'trait': '풍부한 포용력',
        'description': '너그럽고 관대한 마음',
        'emoji': '🐷',
        'color': const Color(0xFFF44336),
        'primaryStat': '포용력'
      },
    };
    
    return animalMap[animal] ?? animalMap['용']!;
  }
  
  /// 12지 목록
  static const List<String> zodiacAnimals = [
    '쥐', '소', '호랑이', '토끼', '용', '뱀',
    '말', '양', '원숭이', '닭', '개', '돼지'
  ];
  
  /// MBTI 목록
  static const List<String> mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP'
  ];
  
  /// 혈액형 목록
  static const List<String> bloodTypes = ['A', 'B', 'O', 'AB'];
  
  /// 별자리 목록
  static const List<String> zodiacSigns = [
    '양자리', '황소자리', '쌍둥이자리', '게자리',
    '사자자리', '처녀자리', '천칭자리', '전갈자리',
    '사수자리', '염소자리', '물병자리', '물고기자리'
  ];
  
  /// 연애 스타일 생성
  static LoveStyle _generateLoveStyle(String mbti) {
    final loveStyles = {
      'ENTJ': const LoveStyle(
        title: '황제의 열정적 사랑',
        description: '사랑도 계획적이고 체계적으로! 목표지향적인 연애를 합니다.',
        whenDating: '완벽한 데이트 코스를 기획하고 상대방을 리드합니다. 장기적인 관계를 중시해요.',
        afterBreakup: '감정보다는 논리적으로 접근해서 빠르게 정리합니다. 다음 연애도 계획적으로!',
      ),
      'ENTP': const LoveStyle(
        title: '썸의 마법사형',
        description: '새로운 사랑에 대한 호기심이 넘치는 연애 스타일입니다.',
        whenDating: '재미있는 대화와 독창적인 아이디어로 상대방을 매혹시킵니다.',
        afterBreakup: '아쉬워하면서도 새로운 만남에 대한 기대감을 가집니다.',
      ),
      'INTJ': const LoveStyle(
        title: '신중한 전략가 사랑',
        description: '선택받은 사람만을 위한 깊고 진실한 사랑을 합니다.',
        whenDating: '상대방을 깊이 이해하려 노력하고 의미 있는 대화를 즐깁니다.',
        afterBreakup: '혼자만의 시간을 통해 관계를 분석하고 다음 연애의 교훈으로 삼아요.',
      ),
      'ENFP': const LoveStyle(
        title: '열정적인 로맨티스트',
        description: '사랑에 빠지면 온 세상이 아름다워 보이는 타입입니다.',
        whenDating: '상대방을 응원하고 격려하며 함께 꿈을 키워나갑니다.',
        afterBreakup: '상처받지만 금방 회복하고 다시 사랑을 믿게 됩니다.',
      ),
      'INFP': const LoveStyle(
        title: '순수한 이상주의자',
        description: '진정한 사랑을 꿈꾸는 로맨틱한 연애 스타일입니다.',
        whenDating: '상대방의 내면을 이해하려 하고 감성적인 교감을 중시합니다.',
        afterBreakup: '오랫동안 그리워하며 그 사람만의 특별함을 기억합니다.',
      ),
    };
    
    return loveStyles[mbti] ?? LoveStyle(
      title: '$mbti만의 특별한 사랑',
      description: '$mbti 특유의 매력적인 연애 스타일을 가지고 있습니다.',
      whenDating: '$mbti의 특성을 살린 따뜻한 연애를 합니다.',
      afterBreakup: '$mbti 나름의 방식으로 이별을 받아들이고 성장합니다.',
    );
  }
  
  /// 업무 스타일 생성
  static WorkStyle _generateWorkStyle(String mbti) {
    final workStyles = {
      'ENTJ': const WorkStyle(
        title: '카리스마 넘치는 리더',
        asBoss: '명확한 비전을 제시하고 팀을 이끌어갑니다. 성과를 중시하지만 공정합니다.',
        atCompanyDinner: '자연스럽게 분위기를 이끌고 팀원들과의 소통을 중요하게 여깁니다.',
        workHabit: '체계적이고 효율적으로 업무를 처리합니다. 목표 달성을 위해 최선을 다해요.',
      ),
      'ENTP': const WorkStyle(
        title: '아이디어 뱅크형 직장인',
        asBoss: '창의적인 아이디어를 장려하고 자유로운 분위기를 만듭니다.',
        atCompanyDinner: '재미있는 이야기로 분위기 메이커 역할을 합니다.',
        workHabit: '새로운 프로젝트에 흥미를 보이고 혁신적인 방법을 시도합니다.',
      ),
      'INTJ': const WorkStyle(
        title: '전략적 사고의 달인',
        asBoss: '장기적인 관점에서 팀을 이끌고 각자의 전문성을 존중합니다.',
        atCompanyDinner: '진지한 대화를 즐기고 업무 관련 인사이트를 공유합니다.',
        workHabit: '완벽주의 성향으로 세심하게 계획을 세우고 실행합니다.',
      ),
    };
    
    return workStyles[mbti] ?? WorkStyle(
      title: '$mbti형 직장인',
      asBoss: '$mbti의 특성을 살린 리더십을 발휘합니다.',
      atCompanyDinner: '$mbti만의 매력으로 동료들과 소통합니다.',
      workHabit: '$mbti 특유의 업무 처리 방식을 가지고 있습니다.',
    );
  }
  
  /// 일상 매칭 생성
  static DailyMatching _generateDailyMatching(String mbti) {
    final dailyMatchings = {
      'ENTJ': const DailyMatching(
        cafeMenu: '아메리카노 (진하고 강렬하게)',
        netflixGenre: '경영 다큐멘터리',
        weekendActivity: '새로운 비즈니스 아이디어 구상',
      ),
      'ENTP': const DailyMatching(
        cafeMenu: '계절 한정 메뉴 (새로운 맛을 찾아서)',
        netflixGenre: 'SF 스릴러',
        weekendActivity: '새로운 카페 탐방',
      ),
      'INTJ': const DailyMatching(
        cafeMenu: '드립커피 (정성스럽게 내린)',
        netflixGenre: '미스터리 드라마',
        weekendActivity: '독서와 사색',
      ),
      'INFP': const DailyMatching(
        cafeMenu: '바닐라 라떼 (부드럽고 달콤하게)',
        netflixGenre: '감성 영화',
        weekendActivity: '혼자만의 창작 활동',
      ),
      'ENFP': const DailyMatching(
        cafeMenu: '카라멜 마키아토 (달콤하고 화려하게)',
        netflixGenre: '로맨틱 코미디',
        weekendActivity: '친구들과의 즐거운 모임',
      ),
    };
    
    return dailyMatchings[mbti] ?? DailyMatching(
      cafeMenu: '$mbti가 좋아할만한 특별한 메뉴',
      netflixGenre: '$mbti 취향저격 장르',
      weekendActivity: '$mbti만의 완벽한 주말',
    );
  }
  
  /// 궁합 생성
  static Compatibility _generateCompatibility(String mbti) {
    final compatibilities = {
      'ENTJ': const Compatibility(
        friend: CompatibilityType(mbti: 'ENTP', description: '서로의 아이디어를 발전시켜주는 완벽한 브레인 파트너'),
        lover: CompatibilityType(mbti: 'INFP', description: '당신의 강함을 부드럽게 받아주는 따뜻한 연인'),
        colleague: CompatibilityType(mbti: 'INTJ', description: '전략적 사고를 공유하는 최고의 업무 파트너'),
      ),
      'ENTP': const Compatibility(
        friend: CompatibilityType(mbti: 'ENFP', description: '끝없는 에너지와 재미를 함께하는 절친'),
        lover: CompatibilityType(mbti: 'INFJ', description: '당신의 자유로운 영혼을 이해해주는 이상적인 파트너'),
        colleague: CompatibilityType(mbti: 'ENTJ', description: '혁신적인 아이디어를 현실로 만드는 드림팀'),
      ),
      'INTJ': const Compatibility(
        friend: CompatibilityType(mbti: 'INFJ', description: '깊이 있는 대화를 나눌 수 있는 지적인 친구'),
        lover: CompatibilityType(mbti: 'ENFP', description: '당신의 세계에 활기를 불어넣어주는 특별한 사람'),
        colleague: CompatibilityType(mbti: 'ENTJ', description: '큰 그림을 그려나가는 완벽한 비즈니스 파트너'),
      ),
    };
    
    // 기본값 설정
    final defaultFriends = ['ENFP', 'ENTP', 'ESFP'];
    final defaultLovers = ['INFJ', 'INFP', 'ENFJ'];
    final defaultColleagues = ['ENTJ', 'ESTJ', 'INTJ'];
    
    return compatibilities[mbti] ?? Compatibility(
      friend: CompatibilityType(mbti: defaultFriends[mbti.hashCode % 3], description: '서로를 이해하고 응원하는 좋은 친구'),
      lover: CompatibilityType(mbti: defaultLovers[mbti.hashCode % 3], description: '마음이 통하는 이상적인 연인'),
      colleague: CompatibilityType(mbti: defaultColleagues[mbti.hashCode % 3], description: '업무에서 시너지를 내는 파트너'),
    );
  }
  
  /// 유명인 생성
  static Celebrity _generateCelebrity(String mbti) {
    final celebrities = {
      'ENTJ': const Celebrity(name: '스티브 잡스', reason: '혁신적인 비전과 강력한 리더십으로 세상을 바꾼 CEO'),
      'ENTP': const Celebrity(name: '로버트 다우니 주니어', reason: '창의적이고 매력적인 아이디어로 사람들을 매혹시키는 배우'),
      'INTJ': const Celebrity(name: '일론 머스크', reason: '미래를 내다보는 전략적 사고로 혁신을 만들어내는 기업가'),
      'INFP': const Celebrity(name: '박보검', reason: '순수하고 따뜻한 매력으로 많은 사람들에게 사랑받는 배우'),
      'ENFP': const Celebrity(name: '유재석', reason: '긍정적인 에너지와 사람들을 즐겁게 하는 재능을 가진 MC'),
      'INFJ': const Celebrity(name: '손흥민', reason: '겸손하면서도 목표를 향한 강한 의지를 가진 축구선수'),
      'ISFJ': const Celebrity(name: '아이유', reason: '타인을 배려하고 완벽주의적인 성향을 가진 가수'),
      'ISFP': const Celebrity(name: '방탄소년단 지민', reason: '예술적 감각과 섬세한 감성을 가진 아티스트'),
      'ESFJ': const Celebrity(name: '송혜교', reason: '따뜻하고 사교적인 매력으로 사랑받는 배우'),
      'ESFP': const Celebrity(name: '박나래', reason: '활발하고 재미있는 성격으로 분위기를 이끄는 연예인'),
      'ESTJ': const Celebrity(name: '정우성', reason: '책임감 있고 신뢰할 수 있는 리더십을 보여주는 배우'),
      'ESTP': const Celebrity(name: '강호동', reason: '즉흥적이고 에너지 넘치는 매력을 가진 MC'),
      'ISTJ': const Celebrity(name: '김연아', reason: '완벽을 추구하고 성실함으로 목표를 달성한 피겨 선수'),
      'ISTP': const Celebrity(name: '정우성', reason: '조용하지만 확고한 자신만의 철학을 가진 배우'),
      'ENFJ': const Celebrity(name: '오프라 윈프리', reason: '사람들에게 영감을 주고 이끄는 카리스마적 리더'),
      'INTP': const Celebrity(name: '빌 게이츠', reason: '논리적 사고와 혁신적 아이디어로 세상을 바꾼 기업가'),
    };
    
    return celebrities[mbti] ?? Celebrity(
      name: '당신과 닮은 유명인',
      reason: '$mbti 특유의 매력을 가진 특별한 사람',
    );
  }
  
  /// MBTI 인구 비율 반환
  static String _getMBTIPopulation(String mbti) {
    final populations = {
      'ENTJ': '2-4', 'ENTP': '3-5', 'INTJ': '1-3', 'INTP': '3-5',
      'ENFJ': '2-5', 'ENFP': '7-9', 'INFJ': '1-3', 'INFP': '4-5',
      'ESTJ': '8-12', 'ESTP': '4-10', 'ISTJ': '11-14', 'ISTP': '5-9',
      'ESFJ': '9-13', 'ESFP': '4-9', 'ISFJ': '9-14', 'ISFP': '5-9',
    };
    return populations[mbti] ?? '5-8';
  }
  
  /// MBTI 인기 순위 반환
  static int _getMBTIPopularityRank(String mbti) {
    final ranks = {
      'ENTJ': 15, 'ENTP': 8, 'INTJ': 12, 'INTP': 10,
      'ENFJ': 6, 'ENFP': 3, 'INFJ': 7, 'INFP': 5,
      'ESTJ': 14, 'ESTP': 9, 'ISTJ': 16, 'ISTP': 11,
      'ESFJ': 13, 'ESFP': 4, 'ISFJ': 2, 'ISFP': 1,
    };
    return ranks[mbti] ?? 8;
  }
}