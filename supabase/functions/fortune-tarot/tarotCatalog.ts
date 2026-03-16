export type TarotArcana = 'major' | 'minor'

export type TarotCatalogEntry = {
  index: number
  cardId: string
  arcana: TarotArcana
  suit: string | null
  rank: number
  cardName: string
  cardNameKr: string
  keywords: string[]
  element: string
  uprightMeaning: string
  reversedMeaning: string
  loreSummary: string
  advice: string
  imagePath: string
}

type MajorCardDefinition = {
  slug: string
  name: string
  nameKr: string
  keywords: string[]
  element: string
  uprightMeaning: string
  reversedMeaning: string
  loreSummary: string
  advice: string
}

type MinorSuitDefinition = {
  englishName: string
  koreanName: string
  element: string
  keywords: string[]
  uprightTheme: string
  reversedTheme: string
  loreSummary: string
  advice: string
}

type MinorRankDefinition = {
  englishName: string
  koreanName: string
  keywords: string[]
  uprightMeaning: string
  reversedMeaning: string
}

const MAJOR_ARCANA: MajorCardDefinition[] = [
  {
    slug: 'fool',
    name: 'The Fool',
    nameKr: '바보',
    keywords: ['새로운 시작', '순수함', '모험'],
    element: '공기',
    uprightMeaning: '새로운 여정을 시작할 용기와 가능성을 보여줍니다.',
    reversedMeaning: '성급함이나 준비 부족을 점검하라는 메시지입니다.',
    loreSummary: '바보는 모든 여정의 출발점입니다. 미지의 세계로 한 걸음을 내딛는 순수한 영혼을 상징합니다.',
    advice: '낯선 시작을 두려워하지 말고, 무모함만 조심하며 움직여 보세요.',
  },
  {
    slug: 'magician',
    name: 'The Magician',
    nameKr: '마법사',
    keywords: ['의지력', '실현', '집중'],
    element: '공기',
    uprightMeaning: '이미 가진 능력으로 원하는 현실을 만들어갈 수 있습니다.',
    reversedMeaning: '재능 분산이나 과장된 자신감을 경계해야 합니다.',
    loreSummary: '마법사는 의지와 기술, 집중을 통해 가능성을 현실로 바꾸는 존재입니다.',
    advice: '지금 가진 도구와 자원을 흩뜨리지 말고 한 방향으로 집중하세요.',
  },
  {
    slug: 'high_priestess',
    name: 'The High Priestess',
    nameKr: '여사제',
    keywords: ['직관', '잠재의식', '신비'],
    element: '물',
    uprightMeaning: '겉으로 드러나지 않은 진실과 직관을 믿으라는 뜻입니다.',
    reversedMeaning: '감각을 무시하거나 혼란에 휩쓸릴 수 있음을 말합니다.',
    loreSummary: '여사제는 보이지 않는 흐름과 내면의 지혜를 읽는 카드입니다.',
    advice: '답을 서두르지 말고, 마음 깊은 곳의 반응을 먼저 살펴보세요.',
  },
  {
    slug: 'empress',
    name: 'The Empress',
    nameKr: '여황제',
    keywords: ['풍요', '창조', '양육'],
    element: '땅',
    uprightMeaning: '풍요와 성장, 관계의 따뜻한 돌봄이 커지는 흐름입니다.',
    reversedMeaning: '과보호나 창조적 정체를 점검할 필요가 있습니다.',
    loreSummary: '여황제는 자라나게 하는 힘, 관계와 현실을 풍요롭게 하는 에너지를 상징합니다.',
    advice: '돌봄과 창조의 힘을 믿되, 내 에너지 소모도 함께 관리하세요.',
  },
  {
    slug: 'emperor',
    name: 'The Emperor',
    nameKr: '황제',
    keywords: ['구조', '권위', '안정'],
    element: '불',
    uprightMeaning: '기준과 구조를 세워 흐름을 안정시키라는 뜻입니다.',
    reversedMeaning: '통제욕이나 완고함이 관계를 경직시킬 수 있습니다.',
    loreSummary: '황제는 질서, 기준, 책임 있는 리더십을 상징합니다.',
    advice: '감정에 휘둘리기보다 기준을 세우고 계획적으로 움직이세요.',
  },
  {
    slug: 'hierophant',
    name: 'The Hierophant',
    nameKr: '교황',
    keywords: ['전통', '배움', '신념'],
    element: '땅',
    uprightMeaning: '기본 원칙과 검증된 방식이 도움이 되는 흐름입니다.',
    reversedMeaning: '관성적 사고나 고정관념이 답을 막을 수 있습니다.',
    loreSummary: '교황은 전통, 학습, 공동체의 지혜를 전달하는 카드입니다.',
    advice: '지금은 기본기와 선배의 조언, 검증된 방법을 참고하세요.',
  },
  {
    slug: 'lovers',
    name: 'The Lovers',
    nameKr: '연인들',
    keywords: ['사랑', '선택', '조화'],
    element: '공기',
    uprightMeaning: '관계의 조화와 진심에 따른 선택이 중요한 시점입니다.',
    reversedMeaning: '가치관 충돌이나 관계의 어긋남을 정리해야 할 수 있습니다.',
    loreSummary: '연인들은 사랑뿐 아니라, 진심과 가치관이 만나는 선택의 순간을 상징합니다.',
    advice: '좋아 보이는 답보다, 오래 유지할 수 있는 진심의 방향을 택하세요.',
  },
  {
    slug: 'chariot',
    name: 'The Chariot',
    nameKr: '전차',
    keywords: ['전진', '승리', '결단'],
    element: '물',
    uprightMeaning: '의지를 모아 한 방향으로 강하게 전진할 수 있습니다.',
    reversedMeaning: '과속하거나 방향을 잃기 쉬운 시기일 수 있습니다.',
    loreSummary: '전차는 상반된 힘을 통제하며 앞으로 나아가는 추진력의 카드입니다.',
    advice: '흔들리는 요소를 먼저 정리하고, 한 번 정한 방향은 단단히 밀어보세요.',
  },
  {
    slug: 'strength',
    name: 'Strength',
    nameKr: '힘',
    keywords: ['인내', '용기', '내면의 힘'],
    element: '불',
    uprightMeaning: '부드럽지만 강한 태도로 상황을 다룰 수 있습니다.',
    reversedMeaning: '자기 의심이나 감정 과열을 다스릴 필요가 있습니다.',
    loreSummary: '힘 카드는 강압보다 인내와 부드러운 통제가 더 큰 힘이 된다는 뜻입니다.',
    advice: '강하게 밀기보다 오래 버틸 수 있는 태도를 선택하세요.',
  },
  {
    slug: 'hermit',
    name: 'The Hermit',
    nameKr: '은둔자',
    keywords: ['성찰', '지혜', '고독'],
    element: '땅',
    uprightMeaning: '잠시 속도를 줄이고 내면의 답을 찾아야 하는 흐름입니다.',
    reversedMeaning: '고립이나 지나친 회피에 빠질 수 있음을 뜻합니다.',
    loreSummary: '은둔자는 바깥의 소음에서 벗어나 스스로의 빛을 찾는 카드입니다.',
    advice: '답을 밖에서만 찾지 말고, 혼자 정리하는 시간을 확보해 보세요.',
  },
  {
    slug: 'wheel_of_fortune',
    name: 'Wheel of Fortune',
    nameKr: '운명의 수레바퀴',
    keywords: ['변화', '순환', '전환점'],
    element: '불',
    uprightMeaning: '흐름이 바뀌는 전환점에 가까워졌다는 신호입니다.',
    reversedMeaning: '변화를 거부하면 같은 문제가 반복될 수 있습니다.',
    loreSummary: '운명의 수레바퀴는 통제 바깥의 흐름과 커다란 변곡점을 상징합니다.',
    advice: '모든 것을 붙잡으려 하기보다, 바뀌는 흐름을 읽고 올라타세요.',
  },
  {
    slug: 'justice',
    name: 'Justice',
    nameKr: '정의',
    keywords: ['균형', '책임', '진실'],
    element: '공기',
    uprightMeaning: '공정한 판단과 책임 있는 선택이 중요한 순간입니다.',
    reversedMeaning: '편향된 판단이나 책임 회피가 문제를 키울 수 있습니다.',
    loreSummary: '정의는 인과와 균형, 냉정한 판단을 상징합니다.',
    advice: '마음이 흔들릴수록 기준과 사실을 다시 확인하세요.',
  },
  {
    slug: 'hanged_man',
    name: 'The Hanged Man',
    nameKr: '매달린 사람',
    keywords: ['관점 전환', '멈춤', '수용'],
    element: '물',
    uprightMeaning: '지금은 밀어붙이기보다 시각을 바꾸는 것이 답입니다.',
    reversedMeaning: '정체감이 길어지거나 의미 없는 버팀이 될 수 있습니다.',
    loreSummary: '매달린 사람은 멈춤을 통해 새로운 관점을 얻게 되는 카드입니다.',
    advice: '답이 안 보이면 속도를 높이지 말고, 보는 방식을 바꿔 보세요.',
  },
  {
    slug: 'death',
    name: 'Death',
    nameKr: '죽음',
    keywords: ['종료', '변화', '재탄생'],
    element: '물',
    uprightMeaning: '끝내야 할 것을 정리할 때 다음 국면이 열립니다.',
    reversedMeaning: '변화를 미루면 더 무거운 방식으로 정리가 들어올 수 있습니다.',
    loreSummary: '죽음 카드는 파괴가 아니라, 한 주기의 종료와 재탄생을 뜻합니다.',
    advice: '놓아야 할 것을 분명히 정리해야 다음 흐름이 들어옵니다.',
  },
  {
    slug: 'temperance',
    name: 'Temperance',
    nameKr: '절제',
    keywords: ['균형', '조화', '조율'],
    element: '불',
    uprightMeaning: '서로 다른 요소를 조율해 안정된 흐름을 만들 수 있습니다.',
    reversedMeaning: '극단으로 치우치면 에너지 소모가 커질 수 있습니다.',
    loreSummary: '절제는 서로 다른 흐름을 섞어 균형을 만드는 카드입니다.',
    advice: '조금 느리더라도 균형을 맞춘 선택이 결국 더 멀리 갑니다.',
  },
  {
    slug: 'devil',
    name: 'The Devil',
    nameKr: '악마',
    keywords: ['집착', '속박', '유혹'],
    element: '땅',
    uprightMeaning: '불안, 집착, 물질적 압박이 선택을 흔들 수 있습니다.',
    reversedMeaning: '속박에서 벗어날 틈과 회복의 신호가 보입니다.',
    loreSummary: '악마는 외부가 아니라 내가 붙잡고 있는 두려움과 집착을 비추는 카드입니다.',
    advice: '내가 놓지 못하는 것이 무엇인지 정확히 보아야 벗어날 수 있습니다.',
  },
  {
    slug: 'tower',
    name: 'The Tower',
    nameKr: '탑',
    keywords: ['붕괴', '각성', '급변'],
    element: '불',
    uprightMeaning: '갑작스러운 변화가 기존 구조를 흔들 수 있습니다.',
    reversedMeaning: '변화의 충격을 줄일 기회가 아직 남아 있을 수 있습니다.',
    loreSummary: '탑은 무너짐을 통해 진실을 드러내는 급격한 전환의 카드입니다.',
    advice: '지켜야 할 것과 버려야 할 것을 빨리 구분하면 회복이 빨라집니다.',
  },
  {
    slug: 'star',
    name: 'The Star',
    nameKr: '별',
    keywords: ['희망', '치유', '영감'],
    element: '공기',
    uprightMeaning: '회복과 희망, 미래를 다시 믿게 되는 흐름입니다.',
    reversedMeaning: '낙담이 길어질 수 있으나 빛은 아직 꺼지지 않았습니다.',
    loreSummary: '별은 상처 뒤에 다시 찾아오는 희망과 회복의 카드를 뜻합니다.',
    advice: '조급하게 결론 내리지 말고, 회복되는 흐름을 천천히 믿어 보세요.',
  },
  {
    slug: 'moon',
    name: 'The Moon',
    nameKr: '달',
    keywords: ['불안', '환상', '직관'],
    element: '물',
    uprightMeaning: '불확실함 속에서도 감각이 예민하게 반응하는 시기입니다.',
    reversedMeaning: '혼란이 걷히고 흐릿했던 것들이 분명해질 수 있습니다.',
    loreSummary: '달은 불안과 환상, 잠재의식의 파도를 비추는 카드입니다.',
    advice: '확신이 서지 않는다면 결정을 서두르지 말고, 사실 확인을 먼저 하세요.',
  },
  {
    slug: 'sun',
    name: 'The Sun',
    nameKr: '태양',
    keywords: ['성공', '활력', '명확함'],
    element: '불',
    uprightMeaning: '상황이 밝아지고 결과가 또렷해지는 좋은 흐름입니다.',
    reversedMeaning: '좋은 흐름 안에서도 과신은 줄이는 편이 안전합니다.',
    loreSummary: '태양은 성취, 확신, 건강한 에너지와 환한 전망을 뜻합니다.',
    advice: '지금의 자신감은 살리되, 너무 앞서 나가지 않도록 속도만 조절하세요.',
  },
  {
    slug: 'judgement',
    name: 'Judgement',
    nameKr: '심판',
    keywords: ['각성', '재평가', '부름'],
    element: '불',
    uprightMeaning: '과거를 정리하고 새로운 기준으로 올라설 시기입니다.',
    reversedMeaning: '자기비판이나 과거 집착이 발목을 잡을 수 있습니다.',
    loreSummary: '심판은 다시 바라보기, 용서, 새로운 부름을 상징하는 카드입니다.',
    advice: '후회에 머물기보다 지금 다시 선택할 수 있는 것을 보세요.',
  },
  {
    slug: 'world',
    name: 'The World',
    nameKr: '세계',
    keywords: ['완성', '통합', '성취'],
    element: '땅',
    uprightMeaning: '한 흐름이 잘 마무리되며 성취와 통합이 따라옵니다.',
    reversedMeaning: '거의 다 왔지만 마무리 정리가 더 필요할 수 있습니다.',
    loreSummary: '세계는 여정의 완성과 다음 장으로 넘어가기 직전의 충만함을 뜻합니다.',
    advice: '지금까지 쌓은 것을 인정하고, 남은 마무리를 깔끔하게 끝내세요.',
  },
]

const MINOR_SUIT_DATA: Record<string, MinorSuitDefinition> = {
  cups: {
    englishName: 'Cups',
    koreanName: '컵',
    element: '물',
    keywords: ['감정', '관계', '공감'],
    uprightTheme: '감정의 흐름과 관계의 교류가 열려 있어요.',
    reversedTheme: '감정의 정리와 거리 조절이 필요한 흐름이에요.',
    loreSummary: '컵 슈트는 감정, 사랑, 관계, 직관의 흐름을 다룹니다.',
    advice: '마음의 반응을 억누르기보다 이유를 차분히 읽어보세요.',
  },
  wands: {
    englishName: 'Wands',
    koreanName: '완드',
    element: '불',
    keywords: ['열정', '행동', '추진력'],
    uprightTheme: '행동력과 추진력이 살아나는 국면이에요.',
    reversedTheme: '조급함을 낮추고 방향을 다시 맞출 때예요.',
    loreSummary: '완드 슈트는 열정, 추진력, 창조적 에너지와 도전을 다룹니다.',
    advice: '속도를 살리되, 목표와 방향을 먼저 선명하게 잡아두세요.',
  },
  swords: {
    englishName: 'Swords',
    koreanName: '소드',
    element: '공기',
    keywords: ['사고', '판단', '소통'],
    uprightTheme: '판단과 결단, 명료한 시선이 필요한 때예요.',
    reversedTheme: '과한 생각을 덜고 핵심만 남겨야 할 흐름이에요.',
    loreSummary: '소드 슈트는 생각, 언어, 갈등, 판단과 진실을 다룹니다.',
    advice: '사실과 감정을 나눠 정리하면 흐름이 한층 선명해집니다.',
  },
  pentacles: {
    englishName: 'Pentacles',
    koreanName: '펜타클',
    element: '땅',
    keywords: ['현실', '자원', '안정'],
    uprightTheme: '현실 감각과 안정적인 기반이 중요한 흐름이에요.',
    reversedTheme: '지출과 에너지 배분을 다시 점검해야 할 시기예요.',
    loreSummary: '펜타클 슈트는 돈, 일, 건강, 일상의 기반과 실질적 결과를 다룹니다.',
    advice: '현실적인 단위로 쪼개서 실행하면 안정감이 커집니다.',
  },
}

const MINOR_RANK_DATA: Record<number, MinorRankDefinition> = {
  1: {
    englishName: 'Ace',
    koreanName: '에이스',
    keywords: ['시작', '씨앗', '기회'],
    uprightMeaning: '새로운 가능성과 첫 신호가 열리는 카드예요.',
    reversedMeaning: '시작의 에너지가 막히거나 타이밍이 어긋날 수 있어요.',
  },
  2: {
    englishName: 'Two',
    koreanName: '2',
    keywords: ['균형', '선택', '조율'],
    uprightMeaning: '두 흐름을 조율하며 균형을 잡아야 하는 카드예요.',
    reversedMeaning: '우선순위가 흔들리거나 선택 피로가 커질 수 있어요.',
  },
  3: {
    englishName: 'Three',
    koreanName: '3',
    keywords: ['전개', '협력', '성장'],
    uprightMeaning: '흐름이 본격적으로 전개되고 협력이 붙는 카드예요.',
    reversedMeaning: '협업의 호흡이 어긋나거나 성장 속도가 더딜 수 있어요.',
  },
  4: {
    englishName: 'Four',
    koreanName: '4',
    keywords: ['안정', '보호', '유지'],
    uprightMeaning: '기반을 다지고 안정감을 확보해야 하는 카드예요.',
    reversedMeaning: '안정을 지키려는 마음이 흐름을 막을 수 있어요.',
  },
  5: {
    englishName: 'Five',
    koreanName: '5',
    keywords: ['변화', '긴장', '시험'],
    uprightMeaning: '불편함과 충돌 속에서 방향을 다시 잡아야 하는 카드예요.',
    reversedMeaning: '갈등이 잦아들지만 핵심 문제는 남아 있을 수 있어요.',
  },
  6: {
    englishName: 'Six',
    koreanName: '6',
    keywords: ['회복', '조화', '이동'],
    uprightMeaning: '흐름이 회복되고 부드럽게 연결되기 시작하는 카드예요.',
    reversedMeaning: '회복이 늦어지거나 정리되지 않은 감정이 남아 있을 수 있어요.',
  },
  7: {
    englishName: 'Seven',
    koreanName: '7',
    keywords: ['점검', '도전', '집중'],
    uprightMeaning: '지금까지의 흐름을 점검하고 버텨내야 하는 카드예요.',
    reversedMeaning: '불안과 분산으로 중심이 흔들릴 수 있어요.',
  },
  8: {
    englishName: 'Eight',
    koreanName: '8',
    keywords: ['가속', '숙련', '전환'],
    uprightMeaning: '속도가 붙거나 숙련도가 올라가는 카드예요.',
    reversedMeaning: '과속, 집착, 피로 누적으로 흐름이 꼬일 수 있어요.',
  },
  9: {
    englishName: 'Nine',
    koreanName: '9',
    keywords: ['완성 직전', '성숙', '수확'],
    uprightMeaning: '성과가 가까워졌고 자신감을 회복하는 카드예요.',
    reversedMeaning: '막바지 피로감이나 불안으로 힘이 빠질 수 있어요.',
  },
  10: {
    englishName: 'Ten',
    koreanName: '10',
    keywords: ['완결', '정점', '정리'],
    uprightMeaning: '한 흐름의 정점 또는 마무리를 보여주는 카드예요.',
    reversedMeaning: '끝내야 할 것을 놓지 못해 무게가 커질 수 있어요.',
  },
  11: {
    englishName: 'Page',
    koreanName: '시종',
    keywords: ['메시지', '호기심', '초심'],
    uprightMeaning: '새 소식, 배움, 작은 시도가 들어오는 카드예요.',
    reversedMeaning: '미숙함이나 소통 실수로 흐름이 어긋날 수 있어요.',
  },
  12: {
    englishName: 'Knight',
    koreanName: '기사',
    keywords: ['추진', '움직임', '집중'],
    uprightMeaning: '목표를 향해 강하게 움직이는 추진력이 들어오는 카드예요.',
    reversedMeaning: '성급함, 과열, 방향 상실을 경계해야 하는 카드예요.',
  },
  13: {
    englishName: 'Queen',
    koreanName: '여왕',
    keywords: ['성숙', '돌봄', '직관'],
    uprightMeaning: '내면의 안정과 성숙한 리더십이 드러나는 카드예요.',
    reversedMeaning: '예민함, 과보호, 감정 기복이 커질 수 있어요.',
  },
  14: {
    englishName: 'King',
    koreanName: '왕',
    keywords: ['통제', '책임', '완성도'],
    uprightMeaning: '구조를 잡고 결과를 이끌 힘이 커지는 카드예요.',
    reversedMeaning: '통제욕, 완고함, 책임 부담이 커질 수 있어요.',
  },
}

const TAROT_DECK_DISPLAY_NAMES: Record<string, string> = {
  rider_waite: '라이더-웨이트-스미스',
  thoth: '토트 타로',
  ancient_italian: '고대 이탈리아 타로',
  before_tarot: '비포 타로',
  after_tarot: '애프터 타로',
  golden_dawn_cicero: '골든 던 매지컬 타로',
  golden_dawn_wang: '골든 던 타로',
  grand_etteilla: '그랑 에테이야',
}

export const AVAILABLE_TAROT_DECKS = Object.keys(TAROT_DECK_DISPLAY_NAMES)

export function getRandomDeck(): string {
  const randomIndex = Math.floor(Math.random() * AVAILABLE_TAROT_DECKS.length)
  return AVAILABLE_TAROT_DECKS[randomIndex]
}

export function getTarotDeckDisplayName(deckId: string): string {
  return TAROT_DECK_DISPLAY_NAMES[deckId] ?? '라이더-웨이트-스미스'
}

export function getTarotCardCatalogEntry(
  index: number,
  deckId: string = 'rider_waite'
): TarotCatalogEntry {
  if (index < 0 || index >= 78) {
    return buildMajorEntry(0, deckId)
  }

  if (index < 22) {
    return buildMajorEntry(index, deckId)
  }

  const minorIndex = index - 22
  const suitOrder = ['cups', 'wands', 'swords', 'pentacles']
  const suit = suitOrder[Math.floor(minorIndex / 14)]
  const rank = (minorIndex % 14) + 1
  return buildMinorEntry(index, suit, rank, deckId)
}

function buildMajorEntry(index: number, deckId: string): TarotCatalogEntry {
  const card = MAJOR_ARCANA[index]
  return {
    index,
    cardId: `major_${String(index).padStart(2, '0')}_${card.slug}`,
    arcana: 'major',
    suit: null,
    rank: index,
    cardName: card.name,
    cardNameKr: card.nameKr,
    keywords: card.keywords,
    element: card.element,
    uprightMeaning: card.uprightMeaning,
    reversedMeaning: card.reversedMeaning,
    loreSummary: card.loreSummary,
    advice: card.advice,
    imagePath: `assets/images/tarot/decks/${deckId}/major/${String(index).padStart(2, '0')}_${card.slug}.webp`,
  }
}

function buildMinorEntry(
  index: number,
  suit: string,
  rank: number,
  deckId: string
): TarotCatalogEntry {
  const suitData = MINOR_SUIT_DATA[suit]
  const rankData = MINOR_RANK_DATA[rank]
  const isCourt = rank >= 11
  const fileName = isCourt
    ? `${rankData.englishName.toLowerCase()}_of_${suit}.webp`
    : `${String(rank).padStart(2, '0')}_of_${suit}.webp`

  return {
    index,
    cardId: `${suit}_${String(rank).padStart(2, '0')}`,
    arcana: 'minor',
    suit,
    rank,
    cardName: `${rankData.englishName} of ${suitData.englishName}`,
    cardNameKr: `${suitData.koreanName} ${rankData.koreanName}`,
    keywords: [...new Set([...suitData.keywords, ...rankData.keywords])],
    element: suitData.element,
    uprightMeaning: `${rankData.uprightMeaning} ${suitData.uprightTheme}`,
    reversedMeaning: `${rankData.reversedMeaning} ${suitData.reversedTheme}`,
    loreSummary: `${suitData.koreanName} 슈트의 ${rankData.koreanName}는 ${suitData.loreSummary}`,
    advice: `${rankData.uprightMeaning} ${suitData.advice}`,
    imagePath: `assets/images/tarot/decks/${deckId}/${suit}/${fileName}`,
  }
}
