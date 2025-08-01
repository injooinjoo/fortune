# 📗 Fortune App UI/UX Master Policy Document

> **Version**: 1.0.0  
> **Last Updated**: January 2025  
> **Status**: Living Document (Continuously Updated)  
> **Owner**: Claude Code Master Agent

## 📋 Table of Contents

1. [Document Purpose & Methodology](#document-purpose--methodology)
2. [Core Design Principles](#core-design-principles)
3. [Micro-Interactions & Haptic Feedback](#micro-interactions--haptic-feedback)
4. [Loading & Error States](#loading--error-states)
5. [Form & Input Interactions](#form--input-interactions)
6. [Data Visualization](#data-visualization)
7. [Social & Sharing Features](#social--sharing-features)
8. [Onboarding & Tutorial Flows](#onboarding--tutorial-flows)
9. [Premium & Monetization UI](#premium--monetization-ui)
10. [Notification & Communication](#notification--communication)
11. [Accessibility Standards](#accessibility-standards)
12. [Performance Guidelines](#performance-guidelines)
13. [Multi-Device Support](#multi-device-support)
14. [Localization & Internationalization](#localization--internationalization)
15. [Version History](#version-history)

---

## 🎯 Document Purpose & Methodology

### Purpose
This master document serves as the single source of truth for all UI/UX policies in the Fortune Flutter app. It documents both existing patterns and newly discovered design elements, ensuring consistency and excellence in user experience.

### Methodology
- **Evidence-Based**: All policies backed by user research, analytics, or industry best practices
- **Iterative**: Continuously refined based on user feedback and testing
- **Measurable**: Each policy includes success metrics
- **Actionable**: Clear implementation guidelines for developers

### Discovery Process
1. **Systematic Exploration**: Regular app audits to identify undocumented patterns
2. **User Observation**: Analytics and user testing to validate decisions
3. **Cross-Reference**: Comparison with industry leaders (Toss, Instagram)
4. **Sub-Agent Validation**: Specialized agents test and refine policies

---

## 🎨 Core Design Principles

### 1. Clarity First
- Every UI element must have a clear, singular purpose
- Remove any element that doesn't directly serve user needs
- Information hierarchy must be immediately apparent

### 2. Delightful Minimalism
- Inspired by Toss's clean aesthetic
- White space is a design element, not wasted space
- Every interaction should feel smooth and purposeful

### 3. Predictable Consistency
- Same action = same result across the app
- Visual patterns must be reusable and scalable
- Deviations require strong justification

### 4. Inclusive by Default
- WCAG 2.1 AA compliance minimum
- Cultural sensitivity in all design decisions
- Performance considerations for all device types

---

## 🎭 Micro-Interactions & Haptic Feedback

### Button Interactions

#### Press Animation
```yaml
trigger: onTapDown
animation:
  scale: 0.95
  duration: 100ms
  curve: easeOut
haptic: 
  type: light_impact
  timing: immediate
```

**Rationale**: The 0.95 scale provides subtle feedback without being distracting. Light haptic feedback confirms the action for users with haptics enabled.

#### Release Animation
```yaml
trigger: onTapUp
animation:
  scale: 1.0
  duration: 200ms
  curve: easeOutBack (slight overshoot)
haptic: none
```

### List Item Interactions

#### Swipe Actions
```yaml
swipe_threshold: 80px
resistance_factor: 0.5 after threshold
haptic:
  - light_impact at 25% swipe
  - medium_impact at threshold
animation:
  background_reveal: progressive
  icon_scale: 0.8 → 1.0 at threshold
```

### Page Transitions

#### Standard Navigation
```yaml
type: slide_fade
duration: 300ms
curve: easeOutCubic
direction: 
  forward: slide_left + fade_in
  back: slide_right + fade_in
overlap: 20% (pages overlap during transition)
```

#### Modal Presentation
```yaml
type: slide_up
duration: 350ms
curve: easeOutCubic
backdrop:
  opacity: 0.5
  blur: 10px (if performance allows)
  duration: 250ms
```

### Haptic Feedback Guidelines

#### Success States
- **Type**: success_heavy
- **Use Cases**: Payment confirmation, fortune saved, profile completed
- **Timing**: After visual confirmation appears

#### Warning States
- **Type**: warning_medium
- **Use Cases**: Destructive action warnings, limit reached
- **Timing**: Before action execution

#### Error States
- **Type**: error_heavy
- **Use Cases**: Failed operations, invalid input
- **Timing**: Immediate on error detection

### Pull-to-Refresh

```yaml
activation_distance: 100px
resistance_curve: exponential (harder to pull further)
stages:
  - 0-50px: "당겨서 새로고침" + arrow rotating 0-90°
  - 50-100px: "놓으면 새로고침" + arrow rotating 90-180°
  - 100px+: Lock at max + bounce animation
haptic:
  - light at 50px (ready state)
  - medium at 100px (will refresh)
refresh_animation:
  type: fortune_symbol_spin
  duration: 1000ms minimum
```

---

## 🔄 Loading & Error States

### Skeleton Loading

#### Content Placeholders
```yaml
base_color: #F0F0F0 (light) / #1C1C1C (dark)
highlight_color: #F8F8F8 (light) / #2A2A2A (dark)
animation:
  type: shimmer
  duration: 1200ms
  direction: left_to_right
  curve: easeInOut
shapes:
  text: rounded_rectangle (4px radius)
  image: rounded_rectangle (8px radius)
  avatar: circle
```

#### Loading Hierarchy
1. **Navigation skeleton** appears first (instant)
2. **Content structure** loads next (100ms delay)
3. **Actual content** replaces skeleton (fade transition 200ms)

### Progress Indicators

#### Determinate Progress
```yaml
style: linear_bar
height: 4px
corner_radius: 2px
animation:
  progress: smooth (no steps)
  complete: scale_up + fade_out
colors:
  track: primary_10%
  fill: primary_gradient
```

#### Indeterminate Progress
```yaml
fortune_loading:
  type: custom_fortune_symbols
  symbols: [☯️, 🔮, ⭐, 🌙]
  animation: rotate + fade
  duration: 2000ms per cycle
fallback:
  type: circular_progress
  size: 24px
  stroke_width: 2px
```

### Error States

#### Network Errors
```yaml
illustration: custom_offline_fortune_teller.svg
title: "인터넷 연결을 확인해주세요"
subtitle: "운세를 불러오려면 네트워크가 필요해요"
action:
  text: "다시 시도"
  style: primary_button
animation:
  illustration: gentle_float (subtle up/down)
  entry: fade_in + slide_up (300ms)
```

#### Empty States
```yaml
illustration: context_specific (no fortunes, no history, etc.)
title: descriptive + encouraging
subtitle: action_oriented
animation:
  illustration: gentle_pulse
  text: fade_in with 100ms stagger
cta:
  style: primary_button or text_button
  position: below_text or floating_bottom
```

#### Inline Errors
```yaml
appearance:
  timing: immediate on validation
  animation: shake (300ms) + fade_in
style:
  color: error_red
  icon: error_circle (16px)
  text_size: caption_medium
  position: below_input
persistence:
  duration: until_user_corrects
  fade_out: 200ms after correction
```

---

## 📝 Form & Input Interactions

### Text Input Fields

#### Default State
```yaml
height: 48px
border:
  width: 1px
  color: divider
  radius: 8px
padding: horizontal 16px
font: body_medium (15px)
placeholder:
  color: text_tertiary
  opacity: 0.7
```

#### Focus State
```yaml
border:
  color: primary
  width: 2px (visual compensation)
  animation: color_transition (200ms)
label:
  animation: float_up + scale(0.85)
  position: above_field (-8px)
  background: surface_color (to cover border)
```

#### Error State
```yaml
border:
  color: error_red
  width: 2px
shake_animation:
  distance: 4px
  duration: 300ms
  count: 2
helper_text:
  color: error_red
  icon: error_16px
  animation: fade_in (200ms)
```

### Bottom Sheet Pickers

#### Date Picker
```yaml
height: 
  collapsed: 320px
  expanded: 480px (with calendar view)
header:
  style: grab_handle + title + done_button
  height: 56px
content:
  default_view: scroll_wheels
  alternative: calendar_grid
animation:
  entry: slide_up + fade (350ms)
  exit: slide_down + fade (300ms)
selection_feedback:
  haptic: light_impact
  visual: scale(1.05) + highlight
```

#### Custom MBTI Picker
```yaml
layout: 4x4 grid
item_size: 72x72px
spacing: 8px
selection:
  animation: scale(0.95→1.1→1.0)
  color: primary_background
  border: 2px primary
  haptic: medium_impact
multi_select: false
auto_proceed: true (on selection)
```

### Phone Number Input
```yaml
format: "010-0000-0000"
auto_formatting: true
keyboard: number_pad
validation:
  real_time: true
  pattern: korean_mobile
country_code:
  display: "+82"
  position: left_fixed
  style: text_secondary
```

### Form Validation

#### Validation Timing
```yaml
on_blur: 
  - required fields
  - format validation
on_submit:
  - all validations
  - async validations (uniqueness)
real_time:
  - password strength
  - character limits
```

#### Validation Feedback
```yaml
success:
  icon: check_circle_green
  message: optional
  duration: 2000ms then fade
error:
  icon: error_circle_red
  message: required
  persistence: until_corrected
warning:
  icon: info_circle_amber
  message: required
  persistence: 5000ms or until_addressed
```

---

## 📊 Data Visualization

### Fortune Charts

#### Hexagon Chart (운세 육각형)
```yaml
size: 
  mobile: 280x280px
  tablet: 360x360px
dimensions: 6 axes
style:
  stroke_width: 2px
  fill_opacity: 0.3
  grid_lines: 3 (inner rings)
animation:
  type: draw_from_center
  duration: 800ms
  curve: easeOutCubic
  stagger: 100ms per axis
interaction:
  tap: show_tooltip
  drag: rotate_slightly (max 15°)
colors:
  fill: primary_gradient
  stroke: primary
  grid: divider_light
```

#### Five Elements Visualization
```yaml
layout: circular_arrangement
element_size: 60px
center_spacing: 120px radius
connections:
  generating: solid_arrow
  overcoming: dashed_arrow
animation:
  entry: scale_up + fade_in (staggered)
  interaction: pulse on tap
  flow: animated_particles along connections
colors:
  wood: #4CAF50
  fire: #F44336
  earth: #FFC107
  metal: #9E9E9E
  water: #2196F3
```

### Statistics Display

#### Percentage Indicators
```yaml
style: circular_progress
size: 
  small: 48px
  medium: 72px
  large: 96px
stroke_width: size * 0.08
animation:
  duration: 1200ms
  curve: easeOutCubic
  count_up: true (0 → value)
center_text:
  value: "85%"
  label: optional
colors:
  track: primary_10%
  progress: primary_gradient
```

#### Trend Graphs
```yaml
type: smooth_line
height: 120px
points: max 7 (week) or 30 (month)
style:
  line_width: 2px
  point_radius: 4px
  fill_gradient: true
animation:
  draw: left_to_right
  duration: 1000ms
  point_appear: staggered
interaction:
  tap_point: show_value_tooltip
  drag: scrub_through_time
```

---

## 🔗 Social & Sharing Features

### Share Card Design

#### Fortune Share Card
```yaml
size: 
  aspect_ratio: 9:16 (stories)
  alternative: 1:1 (feed)
padding: 24px
background:
  type: gradient_mesh
  colors: based_on_fortune_type
content:
  logo: top_left (small)
  fortune_text: center (hero)
  user_info: bottom (subtle)
  qr_code: bottom_right (optional)
watermark:
  text: "@fortune_app"
  position: bottom_center
  opacity: 0.6
```

#### Share Actions
```yaml
trigger: 
  button: "공유하기"
  gesture: long_press on card
options:
  - save_image
  - share_to_instagram_story
  - share_to_kakao
  - copy_link
animation:
  sheet: slide_up
  options: fade_in_staggered
```

### Screenshot Detection

#### Detection Response
```yaml
trigger: screenshot_taken
delay: 500ms
notification:
  type: toast
  position: bottom
  message: "운세를 공유하시겠어요?"
  action: "공유하기"
  duration: 5000ms
animation:
  entry: slide_up + fade_in
  exit: slide_down + fade_out
```

---

## 🎓 Onboarding & Tutorial Flows

### Step Indicators

#### Progress Bar Style
```yaml
type: segmented
height: 4px
spacing: 4px
animation:
  fill: expand_width
  duration: 300ms
  timing: on_step_complete
colors:
  completed: primary
  current: primary_50%
  upcoming: divider
```

#### Dot Indicators
```yaml
size:
  inactive: 8px
  active: 24x8px (pill shape)
spacing: 8px
animation:
  transition: morph + slide
  duration: 300ms
colors:
  active: primary
  inactive: divider
```

### Onboarding Animations

#### Screen Transitions
```yaml
type: slide_with_parallax
duration: 400ms
curve: easeInOutCubic
content_offset: 50px (creates depth)
direction:
  forward: left
  backward: right
```

#### Skip/Complete Actions
```yaml
skip:
  position: top_right
  style: text_button
  availability: after_2_seconds
complete:
  style: primary_button
  animation: scale_in when available
  haptic: success on tap
```

---

## 💎 Premium & Monetization UI

### Subscription Screens

#### Premium Features Display
```yaml
layout: vertical_cards
card_style:
  icon: 48px (left)
  title: headline_small
  description: body_small
  badge: "PRO" label
animation:
  entry: fade_in + slide_up (staggered)
  hover: subtle_elevation_increase
highlight:
  new_features: shimmer_border
  most_popular: primary_background
```

#### Pricing Display
```yaml
layout: horizontal_scroll or vertical_stack
card_size: 
  width: screen_width - 48px
  height: auto
selection:
  border: 2px primary
  scale: 1.02
  shadow: elevated
discount_badge:
  position: top_right (-8px offset)
  style: primary_background
  text: "50% 할인"
```

### Payment Confirmations

#### Success State
```yaml
animation:
  checkmark: draw_circle → draw_check
  duration: 800ms
  confetti: optional
haptic: success_heavy
content:
  icon: animated_checkmark
  title: "결제 완료!"
  subtitle: "프리미엄 기능을 이용하실 수 있어요"
dismiss:
  auto: after 3000ms
  manual: "확인" button
```

---

## 🔔 Notification & Communication

### Toast Messages

#### Standard Toast
```yaml
position: bottom + 80px (above navigation)
width: screen_width - 32px
max_width: 400px
padding: 16px
border_radius: 8px
animation:
  entry: slide_up + fade_in (200ms)
  exit: fade_out (200ms)
  queue: stack with 8px spacing
duration:
  info: 3000ms
  success: 2000ms
  error: 4000ms
  action: until_dismissed
```

#### Toast Types
```yaml
info:
  background: surface_elevated
  icon: info_circle
  text_color: text_primary
success:
  background: success_light
  icon: check_circle
  text_color: success_dark
error:
  background: error_light
  icon: error_circle
  text_color: error_dark
```

### In-App Notifications

#### Banner Notifications
```yaml
position: top (below app_bar)
height: auto (min 56px)
animation:
  entry: slide_down + fade_in
  exit: slide_up + fade_out
interaction:
  swipe_up: dismiss
  tap: navigate_to_content
persistence:
  auto_dismiss: 5000ms
  important: until_interaction
```

---

## ♿ Accessibility Standards

### Touch Targets
```yaml
minimum_size: 44x44px
recommended_size: 48x48px
spacing: 8px minimum between targets
visual_feedback:
  focus: 2px primary border
  hover: subtle_background_tint
```

### Screen Reader Support
```yaml
semantics:
  images: meaningful alt_text
  decorative: hide_from_reader
  buttons: action_description
  fortune_cards: full_content_readable
navigation:
  logical_order: true
  skip_links: available
  landmarks: properly_marked
```

### Color Contrast
```yaml
text_contrast:
  normal: 4.5:1 minimum
  large: 3:1 minimum (18px+)
interactive_elements: 3:1 minimum
focus_indicators: 3:1 against_all_backgrounds
```

---

## 🚀 Performance Guidelines

### Animation Performance
```yaml
frame_rate: 60fps target
frame_budget: 16.67ms
optimization:
  use_hardware_acceleration: true
  avoid_opacity_on_large_areas: true
  prefer_transform_over_position: true
complexity_limits:
  simultaneous_animations: max 3
  particle_effects: max 50 particles
  blur_effects: avoid_on_low_end_devices
```

### Image Loading
```yaml
lazy_loading:
  threshold: 200px before_viewport
  placeholder: blurred_thumbnail
  animation: fade_in (200ms)
optimization:
  format: webp preferred, jpg fallback
  sizes: responsive (1x, 2x, 3x)
  caching: aggressive
progressive_loading:
  1. placeholder (instant)
  2. low_quality (100ms)
  3. full_quality (when ready)
```

---

## 📱 Multi-Device Support

### Responsive Breakpoints
```yaml
phone: 0-599px
tablet: 600-1023px
desktop: 1024px+
foldable:
  folded: treat_as_phone
  unfolded: treat_as_tablet
```

### Layout Adaptations
```yaml
navigation:
  phone: bottom_navigation
  tablet: rail_navigation
  desktop: sidebar_navigation
content_width:
  phone: full_width - 32px
  tablet: max 720px
  desktop: max 1200px
grid_columns:
  phone: 2
  tablet: 3-4
  desktop: 4-6
```

---

## 🌍 Localization & Internationalization

### Text Expansion
```yaml
buffer_space: 30% for translations
truncation: 
  prefer: ellipsis
  avoid: mid_word
  tooltip: show_full_on_hover
line_height: 1.4x minimum for readability
```

### RTL Support
```yaml
layout: mirror_horizontal
icons: direction_neutral or flip
animations: reverse_direction
padding/margin: swap_left_right
```

### Cultural Considerations
```yaml
colors:
  avoid: cultural_taboos
  prefer: neutral_palettes
imagery:
  review: cultural_appropriateness
  provide: region_specific_alternatives
date_time:
  format: locale_specific
  calendar: support_lunar_where_relevant
```

---

## 📜 Version History

### v1.0.0 (January 2025)
- Initial master policy document created
- Documented existing patterns from app analysis
- Established policy structure and methodology
- Created foundation for continuous expansion

### Upcoming (v1.1.0)
- Advanced gesture recognitions
- Voice interaction patterns
- AR visualization guidelines
- AI-powered personalization rules

---

## 🔄 Policy Validation Process

Each policy undergoes:
1. **Research**: User behavior analysis and industry benchmarks
2. **Prototyping**: Testing in isolated environments
3. **User Testing**: Validation with target audience
4. **Implementation**: Gradual rollout with monitoring
5. **Refinement**: Continuous improvement based on metrics

---

**Note**: This is a living document. New policies are added continuously as patterns are discovered and validated. Each update includes rationale, implementation guidelines, and success metrics.