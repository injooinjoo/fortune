# 이미지 에셋 생성 프롬프트 가이드

> AI 이미지 생성 API (DALL-E, Midjourney 등)를 통해 개별 에셋을 생성하기 위한 상세 프롬프트
> 각 에셋별 해상도, 비율, 배경, 파일명, 저장 위치 명시

---

## 공통 규칙

### 파일 저장 위치
```
assets/images/fortune/           # 운세별 메인 일러스트
assets/images/fortune/icons/     # 운세별 아이콘
assets/images/fortune/frames/    # 프레임/테두리
assets/images/fortune/bg/        # 배경 이미지
assets/images/fortune/mascot/    # 마스코트/캐릭터
assets/images/fortune/items/     # 행운 아이템 일러스트
assets/icons/fortune/            # SVG 아이콘 (벡터)
```

### 해상도 기준
| 용도 | 비율 | 해상도 | 포맷 |
|------|------|--------|------|
| 메인 일러스트 | 1:1 | 1024x1024 | PNG (투명) |
| 헤더 배경 | 16:9 | 1920x1080 | PNG |
| 카드 배경 | 3:4 | 900x1200 | PNG |
| 아이콘 (대) | 1:1 | 512x512 | PNG (투명) |
| 아이콘 (중) | 1:1 | 256x256 | PNG (투명) |
| 아이콘 (소) | 1:1 | 128x128 | PNG (투명) |
| 프레임/테두리 | 가변 | 원본 유지 | PNG (투명) |
| 패턴/텍스처 | 1:1 | 512x512 | PNG (타일링 가능) |

### 공통 프롬프트 접미사
```
PNG 투명 배경: ", transparent background, PNG format, high quality, clean edges"
PNG 배경 있음: ", high quality, detailed, 4K resolution"
일러스트 스타일: ", digital illustration, flat design, vector style"
전통 스타일: ", traditional Korean art style, minhwa painting style"
```

---

## 1. 일일 운세 (Daily Fortune)

### 테마 컨셉
- **스타일**: 모던 그라데이션 + 귀여운 마스코트
- **색상**: 민트 → 핑크 → 라벤더 그라데이션
- **분위기**: 밝고 친근한, 앱 스타일

---

### 에셋 1-1: 마스코트 (메인)
```yaml
파일명: mascot_dog_main.png
저장위치: assets/images/fortune/mascot/daily/
해상도: 1024x1024
비율: 1:1
배경: 투명 (transparent)
포맷: PNG

프롬프트: |
  Cute white Samoyed dog mascot character, happy smiling expression,
  sitting pose looking forward, wearing small red collar with golden bell,
  soft fluffy fur texture, big round sparkling eyes, pink tongue slightly out,
  chibi/kawaii style illustration, minimal shading, clean vector art style,
  front facing view, transparent background, PNG format, high quality, clean edges
```

### 에셋 1-2: 마스코트 변형 (축하)
```yaml
파일명: mascot_dog_celebrate.png
저장위치: assets/images/fortune/mascot/daily/
해상도: 1024x1024
비율: 1:1
배경: 투명

프롬프트: |
  Cute white Samoyed dog mascot character celebrating,
  jumping with joy, front paws raised up, sparkling eyes,
  party hat on head, confetti around (but sparse),
  red collar with golden bell, extremely happy expression,
  chibi/kawaii style, flat vector illustration,
  transparent background, PNG format, high quality, clean edges
```

### 에셋 1-3: 마스코트 변형 (슬픔)
```yaml
파일명: mascot_dog_sad.png
저장위치: assets/images/fortune/mascot/daily/
해상도: 1024x1024
비율: 1:1
배경: 투명

프롬프트: |
  Cute white Samoyed dog mascot character looking slightly worried,
  droopy ears, concerned expression but still cute,
  small sweat drop near head, sitting pose,
  red collar with golden bell, big puppy eyes,
  chibi/kawaii style, flat vector illustration,
  transparent background, PNG format, high quality, clean edges
```

### 에셋 1-4: 마스코트 변형 (생각)
```yaml
파일명: mascot_dog_thinking.png
저장위치: assets/images/fortune/mascot/daily/
해상도: 1024x1024
비율: 1:1
배경: 투명

프롬프트: |
  Cute white Samoyed dog mascot character in thinking pose,
  one paw on chin, looking up, thought bubble nearby (empty),
  curious expression, tilted head, red collar with golden bell,
  chibi/kawaii style, flat vector illustration,
  transparent background, PNG format, high quality, clean edges
```

### 에셋 1-5: 배경 그라데이션
```yaml
파일명: bg_daily_gradient.png
저장위치: assets/images/fortune/bg/
해상도: 1080x1920
비율: 9:16 (모바일 세로)
배경: 있음 (그라데이션 자체가 배경)
포맷: PNG

프롬프트: |
  Abstract gradient background, smooth transition from
  mint green (#98E4C9) at top to soft pink (#FFC3C3) in middle
  to lavender purple (#D4B6FF) at bottom,
  subtle floating soft light particles, dreamy atmosphere,
  no objects, pure gradient with gentle glow effects,
  mobile wallpaper style, vertical orientation, 1080x1920 pixels
```

### 에셋 1-6: 시간대 아이콘 - 아침
```yaml
파일명: icon_time_morning.png
저장위치: assets/images/fortune/icons/daily/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Simple flat icon of sunrise, half sun rising over horizon line,
  warm orange and yellow gradient sun, soft rays emanating,
  minimal design, no background elements except horizon,
  flat vector style, clean edges, app icon aesthetic,
  transparent background, PNG format
```

### 에셋 1-7: 시간대 아이콘 - 오후
```yaml
파일명: icon_time_afternoon.png
저장위치: assets/images/fortune/icons/daily/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Simple flat icon of bright sun at zenith,
  full circular sun in bright yellow/gold (#FFD700),
  short rays around, minimal design,
  flat vector style, clean edges, app icon aesthetic,
  transparent background, PNG format
```

### 에셋 1-8: 시간대 아이콘 - 저녁
```yaml
파일명: icon_time_evening.png
저장위치: assets/images/fortune/icons/daily/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Simple flat icon of crescent moon with stars,
  golden yellow crescent moon, 2-3 small stars nearby,
  calm night feeling, minimal design,
  flat vector style, clean edges, app icon aesthetic,
  transparent background, PNG format
```

### 에셋 1-9: 카테고리 아이콘 - 연애
```yaml
파일명: icon_category_love.png
저장위치: assets/icons/fortune/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple heart icon, gradient from pink (#FF6B9D) to red (#E91E63),
  rounded 3D effect with subtle shadow, glossy finish,
  single heart shape, app icon style,
  transparent background, PNG format, clean edges
```

### 에셋 1-10: 카테고리 아이콘 - 재물
```yaml
파일명: icon_category_money.png
저장위치: assets/icons/fortune/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple gold coin icon with dollar sign or Korean won (₩) symbol,
  shiny metallic gold (#FFD700) color, subtle 3D depth,
  single coin, gleaming highlight, app icon style,
  transparent background, PNG format, clean edges
```

### 에셋 1-11: 카테고리 아이콘 - 직장
```yaml
파일명: icon_category_work.png
저장위치: assets/icons/fortune/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple briefcase icon, navy blue (#1A237E) color,
  modern flat design with subtle gradient,
  professional business bag shape, gold clasp detail,
  app icon style, transparent background, PNG format, clean edges
```

### 에셋 1-12: 카테고리 아이콘 - 학업
```yaml
파일명: icon_category_study.png
저장위치: assets/icons/fortune/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple open book icon, blue (#2196F3) color,
  pages fanned open, minimal design, subtle shadow,
  study/education symbol, app icon style,
  transparent background, PNG format, clean edges
```

### 에셋 1-13: 카테고리 아이콘 - 건강
```yaml
파일명: icon_category_health.png
저장위치: assets/icons/fortune/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple flexed bicep arm icon, green (#4CAF50) gradient,
  strong muscle showing, minimal design, health symbol,
  app icon style, clean vector look,
  transparent background, PNG format, clean edges
```

---

## 2. 연애운 패션 스타일링 (Love Fashion)

### 테마 컨셉
- **스타일**: 봄 벚꽃 + 수채화 로맨틱
- **색상**: 피치(#F5E6D3), 핑크(#FFD1DC), 크림
- **분위기**: 로맨틱, 따뜻한, 봄날 데이트

---

### 에셋 2-1: 커플 일러스트 - 봄 공원
```yaml
파일명: couple_spring_park.png
저장위치: assets/images/fortune/love/
해상도: 1024x1024
비율: 1:1
배경: 투명

프롬프트: |
  Romantic couple illustration in Korean watercolor painting style,
  young couple walking together in spring park,
  man in navy suit, woman in elegant beige coat dress,
  cherry blossom trees in soft pink, petals falling gently,
  holding hands, warm sunlight, soft watercolor texture,
  dreamy romantic atmosphere, muted warm colors,
  Korean modern hanbok-inspired fashion details,
  transparent background, PNG format, high quality
```

### 에셋 2-2: 커플 일러스트 - 카페
```yaml
파일명: couple_cafe_date.png
저장위치: assets/images/fortune/love/
해상도: 1024x1024
비율: 1:1
배경: 투명

프롬프트: |
  Romantic couple at cafe illustration in soft watercolor style,
  sitting across table, coffee cups between them,
  warm cozy atmosphere, window with soft light,
  man in casual knit sweater, woman in cream blouse,
  loving gaze at each other, subtle smile,
  Korean modern illustration style, soft edges,
  transparent background, PNG format, high quality
```

### 에셋 2-3: 벚꽃 가지
```yaml
파일명: cherry_blossom_branch.png
저장위치: assets/images/fortune/love/decorations/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Single cherry blossom branch with pink flowers,
  delicate petals in soft pink (#FFB7C5),
  brown twig, 5-7 blossoms, some buds,
  watercolor texture, Korean traditional painting influence,
  graceful curved branch shape,
  transparent background, PNG format, clean edges
```

### 에셋 2-4: 벚꽃 꽃잎 (흩날리는)
```yaml
파일명: cherry_petals_falling.png
저장위치: assets/images/fortune/love/decorations/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Scattered cherry blossom petals floating in air,
  10-15 individual petals in various angles and sizes,
  soft pink (#FFB7C5) to white gradient on each petal,
  delicate, lightweight feeling, some petals closer (larger),
  watercolor texture, dreamy floating effect,
  transparent background, PNG format
```

### 에셋 2-5: 족자 프레임 (패션 아이템용)
```yaml
파일명: frame_scroll_fashion.png
저장위치: assets/images/fortune/frames/
해상도: 400x600
비율: 2:3 (세로)
배경: 투명

프롬프트: |
  Traditional Korean scroll frame (족자) for displaying fashion items,
  vertical hanging scroll shape, wooden top and bottom rods,
  red silk tassel hanging from bottom rod,
  cream/ivory paper texture inside frame area,
  gold decorative corners, traditional pattern borders,
  elegant traditional Korean aesthetic,
  center area empty for content overlay,
  transparent background outside frame, PNG format
```

### 에셋 2-6: 한자 배지 원형 프레임
```yaml
파일명: frame_hanja_circle.png
저장위치: assets/images/fortune/frames/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Circular badge frame for Chinese character display,
  gold metallic brush stroke circle, ink splatter effect,
  traditional Korean calligraphy aesthetic,
  empty center for text overlay,
  subtle gold shimmer, elegant classic look,
  transparent background, PNG format, clean edges
```

### 에셋 2-7: 패션 아이템 - 크림 니트
```yaml
파일명: fashion_cream_knit.png
저장위치: assets/images/fortune/items/fashion/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Cream colored knit sweater illustration,
  cozy chunky knit texture, oversized fit style,
  soft beige/cream (#F5F5DC) color, subtle cable knit pattern,
  flat lay view from above, fashion catalog style,
  soft shadows, clean product illustration,
  transparent background, PNG format
```

### 에셋 2-8: 패션 아이템 - 네이비 청바지
```yaml
파일명: fashion_navy_jeans.png
저장위치: assets/images/fortune/items/fashion/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Navy blue denim jeans illustration,
  straight leg fit, classic 5-pocket design,
  dark indigo (#1A237E) color, subtle denim texture,
  flat lay view, fashion catalog style,
  clean product illustration, soft shadows,
  transparent background, PNG format
```

### 에셋 2-9: 패션 아이템 - 베이지 코트
```yaml
파일명: fashion_beige_coat.png
저장위치: assets/images/fortune/items/fashion/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Elegant beige trench coat illustration,
  classic double-breasted design, belt at waist,
  warm beige (#D4B896) color, smooth fabric texture,
  flat lay view, fashion catalog style,
  clean product illustration, soft shadows,
  transparent background, PNG format
```

### 에셋 2-10: 배경 텍스처 - 피치 수채화
```yaml
파일명: bg_love_watercolor.png
저장위치: assets/images/fortune/bg/
해상도: 1080x1920
비율: 9:16
배경: 있음

프롬프트: |
  Soft watercolor background texture,
  warm peach (#F5E6D3) to soft pink (#FFD1DC) gradient,
  subtle watercolor wash effects, organic edges,
  dreamy romantic atmosphere, light paper texture,
  no objects, abstract watercolor wash only,
  vertical mobile wallpaper, 1080x1920 pixels
```

---

## 3. 타로 (Tarot)

### 테마 컨셉
- **스타일**: 신비로운 밤하늘 + 마법
- **색상**: 딥 퍼플(#1A1A2E), 골드(#FFD700), 은하수
- **분위기**: 미스티컬, 신비로운, 우주적

---

### 에셋 3-1: 타로 카드 뒷면
```yaml
파일명: tarot_card_back.png
저장위치: assets/images/fortune/tarot/
해상도: 600x900
비율: 2:3
배경: 있음 (카드 배경)

프롬프트: |
  Mystical tarot card back design,
  deep purple (#1A1A2E) base color,
  intricate gold geometric sacred geometry pattern,
  central mandala with moon phases,
  stars scattered around edges, gold border frame,
  mysterious magical atmosphere, ornate Victorian style,
  full card design, no transparent areas
```

### 에셋 3-2: 배경 - 별빛 밤하늘
```yaml
파일명: bg_tarot_starry.png
저장위치: assets/images/fortune/bg/
해상도: 1080x1920
비율: 9:16
배경: 있음

프롬프트: |
  Deep mystical night sky background,
  gradient from deep purple (#1A1A2E) to dark blue (#0D1B2A),
  scattered twinkling stars, subtle nebula clouds,
  magical atmosphere, cosmic dust particles,
  gold sparkles randomly placed, no moon,
  vertical mobile background, 1080x1920 pixels
```

### 에셋 3-3: 장식 - 금색 별
```yaml
파일명: decoration_gold_star.png
저장위치: assets/images/fortune/tarot/decorations/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Single shining gold star decoration,
  four-pointed star shape with bright glow,
  metallic gold (#FFD700) color, sparkle effect,
  magical mystical style, clean design,
  transparent background, PNG format
```

### 에셋 3-4: 장식 - 초승달
```yaml
파일명: decoration_crescent_moon.png
저장위치: assets/images/fortune/tarot/decorations/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Elegant crescent moon decoration,
  silver to gold gradient, mystical glow around edges,
  delicate celestial style, facing left,
  subtle face detail (optional), magical atmosphere,
  transparent background, PNG format
```

### 에셋 3-5: 수정구슬 아이콘
```yaml
파일명: icon_crystal_ball.png
저장위치: assets/images/fortune/tarot/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Mystical crystal ball on ornate stand,
  glowing purple (#9C27B0) mist inside glass sphere,
  gold metallic decorative stand with celestial patterns,
  magical sparkles and light reflections,
  fortune telling mystical object, detailed illustration,
  transparent background, PNG format
```

### 에셋 3-6: 스프레드 배경 - 3카드
```yaml
파일명: spread_three_card.png
저장위치: assets/images/fortune/tarot/spreads/
해상도: 1200x600
비율: 2:1
배경: 투명

프롬프트: |
  Tarot three card spread layout indicator,
  three rectangular card placement outlines in gold,
  mystical connecting lines between positions,
  labels in Korean: "과거", "현재", "미래" above each position,
  subtle glow effect, dark purple base hints,
  minimalist mystical design,
  transparent background, PNG format
```

---

## 4. 관상 (Face Reading)

### 테마 컨셉
- **스타일**: 동양 고전 + 모던 AI
- **색상**: 화이트, 그레이, 골드 악센트
- **분위기**: 분석적, 전문적, 고급스러운

---

### 에셋 4-1: 동물상 - 강아지상
```yaml
파일명: animal_face_dog.png
저장위치: assets/images/fortune/face-reading/animals/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Cute dog face illustration representing "dog-like face" personality,
  friendly Shiba Inu or Retriever style face,
  warm brown and cream colors, big friendly eyes,
  soft approachable expression, minimal stylized design,
  Korean modern illustration style, clean lines,
  transparent background, PNG format
```

### 에셋 4-2: 동물상 - 고양이상
```yaml
파일명: animal_face_cat.png
저장위치: assets/images/fortune/face-reading/animals/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Elegant cat face illustration representing "cat-like face" personality,
  mysterious sharp eyes, pointed ears,
  white or gray fur, sophisticated expression,
  slightly aloof but charming look, minimal stylized design,
  Korean modern illustration style, clean lines,
  transparent background, PNG format
```

### 에셋 4-3: 동물상 - 토끼상
```yaml
파일명: animal_face_rabbit.png
저장위치: assets/images/fortune/face-reading/animals/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Cute rabbit face illustration representing "rabbit-like face" personality,
  soft round features, long ears, big innocent eyes,
  white or light pink tones, gentle sweet expression,
  adorable and youthful look, minimal stylized design,
  Korean modern illustration style, clean lines,
  transparent background, PNG format
```

### 에셋 4-4: 동물상 - 여우상
```yaml
파일명: animal_face_fox.png
저장위치: assets/images/fortune/face-reading/animals/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Attractive fox face illustration representing "fox-like face" personality,
  sharp elegant features, pointed face shape,
  orange and white fur, intelligent alluring eyes,
  charming mysterious expression, minimal stylized design,
  Korean modern illustration style, clean lines,
  transparent background, PNG format
```

### 에셋 4-5: 동물상 - 곰상
```yaml
파일명: animal_face_bear.png
저장위치: assets/images/fortune/face-reading/animals/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Friendly bear face illustration representing "bear-like face" personality,
  round full face, small eyes, broad features,
  brown or black fur, warm dependable expression,
  gentle giant look, minimal stylized design,
  Korean modern illustration style, clean lines,
  transparent background, PNG format
```

### 에셋 4-6: 오관 아이콘 - 귀
```yaml
파일명: icon_ogwan_ear.png
저장위치: assets/images/fortune/face-reading/icons/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple human ear icon for face reading analysis,
  side view of ear, clean line art style,
  gold outline (#C9A962) on transparent background,
  medical/analytical aesthetic, minimal design,
  transparent background, PNG format
```

### 에셋 4-7: 오관 아이콘 - 눈썹
```yaml
파일명: icon_ogwan_eyebrow.png
저장위치: assets/images/fortune/face-reading/icons/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple eyebrow icon for face reading analysis,
  single elegant eyebrow shape, clean line art,
  gold outline (#C9A962) on transparent background,
  graceful arch shape, minimal design,
  transparent background, PNG format
```

### 에셋 4-8: 오관 아이콘 - 눈
```yaml
파일명: icon_ogwan_eye.png
저장위치: assets/images/fortune/face-reading/icons/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple human eye icon for face reading analysis,
  front view eye with iris and pupil,
  gold outline (#C9A962), elegant clean design,
  analytical medical aesthetic, minimal,
  transparent background, PNG format
```

### 에셋 4-9: 오관 아이콘 - 코
```yaml
파일명: icon_ogwan_nose.png
저장위치: assets/images/fortune/face-reading/icons/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple nose icon for face reading analysis,
  front view nose shape, clean line art style,
  gold outline (#C9A962), minimal design,
  analytical aesthetic,
  transparent background, PNG format
```

### 에셋 4-10: 오관 아이콘 - 입
```yaml
파일명: icon_ogwan_mouth.png
저장위치: assets/images/fortune/face-reading/icons/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Simple lips/mouth icon for face reading analysis,
  front view closed lips, clean line art style,
  gold outline (#C9A962), elegant shape,
  minimal design, analytical aesthetic,
  transparent background, PNG format
```

### 에셋 4-11: 얼굴형 다이어그램 - 둥근형
```yaml
파일명: face_shape_round.png
저장위치: assets/images/fortune/face-reading/shapes/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Face shape diagram - round/oval face type,
  simple outline of round face shape,
  gold line (#C9A962) on transparent,
  clean geometric representation, no facial features,
  medical diagram style, minimal,
  transparent background, PNG format
```

### 에셋 4-12: 전통 프레임 - 관상
```yaml
파일명: frame_face_reading_traditional.png
저장위치: assets/images/fortune/frames/
해상도: 800x1000
비율: 4:5
배경: 투명

프롬프트: |
  Traditional Korean decorative frame for face reading results,
  elegant gold and black border, traditional Korean patterns,
  clouds (구름문양) at corners, geometric center motifs,
  empty center area for content overlay,
  royal court document aesthetic, antique feel,
  transparent background, PNG format
```

---

## 5. 궁합 (Compatibility)

### 테마 컨셉
- **스타일**: 전통 혼례 + 음양
- **색상**: 레드(#C62828), 골드, 아이보리
- **분위기**: 경사스러운, 전통적, 격식있는

---

### 에셋 5-1: 원앙 일러스트
```yaml
파일명: mandarin_ducks_pair.png
저장위치: assets/images/fortune/compatibility/
해상도: 1024x1024
비율: 1:1
배경: 투명

프롬프트: |
  Traditional Korean mandarin duck pair (원앙) illustration,
  minhwa (민화) folk painting style, male and female ducks,
  swimming together on water, lotus flowers nearby,
  vibrant colors - male with colorful plumage, female more muted,
  symbol of happy marriage and love, traditional Korean art style,
  detailed feather patterns, auspicious atmosphere,
  transparent background, PNG format
```

### 에셋 5-2: 음양 심볼
```yaml
파일명: yin_yang_symbol.png
저장위치: assets/images/fortune/compatibility/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Traditional yin yang (태극) symbol,
  classic black and white with dots,
  red and blue Korean style option,
  clean perfect circle, balanced design,
  harmony and balance symbolism,
  transparent background, PNG format
```

### 에셋 5-3: 등급 도장 - A+
```yaml
파일명: stamp_grade_a_plus.png
저장위치: assets/images/fortune/compatibility/stamps/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Traditional Korean red stamp (도장) with "A+" grade,
  circular seal shape, weathered ink texture,
  deep red (#C62828) color, authentic stamp impression,
  text "천생연분" (meant to be together) around edge,
  vintage seal aesthetic, imperfect edges,
  transparent background, PNG format
```

### 에셋 5-4: 등급 도장 - B
```yaml
파일명: stamp_grade_b.png
저장위치: assets/images/fortune/compatibility/stamps/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Traditional Korean red stamp (도장) with "B" grade,
  circular seal shape, weathered ink texture,
  medium red color, authentic stamp impression,
  text "좋은 인연" around edge,
  vintage seal aesthetic, imperfect edges,
  transparent background, PNG format
```

### 에셋 5-5: 전통 배경 패턴
```yaml
파일명: pattern_traditional_wedding.png
저장위치: assets/images/fortune/bg/
해상도: 512x512
비율: 1:1 (타일링 가능)
배경: 있음

프롬프트: |
  Traditional Korean wedding pattern tile,
  subtle gold geometric patterns on cream background,
  traditional cloud motifs (구름문양), interlocking shapes,
  elegant subtle design, repeatable seamless tile,
  royal court aesthetic, auspicious patterns,
  can be used as tiling background
```

### 에셋 5-6: 두루마리 프레임
```yaml
파일명: frame_scroll_horizontal.png
저장위치: assets/images/fortune/frames/
해상도: 1200x400
비율: 3:1
배경: 투명

프롬프트: |
  Traditional Korean horizontal scroll (두루마리) frame,
  aged parchment paper texture in center,
  wooden scroll ends on left and right,
  red decorative ribbons/tassels at ends,
  empty center area for content overlay,
  traditional document aesthetic,
  transparent background, PNG format
```

### 에셋 5-7: 하트 연결 심볼
```yaml
파일명: icon_hearts_connected.png
저장위치: assets/images/fortune/compatibility/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Two hearts connected by red thread illustration,
  traditional red thread of fate (붉은 실) concept,
  two pink/red hearts, delicate red string connecting them,
  romantic destiny symbolism, clean design,
  transparent background, PNG format
```

---

## 6. 신년 운세 (New Year Fortune)

### 테마 컨셉
- **스타일**: 민화 봉황 + 용 + 황금
- **색상**: 골드(#FFD700), 레드(#C62828), 버건디
- **분위기**: 경사스러운, 화려한, 길상

---

### 에셋 6-1: 봉황 일러스트 (메인)
```yaml
파일명: phoenix_main.png
저장위치: assets/images/fortune/new-year/
해상도: 1200x800
비율: 3:2
배경: 투명

프롬프트: |
  Majestic Korean phoenix (봉황) illustration in minhwa style,
  flying across from left to right, wings fully spread,
  rich colors - red, gold, orange tail feathers,
  intricate feather patterns with traditional Korean motifs,
  five-colored plumage (오색), long flowing tail,
  auspicious mythical bird, royal elegance,
  traditional Korean folk painting style,
  transparent background, PNG format, high detail
```

### 에셋 6-2: 쌍룡 일러스트
```yaml
파일명: twin_dragons.png
저장위치: assets/images/fortune/new-year/
해상도: 800x800
비율: 1:1
배경: 투명

프롬프트: |
  Twin dragons (쌍룡) illustration in traditional Korean minhwa style,
  two dragons facing each other, circling around,
  one golden, one blue/green, clouds surrounding,
  holding or protecting a flaming pearl (여의주) between them,
  powerful auspicious symbolism, intricate scale details,
  traditional Korean dragon design (not Chinese style),
  transparent background, PNG format
```

### 에셋 6-3: 학 일러스트 (3마리)
```yaml
파일명: three_cranes.png
저장위치: assets/images/fortune/new-year/
해상도: 800x600
비율: 4:3
배경: 투명

프롬프트: |
  Three flying cranes (학) illustration in Korean minhwa style,
  red-crowned cranes in flight formation,
  white feathers with black and red accents,
  graceful flying pose, traditional clouds around,
  longevity and good fortune symbolism,
  traditional Korean folk painting aesthetic,
  transparent background, PNG format
```

### 에셋 6-4: 산수화 배경 - 일출
```yaml
파일명: landscape_sunrise.png
저장위치: assets/images/fortune/new-year/
해상도: 1080x600
비율: 9:5
배경: 있음

프롬프트: |
  Korean traditional mountain landscape with sunrise,
  mountains (산수화 style) with rising sun behind peaks,
  golden orange sun rays, misty clouds at mountain base,
  pine trees on mountain sides, peaceful scene,
  traditional Korean ink painting with color washes,
  auspicious new beginning atmosphere,
  full background, no transparency
```

### 에셋 6-5: 금색 원형 프레임
```yaml
파일명: frame_gold_circle.png
저장위치: assets/images/fortune/frames/
해상도: 600x600
비율: 1:1
배경: 투명

프롬프트: |
  Ornate golden circular frame for lucky items display,
  traditional Korean geometric patterns,
  rope/cloud motifs around edge, subtle sparkle effects,
  empty center area for content overlay,
  royal elegant aesthetic, gold (#FFD700) metallic look,
  transparent background, PNG format
```

### 에셋 6-6: 띠별 아이콘 - 쥐
```yaml
파일명: zodiac_rat.png
저장위치: assets/images/fortune/zodiac/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Traditional Korean zodiac rat illustration,
  cute stylized mouse in Korean folk art style,
  sitting pose, holding grain or coin,
  minhwa inspired design, gold and brown colors,
  auspicious clever symbolism,
  transparent background, PNG format
```

### 에셋 6-7: 띠별 아이콘 - 소
```yaml
파일명: zodiac_ox.png
저장위치: assets/images/fortune/zodiac/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Traditional Korean zodiac ox illustration,
  strong sturdy ox in Korean folk art style,
  standing noble pose, traditional patterns,
  minhwa inspired design, brown and gold colors,
  diligence and strength symbolism,
  transparent background, PNG format
```

### 에셋 6-8 ~ 6-17: 나머지 띠별 아이콘
```yaml
# 호랑이, 토끼, 용, 뱀, 말, 양, 원숭이, 닭, 개, 돼지
# 동일한 포맷으로 각각 생성
# 저장위치: assets/images/fortune/zodiac/
# 파일명: zodiac_tiger.png, zodiac_rabbit.png, zodiac_dragon.png,
#         zodiac_snake.png, zodiac_horse.png, zodiac_sheep.png,
#         zodiac_monkey.png, zodiac_rooster.png, zodiac_dog.png, zodiac_pig.png
```

### 에셋 6-18: 금박 장식 요소
```yaml
파일명: decoration_gold_flake.png
저장위치: assets/images/fortune/new-year/decorations/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Scattered gold leaf flakes decoration,
  various small gold fragments and sparkles,
  metallic gold texture, luxury aesthetic,
  random organic shapes, shimmer effect,
  for overlay decoration use,
  transparent background, PNG format
```

---

## 7. MBTI 운세

### 테마 컨셉
- **스타일**: 컬러풀 + 캐릭터 기반
- **색상**: 각 MBTI 타입별 고유 색상
- **분위기**: 개성있는, 재미있는, 현대적

---

### 에셋 7-1: MBTI 타입 배경 - INTJ
```yaml
파일명: mbti_bg_intj.png
저장위치: assets/images/fortune/mbti/backgrounds/
해상도: 512x512
비율: 1:1
배경: 있음

프롬프트: |
  Abstract background representing INTJ personality type,
  deep purple (#673AB7) to dark blue gradient,
  geometric patterns, chess pieces silhouettes,
  strategic planning symbols, constellation patterns,
  intellectual sophisticated atmosphere,
  full background, no transparency
```

### 에셋 7-2 ~ 7-17: 각 MBTI 타입별 배경
```yaml
# 16개 MBTI 타입별로 각각 생성
# INTJ(보라), INTP(청록), ENTJ(빨강), ENTP(주황)
# INFJ(파랑), INFP(라벤더), ENFJ(노랑), ENFP(핑크)
# ISTJ(네이비), ISFJ(민트), ESTJ(갈색), ESFJ(살구)
# ISTP(회색), ISFP(연두), ESTP(오렌지), ESFP(코랄)
# 저장위치: assets/images/fortune/mbti/backgrounds/
```

### 에셋 7-18: MBTI 차원 아이콘 - E/I
```yaml
파일명: icon_mbti_ei.png
저장위치: assets/images/fortune/mbti/icons/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Icon representing Extraversion/Introversion dimension,
  two-sided design - one side showing social gathering,
  other side showing single person in thought,
  balanced yin-yang style composition,
  clean modern icon design, blue and orange colors,
  transparent background, PNG format
```

---

## 8. 꿈 해몽 (Dream Fortune)

### 테마 컨셉
- **스타일**: 몽환적 + 구름
- **색상**: 보라(#7B1FA2), 파랑, 은하수
- **분위기**: 꿈결같은, 신비로운, 부드러운

---

### 에셋 8-1: 구름 프레임
```yaml
파일명: frame_cloud_dream.png
저장위치: assets/images/fortune/dream/
해상도: 600x400
비율: 3:2
배경: 투명

프롬프트: |
  Soft fluffy cloud shape frame for dream content,
  dreamy white and light purple clouds,
  gentle curved edges like thought bubble,
  empty center area for content overlay,
  soft gradient edges, ethereal atmosphere,
  transparent background, PNG format
```

### 에셋 8-2: 꿈 심볼 - 물
```yaml
파일명: dream_symbol_water.png
저장위치: assets/images/fortune/dream/symbols/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Dream symbol illustration - water/waves,
  flowing blue water in dreamy surreal style,
  soft edges, ethereal glow effect,
  symbolic representation not realistic,
  pastel blue tones, mystical atmosphere,
  transparent background, PNG format
```

### 에셋 8-3: 꿈 심볼 - 하늘
```yaml
파일명: dream_symbol_flying.png
저장위치: assets/images/fortune/dream/symbols/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Dream symbol illustration - flying in sky,
  figure with wings soaring through clouds,
  dreamy surreal style, soft purple and blue tones,
  freedom and aspiration symbolism,
  ethereal glow effect, mystical atmosphere,
  transparent background, PNG format
```

### 에셋 8-4: 배경 - 몽환 밤하늘
```yaml
파일명: bg_dream_night.png
저장위치: assets/images/fortune/bg/
해상도: 1080x1920
비율: 9:16
배경: 있음

프롬프트: |
  Dreamy mystical night sky background,
  gradient from deep purple to midnight blue,
  soft fluffy clouds scattered, twinkling stars,
  gentle aurora-like color waves,
  surreal dream world atmosphere,
  vertical mobile background, 1080x1920 pixels
```

---

## 9. 전통 사주 (Traditional Saju)

### 테마 컨셉
- **스타일**: 고전 사주명리 + 한지
- **색상**: 고서 색상, 먹색, 주홍
- **분위기**: 학문적, 전통적, 권위있는

---

### 에셋 9-1: 사주팔자 표 프레임
```yaml
파일명: frame_saju_chart.png
저장위치: assets/images/fortune/saju/
해상도: 800x600
비율: 4:3
배경: 투명

프롬프트: |
  Traditional Korean Saju (Four Pillars) chart frame,
  four vertical columns for 年月日時 pillars,
  aged Korean paper (한지) texture,
  ink brush border decorations, classical design,
  empty cells for character placement,
  traditional fortune telling document style,
  transparent background, PNG format
```

### 에셋 9-2: 오행 아이콘 - 목 (Wood)
```yaml
파일명: element_wood.png
저장위치: assets/images/fortune/saju/elements/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Five Elements icon - Wood (木),
  stylized tree or green growth symbol,
  traditional Korean design aesthetic,
  green color (#4CAF50), clean iconic design,
  Chinese character 木 subtly incorporated,
  transparent background, PNG format
```

### 에셋 9-3: 오행 아이콘 - 화 (Fire)
```yaml
파일명: element_fire.png
저장위치: assets/images/fortune/saju/elements/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Five Elements icon - Fire (火),
  stylized flame symbol,
  traditional Korean design aesthetic,
  red/orange color (#F44336), clean iconic design,
  Chinese character 火 subtly incorporated,
  transparent background, PNG format
```

### 에셋 9-4: 오행 아이콘 - 토 (Earth)
```yaml
파일명: element_earth.png
저장위치: assets/images/fortune/saju/elements/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Five Elements icon - Earth (土),
  stylized mountain or earth symbol,
  traditional Korean design aesthetic,
  yellow/brown color (#FFC107), clean iconic design,
  Chinese character 土 subtly incorporated,
  transparent background, PNG format
```

### 에셋 9-5: 오행 아이콘 - 금 (Metal)
```yaml
파일명: element_metal.png
저장위치: assets/images/fortune/saju/elements/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Five Elements icon - Metal (金),
  stylized gold/metal ingot symbol,
  traditional Korean design aesthetic,
  white/gold color (#FFD700), clean iconic design,
  Chinese character 金 subtly incorporated,
  transparent background, PNG format
```

### 에셋 9-6: 오행 아이콘 - 수 (Water)
```yaml
파일명: element_water.png
저장위치: assets/images/fortune/saju/elements/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Five Elements icon - Water (水),
  stylized water wave symbol,
  traditional Korean design aesthetic,
  blue/black color (#2196F3), clean iconic design,
  Chinese character 水 subtly incorporated,
  transparent background, PNG format
```

### 에셋 9-7: 천간 문자 배경
```yaml
파일명: bg_heavenly_stems.png
저장위치: assets/images/fortune/saju/
해상도: 400x100
비율: 4:1
배경: 투명

프롬프트: |
  Ten Heavenly Stems (천간) background strip,
  甲乙丙丁戊己庚辛壬癸 characters in row,
  faded traditional calligraphy style,
  aged paper texture effect, subtle visibility,
  decorative background element,
  transparent background, PNG format
```

---

## 10. 부적 (Talisman)

### 테마 컨셉
- **스타일**: 전통 한국 부적
- **색상**: 빨강(#E53935), 노랑(#FFC107), 검정
- **분위기**: 신비로운, 보호적, 영적

---

### 에셋 10-1: 부적 - 재물
```yaml
파일명: talisman_wealth.png
저장위치: assets/images/fortune/talisman/
해상도: 400x600
비율: 2:3
배경: 투명

프롬프트: |
  Traditional Korean wealth talisman (재물 부적),
  yellow paper base with red ink symbols,
  traditional talisman calligraphy and symbols,
  wealth bringing characters and patterns,
  authentic Korean talisman design,
  mystical protective energy feel,
  transparent background, PNG format
```

### 에셋 10-2: 부적 - 연애
```yaml
파일명: talisman_love.png
저장위치: assets/images/fortune/talisman/
해상도: 400x600
비율: 2:3
배경: 투명

프롬프트: |
  Traditional Korean love talisman (연애 부적),
  pink/red paper base with black/red ink,
  love and connection symbols, heart motifs,
  traditional talisman calligraphy style,
  romantic fate bringing design,
  mystical energy feel,
  transparent background, PNG format
```

### 에셋 10-3: 부적 - 액막이
```yaml
파일명: talisman_protection.png
저장위치: assets/images/fortune/talisman/
해상도: 400x600
비율: 2:3
배경: 투명

프롬프트: |
  Traditional Korean protection talisman (액막이 부적),
  yellow paper base with black/red ink,
  protective symbols and characters,
  evil warding patterns, strong energy lines,
  traditional talisman calligraphy style,
  powerful protective design,
  transparent background, PNG format
```

### 에셋 10-4: 부적 - 합격
```yaml
파일명: talisman_exam.png
저장위치: assets/images/fortune/talisman/
해상도: 400x600
비율: 2:3
배경: 투명

프롬프트: |
  Traditional Korean exam success talisman (합격 부적),
  yellow paper base with red ink,
  success and wisdom symbols, scholarly motifs,
  traditional talisman calligraphy style,
  study and achievement bringing design,
  transparent background, PNG format
```

### 에셋 10-5: 신비 효과 - 빛
```yaml
파일명: effect_mystic_glow.png
저장위치: assets/images/fortune/talisman/effects/
해상도: 512x512
비율: 1:1
배경: 투명

프롬프트: |
  Mystical glowing light effect overlay,
  soft golden/white radial glow,
  magical energy emanation effect,
  subtle sparkles and light particles,
  for talisman activation overlay use,
  transparent background, PNG format
```

---

## 행운 아이템 공통 에셋

### 에셋 C-1: 행운 색상 견본
```yaml
파일명: lucky_color_swatch_{color}.png
저장위치: assets/images/fortune/items/colors/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Color swatch icon for lucky color display,
  soft rounded square shape with {color} fill,
  subtle gradient and shadow for depth,
  clean modern design, slightly glossy,
  color name: {red/blue/green/yellow/purple/orange/pink/black/white}
  transparent background, PNG format

# 각 색상별 생성 필요:
# lucky_color_swatch_red.png
# lucky_color_swatch_blue.png
# lucky_color_swatch_green.png
# lucky_color_swatch_yellow.png
# lucky_color_swatch_purple.png
# lucky_color_swatch_orange.png
# lucky_color_swatch_pink.png
# lucky_color_swatch_black.png
# lucky_color_swatch_white.png
```

### 에셋 C-2: 방향 나침반
```yaml
파일명: compass_direction.png
저장위치: assets/images/fortune/items/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Traditional Korean compass (나침반) illustration,
  circular compass with Korean direction labels,
  東(동) 西(서) 南(남) 北(북) marked,
  gold and black elegant design,
  traditional aesthetic with modern clarity,
  transparent background, PNG format
```

### 에셋 C-3: 숫자 배지 (1-9)
```yaml
파일명: lucky_number_{n}.png
저장위치: assets/images/fortune/items/numbers/
해상도: 128x128
비율: 1:1
배경: 투명

프롬프트: |
  Lucky number badge displaying number {n},
  circular gold badge with number centered,
  elegant serif font, subtle sparkle effect,
  premium feeling design,
  transparent background, PNG format

# 1~9까지 각각 생성 필요
```

### 에셋 C-4: 음식 아이콘 - 떡국
```yaml
파일명: food_tteokguk.png
저장위치: assets/images/fortune/items/food/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Korean rice cake soup (떡국) illustration,
  traditional bowl with sliced rice cakes in broth,
  garnished with egg and green onion,
  appetizing warm feeling, Korean food illustration style,
  clean detailed drawing,
  transparent background, PNG format
```

### 에셋 C-5: 음식 아이콘 - 삼겹살
```yaml
파일명: food_samgyeopsal.png
저장위치: assets/images/fortune/items/food/
해상도: 256x256
비율: 1:1
배경: 투명

프롬프트: |
  Korean grilled pork belly (삼겹살) illustration,
  sizzling meat on grill, appetizing golden brown,
  side dishes hint, Korean BBQ style,
  delicious warm feeling, Korean food illustration,
  transparent background, PNG format
```

---

## 파일 생성 자동화 스크립트 예시

```dart
// Flutter에서 이미지 에셋 경로 상수 관리
class FortuneAssets {
  // 일일 운세
  static const String dailyMascotMain = 'assets/images/fortune/mascot/daily/mascot_dog_main.png';
  static const String dailyMascotCelebrate = 'assets/images/fortune/mascot/daily/mascot_dog_celebrate.png';
  static const String dailyBgGradient = 'assets/images/fortune/bg/bg_daily_gradient.png';

  // 연애운
  static const String loveCoupleSpring = 'assets/images/fortune/love/couple_spring_park.png';
  static const String loveCherryBranch = 'assets/images/fortune/love/decorations/cherry_blossom_branch.png';

  // 타로
  static const String tarotCardBack = 'assets/images/fortune/tarot/tarot_card_back.png';
  static const String tarotBgStarry = 'assets/images/fortune/bg/bg_tarot_starry.png';

  // 관상
  static const String faceAnimalDog = 'assets/images/fortune/face-reading/animals/animal_face_dog.png';
  static const String faceAnimalCat = 'assets/images/fortune/face-reading/animals/animal_face_cat.png';

  // 궁합
  static const String compatibilityDucks = 'assets/images/fortune/compatibility/mandarin_ducks_pair.png';
  static const String compatibilityYinYang = 'assets/images/fortune/compatibility/yin_yang_symbol.png';

  // 신년
  static const String newYearPhoenix = 'assets/images/fortune/new-year/phoenix_main.png';
  static const String newYearDragons = 'assets/images/fortune/new-year/twin_dragons.png';

  // 부적
  static const String talismanWealth = 'assets/images/fortune/talisman/talisman_wealth.png';
  static const String talismanLove = 'assets/images/fortune/talisman/talisman_love.png';
}
```

---

## 총 에셋 목록 요약

| 카테고리 | 에셋 수 | 주요 항목 |
|---------|--------|----------|
| 일일 운세 | 13개 | 마스코트 4, 배경 1, 시간 아이콘 3, 카테고리 5 |
| 연애운 | 10개 | 커플 2, 벚꽃 2, 프레임 2, 패션 3, 배경 1 |
| 타로 | 6개 | 카드뒷면 1, 배경 1, 장식 2, 수정구 1, 스프레드 1 |
| 관상 | 12개 | 동물상 5, 오관 5, 얼굴형 1, 프레임 1 |
| 궁합 | 7개 | 원앙 1, 음양 1, 도장 2, 패턴 1, 프레임 1, 하트 1 |
| 신년 | 18개 | 봉황 1, 용 1, 학 1, 산수화 1, 프레임 1, 띠 12, 금박 1 |
| MBTI | 17개 | 배경 16, 아이콘 1 |
| 꿈 | 4개 | 프레임 1, 심볼 2, 배경 1 |
| 사주 | 7개 | 차트 프레임 1, 오행 5, 천간 1 |
| 부적 | 5개 | 부적 4종, 효과 1 |
| 공통 | 20개+ | 색상 9, 나침반 1, 숫자 9, 음식 다수 |

**총 예상: 약 120개 이상의 개별 에셋**

---

## 생성 우선순위

### Phase 1 (필수 핵심)
1. 일일 운세 마스코트 (4개)
2. 카테고리 아이콘 (5개)
3. 배경 그라데이션 (5개)
4. 공통 프레임 (5개)

### Phase 2 (주요 운세)
1. 신년 - 봉황, 용, 학, 띠
2. 궁합 - 원앙, 음양, 도장
3. 연애 - 커플, 벚꽃, 패션

### Phase 3 (분석 운세)
1. 관상 - 동물상, 오관
2. 사주 - 오행, 차트
3. 타로 - 카드뒷면, 장식

### Phase 4 (특수 운세)
1. 부적 - 4종류
2. 꿈 - 심볼들
3. MBTI - 배경들