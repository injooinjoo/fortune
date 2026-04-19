/**
 * Presence lines — 채팅 헤더 아래 "지금 뭐해..." 라인 생성기.
 *
 * 시간대 (6개: 새벽/아침/점심/오후/저녁/밤) × 감정 태그 (6개: 일상/애정/기쁨/고민/분노/당황)
 * = 36개 조합, 각 조합 2-3개 템플릿으로 총 ~90개 풀 확보.
 *
 * 모두 클라이언트 로직. LLM 호출 없음. 선택은 항상 랜덤.
 * 템플릿은 `${name}` 플레이스홀더 (있을 때만 치환) 지원.
 */

export type PresenceTimeBucket =
  | 'dawn' // 새벽 0-6
  | 'morning' // 아침 6-11
  | 'lunch' // 점심 11-14
  | 'afternoon' // 오후 14-18
  | 'evening' // 저녁 18-22
  | 'night'; // 밤 22-24

export type PresenceEmotion =
  | '일상'
  | '애정'
  | '기쁨'
  | '고민'
  | '분노'
  | '당황';

interface PresenceKeyInput {
  hour: number;
  emotionTag: string;
  characterName: string;
}

function resolveTimeBucket(hour: number): PresenceTimeBucket {
  const h = ((Math.floor(hour) % 24) + 24) % 24;
  if (h < 6) return 'dawn';
  if (h < 11) return 'morning';
  if (h < 14) return 'lunch';
  if (h < 18) return 'afternoon';
  if (h < 22) return 'evening';
  return 'night';
}

function resolveEmotion(tag: string): PresenceEmotion {
  switch (tag) {
    case '애정':
    case '기쁨':
    case '고민':
    case '분노':
    case '당황':
    case '일상':
      return tag;
    default:
      return '일상';
  }
}

type TemplatePool = Record<
  PresenceTimeBucket,
  Record<PresenceEmotion, readonly string[]>
>;

// Templates: Korean casual messenger tone. `${name}` is optional.
const PRESENCE_TEMPLATES: TemplatePool = {
  dawn: {
    일상: ['잠 안 와서 폰만 봐', '새벽 감성 몰려옴', '잠 깬 김에 물 마시는 중'],
    애정: ['네 생각하다 못 자', '이 시간에 네 생각남...', '꿈에서 너 봤어'],
    기쁨: ['새벽에 웃긴 거 발견함ㅋㅋ', '이런 거 혼자 보니 아깝다', '잠 깼는데 기분 좋네'],
    고민: ['잠이 안 온다', '머리 복잡해서 못 자겠어', '생각이 꼬리에 꼬리를 문다'],
    분노: ['아 짜증나서 잠이 안 와', '그 생각만 하면 속 터진다', '못 참겠다 진짜'],
    당황: ['어라 벌써 새벽?', '시간 언제 이렇게 감...', '어... 나 지금 뭐하고 있지'],
  },
  morning: {
    일상: ['커피 내리는 중', '알람 지금 껐어', '아침 먹으려고 일어남'],
    애정: ['일어나자마자 네 생각', '좋은 아침ㅎㅎ', '네가 먼저 떠오름'],
    기쁨: ['오늘 날씨 좋아!', '기분 좋게 출발', '상쾌하다 진짜'],
    고민: ['아침부터 머리 아파', '오늘 할 일 많네...', '일어나자마자 한숨'],
    분노: ['아침부터 기분 안 좋아', '출근하기 싫다 진심', '왜 이렇게 피곤함'],
    당황: ['지각이다ㅠ', '늦잠 자버림', '어 벌써 10시??'],
  },
  lunch: {
    일상: ['점심 뭐 먹지', '배고픔...', '밥 먹는 중'],
    애정: ['너랑 같이 먹고 싶어', '밥 먹었어? 네 생각나서', '점심 같이 먹을 사람 너뿐'],
    기쁨: ['밥 맛있다', '카페 가려고', '점심 메뉴 당첨!'],
    고민: ['뭐 먹을지 고민 중', '점심 입맛 없네', '메뉴 결정 장애 왔다'],
    분노: ['점심 메뉴 왜 이래', '줄 엄청 서있어 짜증', '배고픈데 다 맛없어 보임'],
    당황: ['어 점심 시간 지났네', '아직 안 먹었다니...', '배고픈데 뭐 할지 모름'],
  },
  afternoon: {
    일상: ['나른한 오후', '커피 한 잔 타는 중', '잠 깨려고 노력 중'],
    애정: ['지금 뭐해?ㅎ', '네 소식 궁금', '너랑 산책하고 싶다'],
    기쁨: ['햇빛 좋다', '산책 나갈까 고민 중', '오후 기분 완전 좋음'],
    고민: ['일이 안 끝나네', '머리가 안 돌아감', '답답한 오후...'],
    분노: ['오후부터 꼬인다', '왜 이렇게 안 풀리지', '조용히 열 받는 중'],
    당황: ['시간 왜 이렇게 빨라', '어 벌써 3시?', '뭐 하다 이렇게 됐지'],
  },
  evening: {
    일상: ['저녁 뭐 먹지', '퇴근하는 중', '하루 마무리 모드'],
    애정: ['보고 싶다ㅠ', '오늘 하루 어땠어?', '같이 저녁 먹고 싶네'],
    기쁨: ['오늘 재밌었다', '하루 잘 보냄!', '저녁 노을 예쁘다'],
    고민: ['저녁인데 기운 없네', '하루 너무 길었어', '생각이 많아지는 시간'],
    분노: ['하루 종일 피곤함', '저녁에 터지네 진짜', '오늘 너무 별로였다'],
    당황: ['벌써 저녁이야?', '하루 왜 이렇게 빨라', '어... 나 뭐 했지 오늘'],
  },
  night: {
    일상: ['씻고 누움', '핸드폰 보는 중', '잘 준비 중'],
    애정: ['네 생각 중...', '잠이 안 와', '자기 전에 생각났어'],
    기쁨: ['오늘 하루 좋았다', '잘 자기 전에 웃음ㅎㅎ', '내일이 더 기대됨'],
    고민: ['잠이 안 오네', '생각 많은 밤', '머리 좀 식혀야 해'],
    분노: ['오늘도 기분 별로', '잠이 안 와 짜증', '이불킥 하고 있음'],
    당황: ['벌써 자야 할 시간?', '시간 왜 이래', '어... 뭐 하다 새벽 됨'],
  },
};

/**
 * 시간/감정/캐릭터명을 받아 적절한 presence 라인을 반환.
 * - `${name}` 토큰은 characterName으로 치환 (비어있으면 빈 문자열로).
 * - 매 호출 랜덤 선택이므로 동일 입력이라도 결과 달라질 수 있음.
 */
export function pickPresenceLine(opts: PresenceKeyInput): string {
  const bucket = resolveTimeBucket(opts.hour);
  const emotion = resolveEmotion(opts.emotionTag);
  const pool = PRESENCE_TEMPLATES[bucket][emotion];
  const index = Math.floor(Math.random() * pool.length);
  const template = pool[index] ?? pool[0] ?? '...';
  const safeName = opts.characterName?.trim() ?? '';
  return template.replace(/\$\{name\}/g, safeName);
}

// 디버깅/테스트 편의용 내부 export
export const __PRESENCE_TEMPLATES_INTERNAL = PRESENCE_TEMPLATES;
