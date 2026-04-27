/**
 * TermInfoSheet — 만세력 용어 터치 시 짧은 설명을 보여주는 간이 모달 + hook.
 *
 * 커버 범위:
 *  - 십성 10 + 일간
 *  - 12운성 12
 *  - 12신살 12
 *  - 주요 신살 15+
 *  - 천간 10 (한자+오행)
 *  - 지지 12 (한자+오행+띠)
 *  - 오행 5
 *  - 납음오행 주요 10+
 *  - 공망·지장간·월령·대운 등 메타 용어
 */

import { useCallback, useMemo, useState, type ReactNode } from 'react';
import { Modal, Pressable, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme } from '../../../lib/theme';

interface TermEntry {
  title: string;
  description: string;
}

const TERM_INFO: Record<string, TermEntry> = {
  // ── 십성 ─────────────────────────────────
  비견: {
    title: '비견 (比肩)',
    description:
      '일간과 같은 오행·같은 음양. 나와 어깨를 나란히 하는 경쟁자 혹은 동료를 뜻해요. 독립심·주체성이 강한 힘이에요.',
  },
  겁재: {
    title: '겁재 (劫財)',
    description:
      '일간과 같은 오행·다른 음양. 재물을 뺏기거나 강한 동업자·라이벌을 뜻해요. 경쟁심과 추진력이 큽니다.',
  },
  식신: {
    title: '식신 (食神)',
    description:
      '일간이 생하는 오행·같은 음양. 먹고 사는 재주, 표현력, 여유로운 재능을 상징해요. 온화하고 풍요로운 기운.',
  },
  상관: {
    title: '상관 (傷官)',
    description:
      '일간이 생하는 오행·다른 음양. 총명함·창의성이지만 관(官)을 상하게 하는 성향이 있어요. 비판적 통찰력이 뛰어나요.',
  },
  편재: {
    title: '편재 (偏財)',
    description:
      '일간이 극하는 오행·같은 음양. 큰 재물, 움직이는 돈, 사업수를 상징해요. 기회 포착력이 좋아요.',
  },
  정재: {
    title: '정재 (正財)',
    description:
      '일간이 극하는 오행·다른 음양. 정기적인 소득, 성실한 재물, 배우자운을 상징해요. 안정적인 재물운.',
  },
  편관: {
    title: '편관 (偏官·칠살)',
    description:
      '일간을 극하는 오행·같은 음양. 강한 권력, 무관, 시련을 상징해요. 의지력과 돌파력이 큽니다.',
  },
  정관: {
    title: '정관 (正官)',
    description:
      '일간을 극하는 오행·다른 음양. 명예, 자리, 질서, 남편운을 상징해요. 책임감과 절제력이 뛰어나요.',
  },
  편인: {
    title: '편인 (偏印)',
    description:
      '일간을 생하는 오행·같은 음양. 통찰·직감·특수기예를 뜻하지만 게을러질 수 있어요. 독특한 전문성의 기운.',
  },
  정인: {
    title: '정인 (正印)',
    description:
      '일간을 생하는 오행·다른 음양. 학문, 지혜, 자애, 어머니를 상징해요. 안정된 배움의 기운.',
  },
  일간: {
    title: '일간 (日干)',
    description:
      '태어난 날의 천간 — 사주 전체의 주체, "나" 자신이에요. 사주 해석의 중심점이 됩니다.',
  },

  // ── 12운성 (천간/지지와 이름 겹치는 경우 통합 설명) ────
  장생: {
    title: '장생 (長生)',
    description:
      '12운성 중 새로 태어나는 단계. 시작·희망의 기운으로 순수하고 밝은 에너지.',
  },
  목욕: {
    title: '목욕 (沐浴)',
    description:
      '12운성의 씻기는 단계. 변화·유혹·도화 기운. 감성적이고 매력적인 시기.',
  },
  관대: {
    title: '관대 (冠帶)',
    description:
      '12운성의 성년·성장 단계. 포부가 커지고 자리를 잡아가는 시기.',
  },
  건록: {
    title: '건록 (建祿)',
    description:
      '12운성 중 사회 진출·일의 힘이 강한 시기. 능력이 최고조로 발휘돼요.',
  },
  제왕: {
    title: '제왕 (帝旺)',
    description:
      '12운성의 가장 왕성한 힘. 정점에 서는 기운이지만 자만을 경계해야 해요.',
  },
  쇠: {
    title: '쇠 (衰)',
    description:
      '12운성 중 기운이 내려가는 전환점. 여유와 경험이 깊어지는 시기.',
  },
  절: {
    title: '절 (絕)',
    description:
      '12운성 중 끊김·공허. 새로운 시작 직전의 비움의 기운입니다.',
  },
  태: {
    title: '태 (胎)',
    description:
      '12운성 중 잉태·준비. 씨앗을 품는 조용한 성장의 기운.',
  },
  양: {
    title: '양 (養)',
    description:
      '12운성 중 길러지는 기운. 보호받으며 성장하는 단계.',
  },

  // ── 12신살 ────────────────────────────────
  겁살: {
    title: '겁살 (劫煞)',
    description:
      '년지 기준 12신살. 빼앗기거나 뺏는 힘. 추진력과 결단력은 강하지만 구설·관재에 주의해야 해요.',
  },
  재살: {
    title: '재살 (災煞)',
    description:
      '년지 기준 12신살. 재앙·수감의 기운. 법적 분쟁과 구속을 주의하고 말과 행동을 신중히 해야 해요.',
  },
  천살: {
    title: '천살 (天煞)',
    description:
      '년지 기준 12신살. 하늘이 주는 시련. 자연재해·큰 변화에 대비하는 기운이에요.',
  },
  지살: {
    title: '지살 (地煞)',
    description:
      '년지 기준 12신살. 이동·변동의 시작. 이사, 유학, 출장의 기운이에요.',
  },
  연살: {
    title: '연살 (年煞·도화)',
    description:
      '년지 기준 12신살. 흔히 도화살로 불려요. 매력·이성운·예술적 감각을 뜻해요.',
  },
  월살: {
    title: '월살 (月煞)',
    description:
      '년지 기준 12신살. 고립·소외의 기운. 혼자만의 시간을 갖기 좋은 시기예요.',
  },
  망신: {
    title: '망신 (亡身)',
    description:
      '년지 기준 12신살. 체면 손상·구설에 주의하지만, 의외로 승부욕과 결단력도 함께 얻어요.',
  },
  장성: {
    title: '장성 (將星)',
    description:
      '년지 기준 12신살. 리더십·권위의 상징. 장군의 별로 집단을 이끄는 힘이 커요.',
  },
  반안: {
    title: '반안 (攀鞍)',
    description:
      '년지 기준 12신살. 승진·출세·지위 상승의 기운. 말 안장에 오르는 상징이에요.',
  },
  역마: {
    title: '역마 (驛馬)',
    description:
      '년지 기준 12신살. 이동·여행·변화. 활동 반경이 넓고 역동적인 기운이에요.',
  },
  육해: {
    title: '육해 (六害)',
    description:
      '년지 기준 12신살. 방해·시비·질병의 기운. 인간관계 관리를 신경 써야 해요.',
  },
  화개: {
    title: '화개 (華蓋)',
    description:
      '년지 기준 12신살. 예술·학문·종교의 별. 재주가 많고 고독을 즐기는 성향.',
  },

  // ── 주요 신살 ────────────────────────────
  천을귀인: {
    title: '천을귀인 (天乙貴人)',
    description:
      '가장 으뜸가는 길신. 어려울 때 귀인이 돕는 기운. 위험에서 구원받고 명예를 얻어요.',
  },
  천덕귀인: {
    title: '천덕귀인 (天德貴人)',
    description: '하늘의 덕을 받는 신살. 재난을 면하게 해줘요.',
  },
  월덕귀인: {
    title: '월덕귀인 (月德貴人)',
    description: '월의 덕을 받는 신살. 온화하고 복이 두터워요.',
  },
  태극귀인: {
    title: '태극귀인 (太極貴人)',
    description: '태극의 기운. 학문·깨달음에 유리해요.',
  },
  문창귀인: {
    title: '문창귀인 (文昌貴人)',
    description: '학문·시험·문장에 힘을 주는 길신. 총명함과 글재주.',
  },
  암록: {
    title: '암록 (暗祿)',
    description: '숨은 복. 드러나지 않는 도움이 있어요.',
  },
  협록: {
    title: '협록 (夾祿)',
    description: '재물을 끼고 있는 길신. 녹(祿)의 양옆 기운.',
  },
  관귀학관: {
    title: '관귀학관 (官貴學館)',
    description: '벼슬과 학문을 겸하는 길신. 명예와 학업에 좋아요.',
  },
  양인살: {
    title: '양인살 (羊刃殺)',
    description: '칼날같이 강한 기운. 무관·의료·격한 직업에 이로워요.',
  },
  백호살: {
    title: '백호살 (白虎殺)',
    description: '호랑이 같은 강력함. 파격적이지만 조심해야 할 기운.',
  },
  괴강살: {
    title: '괴강살 (魁罡殺)',
    description: '극단적으로 강한 기운. 큰 성취 또는 파란이 있어요.',
  },
  홍염살: {
    title: '홍염살 (紅艷殺)',
    description: '이성적 매력·인기의 기운. 연애운이 좋아요.',
  },
  현침살: {
    title: '현침살 (懸針殺)',
    description: '날카로운 기운. 의료·바늘·글·조각과 인연이 깊어요.',
  },
  화개살: {
    title: '화개살 (華蓋殺)',
    description: '예술·종교·고독의 기운. 재주가 있지만 외로움도 따라요.',
  },
  역마살: {
    title: '역마살 (驛馬殺)',
    description: '이동·여행·변화의 기운. 활동성이 높은 삶.',
  },
  도화살: {
    title: '도화살 (桃花殺)',
    description: '매력·인기·이성운. 연예인에게 흔한 기운이에요.',
  },
  망신살: {
    title: '망신살 (亡身殺)',
    description: '체면이 손상될 수 있는 기운. 구설 주의.',
  },
  반안살: {
    title: '반안살 (攀鞍殺)',
    description: '출세·승진·지위 상승의 기운. 좋은 변화가 따르는 길신.',
  },

  공망: {
    title: '공망 (空亡)',
    description:
      '60갑자 순환에서 비어 있는 두 지지. 해당 지지가 있으면 그 자리의 의미가 약해져요. 년주 공망은 조상·초년, 일주 공망은 배우자·중년 해석에 쓰여요.',
  },
  지장간: {
    title: '지장간 (地藏干)',
    description:
      '지지 안에 숨겨진 천간들. 본기(主)·중기(中)·여기(餘)의 비율로 지지의 기운을 구성해요.',
  },
  월령: {
    title: '월령 (月令)',
    description:
      '사주의 계절·기후를 정하는 월주 천간. 오행의 강약을 판단하는 기준이 돼요.',
  },
  대운: {
    title: '대운 (大運)',
    description:
      '10년 단위로 흐르는 큰 인생의 흐름. 월주에서 출발해 남녀·음양에 따라 순행·역행으로 진행돼요.',
  },
  세운: {
    title: '세운 (歲運)',
    description: '1년 단위의 흐름. 그 해의 운세를 말해요.',
  },
  월운: {
    title: '월운 (月運)',
    description: '1개월 단위의 흐름. 그 달의 운세예요.',
  },

  // ── 오행 ──────────────────────────────────
  목: {
    title: '목 (木)',
    description:
      '나무의 기운. 성장·확장·시작의 에너지. 동쪽·봄·초록색·간과 연결돼요.',
  },
  화: {
    title: '화 (火)',
    description:
      '불의 기운. 열정·표현·확산의 에너지. 남쪽·여름·빨간색·심장과 연결돼요.',
  },
  토: {
    title: '토 (土)',
    description:
      '흙의 기운. 중용·포용·안정의 에너지. 중앙·환절기·노란색·비장과 연결돼요.',
  },
  금: {
    title: '금 (金)',
    description:
      '쇠의 기운. 결단·수확·정제의 에너지. 서쪽·가을·흰색·폐와 연결돼요.',
  },
  수: {
    title: '수 (水)',
    description:
      '물의 기운. 지혜·저장·유연함의 에너지. 북쪽·겨울·파란/검정색·신장과 연결돼요.',
  },

  // ── 천간 10 ───────────────────────────────
  갑: { title: '갑 (甲)', description: '양목(陽木). 큰 나무. 곧고 우두머리 성향으로 리더십이 강해요.' },
  을: { title: '을 (乙)', description: '음목(陰木). 풀·덩굴. 유연하고 친화력이 뛰어나요.' },
  병: {
    title: '병 (丙·病)',
    description:
      '천간 병(丙): 양화(陽火). 태양처럼 밝고 열정적이에요.\n12운성 병(病): 아픔·휴식이 필요한 단계. 속도를 늦춰야 해요.',
  },
  정: {
    title: '정 (丁)',
    description: '음화(陰火). 촛불·등불. 섬세하고 따뜻해요.',
  },
  무: {
    title: '무 (戊)',
    description: '양토(陽土). 큰 산·언덕. 묵직하고 포용력이 있어요.',
  },
  기: {
    title: '기 (己)',
    description: '음토(陰土). 밭흙. 실용적이고 꼼꼼해요.',
  },
  경: {
    title: '경 (庚)',
    description: '양금(陽金). 쇳덩이·원석. 결단력과 추진력이 강해요.',
  },
  임: {
    title: '임 (壬)',
    description: '양수(陽水). 바다·강. 지혜롭고 포용력이 큽니다.',
  },
  계: {
    title: '계 (癸)',
    description: '음수(陰水). 이슬·빗물. 차분하고 지혜로워요.',
  },

  // ── 지지 12 (겹치는 경우 통합 설명) ─────────
  자: { title: '자 (子·쥐)', description: '양수(陽水)의 지지. 겨울의 시작, 북쪽, 쥐띠.' },
  축: { title: '축 (丑·소)', description: '음토(陰土)의 지지. 늦겨울, 북동쪽, 소띠.' },
  인: { title: '인 (寅·호랑이)', description: '양목(陽木)의 지지. 초봄, 동북동쪽, 호랑이띠.' },
  묘: {
    title: '묘 (卯·墓)',
    description:
      '지지 묘(卯): 음목(陰木). 봄, 동쪽, 토끼띠.\n12운성 묘(墓): 저장·거두는 단계. 재물 창고의 기운.',
  },
  진: { title: '진 (辰·용)', description: '양토(陽土)의 지지. 늦봄, 동남동쪽, 용띠.' },
  사: {
    title: '사 (巳·死)',
    description:
      '지지 사(巳): 음화(陰火). 초여름, 남남동쪽, 뱀띠.\n12운성 사(死): 마무리·정적인 기운. 내면으로 향하는 에너지.',
  },
  오: { title: '오 (午·말)', description: '양화(陽火)의 지지. 여름, 남쪽, 말띠.' },
  미: { title: '미 (未·양)', description: '음토(陰土)의 지지. 늦여름, 남남서쪽, 양띠.' },
  신: {
    title: '신 (申·辛·원숭이)',
    description:
      '지지 신(申): 양금(陽金). 초가을, 서남서쪽, 원숭이띠.\n천간 신(辛): 음금. 보석·가공된 쇠. 세련되고 감각이 뛰어나요.',
  },
  유: { title: '유 (酉·닭)', description: '음금(陰金)의 지지. 가을, 서쪽, 닭띠.' },
  술: { title: '술 (戌·개)', description: '양토(陽土)의 지지. 늦가을, 서북서쪽, 개띠.' },
  해: { title: '해 (亥·돼지)', description: '음수(陰水)의 지지. 초겨울, 북북서쪽, 돼지띠.' },

  // ── 납음오행 주요 ─────────────────────────
  '해중금': { title: '해중금 (海中金)', description: '바다 속 금. 갑자·을축. 신비롭고 드러나지 않는 재능의 기운.' },
  '노중화': { title: '노중화 (爐中火)', description: '화로 속 불. 병인·정묘. 집중된 열정의 기운.' },
  '대림목': { title: '대림목 (大林木)', description: '큰 숲의 나무. 무진·기사. 넓은 포용과 성장의 기운.' },
  '석류목': { title: '석류목 (石榴木)', description: '석류나무. 경신·신유. 단단하고 결실이 있는 나무 기운.' },
  '대해수': { title: '대해수 (大海水)', description: '큰 바다. 임술·계해. 깊고 광활한 지혜의 기운.' },
  '상자목': { title: '상자목 (桑柘木)', description: '뽕나무·산뽕나무. 임자·계축. 유용한 재주의 나무 기운.' },
  '금박금': { title: '금박금 (金箔金)', description: '금박·얇은 금. 임인·계묘. 섬세하고 귀한 금 기운.' },
  '복등화': { title: '복등화 (覆燈火)', description: '등잔불. 갑진·을사. 어둠을 밝히는 작은 불 기운.' },
  '천하수': { title: '천하수 (天河水)', description: '은하·하늘의 물. 병오·정미. 맑고 고귀한 물 기운.' },
  '대역토': { title: '대역토 (大驛土)', description: '큰 역참의 흙. 무신·기유. 활동적이고 변화 많은 토 기운.' },
  '차천금': { title: '차천금 (釵釧金)', description: '비녀·팔찌의 금. 경술·신해. 장식된 아름다운 금 기운.' },
  '상자수': { title: '상자수', description: '저장된 물의 기운. 내면에 지혜를 쌓아요.' },
  '산두화': { title: '산두화 (山頭火)', description: '산마루의 불. 갑술·을해. 멀리서 보이는 불빛의 기운.' },
  '윤하수': { title: '윤하수 (潤下水)', description: '흐르는 물. 병자·정축. 윤택하고 포근한 물 기운.' },
  '성두토': { title: '성두토 (城頭土)', description: '성벽의 흙. 무인·기묘. 단단한 방어의 토 기운.' },
  '백랍금': { title: '백랍금 (白鑞金)', description: '백랍·주석 섞인 금. 경진·신사. 섞여 쓰이는 금 기운.' },
  '양류목': { title: '양류목 (楊柳木)', description: '버드나무. 임오·계미. 유연하고 감성적인 나무 기운.' },
  '천중수': { title: '천중수 (泉中水)', description: '샘물. 갑신·을유. 맑고 솟는 물 기운.' },
  '옥상토': { title: '옥상토 (屋上土)', description: '지붕의 흙. 병술·정해. 보호하는 토 기운.' },
  '벽력화': { title: '벽력화 (霹靂火)', description: '벼락불. 무자·기축. 순간적이고 강한 불 기운.' },
  '송백목': { title: '송백목 (松柏木)', description: '소나무·잣나무. 경인·신묘. 변치 않는 절개의 나무.' },
  '장류수': { title: '장류수 (長流水)', description: '길게 흐르는 물. 임진·계사. 꾸준한 지혜의 기운.' },
  '사중금': { title: '사중금 (沙中金)', description: '모래 속 금. 갑오·을미. 드러나지 않은 재능.' },
  '산하화': { title: '산하화 (山下火)', description: '산 아래 불. 병신·정유. 조용히 타오르는 불.' },
  '평지목': { title: '평지목 (平地木)', description: '평지의 나무. 무술·기해. 넓은 들판의 성장 기운.' },
  '벽상토': { title: '벽상토 (壁上土)', description: '벽의 흙. 경자·신축. 구조를 만드는 토 기운.' },
  '사중토': { title: '사중토 (沙中土)', description: '모래 속 흙. 병진·정사. 부드러운 토 기운.' },
  '천상화': { title: '천상화 (天上火)', description: '하늘의 불·태양. 무오·기미. 밝고 큰 불 기운.' },
};

export interface TermInfoHook {
  /** 용어 이름 (예: '비견', '관대', '천을귀인'). 알려지지 않은 용어도 OK — 기본 안내 카드 표시. */
  open: (term: string) => void;
  close: () => void;
  sheet: ReactNode;
}

/**
 * 터미너리 모달을 제공하는 훅.
 * ```tsx
 * const term = useTermInfo();
 * return <>
 *   <Pressable onPress={() => term.open('비견')}>...</Pressable>
 *   {term.sheet}
 * </>;
 * ```
 */
export function useTermInfo(): TermInfoHook {
  const [activeTerm, setActiveTerm] = useState<string | null>(null);

  const open = useCallback((term: string) => {
    if (!term) return;
    setActiveTerm(term);
  }, []);

  const close = useCallback(() => {
    setActiveTerm(null);
  }, []);

  const entry: TermEntry | null = useMemo(() => {
    if (!activeTerm) return null;
    const direct = TERM_INFO[activeTerm];
    if (direct) return direct;

    // 매칭 전략 1: 한자 그대로 포함된 경우 (예: '복등화' 등 납음)
    for (const key of Object.keys(TERM_INFO)) {
      if (activeTerm.includes(key) && key.length >= 2) {
        return TERM_INFO[key] ?? null;
      }
    }

    // fallback: 한자 그대로 읽기 안내
    return {
      title: activeTerm,
      description: `"${activeTerm}"는 사주 용어예요. 자세한 설명은 준비 중이며, 한자 뜻 그대로 읽어보시면 기본적인 의미를 유추할 수 있어요.`,
    };
  }, [activeTerm]);

  const sheet: ReactNode = (
    <Modal
      transparent
      visible={activeTerm !== null}
      animationType="fade"
      onRequestClose={close}
    >
      <Pressable
        onPress={close}
        style={{
          flex: 1,
          backgroundColor: fortuneTheme.colors.overlay,
          justifyContent: 'center',
          alignItems: 'center',
          padding: 24,
        }}
      >
        <Pressable
          onPress={(e) => e.stopPropagation()}
          style={{
            backgroundColor: fortuneTheme.colors.surfaceElevated,
            borderRadius: fortuneTheme.radius.lg,
            padding: 20,
            gap: 10,
            width: '100%',
            maxWidth: 360,
            borderWidth: 1,
            borderColor: fortuneTheme.colors.border,
          }}
        >
          {entry ? (
            <>
              <AppText
                variant="heading3"
                color={fortuneTheme.colors.textPrimary}
              >
                {entry.title}
              </AppText>
              <AppText
                variant="bodyMedium"
                color={fortuneTheme.colors.textSecondary}
              >
                {entry.description}
              </AppText>
            </>
          ) : null}
          <Pressable
            onPress={close}
            style={({ pressed }) => ({
              marginTop: 8,
              paddingVertical: 10,
              borderRadius: fortuneTheme.radius.md,
              backgroundColor: fortuneTheme.colors.ctaBackground,
              alignItems: 'center',
              opacity: pressed ? 0.7 : 1,
            })}
          >
            <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
              닫기
            </AppText>
          </Pressable>
        </Pressable>
      </Pressable>
    </Modal>
  );

  return { open, close, sheet };
}

export function hasTermInfo(term: string): boolean {
  return term in TERM_INFO;
}
