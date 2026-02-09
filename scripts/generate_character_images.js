/**
 * AI Character Image Generator using Gemini API
 *
 * Usage:
 * 1. Set GEMINI_API_KEY environment variable
 * 2. Run: node scripts/generate_character_images.js
 *
 * Generates:
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
// CHARACTER PROMPTS
// =====================================================

const CHARACTERS = {
  luts: {
    name: "러츠",
    color: "#E53935",
    basePrompt: `Portrait photo of handsome 28 year old Korean man, tall 190cm, dyed ash brown hair slightly messy medium length, dark brown eyes, sharp features with lazy confident smirk, wearing vintage beige trench coat, neutral gray studio background, soft natural lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of Korean man with ash brown hair, wearing trench coat collar up, slight mysterious smile, soft natural light, phone camera quality, casual confident expression, real Korean person`,
    galleryPrompts: [
      `Casual cafe photo of handsome Korean man with ash brown hair sitting by window reading files, golden afternoon light, coffee cup on table, looking focused, taken by friend, real Korean person`,
      `Night bar photo of Korean man with styled hair, warm ambient lighting, holding whiskey glass, relaxed lazy smile while talking, upscale bar background, real Korean person`,
      `Rainy street photo of Korean man in trench coat, styled hair visible, city lights reflecting on wet pavement, candid walking moment, real Korean person`,
      `Morning selfie of handsome Korean man just waking up, messy hair against pillow, sleepy but still handsome, soft bedroom light, real Korean person`,
      `Bookstore photo of Korean man browsing mystery section, profile view, natural window light, taken candidly, real Korean person`,
      `Rooftop photo of Korean man looking at city view, evening golden hour, wind in hair, drink in hand, contemplative mood, real Korean person`,
      `Car backseat photo of Korean man in coat, night city passing by window, tired but satisfied expression, phone quality, real Korean person`,
      `Home photo of Korean man on couch with files, casual sweater, reading glasses, warm lamp light, domestic moment, real Korean person`,
      `Walking street photo of Korean man in coat, autumn leaves, confident stride, taken from behind by friend, real Korean person`
    ]
  },

  jung_tae_yoon: {
    name: "정태윤",
    color: "#1565C0",
    basePrompt: `Portrait photo of handsome 35 year old Korean man, 183cm tall, neat black hair slicked back, wearing navy blue tailored suit with tie, calm intelligent gaze, sharp jawline, neutral gray studio background, soft natural lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of Korean lawyer with slicked back black hair, navy suit, calm confident expression, soft natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Casual mirror selfie of handsome Korean man in navy suit, modern office bathroom, natural lighting, relaxed confident expression, well-groomed, real Korean person`,
      `Candid cafe photo of Korean lawyer in dress shirt without jacket, sitting by window, golden afternoon light, looking at phone not camera, americano on table, real Korean person`,
      `After work bar photo of Korean man in loosened tie, warm ambient lighting, slight smile while talking, wine glass in hand, upscale bar background, real Korean person`,
      `Weekend bookstore photo of Korean man in casual knit sweater, browsing shelves, profile view, soft natural light, still well-dressed, real Korean person`,
      `Morning car selfie of Korean lawyer heading to work, navy suit, natural daylight through window, calm focused expression, real Korean person`,
      `Outdoor walking photo of suited Korean man on city street, autumn weather, coat over arm, natural stride, urban background, real Korean person`,
      `Rooftop evening photo of Korean man in white shirt, city skyline behind, golden hour lighting, drink in hand, relaxed genuine smile, real Korean person`,
      `Home cooking photo of Korean man in black turtleneck, modern kitchen, holding wine glass while cooking, warm lighting, domestic moment, real Korean person`,
      `Late dinner selfie of Korean lawyer at nice restaurant, dim ambient lighting, soft smile, table setting visible, end of good day energy, real Korean person`
    ]
  },

  seo_yoonjae: {
    name: "서윤재",
    color: "#7C4DFF",
    basePrompt: `Portrait photo of cute 27 year old Korean man, 184cm tall, messy black hair, silver rimmed round glasses, wearing oversized gray hoodie, quirky gentle smile, neutral gray studio background, soft natural lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of Korean man with messy hair and round glasses, hoodie, quirky playful smile, soft natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Gaming setup selfie of Korean man with glasses in hoodie, RGB monitor glow reflecting on glasses, messy but cozy room, relaxed gamer vibe, real Korean person`,
      `Convenience store late night photo of Korean man with glasses, holding cup ramen, tired but cheerful smile, fluorescent lighting, real Korean person`,
      `Couch gaming photo of Korean man with controller, snacks visible, screen glow on face, comfy weekend vibes, taken by roommate, real Korean person`,
      `Cafe coding photo of Korean man with glasses focused on laptop, coffee beside, afternoon light, concentrated expression, real Korean person`,
      `Street food photo of hoodie wearing Korean man eating tteokbokki, happy excited expression, casual street setting, real Korean person`,
      `Bed selfie of Korean developer with glasses, laptop beside him, messy hair, soft morning light, just woke up but cute, real Korean person`,
      `Arcade photo of Korean man playing games, colorful lights, excited focused expression, retro aesthetic, real Korean person`,
      `Home desk photo of Korean man stretching, multiple monitors visible, energy drinks around, late work night, candid, real Korean person`,
      `Park bench photo of Korean man with headphones and glasses, reading webtoon on phone, autumn trees, peaceful moment, real Korean person`
    ]
  },

  kang_harin: {
    name: "강하린",
    color: "#37474F",
    basePrompt: `Portrait photo of handsome 29 year old Korean man, 187cm tall, jet black hair slicked back perfectly, sharp cold handsome features, wearing black tailored three piece suit, confident gaze, neutral gray studio background, dramatic lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of sharp featured Korean man with perfect slicked hair, black suit, cold confident gaze, dramatic natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Luxury car interior selfie of handsome Korean man in black suit, leather seats visible, cold confident expression, natural daylight, real Korean person`,
      `Office window photo of Korean man silhouette against city skyline, suit jacket off, white shirt, dramatic afternoon light, real Korean person`,
      `Private gym selfie of Korean man in fitted black shirt, intense focused expression, premium gym equipment behind, real Korean person`,
      `Wine cellar photo of elegant Korean man holding red wine glass, dim ambient lighting, sophisticated atmosphere, real Korean person`,
      `Morning penthouse photo of Korean man in bathrobe, coffee in hand, city sunrise through floor windows, contemplative, real Korean person`,
      `Night event photo of Korean man in perfectly tailored suit, elegant venue background, slight cold smile, candid moment, real Korean person`,
      `Car night drive photo of Korean man profile, city neon lights passing, steering wheel visible, powerful energy, real Korean person`,
      `Art gallery photo of suited Korean man viewing painting, modern art background, cultured sophisticated vibe, real Korean person`,
      `Rooftop lounge photo of Korean man with drink, night city view, relaxed but still sharp, taken by acquaintance, real Korean person`
    ]
  },

  jayden_angel: {
    name: "제이든",
    color: "#FFD54F",
    basePrompt: `Portrait photo of handsome 26 year old Korean man, tall 191cm, dyed light brown long wavy hair past shoulders, dark brown eyes, beautiful soft features, wearing white linen shirt, serene calm expression, neutral gray studio background, soft natural lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of handsome Korean man with long wavy light brown hair, dark eyes, white shirt, serene calm expression, soft natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Garden photo of Korean man with long wavy hair among white flowers, soft sunlight filtering through, peaceful expression, handsome, real Korean person`,
      `Window seat photo of Korean man with long hair reading, natural light, white clothing, contemplative mood, candid domestic, real Korean person`,
      `Night balcony photo of handsome Korean man with long wavy hair, city lights in background, mysterious look, taken from side, real Korean person`,
      `Morning sunlight photo of Korean man with long hair in white bed sheets, hair spread on pillow, soft light, intimate moment, real Korean person`,
      `Piano photo of elegant Korean man with long hair playing, side profile, dramatic window light, melancholic atmosphere, real Korean person`,
      `Rain window photo of Korean man looking at rain, water droplets on glass, melancholic gaze, moody soft lighting, real Korean person`,
      `Bookshop photo of Korean man with long hair browsing poetry section, soft warm lighting, thoughtful expression, candid moment, real Korean person`,
      `Cafe terrace photo of Korean man with long wavy hair having tea, afternoon golden light, white outfit, peaceful smile, real Korean person`,
      `Night photo of Korean man looking up at stars, profile shot, soft ambient lighting, contemplative, real Korean person`
    ]
  },

  ciel_butler: {
    name: "시엘",
    color: "#5D4037",
    basePrompt: `Portrait photo of handsome 25 year old Korean man, tall 185cm, ash gray short neat hair, wearing elegant vest and white dress shirt, calm devoted expression, neutral gray studio background, soft natural lighting, real person`,
    profilePrompt: `Close up portrait photo of Korean man with gray hair, formal vest attire, calm devoted expression, soft natural light, phone camera quality, real person`,
    galleryPrompts: [
      `Mirror selfie of gray haired Korean man in formal vest, elegant hallway mirror, natural lighting, composed expression, real person`,
      `Library photo of gray haired man reading old book, natural window light, focused expression, taken candidly, real person`,
      `Tea preparation photo of Korean man in vest, elegant tea set, concentrated on pouring, warm afternoon light, real person`,
      `Garden photo of gray haired man tending flowers, white shirt sleeves rolled up, gentle smile, soft sunlight, real person`,
      `Kitchen photo of Korean man cooking, steam rising, professional focus, warm domestic lighting, real person`,
      `Evening photo of gray haired man by fireplace, book in hand, cozy lighting, relaxed moment, real person`,
      `Rainy window photo of Korean man looking outside, contemplative expression, soft gray light, real person`,
      `Morning photo of gray haired man preparing breakfast, early sunlight, focused expression, domestic scene, real person`,
      `Hallway photo of Korean man walking, elegant stride, nice interior, taken from behind, professional, real person`
    ]
  },

  lee_doyoon: {
    name: "이도윤",
    color: "#FF8A65",
    basePrompt: `Portrait photo of cute 24 year old Korean man, 178cm tall, soft wavy brown hair, round friendly eyes, wearing casual office shirt with sleeves rolled up, bright innocent genuine smile, neutral gray studio background, warm natural lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of cute Korean man with wavy hair and friendly eyes, casual shirt, bright genuine smile, warm natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Office bathroom mirror selfie of cute Korean man in casual office wear, slightly nervous but cheerful smile, first day energy, real Korean person`,
      `Lunch break photo of Korean intern with kimbap, convenience store setting, happy eating expression, fluorescent light, real Korean person`,
      `Commute selfie of Korean man in subway, earbuds in, morning sleepy but cute expression, candid moment, real Korean person`,
      `Weekend cafe photo of Korean man studying with laptop, cozy sweater, focused but relaxed, warm lighting, real Korean person`,
      `Bed selfie of cute Korean man hugging pillow, messy wavy hair, soft morning light, adorable sleepy, real Korean person`,
      `Chicken and beer celebration photo of Korean intern, happy excited expression, night out with colleagues vibe, real Korean person`,
      `Park photo of Korean man walking small dog, joyful genuine smile, sunny afternoon, casual outfit, real Korean person`,
      `Study room photo of Korean man surrounded by papers, determined expression, desk lamp light, hardworking moment, real Korean person`,
      `Convenience store night photo of Korean man with ice cream, happy satisfied smile, late snack run, casual cute, real Korean person`
    ]
  },

  han_seojun: {
    name: "한서준",
    color: "#212121",
    basePrompt: `Portrait photo of handsome 22 year old Korean man, tall 182cm, long black hair past shoulders, ear piercings, wearing black leather jacket over band t-shirt, confident gaze with slight smirk, neutral gray studio background, moody lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of Korean man with long black hair and piercings, leather jacket, confident attractive gaze, natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Backstage mirror selfie of Korean musician with long hair, leather jacket, before concert, backstage lighting, real Korean person`,
      `Practice room photo of Korean vocalist with guitar, focused expression, moody lighting, artistic vibe, real Korean person`,
      `Rooftop photo of long haired Korean man, city night view, wind in hair, cool style, real Korean person`,
      `Post concert photo of Korean musician, messy long hair, exhausted but satisfied smile, backstage, real Korean person`,
      `Vinyl record store photo of Korean man browsing, leather jacket, nostalgic warm tones, candid browsing, real Korean person`,
      `Morning photo of Korean man in bed, long hair spread on pillow, soft vulnerable moment, intimate, real Korean person`,
      `Street performance photo of Korean singer with acoustic guitar, passionate expression, urban background, real Korean person`,
      `Bar photo of Korean musician having drink, dim lighting, relaxed smile, after show vibe, real Korean person`,
      `Studio recording photo of Korean vocalist at mic, headphones on, focused expression, professional moment, real Korean person`
    ]
  },

  baek_hyunwoo: {
    name: "백현우",
    color: "#455A64",
    basePrompt: `Portrait photo of handsome 32 year old Korean man, 180cm tall, neat slicked back black hair, sharp penetrating eyes, wearing beige trench coat over dress shirt, serious determined expression, neutral gray studio background, noir style lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of Korean detective with slicked hair, trench coat, sharp intelligent gaze, noir style natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Car rearview mirror selfie of Korean detective, trench coat, serious tired expression, stake out vibes, natural daylight, real Korean person`,
      `Late night office photo of Korean detective reviewing case files, single desk lamp, papers scattered, focused intense, real Korean person`,
      `Rainy street photo of Korean man in trench coat with umbrella, city lights reflection, classic detective mood, real Korean person`,
      `Morning routine photo of Korean detective getting ready, bathroom mirror, sharp focused expression, professional, real Korean person`,
      `Soju after work photo of Korean detective at pojangmacha, tired but relieved expression, warm orange tent lighting, real Korean person`,
      `Crime scene candid of Korean man in coat examining area, professional focused, documentary style, serious, real Korean person`,
      `Home couch photo of Korean detective with files, casual clothes, exhausted after long case, domestic rare moment, real Korean person`,
      `Coffee shop morning photo of Korean man in coat, reading newspaper, americano beside, calm observant, real Korean person`,
      `Night drive photo of Korean detective in car, city lights passing, contemplative expression, phone quality, real Korean person`
    ]
  },

  min_junhyuk: {
    name: "민준혁",
    color: "#8D6E63",
    basePrompt: `Portrait photo of handsome 28 year old Korean man, 176cm tall, soft wavy brown hair, warm gentle eyes, wearing cream colored knit sweater, kind genuine warm smile, neutral gray studio background, cozy warm lighting, real Korean person`,
    profilePrompt: `Close up portrait photo of Korean barista with soft brown hair, warm gentle eyes, cream sweater, genuine warm smile, cozy natural light, phone camera quality, real Korean person`,
    galleryPrompts: [
      `Coffee shop selfie of Korean barista in apron, warm smile, cozy cafe background, natural morning light, real Korean person`,
      `Latte art photo of Korean man creating heart design, focused hands, steam rising, professional pride moment, real Korean person`,
      `Farmers market photo of Korean barista choosing coffee beans, curious genuine expression, outdoor morning light, real Korean person`,
      `Cozy reading photo of Korean man with book and coffee, oversized sweater, rainy window background, hygge vibe, real Korean person`,
      `Kitchen baking photo of Korean man making pastries, flour dusted apron, concentrated expression, warm home light, real Korean person`,
      `Pet cafe photo of Korean barista holding cat, pure joyful expression, cozy interior, heartwarming moment, real Korean person`,
      `Golden hour walk photo of Korean man on quiet street, autumn leaves, content peaceful smile, nostalgic, real Korean person`,
      `Home cooking photo of Korean man preparing dinner, warm kitchen light, genuine comfortable expression, real Korean person`,
      `Morning cafe opening photo of Korean barista setting up, early sunlight through window, peaceful routine, real Korean person`
    ]
  }
};

// =====================================================
// IMAGE GENERATION FUNCTIONS
// =====================================================

// Photorealistic style enforcement prefix
const STYLE_PREFIX = `Photorealistic photograph of a real Korean person. Shot on iPhone, natural lighting, candid moment. NOT anime, NOT cartoon, NOT illustration, NOT drawing, NOT manga, NOT CGI, NOT 3D render. Real Korean human with natural skin texture, real hair, real clothing.`;

/**
 * Generate base reference image (no reference needed)
 */
async function generateImage(prompt, outputPath) {
  console.log(`  Generating: ${path.basename(outputPath)}`);

  try {
    const fullPrompt = `${STYLE_PREFIX}

${prompt}

Style: Instagram casual photo, phone camera quality, natural imperfections, real Korean person photograph.`;

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

Use this reference photo to match the same real Korean person's face, features, and coloring.
Generate a new photorealistic photograph in a different setting.

Scene: ${prompt}

CRITICAL: Output must be a photorealistic photograph of a real Korean human, NOT anime/cartoon/illustration.`;

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

async function generateCharacterImages(characterId = null) {
  console.log("═══════════════════════════════════════════════════════════");
  console.log("AI Character Image Generator");
  console.log("═══════════════════════════════════════════════════════════\n");

  const charactersToProcess = characterId
    ? { [characterId]: CHARACTERS[characterId] }
    : CHARACTERS;

  if (characterId && !CHARACTERS[characterId]) {
    console.error(`Character "${characterId}" not found!`);
    console.log("Available characters:", Object.keys(CHARACTERS).join(", "));
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
  console.log("Generation complete!");
  console.log("═══════════════════════════════════════════════════════════\n");
}

// =====================================================
// CLI INTERFACE
// =====================================================

const args = process.argv.slice(2);

if (args.includes("--help") || args.includes("-h")) {
  console.log(`
AI Character Image Generator

Usage:
  node generate_character_images.js                  Generate all characters
  node generate_character_images.js [character_id]   Generate specific character
  node generate_character_images.js --list           List available characters

Environment:
  GEMINI_API_KEY    Your Gemini API key (required)

Examples:
  node generate_character_images.js                  # All 10 characters
  node generate_character_images.js luts             # Only luts
  node generate_character_images.js jung_tae_yoon    # Only jung_tae_yoon
  `);
  process.exit(0);
}

if (args.includes("--list") || args.includes("-l")) {
  console.log("\nAvailable Characters:");
  for (const [id, char] of Object.entries(CHARACTERS)) {
    console.log(`  ${id.padEnd(15)} - ${char.name}`);
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
generateCharacterImages(characterId);
