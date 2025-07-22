# Fortune App Design System - Color Tokens

## Instructions for Creating in Figma

1. Open the Figma file: https://www.figma.com/design/yt2n13qKKng8fK9NTo7BfZ/Fortune_1?node-id=0-1&m=dev&t=MA7dgQq0y3NJeAwY-1
2. Create a new page called "Design System"
3. Create the following frames with the color styles below

## Core Colors

### Primary Colors
- **Primary**: #000000
- **Primary Light**: #333333
- **Primary Dark**: #1A1A1A

### Secondary Colors
- **Secondary**: #F56040
- **Secondary Light**: #FD1D1D
- **Secondary Dark**: #E1306C

### Neutral Colors
- **Background**: #FAFAFA
- **Surface**: #FFFFFF
- **Text Primary**: #262626
- **Text Secondary**: #8E8E8E
- **Divider**: #E9ECEF

### Semantic Colors
- **Success**: #28A745
- **Error**: #DC3545
- **Warning**: #FFC107

## Category Colors (Gradients)

These should be created as gradient fills in Figma:

### Love & Relationships
- **Love**: #EC4899 → #DB2777
- **Marriage**: #DB2777 → #BE185D
- **Compatibility**: #BE185D → #9333EA
- **Relationship**: #9333EA → #7C3AED

### Career & Education
- **Career**: #2563EB → #1D4ED8
- **Study/Exam**: #03A9F4 → #0288D1

### Money & Investment
- **Money**: #16A34A → #15803D
- **Real Estate**: #059669 → #047857
- **Stock**: #1E88E5 → #1565C0
- **Crypto**: #FF6F00 → #E65100
- **Lottery**: #FFB300 → #F57C00

### Health & Wellness
- **Health**: #10B981 → #059669
- **Sports**: #10B981 → #059669
- **Yoga**: #9C27B0 → #7B1FA2
- **Fitness**: #E91E63 → #C2185B

### Traditional & Spiritual
- **Saju (Traditional)**: #EF4444 → #EC4899
- **Saju Chart**: #5E35B1 → #4527A0
- **Tojeong**: #8B5CF6 → #7C3AED
- **Tarot**: #9333EA → #7C3AED
- **Dream**: #6366F1 → #4F46E5

### Lifestyle & Daily
- **Time-based**: #7C3AED → #3B82F6
- **Birthday**: #EC4899 → #8B5CF6
- **Zodiac (Western)**: #8B5CF6 → #7C3AED
- **Zodiac (Animal)**: #7C3AED → #6366F1
- **MBTI**: #6366F1 → #3B82F6
- **Blood Type**: #DC2626 → #EF4444
- **Biorhythm**: #6366F1 → #8B5CF6

### Pet & Family
- **Pet General**: #E11D48 → #BE123C
- **Dog**: #DC2626 → #B91C1C
- **Cat**: #9333EA → #7C3AED
- **Pet Compatibility**: #EC4899 → #DB2777
- **Children**: #3B82F6 → #2563EB
- **Parenting**: #10B981 → #059669
- **Pregnancy**: #F59E0B → #D97706
- **Family**: #6366F1 → #4F46E5

All gradients should be linear with 45° angle unless specified otherwise.

## Social Brand Colors

### Google
- **Background**: #FFFFFF
- **Border**: #DADCE0 (for the button border)
- **Text**: #3C4043

### Apple
- **Background**: #000000
- **Text**: #FFFFFF

### Kakao
- **Background**: #FEE500
- **Text**: #000000

### Naver
- **Background**: #03C75A
- **Text**: #FFFFFF

## How to Create Color Styles in Figma

1. **Create a Color Frame**:
   - Create a new frame called "Colors" (1920x1080)
   - Organize colors into sections

2. **For Solid Colors**:
   - Create rectangles (100x100px)
   - Apply the hex color as fill
   - Right-click → Create Style
   - Name it according to the token (e.g., "Primary/Default")

3. **For Gradients**:
   - Create rectangles (200x100px)
   - Apply linear gradient with the two colors
   - Set angle to 45°
   - Right-click → Create Style
   - Name it (e.g., "Category/Love")

4. **Organization Structure**:
   ```
   Colors/
   ├── Core/
   │   ├── Primary
   │   ├── Secondary
   │   └── Neutral
   ├── Semantic/
   │   ├── Success
   │   ├── Error
   │   └── Warning
   ├── Categories/
   │   ├── Love
   │   ├── Career
   │   ├── Money
   │   ├── Health
   │   ├── Traditional
   │   └── Personality
   └── Social/
       ├── Google
       ├── Apple
       ├── Kakao
       └── Naver
   ```

## Typography Frame Structure

Create a "Typography" frame with these text styles:
- Display Large (32px)
- Display Medium (28px)
- Display Small (24px)
- Headline Large (24px)
- Headline Medium (20px)
- Headline Small (18px)
- Title Large (22px)
- Title Medium (16px, Medium weight)
- Title Small (14px, Medium weight)
- Body Large (16px)
- Body Medium (14px)
- Body Small (12px)
- Label Large (14px, Medium weight)
- Label Medium (12px, Medium weight)
- Label Small (11px, Medium weight)

## Spacing & Radius Frame

Create a "Spacing & Radius" frame with:

### Spacing Values
- 4px
- 8px
- 12px
- 16px
- 20px
- 24px
- 32px
- 40px
- 48px
- 56px
- 64px

### Border Radius Values
- Small: 8px
- Medium: 12px
- Large: 16px
- XLarge: 24px
- Circle: 999px