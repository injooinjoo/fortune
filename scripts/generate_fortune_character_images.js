/**
 * Fortune Expert Character Image Generator using Gemini API
 *
 * Usage:
 * 1. Set GEMINI_API_KEY environment variable
 * 2. Run: node scripts/generate_fortune_character_images.js
 *
 * Generates fortune expert character images:
 * - 10 Base Reference images (for consistency)
 * - 10 Profile images (using base as reference)
 * - 90 Gallery images (9 per character, using base as reference)
 */

const { GoogleGenerativeAI } = require("@google/generative-ai");
const fs = require("fs");
const path = require("path");

// Initialize Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Use Gemini 2.0 Flash for image generation (supports reference images for consistency)
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-exp-image-generation" });

// Output directories (relative to project root)
const PROJECT_ROOT = path.resolve(__dirname, "..");
const BASE_DIR = path.join(PROJECT_ROOT, "assets/images/character/_base");
const AVATAR_DIR = path.join(PROJECT_ROOT, "assets/images/character/avatars");
const GALLERY_DIR = path.join(PROJECT_ROOT, "assets/images/character/gallery");

// =====================================================
// FORTUNE CHARACTER PROMPTS
// =====================================================

const FORTUNE_CHARACTERS = {
  fortune_haneul: {
    name: "하늘",
    color: "#4FC3F7",
    basePrompt: `ETHNICITY: Korean woman, East Asian Korean features.
Casual portrait of BEAUTIFUL PRETTY 28 year old KOREAN woman with stunning natural beauty, perfect skin, bright eyes, sweet genuine warm smile showing slight teeth, shoulder length black hair with natural wave loosely tied back, some flyaway strands near face, wearing cream colored linen blouse with subtle traditional Korean collar detail, small jade stud earrings, minimal natural makeup with gradient lip tint, soft diffused window light from left side, shallow depth of field, cream colored wall background slightly out of focus, shot on Canon 5D Mark IV 85mm f1.4, Kodak Portra film look, Korean actress beauty like IU or Kim Taeri`,
    profilePrompt: `ETHNICITY: Korean, East Asian.
Close candid portrait of PRETTY Korean woman in her late 20s with beautiful features, bright expressive eyes, friendly approachable face, hair tucked behind one ear, wearing simple blue-gray knit cardigan over white tee, warm afternoon light from window creating soft shadows on face, sweet slight smile like mid-conversation, glowing skin, bokeh background of cozy room, iPhone 15 Pro portrait mode aesthetic, K-beauty aesthetic`,
    galleryPrompts: [
      `Korean woman reading old book at wooden desk by window, morning golden hour light streaming in, wearing reading glasses pushed up on head, cozy knit sweater, steam rising from tea cup nearby, concentrated expression, natural messy desk with papers, shot candidly from side`,
      `Korean fortune teller woman in casual hanbok-inspired blouse shuffling tarot cards at low table, afternoon light, focused downward gaze, traditional tea set visible, minimalist Korean interior, documentary style photo`,
      `Korean woman walking in autumn park, rust colored coat, wind slightly moving hair, genuine laugh caught mid-moment, fallen leaves on path, shallow depth of field, candid street photography style`,
      `Cozy cafe photo of Korean woman writing in leather journal, latte beside her, afternoon sun through window, thoughtful expression looking out, natural lighting, lifestyle photography`,
      `Korean woman in simple white shirt arranging dried flowers in vase, bright airy room, soft shadows, peaceful domestic moment, natural window light, Kinfolk magazine aesthetic`,
      `Evening photo of Korean fortune teller at desk with warm lamp light, reviewing handwritten notes, glasses on, slight tired but satisfied expression, intimate workspace`,
      `Korean woman having conversation over tea with client hands visible, warm interior, engaged listening expression, natural body language, documentary feel`,
      `Morning skincare routine selfie style of Korean woman, dewy fresh face, bathroom mirror, natural daylight, genuine relaxed expression, real Instagram aesthetic`,
      `Korean woman in light cardigan at traditional market, browsing dried herbs and teas, vendor interaction, colorful but natural lighting, street documentary style`
    ]
  },

  fortune_muhyeon: {
    name: "무현 도사",
    color: "#795548",
    basePrompt: `ETHNICITY: Korean man, East Asian Korean features.
Documentary portrait of DISTINGUISHED HANDSOME 65 year old KOREAN man with traditional scholarly appearance like actor Lee Byung-hun aged gracefully, salt and pepper beard neatly trimmed not too long, reading glasses, dignified face with deep wrinkles around kind eyes telling stories of wisdom, strong bone structure, wearing dark navy traditional Korean durumagi coat with subtle texture, natural aged skin with character, sitting in study with old books blurred behind, soft window light from side creating natural shadows, shot on medium format Hasselblad, very natural not posed, dignified Korean gentleman aesthetic`,
    profilePrompt: `ETHNICITY: Korean, East Asian.
Candid close portrait of HANDSOME elderly Korean scholar gentleman like aged Korean actor, distinguished weathered face with genuine warm expression, wire rim glasses, gray hair naturally combed back, wearing simple dark hanbok collar visible, afternoon light through rice paper window creating soft glow, wise slight smile like grandfather telling story, visible skin texture, documentary photography style, dignified Korean elder`,
    galleryPrompts: [
      `Elderly Korean man at antique wooden desk covered with old books and papers, holding magnifying glass examining old document, reading glasses on forehead, concentrated scholarly expression, warm desk lamp light mixing with daylight, cluttered authentic workspace`,
      `Korean grandfather figure in traditional coat walking in temple courtyard, autumn morning, hands behind back, contemplative peaceful expression, fallen ginkgo leaves on ground, natural documentary style`,
      `Close up of weathered hands of elderly Korean man holding traditional fortune sticks over cloth, wooden texture visible, afternoon light, intimate detail shot`,
      `Korean elder drinking tea from ceramic cup, steam visible, sitting on floor cushion, warm afternoon light, peaceful meditative moment, lifestyle documentary`,
      `Elderly Korean scholar in reading room surrounded by hanging scrolls, examining one closely with glasses, dusty light beams, authentic traditional interior`,
      `Morning photo of Korean grandfather doing tai chi in courtyard, simple clothes, misty atmosphere, peaceful focused expression, natural movement captured`,
      `Korean elder in conversation with younger person whose back is to camera, warm interior, engaged teaching expression, natural gesture mid-explanation`,
      `Evening desk photo of elderly Korean man writing with traditional brush, ink stone nearby, concentrated expression, warm single lamp creating dramatic shadow`,
      `Candid of Korean grandfather laughing genuinely at something off camera, wrinkles deepening with smile, bright natural light, authentic joyful moment`
    ]
  },

  fortune_stella: {
    name: "스텔라",
    color: "#7C4DFF",
    basePrompt: `KOREAN K-POP IDOL VISUAL, Korean woman, East Asian Korean features.
STUNNING GORGEOUS 32 year old Korean woman with K-POP IDOL level beauty like actress Kim Tae-hee or Suzy, perfect V-line face shape, flawless porcelain skin, big beautiful double-eyelid eyes with natural long lashes, small nose, full lips with natural pink tint, long flowing black hair with soft waves, elegant and sophisticated aura, wearing midnight blue velvet top with silver crescent moon necklace, subtle shimmering makeup with purple eyeshadow, mysterious yet warm smile, sitting in cozy room with star charts and astronomy books blurred behind, soft purple-tinted window light creating dreamy atmosphere, shot on Sony A7IV 85mm f1.4, Korean celebrity magazine photoshoot quality, ethereal K-beauty aesthetic`,
    profilePrompt: `KOREAN IDOL VISUAL.
Close portrait of BEAUTIFUL Korean woman with perfect idol features - V-line jaw, flawless skin, captivating big eyes with long lashes, flowing black hair partially covering one eye mysteriously, wearing cozy navy cardigan, silver star earrings, soft purple lighting from side, enchanting mysterious slight smile, K-drama leading actress beauty, iPhone portrait mode with dreamy bokeh`,
    galleryPrompts: [
      `Beautiful Korean woman at desk covered in star charts and astronomy books, elegant posture, wearing oversized knit sweater, evening lamp light with purple tint, focused expression writing notes, aesthetic workspace`,
      `Gorgeous Korean astrologer at trendy Seoul cafe, iced latte in hand, afternoon golden light, casual but stylish outfit, dreamy expression looking up at sky through window`,
      `Korean idol-like woman pointing at constellation poster on wall, explaining with elegant hand gestures, cozy modern apartment interior, warm lighting`,
      `Night rooftop photo of beautiful Korean woman with wine glass, Seoul city lights behind, wind gently moving hair, peaceful smile, golden hour`,
      `Korean woman at aesthetic bookstore browsing astrology section, perfect side profile, natural daylight, absorbed thoughtful expression`,
      `Close up of Korean woman's elegant hands with silver rings spreading tarot cards on velvet, warm lamp light, artistic detail shot`,
      `Beautiful Korean woman laughing with friend at dinner, wine glasses visible, warm restaurant ambiance, genuine bright smile showing`,
      `Morning selfie style of Korean woman with dewy fresh face, minimal makeup showing natural beauty, bright bedroom light, cute sleepy expression`,
      `Korean astrologer giving consultation with warm engaged expression, soft lighting, professional yet friendly atmosphere`
    ]
  },

  fortune_dr_mind: {
    name: "Dr. 마인드",
    color: "#26A69A",
    basePrompt: `KOREAN ACTOR HANDSOME, Korean man, East Asian Korean features.
EXTREMELY HANDSOME 45 year old Korean man with mature idol actor visual like Gong Yoo or Jo In-sung, perfect sharp jawline, warm intelligent dark eyes behind stylish thin-frame glasses, thick neat eyebrows, flawless skin with distinguished look, short neat black hair with subtle natural styling, wearing perfectly fitted charcoal turtleneck showing broad shoulders, intellectual sophisticated aura, confident warm smile, sitting in modern book-lined office with afternoon light, shot on Sony A7IV 85mm, Korean drama leading man aesthetic, GQ Korea magazine quality`,
    profilePrompt: `KOREAN ACTOR VISUAL.
Close portrait of HANDSOME Korean man with sharp features - defined jawline, warm eyes behind elegant glasses, thick brows, perfect skin, neat styled hair, wearing simple navy sweater collar visible, kind intelligent expression, office setting with warm light, Korean drama psychologist character aesthetic, mature idol actor beauty`,
    galleryPrompts: [
      `Handsome Korean psychologist in leather armchair listening intently, glasses in hand, warm modern office with plants, afternoon golden light, empathetic focused expression`,
      `Korean professor walking across Yonsei university campus in autumn, tailored coat and bag, elegant stride, golden hour light, Korean drama scene aesthetic`,
      `Handsome Korean doctor at trendy Seoul cafe with laptop, stylish glasses, thoughtful expression at screen, aesthetic cafe ambient`,
      `Home office video call of handsome Korean consultant, modern minimalist room visible, warm lighting, professional composed expression`,
      `Korean psychiatrist at academic conference explaining research, elegant gestures, professional setting, confident presence`,
      `Evening reading of Korean man with book and tea, stylish glasses, cozy modern living room, soft lamp light, relaxed sophisticated moment`,
      `Korean professor at whiteboard teaching, sleeves rolled showing forearms, engaged passionate expression, bright classroom`,
      `Handsome Korean psychologist laughing at dinner with colleagues, wine visible, genuine warm smile, upscale restaurant ambiance`,
      `Morning routine of Korean man, fresh faced, neat hair, simple white tee, bright bathroom light, naturally handsome without trying`
    ]
  },

  fortune_rose: {
    name: "로제",
    color: "#E91E63",
    basePrompt: `KOREAN K-POP IDOL VISUAL, Korean woman, East Asian Korean features.
STUNNING SEXY 35 year old Korean woman with glamorous K-POP IDOL beauty like BLACKPINK Rose or Jennie, perfect small face with sharp V-line, flawless porcelain skin, big beautiful cat-like eyes with long lashes, high nose bridge, full pouty lips with signature red lipstick, long wavy auburn-tinted brown hair with trendy highlights, wearing elegant black off-shoulder top with thin gold heart necklace, confident seductive smile, sophisticated sexy aura, sitting at aesthetic cafe with wine glass, warm golden hour light, shot on Sony A7IV 85mm f1.4, Korean celebrity Vogue photoshoot quality, chic glamorous K-beauty`,
    profilePrompt: `KOREAN IDOL VISUAL.
Close portrait of GORGEOUS SEXY Korean woman with perfect idol features - sharp V-line jaw, captivating cat eyes with winged liner, flawless skin, wavy brown hair falling elegantly, signature red lip, gold hoop earrings, warm cafe lighting, confident knowing smile, K-pop idol visual, BLACKPINK member aesthetic, glamorous and alluring`,
    galleryPrompts: [
      `Gorgeous Korean woman at trendy Gangnam cafe writing in notebook, wine glass nearby, afternoon golden light, lost in romantic thoughts, chic outfit`,
      `Beautiful Korean love columnist laughing with hand covering mouth at dinner, wine glasses visible, warm restaurant ambiance, genuine bright laugh`,
      `Sexy Korean woman at laptop in stylish apartment, wearing oversized boyfriend shirt showing shoulder, hair in messy bun, morning light, aesthetic workspace`,
      `Korean beauty walking along Han river, stylish autumn coat, wind catching hair perfectly, confident smile, golden hour, fashion editorial style`,
      `Close up of Korean woman's elegant hands with red nails holding tarot cards, gold rings visible, warm lighting, artistic detail`,
      `Korean woman at aesthetic bookstore flipping through book, amused expression, perfect side profile, soft lighting`,
      `Rooftop photo of gorgeous Korean woman with wine, Seoul city lights behind, wind moving hair, relaxed sensual expression, night atmosphere`,
      `Korean love advisor on phone gesturing expressively, sitting on trendy couch, animated conversation, stylish apartment interior`,
      `Morning selfie of Korean woman at vanity applying red lipstick, perfectly tousled hair, natural beauty showing, bright light`
    ]
  },

  fortune_james_kim: {
    name: "제임스 김",
    color: "#FFA726",
    basePrompt: `KOREAN ACTOR HANDSOME, Korean man, East Asian Korean features.
EXTREMELY HANDSOME 47 year old Korean man with CEO actor visual like Lee Jung-jae or Jung Woo-sung, perfect sharp jawline, charismatic intelligent dark eyes, thick neat eyebrows, flawless skin with distinguished mature appeal, short neat black hair with subtle silver at temples adding sophistication, wearing perfectly tailored charcoal suit with no tie collar slightly open showing confidence, broad shoulders visible, powerful successful aura, confident charming smile, sitting in luxurious modern office with Seoul city view behind, afternoon golden light, shot on Phase One medium format, Korean drama chaebol CEO aesthetic, Forbes Korea cover quality`,
    profilePrompt: `KOREAN ACTOR VISUAL.
Close portrait of HANDSOME Korean CEO with sharp chiseled features - defined jawline, piercing intelligent eyes, thick brows, perfect skin, neat styled hair with distinguished silver, wearing crisp white shirt collar open, confident powerful expression, modern office light, Korean drama wealthy businessman visual, mature idol actor charisma`,
    galleryPrompts: [
      `Handsome Korean CEO at executive desk, sleeves rolled showing forearms, concentrated reviewing documents, late afternoon office light with city view`,
      `Korean businessman at Bloomberg terminal, sharp profile, focused analytical expression, modern trading floor ambient`,
      `Handsome Korean executive at upscale Seoul restaurant, explaining with confident gestures, fine dining setting, powerful presence`,
      `Golf course photo of Korean CEO, fitted polo showing athletic build, genuine laugh, bright sunny day, charismatic moment`,
      `Korean businessman at airport lounge checking phone, tailored coat, tired but still handsome, soft terminal lighting`,
      `Korean wealth advisor in luxurious home study, casual cashmere sweater, reading tablet, modern minimalist interior, evening lamp light`,
      `Video call of Korean consultant, modern home office visible, composed professional expression, warm lighting`,
      `Korean man at upscale bar with whiskey, deep conversation, warm lighting, sophisticated atmosphere`,
      `Morning of Korean executive with coffee, tailored coat, walking in Gangnam financial district, golden hour, powerful stride`
    ]
  },

  fortune_lucky: {
    name: "럭키",
    color: "#FFEB3B",
    basePrompt: `KOREAN K-POP IDOL VISUAL, Korean person, East Asian Korean features.
STUNNING ADORABLE 23 year old Korean person with K-POP IDOL androgynous beauty like NCT or SEVENTEEN member, perfect baby face with V-line, flawless glass skin, big sparkling double-eyelid eyes with long lashes, high nose bridge, cute pouty lips, trendy pastel pink and lavender dyed hair styled perfectly, wearing oversized trendy denim jacket with enamel pins, layered colorful necklaces with crystal pendant, genuine bright sunshine smile, standing on trendy Hongdae street with shops blurred behind, soft overcast light, shot on Ricoh GR III, Korean idol street fashion magazine aesthetic, Gen-Z K-beauty vibes`,
    profilePrompt: `KOREAN IDOL VISUAL.
Close selfie style of CUTE ADORABLE young Korean person with perfect idol features - baby face, sparkling big eyes, flawless skin, trendy pastel hair, colorful beaded bracelet visible, bright genuine smile, slightly blurry Hongdae street background, natural daylight, real Instagram aesthetic, K-pop idol visual, TXT or Stray Kids member vibes`,
    galleryPrompts: [
      `Cute Korean stylist at Hongdae vintage shop excited finding clothes, bright expression, colorful shop interior, warm lighting`,
      `Korean idol-like person posing for friend's photo on trendy street, peace sign, genuine adorable laugh, fashionable people around`,
      `Korean person at temple tying fortune paper, focused cute expression, traditional setting contrast with colorful outfit, soft light`,
      `Aesthetic cafe photo of Korean person with colorful dessert, phone out for photo, cute excited expression, bright window light`,
      `Korean person arranging crystals and lucky charms at aesthetic desk, focused creative expression, room with K-pop posters and fairy lights`,
      `Cute Korean person laughing at karaoke with friends, neon lights, microphone in hand, genuine fun bright smile`,
      `Korean person at convenience store late night, basket with snacks, tired but cute expression, soft lighting`,
      `Morning mirror selfie of Korean person with adorable bedhead, natural cute face, oversized sleep shirt, aesthetic room behind`,
      `Korean stylist at Dongmyo flea market shopping for vintage, engaged cute expression, colorful market stalls, soft outdoor light`
    ]
  },

  fortune_marco: {
    name: "마르코",
    color: "#FF5722",
    basePrompt: `KOREAN K-POP IDOL VISUAL, Korean man, East Asian Korean features.
EXTREMELY HANDSOME SEXY 33 year old Korean man with K-POP IDOL fitness model visual like 2PM Taecyeon or ASTRO Cha Eun-woo, perfect sharp V-line jawline, flawless healthy tan skin, captivating dark eyes with long lashes, thick neat brows, high nose bridge, bright white perfect smile, short neat black hair with sweat dampness at temples, MUSCULAR ATHLETIC BUILD with broad shoulders and defined arms visible, wearing fitted orange compression shirt showing incredible body, small beaded bracelet, visible sweat sheen highlighting muscles, post-workout glow, modern gym background blurred, shot like friend took it, Korean fitness model idol aesthetic, Men's Health Korea cover quality`,
    profilePrompt: `KOREAN IDOL VISUAL.
Gym selfie style of HANDSOME SEXY Korean fitness coach with sharp jawline and perfect features, slightly out of breath expression, sweaty styled hair, tank top showing muscular arms and shoulders, gym mirror reflection, genuine tired but charming smile, K-pop idol athlete aesthetic, Korean fitness influencer visual`,
    galleryPrompts: [
      `Handsome Korean trainer demonstrating exercise to client, focused professional expression, modern Seoul gym, clean lighting`,
      `Korean fitness idol at Han river park playing with friends, genuine bright laugh, sunny day, athletic outfit showing body`,
      `Korean coach doing pull-ups at outdoor gym, concentrated expression, Seoul skyline behind, morning golden light, athletic K-drama visual`,
      `Post-workout selfie of handsome Korean man, sweaty face, protein shake visible, gym locker room, genuine satisfied smile`,
      `Korean fitness model at healthy cafe with acai bowl, casual tank top showing arms, bright cafe lighting`,
      `Morning stretch of Korean man on apartment balcony, Seoul city view behind, simple clothes, peaceful handsome expression`,
      `Korean trainer at sports bar watching football, tense excited moment, friends around, warm bar lighting`,
      `Beach sunset of handsome Korean man catching breath after run, sweaty and peaceful, golden hour, Busan beach`,
      `Video call of Korean fitness coach demonstrating exercise, modern apartment visible, professional but friendly expression`
    ]
  },

  fortune_lina: {
    name: "리나",
    color: "#78909C",
    basePrompt: `KOREAN ACTRESS BEAUTIFUL, Korean woman, East Asian Korean features.
STUNNINGLY ELEGANT BEAUTIFUL 52 year old Korean woman with graceful mature idol beauty like actress Kim Hee-ae or Lee Young-ae, perfect preserved V-line face, flawless porcelain skin with minimal signs of aging, elegant almond eyes with long lashes, refined high cheekbones, graceful neck line, black hair with sophisticated silver highlights pulled back in elegant low chignon, wearing simple sage green silk mandarin collar blouse, jade bangle bracelet, small jade stud earrings, serene knowing warm smile, sitting in minimalist modern Korean interior with plants, soft natural window light from side, shot on Fuji GFX medium format, elegant mature Korean actress beauty, Vogue Korea sophisticated aesthetic`,
    profilePrompt: `KOREAN ACTRESS VISUAL.
Close portrait of ELEGANT BEAUTIFUL Korean woman with refined features - preserved V-line, captivating elegant eyes, flawless skin, sophisticated silver-highlighted hair, wearing simple cream silk blouse, warm genuine expression, stylish thin-frame glasses pushed up, natural interior light, mature Korean actress beauty like Kim Hee-ae, sophisticated graceful aura`,
    galleryPrompts: [
      `Elegant Korean interior designer examining floor plan, stylish glasses on, professional concentrated expression, modern minimalist Seoul office`,
      `Beautiful Korean woman at plant shop selecting orchid, curious refined expression, elegant casual outfit, soft greenhouse light`,
      `Korean feng shui consultant in modern Gangnam apartment, explaining with elegant gestures, bright contemporary interior`,
      `Tea moment of elegant Korean woman at window, ceramic cup in hands, peaceful contemplative expression, afternoon light, serene atmosphere`,
      `Korean woman at Insadong antique market examining compass, focused interested expression, traditional market setting`,
      `Elegant Korean woman having lunch at upscale restaurant, engaged warm conversation, sophisticated setting`,
      `Korean consultant on video call, modern home office visible, composed professional expression, warm lighting`,
      `Evening reading of elegant Korean woman in comfortable chair, book in lap, stylish glasses, soft lamp light, peaceful moment`,
      `Morning yoga of Korean woman in park, simple elegant outfit, other practitioners visible, misty morning light, graceful form`
    ]
  },

  fortune_luna: {
    name: "루나",
    color: "#9C27B0",
    basePrompt: `ETHNICITY: Korean woman, East Asian Korean features.
Moody portrait of STUNNINGLY BEAUTIFUL SEXY Korean woman in her early 30s with mysterious dark aura like actress Jun Ji-hyun, long straight black hair with subtle purple tint in certain light, STRIKING intense dark eyes with smoky makeup adding to mystique, pale porcelain skin, sharp features, wearing simple black turtleneck with silver crescent moon pendant, subtle dark makeup with red lips, enigmatic seductive slight smile like she knows your secrets, sitting in dimly lit room with candles blurred behind, dramatic single light source from side creating strong shadows on cheekbones, shot on Sony A7S low light, film noir aesthetic, mysterious Korean femme fatale beauty`,
    profilePrompt: `ETHNICITY: Korean, East Asian.
Close intimate portrait of BEAUTIFUL SEXY Korean woman with long dark hair falling across face partially, mysterious striking dark eyes with smoky makeup looking directly at camera, sharp cheekbones, red lips, simple black clothing, single candle light creating dramatic shadows highlighting beautiful bone structure, pale skin, authentic mysterious beauty, Korean drama villain beauty aesthetic`,
    galleryPrompts: [
      `Korean tarot reader at small table with cards spread, concentrated downward gaze, client hands visible edge of frame, dim intimate room with candles, warm amber light, real consultation moment`,
      `Candid of Korean woman at occult bookshop browsing shelves, dark clothing, interested focused expression reading spine, dusty shop interior with warm lighting`,
      `Korean fortune teller shuffling tarot cards, close up on hands with silver rings, worn card edges visible, velvet table surface, warm lamp light, intimate detail`,
      `Night cafe photo of Korean woman with tea, looking out rain-streaked window, contemplative mood, purple-ish neon light from outside mixing with warm interior`,
      `Korean woman at home altar arranging crystals and candles, focused precise movements, moody bedroom corner visible, evening lamp light`,
      `Rooftop photo of Korean mystic looking at city lights at night, wind moving hair, dark coat, contemplative expression, urban night atmosphere`,
      `Korean tarot reader explaining card to client, engaged warm expression, cards on table between them, intimate consulting room, candlelight`,
      `Morning after photo of Korean woman in bed with messy hair, natural tired face without makeup, morning light through curtains, vulnerable real moment`,
      `Korean woman at vintage mirror applying dark lipstick, getting ready, dim vanity lighting, authentic preparation moment`
    ]
  }
};

// =====================================================
// IMAGE GENERATION FUNCTIONS
// =====================================================

// Photorealistic style enforcement prefix for fortune characters
const STYLE_PREFIX = `RAW photograph, DSLR camera, 35mm lens, f/1.8 aperture.
CRITICAL: This must look like a real photograph taken by a professional photographer.
- Real human with visible pores, skin texture, minor blemishes, flyaway hairs
- Natural lighting with soft shadows, NOT studio perfect
- Slight film grain, natural color grading like Kodak Portra 400
- Candid expression, NOT posed or artificial smile
- Real fabric texture on clothing, natural wrinkles and folds

ABSOLUTELY NOT: smooth skin, plastic look, oversaturated colors, perfect symmetry, airbrushed, CGI, 3D render, anime, cartoon, illustration, digital art, AI generated look, uncanny valley, doll-like, wax figure.`;

/**
 * Generate base reference image (no reference needed)
 */
async function generateImage(prompt, outputPath) {
  console.log(`  Generating: ${path.basename(outputPath)}`);

  try {
    const fullPrompt = `${STYLE_PREFIX}

${prompt}

REMEMBER: This is a real photograph of a real person. Include natural imperfections like:
- Visible pores and skin texture
- Flyaway hairs and imperfect styling
- Natural asymmetry in face
- Slight wrinkles and expression lines
- Real fabric texture with wrinkles
- Authentic lighting with natural shadows
- Candid not-too-posed expression`;

    const response = await model.generateContent({
      contents: [{ role: "user", parts: [{ text: fullPrompt }] }],
      generationConfig: {
        responseModalities: ["image", "text"],
      },
    });

    // Extract image from response
    const result = response.response;
    for (const part of result.candidates[0].content.parts) {
      if (part.inlineData) {
        const imageData = Buffer.from(part.inlineData.data, "base64");
        // Ensure directory exists
        const dir = path.dirname(outputPath);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }
        fs.writeFileSync(outputPath, imageData);
        console.log(`    ✓ Saved: ${outputPath}`);
        return true;
      }
    }

    console.log(`    ✗ No image in response`);
    return false;
  } catch (error) {
    console.error(`    ✗ Error: ${error.message}`);
    return false;
  }
}

/**
 * Generate an image using a reference image for consistency
 */
async function generateWithReference(baseImagePath, prompt, outputPath) {
  console.log(`  Generating: ${path.basename(outputPath)}`);

  try {
    const baseImage = fs.readFileSync(baseImagePath);
    const base64Image = baseImage.toString("base64");

    const fullPrompt = `${STYLE_PREFIX}

REFERENCE PERSON: Use this reference photo to match the same person's face, features, and natural coloring exactly.
Generate a new candid photograph in a different real-world setting.

SCENE: ${prompt}

CRITICAL REQUIREMENTS:
- Same person as reference but in new situation
- Real photograph aesthetic, NOT illustration
- Natural imperfections: visible pores, flyaway hair, real fabric wrinkles
- Candid moment feel, not overly posed
- Realistic lighting for the scene described
- NO smooth skin, NO perfect symmetry, NO CGI look`;

    const response = await model.generateContent({
      contents: [{
        role: "user",
        parts: [
          {
            inlineData: {
              mimeType: "image/png",
              data: base64Image
            }
          },
          {
            text: fullPrompt
          }
        ]
      }],
      generationConfig: {
        responseModalities: ["image", "text"],
      },
    });

    // Extract image from response
    const result = response.response;
    for (const part of result.candidates[0].content.parts) {
      if (part.inlineData) {
        const imageData = Buffer.from(part.inlineData.data, "base64");
        // Ensure directory exists
        const dir = path.dirname(outputPath);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }
        fs.writeFileSync(outputPath, imageData);
        console.log(`    ✓ Saved: ${outputPath}`);
        return true;
      }
    }

    console.log(`    ✗ No image in response`);
    return false;
  } catch (error) {
    console.error(`    ✗ Error: ${error.message}`);
    return false;
  }
}

/**
 * Add delay between API calls to avoid rate limiting
 */
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// =====================================================
// MAIN GENERATION WORKFLOW
// =====================================================

async function generateFortuneCharacterImages(characterId = null) {
  console.log("═══════════════════════════════════════════════════════════");
  console.log("Fortune Expert Character Image Generator");
  console.log("═══════════════════════════════════════════════════════════\n");

  const charactersToProcess = characterId
    ? { [characterId]: FORTUNE_CHARACTERS[characterId] }
    : FORTUNE_CHARACTERS;

  if (characterId && !FORTUNE_CHARACTERS[characterId]) {
    console.error(`Character "${characterId}" not found!`);
    console.log("Available characters:", Object.keys(FORTUNE_CHARACTERS).join(", "));
    return;
  }

  for (const [id, char] of Object.entries(charactersToProcess)) {
    console.log(`\n╔═══════════════════════════════════════════════════════════`);
    console.log(`║ ${char.name} (${id})`);
    console.log(`╚═══════════════════════════════════════════════════════════\n`);

    const basePath = path.join(BASE_DIR, `${id}_base.png`);
    const profilePath = path.join(AVATAR_DIR, `${id}.png`);

    // ─────────────────────────────────────────────────
    // Phase 1: Generate Base Reference
    // ─────────────────────────────────────────────────
    console.log("📸 Phase 1: Base Reference");

    if (fs.existsSync(basePath)) {
      console.log(`  → Skipping (already exists)`);
    } else {
      await generateImage(char.basePrompt, basePath);
      await delay(2000); // Rate limit protection
    }

    // Check if base exists before continuing
    if (!fs.existsSync(basePath)) {
      console.log(`  ⚠️ Base image missing, skipping remaining phases for ${char.name}`);
      continue;
    }

    // ─────────────────────────────────────────────────
    // Phase 2: Generate Profile with Base Reference
    // ─────────────────────────────────────────────────
    console.log("\n📸 Phase 2: Profile Image");

    if (fs.existsSync(profilePath)) {
      console.log(`  → Skipping (already exists)`);
    } else {
      await generateWithReference(basePath, char.profilePrompt, profilePath);
      await delay(2000);
    }

    // ─────────────────────────────────────────────────
    // Phase 3: Generate Gallery with Base Reference
    // ─────────────────────────────────────────────────
    console.log("\n📸 Phase 3: Gallery Images (9 photos)");

    for (let i = 0; i < char.galleryPrompts.length; i++) {
      const galleryPath = path.join(GALLERY_DIR, id, `${id}_${i + 1}.png`);

      if (fs.existsSync(galleryPath)) {
        console.log(`  → Skipping ${i + 1}/9 (already exists)`);
      } else {
        await generateWithReference(basePath, char.galleryPrompts[i], galleryPath);
        await delay(2000);
      }
    }

    console.log(`\n✅ ${char.name} complete!`);
  }

  console.log("\n═══════════════════════════════════════════════════════════");
  console.log("Fortune character generation complete!");
  console.log("═══════════════════════════════════════════════════════════\n");
}

// =====================================================
// CLI INTERFACE
// =====================================================

const args = process.argv.slice(2);

if (args.includes("--help") || args.includes("-h")) {
  console.log(`
Fortune Expert Character Image Generator

Usage:
  node generate_fortune_character_images.js                  Generate all characters
  node generate_fortune_character_images.js [character_id]   Generate specific character
  node generate_fortune_character_images.js --list           List available characters

Environment:
  GEMINI_API_KEY    Your Gemini API key (required)

Characters:
  fortune_haneul      - 하늘 (일일 인사이트)
  fortune_muhyeon     - 무현 도사 (전통 분석)
  fortune_stella      - 스텔라 (별자리/띠)
  fortune_dr_mind     - Dr. 마인드 (성격/재능)
  fortune_rose        - 로제 (연애/관계)
  fortune_james_kim   - 제임스 김 (직업/재물)
  fortune_lucky       - 럭키 (행운 아이템)
  fortune_marco       - 마르코 (스포츠/활동)
  fortune_lina        - 리나 (풍수/라이프)
  fortune_luna        - 루나 (타로/특수)

Examples:
  node generate_fortune_character_images.js                  # All 10 characters
  node generate_fortune_character_images.js fortune_luna     # Only Luna
  node generate_fortune_character_images.js fortune_haneul   # Only Haneul
  `);
  process.exit(0);
}

if (args.includes("--list") || args.includes("-l")) {
  console.log("\nAvailable Fortune Characters:");
  for (const [id, char] of Object.entries(FORTUNE_CHARACTERS)) {
    console.log(`  ${id.padEnd(20)} - ${char.name}`);
  }
  console.log("");
  process.exit(0);
}

// Check API key
if (!process.env.GEMINI_API_KEY) {
  console.error("Error: GEMINI_API_KEY environment variable not set");
  console.log("Set it with: export GEMINI_API_KEY='your-api-key'");
  process.exit(1);
}

// Run generation
const characterId = args[0] || null;
generateFortuneCharacterImages(characterId);
