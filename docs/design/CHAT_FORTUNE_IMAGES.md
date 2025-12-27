# 채팅 운세 이미지 스펙 문서

> **Version**: 1.0.0
> **Last Updated**: December 2025
> **Purpose**: 채팅 레이아웃에 사용될 운세별 동양적 이미지 자산 스펙

---

## 개요

채팅 기반 운세 조회 시 각 운세 유형별로 분위기를 전달하는 장식 이미지가 필요합니다.
한국 전통 미학(한지, 오방색, 민화 스타일)을 기반으로 제작합니다.

### 디자인 원칙

- **질감**: 한지 위에 먹으로 그린 듯한 느낌
- **색상**: 오방색 (청, 적, 황, 백, 흑) + 인주색 포인트
- **스타일**: 전통 민화의 현대적 재해석
- **형식**: PNG (투명 배경) 권장

---

## 기존 자산 (활용 가능)

| 카테고리 | 경로 | 수량 | 용도 |
|----------|------|------|------|
| 타로 카드 | `assets/images/tarot/` | 78장 | 타로 운세 |
| 라이더-웨이트 덱 | `assets/images/tarot/decks/rider_waite/` | 78장 | 타로 운세 |

---

## 신규 제작 필요 이미지

### 저장 위치

```
assets/images/fortune/
├── headers/          # 채팅 헤더 장식 (작은 이미지)
├── backgrounds/      # 결과 카드 배경 패턴
├── icons/            # 운세 유형 아이콘
└── decorations/      # 장식 요소
```

---

## 카테고리별 이미지 스펙

### 1. 시간 기반 운세

#### daily (오늘의 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `daily_header.png`, `daily_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 황색 계열 (#B8860B, #D4A017) |
| 모티프 | 해와 달, 구름, 24절기 상징 |
| 프롬프트 | "Traditional Korean minhwa style illustration of sun and moon with clouds, painted on hanji paper texture, golden yellow tones (#B8860B), minimalist ink brush strokes, transparent background" |

#### yearly (연간 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `yearly_header.png`, `yearly_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 청색 + 황색 (#1E3A5F, #B8860B) |
| 모티프 | 12지신, 연도를 상징하는 동물 (용, 뱀 등) |
| 프롬프트 | "Korean traditional minhwa zodiac animal painting, elegant brushwork on hanji paper, deep blue and gold accents, minimal composition, transparent background" |

#### newYear (새해 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `newyear_header.png`, `newyear_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 적색 + 황색 (#B91C1C, #D4A017) |
| 모티프 | 복주머니, 매화, 까치 |
| 프롬프트 | "Korean New Year minhwa illustration with fortune pouch and plum blossoms, traditional red and gold colors, hanji paper texture, festive yet elegant, transparent background" |

---

### 2. 전통 분석

#### traditional (사주 분석)
| 항목 | 스펙 |
|------|------|
| 파일명 | `saju_header.png`, `saju_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 흑색 + 인주색 (#1C1C1C, #DC2626) |
| 모티프 | 팔괘, 음양 문양, 사주 기호 |
| 프롬프트 | "Traditional Korean Saju/Four Pillars elements with Yin-Yang and Bagua symbols, ink brush calligraphy style, black ink on hanji paper with red seal accent, transparent background" |

#### faceReading (AI 관상)
| 항목 | 스펙 |
|------|------|
| 파일명 | `face_header.png`, `face_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 미색 + 먹색 (#F5F5DC, #1C1C1C) |
| 모티프 | 전통 인상학 도해, 얼굴 윤곽 |
| 프롬프트 | "Traditional Korean physiognomy face diagram, elegant line art on aged hanji paper, subtle ink wash effect, scholarly aesthetic, transparent background" |

---

### 3. 성격/개성

#### mbti (MBTI 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `mbti_header.png`, `mbti_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 오방색 조합 (청, 적, 황, 백) |
| 모티프 | 네 방향, 오행 조화, 사군자 |
| 프롬프트 | "Korean traditional four noble plants (plum, orchid, chrysanthemum, bamboo) representing personality types, minhwa style, five-color palette, hanji texture, transparent background" |

#### biorhythm (바이오리듬)
| 항목 | 스펙 |
|------|------|
| 파일명 | `biorhythm_header.png`, `biorhythm_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 청/적/황 (#1E3A5F, #B91C1C, #B8860B) |
| 모티프 | 파도, 산맥, 리듬 곡선 |
| 프롬프트 | "Abstract Korean landscape with flowing wave patterns representing biorhythm cycles, three colors (blue, red, gold), ink wash style on hanji, minimalist, transparent background" |

#### personalityDna (성격 DNA)
| 항목 | 스펙 |
|------|------|
| 파일명 | `personality_header.png`, `personality_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 청색 + 황색 |
| 모티프 | 나선형 문양, 전통 기하 패턴 |
| 프롬프트 | "Korean traditional geometric spiral patterns resembling DNA helix, elegant ink brush on hanji, blue and gold accents, modern interpretation of traditional motifs, transparent background" |

#### talent (적성 찾기)
| 항목 | 스펙 |
|------|------|
| 파일명 | `talent_header.png`, `talent_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 황색 + 청색 |
| 모티프 | 붓, 악기, 화살, 책 등 재능 상징물 |
| 프롬프트 | "Korean minhwa illustration of scholar's four treasures (brush, ink, paper, inkstone) with traditional instruments, refined ink painting style, gold and blue tones, transparent background" |

---

### 4. 연애/관계

#### love (연애 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `love_header.png`, `love_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 연지색/분홍 (#DC2626 톤다운, #F5A5A5) |
| 모티프 | 원앙새, 모란꽃, 연리지 |
| 프롬프트 | "Korean minhwa mandarin ducks (love symbol) with peony flowers, soft pink and red tones, romantic hanji paper texture, traditional wedding art style, transparent background" |

#### compatibility (궁합)
| 항목 | 스펙 |
|------|------|
| 파일명 | `compatibility_header.png`, `compatibility_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 적색 + 청색 (음양) |
| 모티프 | 음양 문양, 두 마리 용/봉황, 결혼 상징 |
| 프롬프트 | "Korean traditional Yin-Yang symbol with dragon and phoenix pair, wedding minhwa style, red and blue harmony, ink brush on hanji paper, transparent background" |

#### blindDate (소개팅 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `blinddate_header.png`, `blinddate_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 연지색 + 미색 |
| 모티프 | 까치, 다리, 만남의 상징 |
| 프롬프트 | "Korean minhwa magpies meeting on a bridge (Chilseok legend), soft romantic colors, elegant brushwork on hanji, hopeful atmosphere, transparent background" |

#### exLover (재회 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `exlover_header.png`, `exlover_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 청색 (그리움) + 미색 |
| 모티프 | 달, 버드나무, 물가, 기다림 |
| 프롬프트 | "Korean minhwa moonlit willow by water, melancholic yet hopeful atmosphere, deep blue and ivory tones, lonely beauty on hanji paper, transparent background" |

#### avoidPeople (경계 대상)
| 항목 | 스펙 |
|------|------|
| 파일명 | `avoid_header.png`, `avoid_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 흑색 + 적색 (경고) |
| 모티프 | 호랑이, 방패, 부적 |
| 프롬프트 | "Korean minhwa protective tiger with talisman elements, bold black ink with red accents, powerful guardian imagery on hanji, transparent background" |

---

### 5. 재물/행운

#### money (재물운)
| 항목 | 스펙 |
|------|------|
| 파일명 | `money_header.png`, `money_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 황금색 (#D4A017, #8B6914) |
| 모티프 | 엽전, 잉어, 부귀 문양 |
| 프롬프트 | "Korean minhwa golden carp leaping over waves with traditional coins, wealth and prosperity symbols, rich gold tones on hanji paper, auspicious imagery, transparent background" |

#### luckyItems (행운 아이템)
| 항목 | 스펙 |
|------|------|
| 파일명 | `lucky_header.png`, `lucky_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 오방색 조합 |
| 모티프 | 복주머니, 길상문양, 사물 |
| 프롬프트 | "Korean minhwa lucky charms collection (fortune pouch, auspicious symbols), colorful five-color palette, playful yet elegant style on hanji, transparent background" |

#### lotto (로또 번호)
| 항목 | 스펙 |
|------|------|
| 파일명 | `lotto_header.png`, `lotto_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 황색 + 적색 (행운) |
| 모티프 | 숫자, 별, 행운의 상징 |
| 프롬프트 | "Korean minhwa lucky stars and numbers, gold and red fortune imagery, traditional number symbols on hanji paper, celebratory atmosphere, transparent background" |

---

### 6. 건강/웰빙

#### health (건강 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `health_header.png`, `health_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 청록색 (#2D5A87, 톤다운 청색) |
| 모티프 | 소나무, 학, 영지버섯, 장수 상징 |
| 프롬프트 | "Korean minhwa longevity symbols - crane, pine tree, and lingzhi mushroom, serene blue-green tones, health and vitality imagery on hanji, transparent background" |

#### exercise (운동 추천)
| 항목 | 스펙 |
|------|------|
| 파일명 | `exercise_header.png`, `exercise_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 청색 + 황색 (활력) |
| 모티프 | 태극권 자세, 활쏘기, 전통 무예 |
| 프롬프트 | "Korean traditional martial arts and movement illustration, dynamic poses in ink brush style, energetic blue and gold, hanji texture, transparent background" |

---

### 7. 꿈/인터랙티브

#### dream (꿈 해몽)
| 항목 | 스펙 |
|------|------|
| 파일명 | `dream_header.png`, `dream_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 보라/남색 + 미색 (몽환적) |
| 모티프 | 구름, 달, 물고기, 나비 |
| 프롬프트 | "Korean minhwa dreamscape with floating clouds, moon, and ethereal butterflies, mystical purple and deep blue tones, dreamy ink wash on hanji, transparent background" |

#### wish (소원 빌기)
| 항목 | 스펙 |
|------|------|
| 파일명 | `wish_header.png`, `wish_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 황색 + 적색 (소원) |
| 모티프 | 초승달, 별, 연등, 소원지 |
| 프롬프트 | "Korean traditional lantern festival with crescent moon and stars, wish paper (소원지) imagery, warm gold and red glow on hanji paper, hopeful atmosphere, transparent background" |

#### celebrity (유명인 궁합)
| 항목 | 스펙 |
|------|------|
| 파일명 | `celebrity_header.png`, `celebrity_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 황금색 + 적색 |
| 모티프 | 별, 왕관, 화려한 문양 |
| 프롬프트 | "Korean minhwa royal symbols with stars and crown motifs, elegant gold and red, celebrity aura imagery on hanji texture, glamorous yet traditional, transparent background" |

---

### 8. 가족/반려동물

#### family (가족 운세)
| 항목 | 스펙 |
|------|------|
| 파일명 | `family_header.png`, `family_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 따뜻한 황색 + 적색 |
| 모티프 | 가족 나무, 새 가족, 효도 상징 |
| 프롬프트 | "Korean minhwa family tree with birds nest and harmonious symbols, warm gold and soft red tones, familial love imagery on hanji paper, transparent background" |

#### pet (반려동물 궁합)
| 항목 | 스펙 |
|------|------|
| 파일명 | `pet_header.png`, `pet_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 미색 + 자연색 |
| 모티프 | 개, 고양이, 새 (민화 스타일 동물) |
| 프롬프트 | "Korean minhwa playful pets - dog, cat, and bird companions, folk art animal style with warm natural colors on hanji, cute yet traditional, transparent background" |

#### naming (작명)
| 항목 | 스펙 |
|------|------|
| 파일명 | `naming_header.png`, `naming_icon.png` |
| 크기 | 헤더: 320x120px, 아이콘: 64x64px |
| 색상 | 흑색 + 인주색 |
| 모티프 | 붓, 먹, 한자, 도장 |
| 프롬프트 | "Korean traditional calligraphy scene with brush, ink stone, and red seal stamp, scholar's naming ritual imagery, black ink and red accent on hanji, transparent background" |

---

## 공통 장식 요소

### 구분선 (Dividers)
| 파일명 | 크기 | 용도 |
|--------|------|------|
| `divider_wave.png` | 320x16px | 물결 구분선 |
| `divider_cloud.png` | 320x24px | 구름 구분선 |
| `divider_bamboo.png` | 320x20px | 대나무 구분선 |

### 모서리 장식 (Corner Decorations)
| 파일명 | 크기 | 용도 |
|--------|------|------|
| `corner_flower.png` | 48x48px | 꽃 모서리 (4방향 세트) |
| `corner_cloud.png` | 48x48px | 구름 모서리 (4방향 세트) |
| `corner_wave.png` | 48x48px | 파도 모서리 (4방향 세트) |

### 낙관/도장 (Seal Stamps)
| 파일명 | 크기 | 용도 |
|--------|------|------|
| `seal_fortune.png` | 64x64px | 運 (운) |
| `seal_luck.png` | 64x64px | 福 (복) |
| `seal_love.png` | 64x64px | 緣 (연) |
| `seal_wealth.png` | 64x64px | 財 (재) |
| `seal_health.png` | 64x64px | 壽 (수) |

---

## 이미지 생성 가이드

### 권장 도구
- Midjourney (v6) - 민화 스타일 최적
- DALL-E 3 - 세부 묘사 우수
- Stable Diffusion XL - 로컬 생성

### 공통 프롬프트 요소
```
Base prompt:
"Korean traditional minhwa folk painting style,
ink brush on aged hanji (Korean paper) texture,
[specific motif],
[color palette: 오방색 based],
minimal composition,
elegant and refined,
transparent background,
high resolution,
digital art suitable for mobile app UI"
```

### 후처리 체크리스트
- [ ] 배경 투명화 (PNG)
- [ ] 지정 크기로 리사이즈
- [ ] 색상 팔레트 조정 (오방색 기준)
- [ ] 에지 정리 (깔끔한 윤곽)
- [ ] 파일명 컨벤션 준수

---

## 파일 네이밍 규칙

```
{fortune_type}_{asset_type}.png

예시:
- daily_header.png
- love_icon.png
- saju_background.png
```

---

## 참조 문서

- [디자인 시스템 v2.0](/docs/design/DESIGN_SYSTEM.md)
- [UI 디자인 시스템 가이드](/.claude/docs/03-ui-design-system.md)
- [오방색 색상 시스템](/lib/core/theme/obangseok_colors.dart)
