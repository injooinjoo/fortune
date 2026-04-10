/* ------------------------------------------------------------------ */
/*  Birthstone data — monthly + daily lookup                           */
/* ------------------------------------------------------------------ */

export interface MonthlyBirthstone {
  month: number;
  name: string;
  nameEn: string;
  emoji: string;
  meaning: string;
  color: string;
}

export interface DailyBirthstone {
  month: number;
  day: number;
  name: string;
  nameEn: string;
}

/* ------------------------------------------------------------------ */
/*  Monthly birthstones (standard 12-month list)                       */
/* ------------------------------------------------------------------ */

const MONTHLY_BIRTHSTONES: MonthlyBirthstone[] = [
  { month: 1, name: '석류석', nameEn: 'Garnet', emoji: '💎', meaning: '사랑, 진실, 우정', color: '#C41E3A' },
  { month: 2, name: '자수정', nameEn: 'Amethyst', emoji: '💜', meaning: '성실, 평화', color: '#9966CC' },
  { month: 3, name: '남옥', nameEn: 'Aquamarine', emoji: '💙', meaning: '침착, 총명, 용감', color: '#7FFFD4' },
  { month: 4, name: '금강석', nameEn: 'Diamond', emoji: '💎', meaning: '영원한 사랑, 불멸', color: '#B9F2FF' },
  { month: 5, name: '취옥', nameEn: 'Emerald', emoji: '💚', meaning: '행복, 행운', color: '#50C878' },
  { month: 6, name: '진주', nameEn: 'Pearl', emoji: '🤍', meaning: '순결, 건강, 부귀', color: '#FDEEF4' },
  { month: 7, name: '홍옥', nameEn: 'Ruby', emoji: '❤️', meaning: '열정, 사랑, 평화', color: '#E0115F' },
  { month: 8, name: '감람석', nameEn: 'Peridot', emoji: '💛', meaning: '부부의 행복, 지혜', color: '#B4C424' },
  { month: 9, name: '청옥', nameEn: 'Sapphire', emoji: '💙', meaning: '자애, 성실, 덕망', color: '#0F52BA' },
  { month: 10, name: '단백석', nameEn: 'Opal', emoji: '🤍', meaning: '희망, 순결', color: '#A8C3BC' },
  { month: 11, name: '황옥', nameEn: 'Topaz', emoji: '💛', meaning: '우정, 인내, 건강', color: '#FFC87C' },
  { month: 12, name: '녹송석', nameEn: 'Turquoise', emoji: '💎', meaning: '행운, 성공, 승리', color: '#30D5C8' },
];

/* ------------------------------------------------------------------ */
/*  Daily birthstones (January–July partial coverage)                   */
/* ------------------------------------------------------------------ */

const DAILY_BIRTHSTONES: DailyBirthstone[] = [
  // January
  { month: 1, day: 1, name: '재드', nameEn: 'Jade' },
  { month: 1, day: 2, name: '크리소베릴', nameEn: 'Chrysoberyl' },
  { month: 1, day: 3, name: '토파졸라이트', nameEn: 'Topazolite' },
  { month: 1, day: 4, name: '크리소콜라', nameEn: 'Chrysocolla' },
  { month: 1, day: 5, name: '지르콘', nameEn: 'Zircon' },
  { month: 1, day: 6, name: '오브시디언', nameEn: 'Obsidian' },
  { month: 1, day: 7, name: '암모라이트', nameEn: 'Ammolite' },
  { month: 1, day: 8, name: '그린 투어말린', nameEn: 'Green Tourmaline' },
  { month: 1, day: 9, name: '그로슈러라이트', nameEn: 'Grossularite' },
  { month: 1, day: 10, name: '골드', nameEn: 'Gold' },
  { month: 1, day: 11, name: '헤마타이트', nameEn: 'Hematite' },
  { month: 1, day: 12, name: '골드스톤', nameEn: 'Goldstone' },
  { month: 1, day: 13, name: '오렌지 자수정', nameEn: 'Orange Amethyst' },
  { month: 1, day: 14, name: '라임 크리스탈', nameEn: 'Lime Crystal' },
  { month: 1, day: 15, name: '인디안 스타 루비', nameEn: 'Indian Star Ruby' },
  { month: 1, day: 16, name: '블루 문스톤', nameEn: 'Blue Moonstone' },
  { month: 1, day: 17, name: '불의 오팔', nameEn: 'Fire Opal' },
  { month: 1, day: 18, name: '로제 석류석', nameEn: 'Roselite Garnet' },
  { month: 1, day: 19, name: '비스머스', nameEn: 'Bismuth' },
  { month: 1, day: 20, name: '스노우플레이크 옵시디언', nameEn: 'Snowflake Obsidian' },
  { month: 1, day: 21, name: '피콕 오팔', nameEn: 'Peacock Opal' },
  { month: 1, day: 22, name: '스타 베릴', nameEn: 'Star Beryl' },
  { month: 1, day: 23, name: '알렉산드라이트', nameEn: 'Alexandrite' },
  { month: 1, day: 24, name: '밀키 오팔', nameEn: 'Milky Opal' },
  { month: 1, day: 25, name: '사디나이트', nameEn: 'Sardonyx' },
  { month: 1, day: 26, name: '파이로프 가넷', nameEn: 'Pyrope Garnet' },
  { month: 1, day: 27, name: '알만다인 가넷', nameEn: 'Almandine Garnet' },
  { month: 1, day: 28, name: '핑크 토파즈', nameEn: 'Pink Topaz' },
  { month: 1, day: 29, name: '크리스탈 쿼츠', nameEn: 'Crystal Quartz' },
  { month: 1, day: 30, name: '파르사이트', nameEn: 'Parsite' },
  { month: 1, day: 31, name: '알렉산드라이트 캐츠아이', nameEn: 'Alexandrite Cat\'s Eye' },
  // February
  { month: 2, day: 1, name: '울렉사이트', nameEn: 'Ulexite' },
  { month: 2, day: 2, name: '코닝카이트', nameEn: 'Conicalcite' },
  { month: 2, day: 3, name: '라브라도라이트', nameEn: 'Labradorite' },
  { month: 2, day: 4, name: '바이컬러 자수정', nameEn: 'Bicolor Amethyst' },
  { month: 2, day: 5, name: '라피스 라줄리', nameEn: 'Lapis Lazuli' },
  { month: 2, day: 6, name: '스타 그레이 사파이어', nameEn: 'Star Grey Sapphire' },
  { month: 2, day: 7, name: '카이아나이트', nameEn: 'Kyanite' },
  { month: 2, day: 8, name: '루틸레이티드 쿼츠', nameEn: 'Rutilated Quartz' },
  { month: 2, day: 9, name: '레드 재스퍼', nameEn: 'Red Jasper' },
  { month: 2, day: 10, name: '레드 타이거아이', nameEn: 'Red Tiger Eye' },
  { month: 2, day: 11, name: '워터멜론 투어말린', nameEn: 'Watermelon Tourmaline' },
  { month: 2, day: 12, name: '옐로 스피넬', nameEn: 'Yellow Spinel' },
  { month: 2, day: 13, name: '바이컬러 플루오라이트', nameEn: 'Bicolor Fluorite' },
  { month: 2, day: 14, name: '핑크 오팔', nameEn: 'Pink Opal' },
  { month: 2, day: 15, name: '핑크 지르콘', nameEn: 'Pink Zircon' },
  { month: 2, day: 16, name: '오렌지 투어말린', nameEn: 'Orange Tourmaline' },
  { month: 2, day: 17, name: '타이거 아이언', nameEn: 'Tiger Iron' },
  { month: 2, day: 18, name: '오렌지 토파즈', nameEn: 'Orange Topaz' },
  { month: 2, day: 19, name: '워터 드롭 쿼츠', nameEn: 'Water Drop Quartz' },
  { month: 2, day: 20, name: '그레이 색시나이트', nameEn: 'Grey Saxonite' },
  { month: 2, day: 21, name: '혼', nameEn: 'Horn' },
  { month: 2, day: 22, name: '캐츠아이 쿼츠', nameEn: 'Cat\'s Eye Quartz' },
  { month: 2, day: 23, name: '뉴마이트', nameEn: 'Nuummite' },
  { month: 2, day: 24, name: '화이트 펄', nameEn: 'White Pearl' },
  { month: 2, day: 25, name: '판타즘 쿼츠', nameEn: 'Phantom Quartz' },
  { month: 2, day: 26, name: '이글 스톤', nameEn: 'Eagle Stone' },
  { month: 2, day: 27, name: '알만딘 그로슈러', nameEn: 'Almandine Grossular' },
  { month: 2, day: 28, name: '코랄', nameEn: 'Coral' },
  { month: 2, day: 29, name: '팔라사이트', nameEn: 'Pallasite' },
  // March
  { month: 3, day: 1, name: '형석', nameEn: 'Fluorite' },
  { month: 3, day: 2, name: '쉘 오팔', nameEn: 'Shell Opal' },
  { month: 3, day: 3, name: '모르가나이트', nameEn: 'Morganite' },
  { month: 3, day: 4, name: '실버', nameEn: 'Silver' },
  { month: 3, day: 5, name: '로열 블루 사파이어', nameEn: 'Royal Blue Sapphire' },
  { month: 3, day: 6, name: '버밀리언', nameEn: 'Vermilion' },
  { month: 3, day: 7, name: '아크로아이트', nameEn: 'Achroite' },
  { month: 3, day: 8, name: '아쿠아프레이즈', nameEn: 'Aquaprase' },
  { month: 3, day: 9, name: '실버 펄', nameEn: 'Silver Pearl' },
  { month: 3, day: 10, name: '레인보우 세이버', nameEn: 'Rainbow Saber' },
  { month: 3, day: 11, name: '이네사이트', nameEn: 'Inesite' },
  { month: 3, day: 12, name: '아쿠아마린 원석', nameEn: 'Aquamarine Rough' },
  { month: 3, day: 13, name: '옐로 다이아몬드', nameEn: 'Yellow Diamond' },
  { month: 3, day: 14, name: '컬러리스 스피넬', nameEn: 'Colorless Spinel' },
  { month: 3, day: 15, name: '오렌지 문스톤', nameEn: 'Orange Moonstone' },
  { month: 3, day: 16, name: '로즈 쿼츠', nameEn: 'Rose Quartz' },
  { month: 3, day: 17, name: '에메랄드 원석', nameEn: 'Emerald Rough' },
  { month: 3, day: 18, name: '에머랄드 캐츠아이', nameEn: 'Emerald Cat\'s Eye' },
  { month: 3, day: 19, name: '바이컬러 쿼츠', nameEn: 'Bicolor Quartz' },
  { month: 3, day: 20, name: '툴마린 원석', nameEn: 'Tourmaline Rough' },
  { month: 3, day: 21, name: '아이언', nameEn: 'Iron' },
  { month: 3, day: 22, name: '소달라이트', nameEn: 'Sodalite' },
  { month: 3, day: 23, name: '픽처 재스퍼', nameEn: 'Picture Jasper' },
  { month: 3, day: 24, name: '그린 아벤츄린', nameEn: 'Green Aventurine' },
  { month: 3, day: 25, name: '핑크 지르콘', nameEn: 'Pink Zircon' },
  { month: 3, day: 26, name: '플래티넘', nameEn: 'Platinum' },
  { month: 3, day: 27, name: '퍼플 지르콘', nameEn: 'Purple Zircon' },
  { month: 3, day: 28, name: '핑크 골드', nameEn: 'Pink Gold' },
  { month: 3, day: 29, name: '마카사이트', nameEn: 'Marcasite' },
  { month: 3, day: 30, name: '엔젤 스킨 코랄', nameEn: 'Angel Skin Coral' },
  { month: 3, day: 31, name: '옐로우 오르토클레이즈', nameEn: 'Yellow Orthoclase' },
  // April
  { month: 4, day: 1, name: '헤르키머 다이아몬드', nameEn: 'Herkimer Diamond' },
  { month: 4, day: 2, name: '세미바로크 펄', nameEn: 'Semi-Baroque Pearl' },
  { month: 4, day: 3, name: '스위트 자수정', nameEn: 'Sweet Amethyst' },
  { month: 4, day: 4, name: '크리소콜라', nameEn: 'Chrysocolla' },
  { month: 4, day: 5, name: '컬러리스 사파이어', nameEn: 'Colorless Sapphire' },
  { month: 4, day: 6, name: '블루 다이아몬드', nameEn: 'Blue Diamond' },
  { month: 4, day: 7, name: '에그 펄', nameEn: 'Egg Pearl' },
  { month: 4, day: 8, name: '파파라챠 사파이어', nameEn: 'Padparadscha Sapphire' },
  { month: 4, day: 9, name: '세라사이트', nameEn: 'Cerasite' },
  { month: 4, day: 10, name: '컬러리스 지르콘', nameEn: 'Colorless Zircon' },
  { month: 4, day: 11, name: '옐로우 지르콘', nameEn: 'Yellow Zircon' },
  { month: 4, day: 12, name: '핑크 플루오라이트', nameEn: 'Pink Fluorite' },
  { month: 4, day: 13, name: '바이올렛 펄', nameEn: 'Violet Pearl' },
  { month: 4, day: 14, name: '아파타이트', nameEn: 'Apatite' },
  { month: 4, day: 15, name: '펄', nameEn: 'Pearl' },
  { month: 4, day: 16, name: '히드나이트', nameEn: 'Hiddenite' },
  { month: 4, day: 17, name: '그린 스피넬', nameEn: 'Green Spinel' },
  { month: 4, day: 18, name: '프리나이트', nameEn: 'Prehnite' },
  { month: 4, day: 19, name: '바이올렛 지르콘', nameEn: 'Violet Zircon' },
  { month: 4, day: 20, name: '조다이사이트', nameEn: 'Jadeite' },
  { month: 4, day: 21, name: '안달루사이트', nameEn: 'Andalusite' },
  { month: 4, day: 22, name: '카멜리안', nameEn: 'Carnelian' },
  { month: 4, day: 23, name: '사막 장미', nameEn: 'Desert Rose' },
  { month: 4, day: 24, name: '쿤자이트', nameEn: 'Kunzite' },
  { month: 4, day: 25, name: '그린 가넷', nameEn: 'Green Garnet' },
  { month: 4, day: 26, name: '아마존아이트', nameEn: 'Amazonite' },
  { month: 4, day: 27, name: '카넬리안', nameEn: 'Carnelian' },
  { month: 4, day: 28, name: '킴벌라이트', nameEn: 'Kimberlite' },
  { month: 4, day: 29, name: '히든 다이아몬드', nameEn: 'Hidden Diamond' },
  { month: 4, day: 30, name: '파이버라이트 캐츠아이', nameEn: 'Fiberolite Cat\'s Eye' },
  // May
  { month: 5, day: 1, name: '아마존아이트', nameEn: 'Amazonite' },
  { month: 5, day: 2, name: '옐로 베릴', nameEn: 'Yellow Beryl' },
  { month: 5, day: 3, name: '그린 지르콘', nameEn: 'Green Zircon' },
  { month: 5, day: 4, name: '펠드스파', nameEn: 'Feldspar' },
  { month: 5, day: 5, name: '레드 코랄', nameEn: 'Red Coral' },
  { month: 5, day: 6, name: '아이도크레이즈', nameEn: 'Idocrase' },
  { month: 5, day: 7, name: '화이트 골드', nameEn: 'White Gold' },
  { month: 5, day: 8, name: '에메랄드 캐츠아이', nameEn: 'Emerald Cat\'s Eye' },
  { month: 5, day: 9, name: '블랙 펄', nameEn: 'Black Pearl' },
  { month: 5, day: 10, name: '타이거아이', nameEn: 'Tiger Eye' },
  { month: 5, day: 11, name: '골든 베릴', nameEn: 'Golden Beryl' },
  { month: 5, day: 12, name: '카코제나이트', nameEn: 'Cacoxenite' },
  { month: 5, day: 13, name: '아이보리', nameEn: 'Ivory' },
  { month: 5, day: 14, name: '블루 그린 지르콘', nameEn: 'Blue Green Zircon' },
  { month: 5, day: 15, name: '레드 제이드', nameEn: 'Red Jade' },
  { month: 5, day: 16, name: '모가나이트', nameEn: 'Moganite' },
  { month: 5, day: 17, name: '퍼플 사파이어', nameEn: 'Purple Sapphire' },
  { month: 5, day: 18, name: '가스파이트', nameEn: 'Gaspeite' },
  { month: 5, day: 19, name: '라피스 라줄리', nameEn: 'Lapis Lazuli' },
  { month: 5, day: 20, name: '그린 골드', nameEn: 'Green Gold' },
  { month: 5, day: 21, name: '트윈 크리스탈', nameEn: 'Twin Crystal' },
  { month: 5, day: 22, name: '데나이트', nameEn: 'Dendritic Quartz' },
  { month: 5, day: 23, name: '레이크 사파이어', nameEn: 'Lake Sapphire' },
  { month: 5, day: 24, name: '화이트 문스톤', nameEn: 'White Moonstone' },
  { month: 5, day: 25, name: '블루 앰버', nameEn: 'Blue Amber' },
  { month: 5, day: 26, name: '코퍼', nameEn: 'Copper' },
  { month: 5, day: 27, name: '그린 투어말린', nameEn: 'Green Tourmaline' },
  { month: 5, day: 28, name: '화이트 칼세도니', nameEn: 'White Chalcedony' },
  { month: 5, day: 29, name: '블랙 오팔', nameEn: 'Black Opal' },
  { month: 5, day: 30, name: '쓰라이트', nameEn: 'Tsavorite' },
  { month: 5, day: 31, name: '스모키 쿼츠', nameEn: 'Smoky Quartz' },
  // June
  { month: 6, day: 1, name: '컬러 체인지 사파이어', nameEn: 'Color Change Sapphire' },
  { month: 6, day: 2, name: '앰버', nameEn: 'Amber' },
  { month: 6, day: 3, name: '페나사이트', nameEn: 'Phenakite' },
  { month: 6, day: 4, name: '오도너타이트', nameEn: 'Odontolite' },
  { month: 6, day: 5, name: '알렉산드라이트', nameEn: 'Alexandrite' },
  { month: 6, day: 6, name: '실리마나이트', nameEn: 'Sillimanite' },
  { month: 6, day: 7, name: '핑크 펄', nameEn: 'Pink Pearl' },
  { month: 6, day: 8, name: '아쿠아마린', nameEn: 'Aquamarine' },
  { month: 6, day: 9, name: '바로크 펄', nameEn: 'Baroque Pearl' },
  { month: 6, day: 10, name: '퀄츠 원석', nameEn: 'Quartz Rough' },
  { month: 6, day: 11, name: '화이트 라브라도라이트', nameEn: 'White Labradorite' },
  { month: 6, day: 12, name: '마베 펄', nameEn: 'Mabe Pearl' },
  { month: 6, day: 13, name: '움바라이트', nameEn: 'Umbalite' },
  { month: 6, day: 14, name: '플래그 아게이트', nameEn: 'Flag Agate' },
  { month: 6, day: 15, name: '사디나이트', nameEn: 'Sardonyx' },
  { month: 6, day: 16, name: '블루 오팔', nameEn: 'Blue Opal' },
  { month: 6, day: 17, name: '카보숑 에메랄드', nameEn: 'Cabochon Emerald' },
  { month: 6, day: 18, name: '골든 나이트', nameEn: 'Golden Knight' },
  { month: 6, day: 19, name: '블랙 스타 사파이어', nameEn: 'Black Star Sapphire' },
  { month: 6, day: 20, name: '그린 플루오라이트', nameEn: 'Green Fluorite' },
  { month: 6, day: 21, name: '서펜틴', nameEn: 'Serpentine' },
  { month: 6, day: 22, name: '선스톤', nameEn: 'Sunstone' },
  { month: 6, day: 23, name: '루비 인 조이사이트', nameEn: 'Ruby in Zoisite' },
  { month: 6, day: 24, name: '워터 오팔', nameEn: 'Water Opal' },
  { month: 6, day: 25, name: '말라카이트', nameEn: 'Malachite' },
  { month: 6, day: 26, name: '스페사르타이트 가넷', nameEn: 'Spessartite Garnet' },
  { month: 6, day: 27, name: '멀티컬러 투어말린', nameEn: 'Multicolor Tourmaline' },
  { month: 6, day: 28, name: '블루 지르콘', nameEn: 'Blue Zircon' },
  { month: 6, day: 29, name: '재스퍼', nameEn: 'Jasper' },
  { month: 6, day: 30, name: '울렉사이트 캐츠아이', nameEn: 'Ulexite Cat\'s Eye' },
  // July
  { month: 7, day: 1, name: '스타 루비', nameEn: 'Star Ruby' },
  { month: 7, day: 2, name: '베리스콥', nameEn: 'Variscite' },
  { month: 7, day: 3, name: '히알라이트', nameEn: 'Hyalite' },
  { month: 7, day: 4, name: '스타 다이옵사이드', nameEn: 'Star Diopside' },
  { month: 7, day: 5, name: '라즈베리 가넷', nameEn: 'Raspberry Garnet' },
  { month: 7, day: 6, name: '오브시디언', nameEn: 'Obsidian' },
  { month: 7, day: 7, name: '스타 로즈 쿼츠', nameEn: 'Star Rose Quartz' },
  { month: 7, day: 8, name: '밀키 오팔', nameEn: 'Milky Opal' },
  { month: 7, day: 9, name: '브라운 다이아몬드', nameEn: 'Brown Diamond' },
  { month: 7, day: 10, name: '와이오밍 제이드', nameEn: 'Wyoming Jade' },
  { month: 7, day: 11, name: '반구형 펄', nameEn: 'Half-Round Pearl' },
  { month: 7, day: 12, name: '비터 스패트', nameEn: 'Bitter Spar' },
  { month: 7, day: 13, name: '크리소베릴', nameEn: 'Chrysoberyl' },
  { month: 7, day: 14, name: '스피넬', nameEn: 'Spinel' },
  { month: 7, day: 15, name: '이나이트', nameEn: 'Enite' },
  { month: 7, day: 16, name: '아줄라이트', nameEn: 'Azurite' },
  { month: 7, day: 17, name: '가든 쿼츠', nameEn: 'Garden Quartz' },
  { month: 7, day: 18, name: '레인보우 문스톤', nameEn: 'Rainbow Moonstone' },
  { month: 7, day: 19, name: '로도크로사이트', nameEn: 'Rhodochrosite' },
  { month: 7, day: 20, name: '아쿠아마린 캐츠아이', nameEn: 'Aquamarine Cat\'s Eye' },
  { month: 7, day: 21, name: '화이트 펄', nameEn: 'White Pearl' },
  { month: 7, day: 22, name: '블랙 사파이어', nameEn: 'Black Sapphire' },
  { month: 7, day: 23, name: '워터멜론 투어말린', nameEn: 'Watermelon Tourmaline' },
  { month: 7, day: 24, name: '스타 그레이 사파이어', nameEn: 'Star Grey Sapphire' },
  { month: 7, day: 25, name: '셀 카메오', nameEn: 'Shell Cameo' },
  { month: 7, day: 26, name: '망가노 칼사이트', nameEn: 'Mangano Calcite' },
  { month: 7, day: 27, name: '멜로 멜로', nameEn: 'Melo Melo' },
  { month: 7, day: 28, name: '핑크 스피넬', nameEn: 'Pink Spinel' },
  { month: 7, day: 29, name: '블랙 오팔', nameEn: 'Black Opal' },
  { month: 7, day: 30, name: '헬리오도르', nameEn: 'Heliodor' },
  { month: 7, day: 31, name: '레드 지르콘', nameEn: 'Red Zircon' },
];

/* ------------------------------------------------------------------ */
/*  Lookup helpers                                                     */
/* ------------------------------------------------------------------ */

const monthlyByMonth = new Map<number, MonthlyBirthstone>(
  MONTHLY_BIRTHSTONES.map((b) => [b.month, b]),
);

const dailyKey = (m: number, d: number) => `${m}-${d}`;
const dailyByKey = new Map<string, DailyBirthstone>(
  DAILY_BIRTHSTONES.map((b) => [dailyKey(b.month, b.day), b]),
);

export function getMonthlyBirthstone(month: number): MonthlyBirthstone {
  return (
    monthlyByMonth.get(month) ?? {
      month,
      name: '알 수 없음',
      nameEn: 'Unknown',
      emoji: '💎',
      meaning: '',
      color: '#888888',
    }
  );
}

export function getDailyBirthstone(
  month: number,
  day: number,
): DailyBirthstone | null {
  return dailyByKey.get(dailyKey(month, day)) ?? null;
}

export function getBirthstoneFromDate(birthDate: string): {
  monthly: MonthlyBirthstone;
  daily: DailyBirthstone | null;
} {
  const d = new Date(birthDate);
  const month = d.getMonth() + 1;
  const day = d.getDate();
  return {
    monthly: getMonthlyBirthstone(month),
    daily: getDailyBirthstone(month, day),
  };
}

/* ------------------------------------------------------------------ */
/*  Compatibility data                                                 */
/* ------------------------------------------------------------------ */

/** Mapping of each month to its most compatible birthstone months */
export const BIRTHSTONE_COMPATIBILITY: Record<number, number[]> = {
  1: [4, 7, 9],   // 석류석 - 금강석, 홍옥, 청옥
  2: [6, 10, 11],  // 자수정 - 진주, 단백석, 황옥
  3: [5, 9, 12],   // 남옥 - 취옥, 청옥, 녹송석
  4: [1, 7, 10],   // 금강석 - 석류석, 홍옥, 단백석
  5: [3, 8, 12],   // 취옥 - 남옥, 감람석, 녹송석
  6: [2, 10, 11],  // 진주 - 자수정, 단백석, 황옥
  7: [1, 4, 9],    // 홍옥 - 석류석, 금강석, 청옥
  8: [5, 11, 12],  // 감람석 - 취옥, 황옥, 녹송석
  9: [1, 3, 7],    // 청옥 - 석류석, 남옥, 홍옥
  10: [2, 4, 6],   // 단백석 - 자수정, 금강석, 진주
  11: [2, 6, 8],   // 황옥 - 자수정, 진주, 감람석
  12: [3, 5, 8],   // 녹송석 - 남옥, 취옥, 감람석
};

export { MONTHLY_BIRTHSTONES, DAILY_BIRTHSTONES };
