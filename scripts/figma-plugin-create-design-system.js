// Figma Plugin Code - Fortune App Design System
// Copy this code and run it in Figma's console or as a plugin

// Load design tokens
const designTokens = {
  colors: {
    core: {
      primary: {
        default: "#000000",
        light: "#333333",
        dark: "#1A1A1A"
      },
      secondary: {
        default: "#F56040",
        light: "#FD1D1D",
        dark: "#E1306C"
      },
      neutral: {
        background: "#FAFAFA",
        surface: "#FFFFFF",
        textPrimary: "#262626",
        textSecondary: "#8E8E8E",
        divider: "#E9ECEF"
      },
      semantic: {
        success: "#28A745",
        error: "#DC3545",
        warning: "#FFC107"
      }
    },
    categories: {
      love: {
        love: { start: "#EC4899", end: "#DB2777" },
        marriage: { start: "#DB2777", end: "#BE185D" },
        compatibility: { start: "#BE185D", end: "#9333EA" },
        relationship: { start: "#9333EA", end: "#7C3AED" }
      },
      career: {
        career: { start: "#2563EB", end: "#1D4ED8" },
        study: { start: "#03A9F4", end: "#0288D1" }
      },
      money: {
        money: { start: "#16A34A", end: "#15803D" },
        realEstate: { start: "#059669", end: "#047857" },
        stock: { start: "#1E88E5", end: "#1565C0" },
        crypto: { start: "#FF6F00", end: "#E65100" },
        lottery: { start: "#FFB300", end: "#F57C00" }
      },
      health: {
        health: { start: "#10B981", end: "#059669" },
        sports: { start: "#10B981", end: "#059669" },
        yoga: { start: "#9C27B0", end: "#7B1FA2" },
        fitness: { start: "#E91E63", end: "#C2185B" }
      },
      traditional: {
        saju: { start: "#EF4444", end: "#EC4899" },
        sajuChart: { start: "#5E35B1", end: "#4527A0" },
        tojeong: { start: "#8B5CF6", end: "#7C3AED" },
        tarot: { start: "#9333EA", end: "#7C3AED" },
        dream: { start: "#6366F1", end: "#4F46E5" }
      },
      lifestyle: {
        timeBased: { start: "#7C3AED", end: "#3B82F6" },
        birthday: { start: "#EC4899", end: "#8B5CF6" },
        zodiacWestern: { start: "#8B5CF6", end: "#7C3AED" },
        zodiacAnimal: { start: "#7C3AED", end: "#6366F1" },
        mbti: { start: "#6366F1", end: "#3B82F6" },
        bloodType: { start: "#DC2626", end: "#EF4444" },
        biorhythm: { start: "#6366F1", end: "#8B5CF6" }
      },
      petFamily: {
        petGeneral: { start: "#E11D48", end: "#BE123C" },
        dog: { start: "#DC2626", end: "#B91C1C" },
        cat: { start: "#9333EA", end: "#7C3AED" },
        petCompatibility: { start: "#EC4899", end: "#DB2777" },
        children: { start: "#3B82F6", end: "#2563EB" },
        parenting: { start: "#10B981", end: "#059669" },
        pregnancy: { start: "#F59E0B", end: "#D97706" },
        family: { start: "#6366F1", end: "#4F46E5" }
      }
    },
    social: {
      google: { background: "#FFFFFF", border: "#DADCE0", text: "#3C4043" },
      apple: { background: "#000000", text: "#FFFFFF" },
      kakao: { background: "#FEE500", text: "#000000" },
      naver: { background: "#03C75A", text: "#FFFFFF" }
    }
  }
};

// Helper function to convert hex to RGB
function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16) / 255,
    g: parseInt(result[2], 16) / 255,
    b: parseInt(result[3], 16) / 255
  } : null;
}

// Create Design System Page
async function createDesignSystemPage() {
  // Find or create Design System page
  let designSystemPage = figma.root.children.find(page => page.name === "Design System");
  if (!designSystemPage) {
    designSystemPage = figma.createPage();
    designSystemPage.name = "Design System";
  }
  
  figma.currentPage = designSystemPage;
  
  // Create main frame
  const mainFrame = figma.createFrame();
  mainFrame.name = "Design System";
  mainFrame.x = 0;
  mainFrame.y = 0;
  mainFrame.resize(1920, 3000);
  mainFrame.fills = [{
    type: 'SOLID',
    color: { r: 0.98, g: 0.98, b: 0.98 }
  }];
  
  // Create sections
  await createColorSection(mainFrame);
  await createTypographySection(mainFrame);
  await createSpacingSection(mainFrame);
  
  // Zoom to fit
  figma.viewport.scrollAndZoomIntoView([mainFrame]);
}

// Create Color Section
async function createColorSection(parent) {
  const colorFrame = figma.createFrame();
  colorFrame.name = "Colors";
  colorFrame.x = 50;
  colorFrame.y = 50;
  colorFrame.resize(1820, 1000);
  colorFrame.layoutMode = 'VERTICAL';
  colorFrame.itemSpacing = 40;
  colorFrame.paddingLeft = 40;
  colorFrame.paddingRight = 40;
  colorFrame.paddingTop = 40;
  colorFrame.paddingBottom = 40;
  colorFrame.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  parent.appendChild(colorFrame);
  
  // Title
  const title = figma.createText();
  title.fontName = { family: "Inter", style: "Bold" };
  title.characters = "Color System";
  title.fontSize = 32;
  title.fills = [{
    type: 'SOLID',
    color: { r: 0.15, g: 0.15, b: 0.15 }
  }];
  colorFrame.appendChild(title);
  
  // Core Colors
  const coreColorsFrame = createColorGroup("Core Colors", [
    { name: "Primary/Default", color: designTokens.colors.core.primary.default },
    { name: "Primary/Light", color: designTokens.colors.core.primary.light },
    { name: "Primary/Dark", color: designTokens.colors.core.primary.dark },
    { name: "Secondary/Default", color: designTokens.colors.core.secondary.default },
    { name: "Secondary/Light", color: designTokens.colors.core.secondary.light },
    { name: "Secondary/Dark", color: designTokens.colors.core.secondary.dark }
  ]);
  colorFrame.appendChild(coreColorsFrame);
  
  // Neutral Colors
  const neutralColorsFrame = createColorGroup("Neutral Colors", [
    { name: "Neutral/Background", color: designTokens.colors.core.neutral.background },
    { name: "Neutral/Surface", color: designTokens.colors.core.neutral.surface },
    { name: "Neutral/Text Primary", color: designTokens.colors.core.neutral.textPrimary },
    { name: "Neutral/Text Secondary", color: designTokens.colors.core.neutral.textSecondary },
    { name: "Neutral/Divider", color: designTokens.colors.core.neutral.divider }
  ]);
  colorFrame.appendChild(neutralColorsFrame);
  
  // Semantic Colors
  const semanticColorsFrame = createColorGroup("Semantic Colors", [
    { name: "Semantic/Success", color: designTokens.colors.core.semantic.success },
    { name: "Semantic/Error", color: designTokens.colors.core.semantic.error },
    { name: "Semantic/Warning", color: designTokens.colors.core.semantic.warning }
  ]);
  colorFrame.appendChild(semanticColorsFrame);
  
  // Category Gradients
  const gradientFrame = figma.createFrame();
  gradientFrame.name = "Category Gradients";
  gradientFrame.layoutMode = 'VERTICAL';
  gradientFrame.itemSpacing = 20;
  gradientFrame.fills = [];
  colorFrame.appendChild(gradientFrame);
  
  const gradientTitle = figma.createText();
  gradientTitle.fontName = { family: "Inter", style: "Medium" };
  gradientTitle.characters = "Category Gradients";
  gradientTitle.fontSize = 20;
  gradientFrame.appendChild(gradientTitle);
  
  const gradientGrid = figma.createFrame();
  gradientGrid.layoutMode = 'HORIZONTAL';
  gradientGrid.layoutWrap = 'WRAP';
  gradientGrid.itemSpacing = 20;
  gradientGrid.counterAxisSpacing = 20;
  gradientGrid.fills = [];
  gradientFrame.appendChild(gradientGrid);
  
  // Create gradient swatches
  Object.entries(designTokens.colors.categories).forEach(([category, items]) => {
    Object.entries(items).forEach(([name, gradient]) => {
      const swatch = createGradientSwatch(
        `Category/${category}/${name}`,
        gradient.start,
        gradient.end
      );
      gradientGrid.appendChild(swatch);
    });
  });
}

// Helper function to create color group
function createColorGroup(title, colors) {
  const frame = figma.createFrame();
  frame.name = title;
  frame.layoutMode = 'VERTICAL';
  frame.itemSpacing = 16;
  frame.fills = [];
  
  const titleText = figma.createText();
  titleText.fontName = { family: "Inter", style: "Medium" };
  titleText.characters = title;
  titleText.fontSize = 20;
  frame.appendChild(titleText);
  
  const colorsRow = figma.createFrame();
  colorsRow.layoutMode = 'HORIZONTAL';
  colorsRow.itemSpacing = 16;
  colorsRow.fills = [];
  frame.appendChild(colorsRow);
  
  colors.forEach(({ name, color }) => {
    const swatch = createColorSwatch(name, color);
    colorsRow.appendChild(swatch);
  });
  
  return frame;
}

// Helper function to create color swatch
function createColorSwatch(name, hexColor) {
  const frame = figma.createFrame();
  frame.name = name;
  frame.resize(100, 120);
  frame.layoutMode = 'VERTICAL';
  frame.itemSpacing = 8;
  frame.fills = [];
  
  const colorRect = figma.createRectangle();
  colorRect.resize(100, 100);
  colorRect.cornerRadius = 8;
  const rgb = hexToRgb(hexColor);
  colorRect.fills = [{
    type: 'SOLID',
    color: rgb
  }];
  
  // Create color style
  const style = figma.createPaintStyle();
  style.name = name;
  style.paints = [{
    type: 'SOLID',
    color: rgb
  }];
  colorRect.fillStyleId = style.id;
  
  frame.appendChild(colorRect);
  
  const label = figma.createText();
  label.fontName = { family: "Inter", style: "Regular" };
  label.characters = hexColor;
  label.fontSize = 12;
  label.textAlignHorizontal = 'CENTER';
  frame.appendChild(label);
  
  return frame;
}

// Helper function to create gradient swatch
function createGradientSwatch(name, startColor, endColor) {
  const frame = figma.createFrame();
  frame.name = name;
  frame.resize(160, 120);
  frame.layoutMode = 'VERTICAL';
  frame.itemSpacing = 8;
  frame.fills = [];
  
  const gradientRect = figma.createRectangle();
  gradientRect.resize(160, 100);
  gradientRect.cornerRadius = 8;
  
  const startRgb = hexToRgb(startColor);
  const endRgb = hexToRgb(endColor);
  
  gradientRect.fills = [{
    type: 'GRADIENT_LINEAR',
    gradientTransform: [
      [0.7071, 0.7071, 0],
      [-0.7071, 0.7071, 0.5]
    ],
    gradientStops: [
      { position: 0, color: { ...startRgb, a: 1 } },
      { position: 1, color: { ...endRgb, a: 1 } }
    ]
  }];
  
  // Create gradient style
  const style = figma.createPaintStyle();
  style.name = name;
  style.paints = gradientRect.fills;
  gradientRect.fillStyleId = style.id;
  
  frame.appendChild(gradientRect);
  
  const label = figma.createText();
  label.fontName = { family: "Inter", style: "Regular" };
  label.characters = name.split('/').pop();
  label.fontSize = 12;
  label.textAlignHorizontal = 'CENTER';
  frame.appendChild(label);
  
  return frame;
}

// Create Typography Section
async function createTypographySection(parent) {
  const typographyFrame = figma.createFrame();
  typographyFrame.name = "Typography";
  typographyFrame.x = 50;
  typographyFrame.y = 1100;
  typographyFrame.resize(1820, 800);
  typographyFrame.layoutMode = 'VERTICAL';
  typographyFrame.itemSpacing = 32;
  typographyFrame.paddingLeft = 40;
  typographyFrame.paddingRight = 40;
  typographyFrame.paddingTop = 40;
  typographyFrame.paddingBottom = 40;
  typographyFrame.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  parent.appendChild(typographyFrame);
  
  // Title
  const title = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Bold" });
  title.fontName = { family: "Inter", style: "Bold" };
  title.characters = "Typography System";
  title.fontSize = 32;
  typographyFrame.appendChild(title);
  
  // Typography styles
  const styles = [
    { category: "Display", sizes: ["Large", "Medium", "Small"] },
    { category: "Headline", sizes: ["Large", "Medium", "Small"] },
    { category: "Title", sizes: ["Large", "Medium", "Small"] },
    { category: "Body", sizes: ["Large", "Medium", "Small"] },
    { category: "Label", sizes: ["Large", "Medium", "Small"] }
  ];
  
  for (const styleGroup of styles) {
    const groupFrame = figma.createFrame();
    groupFrame.name = styleGroup.category;
    groupFrame.layoutMode = 'VERTICAL';
    groupFrame.itemSpacing = 16;
    groupFrame.fills = [];
    typographyFrame.appendChild(groupFrame);
    
    for (const size of styleGroup.sizes) {
      const textSample = figma.createText();
      await figma.loadFontAsync({ family: "Inter", style: "Regular" });
      textSample.fontName = { family: "Inter", style: "Regular" };
      textSample.characters = `${styleGroup.category} ${size} - NotoSansKR을 사용하세요`;
      
      // Create text style
      const textStyle = figma.createTextStyle();
      textStyle.name = `${styleGroup.category}/${size}`;
      textStyle.fontName = { family: "Inter", style: "Regular" };
      
      // Set size based on design tokens
      if (styleGroup.category === "Display") {
        textSample.fontSize = size === "Large" ? 32 : size === "Medium" ? 28 : 24;
      } else if (styleGroup.category === "Headline") {
        textSample.fontSize = size === "Large" ? 24 : size === "Medium" ? 20 : 18;
      } else if (styleGroup.category === "Title") {
        textSample.fontSize = size === "Large" ? 22 : size === "Medium" ? 16 : 14;
      } else if (styleGroup.category === "Body") {
        textSample.fontSize = size === "Large" ? 16 : size === "Medium" ? 14 : 12;
      } else if (styleGroup.category === "Label") {
        textSample.fontSize = size === "Large" ? 14 : size === "Medium" ? 12 : 11;
      }
      
      textStyle.fontSize = textSample.fontSize;
      textSample.textStyleId = textStyle.id;
      
      groupFrame.appendChild(textSample);
    }
  }
}

// Create Spacing Section
async function createSpacingSection(parent) {
  const spacingFrame = figma.createFrame();
  spacingFrame.name = "Spacing & Radius";
  spacingFrame.x = 50;
  spacingFrame.y = 1950;
  spacingFrame.resize(1820, 400);
  spacingFrame.layoutMode = 'HORIZONTAL';
  spacingFrame.itemSpacing = 80;
  spacingFrame.paddingLeft = 40;
  spacingFrame.paddingRight = 40;
  spacingFrame.paddingTop = 40;
  spacingFrame.paddingBottom = 40;
  spacingFrame.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  parent.appendChild(spacingFrame);
  
  // Spacing values
  const spacingGroup = figma.createFrame();
  spacingGroup.name = "Spacing";
  spacingGroup.layoutMode = 'VERTICAL';
  spacingGroup.itemSpacing = 16;
  spacingGroup.fills = [];
  spacingFrame.appendChild(spacingGroup);
  
  const spacingTitle = figma.createText();
  spacingTitle.fontName = { family: "Inter", style: "Medium" };
  spacingTitle.characters = "Spacing Values";
  spacingTitle.fontSize = 20;
  spacingGroup.appendChild(spacingTitle);
  
  const spacingValues = [4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64];
  const spacingRow = figma.createFrame();
  spacingRow.layoutMode = 'HORIZONTAL';
  spacingRow.itemSpacing = 16;
  spacingRow.fills = [];
  spacingGroup.appendChild(spacingRow);
  
  spacingValues.forEach(value => {
    const spacingBox = figma.createFrame();
    spacingBox.name = `${value}px`;
    spacingBox.resize(value, value);
    spacingBox.fills = [{
      type: 'SOLID',
      color: { r: 0.95, g: 0.95, b: 0.95 }
    }];
    spacingRow.appendChild(spacingBox);
  });
  
  // Border radius values
  const radiusGroup = figma.createFrame();
  radiusGroup.name = "Border Radius";
  radiusGroup.layoutMode = 'VERTICAL';
  radiusGroup.itemSpacing = 16;
  radiusGroup.fills = [];
  spacingFrame.appendChild(radiusGroup);
  
  const radiusTitle = figma.createText();
  radiusTitle.fontName = { family: "Inter", style: "Medium" };
  radiusTitle.characters = "Border Radius";
  radiusTitle.fontSize = 20;
  radiusGroup.appendChild(radiusTitle);
  
  const radiusRow = figma.createFrame();
  radiusRow.layoutMode = 'HORIZONTAL';
  radiusRow.itemSpacing = 16;
  radiusRow.fills = [];
  radiusGroup.appendChild(radiusRow);
  
  const radiusValues = [
    { name: "Small", value: 8 },
    { name: "Medium", value: 12 },
    { name: "Large", value: 16 },
    { name: "XLarge", value: 24 },
    { name: "Circle", value: 999 }
  ];
  
  radiusValues.forEach(({ name, value }) => {
    const radiusBox = figma.createRectangle();
    radiusBox.name = name;
    radiusBox.resize(80, 80);
    radiusBox.cornerRadius = value === 999 ? 40 : value;
    radiusBox.fills = [{
      type: 'SOLID',
      color: { r: 0.9, g: 0.9, b: 0.9 }
    }];
    radiusRow.appendChild(radiusBox);
  });
}

// Run the script
createDesignSystemPage();

figma.closePlugin("✅ Design System created successfully!");