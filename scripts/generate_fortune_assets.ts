/**
 * Fortune App 이미지 에셋 대량 생성 스크립트
 *
 * 사용법:
 * 1. .env에 API 키 설정
 * 2. deno run --allow-net --allow-write --allow-read --allow-env scripts/generate_fortune_assets.ts
 *
 * 지원 API:
 * - OpenAI DALL-E 3 (추천: 품질 최고, 한글 이해도 높음)
 * - Stability AI (추천: 일러스트 스타일)
 * - Replicate (Flux, SDXL 모델)
 */

// ============================================================
// API 비교 및 추천
// ============================================================
/*
┌─────────────────┬────────────┬──────────────┬───────────────┬──────────────┐
│ API             │ 품질       │ 한글 이해    │ 일러스트 적합 │ 가격/이미지  │
├─────────────────┼────────────┼──────────────┼───────────────┼──────────────┤
│ DALL-E 3        │ ★★★★★    │ ★★★★★      │ ★★★★☆       │ $0.04-0.12   │
│ Midjourney      │ ★★★★★    │ ★★★☆☆      │ ★★★★★       │ $10/월 250장 │
│ Stability AI    │ ★★★★☆    │ ★★★☆☆      │ ★★★★★       │ $0.02-0.05   │
│ Replicate Flux  │ ★★★★★    │ ★★★★☆      │ ★★★★☆       │ $0.003-0.05  │
│ Leonardo AI     │ ★★★★☆    │ ★★☆☆☆      │ ★★★★★       │ $0.02        │
└─────────────────┴────────────┴──────────────┴───────────────┴──────────────┘

추천:
- 메인 일러스트 (고품질): DALL-E 3
- 대량 아이콘/배경: Stability AI 또는 Replicate
- 전통 한국 스타일: DALL-E 3 (한글 프롬프트 이해도 높음)
*/

// ============================================================
// 설정
// ============================================================

const CONFIG = {
  // API 선택 (환경변수로 오버라이드 가능)
  defaultApi: Deno.env.get("IMAGE_API") || "gemini",

  // API 키
  openaiKey: Deno.env.get("OPENAI_API_KEY") || "",
  stabilityKey: Deno.env.get("STABILITY_API_KEY") || "",
  replicateKey: Deno.env.get("REPLICATE_API_TOKEN") || "",
  geminiKey: Deno.env.get("GEMINI_API_KEY") || "",

  // 저장 경로
  outputBase: "./assets/images/fortune",

  // 동시 요청 수 (API rate limit 고려)
  concurrency: 3,

  // 재시도 횟수
  maxRetries: 3,

  // 요청 간 딜레이 (ms)
  delayBetweenRequests: 1000,
};

// ============================================================
// 에셋 정의 (22-image-asset-generation-prompts.md 기반)
// ============================================================

interface AssetDefinition {
  id: string;
  filename: string;
  path: string;
  width: number;
  height: number;
  transparent: boolean;
  prompt: string;
  negativePrompt?: string;
  style?: string;
  priority: 1 | 2 | 3; // 1=필수, 2=중요, 3=선택
  category: string;
}

const ASSETS: AssetDefinition[] = [
  // ============================================================
  // 1. 일일 운세 (Daily Fortune)
  // ============================================================
  {
    id: "daily_mascot_main",
    filename: "mascot_dog_main.png",
    path: "mascot/daily",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "daily",
    prompt: `Cute white Samoyed dog mascot character, friendly welcoming pose,
STANDING on two legs with arms open wide like greeting a friend,
wearing bright RED SCARF around neck, big warm smile showing teeth,
soft fluffy fur, big round sparkling eyes, pink cheeks,
chibi/kawaii style illustration, clean vector art style,
full body view, transparent background, high quality, no text, no words, no letters, no typography`,
    negativePrompt: "realistic, photo, 3d render, scary, dark, sitting",
  },
  {
    id: "daily_mascot_celebrate",
    filename: "mascot_dog_celebrate.png",
    path: "mascot/daily",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "daily",
    prompt: `Cute white Samoyed dog mascot character in EXTREME celebration,
JUMPING HIGH in the air with all four legs spread out,
wearing GOLDEN CROWN on head, holding TROPHY in one paw,
surrounded by GOLD STARS and sparkles everywhere,
mouth wide open laughing, eyes closed in pure joy, tears of happiness,
wearing bright yellow cape flowing behind,
chibi/kawaii style, flat vector illustration,
transparent background, high quality, dynamic action pose`,
    negativePrompt: "realistic, photo, 3d render, scary, standing still, sitting",
  },
  {
    id: "daily_mascot_sad",
    filename: "mascot_dog_sad.png",
    path: "mascot/daily",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "daily",
    prompt: `Cute white Samoyed dog mascot character looking very sad but adorable,
LYING DOWN flat on belly with chin on paws, completely deflated posture,
wearing BLUE RAINCOAT with hood up, big TEAR DROPS falling from eyes,
small DARK RAIN CLOUD floating directly above head,
ears completely flat and droopy, pouty lip, watery puppy eyes looking up,
holding small wilted flower, entire body slumped,
chibi/kawaii style, flat vector illustration,
transparent background, high quality`,
    negativePrompt: "realistic, photo, 3d render, scary, happy, standing, jumping",
  },
  {
    id: "daily_mascot_thinking",
    filename: "mascot_dog_thinking.png",
    path: "mascot/daily",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "daily",
    prompt: `Cute white Samoyed dog mascot character deep in thought,
SITTING like a professor with legs crossed, wearing GLASSES and PURPLE BERET,
one paw on chin in classic thinking pose, other paw holding open BOOK,
THREE FLOATING QUESTION MARKS above head in different sizes,
eyes looking up and to the side, one eyebrow raised,
small lightbulb icon nearby (dim, not lit yet),
chibi/kawaii style, flat vector illustration,
transparent background, high quality`,
    negativePrompt: "realistic, photo, 3d render, scary, standing, jumping, lying down",
  },
  {
    id: "daily_bg_gradient",
    filename: "bg_daily_gradient.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 1,
    category: "daily",
    prompt: `Abstract gradient background, smooth transition from
mint green (#98E4C9) at top to soft pink (#FFC3C3) in middle
to lavender purple (#D4B6FF) at bottom,
subtle floating soft light particles, dreamy atmosphere,
no objects, pure gradient with gentle glow effects,
mobile wallpaper style, vertical orientation`,
  },
  {
    id: "daily_icon_morning",
    filename: "icon_time_morning.png",
    path: "icons/daily",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "daily",
    prompt: `Simple flat icon of sunrise, half sun rising over horizon line,
warm orange and yellow gradient sun, soft rays emanating,
minimal design, no background elements except horizon,
flat vector style, clean edges, app icon aesthetic`,
  },
  {
    id: "daily_icon_afternoon",
    filename: "icon_time_afternoon.png",
    path: "icons/daily",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "daily",
    prompt: `Simple flat icon of bright sun at zenith,
full circular sun in bright yellow gold (#FFD700),
short rays around, minimal design,
flat vector style, clean edges, app icon aesthetic`,
  },
  {
    id: "daily_icon_evening",
    filename: "icon_time_evening.png",
    path: "icons/daily",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "daily",
    prompt: `Simple flat icon of crescent moon with stars,
golden yellow crescent moon, 2-3 small stars nearby,
calm night feeling, minimal design,
flat vector style, clean edges, app icon aesthetic`,
  },

  // 카테고리 아이콘
  {
    id: "icon_love",
    filename: "icon_category_love.png",
    path: "icons/categories",
    width: 128,
    height: 128,
    transparent: true,
    priority: 1,
    category: "common",
    prompt: `Simple heart icon, gradient from pink (#FF6B9D) to red (#E91E63),
rounded 3D effect with subtle shadow, glossy finish,
single heart shape, app icon style, clean edges`,
  },
  {
    id: "icon_money",
    filename: "icon_category_money.png",
    path: "icons/categories",
    width: 128,
    height: 128,
    transparent: true,
    priority: 1,
    category: "common",
    prompt: `Simple gold coin icon with Korean won symbol,
shiny metallic gold (#FFD700) color, subtle 3D depth,
single coin, gleaming highlight, app icon style, clean edges`,
  },
  {
    id: "icon_work",
    filename: "icon_category_work.png",
    path: "icons/categories",
    width: 128,
    height: 128,
    transparent: true,
    priority: 1,
    category: "common",
    prompt: `Simple briefcase icon, navy blue (#1A237E) color,
modern flat design with subtle gradient,
professional business bag shape, gold clasp detail,
app icon style, clean edges`,
  },
  {
    id: "icon_study",
    filename: "icon_category_study.png",
    path: "icons/categories",
    width: 128,
    height: 128,
    transparent: true,
    priority: 1,
    category: "common",
    prompt: `Simple open book icon, blue (#2196F3) color,
pages fanned open, minimal design, subtle shadow,
study education symbol, app icon style, clean edges`,
  },
  {
    id: "icon_health",
    filename: "icon_category_health.png",
    path: "icons/categories",
    width: 128,
    height: 128,
    transparent: true,
    priority: 1,
    category: "common",
    prompt: `Simple flexed bicep arm icon, green (#4CAF50) gradient,
strong muscle showing, minimal design, health symbol,
app icon style, clean vector look, clean edges`,
  },

  // ============================================================
  // 2. 연애운 (Love Fashion)
  // ============================================================
  {
    id: "love_couple_spring",
    filename: "couple_spring_park.png",
    path: "love",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "love",
    prompt: `Romantic couple illustration in Korean watercolor painting style,
young couple walking together in spring park,
man in navy suit, woman in elegant beige coat dress,
cherry blossom trees in soft pink, petals falling gently,
holding hands, warm sunlight, soft watercolor texture,
dreamy romantic atmosphere, muted warm colors,
Korean modern hanbok-inspired fashion details,
transparent background, high quality`,
  },
  {
    id: "love_couple_cafe",
    filename: "couple_cafe_date.png",
    path: "love",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "love",
    prompt: `Romantic couple at cafe illustration in soft watercolor style,
sitting across table, coffee cups between them,
warm cozy atmosphere, window with soft light,
man in casual knit sweater, woman in cream blouse,
loving gaze at each other, subtle smile,
Korean modern illustration style, soft edges,
transparent background, high quality`,
  },
  {
    id: "love_cherry_branch",
    filename: "cherry_blossom_branch.png",
    path: "love/decorations",
    width: 512,
    height: 512,
    transparent: true,
    priority: 2,
    category: "love",
    prompt: `Single cherry blossom branch with pink flowers,
delicate petals in soft pink (#FFB7C5),
brown twig, 5-7 blossoms, some buds,
watercolor texture, Korean traditional painting influence,
graceful curved branch shape,
transparent background, clean edges`,
  },
  {
    id: "love_cherry_petals",
    filename: "cherry_petals_falling.png",
    path: "love/decorations",
    width: 512,
    height: 512,
    transparent: true,
    priority: 2,
    category: "love",
    prompt: `Scattered cherry blossom petals floating in air,
10-15 individual petals in various angles and sizes,
soft pink (#FFB7C5) to white gradient on each petal,
delicate, lightweight feeling, some petals closer (larger),
watercolor texture, dreamy floating effect,
transparent background`,
  },
  {
    id: "love_frame_scroll",
    filename: "frame_scroll_fashion.png",
    path: "frames",
    width: 400,
    height: 600,
    transparent: true,
    priority: 2,
    category: "love",
    prompt: `Traditional Korean scroll frame (족자) for displaying fashion items,
vertical hanging scroll shape, wooden top and bottom rods,
red silk tassel hanging from bottom rod,
cream ivory paper texture inside frame area,
gold decorative corners, traditional pattern borders,
elegant traditional Korean aesthetic,
center area empty for content overlay,
transparent background outside frame`,
  },
  {
    id: "love_bg_watercolor",
    filename: "bg_love_watercolor.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "love",
    prompt: `Soft watercolor background texture,
warm peach (#F5E6D3) to soft pink (#FFD1DC) gradient,
subtle watercolor wash effects, organic edges,
dreamy romantic atmosphere, light paper texture,
no objects, abstract watercolor wash only,
vertical mobile wallpaper`,
  },

  // ============================================================
  // 3. 타로 (Tarot)
  // ============================================================
  {
    id: "tarot_card_back",
    filename: "tarot_card_back.png",
    path: "tarot",
    width: 600,
    height: 900,
    transparent: false,
    priority: 1,
    category: "tarot",
    prompt: `Mystical tarot card back design,
deep purple (#1A1A2E) base color,
intricate gold geometric sacred geometry pattern,
central mandala with moon phases,
stars scattered around edges, gold border frame,
mysterious magical atmosphere, ornate Victorian style,
full card design`,
  },
  {
    id: "tarot_bg_starry",
    filename: "bg_tarot_starry.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 1,
    category: "tarot",
    prompt: `Deep mystical night sky background,
gradient from deep purple (#1A1A2E) to dark blue (#0D1B2A),
scattered twinkling stars, subtle nebula clouds,
magical atmosphere, cosmic dust particles,
gold sparkles randomly placed, no moon,
vertical mobile background`,
  },
  {
    id: "tarot_star_gold",
    filename: "decoration_gold_star.png",
    path: "tarot/decorations",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "tarot",
    prompt: `Single shining gold star decoration,
four-pointed star shape with bright glow,
metallic gold (#FFD700) color, sparkle effect,
magical mystical style, clean design,
transparent background`,
  },
  {
    id: "tarot_moon",
    filename: "decoration_crescent_moon.png",
    path: "tarot/decorations",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "tarot",
    prompt: `Elegant crescent moon decoration,
silver to gold gradient, mystical glow around edges,
delicate celestial style, facing left,
subtle face detail, magical atmosphere,
transparent background`,
  },
  {
    id: "tarot_crystal_ball",
    filename: "icon_crystal_ball.png",
    path: "tarot",
    width: 512,
    height: 512,
    transparent: true,
    priority: 2,
    category: "tarot",
    prompt: `Mystical crystal ball on ornate stand,
glowing purple (#9C27B0) mist inside glass sphere,
gold metallic decorative stand with celestial patterns,
magical sparkles and light reflections,
fortune telling mystical object, detailed illustration,
transparent background`,
  },

  // ============================================================
  // 4. 관상 (Face Reading)
  // ============================================================
  {
    id: "face_animal_dog",
    filename: "animal_face_dog.png",
    path: "face-reading/animals",
    width: 512,
    height: 512,
    transparent: true,
    priority: 1,
    category: "face-reading",
    prompt: `Cute dog face illustration representing dog-like face personality,
friendly Shiba Inu or Retriever style face,
warm brown and cream colors, big friendly eyes,
soft approachable expression, minimal stylized design,
Korean modern illustration style, clean lines,
transparent background`,
  },
  {
    id: "face_animal_cat",
    filename: "animal_face_cat.png",
    path: "face-reading/animals",
    width: 512,
    height: 512,
    transparent: true,
    priority: 1,
    category: "face-reading",
    prompt: `Elegant cat face illustration representing cat-like face personality,
mysterious sharp eyes, pointed ears,
white or gray fur, sophisticated expression,
slightly aloof but charming look, minimal stylized design,
Korean modern illustration style, clean lines,
transparent background`,
  },
  {
    id: "face_animal_rabbit",
    filename: "animal_face_rabbit.png",
    path: "face-reading/animals",
    width: 512,
    height: 512,
    transparent: true,
    priority: 1,
    category: "face-reading",
    prompt: `Cute rabbit face illustration representing rabbit-like face personality,
soft round features, long ears, big innocent eyes,
white or light pink tones, gentle sweet expression,
adorable and youthful look, minimal stylized design,
Korean modern illustration style, clean lines,
transparent background`,
  },
  {
    id: "face_animal_fox",
    filename: "animal_face_fox.png",
    path: "face-reading/animals",
    width: 512,
    height: 512,
    transparent: true,
    priority: 1,
    category: "face-reading",
    prompt: `Attractive fox face illustration representing fox-like face personality,
sharp elegant features, pointed face shape,
orange and white fur, intelligent alluring eyes,
charming mysterious expression, minimal stylized design,
Korean modern illustration style, clean lines,
transparent background`,
  },
  {
    id: "face_animal_bear",
    filename: "animal_face_bear.png",
    path: "face-reading/animals",
    width: 512,
    height: 512,
    transparent: true,
    priority: 1,
    category: "face-reading",
    prompt: `Friendly bear face illustration representing bear-like face personality,
round full face, small eyes, broad features,
brown or black fur, warm dependable expression,
gentle giant look, minimal stylized design,
Korean modern illustration style, clean lines,
transparent background`,
  },

  // ============================================================
  // 5. 궁합 (Compatibility)
  // ============================================================
  {
    id: "compatibility_ducks",
    filename: "mandarin_ducks_pair.png",
    path: "compatibility",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "compatibility",
    prompt: `Traditional Korean mandarin duck pair (원앙) illustration,
minhwa (민화) folk painting style, male and female ducks,
swimming together on water, lotus flowers nearby,
vibrant colors - male with colorful plumage, female more muted,
symbol of happy marriage and love, traditional Korean art style,
detailed feather patterns, auspicious atmosphere,
transparent background`,
  },
  {
    id: "compatibility_yin_yang",
    filename: "yin_yang_symbol.png",
    path: "compatibility",
    width: 512,
    height: 512,
    transparent: true,
    priority: 1,
    category: "compatibility",
    prompt: `Traditional yin yang (태극) symbol,
red and blue Korean style (not black and white),
clean perfect circle, balanced design,
harmony and balance symbolism,
subtle gradient and depth,
transparent background`,
  },
  {
    id: "compatibility_stamp_a",
    filename: "stamp_grade_a_plus.png",
    path: "compatibility/stamps",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "compatibility",
    prompt: `Traditional Korean red stamp (도장) with A+ grade,
circular seal shape, weathered ink texture,
deep red (#C62828) color, authentic stamp impression,
text 천생연분 around edge in Korean,
vintage seal aesthetic, imperfect edges,
transparent background`,
  },

  // ============================================================
  // 6. 신년 운세 (New Year)
  // ============================================================
  {
    id: "newyear_phoenix",
    filename: "phoenix_main.png",
    path: "new-year",
    width: 1200,
    height: 800,
    transparent: true,
    priority: 1,
    category: "new-year",
    prompt: `Majestic Korean phoenix (봉황) illustration in minhwa style,
flying across from left to right, wings fully spread,
rich colors - red, gold, orange tail feathers,
intricate feather patterns with traditional Korean motifs,
five-colored plumage (오색), long flowing tail,
auspicious mythical bird, royal elegance,
traditional Korean folk painting style,
transparent background, high detail`,
  },
  {
    id: "newyear_dragons",
    filename: "twin_dragons.png",
    path: "new-year",
    width: 800,
    height: 800,
    transparent: true,
    priority: 1,
    category: "new-year",
    prompt: `Twin dragons (쌍룡) illustration in traditional Korean minhwa style,
two dragons facing each other, circling around,
one golden, one blue-green, clouds surrounding,
holding or protecting a flaming pearl (여의주) between them,
powerful auspicious symbolism, intricate scale details,
traditional Korean dragon design (not Chinese style),
transparent background`,
  },
  {
    id: "newyear_cranes",
    filename: "three_cranes.png",
    path: "new-year",
    width: 800,
    height: 600,
    transparent: true,
    priority: 2,
    category: "new-year",
    prompt: `Three flying cranes (학) illustration in Korean minhwa style,
red-crowned cranes in flight formation,
white feathers with black and red accents,
graceful flying pose, traditional clouds around,
longevity and good fortune symbolism,
traditional Korean folk painting aesthetic,
transparent background`,
  },
  {
    id: "newyear_sunrise",
    filename: "landscape_sunrise.png",
    path: "new-year",
    width: 1080,
    height: 600,
    transparent: false,
    priority: 2,
    category: "new-year",
    prompt: `Korean traditional mountain landscape with sunrise,
mountains in 산수화 style with rising sun behind peaks,
golden orange sun rays, misty clouds at mountain base,
pine trees on mountain sides, peaceful scene,
traditional Korean ink painting with color washes,
auspicious new beginning atmosphere`,
  },

  // 띠 동물 12개
  ...["rat", "ox", "tiger", "rabbit", "dragon", "snake",
     "horse", "sheep", "monkey", "rooster", "dog", "pig"].map((animal, i) => ({
    id: `zodiac_${animal}`,
    filename: `zodiac_${animal}.png`,
    path: "zodiac",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2 as const,
    category: "zodiac",
    prompt: `Traditional Korean zodiac ${animal} illustration,
cute stylized ${animal} in Korean folk art style,
sitting or standing noble pose, traditional patterns,
minhwa inspired design, warm gold and earthy colors,
auspicious symbolism for Korean zodiac,
transparent background`,
  })),

  // ============================================================
  // 7. 부적 (Talisman)
  // ============================================================
  {
    id: "talisman_wealth",
    filename: "talisman_wealth.png",
    path: "talisman",
    width: 400,
    height: 600,
    transparent: true,
    priority: 1,
    category: "talisman",
    prompt: `Traditional Korean wealth talisman (재물 부적),
yellow paper base with red ink symbols,
traditional talisman calligraphy and symbols,
wealth bringing characters and patterns,
authentic Korean talisman design,
mystical protective energy feel,
transparent background`,
  },
  {
    id: "talisman_love",
    filename: "talisman_love.png",
    path: "talisman",
    width: 400,
    height: 600,
    transparent: true,
    priority: 1,
    category: "talisman",
    prompt: `Traditional Korean love talisman (연애 부적),
pink or red paper base with black and red ink,
love and connection symbols, heart motifs,
traditional talisman calligraphy style,
romantic fate bringing design,
mystical energy feel,
transparent background`,
  },
  {
    id: "talisman_protection",
    filename: "talisman_protection.png",
    path: "talisman",
    width: 400,
    height: 600,
    transparent: true,
    priority: 1,
    category: "talisman",
    prompt: `Traditional Korean protection talisman (액막이 부적),
yellow paper base with black and red ink,
protective symbols and characters,
evil warding patterns, strong energy lines,
traditional talisman calligraphy style,
powerful protective design,
transparent background`,
  },
  {
    id: "talisman_exam",
    filename: "talisman_exam.png",
    path: "talisman",
    width: 400,
    height: 600,
    transparent: true,
    priority: 2,
    category: "talisman",
    prompt: `Traditional Korean exam success talisman (합격 부적),
yellow paper base with red ink,
success and wisdom symbols, scholarly motifs,
traditional talisman calligraphy style,
study and achievement bringing design,
transparent background`,
  },

  // ============================================================
  // 8. 오행 (Five Elements)
  // ============================================================
  ...["wood", "fire", "earth", "metal", "water"].map((element) => {
    const colors: Record<string, string> = {
      wood: "green (#4CAF50)",
      fire: "red-orange (#F44336)",
      earth: "yellow-brown (#FFC107)",
      metal: "white-gold (#FFD700)",
      water: "blue-black (#2196F3)",
    };
    const symbols: Record<string, string> = {
      wood: "tree or green growth",
      fire: "flame",
      earth: "mountain",
      metal: "gold ingot",
      water: "wave",
    };
    const hanja: Record<string, string> = {
      wood: "木",
      fire: "火",
      earth: "土",
      metal: "金",
      water: "水",
    };
    return {
      id: `element_${element}`,
      filename: `element_${element}.png`,
      path: "saju/elements",
      width: 256,
      height: 256,
      transparent: true,
      priority: 2 as const,
      category: "saju",
      prompt: `Five Elements icon - ${element.charAt(0).toUpperCase() + element.slice(1)} (${hanja[element]}),
stylized ${symbols[element]} symbol,
traditional Korean design aesthetic,
${colors[element]} color, clean iconic design,
Chinese character ${hanja[element]} subtly incorporated,
transparent background`,
    };
  }),

  // ============================================================
  // 9. 직업운 (Career Fortune)
  // ============================================================
  {
    id: "career_mascot_main",
    filename: "mascot_career.png",
    path: "career",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "career",
    prompt: `Professional confident business person mascot character,
modern Korean style illustration, wearing smart casual attire,
briefcase in hand, confident smile, standing power pose,
clean vector illustration style, minimal shading,
business success vibes, transparent background`,
    negativePrompt: "realistic photo, 3d render, dark colors",
  },
  {
    id: "career_icon_briefcase",
    filename: "icon_briefcase.png",
    path: "icons/career",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "career",
    prompt: `Professional briefcase icon, modern flat design,
brown leather briefcase with gold clasp,
clean minimal vector style, app icon aesthetic,
transparent background, PNG format`,
  },
  {
    id: "career_icon_chart",
    filename: "icon_chart_up.png",
    path: "icons/career",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "career",
    prompt: `Rising chart icon with upward arrow,
green and blue gradient bars showing growth,
success and progress symbolism,
flat vector icon style, clean minimal design,
transparent background`,
  },
  {
    id: "career_icon_handshake",
    filename: "icon_handshake.png",
    path: "icons/career",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "career",
    prompt: `Professional handshake icon, two hands meeting,
business partnership symbolism, blue and gold colors,
flat vector illustration style, clean minimal,
transparent background`,
  },
  {
    id: "career_icon_lightbulb",
    filename: "icon_idea.png",
    path: "icons/career",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "career",
    prompt: `Glowing lightbulb idea icon, creative inspiration symbol,
yellow golden glow, spark effects around bulb,
flat vector design, innovation and creativity,
transparent background`,
  },
  {
    id: "career_bg_modern",
    filename: "bg_career.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "career",
    prompt: `Modern office abstract background,
subtle blue and gray gradient with geometric shapes,
professional business atmosphere, blurred city skyline hint,
soft lighting, vertical mobile wallpaper orientation,
clean professional aesthetic`,
  },

  // ============================================================
  // 10. 건강운 (Health Fortune)
  // ============================================================
  {
    id: "health_mascot_main",
    filename: "mascot_health.png",
    path: "health",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "health",
    prompt: `Healthy energetic mascot character doing stretching pose,
cute cartoon style, green and white color scheme,
radiating energy and vitality, happy glowing expression,
athletic wear, wellness vibes, korean illustration style,
transparent background, clean edges`,
    negativePrompt: "realistic, dark, sick, tired",
  },
  {
    id: "health_icon_heart",
    filename: "icon_heart_pulse.png",
    path: "icons/health",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "health",
    prompt: `Heart with pulse line icon, medical heartbeat symbol,
red heart with white ECG line through it,
health and vitality representation,
flat vector design, clean minimal,
transparent background`,
  },
  {
    id: "health_icon_sleep",
    filename: "icon_sleep.png",
    path: "icons/health",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "health",
    prompt: `Sleep and rest icon, crescent moon with stars and Zzz,
calm blue and purple colors, peaceful night theme,
sleep quality and rest symbolism,
flat vector design, transparent background`,
  },
  {
    id: "health_icon_nutrition",
    filename: "icon_nutrition.png",
    path: "icons/health",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "health",
    prompt: `Healthy nutrition icon, fresh fruits and vegetables,
colorful apple, carrot, broccoli arrangement,
balanced diet symbolism, vibrant colors,
flat vector illustration style,
transparent background`,
  },
  {
    id: "health_bg_wellness",
    filename: "bg_health.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "health",
    prompt: `Calming wellness background, soft green and white gradient,
subtle leaf patterns, fresh morning atmosphere,
clean air and nature feeling, light rays,
vertical mobile wallpaper, spa-like serenity`,
  },

  // ============================================================
  // 11. 꿈 해몽 (Dream Fortune)
  // ============================================================
  {
    id: "dream_mascot_main",
    filename: "mascot_dream.png",
    path: "dream",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "dream",
    prompt: `Dreamy cloud fairy mascot character floating in soft clouds,
sleepy peaceful expression, surrounded by stars and moons,
pastel purple and blue colors, ethereal glow,
cute kawaii style illustration, magical dream guide,
transparent background`,
    negativePrompt: "nightmare, scary, dark, horror",
  },
  {
    id: "dream_icon_cloud",
    filename: "icon_cloud.png",
    path: "icons/dream",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "dream",
    prompt: `Soft fluffy dream cloud icon, white and light purple,
sleeping face or gentle expression on cloud,
peaceful dreaming symbolism, kawaii style,
flat vector design, transparent background`,
  },
  {
    id: "dream_icon_moon",
    filename: "icon_crescent.png",
    path: "icons/dream",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "dream",
    prompt: `Crescent moon with stars icon, night dream symbol,
golden yellow moon with twinkling stars around,
mystical nighttime atmosphere, magical,
flat vector design, transparent background`,
  },
  {
    id: "dream_symbol_flying",
    filename: "symbol_flying.png",
    path: "dream/symbols",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "dream",
    prompt: `Flying dream symbol, person with wings soaring through clouds,
freedom and aspiration symbolism, soft pastel colors,
dreamy ethereal style, gentle lines,
flat illustration, transparent background`,
  },
  {
    id: "dream_symbol_water",
    filename: "symbol_water.png",
    path: "dream/symbols",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "dream",
    prompt: `Dream water symbol, calm ocean waves with reflection,
subconscious and emotion representation,
blue and teal gradient, peaceful flowing,
flat illustration style, transparent background`,
  },
  {
    id: "dream_symbol_teeth",
    filename: "symbol_teeth.png",
    path: "dream/symbols",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "dream",
    prompt: `Cartoon tooth icon for dream interpretation,
white cute tooth character, simple non-scary design,
common dream symbol representation,
flat vector style, transparent background`,
    negativePrompt: "realistic, scary, bloody, horror",
  },
  {
    id: "dream_bg_ethereal",
    filename: "bg_dream.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "dream",
    prompt: `Dreamy ethereal background, soft purple and blue gradient,
floating stars and cosmic dust, gentle clouds,
mystical night sky atmosphere, aurora-like lights,
vertical mobile wallpaper, magical dreamy feel`,
  },

  // ============================================================
  // 12. MBTI 운세
  // ============================================================
  // MBTI 16개 타입 캐릭터
  ...["INTJ", "INTP", "ENTJ", "ENTP", "INFJ", "INFP", "ENFJ", "ENFP",
     "ISTJ", "ISFJ", "ESTJ", "ESFJ", "ISTP", "ISFP", "ESTP", "ESFP"].map((mbti) => {
    const traits: Record<string, string> = {
      INTJ: "confident strategist with books and chess pieces, dark blue",
      INTP: "curious thinker with scientific equipment, purple",
      ENTJ: "commanding leader with crown and podium, red",
      ENTP: "creative debater with lightbulbs and speech bubbles, orange",
      INFJ: "mystical counselor with spiritual symbols, teal",
      INFP: "dreamy idealist with flowers and poetry, pink",
      ENFJ: "charismatic teacher with warm glow, yellow",
      ENFP: "enthusiastic explorer with colorful butterflies, coral",
      ISTJ: "organized inspector with checklist and folders, navy",
      ISFJ: "caring defender with shield and hearts, sage green",
      ESTJ: "decisive executive with gavel and documents, maroon",
      ESFJ: "social consul with party decorations, peach",
      ISTP: "cool virtuoso with tools and gadgets, steel gray",
      ISFP: "artistic adventurer with paint brushes, lavender",
      ESTP: "daring entrepreneur with action pose, electric blue",
      ESFP: "fun entertainer with spotlight and confetti, hot pink",
    };
    return {
      id: `mbti_${mbti.toLowerCase()}`,
      filename: `mbti_${mbti.toLowerCase()}.png`,
      path: "mbti/characters",
      width: 512,
      height: 512,
      transparent: true,
      priority: 1 as const,
      category: "mbti",
      prompt: `MBTI ${mbti} personality character illustration,
${traits[mbti]}, cute chibi style character,
personality type visual representation,
clean vector style, Korean webtoon aesthetic,
transparent background`,
    };
  }),
  {
    id: "mbti_bg_gradient",
    filename: "bg_mbti.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "mbti",
    prompt: `Modern gradient background for MBTI personality test,
soft gradient from purple through pink to orange,
geometric subtle patterns, contemporary design,
vertical mobile wallpaper orientation,
clean and professional yet friendly`,
  },

  // ============================================================
  // 13. 재물운 (Wealth Fortune)
  // ============================================================
  {
    id: "wealth_mascot_main",
    filename: "mascot_wealth.png",
    path: "wealth",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "wealth",
    prompt: `Lucky wealth mascot, traditional Korean money god style,
holding gold ingots and coins, rich golden aura,
happy prosperous expression, red and gold colors,
blend of traditional and cute modern illustration,
transparent background`,
    negativePrompt: "dark, poor, negative",
  },
  {
    id: "wealth_icon_coin",
    filename: "icon_gold_coin.png",
    path: "icons/wealth",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "wealth",
    prompt: `Golden coin icon with Korean traditional pattern,
shining gold with subtle 福 character,
prosperity and wealth symbol,
3D-ish gold effect, glossy surface,
transparent background`,
  },
  {
    id: "wealth_icon_ingot",
    filename: "icon_gold_ingot.png",
    path: "icons/wealth",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "wealth",
    prompt: `Traditional gold ingot (금덩이) icon,
Korean style gold bar, shining metallic surface,
wealth and prosperity symbolism,
flat stylized design with gold gradient,
transparent background`,
  },
  {
    id: "wealth_icon_piggybank",
    filename: "icon_piggybank.png",
    path: "icons/wealth",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "wealth",
    prompt: `Cute piggy bank icon, pink ceramic pig,
gold coin going into slot, savings symbol,
adorable saving money representation,
flat vector illustration, transparent background`,
  },
  {
    id: "wealth_icon_wallet",
    filename: "icon_wallet.png",
    path: "icons/wealth",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "wealth",
    prompt: `Overflowing wallet icon, brown leather wallet,
money bills and coins spilling out,
abundance and prosperity symbol,
flat vector design, transparent background`,
  },
  {
    id: "wealth_bg_luxury",
    filename: "bg_wealth.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "wealth",
    prompt: `Luxurious gold gradient background,
subtle golden shimmer and sparkles,
prosperity and abundance atmosphere,
elegant gold to cream gradient,
vertical mobile wallpaper, opulent feel`,
  },

  // ============================================================
  // 14. 투자운 (Investment Fortune)
  // ============================================================
  {
    id: "investment_mascot_main",
    filename: "mascot_investment.png",
    path: "investment",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "investment",
    prompt: `Smart investor mascot character, wearing suit and glasses,
holding tablet with stock charts, confident analytical expression,
surrounded by upward trending graphs and coins,
modern Korean business illustration style,
professional yet approachable, transparent background`,
    negativePrompt: "dark, negative, loss, red charts",
  },
  {
    id: "investment_icon_stocks",
    filename: "icon_stocks.png",
    path: "icons/investment",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "investment",
    prompt: `Stock market icon, candlestick chart pattern,
green upward trend line, financial trading symbol,
clean modern design, finance aesthetic,
flat vector style, transparent background`,
  },
  {
    id: "investment_icon_crypto",
    filename: "icon_crypto.png",
    path: "icons/investment",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "investment",
    prompt: `Cryptocurrency icon, stylized Bitcoin-like coin,
digital blockchain aesthetic, gold and blue colors,
modern tech finance symbol,
flat vector design, transparent background`,
  },
  {
    id: "investment_bg_finance",
    filename: "bg_investment.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "investment",
    prompt: `Modern financial background, dark blue gradient,
subtle stock chart lines and data visualization,
professional trading floor atmosphere,
vertical mobile wallpaper, sophisticated finance aesthetic`,
  },

  // ============================================================
  // 15. 시험운 (Exam Fortune)
  // ============================================================
  {
    id: "exam_mascot_main",
    filename: "mascot_exam.png",
    path: "exam",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "exam",
    prompt: `Determined student mascot character studying hard,
cute cartoon style, wearing headband of determination,
surrounded by books and notes, focused expression,
pen in hand, desk lamp, Korean student aesthetic,
chibi style illustration, transparent background`,
    negativePrompt: "stressed, crying, failure, dark",
  },
  {
    id: "exam_icon_book",
    filename: "icon_book.png",
    path: "icons/exam",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "exam",
    prompt: `Open book icon with stars coming out,
knowledge and learning symbol, colorful pages,
magical study vibes, cute educational icon,
flat vector design, transparent background`,
  },
  {
    id: "exam_icon_pencil",
    filename: "icon_pencil.png",
    path: "icons/exam",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "exam",
    prompt: `Sharp pencil icon with sparkle effect,
writing and test-taking symbol, yellow HB pencil,
success in exams representation,
flat vector style, transparent background`,
  },
  {
    id: "exam_icon_certificate",
    filename: "icon_certificate.png",
    path: "icons/exam",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "exam",
    prompt: `Certificate of achievement icon,
golden seal with ribbon, passing exam symbol,
success and graduation representation,
flat vector design, transparent background`,
  },
  {
    id: "exam_bg_study",
    filename: "bg_exam.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "exam",
    prompt: `Calm study room background, soft beige and cream,
subtle book stack silhouettes, warm lamp glow,
focused study atmosphere, minimalist design,
vertical mobile wallpaper, concentration-enhancing`,
  },

  // ============================================================
  // 16. 재능운 (Talent Fortune)
  // ============================================================
  {
    id: "talent_mascot_main",
    filename: "mascot_talent.png",
    path: "talent",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "talent",
    prompt: `Creative talent mascot character, artist or performer,
surrounded by various creative symbols (palette, musical notes, pen),
rainbow aura of creativity, joyful confident expression,
discovering hidden talents, colorful chibi illustration,
transparent background`,
  },
  {
    id: "talent_icon_star",
    filename: "icon_talent_star.png",
    path: "icons/talent",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "talent",
    prompt: `Shining talent star icon, golden five-pointed star,
special ability and gift symbol, sparkling effect,
potential and skill representation,
flat vector design, transparent background`,
  },
  {
    id: "talent_icon_palette",
    filename: "icon_palette.png",
    path: "icons/talent",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "talent",
    prompt: `Artist palette icon with colorful paint,
creative artistic talent symbol, brush included,
rainbow of colors, artistic expression,
flat vector style, transparent background`,
  },
  {
    id: "talent_bg_creative",
    filename: "bg_talent.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "talent",
    prompt: `Creative inspiration background, gradient from indigo to magenta,
subtle abstract artistic patterns, paint splashes effect,
creative energy and artistic vibes,
vertical mobile wallpaper, inspiring atmosphere`,
  },

  // ============================================================
  // 17. 행운 아이템 (Lucky Items)
  // ============================================================
  ...["clover", "horseshoe", "ladybug", "rainbow", "coin",
     "star", "heart", "gem", "key", "feather"].map((item) => {
    const itemDescriptions: Record<string, string> = {
      clover: "four-leaf clover, green lucky charm, Irish luck symbol",
      horseshoe: "golden horseshoe, traditional luck symbol, upward facing",
      ladybug: "cute red ladybug with black spots, good fortune insect",
      rainbow: "colorful rainbow arc, hope and luck symbol",
      coin: "shiny lucky coin, gold with clover or sun pattern",
      star: "golden lucky star, twinkling wish-upon-a-star",
      heart: "red heart with golden glow, love luck symbol",
      gem: "sparkling lucky gemstone, purple amethyst crystal",
      key: "ornate golden key, opportunity and unlocking luck",
      feather: "white angel feather, divine luck and protection",
    };
    return {
      id: `lucky_item_${item}`,
      filename: `lucky_${item}.png`,
      path: "items/lucky",
      width: 256,
      height: 256,
      transparent: true,
      priority: 2 as const,
      category: "lucky-items",
      prompt: `Lucky item illustration: ${itemDescriptions[item]},
cute kawaii style, magical sparkle effect,
clean flat vector design, vibrant colors,
fortune and good luck aesthetic,
transparent background`,
    };
  }),

  // Korean traditional lucky items
  ...["dokkaebi", "norigae", "bokjumeoni", "dancheong", "haetae"].map((item) => {
    const itemDescriptions: Record<string, string> = {
      dokkaebi: "Korean goblin (도깨비) charm, mischievous but lucky spirit, holding magic club (방망이)",
      norigae: "Korean traditional ornament (노리개), colorful silk tassels, blessing charm",
      bokjumeoni: "Korean lucky pouch (복주머니), red silk bag with gold embroidery",
      dancheong: "Korean traditional pattern (단청), colorful temple design motif",
      haetae: "Korean mythical beast (해태), guardian lion-dog, protection symbol",
    };
    return {
      id: `lucky_korean_${item}`,
      filename: `lucky_kr_${item}.png`,
      path: "items/lucky/korean",
      width: 256,
      height: 256,
      transparent: true,
      priority: 2 as const,
      category: "lucky-items",
      prompt: `Korean traditional lucky symbol: ${itemDescriptions[item]},
traditional Korean art style with modern cute twist,
minhwa inspired but approachable,
rich red, gold, and traditional colors,
transparent background`,
    };
  }),

  // ============================================================
  // 18. 반려동물 궁합 (Pet Compatibility)
  // ============================================================
  ...["dog", "cat", "rabbit", "hamster", "bird", "fish",
     "turtle", "hedgehog", "guinea_pig", "ferret"].map((pet) => {
    const petDescriptions: Record<string, string> = {
      dog: "happy loyal dog, golden retriever or mixed breed, wagging tail",
      cat: "elegant cat, orange tabby or mixed, curious expression",
      rabbit: "fluffy bunny, white or lop-eared, cute munching pose",
      hamster: "tiny adorable hamster, cheeks full, round and fluffy",
      bird: "colorful parakeet or budgie, singing pose, vibrant feathers",
      fish: "beautiful betta fish, flowing fins, blue and red colors",
      turtle: "cute small turtle, peeking from shell, gentle expression",
      hedgehog: "spiky hedgehog curled up, tiny face visible, adorable",
      guinea_pig: "fluffy guinea pig, two-toned fur, sweet expression",
      ferret: "playful ferret, long body, curious mischievous look",
    };
    return {
      id: `pet_${pet}`,
      filename: `pet_${pet}.png`,
      path: "pets",
      width: 512,
      height: 512,
      transparent: true,
      priority: 2 as const,
      category: "pet-compatibility",
      prompt: `Adorable pet illustration: ${petDescriptions[pet]},
cute kawaii style, big expressive eyes,
friendly approachable character design,
Korean webtoon pet illustration style,
transparent background`,
      negativePrompt: "scary, aggressive, realistic, dark",
    };
  }),
  {
    id: "pet_bg_gradient",
    filename: "bg_pet.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "pet-compatibility",
    prompt: `Warm cozy pet-friendly background,
soft gradient from peach to mint green,
subtle paw print patterns, friendly atmosphere,
warm lighting, home comfort vibes,
vertical mobile wallpaper`,
  },

  // ============================================================
  // 19. 소개팅/블라인드데이트 (Blind Date)
  // ============================================================
  {
    id: "blinddate_mascot_main",
    filename: "mascot_blinddate.png",
    path: "blind-date",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "blind-date",
    prompt: `Cute couple mascot for blind date fortune,
two characters meeting with hearts floating between,
shy excited expressions, cafe date setting hint,
romantic yet innocent illustration style,
Korean webtoon couple aesthetic, transparent background`,
    negativePrompt: "inappropriate, mature, dark",
  },
  {
    id: "blinddate_icon_hearts",
    filename: "icon_hearts.png",
    path: "icons/blind-date",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "blind-date",
    prompt: `Two hearts connecting icon, romantic chemistry symbol,
pink and red gradient hearts, sparkle effects,
love at first sight representation,
flat vector design, transparent background`,
  },
  {
    id: "blinddate_bg_romantic",
    filename: "bg_blinddate.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "blind-date",
    prompt: `Romantic date background, soft pink gradient,
subtle heart bokeh effects, dreamy atmosphere,
cafe window light feel, warm romantic ambiance,
vertical mobile wallpaper`,
  },

  // ============================================================
  // 20. 전생운 (Past Life Fortune)
  // ============================================================
  {
    id: "pastlife_mascot_main",
    filename: "mascot_pastlife.png",
    path: "past-life",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 1,
    category: "past-life",
    prompt: `Mystical past life guide character,
ethereal being with multiple historical costume hints,
Joseon, Victorian, Ancient elements blended,
glowing spiritual aura, wise gentle expression,
fantasy illustration style, transparent background`,
  },
  {
    id: "pastlife_icon_hourglass",
    filename: "icon_hourglass.png",
    path: "icons/past-life",
    width: 256,
    height: 256,
    transparent: true,
    priority: 1,
    category: "past-life",
    prompt: `Mystical hourglass icon, golden ornate design,
flowing sand between past and present,
time and reincarnation symbol,
magical glow effect, flat vector style,
transparent background`,
  },
  {
    id: "pastlife_bg_ethereal",
    filename: "bg_pastlife.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 2,
    category: "past-life",
    prompt: `Mystical past life background, deep purple gradient,
cosmic stars and nebula effect, time portal swirls,
ancient mysterious atmosphere,
vertical mobile wallpaper, spiritual dimension feel`,
  },

  // ============================================================
  // 21. 가족운 시리즈 (Family Fortune Series)
  // ============================================================
  {
    id: "family_mascot_main",
    filename: "mascot_family.png",
    path: "family",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "family",
    prompt: `Happy family mascot illustration,
Korean family of 4 (parents and 2 children),
warm loving poses, holding hands or hugging,
cute cartoon style, warm colors,
family harmony and love representation,
transparent background`,
  },
  {
    id: "family_icon_home",
    filename: "icon_home.png",
    path: "icons/family",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "family",
    prompt: `Cozy home icon with heart,
simple house shape with chimney,
warm orange glow from windows,
family warmth and security symbol,
flat vector design, transparent background`,
  },
  {
    id: "family_bg_warm",
    filename: "bg_family.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 3,
    category: "family",
    prompt: `Warm family background, soft peach and cream gradient,
subtle home elements silhouettes,
cozy comfortable atmosphere,
vertical mobile wallpaper, nurturing feel`,
  },

  // ============================================================
  // 22. 운동운 (Exercise Fortune)
  // ============================================================
  {
    id: "exercise_mascot_main",
    filename: "mascot_exercise.png",
    path: "exercise",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "exercise",
    prompt: `Energetic fitness mascot character,
doing stretching or jumping pose,
athletic wear, sweat drops showing effort,
healthy active lifestyle, orange and green colors,
chibi sporty illustration, transparent background`,
  },
  {
    id: "exercise_icon_dumbbell",
    filename: "icon_dumbbell.png",
    path: "icons/exercise",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "exercise",
    prompt: `Dumbbell weight icon, fitness symbol,
colorful gradient (blue to purple),
strength training representation,
flat vector design, transparent background`,
  },
  {
    id: "exercise_bg_active",
    filename: "bg_exercise.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 3,
    category: "exercise",
    prompt: `Active fitness background, energetic gradient,
orange to coral dynamic colors,
subtle motion lines and energy patterns,
vertical mobile wallpaper, motivating atmosphere`,
  },

  // ============================================================
  // 23. 이사운 (Moving Fortune)
  // ============================================================
  {
    id: "moving_mascot_main",
    filename: "mascot_moving.png",
    path: "moving",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "moving",
    prompt: `Happy moving day mascot, character with moving boxes,
excited expression, new home keys in hand,
cardboard boxes with 행복 or 福 labels,
new beginning fresh start vibes,
cute illustration style, transparent background`,
  },
  {
    id: "moving_icon_house",
    filename: "icon_new_home.png",
    path: "icons/moving",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "moving",
    prompt: `New house with sparkles icon,
cute house with key, moving truck hint,
fresh start and relocation symbol,
flat vector design, transparent background`,
  },
  {
    id: "moving_bg_fresh",
    filename: "bg_moving.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 3,
    category: "moving",
    prompt: `Fresh start background, soft sky blue gradient,
subtle cloud patterns, open window feel,
new beginnings atmosphere, clean and airy,
vertical mobile wallpaper`,
  },

  // ============================================================
  // 24. 작명운 (Naming Fortune)
  // ============================================================
  {
    id: "naming_mascot_main",
    filename: "mascot_naming.png",
    path: "naming",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "naming",
    prompt: `Scholar mascot for naming fortune,
traditional Korean scholar (선비) inspired character,
holding brush and scroll with beautiful characters,
wise thoughtful expression, ink and paper elements,
blend of traditional and cute illustration, transparent background`,
  },
  {
    id: "naming_icon_brush",
    filename: "icon_brush.png",
    path: "icons/naming",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "naming",
    prompt: `Traditional Korean calligraphy brush icon,
붓 with ink stone (벼루), writing hanja,
elegant cultural symbol for naming,
flat vector with traditional touch, transparent background`,
  },
  {
    id: "naming_bg_elegant",
    filename: "bg_naming.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 3,
    category: "naming",
    prompt: `Elegant traditional background for naming,
soft cream and gold gradient,
subtle traditional Korean paper texture,
scholarly atmosphere, vertical mobile wallpaper`,
  },

  // ============================================================
  // 25. 바이오리듬 (Biorhythm)
  // ============================================================
  {
    id: "biorhythm_mascot_main",
    filename: "mascot_biorhythm.png",
    path: "biorhythm",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "biorhythm",
    prompt: `Biorhythm mascot character,
figure with three glowing orbs (physical, emotional, intellectual),
representing body-mind balance,
colorful aura, zen-like expression,
scientific meets spiritual illustration, transparent background`,
  },
  {
    id: "biorhythm_icon_waves",
    filename: "icon_biorhythm.png",
    path: "icons/biorhythm",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "biorhythm",
    prompt: `Biorhythm wave icon, three sine waves,
red (physical), blue (emotional), green (intellectual),
overlapping rhythm curves, scientific symbol,
flat vector design, transparent background`,
  },
  {
    id: "biorhythm_bg_rhythm",
    filename: "bg_biorhythm.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 3,
    category: "biorhythm",
    prompt: `Biorhythm background, dark gradient with wave patterns,
subtle sine wave lines in multiple colors,
scientific rhythmic atmosphere,
vertical mobile wallpaper, balanced feel`,
  },

  // ============================================================
  // 26. OOTD/패션 스타일링 (Daily Fashion)
  // ============================================================
  {
    id: "ootd_mascot_main",
    filename: "mascot_ootd.png",
    path: "ootd",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "ootd",
    prompt: `Fashionable OOTD mascot character,
stylish figure in trendy Korean fashion,
shopping bags and mirror, confident pose,
fashion-forward illustration, K-fashion aesthetic,
transparent background`,
  },
  {
    id: "ootd_icon_hanger",
    filename: "icon_hanger.png",
    path: "icons/ootd",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "ootd",
    prompt: `Fashion hanger with outfit icon,
stylish clothes on hanger, colorful,
daily outfit styling symbol,
flat vector design, transparent background`,
  },
  {
    id: "ootd_bg_fashion",
    filename: "bg_ootd.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 3,
    category: "ootd",
    prompt: `Fashion forward background, blush pink gradient,
subtle wardrobe silhouettes, chic atmosphere,
runway inspired, vertical mobile wallpaper`,
  },

  // ============================================================
  // 27. 시간대별 운세 (Time-based Fortune)
  // ============================================================
  {
    id: "time_icon_morning",
    filename: "icon_morning.png",
    path: "icons/time",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "time",
    prompt: `Morning sun icon, sunrise with rays,
fresh start of day symbolism,
warm orange and yellow gradient,
flat vector design, transparent background`,
  },
  {
    id: "time_icon_afternoon",
    filename: "icon_afternoon.png",
    path: "icons/time",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "time",
    prompt: `Afternoon sun icon, bright midday sun,
peak energy symbolism, golden yellow,
flat vector design, transparent background`,
  },
  {
    id: "time_icon_evening",
    filename: "icon_evening.png",
    path: "icons/time",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "time",
    prompt: `Evening sunset icon, setting sun,
warm orange to purple gradient,
transition time symbolism,
flat vector design, transparent background`,
  },
  {
    id: "time_icon_night",
    filename: "icon_night.png",
    path: "icons/time",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "time",
    prompt: `Night moon and stars icon,
crescent moon with twinkling stars,
peaceful night symbolism, blue and silver,
flat vector design, transparent background`,
  },

  // ============================================================
  // 28. 피해야 할 사람 (Avoid People)
  // ============================================================
  {
    id: "avoid_mascot_main",
    filename: "mascot_avoid.png",
    path: "avoid-people",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 2,
    category: "avoid-people",
    prompt: `Cautious character mascot for avoid fortune,
thoughtful expression, looking carefully around,
shield or barrier symbolic element,
protective self-care illustration style,
not scary, just careful, transparent background`,
    negativePrompt: "scary, threatening, violent, dark",
  },
  {
    id: "avoid_icon_shield",
    filename: "icon_shield.png",
    path: "icons/avoid-people",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2,
    category: "avoid-people",
    prompt: `Protection shield icon,
golden shield with soft glow,
self-protection and boundary symbol,
flat vector design, transparent background`,
  },

  // ============================================================
  // 29. 전 애인 운세 (Ex-Lover Fortune)
  // ============================================================
  {
    id: "exlover_mascot_main",
    filename: "mascot_exlover.png",
    path: "ex-lover",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 3,
    category: "ex-lover",
    prompt: `Contemplative character for ex-lover fortune,
thoughtful expression looking at old memories,
photo album or broken heart healing imagery,
bittersweet but hopeful illustration,
closure and moving on theme, transparent background`,
    negativePrompt: "angry, violent, dark, depressing",
  },
  {
    id: "exlover_icon_heartbreak",
    filename: "icon_mending_heart.png",
    path: "icons/ex-lover",
    width: 256,
    height: 256,
    transparent: true,
    priority: 3,
    category: "ex-lover",
    prompt: `Mending heart icon, cracked heart with bandage,
healing and recovery symbolism,
hopeful pink and gold colors,
flat vector design, transparent background`,
  },

  // ============================================================
  // 30. 연예인 사주 (Celebrity Fortune)
  // ============================================================
  {
    id: "celebrity_mascot_main",
    filename: "mascot_celebrity.png",
    path: "celebrity",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 3,
    category: "celebrity",
    prompt: `Star celebrity mascot character,
glamorous figure with spotlight and stars,
red carpet vibes, confident pose,
K-pop idol inspired illustration,
transparent background`,
  },
  {
    id: "celebrity_icon_star",
    filename: "icon_celebrity_star.png",
    path: "icons/celebrity",
    width: 256,
    height: 256,
    transparent: true,
    priority: 3,
    category: "celebrity",
    prompt: `Celebrity star icon, Hollywood-style star,
glowing golden star with sparkles,
fame and stardom symbol,
flat vector design, transparent background`,
  },

  // ============================================================
  // 31. 풍수 인테리어 (Feng Shui)
  // ============================================================
  {
    id: "fengshui_mascot_main",
    filename: "mascot_fengshui.png",
    path: "fengshui",
    width: 1024,
    height: 1024,
    transparent: true,
    priority: 3,
    category: "fengshui",
    prompt: `Feng shui master mascot character,
wise character with compass (나침반),
surrounded by yin-yang and five elements symbols,
harmony and balance representation,
traditional meets modern illustration, transparent background`,
  },
  {
    id: "fengshui_icon_compass",
    filename: "icon_compass.png",
    path: "icons/fengshui",
    width: 256,
    height: 256,
    transparent: true,
    priority: 3,
    category: "fengshui",
    prompt: `Feng shui compass (나경) icon,
traditional compass with bagua symbols,
harmony and direction representation,
flat vector with traditional elements, transparent background`,
  },
  {
    id: "fengshui_icon_yinyang",
    filename: "icon_yinyang.png",
    path: "icons/fengshui",
    width: 256,
    height: 256,
    transparent: true,
    priority: 3,
    category: "fengshui",
    prompt: `Yin-yang symbol icon,
classic black and white balance,
subtle gradient and glow effect,
harmony symbol, flat vector, transparent background`,
  },
  {
    id: "fengshui_bg_harmony",
    filename: "bg_fengshui.png",
    path: "bg",
    width: 1080,
    height: 1920,
    transparent: false,
    priority: 3,
    category: "fengshui",
    prompt: `Feng shui harmony background,
soft green and cream gradient,
subtle bamboo and water elements,
balanced peaceful atmosphere,
vertical mobile wallpaper, zen feel`,
  },

  // ============================================================
  // [NEW] 21. 운세 결과 히어로 이미지 (Fortune Heroes)
  // ============================================================
  ...["daily", "love", "career", "health", "investment", "tarot", "dream", "exam", "compatibility", "mbti", "past_life", "wish"].flatMap((type) => {
    const subjects: Record<string, string> = {
      daily: "Sun and clouds over mountains",
      love: "Blooming peonies and mandarin ducks",
      career: "Soaring eagle and bamboo forest",
      health: "Cranes and pine trees",
      investment: "Bull and golden coins",
      tarot: "Mystical moon and stars",
      dream: "Dreamy clouds and butterflies",
      exam: "Success brushes and books",
      compatibility: "Yin-yang harmony and lotus",
      mbti: "Stylized characters and geometric patterns",
      past_life: "Royal palace and ancient scenery",
      wish: "Dragon chasing a pearl",
    };
    
    return ["high", "medium", "low"].map((level) => {
      const moods: Record<string, string> = {
        high: "bright, sunny, prosperous, vibrant colors",
        medium: "calm, stable, peaceful, soft colors",
        low: "stormy, careful, warning, muted or dark colors",
      };
      
      const filenameMap: Record<string, Record<string, string>> = {
        daily: { high: "daily_hero_sunny.webp", medium: "daily_hero_cloudy.webp", low: "daily_hero_stormy.webp" },
        love: { high: "love_hero_blooming.webp", medium: "love_hero_stable.webp", low: "love_hero_waiting.webp" },
        career: { high: "career_hero_promotion.webp", medium: "career_hero_stable.webp", low: "career_hero_challenge.webp" },
        health: { high: "health_hero_vitality.webp", medium: "health_hero_balance.webp", low: "health_hero_caution.webp" },
        investment: { high: "invest_hero_bull.webp", medium: "invest_hero_neutral.webp", low: "invest_hero_bear.webp" },
        tarot: { high: "tarot_hero_mystical.webp", medium: "tarot_hero_mystical.webp", low: "tarot_hero_mystical.webp" },
        dream: { high: "dream_hero_auspicious.webp", medium: "dream_hero_mysterious.webp", low: "dream_hero_warning.webp" },
        exam: { high: "exam_hero_grade_a.webp", medium: "exam_hero_grade_b.webp", low: "exam_hero_grade_c.webp" },
        compatibility: { high: "compat_hero_perfect.webp", medium: "compat_hero_good.webp", low: "compat_hero_challenging.webp" },
        mbti: { high: "mbti_hero_energy.webp", medium: "mbti_hero_balanced.webp", low: "mbti_hero_recharge.webp" },
        past_life: { high: "pastlife_hero_royal.webp", medium: "pastlife_hero_scholar.webp", low: "pastlife_hero_common.webp" },
        wish: { high: "wish_hero_dragon.webp", medium: "wish_hero_star.webp", low: "wish_hero_fountain.webp" },
      };

      return {
        id: `${type}_hero_${level}`,
        filename: filenameMap[type]?.[level] || `${type}_hero_${level}.webp`,
        path: `heroes/${type.replace("_", "-")}`,
        width: 1792,
        height: 1024,
        transparent: false,
        priority: 1 as const,
        category: "heroes",
        prompt: `${subjects[type]} in traditional Korean Minhwa style, thick ink wash strokes (Balmuk), heavy Hanji paper texture, ethereal and atmospheric, ${moods[level]}, 8k resolution, cinematic lighting, no text, no words, no letters, no typography, pure illustration`,
      };
    });
  }),

  // ============================================================
  // [NEW] 22. 공유 아이콘 세트 (Shared Icons)
  // ============================================================
  // 행운 색상 (Lucky Colors)
  ...["red", "orange", "yellow", "green", "blue", "purple", "pink", "white", "black", "gold", "silver", "coral"].map((color) => ({
    id: `lucky_color_${color}`,
    filename: `lucky_color_${color}.webp`,
    path: "icons/lucky",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2 as const,
    category: "icons",
    prompt: `Minimalist brush stroke icon of ${color} color droplet or swatch, traditional sumi-e aesthetic, single stroke emphasis, rough edges, ink splatter, white background`,
  })),

  // 섹션 아이콘 (Section Icons)
  ...["work", "relationship", "health", "money", "study", "rest", "warning", "advice", "lucky", "action"].map((section) => ({
    id: `section_icon_${section}`,
    filename: `section_${section}.webp`,
    path: "icons/section",
    width: 256,
    height: 256,
    transparent: true,
    priority: 2 as const,
    category: "icons",
    prompt: `Minimalist Korean brush stroke icon for ${section}, sumi-e style, rough edges, traditional ink wash aesthetic, black ink on white background`,
  })),
];

// ============================================================
// API 클라이언트
// ============================================================

interface GenerationResult {
  success: boolean;
  assetId: string;
  filePath?: string;
  error?: string;
}

// DALL-E 3 API
async function generateWithDalle3(asset: AssetDefinition): Promise<GenerationResult> {
  const url = "https://api.openai.com/v1/images/generations";

  // DALL-E 3는 1024x1024, 1024x1792, 1792x1024만 지원
  let size = "1024x1024";
  if (asset.width > asset.height * 1.5) size = "1792x1024";
  else if (asset.height > asset.width * 1.5) size = "1024x1792";

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${CONFIG.openaiKey}`,
    },
    body: JSON.stringify({
      model: "dall-e-3",
      prompt: asset.prompt + (asset.transparent ? ", transparent background, PNG" : ""),
      n: 1,
      size,
      quality: "hd",
      response_format: "url",
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    return { success: false, assetId: asset.id, error };
  }

  const data = await response.json();
  const imageUrl = data.data[0].url;

  // 이미지 다운로드
  const imageResponse = await fetch(imageUrl);
  const imageBuffer = await imageResponse.arrayBuffer();

  // 파일 저장
  const outputPath = `${CONFIG.outputBase}/${asset.path}`;
  await Deno.mkdir(outputPath, { recursive: true });
  const filePath = `${outputPath}/${asset.filename}`;
  await Deno.writeFile(filePath, new Uint8Array(imageBuffer));

  return { success: true, assetId: asset.id, filePath };
}

// Stability AI
async function generateWithStability(asset: AssetDefinition): Promise<GenerationResult> {
  const url = "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image";

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${CONFIG.stabilityKey}`,
      Accept: "application/json",
    },
    body: JSON.stringify({
      text_prompts: [
        { text: asset.prompt, weight: 1 },
        ...(asset.negativePrompt ? [{ text: asset.negativePrompt, weight: -1 }] : []),
      ],
      cfg_scale: 7,
      height: Math.min(asset.height, 1024),
      width: Math.min(asset.width, 1024),
      samples: 1,
      steps: 30,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    return { success: false, assetId: asset.id, error };
  }

  const data = await response.json();
  const base64Image = data.artifacts[0].base64;

  // 파일 저장
  const outputPath = `${CONFIG.outputBase}/${asset.path}`;
  await Deno.mkdir(outputPath, { recursive: true });
  const filePath = `${outputPath}/${asset.filename}`;

  // Base64 디코딩 및 저장
  const binaryString = atob(base64Image);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  await Deno.writeFile(filePath, bytes);

  return { success: true, assetId: asset.id, filePath };
}

// Replicate (Flux)
async function generateWithReplicate(asset: AssetDefinition): Promise<GenerationResult> {
  // Replicate 구현
  // flux-schnell 또는 flux-dev 모델 사용
  const url = "https://api.replicate.com/v1/predictions";

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Token ${CONFIG.replicateKey}`,
    },
    body: JSON.stringify({
      version: "black-forest-labs/flux-schnell", // 빠른 버전
      input: {
        prompt: asset.prompt,
        num_outputs: 1,
        aspect_ratio: asset.width === asset.height ? "1:1" :
                     asset.width > asset.height ? "16:9" : "9:16",
        output_format: "png",
      },
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    return { success: false, assetId: asset.id, error };
  }

  const prediction = await response.json();

  // 결과 폴링
  let result = prediction;
  while (result.status !== "succeeded" && result.status !== "failed") {
    await new Promise((r) => setTimeout(r, 1000));
    const pollResponse = await fetch(
      `https://api.replicate.com/v1/predictions/${prediction.id}`,
      {
        headers: { Authorization: `Token ${CONFIG.replicateKey}` },
      }
    );
    result = await pollResponse.json();
  }

  if (result.status === "failed") {
    return { success: false, assetId: asset.id, error: result.error };
  }

  // 이미지 다운로드
  const imageUrl = result.output[0];
  const imageResponse = await fetch(imageUrl);
  const imageBuffer = await imageResponse.arrayBuffer();

  // 파일 저장
  const outputPath = `${CONFIG.outputBase}/${asset.path}`;
  await Deno.mkdir(outputPath, { recursive: true });
  const filePath = `${outputPath}/${asset.filename}`;
  await Deno.writeFile(filePath, new Uint8Array(imageBuffer));

  return { success: true, assetId: asset.id, filePath };
}

// ============================================================
// CLI 옵션 파싱
// ============================================================

interface CLIOptions {
  category?: string;      // 특정 카테고리만 생성
  priority?: number;      // 특정 우선순위만 생성
  api?: string;           // 사용할 API
  dryRun?: boolean;       // 실제 생성 없이 목록만 표시
  single?: string;        // 단일 에셋 ID만 생성
  list?: boolean;         // 에셋 목록만 표시
  help?: boolean;
}

function parseArgs(): CLIOptions {
  const args = Deno.args;
  const options: CLIOptions = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case "--category":
      case "-c":
        options.category = args[++i];
        break;
      case "--priority":
      case "-p":
        options.priority = parseInt(args[++i]);
        break;
      case "--api":
      case "-a":
        options.api = args[++i];
        break;
      case "--dry-run":
      case "-d":
        options.dryRun = true;
        break;
      case "--single":
      case "-s":
        options.single = args[++i];
        break;
      case "--list":
      case "-l":
        options.list = true;
        break;
      case "--help":
      case "-h":
        options.help = true;
        break;
    }
  }

  return options;
}

function printHelp() {
  console.log(`
🎨 Fortune App 이미지 에셋 생성 스크립트

사용법:
  deno run --allow-net --allow-write --allow-read --allow-env scripts/generate_fortune_assets.ts [options]

옵션:
  -c, --category <name>   특정 카테고리만 생성
                          예: --category daily, --category tarot

  -p, --priority <1|2|3>  특정 우선순위만 생성
                          1=필수, 2=중요, 3=선택

  -a, --api <name>        사용할 API 선택
                          dalle3 (기본값), stability, replicate

  -s, --single <id>       단일 에셋 ID만 생성
                          예: --single daily_mascot_main

  -l, --list              에셋 목록만 표시 (생성 안 함)

  -d, --dry-run           실제 생성 없이 계획만 표시

  -h, --help              이 도움말 표시

카테고리 목록:
  daily, love, tarot, face-reading, compatibility,
  new-year, saju, zodiac, talisman, common,
  career, health, dream, mbti, wealth,
  investment, exam, talent, lucky-items, pet-compatibility,
  blind-date, past-life, family, exercise, moving,
  naming, biorhythm, ootd, time, avoid-people,
  ex-lover, celebrity, fengshui

예시:
  # 모든 에셋 생성
  deno run ... scripts/generate_fortune_assets.ts

  # 일일 운세 에셋만 생성
  deno run ... scripts/generate_fortune_assets.ts --category daily

  # Priority 1 에셋만 생성
  deno run ... scripts/generate_fortune_assets.ts --priority 1

  # Stability AI로 타로 에셋만 생성
  deno run ... scripts/generate_fortune_assets.ts --category tarot --api stability

  # 목록만 확인
  deno run ... scripts/generate_fortune_assets.ts --list
`);
}

function listAssets(assets: AssetDefinition[]) {
  // 카테고리별 그룹화
  const byCategory: Record<string, AssetDefinition[]> = {};
  assets.forEach((a) => {
    if (!byCategory[a.category]) byCategory[a.category] = [];
    byCategory[a.category].push(a);
  });

  console.log("\n📦 에셋 목록\n");
  console.log("=".repeat(60));

  const categories = Object.keys(byCategory).sort();
  for (const cat of categories) {
    const catAssets = byCategory[cat];
    console.log(`\n📁 ${cat} (${catAssets.length}개)`);
    console.log("-".repeat(40));

    catAssets.forEach((a) => {
      const priorityIcon = a.priority === 1 ? "🔴" : a.priority === 2 ? "🟡" : "🟢";
      console.log(`  ${priorityIcon} ${a.id}`);
      console.log(`     → ${a.path}/${a.filename} (${a.width}x${a.height})`);
    });
  }

  console.log("\n" + "=".repeat(60));
  console.log(`총 ${assets.length}개 에셋`);
  console.log(`  🔴 Priority 1 (필수): ${assets.filter((a) => a.priority === 1).length}개`);
  console.log(`  🟡 Priority 2 (중요): ${assets.filter((a) => a.priority === 2).length}개`);
  console.log(`  🟢 Priority 3 (선택): ${assets.filter((a) => a.priority === 3).length}개`);
}

// ============================================================
// 메인 실행
// ============================================================

async function generateAsset(asset: AssetDefinition, api: string): Promise<GenerationResult> {
  try {
    switch (api) {
      case "dalle3":
        return await generateWithDalle3(asset);
      case "gemini":
        return await generateWithGemini(asset);
      case "stability":
        return await generateWithStability(asset);
      case "replicate":
        return await generateWithReplicate(asset);
      default:
        return { success: false, assetId: asset.id, error: `Unknown API: ${api}` };
    }
  } catch (error) {
    return { success: false, assetId: asset.id, error: String(error) };
  }
}

async function main() {
  const options = parseArgs();

  // 도움말
  if (options.help) {
    printHelp();
    return;
  }

  // API 설정
  const api = options.api || CONFIG.defaultApi;

  // 에셋 필터링
  let assetsToProcess = [...ASSETS];

  // 카테고리 필터
  if (options.category) {
    assetsToProcess = assetsToProcess.filter((a) => a.category === options.category);
    if (assetsToProcess.length === 0) {
      console.log(`❌ 카테고리 '${options.category}'에 해당하는 에셋이 없습니다.`);
      console.log("사용 가능한 카테고리: " + [...new Set(ASSETS.map((a) => a.category))].join(", "));
      return;
    }
  }

  // 우선순위 필터
  if (options.priority) {
    assetsToProcess = assetsToProcess.filter((a) => a.priority === options.priority);
  }

  // 단일 에셋 필터
  if (options.single) {
    assetsToProcess = assetsToProcess.filter((a) => a.id === options.single);
    if (assetsToProcess.length === 0) {
      console.log(`❌ ID '${options.single}'에 해당하는 에셋이 없습니다.`);
      return;
    }
  }

  // 목록만 표시
  if (options.list) {
    listAssets(assetsToProcess);
    return;
  }

  // 헤더 출력
  console.log("🎨 Fortune App 이미지 에셋 생성 시작");
  console.log("=".repeat(50));
  console.log(`📦 총 에셋 수: ${ASSETS.length}`);
  console.log(`🎯 생성 대상: ${assetsToProcess.length}개`);
  console.log(`🔧 사용 API: ${api}`);
  if (options.category) console.log(`📁 카테고리: ${options.category}`);
  if (options.priority) console.log(`⭐ 우선순위: ${options.priority}`);
  if (options.dryRun) console.log(`🔍 Dry Run 모드 (실제 생성 안 함)`);
  console.log("");

  // 우선순위별 분류
  const priority1 = assetsToProcess.filter((a) => a.priority === 1);
  const priority2 = assetsToProcess.filter((a) => a.priority === 2);
  const priority3 = assetsToProcess.filter((a) => a.priority === 3);

  console.log(`✅ Priority 1 (필수): ${priority1.length}개`);
  console.log(`📝 Priority 2 (중요): ${priority2.length}개`);
  console.log(`📌 Priority 3 (선택): ${priority3.length}개`);
  console.log("");

  // Dry run이면 목록만 출력하고 종료
  if (options.dryRun) {
    console.log("📋 생성 예정 에셋:");
    assetsToProcess.forEach((a, i) => {
      console.log(`  ${i + 1}. [P${a.priority}] ${a.id} → ${a.path}/${a.filename}`);
    });
    console.log("\n💰 예상 비용:");
    const dallePrice = 0.08;
    const stabilityPrice = 0.02;
    const replicatePrice = 0.01;
    const price = api === "dalle3" ? dallePrice : api === "stability" ? stabilityPrice : replicatePrice;
    console.log(`  ${api}: $${(assetsToProcess.length * price).toFixed(2)}`);
    return;
  }

  // API 키 확인
  if (api === "dalle3" && !CONFIG.openaiKey) {
    console.log("❌ OPENAI_API_KEY 환경변수가 설정되지 않았습니다.");
    console.log("   export OPENAI_API_KEY=your-api-key");
    return;
  }
  if (api === "stability" && !CONFIG.stabilityKey) {
    console.log("❌ STABILITY_API_KEY 환경변수가 설정되지 않았습니다.");
    return;
  }
  if (api === "replicate" && !CONFIG.replicateKey) {
    console.log("❌ REPLICATE_API_TOKEN 환경변수가 설정되지 않았습니다.");
    return;
  }

  const results: GenerationResult[] = [];
  const orderedAssets = [...priority1, ...priority2, ...priority3];

  // 순차 처리 (rate limit 고려)
  for (let i = 0; i < orderedAssets.length; i++) {
    const asset = orderedAssets[i];
    const progress = `[${i + 1}/${orderedAssets.length}]`;
    const filePath = `${CONFIG.outputBase}/${asset.path}/${asset.filename}`;

    // 파일 존재 확인 (이미 있는 파일은 스킵)
    try {
      const info = await Deno.stat(filePath);
      if (info.isFile) {
        console.log(`${progress} 스킵 (이미 존재함): ${asset.id}`);
        continue;
      }
    } catch {
      // 파일이 없으면 정상 진행 (stat 실패가 일반적)
    }

    console.log(`${progress} 생성 중: ${asset.id}`);

    let result: GenerationResult | null = null;
    let retries = 0;

    while (retries < CONFIG.maxRetries) {
      result = await generateAsset(asset, api);
      if (result.success) break;
      retries++;
      console.log(`  ⚠️ 재시도 ${retries}/${CONFIG.maxRetries}: ${result.error}`);
      await new Promise((r) => setTimeout(r, 2000));
    }

    if (result) {
      results.push(result);
      if (result.success) {
        console.log(`  ✅ 저장됨: ${result.filePath}`);
      } else {
        console.log(`  ❌ 실패: ${result.error}`);
      }
    }

    // Rate limit 방지 딜레이
    await new Promise((r) => setTimeout(r, CONFIG.delayBetweenRequests));
  }

  // 결과 요약
  console.log("");
  console.log("=".repeat(50));
  console.log("📊 생성 결과 요약");
  console.log("=".repeat(50));

  const successful = results.filter((r) => r.success);
  const failed = results.filter((r) => !r.success);

  console.log(`✅ 성공: ${successful.length}개`);
  console.log(`❌ 실패: ${failed.length}개`);

  if (failed.length > 0) {
    console.log("");
    console.log("실패한 에셋:");
    failed.forEach((r) => console.log(`  - ${r.assetId}: ${r.error}`));
  }

  // 결과 JSON 저장
  const resultFile = options.category
    ? `asset_generation_results_${options.category}.json`
    : "asset_generation_results.json";

  await Deno.writeTextFile(
    resultFile,
    JSON.stringify({
      results,
      options: { category: options.category, priority: options.priority, api },
      timestamp: new Date().toISOString(),
    }, null, 2)
  );

  console.log("");
  console.log(`🎉 완료! 결과가 ${resultFile}에 저장되었습니다.`);
}

// Gemini (Imagen 3)
async function generateWithGemini(asset: AssetDefinition): Promise<GenerationResult> {
  const apiKey = CONFIG.geminiKey;
  if (!apiKey) {
    return { success: false, assetId: asset.id, error: "GEMINI_API_KEY is missing" };
  }

  // Google AI Studio Gemini 2.5 Flash Image model
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=${apiKey}`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      contents: [
        {
          parts: [
            { text: asset.prompt }
          ],
        },
      ],
      generationConfig: {
        // Option to specify size/count might be here or handled by the model
        // Note: gemini-2.5-flash-image usually outputs images as inlineData parts
      },
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    return { success: false, assetId: asset.id, error: `Gemini API Error: ${error}` };
  }

  const data = await response.json();
  
  // Find the image part in the response
  const imagePart = data.candidates?.[0]?.content?.parts?.find((p: any) => p.inlineData);
  
  if (!imagePart || !imagePart.inlineData || !imagePart.inlineData.data) {
    return { success: false, assetId: asset.id, error: "No image generated by Gemini 2.5 Flash" };
  }

  const base64Image = imagePart.inlineData.data;

  // 파일 저장
  const outputPath = `${CONFIG.outputBase}/${asset.path}`;
  await Deno.mkdir(outputPath, { recursive: true });
  const filePath = `${outputPath}/${asset.filename}`;

  // Base64 디코딩 및 저장
  const bytes = Uint8Array.from(atob(base64Image), c => c.charCodeAt(0));
  await Deno.writeFile(filePath, bytes);

  return { success: true, assetId: asset.id, filePath };
}

// 실행
if (import.meta.main) {
  main();
}