import '../core/models/fortune_result.dart';

/// 하드코딩된 꿈 해몽 데이터 모델
///
/// 60개 인기 꿈 주제에 대한 상세 해몽을 미리 저장하여
/// API 호출 없이 즉시 결과를 제공합니다.
class DreamInterpretationData {
  final String dreamId;
  final String dreamType; // prophetic, anxiety, wish-fulfillment, processing, symbolic
  final String interpretation;
  final String todayGuidance;
  final String psychologicalState;
  final int emotionalBalance; // 1-10
  final int significanceLevel; // 1-10
  final List<String> actionAdvice;
  final List<String> affirmations;
  final List<String> relatedSymbols;

  const DreamInterpretationData({
    required this.dreamId,
    required this.dreamType,
    required this.interpretation,
    required this.todayGuidance,
    required this.psychologicalState,
    required this.emotionalBalance,
    required this.significanceLevel,
    required this.actionAdvice,
    required this.affirmations,
    required this.relatedSymbols,
  });

  /// FortuneResult로 변환 (기존 UI와 호환)
  FortuneResult toFortuneResult({required bool isPremium, required String dreamTitle}) {
    return FortuneResult(
      type: 'dream',
      title: '$dreamTitle 해몽',
      summary: {
        'dreamType': dreamType,
        'emotionalBalance': emotionalBalance,
        'significanceLevel': significanceLevel,
      },
      score: emotionalBalance * 10, // 1-10 → 10-100
      data: {
        'dreamType': dreamType,
        'interpretation': interpretation,
        'todayGuidance': todayGuidance,
        'psychologicalState': psychologicalState,
        'emotionalBalance': emotionalBalance,
        'significanceLevel': significanceLevel,
        'actionAdvice': actionAdvice,
        'affirmations': affirmations,
        'relatedSymbols': relatedSymbols,
        'timestamp': DateTime.now().toIso8601String(),
      },
      isBlurred: !isPremium,
      blurredSections: isPremium
          ? []
          : ['relatedSymbols', 'interpretation', 'todayGuidance'],
    );
  }
}

/// 60개 꿈에 대한 상세 해몽 데이터 저장소
class DreamInterpretations {
  DreamInterpretations._();

  /// ID로 해몽 데이터 조회
  static DreamInterpretationData? getById(String dreamId) {
    return _data[dreamId];
  }

  /// 전체 해몽 데이터
  static const Map<String, DreamInterpretationData> _data = {
    // ==================== 동물 (12개) ====================

    'snake': DreamInterpretationData(
      dreamId: 'snake',
      dreamType: 'symbolic',
      interpretation:
          '뱀 꿈은 변화와 재생의 강력한 상징입니다. 당신의 무의식은 삶의 전환점에 서 있으며, 낡은 습관이나 관계를 벗어던지고 새로운 시작을 준비하라는 메시지를 보내고 있습니다. 전통 해몽에서 뱀은 재물운과 지혜를 상징하며, 특히 큰 뱀일수록 큰 행운을 의미합니다.',
      todayGuidance:
          '오늘은 변화를 두려워하지 마세요. 불필요한 것을 정리하고 새로운 기회에 마음을 열어보세요. 특히 오후에 중요한 결정을 내리기 좋으며, 직감을 따르면 좋은 결과가 있을 것입니다.',
      psychologicalState:
          '현재 당신은 성장과 변화의 에너지가 충만한 상태입니다. 융 심리학에서 뱀은 자아 통합과 치유의 상징으로, 내면의 지혜가 깨어나고 있음을 의미합니다.',
      emotionalBalance: 7,
      significanceLevel: 9,
      actionAdvice: [
        '오래된 물건이나 관계를 정리하는 시간을 가져보세요. 물리적 정리가 심리적 정화로 이어집니다.',
        '새로운 것을 배우거나 시작하기에 좋은 시기입니다. 관심 있던 분야에 첫 발을 내딛어 보세요.',
        '직감을 믿으세요. 오늘 떠오르는 아이디어나 느낌은 무의식의 중요한 메시지일 수 있습니다.',
      ],
      affirmations: [
        '나는 변화를 통해 더 나은 나로 성장한다.',
        '나의 내면에는 무한한 지혜와 힘이 있다.',
        '나는 과거를 내려놓고 새로운 시작을 환영한다.',
      ],
      relatedSymbols: ['변화', '재생', '지혜', '치유', '재물'],
    ),

    'pig': DreamInterpretationData(
      dreamId: 'pig',
      dreamType: 'wish-fulfillment',
      interpretation:
          '돼지 꿈은 전통적으로 최고의 길몽 중 하나입니다. 풍요와 재물, 복을 상징하며 가까운 시일 내에 경제적 행운이 찾아올 수 있음을 암시합니다. 특히 살찐 돼지나 새끼 돼지 여러 마리가 나오면 더욱 큰 행운을 의미합니다.',
      todayGuidance:
          '오늘은 재물과 관련된 좋은 소식이 있을 수 있습니다. 복권 구매나 투자 결정에 신중하되 긍정적인 마음으로 임하세요. 감사하는 마음을 가지면 더 큰 복이 따릅니다.',
      psychologicalState:
          '당신의 무의식은 풍요로움과 안정에 대한 강한 욕구를 표현하고 있습니다. 이는 현재 물질적 안정을 추구하거나, 삶의 풍요로움을 갈망하는 심리 상태를 반영합니다.',
      emotionalBalance: 9,
      significanceLevel: 9,
      actionAdvice: [
        '가계부를 정리하고 재정 상태를 점검해보세요. 숨겨진 자산이나 기회를 발견할 수 있습니다.',
        '주변 사람들과 음식을 나누며 감사의 마음을 표현하세요. 나눔이 더 큰 복을 부릅니다.',
        '오늘 들어오는 제안이나 기회에 열린 마음으로 귀 기울여보세요.',
      ],
      affirmations: [
        '나에게는 풍요로운 에너지가 흐르고 있다.',
        '나는 받을 자격이 있으며, 넉넉함을 즐긴다.',
        '감사와 나눔으로 더 큰 복이 돌아온다.',
      ],
      relatedSymbols: ['풍요', '재물', '복', '다산', '행운'],
    ),

    'dog': DreamInterpretationData(
      dreamId: 'dog',
      dreamType: 'processing',
      interpretation:
          '강아지 꿈은 충성스러운 관계와 우정을 상징합니다. 당신 주변에 진심으로 당신을 아끼는 사람이 있거나, 곧 믿을 수 있는 조력자가 나타날 것을 암시합니다. 강아지가 당신에게 다가오면 좋은 소식이, 짖거나 물면 주변 관계를 점검하라는 신호입니다.',
      todayGuidance:
          '오늘은 친구나 동료와의 관계에 감사하는 시간을 가져보세요. 오래된 친구에게 연락하거나, 도움을 준 사람에게 고마움을 표현하면 관계가 더욱 깊어집니다.',
      psychologicalState:
          '당신은 현재 소속감과 유대감에 대한 욕구가 강한 상태입니다. 누군가에게 충성하고 싶거나, 반대로 충성스러운 지지자를 원하는 마음이 꿈에 반영되었습니다.',
      emotionalBalance: 8,
      significanceLevel: 7,
      actionAdvice: [
        '오래 연락하지 못한 친구에게 안부 메시지를 보내보세요. 뜻밖의 좋은 소식을 들을 수 있습니다.',
        '반려동물이 있다면 오늘 특별한 시간을 함께 보내세요. 없다면 동물 관련 봉사활동을 고려해보세요.',
        '직장이나 모임에서 신뢰를 쌓을 수 있는 행동을 실천하세요.',
      ],
      affirmations: [
        '나는 사랑받고 지지받을 자격이 있다.',
        '내 주변에는 나를 진심으로 아끼는 사람들이 있다.',
        '나는 신뢰할 수 있는 사람이며, 좋은 관계를 만들어간다.',
      ],
      relatedSymbols: ['충성', '우정', '신뢰', '보호', '동반자'],
    ),

    'cat': DreamInterpretationData(
      dreamId: 'cat',
      dreamType: 'symbolic',
      interpretation:
          '고양이 꿈은 직관력과 독립성을 상징합니다. 당신의 내면에서 자유롭고 독립적인 에너지가 깨어나고 있습니다. 전통 해몽에서 고양이는 여성성과 신비로움을 나타내며, 흰 고양이는 행운을, 검은 고양이는 숨겨진 진실의 발견을 의미합니다.',
      todayGuidance:
          '오늘은 타인의 의견보다 자신의 직감을 믿으세요. 혼자만의 시간을 가지며 내면의 목소리에 귀 기울여보세요. 직관적으로 느껴지는 것을 따르면 좋은 결과가 있습니다.',
      psychologicalState:
          '융 심리학에서 고양이는 아니마(Anima)의 상징으로, 당신 내면의 여성적 에너지와 직관력이 활성화되고 있습니다. 이성적 사고와 감성적 직관의 균형을 찾는 시기입니다.',
      emotionalBalance: 7,
      significanceLevel: 7,
      actionAdvice: [
        '오늘은 혼자만의 시간을 확보하세요. 산책이나 명상으로 내면의 목소리를 들어보세요.',
        '직관적으로 끌리는 일이 있다면 망설이지 말고 시도해보세요.',
        '주변의 미묘한 신호들에 주의를 기울이세요. 중요한 정보가 숨어있을 수 있습니다.',
      ],
      affirmations: [
        '나는 나만의 길을 당당하게 걸어간다.',
        '내 직관은 나를 올바른 방향으로 이끈다.',
        '나는 독립적이면서도 깊은 연결을 만들 수 있다.',
      ],
      relatedSymbols: ['직관', '독립', '신비', '여성성', '자유'],
    ),

    'tiger': DreamInterpretationData(
      dreamId: 'tiger',
      dreamType: 'prophetic',
      interpretation:
          '호랑이 꿈은 한국 전통에서 최고의 길몽입니다. 권력, 용기, 위엄을 상징하며 큰 성공과 출세를 암시합니다. 호랑이가 당신을 해치지 않으면 강력한 조력자가 나타나거나 승진, 합격 등 좋은 소식이 있을 것입니다. 태몽으로도 매우 좋은 꿈입니다.',
      todayGuidance:
          '오늘은 당당하고 자신감 있게 행동하세요. 중요한 미팅이나 발표가 있다면 적극적으로 임하세요. 두려움 없이 도전하면 예상보다 큰 성과를 얻을 수 있습니다.',
      psychologicalState:
          '당신의 내면에서 강력한 힘과 자신감이 솟아나고 있습니다. 그동안 억눌렀던 야망과 리더십 에너지가 표출되려 하며, 이를 건강하게 발휘할 때입니다.',
      emotionalBalance: 9,
      significanceLevel: 10,
      actionAdvice: [
        '오래 미뤄왔던 중요한 결정을 오늘 내려보세요. 지금이 적기입니다.',
        '리더십을 발휘할 기회가 있다면 주저하지 마세요. 당신에게 그 능력이 있습니다.',
        '두려움에 맞서세요. 오늘 도전하는 일은 성공 가능성이 높습니다.',
      ],
      affirmations: [
        '나는 어떤 도전도 극복할 힘이 있다.',
        '나의 당당함이 주변에 긍정적 영향을 준다.',
        '나는 성공을 향해 담대하게 나아간다.',
      ],
      relatedSymbols: ['용기', '권력', '위엄', '성공', '수호'],
    ),

    'dragon': DreamInterpretationData(
      dreamId: 'dragon',
      dreamType: 'prophetic',
      interpretation:
          '용 꿈은 동양 문화권에서 최고의 길몽으로 꼽힙니다. 대성공, 출세, 권력, 명예를 상징하며, 인생에서 큰 전환점이 다가오고 있음을 알립니다. 용이 하늘로 오르면 목표 달성을, 용이 물에서 나오면 새로운 기회의 시작을 의미합니다.',
      todayGuidance:
          '오늘은 큰 꿈을 품으세요. 평소보다 높은 목표를 세우고 그를 향해 첫 걸음을 내딛으세요. 불가능해 보이는 일도 시도할 가치가 있습니다. 귀인이 나타날 수 있으니 새로운 만남에 열린 자세를 가지세요.',
      psychologicalState:
          '당신의 무의식은 잠재된 큰 가능성과 야망을 드러내고 있습니다. 융의 원형 이론에서 용은 자아 초월과 완전한 자기실현을 상징하며, 당신이 새로운 단계로 도약할 준비가 되었음을 나타냅니다.',
      emotionalBalance: 10,
      significanceLevel: 10,
      actionAdvice: [
        '장기적인 목표와 비전을 글로 적어보세요. 명확한 목표가 실현의 첫 단계입니다.',
        '멘토나 조언자를 찾아보세요. 귀인의 도움으로 더 빨리 성장할 수 있습니다.',
        '자신의 능력을 과소평가하지 마세요. 당신에게는 큰 일을 해낼 잠재력이 있습니다.',
      ],
      affirmations: [
        '나는 무한한 가능성을 가진 존재이다.',
        '큰 꿈이 나를 큰 사람으로 만든다.',
        '나는 성공과 풍요를 향해 힘차게 비상한다.',
      ],
      relatedSymbols: ['성공', '권력', '비상', '행운', '귀인'],
    ),

    'fish': DreamInterpretationData(
      dreamId: 'fish',
      dreamType: 'wish-fulfillment',
      interpretation:
          '물고기 꿈은 재물운과 풍요를 상징하는 대표적인 길몽입니다. 특히 잉어나 큰 물고기를 잡는 꿈은 뜻밖의 횡재나 승진을 암시합니다. 물고기가 많이 보이면 여러 방면에서 좋은 기회가 올 것이며, 맑은 물에서 헤엄치는 물고기는 사업 번창을 의미합니다.',
      todayGuidance:
          '오늘은 재정적 기회에 눈을 크게 뜨세요. 투자, 사업, 취업 관련 좋은 소식이 있을 수 있습니다. 물가나 수족관에 가보면 좋은 영감을 받을 수 있습니다.',
      psychologicalState:
          '물고기는 무의식의 깊은 곳에서 떠오르는 통찰과 풍요로움을 상징합니다. 당신의 내면에서 창의적 아이디어와 직관이 활성화되고 있으며, 이를 현실에서 풍요로 연결할 준비가 되어 있습니다.',
      emotionalBalance: 8,
      significanceLevel: 8,
      actionAdvice: [
        '새로운 수입원이나 부업 기회를 탐색해보세요. 숨겨진 가능성이 있습니다.',
        '창의적인 아이디어가 떠오르면 메모해두세요. 나중에 큰 도움이 됩니다.',
        '오늘 받는 조언이나 정보에 주의를 기울이세요. 재정적 힌트가 숨어있을 수 있습니다.',
      ],
      affirmations: [
        '풍요로운 기회가 나에게 쉽게 흘러온다.',
        '나는 재정적 풍요를 누릴 자격이 있다.',
        '내 직관이 나를 번영으로 이끈다.',
      ],
      relatedSymbols: ['재물', '풍요', '무의식', '기회', '번영'],
    ),

    'bird': DreamInterpretationData(
      dreamId: 'bird',
      dreamType: 'prophetic',
      interpretation:
          '새 꿈은 자유와 희망, 좋은 소식의 도래를 상징합니다. 새가 날아오르면 목표 달성과 성공을, 새가 노래하면 기쁜 소식을 의미합니다. 집 안으로 새가 들어오면 결혼이나 임신 등 경사가 있을 수 있고, 학이나 봉황 같은 신령한 새는 더욱 큰 행운을 뜻합니다.',
      todayGuidance:
          '오늘은 좋은 소식을 기대해도 좋습니다. 연락을 기다리고 있었다면 반가운 소식이 올 수 있습니다. 창문을 열어 신선한 공기를 마시고, 새처럼 자유로운 마음으로 하루를 시작하세요.',
      psychologicalState:
          '새는 영혼과 자유로운 정신을 상징합니다. 당신의 마음이 구속에서 벗어나 자유롭게 비상하고 싶어하며, 새로운 관점과 희망을 갈망하고 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 8,
      actionAdvice: [
        '하늘을 올려다보며 잠시 명상하세요. 높은 관점에서 상황을 바라볼 수 있습니다.',
        '속박감을 주는 것들을 하나씩 정리해보세요. 마음의 자유가 필요합니다.',
        '좋은 소식을 전하는 역할을 해보세요. 긍정의 에너지가 배가 됩니다.',
      ],
      affirmations: [
        '나는 자유롭게 꿈을 향해 날아오른다.',
        '좋은 소식과 기회가 나를 찾아온다.',
        '내 영혼은 무한히 자유롭고 가볍다.',
      ],
      relatedSymbols: ['자유', '희망', '소식', '영혼', '비상'],
    ),

    'horse': DreamInterpretationData(
      dreamId: 'horse',
      dreamType: 'prophetic',
      interpretation:
          '말 꿈은 성공과 출세, 빠른 발전을 상징합니다. 말을 타고 달리면 승진이나 합격 등 목표 달성이 가까워지고, 백마는 특히 큰 행운을 의미합니다. 말이 힘차게 달리면 사업이나 프로젝트가 순탄하게 진행될 것이며, 여러 마리의 말은 재물운 상승을 뜻합니다.',
      todayGuidance:
          '오늘은 속도감 있게 일을 추진하세요. 망설이기보다 행동으로 옮기면 좋은 결과가 있습니다. 중요한 면접, 시험, 사업 미팅이 있다면 자신감을 가지고 임하세요.',
      psychologicalState:
          '말은 본능적 에너지와 추진력을 상징합니다. 당신 내면에서 강력한 동력이 솟아나고 있으며, 목표를 향해 질주하고 싶은 욕구가 강해지고 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 9,
      actionAdvice: [
        '미뤄둔 프로젝트나 계획을 오늘 시작하세요. 추진력이 좋은 날입니다.',
        '운동으로 에너지를 발산하세요. 몸을 움직이면 정신도 활력을 얻습니다.',
        '목표를 향해 당당하게 나아가세요. 주저하지 않으면 반드시 도달합니다.',
      ],
      affirmations: [
        '나는 목표를 향해 힘차게 달려간다.',
        '성공은 이미 내게 다가오고 있다.',
        '나의 열정과 추진력은 멈출 수 없다.',
      ],
      relatedSymbols: ['성공', '속도', '추진력', '출세', '열정'],
    ),

    'cow': DreamInterpretationData(
      dreamId: 'cow',
      dreamType: 'wish-fulfillment',
      interpretation:
          '소 꿈은 근면과 성실함의 결실, 안정적인 재물 축적을 상징합니다. 살찐 소는 풍요와 번영을, 소가 밭을 가는 모습은 노력의 결실을 의미합니다. 젖소가 우유를 주면 수입 증가나 사업 성공을, 많은 소떼는 재산 증식을 암시합니다.',
      todayGuidance:
          '오늘은 성실하게 맡은 일에 집중하세요. 화려한 성과보다 묵묵한 노력이 더 큰 보상으로 돌아옵니다. 저축이나 투자 계획을 세우기에도 좋은 날입니다.',
      psychologicalState:
          '소는 인내와 끈기, 풍요의 원형을 나타냅니다. 당신의 무의식은 안정적이고 지속적인 성장을 추구하며, 노력에 대한 정당한 보상을 기대하고 있습니다.',
      emotionalBalance: 8,
      significanceLevel: 8,
      actionAdvice: [
        '재정 계획을 점검하고 저축 목표를 세워보세요. 안정적인 미래를 준비할 때입니다.',
        '급하게 서두르지 말고 꾸준히 진행하세요. 느리지만 확실한 성과가 기다립니다.',
        '건강한 식사와 충분한 휴식으로 체력을 보충하세요.',
      ],
      affirmations: [
        '나의 꾸준한 노력은 반드시 결실을 맺는다.',
        '나는 풍요롭고 안정된 삶을 만들어간다.',
        '인내와 성실함이 나의 가장 큰 자산이다.',
      ],
      relatedSymbols: ['풍요', '근면', '안정', '결실', '인내'],
    ),

    'spider': DreamInterpretationData(
      dreamId: 'spider',
      dreamType: 'symbolic',
      interpretation:
          '거미 꿈은 창의성과 운명의 엮임을 상징합니다. 거미가 거미줄을 치는 모습은 당신이 삶에서 무언가를 창조하고 연결하고 있음을 의미합니다. 전통 해몽에서 거미는 재물을 모으는 상징으로, 특히 집 안의 거미는 좋은 징조입니다.',
      todayGuidance:
          '오늘은 창의적인 작업에 집중하기 좋습니다. 아이디어들을 연결하고 계획을 세워보세요. 인맥을 확장하거나 네트워킹 활동도 효과적입니다.',
      psychologicalState:
          '거미는 창조와 파괴, 인내와 계획성의 상징입니다. 당신의 무의식은 현재 삶의 여러 요소들을 연결하고 전체적인 그림을 완성하려 하고 있습니다.',
      emotionalBalance: 6,
      significanceLevel: 7,
      actionAdvice: [
        '복잡하게 얽힌 문제가 있다면 전체 그림을 먼저 파악하세요.',
        '인맥 관리에 신경 쓰세요. 사람들 사이의 연결이 기회를 만듭니다.',
        '창의적인 프로젝트를 시작하거나 진행하기에 좋은 시기입니다.',
      ],
      affirmations: [
        '나는 내 운명의 그물을 스스로 짠다.',
        '모든 연결은 의미가 있고, 나는 그 패턴을 이해한다.',
        '인내심을 가지고 나만의 작품을 완성해간다.',
      ],
      relatedSymbols: ['창의성', '연결', '운명', '인내', '계획'],
    ),

    'elephant': DreamInterpretationData(
      dreamId: 'elephant',
      dreamType: 'prophetic',
      interpretation:
          '코끼리 꿈은 힘과 지혜, 기억력, 큰 행운을 상징합니다. 코끼리는 장애물을 제거하는 힘을 가졌으며, 인도에서는 가네샤 신과 연결되어 성공과 번영을 불러온다고 믿습니다. 코끼리를 타면 권력이나 지위 상승을, 코끼리 무리는 가족의 화목과 번영을 의미합니다.',
      todayGuidance:
          '오늘은 큰 결단을 내리기 좋은 날입니다. 장애물이 있어도 포기하지 마세요. 당신에게는 그것을 넘어설 힘이 있습니다. 연장자나 경험 많은 분의 조언을 구하면 도움이 됩니다.',
      psychologicalState:
          '코끼리는 집단 무의식에서 지혜와 힘, 기억의 상징입니다. 당신은 현재 삶에서 중요한 것을 기억하고 지키려는 의지가 강하며, 내면의 힘이 충만한 상태입니다.',
      emotionalBalance: 8,
      significanceLevel: 9,
      actionAdvice: [
        '장기적인 목표를 떠올리고 흔들리지 마세요. 끈기가 성공을 만듭니다.',
        '가족이나 오래된 친구와 시간을 보내세요. 유대감이 힘이 됩니다.',
        '과거의 경험과 지혜를 현재 상황에 적용해보세요.',
      ],
      affirmations: [
        '나에게는 모든 장애를 넘어설 힘이 있다.',
        '나의 지혜가 나를 올바른 길로 인도한다.',
        '나는 강하고, 지혜롭고, 기억 속의 교훈을 소중히 여긴다.',
      ],
      relatedSymbols: ['힘', '지혜', '기억', '번영', '장애제거'],
    ),

    // ==================== 재물 (10개) ====================

    'money': DreamInterpretationData(
      dreamId: 'money',
      dreamType: 'wish-fulfillment',
      interpretation:
          '돈을 줍는 꿈은 예상치 못한 행운과 횡재를 암시하는 대표적인 길몽입니다. 길에서 돈을 줍는다면 뜻밖의 소득이, 많은 돈을 줍는다면 큰 재물이 들어올 수 있습니다. 다만 돈을 잃는 꿈은 역몽으로 오히려 재물이 들어올 수 있다는 의미입니다.',
      todayGuidance:
          '오늘은 재정적으로 좋은 기운이 흐릅니다. 작은 투자 기회나 뜻밖의 수입에 주목하세요. 단, 탐욕을 부리지 말고 감사하는 마음으로 받아들이면 복이 오래갑니다.',
      psychologicalState:
          '돈에 대한 꿈은 자기 가치감과 안정에 대한 욕구를 반영합니다. 당신은 현재 경제적 안정이나 자신의 가치를 인정받고 싶은 심리 상태에 있습니다.',
      emotionalBalance: 8,
      significanceLevel: 9,
      actionAdvice: [
        '가계부를 정리하고 재정 상태를 점검하세요. 새로운 기회가 보일 수 있습니다.',
        '주변의 도움 요청에 열린 마음으로 응하세요. 베풂이 더 큰 복으로 돌아옵니다.',
        '복권이나 소액 투자를 고려해볼 수 있지만, 과욕은 금물입니다.',
      ],
      affirmations: [
        '나에게는 풍요가 자연스럽게 흘러온다.',
        '나는 재정적 행운을 받을 자격이 있다.',
        '감사하는 마음이 더 큰 복을 부른다.',
      ],
      relatedSymbols: ['횡재', '행운', '풍요', '가치', '축복'],
    ),

    'lottery': DreamInterpretationData(
      dreamId: 'lottery',
      dreamType: 'wish-fulfillment',
      interpretation:
          '복권 당첨 꿈은 인생의 전환점과 큰 행운을 암시합니다. 실제 복권 당첨보다는 예상치 못한 좋은 기회나 소원 성취를 상징하는 경우가 많습니다. 꿈에서 느낀 기쁨의 크기가 현실에서 받을 축복의 크기를 나타냅니다.',
      todayGuidance:
          '오늘은 평소 기대하지 않던 곳에서 좋은 소식이 올 수 있습니다. 열린 마음으로 하루를 보내세요. 운에만 의존하지 말고, 기회가 왔을 때 잡을 준비를 하세요.',
      psychologicalState:
          '복권 꿈은 삶에서 극적인 변화를 원하는 마음을 반영합니다. 현재 상황에서 벗어나고 싶거나, 노력 없이 보상받고 싶은 무의식적 욕구가 있을 수 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 8,
      actionAdvice: [
        '큰 행운을 기다리면서도 작은 기회들을 놓치지 마세요.',
        '자신의 재능과 능력을 개발하는 데 투자하세요. 진정한 행운은 준비된 자에게 옵니다.',
        '감사 일기를 써보세요. 이미 가진 축복을 인식하면 더 큰 복이 옵니다.',
      ],
      affirmations: [
        '내 인생에는 놀라운 행운이 기다리고 있다.',
        '나는 좋은 기회를 알아보고 잡을 준비가 되어있다.',
        '풍요는 예상치 못한 곳에서 나를 찾아온다.',
      ],
      relatedSymbols: ['행운', '전환점', '희망', '풍요', '기대'],
    ),

    'gold': DreamInterpretationData(
      dreamId: 'gold',
      dreamType: 'wish-fulfillment',
      interpretation:
          '금 꿈은 최상의 가치와 영구적인 성공을 상징하는 매우 좋은 길몽입니다. 금을 발견하면 숨겨진 재능이나 기회를, 금을 받으면 인정과 보상을, 금을 착용하면 명예와 지위 상승을 의미합니다. 금덩어리가 클수록 행운의 크기도 큽니다.',
      todayGuidance:
          '오늘은 당신의 진정한 가치가 빛날 수 있는 날입니다. 자신을 과소평가하지 말고, 당당하게 능력을 발휘하세요. 귀중한 기회나 인연이 다가올 수 있습니다.',
      psychologicalState:
          '금은 완전함과 불변의 가치를 상징합니다. 당신의 무의식은 자신의 진정한 가치를 인정받고 싶어하며, 영속적인 성공과 안정을 갈망하고 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 9,
      actionAdvice: [
        '자신의 핵심 역량과 가치를 글로 정리해보세요. 자기 인식이 성공의 첫 걸음입니다.',
        '장기적으로 가치가 있는 것에 투자하세요. 시간, 관계, 기술 모두 포함됩니다.',
        '오늘 만나는 사람들에게 진심을 다하세요. 귀인이 될 수 있습니다.',
      ],
      affirmations: [
        '나는 금처럼 변하지 않는 가치를 지닌 존재이다.',
        '나의 진정한 가치는 세상에 인정받는다.',
        '풍요와 성공이 나의 삶에 자연스럽게 깃든다.',
      ],
      relatedSymbols: ['가치', '성공', '불변', '명예', '귀중함'],
    ),

    'treasure': DreamInterpretationData(
      dreamId: 'treasure',
      dreamType: 'symbolic',
      interpretation:
          '보물 발견 꿈은 숨겨진 가능성과 내면의 보물을 발견할 때가 되었음을 알립니다. 땅을 파서 보물을 찾으면 노력의 결실을, 우연히 발견하면 뜻밖의 행운을, 보물 지도를 보면 목표로 가는 길이 보일 것을 의미합니다.',
      todayGuidance:
          '오늘은 숨겨진 기회나 재능을 발견할 수 있는 날입니다. 평소 지나치던 것들에 주의를 기울이세요. 자신의 내면을 탐색하면 잊고 있던 꿈이나 능력을 재발견할 수 있습니다.',
      psychologicalState:
          '보물은 무의식에 묻혀있던 잠재력이나 억압된 욕구의 상징입니다. 당신의 내면에는 아직 발굴되지 않은 소중한 자원이 있으며, 이를 찾아 나설 때가 되었습니다.',
      emotionalBalance: 8,
      significanceLevel: 8,
      actionAdvice: [
        '과거에 포기했던 꿈이나 취미를 다시 생각해보세요. 지금은 상황이 다를 수 있습니다.',
        '오래된 물건이나 서류를 정리하다 보면 뜻밖의 발견이 있을 수 있습니다.',
        '자기 성찰의 시간을 가지세요. 명상이나 일기 쓰기가 도움됩니다.',
      ],
      affirmations: [
        '나의 내면에는 무한한 보물이 숨겨져 있다.',
        '나는 매일 새로운 가능성을 발견한다.',
        '내가 찾는 것은 이미 내 안에 있다.',
      ],
      relatedSymbols: ['발견', '잠재력', '숨겨진 가치', '모험', '성취'],
    ),

    'poop': DreamInterpretationData(
      dreamId: 'poop',
      dreamType: 'wish-fulfillment',
      interpretation:
          '똥 꿈은 역설적이게도 동양에서 최고의 재물 길몽입니다. 똥을 밟으면 횡재가, 똥더미를 보면 큰 재물이, 똥을 만지거나 먹는 꿈도 역몽으로 부자가 될 징조입니다. 불쾌할수록 오히려 재물운이 강합니다.',
      todayGuidance:
          '오늘은 예상치 못한 곳에서 재정적 기회가 올 수 있습니다. 불쾌하거나 귀찮아 보이는 일에도 숨겨진 기회가 있을 수 있으니 열린 마음을 가지세요.',
      psychologicalState:
          '프로이트 이론에서 배설물은 창조성과 물질적 가치의 상징입니다. 당신의 무의식은 현재 창조적 에너지가 넘치며, 이를 물질적 성공으로 전환할 준비가 되어있습니다.',
      emotionalBalance: 9,
      significanceLevel: 9,
      actionAdvice: [
        '오늘 들어오는 모든 기회에 감사하세요. 작아 보여도 큰 복이 될 수 있습니다.',
        '몸의 건강에도 신경 쓰세요. 소화기 건강이 전체 에너지에 영향을 줍니다.',
        '정리 정돈을 하면 막혀있던 에너지가 흐르기 시작합니다.',
      ],
      affirmations: [
        '나에게 불편해 보이는 것도 축복이 될 수 있다.',
        '재물과 풍요가 예상치 못한 방식으로 찾아온다.',
        '나는 모든 경험에서 가치를 발견한다.',
      ],
      relatedSymbols: ['횡재', '재물', '역몽', '창조', '전환'],
    ),

    'wallet': DreamInterpretationData(
      dreamId: 'wallet',
      dreamType: 'processing',
      interpretation:
          '지갑 꿈은 재정 상태와 자아 정체성을 반영합니다. 지갑이 두툼하면 재물운 상승을, 지갑을 잃어버리면 역몽으로 오히려 재물이 들어올 수 있습니다. 새 지갑을 받으면 새로운 수입원이, 빈 지갑은 곧 채워질 기회가 올 것을 암시합니다.',
      todayGuidance:
          '오늘은 재정 관리에 관심을 기울이세요. 새로운 저축 계획을 세우거나, 지출 패턴을 점검하기 좋은 날입니다. 신분증이나 중요 서류도 확인해두세요.',
      psychologicalState:
          '지갑은 자기 가치와 정체성의 상징입니다. 당신은 현재 자신의 가치를 어떻게 관리하고 보호할지 고민하고 있으며, 재정적 안정에 대한 욕구가 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 7,
      actionAdvice: [
        '지갑과 가방을 정리하세요. 불필요한 카드나 영수증을 정리하면 에너지가 좋아집니다.',
        '예산을 세우고 저축 목표를 설정하세요. 계획이 풍요를 부릅니다.',
        '자신의 가치를 인정하고, 정당한 대가를 요구하는 연습을 하세요.',
      ],
      affirmations: [
        '나의 지갑은 항상 풍요로움으로 가득 찬다.',
        '나는 돈을 현명하게 관리하고 늘려간다.',
        '나의 가치는 측정할 수 없이 크다.',
      ],
      relatedSymbols: ['재정', '정체성', '관리', '안정', '가치'],
    ),

    'gift': DreamInterpretationData(
      dreamId: 'gift',
      dreamType: 'wish-fulfillment',
      interpretation:
          '선물 받는 꿈은 사랑과 인정, 예상치 못한 축복을 상징합니다. 누구에게서 받느냐에 따라 의미가 달라지는데, 낯선 사람은 새로운 기회를, 가족은 유산이나 지원을, 연인은 관계 발전을 암시합니다. 선물이 클수록 복도 큽니다.',
      todayGuidance:
          '오늘은 열린 마음으로 다른 사람의 호의를 받아들이세요. 거절하지 말고 감사히 받으면 더 큰 복이 따릅니다. 당신도 누군가에게 작은 선물이나 친절을 베풀어보세요.',
      psychologicalState:
          '선물은 사랑과 인정의 욕구를 반영합니다. 당신의 무의식은 누군가로부터 사랑받고 인정받고 싶어하며, 동시에 베풀고 싶은 마음도 가지고 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 8,
      actionAdvice: [
        '오늘 받는 제안이나 도움을 거절하지 마세요. 그 안에 큰 기회가 있을 수 있습니다.',
        '감사 편지나 메시지를 보내세요. 감사의 표현이 더 큰 축복을 부릅니다.',
        '자신에게도 작은 선물을 하세요. 자기 사랑이 중요합니다.',
      ],
      affirmations: [
        '나는 우주로부터 풍성한 선물을 받는다.',
        '받는 것과 주는 것 모두 축복이다.',
        '나는 사랑받을 자격이 있다.',
      ],
      relatedSymbols: ['축복', '사랑', '인정', '기회', '호의'],
    ),

    'coin': DreamInterpretationData(
      dreamId: 'coin',
      dreamType: 'processing',
      interpretation:
          '동전 꿈은 작지만 확실한 행운과 축적의 힘을 상징합니다. 동전을 줍는 꿈은 작은 기회들이 모여 큰 성공이 될 것을, 동전 더미는 꾸준한 저축의 결실을, 오래된 동전은 과거의 노력이 보상받을 것을 의미합니다.',
      todayGuidance:
          '오늘은 작은 것에도 감사하세요. 큰 행운만 바라지 말고 일상의 소소한 축복들을 인식하면 더 큰 복이 따릅니다. 저축을 시작하거나 절약 습관을 들이기 좋은 날입니다.',
      psychologicalState:
          '동전은 가치의 기본 단위로, 자기 가치에 대한 인식을 반영합니다. 당신은 현재 작은 성취들의 가치를 이해하고, 꾸준함의 힘을 믿고 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 6,
      actionAdvice: [
        '저금통을 준비하고 매일 작은 금액이라도 저축하세요. 습관이 부를 만듭니다.',
        '작은 성취도 기록하고 축하하세요. 동기 부여가 됩니다.',
        '발밑을 잘 살펴보세요. 실제로 동전을 발견하면 행운의 징조입니다.',
      ],
      affirmations: [
        '작은 것들이 모여 큰 성공을 이룬다.',
        '나는 매일 조금씩 더 풍요로워진다.',
        '모든 시작은 작은 한 걸음부터이다.',
      ],
      relatedSymbols: ['축적', '꾸준함', '작은 행운', '저축', '가치'],
    ),

    'rice': DreamInterpretationData(
      dreamId: 'rice',
      dreamType: 'wish-fulfillment',
      interpretation:
          '쌀이나 곡식 꿈은 풍요와 건강, 가정의 평화를 상징하는 길몽입니다. 쌀이 가득 차 있으면 재물이 늘어날 것을, 쌀을 받으면 도움이 올 것을, 밥을 짓는 꿈은 가정의 화목과 건강을 의미합니다. 곡식이 익어가는 모습은 노력의 결실을 암시합니다.',
      todayGuidance:
          '오늘은 가정과 건강에 집중하세요. 가족과 함께 식사하거나, 건강한 음식을 챙겨 먹으면 좋습니다. 기본에 충실할 때 더 큰 복이 따릅니다.',
      psychologicalState:
          '쌀과 곡식은 생존과 안정의 기본 욕구를 상징합니다. 당신의 무의식은 안정적인 기반과 풍족한 삶을 원하며, 현재 기본적인 것들의 소중함을 느끼고 있습니다.',
      emotionalBalance: 8,
      significanceLevel: 8,
      actionAdvice: [
        '오늘 식사는 정성껏 준비하거나, 가족과 함께하세요. 음식이 복을 부릅니다.',
        '식료품 저장고를 정리하고 채워두세요. 풍요의 에너지가 흐릅니다.',
        '건강 검진이나 식습관 개선을 계획해보세요.',
      ],
      affirmations: [
        '나의 삶은 풍요로움으로 가득 차 있다.',
        '기본에 충실할 때 모든 것이 풍성해진다.',
        '나와 내 가족은 건강하고 행복하다.',
      ],
      relatedSymbols: ['풍요', '건강', '가정', '기본', '결실'],
    ),

    'fruit': DreamInterpretationData(
      dreamId: 'fruit',
      dreamType: 'wish-fulfillment',
      interpretation:
          '과일 꿈은 노력의 결실과 달콤한 보상을 상징합니다. 잘 익은 과일은 성공이 가까워짐을, 과일을 따는 꿈은 목표 달성을, 과일을 먹으면 행복한 결과를 누릴 것을 의미합니다. 포도나 석류처럼 씨가 많은 과일은 다산과 풍요를 상징합니다.',
      todayGuidance:
          '오늘은 그동안 노력한 일의 결과를 기대해도 좋습니다. 좋은 소식이나 보상이 있을 수 있습니다. 달콤한 과일처럼 인생의 좋은 순간을 온전히 즐기세요.',
      psychologicalState:
          '과일은 성취와 풍요, 자연스러운 보상의 상징입니다. 당신의 무의식은 노력에 대한 정당한 보상을 기대하고 있으며, 삶의 달콤함을 누릴 준비가 되어있습니다.',
      emotionalBalance: 9,
      significanceLevel: 8,
      actionAdvice: [
        '진행 중인 프로젝트의 마무리에 집중하세요. 결실을 거둘 때입니다.',
        '건강한 과일을 먹으며 자신에게 보상을 주세요.',
        '성취를 기록하고 축하하세요. 자기 인정이 더 큰 성공을 부릅니다.',
      ],
      affirmations: [
        '나의 노력은 달콤한 열매를 맺는다.',
        '나는 인생의 풍요로움을 마음껏 즐긴다.',
        '성공과 행복이 자연스럽게 나를 찾아온다.',
      ],
      relatedSymbols: ['결실', '보상', '풍요', '달콤함', '성취'],
    ),

    // ==================== 행동 (12개) ====================

    'flying': DreamInterpretationData(
      dreamId: 'flying',
      dreamType: 'wish-fulfillment',
      interpretation:
          '하늘을 나는 꿈은 자유와 해방, 목표 달성을 상징하는 대표적인 길몽입니다. 높이 날수록 야망이 크고, 자유롭게 날수록 현재 삶에 대한 만족도가 높습니다. 장애물 없이 날면 목표 달성이 순조로울 것을 의미하며, 다른 사람들 위로 날면 승진이나 성공을 암시합니다.',
      todayGuidance:
          '오늘은 높은 목표를 향해 도전하세요. 불가능해 보이는 일도 시도할 가치가 있습니다. 자유로운 발상과 창의적 사고가 좋은 결과를 가져옵니다. 답답했던 상황에서 해방될 기회가 올 수 있습니다.',
      psychologicalState:
          '하늘을 나는 꿈은 자아 초월과 성장에 대한 강한 욕구를 반영합니다. 현재의 제약에서 벗어나고 싶고, 더 높은 관점에서 삶을 바라보고 싶은 마음이 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 9,
      actionAdvice: [
        '장기 목표를 점검하고, 한 단계 높은 수준으로 상향 조정해보세요.',
        '답답하게 느껴지는 규칙이나 제약이 있다면 합리적인 방법으로 변화를 시도하세요.',
        '창의적인 아이디어가 떠오르면 바로 메모하고 실행 계획을 세우세요.',
      ],
      affirmations: [
        '나는 한계를 넘어 자유롭게 비상한다.',
        '내 잠재력에는 끝이 없다.',
        '모든 장애물 위로 날아오른다.',
      ],
      relatedSymbols: ['자유', '해방', '성취', '초월', '야망'],
    ),

    'falling': DreamInterpretationData(
      dreamId: 'falling',
      dreamType: 'anxiety',
      interpretation:
          '떨어지는 꿈은 통제력 상실에 대한 불안을 반영하지만, 역설적으로 좋은 신호일 수 있습니다. 떨어지다 착지하면 위기를 극복할 것을, 떨어지다 날기 시작하면 전환의 기회를 의미합니다. 전통 해몽에서는 높은 곳에서 떨어지는 꿈이 오히려 신분 상승을 암시하기도 합니다.',
      todayGuidance:
          '오늘은 불안한 마음이 들더라도 침착함을 유지하세요. 통제할 수 없는 것에 대한 걱정보다 통제 가능한 것에 집중하세요. 변화를 두려워하지 말고, 그 안에서 기회를 찾아보세요.',
      psychologicalState:
          '떨어지는 꿈은 삶의 어떤 영역에서 통제력을 잃었거나, 실패에 대한 두려움이 있음을 나타냅니다. 하지만 이는 성장을 위해 필요한 과정일 수 있습니다.',
      emotionalBalance: 5,
      significanceLevel: 7,
      actionAdvice: [
        '현재 불안하게 느끼는 부분을 글로 적어보세요. 명확해지면 해결책도 보입니다.',
        '완벽을 추구하기보다 최선을 다하는 것에 집중하세요.',
        '깊은 호흡과 명상으로 마음을 안정시키세요.',
      ],
      affirmations: [
        '나는 어떤 상황에서도 안전하다.',
        '변화 속에서도 나는 균형을 유지한다.',
        '떨어지더라도 다시 일어날 힘이 있다.',
      ],
      relatedSymbols: ['변화', '불안', '통제', '전환', '회복'],
    ),

    'chased': DreamInterpretationData(
      dreamId: 'chased',
      dreamType: 'anxiety',
      interpretation:
          '쫓기는 꿈은 피하고 싶은 문제나 감정이 있음을 나타냅니다. 누구에게 쫓기느냐가 중요한데, 괴물은 억압된 두려움을, 사람은 대인 관계 문제를, 동물은 본능적 욕구를 상징합니다. 쫓기다 도망치면 해결책을 찾을 것이고, 맞서면 문제를 극복할 것입니다.',
      todayGuidance:
          '오늘은 피하고 있던 문제를 직시해보세요. 미루면 미룰수록 더 커집니다. 작은 것부터 해결하다 보면 자신감이 생깁니다. 도움이 필요하면 주변에 요청하세요.',
      psychologicalState:
          '쫓기는 꿈은 현실에서 마주하기 싫은 상황이나 감정이 있음을 반영합니다. 무의식이 "이제 직면해야 할 때"라는 신호를 보내고 있습니다.',
      emotionalBalance: 4,
      significanceLevel: 7,
      actionAdvice: [
        '미루고 있던 일 목록을 만들고, 가장 쉬운 것부터 처리하세요.',
        '두려운 대상이나 상황을 구체적으로 적어보세요. 명확해지면 덜 무섭습니다.',
        '운동이나 활동적인 취미로 축적된 스트레스를 해소하세요.',
      ],
      affirmations: [
        '나는 두려움에 맞설 용기가 있다.',
        '문제를 직시하면 해결책이 보인다.',
        '나는 어떤 상황도 극복할 수 있다.',
      ],
      relatedSymbols: ['두려움', '회피', '직면', '해결', '용기'],
    ),

    'teeth': DreamInterpretationData(
      dreamId: 'teeth',
      dreamType: 'anxiety',
      interpretation:
          '이빨이 빠지는 꿈은 전 세계적으로 가장 흔한 꿈 중 하나입니다. 이는 자존감, 외모, 나이에 대한 불안을 반영하지만, 전통 해몽에서는 역몽으로 오히려 좋은 징조입니다. 새 이빨이 나면 새로운 시작을, 이빨이 깨끗해지면 문제 해결을 의미합니다.',
      todayGuidance:
          '오늘은 자기 관리와 건강에 신경 쓰세요. 치과 검진이 필요하다면 예약하세요. 외모나 나이에 대한 불안이 있다면, 자신의 가치는 겉모습이 아님을 기억하세요.',
      psychologicalState:
          '이빨 꿈은 자기 이미지와 관련된 불안을 반영합니다. 자신감이 흔들리거나, 다른 사람들에게 어떻게 보이는지 걱정하고 있을 수 있습니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '건강 검진 일정을 확인하고 필요한 것이 있으면 예약하세요.',
        '자신의 강점과 성취를 적어보세요. 자존감 회복에 도움이 됩니다.',
        '외모보다 내면의 가치에 집중하는 시간을 가지세요.',
      ],
      affirmations: [
        '나는 내면과 외면 모두 아름답다.',
        '나이와 상관없이 나는 가치 있는 존재다.',
        '자신감은 내 안에서 나온다.',
      ],
      relatedSymbols: ['자존감', '외모', '불안', '변화', '재생'],
    ),

    'naked': DreamInterpretationData(
      dreamId: 'naked',
      dreamType: 'anxiety',
      interpretation:
          '알몸인 꿈은 취약함과 노출에 대한 두려움을 반영합니다. 다른 사람 앞에서 알몸이면 비밀이 드러날 걱정이, 혼자 알몸이면 자기 자신을 직면하라는 신호입니다. 흥미롭게도 다른 사람들이 알아채지 못하면 걱정이 기우임을 의미합니다.',
      todayGuidance:
          '오늘은 진정한 자신을 보여줘도 괜찮습니다. 완벽하지 않아도 받아들여질 수 있습니다. 비밀이나 걱정이 있다면 신뢰할 수 있는 사람과 나누는 것을 고려해보세요.',
      psychologicalState:
          '알몸 꿈은 취약함에 대한 두려움과 진정성에 대한 욕구가 충돌하고 있음을 나타냅니다. 가면을 벗고 진짜 자신을 보여주고 싶지만, 그것이 두렵기도 합니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '오늘은 솔직하게 자신의 의견을 표현해보세요. 작은 것부터 시작하세요.',
        '완벽해 보여야 한다는 압박감을 내려놓으세요. 불완전함도 매력입니다.',
        '자기 수용에 대한 책이나 영상을 찾아보세요.',
      ],
      affirmations: [
        '나는 있는 그대로 충분하다.',
        '취약함을 보여주는 것은 용기다.',
        '진정한 나를 보여줄수록 더 사랑받는다.',
      ],
      relatedSymbols: ['취약함', '진정성', '두려움', '수용', '용기'],
    ),

    'late': DreamInterpretationData(
      dreamId: 'late',
      dreamType: 'anxiety',
      interpretation:
          '지각하는 꿈은 기회를 놓칠까 봐 두려워하거나, 과도한 책임감에 시달리고 있음을 나타냅니다. 중요한 행사에 늦으면 삶에서 중요한 것을 놓치고 있다는 신호이고, 늦었지만 괜찮으면 너무 자신에게 엄격하다는 의미입니다.',
      todayGuidance:
          '오늘은 시간 관리와 우선순위 설정에 집중하세요. 모든 것을 완벽하게 할 필요는 없습니다. 정말 중요한 것에 에너지를 쏟으세요. 여유를 가지면 오히려 효율이 오릅니다.',
      psychologicalState:
          '지각 꿈은 성과에 대한 불안과 시간 압박감을 반영합니다. 너무 많은 것을 감당하려 하거나, 자신에게 비현실적인 기대를 하고 있을 수 있습니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '오늘의 할 일 목록을 3가지 이내로 줄여보세요. 집중이 성과를 만듭니다.',
        '일정에 여유 시간을 반드시 포함하세요. 버퍼가 스트레스를 줄입니다.',
        '완료하지 못한 일에 대해 자책하지 마세요. 내일 해도 됩니다.',
      ],
      affirmations: [
        '나는 내 속도로 충분히 잘하고 있다.',
        '중요한 것에 집중하면 모든 것이 제때 이루어진다.',
        '여유는 효율의 일부다.',
      ],
      relatedSymbols: ['시간', '불안', '책임감', '우선순위', '여유'],
    ),

    'lost': DreamInterpretationData(
      dreamId: 'lost',
      dreamType: 'processing',
      interpretation:
          '길을 잃는 꿈은 인생의 방향에 대한 혼란이나 탐색의 시기를 나타냅니다. 익숙한 곳에서 길을 잃으면 정체성의 위기를, 낯선 곳에서 잃으면 새로운 도전을 의미합니다. 결국 길을 찾으면 해답이 올 것이고, 도움을 받으면 조력자가 나타날 것입니다.',
      todayGuidance:
          '오늘은 삶의 방향에 대해 생각해보는 시간을 가지세요. 어디로 가고 싶은지 명확하지 않다면 그것도 괜찮습니다. 탐색 자체가 여정입니다. 필요하면 조언을 구하세요.',
      psychologicalState:
          '길을 잃는 꿈은 정체성이나 목적에 대한 탐색을 반영합니다. 새로운 단계로 넘어가는 과도기에 있거나, 삶의 의미를 재정립하고 있을 수 있습니다.',
      emotionalBalance: 6,
      significanceLevel: 7,
      actionAdvice: [
        '5년 후 자신의 모습을 상상해보고 글로 적어보세요.',
        '멘토나 상담사와 대화해보세요. 방향을 찾는 데 도움이 됩니다.',
        '새로운 경험을 시도해보세요. 길은 걸으면서 만들어집니다.',
      ],
      affirmations: [
        '길을 잃어도 나는 안전하다.',
        '탐색의 과정이 나를 성장시킨다.',
        '나만의 길은 반드시 존재한다.',
      ],
      relatedSymbols: ['탐색', '방향', '정체성', '여정', '발견'],
    ),

    'swimming': DreamInterpretationData(
      dreamId: 'swimming',
      dreamType: 'symbolic',
      interpretation:
          '수영하는 꿈은 감정의 바다를 헤쳐나가는 능력을 상징합니다. 맑은 물에서 잘 수영하면 감정 조절이 잘 되고 있음을, 탁한 물에서 힘겹게 수영하면 감정적 어려움을 겪고 있음을 의미합니다. 헤엄쳐서 목적지에 도달하면 목표 성취를 암시합니다.',
      todayGuidance:
          '오늘은 감정에 솔직해지세요. 억누르지 말고 건강하게 표현하면 더 가벼워집니다. 물과 관련된 활동(수영, 목욕, 바다 구경)이 마음을 정화해줄 수 있습니다.',
      psychologicalState:
          '수영 꿈은 무의식적 감정과의 관계를 반영합니다. 감정의 흐름에 몸을 맡기고 유연하게 대처하는 능력이 발달하고 있거나, 그 필요성을 느끼고 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 7,
      actionAdvice: [
        '감정 일기를 써보세요. 내면의 감정을 인식하는 것이 첫 단계입니다.',
        '물가에서 산책하거나, 목욕으로 심신을 이완하세요.',
        '흐름에 맞서기보다 유연하게 적응하는 연습을 하세요.',
      ],
      affirmations: [
        '나는 감정의 파도를 능숙하게 헤쳐나간다.',
        '어떤 감정도 나를 삼키지 못한다.',
        '유연함이 나의 강점이다.',
      ],
      relatedSymbols: ['감정', '적응', '유연성', '정화', '흐름'],
    ),

    'driving': DreamInterpretationData(
      dreamId: 'driving',
      dreamType: 'processing',
      interpretation:
          '운전하는 꿈은 삶의 통제력과 방향성을 상징합니다. 잘 운전하면 인생을 잘 다스리고 있음을, 사고가 나면 경고 신호를, 브레이크가 안 들으면 멈출 필요가 있음을 의미합니다. 누가 운전하느냐도 중요한데, 내가 운전하면 주도권을, 남이 운전하면 의존성을 나타냅니다.',
      todayGuidance:
          '오늘은 삶의 방향타를 단단히 잡으세요. 중요한 결정은 스스로 내리고, 속도 조절도 필요하면 하세요. 너무 빠르게 달리고 있다면 잠시 멈추는 것도 좋습니다.',
      psychologicalState:
          '운전 꿈은 자율성과 통제에 대한 욕구를 반영합니다. 당신은 현재 삶을 스스로 이끌어가고 싶어하며, 그 능력도 갖추고 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 7,
      actionAdvice: [
        '삶에서 주도권을 더 가져야 할 영역을 찾아보세요.',
        '너무 빨리 달려왔다면 오늘은 속도를 줄이세요.',
        '목표로 가는 경로를 점검하고 필요하면 수정하세요.',
      ],
      affirmations: [
        '나는 내 삶의 운전대를 쥐고 있다.',
        '속도와 방향은 내가 결정한다.',
        '안전하게 목적지에 도달할 것이다.',
      ],
      relatedSymbols: ['통제', '방향', '속도', '주도권', '여정'],
    ),

    'climbing': DreamInterpretationData(
      dreamId: 'climbing',
      dreamType: 'prophetic',
      interpretation:
          '산을 오르는 꿈은 도전과 성취, 인내의 결실을 상징합니다. 정상에 오르면 목표 달성을, 힘들지만 오르면 노력이 보상받을 것을, 중간에 멈추면 재충전이 필요함을 의미합니다. 높은 산일수록 큰 성취를, 함께 오르면 협력의 중요성을 나타냅니다.',
      todayGuidance:
          '오늘은 도전적인 목표를 향해 한 걸음 나아가세요. 정상은 한 번에 가는 게 아니라 한 걸음씩 가는 것입니다. 힘들면 잠시 쉬어도 되지만, 포기하지는 마세요.',
      psychologicalState:
          '산을 오르는 꿈은 성장과 성취에 대한 강한 의지를 반영합니다. 당신은 현재 더 높은 곳을 향해 나아가려는 내적 동력이 있습니다.',
      emotionalBalance: 8,
      significanceLevel: 8,
      actionAdvice: [
        '큰 목표를 작은 단계로 나누어 오늘 첫 단계를 실행하세요.',
        '힘들 때 도움을 요청하세요. 함께 오르면 더 높이 갈 수 있습니다.',
        '중간중간 성취를 축하하세요. 동기 부여가 됩니다.',
      ],
      affirmations: [
        '나는 정상을 향해 꾸준히 나아간다.',
        '모든 어려움은 나를 더 강하게 만든다.',
        '끝까지 가면 반드시 성공한다.',
      ],
      relatedSymbols: ['도전', '인내', '성취', '성장', '노력'],
    ),

    'exam': DreamInterpretationData(
      dreamId: 'exam',
      dreamType: 'anxiety',
      interpretation:
          '시험 보는 꿈은 평가와 수행에 대한 불안을 반영합니다. 준비 없이 시험을 보면 자신감 부족을, 시험에 늦으면 기회를 놓칠 두려움을, 쉬운 시험이면 현재 잘하고 있음을 의미합니다. 흥미롭게도 졸업 후에도 이 꿈을 꾸는 것은 성인 생활의 도전을 상징합니다.',
      todayGuidance:
          '오늘은 자신을 믿으세요. 당신은 이미 많은 시험을 통과해왔습니다. 완벽할 필요 없이 최선을 다하면 됩니다. 스스로를 평가하는 기준을 너무 높게 잡지 마세요.',
      psychologicalState:
          '시험 꿈은 자기 평가와 외부 판단에 대한 불안을 나타냅니다. 당신은 능력을 증명해야 한다는 압박감을 느끼고 있지만, 실제로는 이미 충분히 유능합니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '자신의 역량과 성취 목록을 작성해보세요. 자신감 회복에 도움이 됩니다.',
        '오늘 중요한 일이 있다면 미리 준비하되, 완벽을 추구하지 마세요.',
        '실패해도 괜찮다고 자신에게 말해주세요. 배움의 기회가 됩니다.',
      ],
      affirmations: [
        '나는 이미 충분히 준비되어 있다.',
        '모든 도전은 성장의 기회다.',
        '결과와 상관없이 나는 가치 있다.',
      ],
      relatedSymbols: ['평가', '불안', '준비', '능력', '증명'],
    ),

    'fighting': DreamInterpretationData(
      dreamId: 'fighting',
      dreamType: 'processing',
      interpretation:
          '싸우는 꿈은 내적 갈등이나 외부 충돌을 반영합니다. 이기면 문제를 극복할 것을, 지면 다른 접근이 필요함을, 모르는 사람과 싸우면 자기 자신과의 싸움을 의미합니다. 싸움 후 화해하면 갈등 해결의 가능성을 암시합니다.',
      todayGuidance:
          '오늘은 갈등 상황에서 한 발 물러서서 상황을 객관적으로 보세요. 모든 싸움이 필요한 건 아닙니다. 싸울 가치가 있는 것과 그렇지 않은 것을 구별하세요.',
      psychologicalState:
          '싸우는 꿈은 억압된 분노나 해결되지 않은 갈등을 표출합니다. 이 에너지를 건설적으로 전환할 방법을 찾는 것이 중요합니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '분노나 불만이 있다면 건강한 방식으로 표현할 방법을 찾으세요.',
        '운동이나 신체 활동으로 긴장을 해소하세요.',
        '갈등 상황이 있다면 대화로 해결을 시도해보세요.',
      ],
      affirmations: [
        '나는 갈등을 지혜롭게 해결할 수 있다.',
        '분노도 건강하게 다룰 수 있다.',
        '평화로운 해결책이 항상 존재한다.',
      ],
      relatedSymbols: ['갈등', '분노', '해결', '힘', '화해'],
    ),

    // ==================== 사람 (10개) ====================

    'dead_person': DreamInterpretationData(
      dreamId: 'dead_person',
      dreamType: 'symbolic',
      interpretation:
          '돌아가신 분이 나오는 꿈은 특별한 의미를 가집니다. 편안한 모습이면 그분의 축복을, 무언가 말씀하시면 중요한 메시지를, 음식을 주시면 건강이나 재물 행운을 암시합니다. 전통적으로 조상님 꿈은 후손을 돌보시는 의미로 해석되며, 큰 결정 전에 꾸면 조언을 구하라는 신호입니다.',
      todayGuidance:
          '오늘은 조상님이나 돌아가신 분을 추모하는 시간을 가져보세요. 그분들이 남기신 가르침을 떠올리고 삶에 적용해보세요. 가족과 유대를 강화하기 좋은 날입니다.',
      psychologicalState:
          '돌아가신 분 꿈은 그리움과 미해결 감정, 또는 내면의 지혜가 활성화되었음을 나타냅니다. 그분과의 관계에서 정리하지 못한 것이 있거나, 삶의 지혜를 구하고 있을 수 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 9,
      actionAdvice: [
        '조상님 묘소 방문이나 차례를 계획해보세요. 마음의 평화가 찾아옵니다.',
        '돌아가신 분과 관련된 추억이나 가르침을 가족과 나눠보세요.',
        '미처 하지 못한 말이 있다면 편지를 써보세요. 치유가 됩니다.',
      ],
      affirmations: [
        '조상님의 지혜가 나를 인도한다.',
        '사랑했던 이들은 내 마음에 영원히 살아있다.',
        '나는 선조들의 축복을 받고 있다.',
      ],
      relatedSymbols: ['조상', '지혜', '축복', '연결', '추모'],
    ),

    'baby': DreamInterpretationData(
      dreamId: 'baby',
      dreamType: 'prophetic',
      interpretation:
          '아기 꿈은 새로운 시작과 가능성을 상징하는 길몽입니다. 예쁜 아기를 안으면 새로운 프로젝트 성공을, 아기가 웃으면 행복한 소식을, 아기를 낳으면 창조적 결실을 의미합니다. 태몽으로도 좋으며, 사업가에게는 새 사업의 시작을 암시합니다.',
      todayGuidance:
          '오늘은 새로운 시작을 위한 첫 걸음을 내딛기 좋습니다. 아이디어가 있다면 실행에 옮기세요. 순수한 마음으로 세상을 바라보면 새로운 가능성이 보입니다.',
      psychologicalState:
          '아기 꿈은 내면의 순수함과 새로운 가능성에 대한 열망을 반영합니다. 당신 안에 있는 창조적 에너지가 발현되기를 원하고 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 9,
      actionAdvice: [
        '새로 시작하고 싶던 일이 있다면 오늘 첫 단계를 밟으세요.',
        '아이의 눈으로 세상을 바라보세요. 놀라운 것들이 보일 것입니다.',
        '창의적인 취미나 프로젝트에 시간을 투자하세요.',
      ],
      affirmations: [
        '새로운 시작이 나를 기다리고 있다.',
        '나의 아이디어는 귀중한 가능성이다.',
        '순수한 마음으로 세상을 포용한다.',
      ],
      relatedSymbols: ['시작', '순수', '가능성', '창조', '탄생'],
    ),

    'ex': DreamInterpretationData(
      dreamId: 'ex',
      dreamType: 'processing',
      interpretation:
          '전 애인 꿈은 반드시 그 사람에 대한 미련을 의미하지 않습니다. 오히려 그 관계에서 배운 교훈이나, 과거의 자신을 떠올리게 하는 상징일 수 있습니다. 좋은 모습이면 성장했음을, 싸우면 해결할 내적 갈등이 있음을, 화해하면 자기 용서가 필요함을 나타냅니다.',
      todayGuidance:
          '오늘은 과거 관계에서 배운 것들을 생각해보세요. 그때의 나와 지금의 나를 비교하며 성장을 확인하세요. 과거에 얽매이지 말고 현재에 집중하세요.',
      psychologicalState:
          '전 애인 꿈은 현재 관계나 자기 자신에 대한 성찰을 촉구합니다. 과거 관계의 패턴이 현재에 영향을 미치고 있거나, 정리가 필요한 감정이 있을 수 있습니다.',
      emotionalBalance: 6,
      significanceLevel: 6,
      actionAdvice: [
        '과거 관계에서 배운 교훈을 일기에 적어보세요.',
        '현재 관계(연인, 친구, 가족)에 더 집중하고 감사를 표현하세요.',
        '자기 용서가 필요하다면, 그때의 자신에게 편지를 써보세요.',
      ],
      affirmations: [
        '과거는 나를 성장시킨 선생님이다.',
        '나는 더 나은 관계를 만들 준비가 되어있다.',
        '과거를 내려놓고 현재를 완전히 살아간다.',
      ],
      relatedSymbols: ['과거', '성장', '교훈', '관계', '자기성찰'],
    ),

    'celebrity': DreamInterpretationData(
      dreamId: 'celebrity',
      dreamType: 'wish-fulfillment',
      interpretation:
          '연예인 꿈은 인정받고 싶은 욕구와 이상적 자아를 상징합니다. 연예인과 대화하면 영감을 받을 것을, 연예인이 되면 재능 발휘의 기회를, 연예인과 사귀면 자존감 상승을 의미합니다. 누구냐에 따라 당신이 갈망하는 특성이 다르게 나타납니다.',
      todayGuidance:
          '오늘은 당신의 재능과 매력을 발휘하세요. 너무 겸손하지 말고 자신을 드러내도 좋습니다. 그 연예인이 가진 긍정적 특성을 자신에게서 찾아보세요.',
      psychologicalState:
          '연예인 꿈은 인정과 성공에 대한 욕구, 이상적 자아상을 반영합니다. 당신도 빛나고 싶고, 주목받을 자격이 있다는 내면의 목소리입니다.',
      emotionalBalance: 8,
      significanceLevel: 6,
      actionAdvice: [
        '그 연예인의 어떤 점이 마음에 드는지 생각해보세요. 당신에게도 그런 면이 있습니다.',
        '자신의 재능을 드러낼 기회를 만들어보세요. SNS 활동도 좋습니다.',
        '외모나 이미지에 신경 쓰기 좋은 날입니다. 자기 관리를 하세요.',
      ],
      affirmations: [
        '나도 빛날 자격이 있다.',
        '나의 재능은 세상에 인정받는다.',
        '나는 나만의 스타일로 빛난다.',
      ],
      relatedSymbols: ['인정', '재능', '매력', '이상', '성공'],
    ),

    'stranger': DreamInterpretationData(
      dreamId: 'stranger',
      dreamType: 'symbolic',
      interpretation:
          '모르는 사람 꿈은 자기 자신의 숨겨진 면이나 새로운 가능성을 상징합니다. 친절한 낯선 사람은 도움이 올 것을, 위협적인 낯선 사람은 직면해야 할 그림자를, 매력적인 낯선 사람은 발견하지 못한 자신의 매력을 의미합니다.',
      todayGuidance:
          '오늘은 새로운 만남에 열린 자세를 가지세요. 모르는 사람에게서도 배울 점이 있습니다. 또한 자신의 알려지지 않은 면을 탐색해보세요.',
      psychologicalState:
          '낯선 사람은 융이 말한 그림자(Shadow) 또는 아직 발현되지 않은 잠재적 자아를 나타냅니다. 당신 내면에는 아직 발견하지 못한 면들이 많이 있습니다.',
      emotionalBalance: 6,
      significanceLevel: 7,
      actionAdvice: [
        '오늘 만나는 새로운 사람에게 먼저 인사해보세요. 귀인이 될 수 있습니다.',
        '평소 해보지 않던 새로운 활동을 시도해보세요. 새로운 나를 발견할 수 있습니다.',
        '거울을 보며 자신에게 "당신의 어떤 면을 더 알고 싶어?"라고 물어보세요.',
      ],
      affirmations: [
        '나에게는 아직 발견하지 못한 무한한 가능성이 있다.',
        '새로운 만남이 나를 성장시킨다.',
        '나의 모든 면을 받아들이고 사랑한다.',
      ],
      relatedSymbols: ['가능성', '그림자', '발견', '만남', '미지'],
    ),

    'wedding': DreamInterpretationData(
      dreamId: 'wedding',
      dreamType: 'prophetic',
      interpretation:
          '결혼하는 꿈은 새로운 결합과 중요한 약속을 상징하는 길몽입니다. 자신의 결혼식은 새로운 단계로의 진입을, 다른 사람의 결혼은 축하할 일이 생김을, 결혼 준비는 중요한 계획의 진행을 의미합니다. 사업 파트너십이나 계약을 암시하기도 합니다.',
      todayGuidance:
          '오늘은 중요한 결정이나 약속을 하기 좋은 날입니다. 파트너십, 계약, 협력에 관한 일이 순조롭습니다. 관계에서 더 깊은 헌신을 고려해볼 수 있습니다.',
      psychologicalState:
          '결혼 꿈은 통합과 헌신에 대한 욕구를 반영합니다. 삶의 어떤 영역에서 더 깊은 결합이나 완전함을 추구하고 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 8,
      actionAdvice: [
        '중요한 파트너십이나 협력 관계를 강화하세요.',
        '미뤄왔던 중요한 약속이나 결정을 오늘 해보세요.',
        '소중한 사람에게 헌신과 사랑을 표현하세요.',
      ],
      affirmations: [
        '나는 진정한 결합과 조화를 이룬다.',
        '내 약속은 나와 상대 모두에게 축복이다.',
        '사랑과 헌신이 내 삶을 풍요롭게 한다.',
      ],
      relatedSymbols: ['결합', '약속', '새출발', '파트너십', '축복'],
    ),

    'pregnant': DreamInterpretationData(
      dreamId: 'pregnant',
      dreamType: 'prophetic',
      interpretation:
          '임신 꿈은 창조와 새로운 가능성이 무르익고 있음을 상징합니다. 실제 임신을 예고하기도 하지만, 대부분 새로운 프로젝트, 아이디어, 변화가 준비되고 있음을 의미합니다. 만삭이면 곧 결실을, 초기 임신이면 시작 단계임을 나타냅니다.',
      todayGuidance:
          '오늘은 창조적 에너지가 높습니다. 새로운 아이디어나 프로젝트를 품고 키우세요. 조급해하지 말고, 열매가 익을 때까지 인내하며 준비하세요.',
      psychologicalState:
          '임신 꿈은 창조성과 잠재력이 개발되고 있음을 반영합니다. 당신 안에서 무언가 새롭고 소중한 것이 자라고 있습니다.',
      emotionalBalance: 8,
      significanceLevel: 9,
      actionAdvice: [
        '진행 중인 프로젝트나 계획이 있다면 꾸준히 가꾸세요. 곧 결실을 봅니다.',
        '새로운 아이디어가 떠오르면 기록하고 발전시키세요.',
        '자신과 아이디어를 위해 영양가 있는 것(정보, 경험, 관계)을 섭취하세요.',
      ],
      affirmations: [
        '내 안에서 아름다운 것이 자라고 있다.',
        '나는 창조의 에너지로 가득하다.',
        '모든 것은 완벽한 타이밍에 열매 맺는다.',
      ],
      relatedSymbols: ['창조', '가능성', '성장', '결실', '기대'],
    ),

    'parent': DreamInterpretationData(
      dreamId: 'parent',
      dreamType: 'processing',
      interpretation:
          '부모님 꿈은 안정, 보호, 그리고 내면화된 가치관을 상징합니다. 부모님이 건강하시면 가정의 평화를, 조언하시면 현명한 결정이 필요함을, 아프시면 걱정되는 일이 있음을 의미합니다. 돌아가신 부모님 꿈은 그분의 축복과 인도하심입니다.',
      todayGuidance:
          '오늘은 부모님께 연락드리세요. 감사의 마음을 전하거나, 조언을 구해보세요. 부모님 역할을 하고 있다면, 자녀에게 더 관심을 기울여보세요.',
      psychologicalState:
          '부모님 꿈은 안전함과 지지에 대한 욕구, 또는 내면화된 부모의 목소리(초자아)를 반영합니다. 어른으로서의 책임과 어린아이로서의 보호 사이에서 균형을 찾고 있을 수 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 7,
      actionAdvice: [
        '부모님께 전화나 방문으로 안부를 전하세요.',
        '부모님에게 배운 가장 소중한 교훈을 떠올려보세요.',
        '자신이 부모라면, 오늘 자녀와 특별한 시간을 보내세요.',
      ],
      affirmations: [
        '나는 가족의 사랑 속에서 안전하다.',
        '부모님의 지혜가 나를 인도한다.',
        '나는 사랑을 주고받는 관계 속에 있다.',
      ],
      relatedSymbols: ['가족', '보호', '지혜', '근원', '안정'],
    ),

    'friend': DreamInterpretationData(
      dreamId: 'friend',
      dreamType: 'processing',
      interpretation:
          '친구 꿈은 사회적 연결과 자기 자신의 일부를 반영합니다. 친구와 즐거우면 관계가 좋음을, 다투면 갈등 해결이 필요함을, 오래된 친구가 나오면 과거의 자신을 돌아보라는 신호입니다. 친구의 특성이 당신에게도 있을 수 있습니다.',
      todayGuidance:
          '오늘은 친구에게 연락하세요. 오래 만나지 못한 친구라면 더욱 좋습니다. 우정을 돌보는 것도 중요한 일입니다. 친구가 보여주는 특성에서 자신을 발견해보세요.',
      psychologicalState:
          '친구 꿈은 사회적 욕구와 자아의 일부를 투사한 것입니다. 그 친구가 가진 특성이 당신 안에도 있거나, 그런 특성을 발달시키고 싶어할 수 있습니다.',
      emotionalBalance: 8,
      significanceLevel: 6,
      actionAdvice: [
        '오래 연락 못 한 친구에게 메시지를 보내세요.',
        '그 친구의 어떤 점이 좋은지 생각하고, 자신에게서도 찾아보세요.',
        '친구들과의 모임을 계획해보세요. 사회적 연결이 힘이 됩니다.',
      ],
      affirmations: [
        '나는 좋은 친구들과 연결되어 있다.',
        '친구들 속에서 나 자신을 더 잘 알아간다.',
        '우정은 내 삶을 풍요롭게 한다.',
      ],
      relatedSymbols: ['우정', '연결', '자아', '사회', '지지'],
    ),

    'enemy': DreamInterpretationData(
      dreamId: 'enemy',
      dreamType: 'processing',
      interpretation:
          '싫어하는 사람 꿈은 내면의 갈등과 자기 자신의 거부하는 측면을 반영합니다. 그 사람을 이기면 내적 갈등 극복을, 화해하면 자기 수용을, 도망치면 직면해야 할 문제가 있음을 의미합니다. 흥미롭게도 싫어하는 특성이 자신에게도 있을 수 있습니다.',
      todayGuidance:
          '오늘은 불편한 감정을 직시해보세요. 그 사람의 어떤 점이 싫은지 정확히 알면, 자신에 대해서도 알게 됩니다. 용서는 상대가 아닌 자신을 위한 것입니다.',
      psychologicalState:
          '싫어하는 사람은 융의 그림자(Shadow) 투사입니다. 타인에게서 불편하게 느끼는 것이 실은 자신 안에도 있는 억압된 특성일 수 있습니다.',
      emotionalBalance: 4,
      significanceLevel: 7,
      actionAdvice: [
        '그 사람의 정확히 어떤 점이 불편한지 글로 적어보세요.',
        '그 특성이 혹시 자신에게도 있는지 솔직히 살펴보세요.',
        '용서의 의미를 생각해보세요. 용서는 자유를 위한 것입니다.',
      ],
      affirmations: [
        '불편한 감정도 나를 가르친다.',
        '용서로 나 자신을 자유롭게 한다.',
        '모든 만남은 성장의 기회다.',
      ],
      relatedSymbols: ['그림자', '갈등', '투사', '용서', '성찰'],
    ),

    // ==================== 자연 (8개) ====================

    'water': DreamInterpretationData(
      dreamId: 'water',
      dreamType: 'symbolic',
      interpretation:
          '물/바다 꿈은 무의식과 감정의 세계를 상징합니다. 맑은 물은 정서적 명료함과 평화를, 탁한 물은 혼란스러운 감정을, 거센 파도는 억누른 감정의 분출을 의미합니다. 물에 빠지면 감정에 압도당함을, 물 위를 걸으면 감정을 완벽히 통제함을 나타냅니다.',
      todayGuidance:
          '오늘은 감정의 흐름에 주목하세요. 억눌린 감정이 있다면 건강한 방식으로 표현해보세요. 물가에서 산책하거나 목욕하며 마음을 정화하는 것도 좋습니다.',
      psychologicalState:
          '물은 무의식의 상징입니다. 꿈에서 물의 상태는 현재 감정 상태를 반영하며, 물과의 관계는 자신의 감정과의 관계를 보여줍니다.',
      emotionalBalance: 6,
      significanceLevel: 8,
      actionAdvice: [
        '오늘 느끼는 감정을 판단 없이 있는 그대로 느껴보세요.',
        '물 마시기, 샤워, 산책 등 물과 관련된 활동으로 정화하세요.',
        '감정 일기를 써서 내면의 흐름을 파악해보세요.',
      ],
      affirmations: [
        '내 감정은 자연스럽게 흐르도록 허락한다.',
        '나는 감정의 파도를 타며 균형을 유지한다.',
        '내면의 깊은 곳에서 지혜가 솟아오른다.',
      ],
      relatedSymbols: ['무의식', '감정', '정화', '흐름', '깊이'],
    ),

    'fire': DreamInterpretationData(
      dreamId: 'fire',
      dreamType: 'symbolic',
      interpretation:
          '불 꿈은 열정, 변화, 정화의 강력한 상징입니다. 따뜻한 불은 가정의 안정과 사랑을, 타오르는 불은 억눌린 열정이나 분노를, 불에 타는 것은 자아의 변형을 의미합니다. 전통 해몽에서 집에 불나면 재물운 상승의 길몽입니다.',
      todayGuidance:
          '오늘은 열정을 행동으로 옮기세요. 오래 미뤄둔 일이 있다면 이제 불을 붙일 때입니다. 단, 분노가 느껴진다면 건강하게 해소할 방법을 찾으세요.',
      psychologicalState:
          '불은 변형의 에너지입니다. 무언가를 태워 없앰과 동시에 새로운 가능성을 열어줍니다. 현재 당신 안에 변화를 향한 강한 에너지가 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 8,
      actionAdvice: [
        '열정을 쏟을 수 있는 활동을 찾아 에너지를 발산하세요.',
        '분노나 답답함이 있다면 운동으로 건강하게 해소하세요.',
        '양초를 켜고 명상하며 내면의 빛과 연결해보세요.',
      ],
      affirmations: [
        '내 안의 불꽃은 나를 밝히고 따뜻하게 한다.',
        '열정은 내 삶을 변화시키는 힘이다.',
        '낡은 것을 태우고 새로운 나로 다시 태어난다.',
      ],
      relatedSymbols: ['열정', '변화', '정화', '에너지', '재물'],
    ),

    'rain': DreamInterpretationData(
      dreamId: 'rain',
      dreamType: 'symbolic',
      interpretation:
          '비 오는 꿈은 정화와 새로운 시작을 상징합니다. 시원한 비는 스트레스 해소와 정서적 치유를, 폭우는 감정의 방출을, 비를 맞으며 걷는 것은 감정을 직면하는 용기를 의미합니다. 비 온 뒤 무지개는 희망의 상징입니다.',
      todayGuidance:
          '오늘은 마음의 비를 맞아도 괜찮습니다. 슬픔이나 스트레스를 흘려보내세요. 울고 싶다면 울어도 됩니다. 비 온 뒤 땅이 굳듯, 당신도 더 단단해질 것입니다.',
      psychologicalState:
          '비는 하늘의 눈물이자 대지의 축복입니다. 정서적 방출의 필요성과 동시에 정화 후 올 새로운 성장을 암시합니다.',
      emotionalBalance: 5,
      significanceLevel: 7,
      actionAdvice: [
        '감정을 억누르지 말고 자연스럽게 표현하세요.',
        '빗소리를 들으며 명상하거나 휴식을 취해보세요.',
        '정리가 필요한 것들(감정, 관계, 물건)을 정돈하세요.',
      ],
      affirmations: [
        '눈물은 마음을 씻어주는 치유의 비다.',
        '비 온 뒤 땅이 굳듯, 나도 더 단단해진다.',
        '모든 폭풍이 지나면 무지개가 뜬다.',
      ],
      relatedSymbols: ['정화', '치유', '새로운 시작', '감정', '축복'],
    ),

    'snow': DreamInterpretationData(
      dreamId: 'snow',
      dreamType: 'symbolic',
      interpretation:
          '눈 오는 꿈은 순수함, 정화, 새로운 시작을 상징합니다. 하얀 눈은 마음의 평화와 순수한 상태를, 눈 덮인 풍경은 고요한 성찰의 시간을, 눈싸움은 유희와 즐거움을 의미합니다. 녹는 눈은 감정의 해빙을 나타냅니다.',
      todayGuidance:
          '오늘은 마음을 비우고 순수한 상태로 돌아가보세요. 복잡한 일들을 잠시 내려놓고, 어린아이처럼 단순하게 생각해보세요. 새하얀 도화지처럼 새로운 시작이 가능합니다.',
      psychologicalState:
          '눈은 모든 것을 덮어 새롭게 만듭니다. 과거를 덮고 새 출발하고 싶은 무의식적 욕구, 또는 현재의 평화로운 마음 상태를 반영합니다.',
      emotionalBalance: 8,
      significanceLevel: 7,
      actionAdvice: [
        '마음을 복잡하게 하는 것들을 잠시 내려놓으세요.',
        '흰색 옷을 입거나 정돈된 공간에서 시간을 보내세요.',
        '새로운 일을 시작하기에 좋은 때입니다. 계획을 세워보세요.',
      ],
      affirmations: [
        '내 마음은 새하얀 눈처럼 순수하다.',
        '과거를 덮고 새로운 시작을 한다.',
        '고요함 속에서 내면의 지혜를 듣는다.',
      ],
      relatedSymbols: ['순수', '정화', '새 시작', '평화', '고요'],
    ),

    'flower': DreamInterpretationData(
      dreamId: 'flower',
      dreamType: 'prophetic',
      interpretation:
          '꽃 꿈은 아름다움, 성장, 사랑의 상징입니다. 활짝 핀 꽃은 목표 달성과 번영을, 시든 꽃은 놓친 기회나 끝나가는 관계를, 꽃봉오리는 새로운 가능성을 의미합니다. 전통적으로 꽃 꿈은 좋은 소식과 행운을 예고합니다.',
      todayGuidance:
          '오늘은 아름다움을 발견하세요. 작은 것에서 기쁨을 찾고, 자신의 성장을 축하하세요. 누군가에게 꽃처럼 따뜻한 말 한마디를 건네보세요.',
      psychologicalState:
          '꽃은 자아실현과 잠재력의 개화를 상징합니다. 당신 안의 아름다운 가능성이 피어나려 하고 있으며, 성장에 대한 긍정적 에너지가 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 7,
      actionAdvice: [
        '자신의 성장과 발전을 인정하고 축하하세요.',
        '사랑하는 사람에게 마음을 표현해보세요.',
        '꽃을 사거나 식물을 가꾸며 생명력을 느껴보세요.',
      ],
      affirmations: [
        '나는 매일 조금씩 더 아름답게 피어난다.',
        '내 안의 잠재력이 활짝 꽃피고 있다.',
        '사랑과 기쁨이 내 삶에 풍성하다.',
      ],
      relatedSymbols: ['성장', '아름다움', '사랑', '희망', '번영'],
    ),

    'mountain': DreamInterpretationData(
      dreamId: 'mountain',
      dreamType: 'prophetic',
      interpretation:
          '산 꿈은 도전, 목표, 성취를 상징합니다. 산을 오르면 목표를 향한 노력을, 정상에 서면 성공과 통찰을, 산을 바라보면 앞으로의 도전을 의미합니다. 전통적으로 높은 산 꿈은 큰 성공과 입신양명의 길몽입니다.',
      todayGuidance:
          '오늘은 큰 그림을 보세요. 당장의 어려움에 좌절하지 말고, 정상에서 보게 될 풍경을 상상하세요. 한 걸음씩 꾸준히 나아가면 반드시 도달합니다.',
      psychologicalState:
          '산은 자아실현의 여정을 상징합니다. 현재 중요한 도전 앞에 있으며, 그것을 극복하려는 의지와 준비가 되어 있습니다.',
      emotionalBalance: 7,
      significanceLevel: 9,
      actionAdvice: [
        '장기적인 목표를 세우고 단계별 계획을 만드세요.',
        '어려움을 성장의 기회로 바라보세요.',
        '실제로 산책이나 하이킹을 하며 도전 정신을 깨워보세요.',
      ],
      affirmations: [
        '나는 어떤 산도 오를 수 있는 힘이 있다.',
        '한 걸음씩 나아가면 정상에 도달한다.',
        '도전은 나를 더 강하게 만든다.',
      ],
      relatedSymbols: ['도전', '성취', '목표', '성공', '인내'],
    ),

    'sun': DreamInterpretationData(
      dreamId: 'sun',
      dreamType: 'prophetic',
      interpretation:
          '해/태양 꿈은 생명력, 성공, 희망의 강력한 상징입니다. 밝은 태양은 번영과 행운을, 떠오르는 해는 새로운 시작과 기회를, 지는 해는 한 시기의 마무리를 의미합니다. 태양 꿈은 전통적으로 최고의 길몽 중 하나입니다.',
      todayGuidance:
          '오늘은 자신감을 가지세요! 당신의 빛을 발할 때입니다. 숨기지 말고 능력을 보여주세요. 리더십을 발휘하거나 중요한 발표를 하기에 좋은 날입니다.',
      psychologicalState:
          '태양은 의식, 자아, 남성적 에너지를 상징합니다. 자신감과 활력이 충만하며, 자신의 존재를 세상에 드러내려는 에너지가 있습니다.',
      emotionalBalance: 9,
      significanceLevel: 9,
      actionAdvice: [
        '자신감을 가지고 적극적으로 행동하세요.',
        '숨겨둔 능력이나 아이디어를 세상에 드러내세요.',
        '아침 햇살을 받으며 하루를 시작해보세요.',
      ],
      affirmations: [
        '나는 태양처럼 빛나는 존재다.',
        '내 안의 빛이 세상을 밝힌다.',
        '성공과 번영이 내게로 온다.',
      ],
      relatedSymbols: ['성공', '희망', '활력', '번영', '리더십'],
    ),

    'moon': DreamInterpretationData(
      dreamId: 'moon',
      dreamType: 'symbolic',
      interpretation:
          '달 꿈은 직관, 여성성, 신비를 상징합니다. 보름달은 완성과 풍요를, 초승달은 새로운 시작을, 달빛은 무의식의 지혜를 의미합니다. 달은 감정의 리듬과 변화를 나타내며, 직관적 통찰의 시간임을 알려줍니다.',
      todayGuidance:
          '오늘은 논리보다 직관을 따르세요. 분석하지 말고 느껴보세요. 특히 밤 시간에 좋은 아이디어나 통찰이 올 수 있습니다. 꿈 일기를 쓰는 것도 좋습니다.',
      psychologicalState:
          '달은 무의식, 감정, 여성적 에너지를 상징합니다. 내면의 직관적인 지혜에 접근할 준비가 되었으며, 숨겨진 진실을 볼 수 있는 때입니다.',
      emotionalBalance: 7,
      significanceLevel: 8,
      actionAdvice: [
        '직관을 신뢰하고 느낌대로 결정해보세요.',
        '밤에 명상이나 산책을 하며 고요함을 느껴보세요.',
        '꿈 일기를 쓰며 무의식의 메시지를 기록하세요.',
      ],
      affirmations: [
        '내 직관은 나를 올바른 길로 인도한다.',
        '내면의 지혜가 어둠 속에서도 빛난다.',
        '감정의 리듬을 따라 자연스럽게 흐른다.',
      ],
      relatedSymbols: ['직관', '신비', '여성성', '변화', '지혜'],
    ),

    // ==================== 장소 (8개) ====================

    'house': DreamInterpretationData(
      dreamId: 'house',
      dreamType: 'symbolic',
      interpretation:
          '집 꿈은 자아와 내면 세계를 상징합니다. 방들은 성격의 다양한 측면을, 다락은 과거와 잠재력을, 지하실은 무의식을, 큰 집은 자아의 확장을, 낡은 집은 오래된 습관이나 기억을 의미합니다. 새집은 새로운 자아상의 형성입니다.',
      todayGuidance:
          '오늘은 자신의 내면을 탐험해보세요. 어떤 부분이 편안하고 어떤 부분이 불편한지 살펴보세요. 실제 집 정리도 마음 정리에 도움이 됩니다.',
      psychologicalState:
          '집은 자아의 상징입니다. 꿈에서 집의 상태는 현재 정신 상태를 반영하며, 탐험하는 방은 자기 발견의 여정을 나타냅니다.',
      emotionalBalance: 7,
      significanceLevel: 7,
      actionAdvice: [
        '자신의 장단점을 객관적으로 돌아보세요.',
        '실제 생활 공간을 정리하면 마음도 정리됩니다.',
        '새로운 자신의 모습을 상상하고 계획해보세요.',
      ],
      affirmations: [
        '내 안에는 무한한 가능성의 방들이 있다.',
        '나는 내 마음의 주인이다.',
        '내면의 모든 부분을 수용하고 사랑한다.',
      ],
      relatedSymbols: ['자아', '내면', '안정', '가족', '보호'],
    ),

    'school': DreamInterpretationData(
      dreamId: 'school',
      dreamType: 'processing',
      interpretation:
          '학교 꿈은 배움, 평가, 과거의 경험을 상징합니다. 시험에 늦는 꿈은 준비 부족 불안을, 졸업하는 꿈은 성장과 새로운 단계를, 오래된 학교로 돌아가는 꿈은 해결되지 않은 과거 이슈를 의미합니다.',
      todayGuidance:
          '오늘은 배움의 자세로 하루를 시작하세요. 실수도 교훈이라 생각하고, 모든 경험에서 성장하세요. 과거의 아쉬움이 있다면 이제 다른 방식으로 만회할 수 있습니다.',
      psychologicalState:
          '학교 꿈은 현재 평가받고 있다는 느낌이나 자기 검증의 필요성을 나타냅니다. 성장하고 증명하려는 욕구가 있습니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '새로운 것을 배우는 시간을 만드세요.',
        '자신에게 너무 엄격하지 마세요. 완벽할 필요 없습니다.',
        '과거의 아쉬움을 현재의 동력으로 바꿔보세요.',
      ],
      affirmations: [
        '매일이 배움과 성장의 기회다.',
        '나는 충분히 잘하고 있다.',
        '실수는 성장을 위한 디딤돌이다.',
      ],
      relatedSymbols: ['배움', '평가', '성장', '과거', '준비'],
    ),

    'elevator': DreamInterpretationData(
      dreamId: 'elevator',
      dreamType: 'anxiety',
      interpretation:
          '엘리베이터 꿈은 인생의 오르내림과 통제력을 상징합니다. 올라가면 사회적 상승이나 성공을, 내려가면 내면 탐구나 하락을, 갇히면 상황에 대한 무력감을, 추락하면 급격한 변화에 대한 두려움을 의미합니다.',
      todayGuidance:
          '오늘은 삶의 통제권을 점검해보세요. 어디로 가고 있는지, 그것이 원하는 방향인지 생각해보세요. 때로는 버튼을 누르고 기다리는 것도 필요합니다.',
      psychologicalState:
          '엘리베이터는 삶의 상승과 하강을 빠르게 경험하는 상징입니다. 현재 변화의 속도에 대한 불안이나 기대가 있을 수 있습니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '인생에서 가고 싶은 방향을 명확히 하세요.',
        '급하게 서두르지 말고 과정을 즐기세요.',
        '통제할 수 없는 것은 내려놓고, 할 수 있는 것에 집중하세요.',
      ],
      affirmations: [
        '나는 내 인생의 방향을 선택한다.',
        '오르막도 내리막도 모두 여정의 일부다.',
        '적절한 때에 적절한 곳에 도달한다.',
      ],
      relatedSymbols: ['상승', '하강', '통제', '변화', '불안'],
    ),

    'toilet': DreamInterpretationData(
      dreamId: 'toilet',
      dreamType: 'processing',
      interpretation:
          '화장실 꿈은 정화, 배출, 사적인 공간의 필요를 상징합니다. 화장실을 찾는 꿈은 감정 해소의 필요를, 막힌 화장실은 표현하지 못한 감정을, 깨끗한 화장실은 건강한 정서 처리를, 더러운 화장실은 해결이 필요한 문제를 의미합니다.',
      todayGuidance:
          '오늘은 정서적 정화의 시간을 가지세요. 말 못 한 것이 있다면 표현하고, 스트레스가 있다면 건강하게 해소하세요. 자신만의 사적인 시간도 중요합니다.',
      psychologicalState:
          '화장실은 불필요한 것을 내보내는 상징입니다. 감정적으로 비워내야 할 것이 있으며, 프라이버시와 자기 돌봄의 필요성을 나타냅니다.',
      emotionalBalance: 5,
      significanceLevel: 5,
      actionAdvice: [
        '억눌린 감정이나 스트레스를 건강하게 표출하세요.',
        '자신만의 시간과 공간을 확보하세요.',
        '몸과 마음의 독소를 해소하는 활동을 하세요.',
      ],
      affirmations: [
        '불필요한 것을 내보내고 가벼워진다.',
        '나만의 공간에서 재충전한다.',
        '정화를 통해 새롭게 시작한다.',
      ],
      relatedSymbols: ['정화', '배출', '프라이버시', '해소', '정서'],
    ),

    'car': DreamInterpretationData(
      dreamId: 'car',
      dreamType: 'symbolic',
      interpretation:
          '자동차 꿈은 인생의 방향과 자율성을 상징합니다. 운전하면 삶의 통제권을, 조수석은 타인 의존을, 브레이크 고장은 통제력 상실을, 새 차는 새로운 정체성을, 사고는 경고나 방향 전환 필요를 의미합니다.',
      todayGuidance:
          '오늘은 인생의 핸들을 꽉 잡으세요. 당신이 운전자입니다. 가고 싶은 방향으로 가세요. 단, 속도 조절도 중요합니다. 너무 급하면 사고 납니다.',
      psychologicalState:
          '자동차는 자아의 연장이자 삶의 여정을 나타냅니다. 현재 자신의 방향성과 통제력에 대한 인식이 꿈에 반영되어 있습니다.',
      emotionalBalance: 6,
      significanceLevel: 7,
      actionAdvice: [
        '인생의 방향과 목적지를 점검해보세요.',
        '주도적으로 결정하고 책임지세요.',
        '적절한 속도로 나아가세요. 서두르지 않아도 됩니다.',
      ],
      affirmations: [
        '내 인생은 내가 운전한다.',
        '올바른 방향으로 안전하게 나아간다.',
        '여정 자체를 즐기며 목적지에 도달한다.',
      ],
      relatedSymbols: ['방향', '자율성', '통제', '여정', '속도'],
    ),

    'airplane': DreamInterpretationData(
      dreamId: 'airplane',
      dreamType: 'prophetic',
      interpretation:
          '비행기 꿈은 높은 목표, 자유, 새로운 관점을 상징합니다. 이륙은 새로운 시작과 상승을, 순항은 순조로운 진행을, 착륙은 목표 달성을, 추락은 야망에 대한 두려움을, 탑승 못 함은 기회를 놓칠 불안을 의미합니다.',
      todayGuidance:
          '오늘은 더 큰 그림을 보세요. 일상에서 벗어나 높은 곳에서 전체를 조망해보세요. 새로운 가능성을 향해 도약할 준비가 되어 있습니다.',
      psychologicalState:
          '비행기는 야망, 자유, 초월의 상징입니다. 현실을 넘어 더 높은 곳을 향하려는 열망이 있으며, 새로운 시각을 얻고자 합니다.',
      emotionalBalance: 7,
      significanceLevel: 8,
      actionAdvice: [
        '큰 목표를 세우고 이륙 준비를 하세요.',
        '새로운 경험이나 여행을 계획해보세요.',
        '일상에서 벗어나 다른 관점을 가져보세요.',
      ],
      affirmations: [
        '나는 한계를 넘어 자유롭게 날아오른다.',
        '높은 곳에서 새로운 시각을 얻는다.',
        '모든 목적지에 안전하게 도달한다.',
      ],
      relatedSymbols: ['상승', '자유', '목표', '여행', '관점'],
    ),

    'hospital': DreamInterpretationData(
      dreamId: 'hospital',
      dreamType: 'processing',
      interpretation:
          '병원 꿈은 치유, 돌봄, 자기 관리의 필요를 상징합니다. 입원하면 휴식과 회복의 필요를, 진료받는 것은 문제 진단의 필요를, 퇴원은 치유 완료를, 병문안은 타인 케어를 의미합니다. 건강 점검 메시지일 수도 있습니다.',
      todayGuidance:
          '오늘은 자기 돌봄에 집중하세요. 무리하지 말고, 몸과 마음의 소리에 귀 기울이세요. 미뤄둔 건강 검진이 있다면 예약하세요.',
      psychologicalState:
          '병원은 치유의 공간입니다. 신체적 또는 정서적으로 돌봄이 필요하며, 자기 치유를 향한 무의식적 움직임이 있습니다.',
      emotionalBalance: 5,
      significanceLevel: 6,
      actionAdvice: [
        '몸과 마음의 건강 상태를 점검하세요.',
        '휴식이 필요하면 충분히 쉬세요.',
        '미룬 건강 검진이 있다면 일정을 잡으세요.',
      ],
      affirmations: [
        '나는 내 몸과 마음을 소중히 돌본다.',
        '휴식은 생산성의 일부다.',
        '치유의 에너지가 나를 감싸고 있다.',
      ],
      relatedSymbols: ['치유', '돌봄', '건강', '회복', '휴식'],
    ),

    'mirror': DreamInterpretationData(
      dreamId: 'mirror',
      dreamType: 'symbolic',
      interpretation:
          '거울 꿈은 자기 인식과 성찰을 상징합니다. 자신을 보면 자아 탐구를, 낯선 모습은 알지 못하는 자신을, 깨진 거울은 자아상의 균열을, 아름다운 모습은 자기 수용을, 못생긴 모습은 자기 비판을 의미합니다.',
      todayGuidance:
          '오늘은 자신을 객관적으로 바라보세요. 장점도 단점도 있는 그대로 보세요. 거울은 판단하지 않고 그냥 비춰줄 뿐입니다. 자신에게도 그런 시선을 주세요.',
      psychologicalState:
          '거울은 자기 인식의 도구입니다. 자신을 어떻게 바라보는지, 자아상이 현실적인지 탐구하는 중입니다. 자기 수용의 과정에 있습니다.',
      emotionalBalance: 6,
      significanceLevel: 7,
      actionAdvice: [
        '자신의 장단점을 있는 그대로 인정하세요.',
        '타인의 평가가 아닌, 자신의 기준으로 자신을 보세요.',
        '거울 앞에서 자신에게 긍정적인 말을 해보세요.',
      ],
      affirmations: [
        '나는 있는 그대로의 나를 사랑한다.',
        '내 안의 모든 면을 수용한다.',
        '진정한 나를 발견하고 표현한다.',
      ],
      relatedSymbols: ['자아', '성찰', '진실', '수용', '인식'],
    ),
  };
}
