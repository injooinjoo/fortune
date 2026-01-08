# AI Prompt Templates for Fortune Assets

This document provides standardized templates for generating ~300 image assets in the **"Hanji & Ink Wash" (Minhwa)** style.

## Core Aesthetic: Hanji & Ink Wash (발묵)

- **Texture**: Heavy Hanji (traditional Korean paper) texture with rough edges.
- **Style**: Ink wash painting (Sumi-e / Minhwa) with dynamic brush strokes.
- **Color Palette**:
  - Base: Cream (#F5F0E6) or Charcoal (#1A1A1A).
  - Accents: Deep red (먹색), Indigo, Goldleaf.

---

## 1. Hero Illustrations (Heroes)

_Used for SliverAppBar backgrounds. 21:9 or 16:9 ratio._

### Template

> `[Subject Description]` in traditional Korean Minhwa style, thick ink wash strokes (Balmuk), heavy Hanji paper texture, ethereal and atmospheric, minimalistic composition, high contrast between ink and paper, `[Mood: Sunny/Stormy/Mystical]`, 8k resolution, cinematic lighting --ar 21:9 --v 6.0

### Examples

- **Daily (Sunny)**: "Morning sun rising over stylized mountains with ink bleed effects."
- **Love (Blooming)**: "Peony flowers in full bloom with delicate brush strokes and soft ink gradients."
- **Warning (Stormy)**: "Dark thunderclouds and lightning over a turbulent sea in monochrome ink style."

---

## 2. Mascot Characters (Mascots)

_Transparent background (WebP). Context-aware expressions._

### Template

> A `[Character: Shiba Inu/Cat/Scholar]` character in traditional Korean ink wash animation style, wearing a `[Costume: Hanbok/Gat]`, `[Expression: Happy/Serious/Sad]`, thick brush outlines, soft ink shading, white background for easy isolation, cute but premium aesthetic --v 6.0

### Mood Mapping

- **Cute**: Daily, Pet, Fun types.
- **Pretty**: Love, Compatibility, MBTI.
- **Serious/Scary**: Warning, Health, Crisis.
- **Vintage (Antique)**: Past Life, Traditional, Saju.

---

## 3. Brush Stroke Icons (Icons)

_Small functional assets. Vector-like ink strokes._

### Template

> Minimalist icon for `[Object: Red Sphere/Directional Compass/Tiger]`, hand-drawn Korean brush stroke style, sumi-e aesthetic, single stroke emphasis, rough edges, ink splatter details, high contrast monochrome or two-tone, flat design on white background --no shadows

---

## 4. Technical Specifications

| Asset Type | Format   | Recommended Size | Notes                            |
| :--------- | :------- | :--------------- | :------------------------------- |
| **Hero**   | WebP     | 1200x600 px      | Optimize for < 150KB             |
| **Mascot** | WebP     | 800x800 px       | Must have transparent background |
| **Icon**   | WebP/SVG | 256x256 px       | Sharp brush stroke edges         |

## Generation Workflow

1. Use **Midjourney v6** for Hero and Mascot illustrations.
2. Use **DALL-E 3** for specific functional icons if Midjourney is too artistic.
3. Batch convert to **WebP** using `cwebp` or ImageMagick.
4. Place in `assets/images/fortune/[subfolder]/`.
