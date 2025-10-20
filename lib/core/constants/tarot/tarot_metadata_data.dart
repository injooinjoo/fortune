import 'tarot_card_info.dart';
import 'tarot_spread.dart';

// TarotMetadata class with all card data
class TarotMetadata {
  // Major Arcana (메이저 아르카나) - 22장
  static const Map<int, TarotCardInfo> majorArcana = {
    0: TarotCardInfo(
      id: 0,
      name: '바보 (The Fool)',
      keywords: ['새로운 시작', '순수함', '자유', '모험'],
      uprightMeaning: '새로운 여정의 시작, 무한한 가능성, 순수한 마음',
      reversedMeaning: '무모함, 위험한 선택, 준비 부족',
      element: '공기',
      astrology: '천왕성',
      numerology: 0,
      imagery: '절벽 끝에 서 있는 젊은이, 하얀 개, 태양',
      advice: '두려움 없이 새로운 도전을 받아들이세요',
      questions: [
        '어떤 새로운 시작이 당신을 기다리고 있나요?',
        '무엇이 당신을 주저하게 만들고 있나요?'],
      story: '''바보는 타로의 첫 번째 카드로, 영혼의 여정을 시작하는 순수한 존재를 나타냅니다. 
      
젊은 여행자가 작은 보따리 하나만 메고 절벽 끝에 서 있습니다. 그의 얼굴은 하늘을 향하고 있으며, 한 발은 이미 절벽 너머로 향하고 있습니다. 하얀 개가 그의 발치에서 짖으며 경고하지만, 바보는 개의 경고를 듣지 않습니다. 

그의 손에는 하얀 장미가 들려 있는데, 이는 순수함과 무구함을 상징합니다. 어깨에 멘 작은 보따리에는 그의 모든 소유물이 담겨 있지만, 그에게는 그것만으로도 충분합니다. 밝은 태양이 그의 여정을 축복하며 빛나고 있습니다.

바보는 아직 세상의 위험을 모르는 순수한 영혼입니다. 그러나 바로 그 순수함과 열린 마음이 그를 새로운 경험으로 이끌어갑니다. 때로는 무모해 보일 수 있지만, 진정한 지혜는 때때로 '모르는 것'에서 시작됩니다.''',
      
      mythology: '''연결됩니다:

**디오니소스(그리스)**: 광기와 황홀경의 신으로, 일상적 의식을 초월한 상태를 상징합니다.

**파르지팔(아서왕 전설)**: 순수한 바보로 시작하여 성배를 찾는 기사가 된 인물입니다. 그의 순수함이 오히려 그를 성공으로 이끌었습니다.

**릴(히브리 전설)**: 최초의 인간으로, 에덴동산에서의 순수한 상태를 나타냅니다.

**코요테(북미 원주민)**: 트릭스터 신으로, 지혜로운 바보의 원형입니다. 실수를 통해 가르침을 주는 존재입니다.''', 
      
      psychologicalMeaning: '''융의 관점에서 바보는 '영원한 소년(Puer Aeternus)' 원형을 나타냅니다.

**의식의 시작**: 바보는 자아가 무의식으로부터 분리되기 시작하는 순간을 상징합니다. 아직 페르소나(사회적 가면)를 쓰지 않은 순수한 상태입니다.

**개성화 과정**: 바보의 여정은 융이 말하는 개성화 과정의 시작점입니다. 자기(Self)를 향한 긴 여정의 첫걸음입니다.

**그림자의 부재**: 바보는 아직 자신의 그림자를 인식하지 못합니다. 이는 순수함이자 동시에 미성숙함을 의미합니다.

**가능성의 상태**: 모든 것이 될 수 있는 잠재력을 지닌 상태로, 의식이 아직 고정되지 않은 유연한 상태를 나타냅니다.''',
      
      spiritualMeaning: '''바보는 영적 여정의 시작을 알리는 신성한 순간을 나타냅니다.

**영혼의 순수성**: 물질세계에 오염되지 않은 순수한 영혼의 상태를 상징합니다. 이는 모든 영적 전통에서 추구하는 '초심'의 상태입니다.

**신성한 광기**: 세속적 지혜를 초월한 신성한 광기를 나타냅니다. 수피교의 '신에 취한 자': 기독교의 '그리스도 안의 바보'와 같은 개념입니다.

**무한의 가능성**: 0이라는 숫자는 무(無)이자 동시에 무한(∞)을 의미합니다. 모든 것의 시작이자 끝입니다.

**믿음의 도약**: 이성과 논리를 넘어선 순수한 믿음의 도약을 상징합니다. 신비주의자들이 말하는 '어둠 속으로의 도약'입니다.''', 
      
      dailyApplications: [
        '새로운 프로젝트나 관계를 시작할 때 열린 마음을 유지하세요',
        '실패를 두려워하지 말고 배움의 기회로 삼으세요',
        '어린아이같은 호기심으로 일상을 바라보세요',
        '계획에 너무 얽매이지 말고 즉흥성을 허용하세요',
        '모르는 것을 인정하고 질문하는 용기를 가지세요'],
      meditation: '''명상법:

1. 편안한 자세로 앉아 눈을 감습니다.
2. 절벽 끝에 서 있는 자신을 상상합니다.
3. 발아래 펼쳐진 미지의 세계를 느껴봅니다.
4. 두려움 없이 한 발을 내딛는 자신을 봅니다.
5. 떨어지는 것이 아니라 날아오르는 느낌을 경험합니다.
6. "나는 새로운 시작을 환영합니다"라고 마음속으로 반복합니다.''',
      affirmations: [
        '나는 새로운 경험을 두려움 없이 받아들입니다',
        '나의 순수함과 호기심이 나를 올바른 길로 인도합니다',
        '나는 우주의 보호를 받으며 나아갑니다',
        '매 순간이 새로운 시작입니다',
        '나는 무한한 가능성의 존재입니다'],
      colorSymbolism: '''
**노란색 배경**: 낙관주의, 지적 명료함, 새로운 아이디어
**흰색 옷**: 순수함, 영적 각성, 새로운 시작
**빨간 깃털**: 생명력, 열정, 모험심
**흰 장미**: 순수한 의도, 영적 열망
**흰 개**: 본능, 보호, 충실한 동반자''',
      
      crystals: [
        '클리어 쿼츠 - 명료함과 새로운 시작',
        '문스톤 - 직관과 새로운 주기',
        '라브라도라이트 - 변화와 모험',
        '아쿠아마린 - 용기와 명확한 소통'],
      timing: '새로운 달, 봄의 시작, 3월 21일(춘분), 새벽 시간',
      
      healthMessage: '''신체적으로는 신경계와 관련이 있으며, 새로운 활력과 에너지를 나타냅니다. 정신적으로는 스트레스 해소와 마음의 개방성이 필요한 시기입니다. 새로운 운동이나 건강 습관을 시작하기 좋은 때입니다.''',
      
      cardCombinations: {
        '바보 + 마법사': '잠재력이 실현되기 시작함',
        '바보 + 여사제': '직관을 따르는 새로운 시작',
        '바보 + 죽음': '완전히 새로운 삶의 장이 열림',
        '바보 + 탑': '예상치 못한 변화로 인한 새출발',
        '바보 + 세계': '한 주기가 끝나고 새로운 주기가 시작됨'},
      historicalContext: '''바보 카드는 중세 유럽의 궁정 광대 전통과 깊은 연관이 있습니다. 광대는 왕에게 진실을 말할 수 있는 유일한 존재였으며, 그들의 '어리석음'은 오히려 지혜를 전달하는 수단이었습니다. 르네상스 시대에는 '신성한 광기'라는 개념이 유행했으며, 이는 바보 카드의 심오한 의미와 연결됩니다.''',
      
      artisticSymbolism: '''라이더-웨이트 덱에서 팸밀라 콜먼 스미스는 바보를 젊고 앤드로지너스한 인물로 그렸습니다. 이는 성별을 초월한 순수한 영혼을 나타냅니다. 절벽은 의식과 무의식의 경계를, 태양은 신성한 축복을 상징합니다. 작은 보따리는 과거의 경험을, 지팡이는 의지력을 나타냅니다.'''),
    1: TarotCardInfo(
      id: 1,
      name: '마법사 (The Magician)',
      keywords: ['의지력', '창조', '기술', '자신감'],
      uprightMeaning: '목표 실현의 능력, 모든 도구를 갖춤, 집중력',
      reversedMeaning: '재능 낭비, 속임수, 자신감 부족',
      element: '모든 원소',
      astrology: '수성',
      numerology: 1,
      imagery: '테이블 위의 4원소, 무한대 기호, 지팡이',
      advice: '당신의 모든 능력을 활용하여 목표를 달성하세요',
      questions: [
        '어떤 재능을 더 개발해야 하나요?',
        '목표 달성을 위해 무엇이 필요한가요?']),
    2: TarotCardInfo(
      id: 2,
      name: '여사제 (The High Priestess)',
      keywords: ['직관', '신비', '잠재의식', '지혜'],
      uprightMeaning: '내면의 목소리, 숨겨진 지식, 인내',
      reversedMeaning: '비밀 공개, 직관 무시, 표면적 판단',
      element: '물',
      astrology: '달',
      numerology: 2,
      imagery: '두 기둥 사이의 여사제, 초승달, 석류',
      advice: '직관을 믿고 내면의 지혜에 귀 기울이세요',
      questions: [
        '무엇이 아직 드러나지 않았나요?',
        '내면의 목소리가 무엇을 말하고 있나요?']),
    3: TarotCardInfo(
      id: 3,
      name: '여황제 (The Empress)',
      keywords: ['풍요', '모성', '창조', '자연'],
      uprightMeaning: '창조성과 풍요, 양육과 성장, 감각적 즐거움',
      reversedMeaning: '창조적 막힘, 과잉 보호, 의존성',
      element: '땅',
      astrology: '금성',
      numerology: 3,
      imagery: '왕좌의 여황제, 밀밭, 금성 기호',
      advice: '자연과 조화를 이루며 창조적 에너지를 발산하세요',
      questions: [
        '무엇을 창조하고 키워나가고 있나요?',
        '어떻게 자신을 더 사랑할 수 있나요?']),
    4: TarotCardInfo(
      id: 4,
      name: '황제 (The Emperor)',
      keywords: ['권위', '구조', '아버지', '안정'],
      uprightMeaning: '리더십, 권위, 안정적인 기반, 보호',
      reversedMeaning: '독재, 경직성, 권력 남용',
      element: '불',
      astrology: '양자리',
      numerology: 4,
      imagery: '왕좌의 황제, 양의 머리, 붉은 옷',
      advice: '책임감을 갖고 안정적인 구조를 만들어가세요',
      questions: [
        '어디서 더 많은 구조가 필요한가요?',
        '당신의 권위를 어떻게 사용하고 있나요?']),
    5: TarotCardInfo(
      id: 5,
      name: '교황 (The Hierophant)',
      keywords: ['전통', '가르침', '신념', '사회적 규범'],
      uprightMeaning: '전통적 가치, 영적 지도, 교육과 학습',
      reversedMeaning: '독단적 사고, 전통에 대한 의문, 비순응',
      element: '땅',
      astrology: '황소자리',
      numerology: 5,
      imagery: '종교적 인물, 두 기둥, 두 제자',
      advice: '지혜로운 조언을 구하고 전통에서 배우세요',
      questions: [
        '어떤 믿음이 당신을 인도하고 있나요?',
        '누구에게서 배울 수 있나요?']),
    6: TarotCardInfo(
      id: 6,
      name: '연인들 (The Lovers)',
      keywords: ['사랑', '선택', '조화', '관계'],
      uprightMeaning: '사랑과 조화, 중요한 선택, 가치관의 일치',
      reversedMeaning: '불화, 나쁜 선택, 가치관 충돌',
      element: '공기',
      astrology: '쌍둥이자리',
      numerology: 6,
      imagery: '두 연인, 천사, 에덴동산',
      advice: '마음의 소리를 듣고 진정한 선택을 하세요',
      questions: [
        '어떤 선택이 당신 앞에 놓여 있나요?',
        '무엇이 진정한 조화를 만드나요?']),
    7: TarotCardInfo(
      id: 7,
      name: '전차 (The Chariot)',
      keywords: ['의지', '결단', '승리', '통제'],
      uprightMeaning: '의지력으로 얻는 승리, 자기 통제, 결단력',
      reversedMeaning: '통제력 상실, 공격성, 방향성 부족',
      element: '물',
      astrology: '게자리',
      numerology: 7,
      imagery: '전차를 모는 전사, 스핑크스, 별이 빛나는 천장',
      advice: '목표를 향해 결단력 있게 전진하세요',
      questions: [
        '어떤 도전을 극복해야 하나요?',
        '어떻게 균형을 유지할 수 있나요?']),
    8: TarotCardInfo(
      id: 8,
      name: '힘 (Strength)',
      keywords: ['내적 힘', '용기', '인내', '자비'],
      uprightMeaning: '내면의 힘, 부드러운 통제, 용기와 인내',
      reversedMeaning: '자기 의심, 약함, 인내력 부족',
      element: '불',
      astrology: '사자자리',
      numerology: 8,
      imagery: '사자를 다루는 여인, 무한대 기호',
      advice: '부드러운 힘으로 어려움을 극복하세요',
      questions: [
        '어떤 내적 힘을 발견했나요?',
        '어디서 더 많은 인내가 필요한가요?']),
    9: TarotCardInfo(
      id: 9,
      name: '은둔자 (The Hermit)',
      keywords: ['내면 탐구', '지혜', '고독', '안내'],
      uprightMeaning: '내면의 탐구, 영적 깨달음, 혼자만의 시간',
      reversedMeaning: '고립, 외로움, 내면 회피',
      element: '땅',
      astrology: '처녀자리',
      numerology: 9,
      imagery: '등불을 든 노인, 산꼭대기, 지팡이',
      advice: '내면의 빛을 따라 진실을 찾으세요',
      questions: [
        '무엇을 찾고 있나요?',
        '혼자만의 시간이 왜 필요한가요?']),
    10: TarotCardInfo(
      id: 10,
      name: '운명의 수레바퀴 (Wheel of Fortune)',
      keywords: ['변화', '순환', '운명', '기회'],
      uprightMeaning: '행운의 전환점, 새로운 기회, 운명의 순환',
      reversedMeaning: '불운, 통제력 상실, 저항',
      element: '불',
      astrology: '목성',
      numerology: 10,
      imagery: '회전하는 바퀴, 스핑크스, 동물 상징',
      advice: '변화의 흐름을 받아들이고 기회를 포착하세요',
      questions: [
        '어떤 변화가 다가오고 있나요?',
        '운명의 흐름을 어떻게 활용할 수 있나요?']),
    11: TarotCardInfo(
      id: 11,
      name: '정의 (Justice)',
      keywords: ['공정', '균형', '진실', '책임'],
      uprightMeaning: '공정한 판단, 균형과 조화, 인과응보',
      reversedMeaning: '불공정, 편견, 책임 회피',
      element: '공기',
      astrology: '천칭자리',
      numerology: 11,
      imagery: '저울과 검을 든 인물, 두 기둥',
      advice: '진실과 공정함을 추구하세요',
      questions: [
        '어떤 결정이 필요한가요?',
        '무엇이 진정한 균형인가요?']),
    12: TarotCardInfo(
      id: 12,
      name: '매달린 사람 (The Hanged Man)',
      keywords: ['희생', '관점 전환', '인내', '깨달음'],
      uprightMeaning: '자발적 희생, 새로운 관점, 영적 깨달음',
      reversedMeaning: '무의미한 희생, 정체, 지연',
      element: '물',
      astrology: '해왕성',
      numerology: 12,
      imagery: '거꾸로 매달린 사람, 후광, 나무',
      advice: '다른 관점에서 상황을 바라보세요',
      questions: [
        '무엇을 놓아주어야 하나요?',
        '어떤 새로운 관점이 필요한가요?']),
    13: TarotCardInfo(
      id: 13,
      name: '죽음 (Death)',
      keywords: ['변화', '종료', '변혁', '재생'],
      uprightMeaning: '큰 변화, 한 주기의 끝, 변혁과 재생',
      reversedMeaning: '변화 거부, 정체, 두려움',
      element: '물',
      astrology: '전갈자리',
      numerology: 13,
      imagery: '해골 기사, 검은 말, 떠오르는 태양',
      advice: '끝은 새로운 시작을 위한 준비입니다',
      questions: [
        '무엇을 끝내야 하나요?',
        '어떤 변화가 필요한가요?']),
    14: TarotCardInfo(
      id: 14,
      name: '절제 (Temperance)',
      keywords: ['균형', '조화', '인내', '통합'],
      uprightMeaning: '균형과 조화, 인내심, 중용의 미덕',
      reversedMeaning: '불균형, 과잉, 조급함',
      element: '불',
      astrology: '사수자리',
      numerology: 14,
      imagery: '천사, 두 잔의 물, 붓꽃',
      advice: '인내심을 갖고 균형을 찾으세요',
      questions: [
        '어디서 더 많은 균형이 필요한가요?',
        '무엇을 통합해야 하나요?']),
    15: TarotCardInfo(
      id: 15,
      name: '악마 (The Devil)',
      keywords: ['속박', '유혹', '물질주의', '그림자'],
      uprightMeaning: '속박과 중독, 물질적 집착, 억압된 욕망',
      reversedMeaning: '해방, 속박에서 벗어남, 각성',
      element: '땅',
      astrology: '염소자리',
      numerology: 15,
      imagery: '악마, 쇠사슬에 묶인 남녀, 거꾸로 된 오각별',
      advice: '자신을 속박하는 것에서 벗어나세요',
      questions: [
        '무엇이 당신을 속박하고 있나요?',
        '어떤 두려움과 마주해야 하나요?']),
    16: TarotCardInfo(
      id: 16,
      name: '탑 (The Tower)',
      keywords: ['파괴', '각성', '충격', '해방'],
      uprightMeaning: '갑작스런 변화, 기존 구조의 붕괴, 각성',
      reversedMeaning: '변화 회피, 재난 예방, 내적 변화',
      element: '불',
      astrology: '화성',
      numerology: 16,
      imagery: '번개 맞은 탑, 떨어지는 사람들, 왕관',
      advice: '파괴는 때로 필요한 정화 과정입니다',
      questions: [
        '어떤 구조가 무너져야 하나요?',
        '진실은 무엇인가요?']),
    17: TarotCardInfo(
      id: 17,
      name: '별 (The Star)',
      keywords: ['희망', '영감', '치유', '갱신'],
      uprightMeaning: '희망과 영감, 영적 인도, 치유와 갱신',
      reversedMeaning: '절망, 신념 상실, 단절감',
      element: '공기',
      astrology: '물병자리',
      numerology: 17,
      imagery: '물을 붓는 여인, 일곱 개의 작은 별, 하나의 큰 별',
      advice: '희망을 품고 미래를 믿으세요',
      questions: [
        '무엇이 당신에게 희망을 주나요?',
        '어떤 꿈을 향해 나아가고 있나요?']),
    18: TarotCardInfo(
      id: 18,
      name: '달 (The Moon)',
      keywords: ['환상', '두려움', '잠재의식', '직관'],
      uprightMeaning: '환상과 불안, 숨겨진 진실, 직관의 메시지',
      reversedMeaning: '환상에서 깨어남, 명확성, 두려움 극복',
      element: '물',
      astrology: '물고기자리',
      numerology: 18,
      imagery: '달, 개와 늑대, 가재, 두 탑',
      advice: '직관을 신뢰하되 환상에 주의하세요',
      questions: [
        '무엇이 숨겨져 있나요?',
        '어떤 두려움이 당신을 지배하나요?']),
    19: TarotCardInfo(
      id: 19,
      name: '태양 (The Sun)',
      keywords: ['성공', '활력', '기쁨', '성취'],
      uprightMeaning: '성공과 성취, 활력과 기쁨, 긍정적 에너지',
      reversedMeaning: '일시적 좌절, 과도한 낙관, 자만',
      element: '불',
      astrology: '태양',
      numerology: 19,
      imagery: '빛나는 태양, 아이와 말, 해바라기',
      advice: '당신의 빛을 세상과 나누세요',
      questions: [
        '무엇이 당신을 행복하게 하나요?',
        '어떤 성공을 축하해야 하나요?']),
    20: TarotCardInfo(
      id: 20,
      name: '심판 (Judgement)',
      keywords: ['부활', '각성', '용서', '재평가'],
      uprightMeaning: '영적 각성, 과거의 정리, 새로운 시작',
      reversedMeaning: '자기 비판, 용서 부족, 과거에 매임',
      element: '불',
      astrology: '명왕성',
      numerology: 20,
      imagery: '천사의 나팔, 부활하는 사람들, 깃발',
      advice: '과거를 용서하고 새롭게 태어나세요',
      questions: [
        '무엇을 용서해야 하나요?',
        '어떤 부름을 받고 있나요?']),
    21: TarotCardInfo(
      id: 21,
      name: '세계 (The World)',
      keywords: ['완성', '성취', '통합', '전체성'],
      uprightMeaning: '완성과 성취, 한 주기의 완료, 조화와 통합',
      reversedMeaning: '미완성, 지연, 외적 성공 내적 공허',
      element: '땅',
      astrology: '토성',
      numerology: 21,
      imagery: '월계관 속의 춤추는 인물, 네 생명체',
      advice: '성취를 축하하고 새로운 여정을 준비하세요',
      questions: [
        '무엇을 완성했나요?',
        '다음 여정은 무엇인가요?']),
    };

  // 모든 타로 카드를 하나의 맵으로 통합 (78장)
  static Map<int, TarotCardInfo> get allCards {
    final Map<int, TarotCardInfo> cards = {};
    
    // Major Arcana 추가
    cards.addAll(majorArcana);
    
    // Minor Arcana 추가 - 임시로 참조하기 위해 동적 import
    // 실제 구현시 TarotMinorArcana 클래스의 카드들을 여기에 직접 추가
    
    return cards;
  }

  // 카드 정보 가져오기
  static TarotCardInfo? getCard(int cardIndex) {
    if (cardIndex < 0 || cardIndex >= 78) return null;
    
    // Major Arcana (0-21)
    if (cardIndex < 22) {
      return majorArcana[cardIndex];
    }
    
    // Minor Arcana는 별도 파일에서 관리하므로 null 반환
    // 실제 사용시 TarotMinorArcana 클래스와 통합 필요
    return null;
  }

  // 슈트별 카드 가져오기
  static List<TarotCardInfo> getCardsBySuit(String suit) {
    final List<TarotCardInfo> cards = [];
    
    // Major Arcana에서 원소별로 필터링
    if (suit == 'major') {
      cards.addAll(majorArcana.values);
    }
    
    return cards;
  }

  // 타로 스프레드 종류
  static const Map<String, TarotSpread> spreads = {
    'single': TarotSpread(
      name: '원 카드 리딩',
      description: '오늘의 메시지나 즉각적인 통찰',
      cardCount: 1,
      positions: ['현재 상황/오늘의 메시지'],
      layout: SpreadLayout.single,
      soulCost: 1),
    'three': TarotSpread(
      name: '쓰리 카드 스프레드',
      description: '과거-현재-미래 또는 상황-행동-결과',
      cardCount: 3,
      positions: ['과거/상황', '현재/행동', '미래/결과'],
      layout: SpreadLayout.horizontal,
      soulCost: 3),
    'celtic': TarotSpread(
      name: '켈틱 크로스',
      description: '가장 상세한 10장 스프레드',
      cardCount: 10,
      positions: [
        '현재 상황',
        '도전/십자가',
        '먼 과거/기초',
        '최근 과거',
        '가능한 미래',
        '가까운 미래',
        '당신의 접근',
        '외부 영향',
        '희망과 두려움',
        '최종 결과'],
      layout: SpreadLayout.celticCross,
      soulCost: 5),
    'relationship': TarotSpread(
      name: '관계 스프레드',
      description: '두 사람 사이의 관계 분석',
      cardCount: 7,
      positions: [
        '나의 감정',
        '상대의 감정',
        '관계의 기초',
        '나의 도전',
        '상대의 도전',
        '관계의 잠재력',
        '조언'],
      layout: SpreadLayout.relationship,
      soulCost: 4),
    'career': TarotSpread(
      name: '경력 스프레드',
      description: '직업과 경력에 대한 통찰',
      cardCount: 5,
      positions: [
        '현재 직업 상황',
        '숨겨진 영향',
        '조언',
        '예상되는 도전',
        '잠재적 결과'],
      layout: SpreadLayout.pyramid,
      soulCost: 3),
    'decision': TarotSpread(
      name: '결정 스프레드',
      description: '중요한 선택을 위한 가이드',
      cardCount: 7,
      positions: [
        '현재 상황',
        '선택지 1',
        '선택지 1의 결과',
        '선택지 2',
        '선택지 2의 결과',
        '중요한 요소',
        '최종 조언'],
      layout: SpreadLayout.decision,
      soulCost: 4),
    'year': TarotSpread(
      name: '연간 스프레드',
      description: '12개월 전망',
      cardCount: 12,
      positions: [
        '1월', '2월', '3월', '4월', '5월', '6월',
        '7월', '8월', '9월', '10월', '11월', '12월'],
      layout: SpreadLayout.circle,
      soulCost: 5),
    'chakra': TarotSpread(
      name: '차크라 스프레드',
      description: '7개 차크라 에너지 상태',
      cardCount: 7,
      positions: [
        '루트 차크라 (생존)',
        '천골 차크라 (감정)',
        '태양신경총 차크라 (의지)',
        '하트 차크라 (사랑)',
        '목 차크라 (소통)',
        '제3의 눈 차크라 (직관)',
        '크라운 차크라 (영성)'],
      layout: SpreadLayout.vertical,
      soulCost: 4)
  };

  // 카드 해석 깊이 레벨
  static const Map<String, InterpretationDepth> interpretationLevels = {
    'basic': InterpretationDepth(
      name: '기본 해석',
      includeReversed: false,
      includeElemental: false,
      includeNumerology: false,
      includeAstrology: false,
      detailLevel: 1),
    'standard': InterpretationDepth(
      name: '표준 해석',
      includeReversed: true,
      includeElemental: true,
      includeNumerology: false,
      includeAstrology: false,
      detailLevel: 2),
    'advanced': InterpretationDepth(
      name: '심화 해석',
      includeReversed: true,
      includeElemental: true,
      includeNumerology: true,
      includeAstrology: true,
      detailLevel: 3)};

  // 카드 조합 의미
  static const Map<String, CardCombination> significantCombinations = {
    'tower_death': CardCombination(
      cards: ['The Tower', 'Death'],
      meaning: '급격한 변화와 변혁의 시기, 과거와의 완전한 단절',
      advice: '변화를 받아들이고 새로운 시작을 준비하세요'),
    'lovers_twocups': CardCombination(
      cards: ['The Lovers', 'Two of Cups'],
      meaning: '깊은 사랑과 조화로운 관계의 시작',
      advice: '마음을 열고 진정한 연결을 만들어가세요'),
    // ... 더 많은 조합들
  };
}

