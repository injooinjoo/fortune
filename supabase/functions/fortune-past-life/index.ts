/**
 * 전생 운세 (Past Life Fortune) Edge Function V2
 *
 * @description 사용자의 전생 신분, 스토리, AI 초상화를 생성합니다.
 * V2: 얼굴 분석 → Gemini 이미지 생성, 30개 시나리오, 챕터 구조
 *
 * @endpoint POST /fortune-past-life
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name: string - 사용자 이름
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 생시 (선택)
 * - gender: string - 현재 성별
 * - isPremium?: boolean - 프리미엄 여부
 * - faceImageBase64?: string - 얼굴 사진 (Base64)
 * - useProfilePhoto?: boolean - 프로필 사진 사용 여부
 *
 * @response PastLifeFortuneResponse (with chapters)
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 신분 설정 (80개+ 확장)
interface StatusConfig {
  kr: string
  en: string
  desc: string
  clothing: string
  accessories: string
  category: string
  positiveTraits: string[]  // 긍정적 특성 풀
  scene: string  // 민화 스타일 장면 설명
}

const STATUS_CONFIGS: Record<string, StatusConfig> = {
  // ===== 1. 궁궐/관료 (15개) =====
  court_secretary: {
    kr: '승정원 서리',
    en: 'Royal Secretary',
    desc: 'a royal secretary handling confidential documents',
    clothing: 'formal court robes (관복) with official hat (사모), jade belt',
    accessories: 'royal documents, brush and ink, official seal',
    category: 'palace',
    positiveTraits: ['명석한', '충직한', '신뢰받는', '세심한'],
    scene: 'writing royal edicts with careful brushstrokes',
  },
  historian: {
    kr: '사관',
    en: 'Royal Historian',
    desc: 'a historian recording royal affairs',
    clothing: 'scholarly court attire, official hat',
    accessories: 'historical records, brush, ink stone',
    category: 'palace',
    positiveTraits: ['정직한', '용감한', '학식 높은', '원칙있는'],
    scene: 'recording history with unwavering integrity',
  },
  royal_physician: {
    kr: '내의원 의원',
    en: 'Royal Physician',
    desc: 'a physician serving the royal family',
    clothing: 'medical official robes, official hat',
    accessories: 'medicine box, acupuncture needles, medical texts',
    category: 'palace',
    positiveTraits: ['자비로운', '학식 높은', '헌신적인', '신중한'],
    scene: 'preparing herbal medicine with care',
  },
  eunuch: {
    kr: '내시',
    en: 'Court Eunuch',
    desc: 'a trusted court eunuch',
    clothing: 'court servant attire, small official hat',
    accessories: 'ceremonial whisk, palace keys',
    category: 'palace',
    positiveTraits: ['충성스러운', '신중한', '지혜로운', '인내심 강한'],
    scene: 'faithfully attending to royal duties',
  },
  court_lady: {
    kr: '궁녀',
    en: 'Court Lady',
    desc: 'an elegant court lady',
    clothing: 'palace hanbok in refined colors, neatly styled hair',
    accessories: 'ceremonial items, elegant ornaments',
    category: 'palace',
    positiveTraits: ['우아한', '총명한', '예의바른', '인내심 강한'],
    scene: 'gracefully performing palace duties',
  },
  head_chef: {
    kr: '수라간 상궁',
    en: 'Royal Kitchen Matron',
    desc: 'a head matron of royal kitchen',
    clothing: 'palace hanbok with apron, neat hairstyle',
    accessories: 'cooking utensils, recipe scrolls',
    category: 'palace',
    positiveTraits: ['숙련된', '세심한', '신뢰받는', '창의적인'],
    scene: 'preparing royal cuisine with expertise',
  },
  seamstress: {
    kr: '침선장',
    en: 'Royal Seamstress',
    desc: 'a master seamstress for royal garments',
    clothing: 'neat hanbok, simple hairstyle',
    accessories: 'silk threads, needles, fabric samples',
    category: 'palace',
    positiveTraits: ['정교한', '예술적인', '인내심 강한', '완벽주의자'],
    scene: 'embroidering royal robes with golden threads',
  },
  court_painter: {
    kr: '도화서 화원',
    en: 'Royal Court Painter',
    desc: 'a painter at the royal academy',
    clothing: 'scholarly robes, simple attire',
    accessories: 'brushes, ink, painting scrolls',
    category: 'palace',
    positiveTraits: ['재능 있는', '관찰력 뛰어난', '섬세한', '창의적인'],
    scene: 'painting landscapes with masterful brushwork',
  },
  portrait_painter: {
    kr: '어진 화가',
    en: 'Royal Portrait Painter',
    desc: 'a painter specializing in royal portraits',
    clothing: 'formal scholarly robes',
    accessories: 'fine brushes, mineral pigments, silk canvas',
    category: 'palace',
    positiveTraits: ['명망 높은', '섬세한', '존경받는', '완벽주의자'],
    scene: 'capturing royal dignity on silk',
  },
  garden_keeper: {
    kr: '원예관',
    en: 'Royal Garden Keeper',
    desc: 'a keeper of royal gardens',
    clothing: 'practical court attire',
    accessories: 'gardening tools, flower seeds, pruning shears',
    category: 'palace',
    positiveTraits: ['자연을 사랑하는', '인내심 강한', '세심한', '평화로운'],
    scene: 'tending beautiful palace gardens',
  },

  // ===== 2. 무사/군인 (12개) =====
  naval_commander: {
    kr: '수군 장수',
    en: 'Naval Commander',
    desc: 'a commander of naval forces',
    clothing: 'military robes with naval insignia, commander hat',
    accessories: 'sword, naval maps, command flag',
    category: 'military',
    positiveTraits: ['용맹한', '전략적인', '카리스마 있는', '충성스러운'],
    scene: 'commanding naval fleet with authority',
  },
  army_general: {
    kr: '육군 장군',
    en: 'Army General',
    desc: 'a heroic army general',
    clothing: 'ceremonial armor (갑옷), general helmet (투구)',
    accessories: 'sword, bow, military seal',
    category: 'military',
    positiveTraits: ['영웅적인', '용감한', '지략가', '존경받는'],
    scene: 'leading troops to victory',
  },
  royal_guard: {
    kr: '금위영 병사',
    en: 'Royal Guard',
    desc: 'an elite royal palace guard',
    clothing: 'royal guard uniform, helmet',
    accessories: 'spear, sword, shield',
    category: 'military',
    positiveTraits: ['충성스러운', '강인한', '명예로운', '경계심 강한'],
    scene: 'vigilantly protecting the palace',
  },
  gate_commander: {
    kr: '수문장',
    en: 'Gate Commander',
    desc: 'a commander guarding palace gates',
    clothing: 'formal military attire, commander hat',
    accessories: 'ceremonial weapon, gate keys',
    category: 'military',
    positiveTraits: ['위엄 있는', '책임감 강한', '신중한', '존경받는'],
    scene: 'standing guard at palace gates',
  },
  messenger: {
    kr: '파발',
    en: 'Royal Messenger',
    desc: 'a swift royal messenger',
    clothing: 'light travel clothes, messenger hat',
    accessories: 'message pouch, horse whip, signal flag',
    category: 'military',
    positiveTraits: ['신속한', '충성스러운', '용감한', '인내심 강한'],
    scene: 'riding swiftly with urgent messages',
  },
  secret_agent: {
    kr: '비밀 사자',
    en: 'Secret Envoy',
    desc: 'a covert royal agent',
    clothing: 'inconspicuous traveling clothes',
    accessories: 'hidden documents, secret seal',
    category: 'military',
    positiveTraits: ['지략가', '은밀한', '충성스러운', '용감한'],
    scene: 'carrying out secret royal missions',
  },
  bounty_hunter: {
    kr: '추노꾼',
    en: 'Bounty Hunter',
    desc: 'a skilled fugitive hunter',
    clothing: 'practical dark clothes, wide-brimmed hat',
    accessories: 'rope, tracking tools, warrant documents',
    category: 'military',
    positiveTraits: ['날카로운', '추적의 달인', '끈기 있는', '정의로운'],
    scene: 'tracking with keen instincts',
  },
  detective: {
    kr: '포도청 수사관',
    en: 'Police Detective',
    desc: 'a detective solving crimes',
    clothing: 'official investigator robes',
    accessories: 'investigation tools, arrest warrant',
    category: 'military',
    positiveTraits: ['통찰력 있는', '정의로운', '끈기 있는', '명석한'],
    scene: 'investigating cases with sharp mind',
  },
  master_archer: {
    kr: '명궁',
    en: 'Master Archer',
    desc: 'a legendary archer',
    clothing: 'archer uniform, arm guards',
    accessories: 'bow, quiver of arrows, archer ring',
    category: 'military',
    positiveTraits: ['백발백중', '집중력 강한', '전설적인', '명예로운'],
    scene: 'drawing bow with perfect form',
  },
  horse_trainer: {
    kr: '조련사',
    en: 'Horse Trainer',
    desc: 'a skilled horse trainer',
    clothing: 'practical riding clothes',
    accessories: 'horse whip, saddle, reins',
    category: 'military',
    positiveTraits: ['동물과 교감하는', '인내심 강한', '숙련된', '자연을 사랑하는'],
    scene: 'training horses with gentle expertise',
  },

  // ===== 3. 학문/종교 (12개) =====
  confucian_scholar: {
    kr: '유학자',
    en: 'Confucian Scholar',
    desc: 'a learned Confucian scholar',
    clothing: 'white scholarly robes (도포), black gat hat',
    accessories: 'books, brush, jade pendant',
    category: 'scholarly',
    positiveTraits: ['학식 높은', '고결한', '지혜로운', '존경받는'],
    scene: 'reading classics in peaceful study',
  },
  top_graduate: {
    kr: '장원급제 선비',
    en: 'Top Graduate Scholar',
    desc: 'a scholar who achieved top honors',
    clothing: 'ceremonial graduate robes, flower crown',
    accessories: 'royal appointment scroll, parade horse',
    category: 'scholarly',
    positiveTraits: ['수재', '영예로운', '미래가 촉망되는', '근면한'],
    scene: 'celebrating examination success',
  },
  county_magistrate: {
    kr: '현감',
    en: 'County Magistrate',
    desc: 'a just local magistrate',
    clothing: 'official magistrate robes, official hat',
    accessories: 'official seal, judicial gavel, documents',
    category: 'scholarly',
    positiveTraits: ['공정한', '백성을 사랑하는', '지혜로운', '청렴한'],
    scene: 'governing with wisdom and fairness',
  },
  governor: {
    kr: '목민관',
    en: 'Provincial Governor',
    desc: 'a caring provincial governor',
    clothing: 'high official robes, official hat',
    accessories: 'official seal, administrative documents',
    category: 'scholarly',
    positiveTraits: ['덕망 있는', '백성을 위하는', '청렴한', '지혜로운'],
    scene: 'caring for the people welfare',
  },
  finance_official: {
    kr: '호조 관리',
    en: 'Finance Official',
    desc: 'a finance ministry official',
    clothing: 'official court robes',
    accessories: 'accounting books, abacus, tax records',
    category: 'scholarly',
    positiveTraits: ['정확한', '청렴한', '책임감 강한', '꼼꼼한'],
    scene: 'managing state finances with integrity',
  },
  diplomat: {
    kr: '외교관',
    en: 'Diplomat',
    desc: 'a skilled diplomat',
    clothing: 'formal envoy robes, diplomatic attire',
    accessories: 'diplomatic credentials, gifts, documents',
    category: 'scholarly',
    positiveTraits: ['말솜씨 좋은', '지략가', '교양 있는', '침착한'],
    scene: 'negotiating with foreign envoys',
  },
  strategist: {
    kr: '책사',
    en: 'Royal Strategist',
    desc: 'a brilliant royal strategist',
    clothing: 'scholarly robes, simple hat',
    accessories: 'strategy maps, chess board, scrolls',
    category: 'scholarly',
    positiveTraits: ['천재적인', '통찰력 있는', '은밀한', '지략가'],
    scene: 'planning strategies in candlelight',
  },
  buddhist_monk: {
    kr: '승려',
    en: 'Buddhist Monk',
    desc: 'an enlightened Buddhist monk',
    clothing: 'gray monk robes (승복), shaved head',
    accessories: 'prayer beads (염주), sutra, wooden fish',
    category: 'spiritual',
    positiveTraits: ['깨달은', '자비로운', '지혜로운', '평화로운'],
    scene: 'meditating in mountain temple',
  },
  hermit_poet: {
    kr: '은둔 시인',
    en: 'Hermit Poet',
    desc: 'a reclusive poet living in nature',
    clothing: 'simple white robes, bamboo hat',
    accessories: 'brush, poetry scrolls, wine gourd',
    category: 'scholarly',
    positiveTraits: ['예술적인', '자유로운', '철학적인', '자연을 사랑하는'],
    scene: 'composing poetry by mountain stream',
  },

  // ===== 4. 신비/술사 (10개) =====
  face_reader: {
    kr: '관상가',
    en: 'Physiognomist',
    desc: 'a skilled face reader',
    clothing: 'mysterious dark robes',
    accessories: 'fortune telling tools, crystal ball',
    category: 'mystical',
    positiveTraits: ['예지력 있는', '통찰력 있는', '신비로운', '지혜로운'],
    scene: 'reading fate in facial features',
  },
  astronomer: {
    kr: '천문관',
    en: 'Royal Astronomer',
    desc: 'an astronomer reading the heavens',
    clothing: 'official robes, scholarly hat',
    accessories: 'star charts, astrolabe, telescope',
    category: 'mystical',
    positiveTraits: ['학식 높은', '하늘의 뜻을 읽는', '지혜로운', '신비로운'],
    scene: 'observing stars and reading omens',
  },
  calendar_maker: {
    kr: '관상감 관원',
    en: 'Calendar Official',
    desc: 'an official calculating calendars',
    clothing: 'official scholarly robes',
    accessories: 'astronomical instruments, calculation tools',
    category: 'mystical',
    positiveTraits: ['정밀한', '학식 높은', '인내심 강한', '꼼꼼한'],
    scene: 'calculating celestial movements',
  },
  fortune_teller: {
    kr: '역술가',
    en: 'Fortune Teller',
    desc: 'a master fortune teller',
    clothing: 'traditional dark robes',
    accessories: 'fortune telling coins, four pillars chart',
    category: 'mystical',
    positiveTraits: ['예언의', '신비로운', '통찰력 있는', '지혜로운'],
    scene: 'divining fate with ancient arts',
  },
  geomancer: {
    kr: '지관',
    en: 'Geomancer',
    desc: 'a feng shui master',
    clothing: 'scholarly robes, traveling hat',
    accessories: 'compass (나침반), feng shui tools, maps',
    category: 'mystical',
    positiveTraits: ['땅의 기운을 읽는', '지혜로운', '존경받는', '신비로운'],
    scene: 'reading energy of the land',
  },
  tomb_selector: {
    kr: '명당 감정관',
    en: 'Auspicious Site Selector',
    desc: 'a selector of auspicious burial sites',
    clothing: 'formal scholarly robes',
    accessories: 'geomancy tools, terrain maps',
    category: 'mystical',
    positiveTraits: ['명망 높은', '신비로운', '지혜로운', '존경받는'],
    scene: 'selecting perfect resting places',
  },
  ritual_master: {
    kr: '제관',
    en: 'Ritual Master',
    desc: 'a master of royal ceremonies',
    clothing: 'ceremonial robes, ritual hat',
    accessories: 'ritual vessels, incense, ceremonial items',
    category: 'mystical',
    positiveTraits: ['엄숙한', '학식 높은', '존경받는', '정결한'],
    scene: 'performing sacred ceremonies',
  },
  shaman: {
    kr: '무당',
    en: 'Shaman',
    desc: 'a powerful spiritual shaman',
    clothing: 'colorful ceremonial dress (무복), spirit crown',
    accessories: 'spirit bells, ritual knife, shamanic fan',
    category: 'mystical',
    positiveTraits: ['영험한', '치유하는', '신비로운', '영적인'],
    scene: 'connecting heaven and earth',
  },
  taoist: {
    kr: '도사',
    en: 'Taoist Master',
    desc: 'a Taoist master of arts',
    clothing: 'flowing Taoist robes, traditional hat',
    accessories: 'sword, talismans, elixir gourd',
    category: 'mystical',
    positiveTraits: ['신비로운', '도를 닦은', '초월적인', '지혜로운'],
    scene: 'practicing ancient Taoist arts',
  },
  healer: {
    kr: '약초 치료사',
    en: 'Herbal Healer',
    desc: 'a healer using herbal medicine',
    clothing: 'simple practical robes',
    accessories: 'herb basket, mortar and pestle, medicine pouch',
    category: 'mystical',
    positiveTraits: ['치유하는', '자비로운', '지식 풍부한', '백성을 돕는'],
    scene: 'gathering healing herbs in mountains',
  },

  // ===== 5. 상인/장인 (12개) =====
  traveling_merchant: {
    kr: '보부상',
    en: 'Traveling Merchant',
    desc: 'a traveling merchant across the land',
    clothing: 'practical travel hanbok, wide hat',
    accessories: 'goods backpack, walking stick, trade goods',
    category: 'merchant',
    positiveTraits: ['활달한', '교류하는', '정보통', '모험적인'],
    scene: 'traveling with precious goods',
  },
  silk_merchant: {
    kr: '비단 상인',
    en: 'Silk Merchant',
    desc: 'a wealthy silk trader',
    clothing: 'fine silk hanbok showing prosperity',
    accessories: 'silk samples, trade ledger, money pouch',
    category: 'merchant',
    positiveTraits: ['거부', '안목 있는', '사업수완 좋은', '신용 있는'],
    scene: 'trading finest silk fabrics',
  },
  medicine_merchant: {
    kr: '약재상',
    en: 'Medicine Merchant',
    desc: 'a merchant of medicinal herbs',
    clothing: 'quality hanbok, merchant attire',
    accessories: 'medicine chest, scales, herb samples',
    category: 'merchant',
    positiveTraits: ['지식 풍부한', '정직한', '백성을 돕는', '신뢰받는'],
    scene: 'selecting finest medicinal herbs',
  },
  ceramicist: {
    kr: '도공',
    en: 'Master Ceramicist',
    desc: 'a master potter creating fine ceramics',
    clothing: 'working hanbok, craftsman apron',
    accessories: 'pottery wheel, kiln tools, finished ceramics',
    category: 'artisan',
    positiveTraits: ['장인의', '예술적인', '숙련된', '완벽주의자'],
    scene: 'crafting beautiful celadon pottery',
  },
  blacksmith: {
    kr: '대장장이',
    en: 'Master Blacksmith',
    desc: 'a skilled blacksmith',
    clothing: 'working clothes, leather apron',
    accessories: 'hammer, anvil, forge tools',
    category: 'artisan',
    positiveTraits: ['강인한', '숙련된', '존경받는', '뛰어난 솜씨의'],
    scene: 'forging fine blades with fire',
  },
  paper_maker: {
    kr: '한지 장인',
    en: 'Traditional Paper Maker',
    desc: 'a master of traditional paper making',
    clothing: 'simple working clothes',
    accessories: 'paper molds, mulberry bark, drying frames',
    category: 'artisan',
    positiveTraits: ['전통을 잇는', '숙련된', '인내심 강한', '예술적인'],
    scene: 'making finest hanji paper',
  },
  printer: {
    kr: '인쇄공',
    en: 'Master Printer',
    desc: 'a skilled woodblock printer',
    clothing: 'working hanbok',
    accessories: 'woodblocks, ink, printing tools',
    category: 'artisan',
    positiveTraits: ['정교한', '학식 있는', '숙련된', '문화를 전파하는'],
    scene: 'printing valuable texts',
  },
  copyist: {
    kr: '필사장',
    en: 'Royal Copyist',
    desc: 'a skilled calligrapher copying texts',
    clothing: 'scholarly attire',
    accessories: 'brushes, ink, manuscript scrolls',
    category: 'artisan',
    positiveTraits: ['섬세한', '인내심 강한', '아름다운 글씨의', '학식 있는'],
    scene: 'copying sutras with beautiful calligraphy',
  },
  cartographer: {
    kr: '지도 제작자',
    en: 'Cartographer',
    desc: 'a skilled map maker',
    clothing: 'scholarly robes',
    accessories: 'drawing tools, surveying equipment, maps',
    category: 'artisan',
    positiveTraits: ['정밀한', '지식 풍부한', '모험적인', '창의적인'],
    scene: 'drawing detailed maps of the land',
  },
  innkeeper: {
    kr: '주막 주인',
    en: 'Innkeeper',
    desc: 'a hospitable inn owner',
    clothing: 'practical hanbok',
    accessories: 'serving trays, cooking utensils',
    category: 'merchant',
    positiveTraits: ['인심 좋은', '이야기꾼', '정보통', '친절한'],
    scene: 'welcoming travelers warmly',
  },

  // ===== 6. 기술/실무 (8개) =====
  stable_master: {
    kr: '마부',
    en: 'Stable Master',
    desc: 'a skilled stable master',
    clothing: 'practical working clothes',
    accessories: 'horse gear, brushes, hay',
    category: 'labor',
    positiveTraits: ['동물을 사랑하는', '충성스러운', '부지런한', '신뢰받는'],
    scene: 'caring for noble horses',
  },
  carpenter: {
    kr: '목수',
    en: 'Master Carpenter',
    desc: 'a master carpenter',
    clothing: 'working clothes, craftsman attire',
    accessories: 'woodworking tools, measuring ruler, plane',
    category: 'artisan',
    positiveTraits: ['숙련된', '창의적인', '정교한', '존경받는'],
    scene: 'building with masterful skill',
  },
  stonemason: {
    kr: '석공',
    en: 'Master Stonemason',
    desc: 'a skilled stonemason',
    clothing: 'sturdy working clothes',
    accessories: 'chisel, hammer, stone samples',
    category: 'artisan',
    positiveTraits: ['강인한', '숙련된', '인내심 강한', '예술적인'],
    scene: 'carving stone with precision',
  },
  engineer: {
    kr: '토목 기술자',
    en: 'Civil Engineer',
    desc: 'an engineer building structures',
    clothing: 'practical official robes',
    accessories: 'building plans, measuring tools',
    category: 'artisan',
    positiveTraits: ['혁신적인', '지식 풍부한', '백성을 위하는', '숙련된'],
    scene: 'designing bridges and structures',
  },
  armory_keeper: {
    kr: '무기고 관리인',
    en: 'Armory Keeper',
    desc: 'a keeper of royal armory',
    clothing: 'official keeper uniform',
    accessories: 'keys, weapon inventory, maintenance tools',
    category: 'military',
    positiveTraits: ['책임감 강한', '꼼꼼한', '신뢰받는', '충성스러운'],
    scene: 'maintaining weapons with care',
  },
  undertaker: {
    kr: '장의사',
    en: 'Funeral Director',
    desc: 'a respectful funeral director',
    clothing: 'simple dark robes',
    accessories: 'ceremonial items, ritual tools',
    category: 'labor',
    positiveTraits: ['자비로운', '존엄을 지키는', '경건한', '위로하는'],
    scene: 'honoring the departed with dignity',
  },
  farmer: {
    kr: '농부',
    en: 'Respected Farmer',
    desc: 'a hardworking respected farmer',
    clothing: 'clean earth-toned hanbok, straw hat (삿갓)',
    accessories: 'farming tools, grain basket',
    category: 'labor',
    positiveTraits: ['부지런한', '의로운', '마을의 존경을 받는', '정직한'],
    scene: 'working fertile fields at sunrise',
  },
  servant: {
    kr: '하인',
    en: 'Faithful Servant',
    desc: 'a faithful and clever servant',
    clothing: 'simple clean hanbok',
    accessories: 'serving items',
    category: 'labor',
    positiveTraits: ['영특한', '충성스러운', '지혜로운', '주인의 신뢰를 받는'],
    scene: 'faithfully serving with wisdom',
  },

  // ===== 7. 여성 직업 (10개) =====
  female_physician: {
    kr: '의녀',
    en: 'Female Physician',
    desc: 'a skilled female royal physician',
    clothing: 'medical uniform for women, neat hairstyle',
    accessories: 'medicine box, acupuncture needles, medical texts',
    category: 'palace',
    positiveTraits: ['치유하는', '자비로운', '학식 높은', '헌신적인'],
    scene: 'healing with herbal medicine',
  },
  head_court_lady: {
    kr: '내명부 상궁',
    en: 'Head Court Matron',
    desc: 'a senior court matron of high rank',
    clothing: 'formal palace hanbok, elaborate hairstyle',
    accessories: 'palace keys, official documents',
    category: 'palace',
    positiveTraits: ['위엄 있는', '지혜로운', '존경받는', '카리스마 있는'],
    scene: 'managing palace with authority',
  },
  embroiderer: {
    kr: '침선비',
    en: 'Master Embroiderer',
    desc: 'a master of embroidery arts',
    clothing: 'neat hanbok, simple elegant style',
    accessories: 'embroidery frame, silk threads, needles',
    category: 'artisan',
    positiveTraits: ['예술적인', '섬세한', '인내심 강한', '창의적인'],
    scene: 'creating beautiful embroidery',
  },
  tavern_owner: {
    kr: '주모',
    en: 'Tavern Mistress',
    desc: 'a lively tavern owner',
    clothing: 'practical hanbok, neat appearance',
    accessories: 'serving bowls, cooking utensils',
    category: 'merchant',
    positiveTraits: ['활기찬', '인심 좋은', '사업수완 좋은', '정보통'],
    scene: 'running lively tavern',
  },
  female_shaman: {
    kr: '무녀',
    en: 'Female Shaman',
    desc: 'a powerful female shaman',
    clothing: 'colorful shamanic dress, spirit ornaments',
    accessories: 'spirit bells, ritual fan, sacred items',
    category: 'mystical',
    positiveTraits: ['영험한', '치유하는', '신비로운', '영적인'],
    scene: 'performing healing rituals',
  },
  artistic_gisaeng: {
    kr: '예기',
    en: 'Artistic Gisaeng',
    desc: 'a cultured artistic entertainer',
    clothing: 'elegant colorful hanbok, elaborate hairstyle',
    accessories: 'gayageum, poetry scrolls, flower ornaments',
    category: 'entertainment',
    positiveTraits: ['예술적인', '교양 있는', '아름다운', '재능 있는'],
    scene: 'performing elegant arts',
  },
  wet_nurse: {
    kr: '유모',
    en: 'Royal Wet Nurse',
    desc: 'a trusted royal wet nurse',
    clothing: 'palace servant attire',
    accessories: 'baby items, caring tools',
    category: 'palace',
    positiveTraits: ['자애로운', '신뢰받는', '헌신적인', '지혜로운'],
    scene: 'caring for royal children',
  },
  midwife: {
    kr: '산파',
    en: 'Skilled Midwife',
    desc: 'an experienced midwife',
    clothing: 'simple practical hanbok',
    accessories: 'birthing supplies, herbal medicines',
    category: 'labor',
    positiveTraits: ['생명을 돕는', '경험 많은', '자비로운', '존경받는'],
    scene: 'helping bring new life',
  },
  herb_gatherer: {
    kr: '약초 채집꾼',
    en: 'Herb Gatherer',
    desc: 'a knowledgeable herb gatherer',
    clothing: 'practical mountain clothes',
    accessories: 'herb basket, digging tools, herb pouch',
    category: 'labor',
    positiveTraits: ['자연과 교감하는', '지식 풍부한', '부지런한', '치유하는'],
    scene: 'gathering herbs in deep mountains',
  },
  weaver: {
    kr: '길쌈 장인',
    en: 'Master Weaver',
    desc: 'a skilled textile weaver',
    clothing: 'simple working hanbok',
    accessories: 'loom, silk threads, fabric samples',
    category: 'artisan',
    positiveTraits: ['숙련된', '인내심 강한', '창의적인', '전통을 잇는'],
    scene: 'weaving beautiful fabrics',
  },

  // ===== 8. 예술인 (10개) =====
  court_musician: {
    kr: '악공',
    en: 'Court Musician',
    desc: 'a skilled royal court musician',
    clothing: 'court musician uniform',
    accessories: 'traditional instruments, music scrolls',
    category: 'entertainment',
    positiveTraits: ['재능 있는', '우아한', '존경받는', '예술적인'],
    scene: 'playing beautiful court music',
  },
  clown: {
    kr: '광대',
    en: 'Entertainer Clown',
    desc: 'a beloved comedic entertainer',
    clothing: 'colorful performer costume',
    accessories: 'masks, props, musical instruments',
    category: 'entertainment',
    positiveTraits: ['재치 있는', '사람들을 웃기는', '창의적인', '활달한'],
    scene: 'bringing joy to crowds',
  },
  tightrope_walker: {
    kr: '줄타기꾼',
    en: 'Tightrope Walker',
    desc: 'a daring tightrope performer',
    clothing: 'performer attire, light and flexible',
    accessories: 'balancing pole, performance props',
    category: 'entertainment',
    positiveTraits: ['용감한', '균형감 있는', '전설적인', '관중을 사로잡는'],
    scene: 'dancing on thin rope',
  },
  mask_dancer: {
    kr: '탈꾼',
    en: 'Mask Dance Master',
    desc: 'a master of traditional mask dance',
    clothing: 'traditional mask dance costume',
    accessories: 'various masks, dance props',
    category: 'entertainment',
    positiveTraits: ['예술적인', '전통을 잇는', '표현력 풍부한', '영적인'],
    scene: 'performing powerful mask dance',
  },
  pansori_singer: {
    kr: '소리꾼',
    en: 'Pansori Singer',
    desc: 'a legendary pansori performer',
    clothing: 'traditional performer hanbok, fan',
    accessories: 'fan, gosu drum, performance items',
    category: 'entertainment',
    positiveTraits: ['전설적인', '감동을 주는', '혼을 담은', '명창'],
    scene: 'singing with soul-stirring voice',
  },
  singer: {
    kr: '가객',
    en: 'Traditional Singer',
    desc: 'a refined traditional singer',
    clothing: 'elegant performer attire',
    accessories: 'musical instruments, song scrolls',
    category: 'entertainment',
    positiveTraits: ['아름다운 목소리의', '우아한', '교양 있는', '예술적인'],
    scene: 'singing beautiful melodies',
  },
  dancer: {
    kr: '춤꾼',
    en: 'Traditional Dancer',
    desc: 'a graceful traditional dancer',
    clothing: 'flowing dance costume, elegant hanbok',
    accessories: 'fans, ribbons, dance props',
    category: 'entertainment',
    positiveTraits: ['우아한', '아름다운', '예술적인', '관중을 매료시키는'],
    scene: 'dancing with flowing grace',
  },
  drummer: {
    kr: '북장이',
    en: 'Master Drummer',
    desc: 'a skilled traditional drummer',
    clothing: 'performer attire',
    accessories: 'various drums, drumsticks',
    category: 'entertainment',
    positiveTraits: ['리듬감 있는', '열정적인', '숙련된', '흥을 돋우는'],
    scene: 'beating drums with passion',
  },
  geomungo_master: {
    kr: '거문고 명인',
    en: 'Geomungo Master',
    desc: 'a master of the geomungo',
    clothing: 'refined scholarly or performer attire',
    accessories: 'geomungo, music scrolls',
    category: 'entertainment',
    positiveTraits: ['명인', '깊은 감성의', '존경받는', '예술적인'],
    scene: 'playing deep melodies',
  },
  flute_master: {
    kr: '피리 명인',
    en: 'Flute Master',
    desc: 'a master flute player',
    clothing: 'elegant performer or scholarly attire',
    accessories: 'various flutes (대금, 피리), music scrolls',
    category: 'entertainment',
    positiveTraits: ['맑은 소리의', '영혼을 울리는', '명인', '자연과 교감하는'],
    scene: 'playing haunting melodies',
  },
}

// =====================================================
// 민화 스타일 기본 프롬프트 상수
// 사용자 요청에 따라 품질 개선
// =====================================================

const MINHWA_STYLE_BASE = `
=== ART STYLE (CRITICAL) ===
Style: Korean traditional Minhwa painting (한국 전통 민화)
- Joseon Dynasty folk art style (조선시대 민화 양식)
- Minhwa (민화) aesthetic with narrative elements
- Gongbi (공필화) fine line technique

Technique:
- Fine ink line drawing (섬세한 먹선)
- Muted, soft watercolor texture
- Ink and wash painting (수묵담채)
- Visible brushstroke texture

Medium:
- Old Hanji paper texture (오래된 한지 질감)
- Vintage paper background with natural aging
- Traditional mineral pigments appearance
- Aged patina effect

Color Palette:
- Muted earth tones: ochre (황토색), burnt sienna, indigo
- Natural mineral pigments look
- Soft watercolor washes with occasional rich accents
- NO bright saturated colors

Quality: Museum masterpiece, National Museum of Korea (국립중앙박물관) collection level
`

const MINHWA_FORBIDDEN = `
=== FORBIDDEN ELEMENTS ===
- Modern elements or contemporary clothing
- Anime, manga, cartoon, or illustration style
- Bright saturated or neon colors
- Western painting techniques
- Fantasy, supernatural, or magical elements
- Text, watermarks, signatures, or logos
- Photorealistic or digital rendering style
- AI-generated artifacts or glitches
- Multiple subjects or crowd scenes
`

// =====================================================
// 분위기/조명 옵션 (다양성 증가)
// =====================================================
interface Atmosphere {
  mood: string       // 한글 분위기 설명
  light: string      // 영문 조명 설명
  season?: string    // 계절 (선택)
}

const ATMOSPHERES: Atmosphere[] = [
  { mood: '고요한 아침', light: 'soft golden morning light gently streaming from the east', season: 'spring' },
  { mood: '한낮의 햇살 아래', light: 'bright midday sunlight casting gentle shadows' },
  { mood: '석양 무렵', light: 'warm dramatic sunset glow with orange and pink hues', season: 'autumn' },
  { mood: '달빛 아래', light: 'soft silvery moonlight creating a mysterious, ethereal glow' },
  { mood: '촛불 앞에서', light: 'warm candlelight creating intimate golden shadows' },
  { mood: '봄날 꽃비 내리는', light: 'soft diffused light filtering through cherry blossom petals', season: 'spring' },
  { mood: '여름 소나기 후', light: 'fresh post-rain light with subtle dewy atmosphere', season: 'summer' },
  { mood: '가을 단풍 물든', light: 'golden autumn light filtering through maple leaves', season: 'autumn' },
  { mood: '눈 내리는 겨울', light: 'cool blue-white winter light with soft snowflakes', season: 'winter' },
  { mood: '안개 낀 새벽', light: 'misty pre-dawn light with soft atmospheric haze' },
  { mood: '맑은 하늘 아래', light: 'clear bright daylight with crisp details' },
  { mood: '노을 지는 저녁', light: 'deep crimson and gold sunset illumination' },
]

// =====================================================
// 배경 옵션 (직업별 적합성 포함)
// =====================================================
interface Background {
  type: string       // 배경 타입
  desc: string       // 영문 설명
  suitableFor: string[]  // 적합한 카테고리
}

const BACKGROUNDS: Background[] = [
  // 실내 배경
  { type: 'palace', desc: 'elegant palace interior with ornate wooden screens and silk curtains', suitableFor: ['palace', 'scholarly'] },
  { type: 'study', desc: 'scholar\'s study filled with scrolls, brushes, and ink stones on wooden desk', suitableFor: ['scholarly', 'artisan'] },
  { type: 'tea_room', desc: 'serene traditional tea room with minimal elegance and bamboo accents', suitableFor: ['palace', 'mystical'] },
  { type: 'workshop', desc: 'artisan workshop with tools of the trade and works in progress', suitableFor: ['artisan', 'labor'] },
  { type: 'temple', desc: 'peaceful Buddhist temple interior with soft incense haze', suitableFor: ['mystical', 'spiritual'] },
  // 실외 배경
  { type: 'garden', desc: 'traditional Korean garden with pavilion, lotus pond and pine trees', suitableFor: ['palace', 'scholarly', 'entertainment'] },
  { type: 'mountain', desc: 'misty mountain backdrop with ancient pine trees and distant peaks', suitableFor: ['mystical', 'spiritual', 'military'] },
  { type: 'market', desc: 'bustling traditional marketplace with colorful goods and activity', suitableFor: ['merchant', 'labor'] },
  { type: 'village', desc: 'peaceful village scene with thatched roof houses and paths', suitableFor: ['labor', 'merchant'] },
  { type: 'battlefield', desc: 'dramatic open field with banners and distant mountains', suitableFor: ['military'] },
  // 추상/심플 배경
  { type: 'clouds', desc: 'ethereal clouds and mist like a celestial realm', suitableFor: ['mystical', 'spiritual'] },
  { type: 'simple', desc: 'plain aged Hanji paper with natural texture and subtle patina', suitableFor: ['all'] },
  { type: 'mist', desc: 'atmospheric soft mist fading into infinity', suitableFor: ['all'] },
]

// =====================================================
// 포즈 옵션 (동적 다양성)
// =====================================================
interface PoseOption {
  pose: string       // 영문 포즈 설명
  mood: string       // 분위기 (formal, active, contemplative)
}

const POSES: PoseOption[] = [
  { pose: 'formal seated position on silk cushion, back straight with dignified composure', mood: 'formal' },
  { pose: 'standing with hands clasped in front, in a dignified ceremonial stance', mood: 'formal' },
  { pose: 'mid-action, skillfully performing their craft with focused concentration', mood: 'active' },
  { pose: 'thoughtfully gazing into the distance, as if contemplating life\'s mysteries', mood: 'contemplative' },
  { pose: 'turning gracefully to the side, captured in an elegant moment of movement', mood: 'active' },
  { pose: 'seated with meaningful object in hand, embodying their life\'s work', mood: 'contemplative' },
  { pose: 'walking with purpose, robes flowing naturally with movement', mood: 'active' },
  { pose: 'kneeling in respectful posture, hands placed properly on knees', mood: 'formal' },
  { pose: 'leaning slightly forward with warm, welcoming expression', mood: 'contemplative' },
  { pose: 'looking over shoulder with knowing smile, as if sharing a secret', mood: 'active' },
]

// =====================================================
// 품질 수식어 (유명 화가 스타일 참조)
// =====================================================
const QUALITY_MODIFIERS: string[] = [
  'museum masterpiece quality worthy of National Museum of Korea (국립중앙박물관) permanent collection',
  'exquisite brushwork reminiscent of the great Shin Yun-bok (신윤복), master of elegant genre paintings',
  'delicate detail and wit rivaling Kim Hong-do (김홍도), capturing the essence of daily life',
  'ethereal quality of traditional Joseon royal portrait tradition (어진)',
  'poetic composition like a scene from classical Korean literature (고전문학)',
  'masterful ink gradation technique of Jeong Seon (정선), the mountain painting genius',
  'refined elegance of Joseon court painting academy (도화서) at its peak',
  'timeless beauty capturing the scholarly spirit of Joseon literati painting (문인화)',
]

// =====================================================
// 선택 함수들
// =====================================================
function selectAtmosphere(): Atmosphere {
  return ATMOSPHERES[Math.floor(Math.random() * ATMOSPHERES.length)]
}

function selectBackground(category: string): Background {
  // 카테고리에 적합한 배경 필터링
  const suitable = BACKGROUNDS.filter(
    bg => bg.suitableFor.includes(category) || bg.suitableFor.includes('all')
  )
  // 적합한 배경이 없으면 전체에서 선택
  const pool = suitable.length > 0 ? suitable : BACKGROUNDS
  return pool[Math.floor(Math.random() * pool.length)]
}

function selectPose(): PoseOption {
  return POSES[Math.floor(Math.random() * POSES.length)]
}

function selectQualityModifier(): string {
  return QUALITY_MODIFIERS[Math.floor(Math.random() * QUALITY_MODIFIERS.length)]
}

// =====================================================
// 80개+ 전생 시나리오 (모든 직업, 긍정적 특성)
// 모든 시나리오는 기분 좋은 결과로 포장
// =====================================================
interface PastLifeScenario {
  id: string
  category: string
  status: string  // STATUS_CONFIGS의 키와 매칭
  trait: string   // 긍정적 특성 (STATUS_CONFIGS.positiveTraits에서 선택됨)
  storySeed: string
  weight: number  // 높을수록 자주 등장 (기본 10)
}

// ===== 플롯 템플릿 시스템 (V2.1 Dynamic Story) =====
type PlotType = 'TRAGEDY' | 'TRIUMPH' | 'ROMANCE' | 'MYSTERY' | 'ADVENTURE'

interface PlotTemplate {
  name: PlotType
  nameKr: string
  arc: string[]  // 5챕터 제목
  emojis: string[]  // 챕터별 이모지
  tone: string
  ending: string
  writingStyle: string  // 서술 스타일 가이드
}

const PLOT_TEMPLATES: Record<PlotType, PlotTemplate> = {
  TRAGEDY: {
    name: 'TRAGEDY',
    nameKr: '비극',
    arc: ['영광의 시작', '정점에 서다', '운명의 균열', '추락', '비극적 교훈'],
    emojis: ['🌅', '👑', '⚡', '🌑', '🕯️'],
    tone: '비극적, 숙명적, 애절한',
    ending: '안타까운 최후, 후세에 남긴 경고와 교훈',
    writingStyle: '운명의 아이러니 강조, 절정의 순간 직후 추락, 독자의 연민 유발'
  },
  TRIUMPH: {
    name: 'TRIUMPH',
    nameKr: '승리',
    arc: ['비천한 시작', '희망의 불씨', '시련의 연속', '극적 반전', '영웅의 탄생'],
    emojis: ['🌱', '✨', '🔥', '💫', '🏆'],
    tone: '희망적, 감동적, 고무적',
    ending: '영광스러운 결말, 전설이 되어 후세에 기억됨',
    writingStyle: '역경 속 성장 강조, 조력자와의 만남, 결정적 승리의 순간'
  },
  ROMANCE: {
    name: 'ROMANCE',
    nameKr: '로맨스',
    arc: ['운명적 만남', '피어나는 감정', '이별의 위기', '재회 또는 이별', '영원한 사랑'],
    emojis: ['💕', '🌸', '💔', '🌙', '❤️‍🔥'],
    tone: '로맨틱, 애절한, 가슴 저미는',
    ending: '이루어진 사랑 또는 애틋한 영원한 이별',
    writingStyle: '감정의 깊이 묘사, 장애물의 극복, 사랑의 희생과 헌신'
  },
  MYSTERY: {
    name: 'MYSTERY',
    nameKr: '미스터리',
    arc: ['수수께끼의 등장', '숨겨진 정체', '진실에 다가서다', '충격의 반전', '비밀의 대가'],
    emojis: ['🎭', '🔍', '🗝️', '😱', '⚖️'],
    tone: '긴장감, 의문, 반전',
    ending: '진실 폭로와 그 여파, 숨겨진 정체의 결말',
    writingStyle: '복선과 암시, 점진적 진실 공개, 독자 예상 뒤엎는 반전'
  },
  ADVENTURE: {
    name: 'ADVENTURE',
    nameKr: '모험',
    arc: ['모험의 부름', '낯선 세계', '시련과 동료', '보물 발견', '변화된 귀환'],
    emojis: ['🚀', '🗺️', '⚔️', '💎', '🏠'],
    tone: '역동적, 흥미진진, 성장',
    ending: '성장과 깨달음을 얻은 귀환, 변화된 인물',
    writingStyle: '새로운 세계 묘사, 동료와의 유대, 내면의 성장'
  }
}

// 카테고리별 플롯 가중치 (합계 1.0)
const CATEGORY_PLOT_WEIGHTS: Record<string, Partial<Record<PlotType, number>>> = {
  palace: { TRAGEDY: 0.35, TRIUMPH: 0.25, ROMANCE: 0.2, MYSTERY: 0.2 },
  military: { TRIUMPH: 0.4, TRAGEDY: 0.3, ADVENTURE: 0.2, MYSTERY: 0.1 },
  scholarly: { TRIUMPH: 0.35, MYSTERY: 0.25, ROMANCE: 0.2, TRAGEDY: 0.2 },
  mystical: { MYSTERY: 0.4, TRAGEDY: 0.25, ADVENTURE: 0.2, TRIUMPH: 0.15 },
  merchant: { ADVENTURE: 0.35, TRIUMPH: 0.3, MYSTERY: 0.2, ROMANCE: 0.15 },
  artisan: { TRIUMPH: 0.35, ROMANCE: 0.25, TRAGEDY: 0.2, ADVENTURE: 0.2 },
  spiritual: { MYSTERY: 0.3, TRIUMPH: 0.3, TRAGEDY: 0.25, ADVENTURE: 0.15 },
  entertainment: { ROMANCE: 0.4, TRAGEDY: 0.35, TRIUMPH: 0.15, MYSTERY: 0.1 },
  labor: { TRIUMPH: 0.45, TRAGEDY: 0.25, ADVENTURE: 0.2, ROMANCE: 0.1 },
  female: { ROMANCE: 0.35, TRIUMPH: 0.3, TRAGEDY: 0.2, MYSTERY: 0.15 }
}

// 가중치 기반 플롯 선택 함수
function selectPlotTemplate(category: string): PlotTemplate {
  const weights = CATEGORY_PLOT_WEIGHTS[category] || CATEGORY_PLOT_WEIGHTS['palace']
  const plotTypes = Object.keys(weights) as PlotType[]

  // 가중치 기반 랜덤 선택
  const random = Math.random()
  let cumulative = 0

  for (const plotType of plotTypes) {
    cumulative += weights[plotType] || 0
    if (random <= cumulative) {
      return PLOT_TEMPLATES[plotType]
    }
  }

  // 기본값: TRIUMPH
  return PLOT_TEMPLATES.TRIUMPH
}

const PAST_LIFE_SCENARIOS: PastLifeScenario[] = [
  // ===== 1. 궁궐/관료 (15개) =====
  { id: 'secretary_trusted', category: 'palace', status: 'court_secretary', trait: '신뢰받는', storySeed: '왕의 비밀 문서를 다루던', weight: 10 },
  { id: 'historian_brave', category: 'palace', status: 'historian', trait: '용감한', storySeed: '역사의 진실을 기록한', weight: 10 },
  { id: 'physician_healing', category: 'palace', status: 'royal_physician', trait: '자비로운', storySeed: '왕실의 건강을 지킨', weight: 12 },
  { id: 'eunuch_wise', category: 'palace', status: 'eunuch', trait: '지혜로운', storySeed: '궁궐의 비밀을 간직한', weight: 8 },
  { id: 'court_lady_elegant', category: 'palace', status: 'court_lady', trait: '우아한', storySeed: '궁중 예법을 지킨', weight: 10 },
  { id: 'chef_skilled', category: 'palace', status: 'head_chef', trait: '숙련된', storySeed: '어전에 수라를 올린', weight: 10 },
  { id: 'seamstress_artistic', category: 'palace', status: 'seamstress', trait: '예술적인', storySeed: '왕실 의복에 혼을 담은', weight: 10 },
  { id: 'court_painter_talented', category: 'palace', status: 'court_painter', trait: '재능 있는', storySeed: '산수화로 이름난', weight: 12 },
  { id: 'portrait_painter_respected', category: 'palace', status: 'portrait_painter', trait: '존경받는', storySeed: '어진을 그린', weight: 8 },
  { id: 'garden_keeper_peaceful', category: 'palace', status: 'garden_keeper', trait: '평화로운', storySeed: '궁궐 정원을 가꾼', weight: 10 },

  // ===== 2. 무사/군인 (12개) =====
  { id: 'naval_heroic', category: 'military', status: 'naval_commander', trait: '용맹한', storySeed: '바다에서 적을 물리친', weight: 10 },
  { id: 'general_legendary', category: 'military', status: 'army_general', trait: '영웅적인', storySeed: '나라를 구한', weight: 8 },
  { id: 'guard_loyal', category: 'military', status: 'royal_guard', trait: '충성스러운', storySeed: '왕을 목숨 걸고 호위한', weight: 12 },
  { id: 'gate_dignified', category: 'military', status: 'gate_commander', trait: '위엄 있는', storySeed: '궁궐 문을 지킨', weight: 10 },
  { id: 'messenger_swift', category: 'military', status: 'messenger', trait: '신속한', storySeed: '긴급 문서를 전달한', weight: 10 },
  { id: 'agent_secret', category: 'military', status: 'secret_agent', trait: '충성스러운', storySeed: '왕의 밀명을 수행한', weight: 8 },
  { id: 'hunter_skilled', category: 'military', status: 'bounty_hunter', trait: '정의로운', storySeed: '악인을 추적한', weight: 8 },
  { id: 'detective_sharp', category: 'military', status: 'detective', trait: '통찰력 있는', storySeed: '미궁 사건을 해결한', weight: 10 },
  { id: 'archer_legendary', category: 'military', status: 'master_archer', trait: '전설적인', storySeed: '백발백중의', weight: 10 },
  { id: 'trainer_patient', category: 'military', status: 'horse_trainer', trait: '동물과 교감하는', storySeed: '명마를 길러낸', weight: 10 },

  // ===== 3. 학문/종교 (12개) =====
  { id: 'scholar_wise', category: 'scholarly', status: 'confucian_scholar', trait: '학식 높은', storySeed: '성리학의 대가였던', weight: 12 },
  { id: 'graduate_brilliant', category: 'scholarly', status: 'top_graduate', trait: '수재', storySeed: '장원급제하여 이름을 날린', weight: 10 },
  { id: 'magistrate_just', category: 'scholarly', status: 'county_magistrate', trait: '공정한', storySeed: '백성을 위해 선정을 베푼', weight: 12 },
  { id: 'governor_caring', category: 'scholarly', status: 'governor', trait: '백성을 위하는', storySeed: '덕망 높은', weight: 10 },
  { id: 'finance_honest', category: 'scholarly', status: 'finance_official', trait: '청렴한', storySeed: '나라 재정을 바르게 관리한', weight: 10 },
  { id: 'diplomat_eloquent', category: 'scholarly', status: 'diplomat', trait: '말솜씨 좋은', storySeed: '외교로 나라를 빛낸', weight: 10 },
  { id: 'strategist_genius', category: 'scholarly', status: 'strategist', trait: '천재적인', storySeed: '귀신같은 전략을 세운', weight: 8 },
  { id: 'monk_enlightened', category: 'spiritual', status: 'buddhist_monk', trait: '깨달은', storySeed: '산사에서 도를 닦은', weight: 10 },
  { id: 'poet_free', category: 'scholarly', status: 'hermit_poet', trait: '자유로운', storySeed: '자연 속에서 시를 읊은', weight: 12 },

  // ===== 4. 신비/술사 (10개) =====
  { id: 'face_reader_insightful', category: 'mystical', status: 'face_reader', trait: '통찰력 있는', storySeed: '사람의 운명을 읽은', weight: 10 },
  { id: 'astronomer_wise', category: 'mystical', status: 'astronomer', trait: '하늘의 뜻을 읽는', storySeed: '별의 움직임을 해석한', weight: 10 },
  { id: 'calendar_precise', category: 'mystical', status: 'calendar_maker', trait: '정밀한', storySeed: '역법을 계산한', weight: 8 },
  { id: 'fortune_prophetic', category: 'mystical', status: 'fortune_teller', trait: '예언의', storySeed: '미래를 내다본', weight: 10 },
  { id: 'geomancer_respected', category: 'mystical', status: 'geomancer', trait: '존경받는', storySeed: '명당을 찾아낸', weight: 10 },
  { id: 'tomb_famous', category: 'mystical', status: 'tomb_selector', trait: '명망 높은', storySeed: '왕릉 자리를 정한', weight: 8 },
  { id: 'ritual_sacred', category: 'mystical', status: 'ritual_master', trait: '학식 높은', storySeed: '제사를 엄숙히 집행한', weight: 8 },
  { id: 'shaman_spiritual', category: 'mystical', status: 'shaman', trait: '영험한', storySeed: '신과 교감하던', weight: 10 },
  { id: 'taoist_mystical', category: 'mystical', status: 'taoist', trait: '도를 닦은', storySeed: '신선의 경지에 이른', weight: 8 },
  { id: 'healer_compassionate', category: 'mystical', status: 'healer', trait: '치유하는', storySeed: '약초로 많은 생명을 살린', weight: 12 },

  // ===== 5. 상인/장인 (12개) =====
  { id: 'merchant_adventurous', category: 'merchant', status: 'traveling_merchant', trait: '활달한', storySeed: '전국을 누빈', weight: 12 },
  { id: 'silk_wealthy', category: 'merchant', status: 'silk_merchant', trait: '안목 있는', storySeed: '비단으로 거부가 된', weight: 10 },
  { id: 'medicine_helpful', category: 'merchant', status: 'medicine_merchant', trait: '백성을 돕는', storySeed: '좋은 약재로 이름난', weight: 10 },
  { id: 'ceramicist_master', category: 'artisan', status: 'ceramicist', trait: '장인의', storySeed: '청자를 빚은', weight: 10 },
  { id: 'blacksmith_skilled', category: 'artisan', status: 'blacksmith', trait: '숙련된', storySeed: '명검을 만든', weight: 10 },
  { id: 'paper_traditional', category: 'artisan', status: 'paper_maker', trait: '전통을 잇는', storySeed: '최고의 한지를 만든', weight: 10 },
  { id: 'printer_cultured', category: 'artisan', status: 'printer', trait: '문화를 전파하는', storySeed: '귀한 서적을 인쇄한', weight: 10 },
  { id: 'copyist_beautiful', category: 'artisan', status: 'copyist', trait: '아름다운 글씨의', storySeed: '불경을 필사한', weight: 10 },
  { id: 'cartographer_adventurous', category: 'artisan', status: 'cartographer', trait: '모험적인', storySeed: '산천을 측량한', weight: 10 },
  { id: 'innkeeper_warm', category: 'merchant', status: 'innkeeper', trait: '인심 좋은', storySeed: '나그네를 따뜻이 맞은', weight: 12 },

  // ===== 6. 기술/실무 (8개) =====
  { id: 'stable_faithful', category: 'labor', status: 'stable_master', trait: '동물을 사랑하는', storySeed: '명마를 돌본', weight: 10 },
  { id: 'carpenter_skilled', category: 'artisan', status: 'carpenter', trait: '숙련된', storySeed: '누각을 지은', weight: 10 },
  { id: 'stonemason_artistic', category: 'artisan', status: 'stonemason', trait: '예술적인', storySeed: '석탑을 조각한', weight: 10 },
  { id: 'engineer_innovative', category: 'artisan', status: 'engineer', trait: '혁신적인', storySeed: '다리를 설계한', weight: 10 },
  { id: 'armory_trusted', category: 'military', status: 'armory_keeper', trait: '신뢰받는', storySeed: '무기고를 철저히 관리한', weight: 8 },
  { id: 'undertaker_dignified', category: 'labor', status: 'undertaker', trait: '존엄을 지키는', storySeed: '망자를 정성껏 모신', weight: 10 },
  { id: 'farmer_respected', category: 'labor', status: 'farmer', trait: '마을의 존경을 받는', storySeed: '풍년을 이끈', weight: 12 },
  { id: 'servant_wise', category: 'labor', status: 'servant', trait: '지혜로운', storySeed: '주인의 신뢰를 얻은', weight: 10 },

  // ===== 7. 여성 직업 (10개) =====
  { id: 'female_physician_healing', category: 'palace', status: 'female_physician', trait: '치유하는', storySeed: '여성들의 병을 고친', weight: 12 },
  { id: 'head_court_lady_dignified', category: 'palace', status: 'head_court_lady', trait: '위엄 있는', storySeed: '내명부를 총괄한', weight: 10 },
  { id: 'embroiderer_artistic', category: 'artisan', status: 'embroiderer', trait: '예술적인', storySeed: '수놓은 작품으로 이름난', weight: 10 },
  { id: 'tavern_lively', category: 'merchant', status: 'tavern_owner', trait: '활기찬', storySeed: '정보가 모이는 주막을 운영한', weight: 10 },
  { id: 'female_shaman_spiritual', category: 'mystical', status: 'female_shaman', trait: '영험한', storySeed: '마을의 안녕을 빈', weight: 10 },
  { id: 'gisaeng_talented', category: 'entertainment', status: 'artistic_gisaeng', trait: '재능 있는', storySeed: '시와 음악으로 이름난', weight: 10 },
  { id: 'wet_nurse_loving', category: 'palace', status: 'wet_nurse', trait: '자애로운', storySeed: '왕자를 키운', weight: 10 },
  { id: 'midwife_lifegiver', category: 'labor', status: 'midwife', trait: '생명을 돕는', storySeed: '수많은 아이를 받은', weight: 12 },
  { id: 'herb_gatherer_nature', category: 'labor', status: 'herb_gatherer', trait: '자연과 교감하는', storySeed: '산속 약초를 찾아다닌', weight: 10 },
  { id: 'weaver_skilled', category: 'artisan', status: 'weaver', trait: '숙련된', storySeed: '비단을 짠', weight: 10 },

  // ===== 8. 예술인 (10개) =====
  { id: 'musician_elegant', category: 'entertainment', status: 'court_musician', trait: '우아한', storySeed: '궁중 연주를 이끈', weight: 10 },
  { id: 'clown_joyful', category: 'entertainment', status: 'clown', trait: '사람들을 웃기는', storySeed: '온 나라에 웃음을 전한', weight: 12 },
  { id: 'tightrope_daring', category: 'entertainment', status: 'tightrope_walker', trait: '전설적인', storySeed: '하늘을 나는 듯한', weight: 10 },
  { id: 'mask_dancer_expressive', category: 'entertainment', status: 'mask_dancer', trait: '표현력 풍부한', storySeed: '탈춤으로 이름난', weight: 10 },
  { id: 'pansori_legendary', category: 'entertainment', status: 'pansori_singer', trait: '감동을 주는', storySeed: '판소리 명창이었던', weight: 10 },
  { id: 'singer_beautiful', category: 'entertainment', status: 'singer', trait: '아름다운 목소리의', storySeed: '노래로 사람들을 울린', weight: 10 },
  { id: 'dancer_graceful', category: 'entertainment', status: 'dancer', trait: '우아한', storySeed: '춤으로 매료시킨', weight: 10 },
  { id: 'drummer_passionate', category: 'entertainment', status: 'drummer', trait: '열정적인', storySeed: '북으로 흥을 돋운', weight: 10 },
  { id: 'geomungo_master_deep', category: 'entertainment', status: 'geomungo_master', trait: '깊은 감성의', storySeed: '거문고의 대가였던', weight: 10 },
  { id: 'flute_master_soulful', category: 'entertainment', status: 'flute_master', trait: '영혼을 울리는', storySeed: '피리 소리로 세상을 감동시킨', weight: 10 },
]

// 시나리오 가중치 기반 랜덤 선택
function selectRandomScenario(): PastLifeScenario {
  const totalWeight = PAST_LIFE_SCENARIOS.reduce((sum, s) => sum + s.weight, 0)
  let random = Math.random() * totalWeight

  for (const scenario of PAST_LIFE_SCENARIOS) {
    random -= scenario.weight
    if (random <= 0) return scenario
  }
  return PAST_LIFE_SCENARIOS[0]
}

// =====================================================
// 얼굴 특징 인터페이스
// =====================================================
interface FaceFeatures {
  faceShape: string       // 둥근/각진/갸름한/하트형
  eyes: { shape: string; size: string }
  eyebrows: { shape: string; thickness: string }
  nose: { bridge: string; tip: string }
  mouth: { size: string; lips: string }
  overallImpression: string[]
}

// 조선시대 시대 구분
const ERAS = ['조선 초기 (15세기)', '조선 중기 (16-17세기)', '조선 후기 (18-19세기)']

// 전생 이름 생성용 성씨와 이름
const SURNAMES = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임', '한', '신', '권', '황', '안']
const MALE_NAMES = ['학문', '도윤', '성현', '태호', '재민', '건우', '정민', '승호', '현우', '진석', '명수', '철수', '영호', '기현', '동혁']
const FEMALE_NAMES = ['설희', '채원', '민지', '수아', '은지', '소연', '하나', '지은', '영숙', '순희', '옥분', '춘화', '미연', '정아', '혜진']

function generateName(gender: string): string {
  const surname = SURNAMES[Math.floor(Math.random() * SURNAMES.length)]
  const names = gender === 'male' ? MALE_NAMES : FEMALE_NAMES
  const name = names[Math.floor(Math.random() * names.length)]
  return `${surname}${name}`
}

function selectRandomGender(): string {
  return Math.random() > 0.5 ? 'male' : 'female'
}

function selectRandomEra(): string {
  return ERAS[Math.floor(Math.random() * ERAS.length)]
}

/**
 * Gemini Vision으로 얼굴 특징 분석
 */
async function analyzeFaceWithVision(imageBase64: string): Promise<FaceFeatures | null> {
  console.log('👤 [PastLife] Analyzing face with Gemini Vision...')

  try {
    const llm = LLMFactory.createFromConfig('fortune-face-reading')

    const prompt = `Analyze this face photo and extract the following features in JSON format:

{
  "faceShape": "둥근" | "각진" | "갸름한" | "하트형" | "타원형",
  "eyes": { "shape": "둥근눈" | "고양이눈" | "처진눈" | "올라간눈", "size": "큰" | "보통" | "작은" },
  "eyebrows": { "shape": "일자" | "아치형" | "각진", "thickness": "굵은" | "보통" | "가는" },
  "nose": { "bridge": "높은" | "보통" | "낮은", "tip": "뾰족한" | "둥근" | "넓은" },
  "mouth": { "size": "큰" | "보통" | "작은", "lips": "도톰한" | "보통" | "얇은" },
  "overallImpression": ["형용사1", "형용사2", "형용사3"]
}

Important: Return ONLY valid JSON, no explanation. Use Korean for values.`

    const response = await llm.generate([
      { role: 'system', content: '당신은 얼굴 특징 분석 전문가입니다. JSON 형식으로만 응답하세요.' },
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          { type: 'image_url', image_url: { url: `data:image/jpeg;base64,${imageBase64}` } }
        ]
      },
    ])

    const jsonMatch = response.content.match(/\{[\s\S]*\}/)
    if (!jsonMatch) {
      console.log('⚠️ [PastLife] Failed to parse face features JSON')
      return null
    }

    const features = JSON.parse(jsonMatch[0]) as FaceFeatures
    console.log('✅ [PastLife] Face features analyzed:', JSON.stringify(features).substring(0, 100))
    return features
  } catch (error) {
    console.error('❌ [PastLife] Face analysis error:', error)
    return null
  }
}

/**
 * 얼굴 특징을 반영한 조선시대 민화 스타일 초상화 프롬프트 생성
 * STATUS_CONFIGS의 새로운 필드(scene, clothing, accessories) 활용
 *
 * 개선된 버전: 분위기/조명, 배경, 포즈, 품질 수식어 랜덤화 적용
 * → 더욱 다양하고 고퀄리티의 이미지 생성
 */
function buildPortraitPrompt(
  status: string,
  gender: string,
  era: string,
  scenario: PastLifeScenario,
  faceFeatures?: FaceFeatures | null
): string {
  const config = STATUS_CONFIGS[status]
  if (!config) {
    console.warn(`⚠️ [PastLife] Unknown status: ${status}, using default`)
  }

  const genderKo = gender === 'male' ? '남성' : '여성'
  const genderEn = gender === 'male' ? 'man' : 'woman'

  // 직업 정보 (fallback 포함)
  const jobKr = config?.kr || '조선시대 인물'
  const jobEn = config?.en || 'Joseon person'
  const jobDesc = config?.desc || 'a person from Joseon dynasty'
  const clothing = config?.clothing || 'traditional hanbok'
  const accessories = config?.accessories || 'traditional items'
  const scene = config?.scene || 'in a dignified pose'

  // 랜덤 요소 선택 (다양성 증가)
  const atmosphere = selectAtmosphere()
  const background = selectBackground(scenario.category)
  const poseOption = selectPose()
  const qualityModifier = selectQualityModifier()

  console.log(`🎨 [PastLife] Prompt variety:`)
  console.log(`   - Atmosphere: ${atmosphere.mood}`)
  console.log(`   - Background: ${background.type}`)
  console.log(`   - Pose mood: ${poseOption.mood}`)

  // 얼굴 특징 설명 생성 (사용자 사진 분석 결과)
  let faceDescription = ''
  if (faceFeatures) {
    faceDescription = `
=== FACIAL FEATURES (From User Photo) ===
The portrait subject MUST have these facial characteristics:
- Face shape: ${faceFeatures.faceShape}
- Eyes: ${faceFeatures.eyes.shape}, ${faceFeatures.eyes.size}
- Eyebrows: ${faceFeatures.eyebrows.shape}, ${faceFeatures.eyebrows.thickness}
- Nose: ${faceFeatures.nose.bridge} bridge, ${faceFeatures.nose.tip} tip
- Mouth: ${faceFeatures.mouth.size}, ${faceFeatures.mouth.lips} lips
- Overall: ${faceFeatures.overallImpression.join(', ')}

Render this person as if they lived in Joseon Dynasty, maintaining their unique facial features.
`
  }

  return `=== KOREAN TRADITIONAL MINHWA PORTRAIT ===

SUBJECT: A ${scenario.trait} ${jobKr} (${jobEn})
A single ${genderEn}, ${jobDesc}, ${scene}.
Story Moment: "${scenario.storySeed}" - ${atmosphere.mood}
Era: ${era}

=== ATMOSPHERE & LIGHTING ===
Mood: ${atmosphere.mood}
Lighting: ${atmosphere.light}
${atmosphere.season ? `Season hint: ${atmosphere.season} elements may subtly appear` : ''}

${MINHWA_STYLE_BASE}

=== CHARACTER DETAILS ===
Occupation: ${jobKr} (${jobEn})
Attire: ${clothing}, appropriate for ${era}
Props/Accessories: ${accessories}
Activity: ${scene}
Personality: ${scenario.trait} (${genderKo})
${faceDescription}

=== COMPOSITION ===
- Single figure portrait (한 명만, one person only)
- Pose: ${poseOption.pose}
- Background: ${background.desc}
- Frame: 2:3 portrait orientation
- Framing: Subject centered, full upper body or 3/4 view
- Depth: Subtle atmospheric perspective separating figure from background

=== ARTISTIC QUALITY ===
${qualityModifier}
- Fine ink outlines (섬세한 먹선) with soft watercolor fills
- Meticulous fabric texture showing the quality of ${clothing}
- Traditional Korean color harmony using natural pigments
- Aged Hanji paper texture visible as subtle base
- Expressive brushwork that conveys ${scenario.trait} personality
- Harmonious balance between figure and ${background.type} background

${MINHWA_FORBIDDEN}`
}

/**
 * Gemini로 조선시대 자화상 스타일 초상화 생성
 * Gemini 2.0 Flash의 이미지 생성 기능 사용
 */
async function generatePortraitWithGemini(prompt: string): Promise<string | null> {
  console.log('🎨 [PastLife] Generating portrait with Gemini...')
  const startTime = Date.now()

  if (!GEMINI_API_KEY) {
    console.log('⚠️ [PastLife] Gemini API key not configured, using fallback')
    return null
  }

  try {
    // Gemini 2.5 Flash 이미지 생성 모델 사용 (통일)
    const imageModel = 'gemini-2.5-flash-image'

    const requestBody = {
      contents: [
        {
          role: 'user',
          parts: [{ text: prompt }],
        },
      ],
      generationConfig: {
        responseModalities: ['TEXT', 'IMAGE'],
      },
    }

    console.log('🔄 [PastLife] Calling Gemini Image Generation API...')
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${imageModel}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: JSON.stringify(requestBody),
      }
    )

    console.log('✅ [PastLife] API call completed, status:', response.status)

    if (!response.ok) {
      const errorText = await response.text()
      console.error(`⚠️ [PastLife] Gemini Image API error: ${response.status} - ${errorText}`)
      return null
    }

    const data = await response.json()

    if (!data.candidates || data.candidates.length === 0) {
      console.error('⚠️ [PastLife] No candidates in Gemini Image response')
      return null
    }

    // 이미지 데이터 추출
    const parts = data.candidates[0].content?.parts || []
    const imagePart = parts.find((p: any) => p.inlineData?.mimeType?.startsWith('image/'))

    if (!imagePart || !imagePart.inlineData) {
      console.error('⚠️ [PastLife] No image data in Gemini response')
      // Text 응답도 로그
      const textPart = parts.find((p: any) => p.text)
      if (textPart) {
        console.log('ℹ️ [PastLife] Gemini text response:', textPart.text?.substring(0, 200))
      }
      return null
    }

    const latency = Date.now() - startTime
    console.log(`✅ [PastLife] Portrait generated in ${latency}ms`)

    return imagePart.inlineData.data
  } catch (error) {
    console.error('⚠️ [PastLife] Gemini image generation error:', error)
    return null
  }
}

/**
 * Supabase Storage에 이미지 업로드
 */
async function uploadPortraitToStorage(
  imageBase64: string,
  userId: string
): Promise<string> {
  console.log('📤 [PastLife] Uploading portrait to storage...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // Base64를 Blob으로 변환
  const imageBuffer = Uint8Array.from(atob(imageBase64), (c) => c.charCodeAt(0))
  const fileName = `${userId}/past_life_${Date.now()}.png`

  const { data, error } = await supabase.storage
    .from('past-life-portraits')
    .upload(fileName, imageBuffer, {
      contentType: 'image/png',
      upsert: false,
    })

  if (error) {
    console.error('❌ [PastLife] Upload error:', error)
    throw new Error(`Upload failed: ${error.message}`)
  }

  const { data: publicUrlData } = supabase.storage
    .from('past-life-portraits')
    .getPublicUrl(fileName)

  console.log('✅ [PastLife] Portrait uploaded:', publicUrlData.publicUrl)
  return publicUrlData.publicUrl
}

// =====================================================
// 이미지 Pool 관련 함수
// 각 status(직업)당 3개까지 저장 후 재사용
// =====================================================

const MAX_PORTRAITS_PER_STATUS = 3

/**
 * Pool에서 status별 이미지 개수 조회
 */
async function getPortraitCountForStatus(
  status: string,
  gender: string
): Promise<number> {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  try {
    const { data, error } = await supabase.rpc('get_portrait_count_for_status', {
      p_status: status,
      p_gender: gender,
    })

    if (error) {
      console.error('⚠️ [PastLife] Error getting portrait count:', error)
      return 0
    }

    return data || 0
  } catch (e) {
    console.error('⚠️ [PastLife] Exception getting portrait count:', e)
    return 0
  }
}

/**
 * Pool에서 랜덤 이미지 가져오기
 */
async function getRandomPortraitFromPool(
  status: string,
  gender: string
): Promise<string | null> {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  try {
    const { data, error } = await supabase.rpc('get_random_portrait_for_status', {
      p_status: status,
      p_gender: gender,
    })

    if (error) {
      console.error('⚠️ [PastLife] Error getting random portrait:', error)
      return null
    }

    if (data && data.length > 0) {
      console.log(`♻️ [PastLife] Reusing portrait from pool for ${status}/${gender}`)
      return data[0].portrait_url
    }

    return null
  } catch (e) {
    console.error('⚠️ [PastLife] Exception getting random portrait:', e)
    return null
  }
}

/**
 * 신분별 기본 초상화 URL 반환 (Fallback용)
 */
function getDefaultPortraitUrl(status: string): string {
  const statusFallbacks: Record<string, string> = {
    king: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-king.jpg',
    queen: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-queen.jpg',
    gisaeng: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-gisaeng.jpg',
    scholar: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-scholar.jpg',
    warrior: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-warrior.jpg',
    noble: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-noble.jpg',
    merchant: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-merchant.jpg',
    farmer: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-farmer.jpg',
    monk: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-monk.jpg',
    artisan: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-artisan.jpg',
    shaman: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-shaman.jpg',
    servant: 'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-servant.jpg',
  }

  return statusFallbacks[status] ||
    'https://uqshnmhpdjqduwdypgxr.supabase.co/storage/v1/object/public/assets/past-life/default-portrait.jpg'
}

/**
 * 새 이미지를 Pool에 저장
 */
async function savePortraitToPool(
  status: string,
  statusKr: string,
  statusEn: string,
  gender: string,
  portraitUrl: string,
  portraitPrompt: string
): Promise<boolean> {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  try {
    const { data, error } = await supabase.rpc('save_portrait_to_pool', {
      p_status: status,
      p_status_kr: statusKr,
      p_status_en: statusEn,
      p_gender: gender,
      p_portrait_url: portraitUrl,
      p_portrait_prompt: portraitPrompt,
      p_max_per_status: MAX_PORTRAITS_PER_STATUS,
    })

    if (error) {
      console.error('⚠️ [PastLife] Error saving to pool:', error)
      return false
    }

    if (data) {
      console.log(`💾 [PastLife] Portrait saved to pool: ${status}/${gender}`)
    } else {
      console.log(`ℹ️ [PastLife] Pool full for ${status}/${gender}, not saving`)
    }

    return data || false
  } catch (e) {
    console.error('⚠️ [PastLife] Exception saving to pool:', e)
    return false
  }
}

/**
 * 스토리 챕터 인터페이스
 */
interface StoryChapter {
  title: string
  content: string
  emoji: string
}

/**
 * LLM으로 전생 스토리 생성 (V2.1 Dynamic Story - 5챕터 플롯 시스템)
 */
async function generatePastLifeStory(
  scenario: PastLifeScenario,
  statusKr: string,
  gender: string,
  era: string,
  name: string,
  userName: string,
  userBirthDate: string,
  faceFeatures?: FaceFeatures | null
): Promise<{
  story: string
  summary: string
  advice: string
  score: number
  chapters: StoryChapter[]
  plotType: PlotType
  llmResponse: any  // LLMResponse for usage logging
}> {
  console.log('📝 [PastLife] Generating dynamic story with 5 chapters...')

  const llm = LLMFactory.createFromConfig('fortune-past-life')
  const genderKo = gender === 'male' ? '남성' : '여성'

  // 플롯 템플릿 선택 (카테고리 기반)
  const plot = selectPlotTemplate(scenario.category)
  console.log(`🎭 [PastLife] Selected plot: ${plot.name} (${plot.nameKr})`)

  // 얼굴 특징 기반 성격 힌트
  let personalityHint = ''
  if (faceFeatures) {
    personalityHint = `
## 외모 기반 성격 힌트
- 얼굴형: ${faceFeatures.faceShape}
- 눈: ${faceFeatures.eyes.shape}, ${faceFeatures.eyes.size}
- 전체 인상: ${faceFeatures.overallImpression.join(', ')}
이 외모적 특징을 전생 캐릭터의 외양과 성격에 자연스럽게 녹여주세요.`
  }

  const prompt = `당신은 조선시대 전생 이야기를 들려주는 소설가입니다. 드라마틱하고 몰입감 있는 스토리를 만들어주세요.

## 플롯 유형: ${plot.nameKr} (${plot.name})
- **전개 구조**: ${plot.arc.join(' → ')}
- **톤과 분위기**: ${plot.tone}
- **결말 방향**: ${plot.ending}
- **서술 스타일**: ${plot.writingStyle}

## 전생 정보
- 신분: ${statusKr}
- 이름: ${name}
- 시대: ${era}
- 성별: ${genderKo}
- 특징: ${scenario.trait} 인물
- 배경: ${scenario.storySeed}
${personalityHint}

## 스토리텔링 핵심 규칙

### 필수 요소 (매우 중요!)
1. **대화 포함**: 각 챕터에 반드시 1-2개의 생생한 대사 (따옴표로 감싸기)
   - 예시: "미쳤군! 여자가 물길을 바꾸겠다고?"
2. **감각 묘사**: 시각/청각/촉각 중 최소 1개
   - 예시: "손바닥이 찢어지고", "황금빛으로 물들었다"
3. **감정 표현**: 캐릭터의 내면 심리 드러내기
4. **시대적 디테일**: 조선시대 특유의 문화, 관습, 배경 반영
5. **서술체**: "~했습니다"로 끝나지 않고 "~했다", "~였다" 등 문학적 서술

### 피해야 할 것 (절대 금지)
❌ "~했습니다", "~입니다"로 끝나는 설명적 서술
❌ 감정 없이 사실만 나열하는 방식
❌ 뻔하고 예측 가능한 전개
❌ 추상적이고 모호한 표현

### 챕터 작성법 (각 150-250자)

**챕터 1: ${plot.arc[0]}** (${plot.emojis[0]})
- 흥미로운 첫 문장으로 훅(Hook) 만들기
- 주인공의 특별함 암시하는 복선
- 독자를 단숨에 사로잡기

**챕터 2: ${plot.arc[1]}** (${plot.emojis[1]})
- 핵심 갈등 또는 기회 등장
- 주인공의 결정적 선택
- 긴장감 고조

**챕터 3: ${plot.arc[2]}** (${plot.emojis[2]}) [클라이맥스]
- 가장 극적인 장면
- 감정의 정점
- ${plot.name === 'TRAGEDY' ? '운명의 어두운 그림자' : plot.name === 'ROMANCE' ? '사랑의 시험' : '결정적 순간'}

**챕터 4: ${plot.arc[3]}** (${plot.emojis[3]})
- 트위스트 또는 전환점
- 독자 예상을 뒤엎는 전개
- 결과의 시작

**챕터 5: ${plot.arc[4]}** (${plot.emojis[4]})
- 여운 있는 마무리
- 현생과의 연결 암시
- ${plot.ending}

### 예시 (좋은 서술)
"저 아이 눈빛 좀 봐. 범상치 않아." 산파 할멈의 말에 아버지는 코웃음 쳤다. 하지만 어린 순희가 가뭄에 시든 밭에서 물줄기를 찾아낸 그날, 마을 사람들은 할멈의 말을 떠올렸다. 흙 묻은 손으로 하늘을 가리키던 다섯 살 순희의 이야기는 그렇게 시작되었다.

### summary (FREE 콘텐츠)
1-2문장으로 독자의 흥미를 끄는 요약.
형식: "당신의 전생은 ${era} ${scenario.trait} ${statusKr}이었습니다. [한 줄 훅]"

### advice (BLUR 콘텐츠)
150-200자. 전생과 현생의 연결점, 그리고 이번 생에서의 조언.

### score
1-100 점. ${statusKr} 기준 점수 범위 내에서 스토리 완성도에 따라 조정.

## JSON 응답 형식 (정확히 따라주세요)
{
  "plotType": "${plot.name}",
  "summary": "당신의 전생은...",
  "chapters": [
    { "title": "${plot.arc[0]}", "content": "...", "emoji": "${plot.emojis[0]}" },
    { "title": "${plot.arc[1]}", "content": "...", "emoji": "${plot.emojis[1]}" },
    { "title": "${plot.arc[2]}", "content": "...", "emoji": "${plot.emojis[2]}" },
    { "title": "${plot.arc[3]}", "content": "...", "emoji": "${plot.emojis[3]}" },
    { "title": "${plot.arc[4]}", "content": "...", "emoji": "${plot.emojis[4]}" }
  ],
  "advice": "현생과의 연결점...",
  "score": 85
}`

  const systemPrompt = `당신은 조선시대를 배경으로 한 전생 이야기 전문 작가입니다.

역할:
- 독자의 마음을 사로잡는 드라마틱한 스토리텔러
- 조선시대의 역사와 문화에 정통한 전문가
- JSON 형식으로 정확하게 응답하는 AI

규칙:
1. 반드시 5개 챕터를 모두 작성
2. 각 챕터는 150-250자 (한글 기준)
3. 대화와 감각 묘사 필수
4. "${plot.nameKr}" 플롯의 톤과 결말 방향 준수
5. JSON 형식 엄수`

  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: prompt },
  ])

  // JSON 파싱
  const content = response.content
  const jsonMatch = content.match(/\{[\s\S]*\}/)
  if (!jsonMatch) {
    throw new Error('Failed to parse LLM response as JSON')
  }

  const parsed = JSON.parse(jsonMatch[0])

  // story는 chapters를 합친 전체 이야기
  const fullStory = parsed.chapters
    .map((ch: StoryChapter) => `${ch.emoji} ${ch.title}\n${ch.emoji} ${ch.content}`)
    .join('\n\n')

  return {
    story: fullStory,
    summary: parsed.summary || '',
    advice: parsed.advice || '',
    score: parsed.score || 75,
    chapters: parsed.chapters || [],
    plotType: plot.name,
    llmResponse: response,
  }
}

/**
 * 결과를 DB에 저장
 */
async function savePastLifeResult(
  userId: string,
  scenario: PastLifeScenario,
  statusKr: string,
  statusEn: string,
  gender: string,
  era: string,
  name: string,
  story: string,
  summary: string,
  portraitUrl: string,
  portraitPrompt: string,
  advice: string,
  score: number,
  chapters: StoryChapter[],
  faceFeatures?: FaceFeatures | null
): Promise<string> {
  console.log('💾 [PastLife] Saving result to database...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  const { data, error } = await supabase
    .from('past_life_results')
    .insert({
      user_id: userId,
      past_life_status: statusKr,
      past_life_status_en: statusEn,
      past_life_gender: gender,
      past_life_era: era,
      past_life_name: name,
      story_text: story,
      story_summary: summary,
      portrait_url: portraitUrl,
      portrait_prompt: portraitPrompt,
      advice: advice,
      score: score,
      // V2 추가 필드
      scenario_id: scenario.id,
      scenario_category: scenario.category,
      scenario_trait: scenario.trait,
      chapters: chapters,
      face_features: faceFeatures || null,
    })
    .select('id')
    .single()

  if (error) {
    console.error('❌ [PastLife] Database insert error:', error)
    throw new Error(`Database insert failed: ${error.message}`)
  }

  console.log('✅ [PastLife] Result saved, id:', data.id)
  return data.id
}

/**
 * 블러 처리 적용
 * FREE: summary, status, score
 * BLUR: chapters, advice, portrait (full quality)
 */
function applyBlurring(fortune: any, isPremium: boolean): any {
  if (isPremium) {
    return { ...fortune, isBlurred: false, blurredSections: [] }
  }

  return {
    ...fortune,
    isBlurred: true,
    blurredSections: ['chapters', 'advice', 'portrait_full'],
  }
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const startTime = Date.now()

  try {
    const requestData = await req.json()
    const {
      userId,
      name: userName = '사용자',
      birthDate: userBirthDate,
      birthTime,
      gender: userGender,
      isPremium = false,
      // V2: 얼굴 이미지 관련
      faceImageBase64,
      useProfilePhoto = false,
    } = requestData

    console.log('🔮 [PastLife] V2 전생 운세 요청 시작')
    console.log(`   - 사용자: ${userName}`)
    console.log(`   - 생년월일: ${userBirthDate}`)
    console.log(`   - Premium: ${isPremium}`)
    console.log(`   - 얼굴 이미지: ${faceImageBase64 ? '있음' : '없음'}`)

    // 필수 필드 검증
    if (!userId || !userBirthDate) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userId, birthDate' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 1. 얼굴 분석 (이미지가 있는 경우)
    let faceFeatures: FaceFeatures | null = null
    if (faceImageBase64) {
      faceFeatures = await analyzeFaceWithVision(faceImageBase64)
    }

    // 2. 전생 시나리오 선택 (30개 중 랜덤)
    const scenario = selectRandomScenario()
    const statusConfig = STATUS_CONFIGS[scenario.status]
    const pastLifeGender = selectRandomGender()
    const pastLifeEra = selectRandomEra()
    const pastLifeName = generateName(pastLifeGender)

    console.log(`   - 시나리오: ${scenario.id} (${scenario.category})`)
    console.log(`   - 전생 신분: ${statusConfig.kr} (${scenario.status})`)
    console.log(`   - 특성: ${scenario.trait}, ${scenario.storySeed}`)
    console.log(`   - 전생 성별: ${pastLifeGender}`)
    console.log(`   - 전생 시대: ${pastLifeEra}`)
    console.log(`   - 전생 이름: ${pastLifeName}`)

    // 3. 초상화 프롬프트 생성 (얼굴 특징 포함)
    const portraitPrompt = buildPortraitPrompt(
      scenario.status,
      pastLifeGender,
      pastLifeEra,
      scenario,
      faceFeatures
    )

    // 4. 이미지 Pool 확인 후 초상화 결정
    //    - 얼굴 이미지가 있으면: 항상 새로 생성 (개인화)
    //    - 없으면: Pool에서 재사용 (status+gender당 3개까지)
    let portraitUrl: string
    let isFromPool = false

    if (faceImageBase64) {
      // 얼굴 이미지 제공됨 → 개인화 필요, 항상 새로 생성
      console.log('👤 [PastLife] Face image provided, generating personalized portrait...')
      const imageBase64 = await generatePortraitWithGemini(portraitPrompt)

      if (imageBase64) {
        portraitUrl = await uploadPortraitToStorage(imageBase64, userId)
        // 개인화된 이미지는 Pool에 저장하지 않음 (재사용 불가)
      } else {
        // Fallback 사용
        portraitUrl = getDefaultPortraitUrl(scenario.status)
        console.log(`📷 [PastLife] Using fallback portrait for ${scenario.status}`)
      }
    } else {
      // 얼굴 이미지 없음 → Pool 확인 후 재사용/생성
      const poolCount = await getPortraitCountForStatus(scenario.status, pastLifeGender)
      console.log(`🔍 [PastLife] Pool check: ${scenario.status}/${pastLifeGender} = ${poolCount}/${MAX_PORTRAITS_PER_STATUS}`)

      if (poolCount >= MAX_PORTRAITS_PER_STATUS) {
        // Pool에 충분한 이미지 있음 → 재사용
        const poolPortrait = await getRandomPortraitFromPool(scenario.status, pastLifeGender)

        if (poolPortrait) {
          portraitUrl = poolPortrait
          isFromPool = true
          console.log(`♻️ [PastLife] Reusing portrait from pool`)
        } else {
          // Pool 조회 실패 → 새로 생성
          const imageBase64 = await generatePortraitWithGemini(portraitPrompt)
          if (imageBase64) {
            portraitUrl = await uploadPortraitToStorage(imageBase64, userId)
          } else {
            portraitUrl = getDefaultPortraitUrl(scenario.status)
          }
        }
      } else {
        // Pool이 아직 부족함 → 새로 생성 후 Pool에 저장
        console.log(`🎨 [PastLife] Pool not full, generating new portrait...`)
        const imageBase64 = await generatePortraitWithGemini(portraitPrompt)

        if (imageBase64) {
          portraitUrl = await uploadPortraitToStorage(imageBase64, userId)

          // Pool에 저장 (비동기, 실패해도 무시)
          savePortraitToPool(
            scenario.status,
            statusConfig.kr,
            statusConfig.en,
            pastLifeGender,
            portraitUrl,
            portraitPrompt
          ).catch(err => console.error('⚠️ [PastLife] Failed to save to pool:', err))
        } else {
          portraitUrl = getDefaultPortraitUrl(scenario.status)
          console.log(`📷 [PastLife] Using fallback portrait for ${scenario.status}`)
        }
      }
    }

    console.log(`   - 초상화 URL: ${portraitUrl.substring(0, 80)}...`)
    console.log(`   - Pool에서 재사용: ${isFromPool}`)

    // 6. LLM으로 5챕터 동적 스토리 생성 (V2.1)
    const { story, summary, advice, score, chapters, plotType, llmResponse } = await generatePastLifeStory(
      scenario,
      statusConfig.kr,
      pastLifeGender,
      pastLifeEra,
      pastLifeName,
      userName,
      userBirthDate,
      faceFeatures
    )

    // 7. DB에 저장
    const recordId = await savePastLifeResult(
      userId,
      scenario,
      statusConfig.kr,
      statusConfig.en,
      pastLifeGender,
      pastLifeEra,
      pastLifeName,
      story,
      summary,
      portraitUrl,
      portraitPrompt,
      advice,
      score,
      chapters,
      faceFeatures
    )

    // 8. 응답 구성
    const fortune = {
      id: recordId,
      fortuneType: 'past-life',
      // 기본 정보
      pastLifeStatus: statusConfig.kr,
      pastLifeStatusEn: statusConfig.en,
      pastLifeGender: pastLifeGender,
      pastLifeEra: pastLifeEra,
      pastLifeName: pastLifeName,
      // 시나리오 정보
      scenarioId: scenario.id,
      scenarioCategory: scenario.category,
      scenarioTrait: scenario.trait,
      plotType: plotType,  // V2.1: 플롯 유형 (TRAGEDY/TRIUMPH/ROMANCE/MYSTERY/ADVENTURE)
      // 콘텐츠
      story: story,
      summary: summary,
      chapters: chapters,
      portraitUrl: portraitUrl,
      advice: advice,
      score: score,
      // 얼굴 특징 (있는 경우)
      faceFeatures: faceFeatures,
      timestamp: new Date().toISOString(),
    }

    // 블러 처리
    const processedFortune = applyBlurring(fortune, isPremium)

    // 사용량 로깅 - 올바른 패턴 (fortune-tarot 참조)
    UsageLogger.log({
      userId,
      fortuneType: 'past-life',
      provider: llmResponse.provider,
      model: llmResponse.model,
      response: llmResponse,
      metadata: {
        hasImage: !!faceImageBase64,
        hasFaceAnalysis: !!faceFeatures,
        isPremium,
        scenarioId: scenario.id,
        scenarioCategory: scenario.category,
        // 이미지 Pool 관련 메타데이터
        portraitFromPool: isFromPool,
        portraitStatus: scenario.status,
        portraitGender: pastLifeGender,
      },
    }).catch(console.error)

    console.log(`🎉 [PastLife] V2 완료! 총 소요시간: ${Date.now() - startTime}ms`)

    return new Response(
      JSON.stringify({ fortune: processedFortune }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
      }
    )
  } catch (error) {
    console.error('❌ [PastLife] Error:', error)

    // 에러 로깅 - UsageLogger.logError 사용
    UsageLogger.logError(
      'past-life',
      'gemini',
      'gemini-2.0-flash',
      error instanceof Error ? error.message : 'Unknown error',
      undefined,
      { latencyMs: Date.now() - startTime }
    ).catch(console.error)

    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
