// Figma Plugin Code - Fortune App Components
// Run this after creating the Design System

// Component creation functions
async function createComponentsPage() {
  // Find or create Components page
  let componentsPage = figma.root.children.find(page => page.name === "Components");
  if (!componentsPage) {
    componentsPage = figma.createPage();
    componentsPage.name = "Components";
  }
  
  figma.currentPage = componentsPage;
  
  // Create main frame
  const mainFrame = figma.createFrame();
  mainFrame.name = "Component Library";
  mainFrame.x = 0;
  mainFrame.y = 0;
  mainFrame.resize(1920, 2000);
  mainFrame.fills = [{
    type: 'SOLID',
    color: { r: 0.98, g: 0.98, b: 0.98 }
  }];
  
  // Create component sections
  await createButtonComponents(mainFrame);
  await createInputComponents(mainFrame);
  await createFortuneCardComponents(mainFrame);
  await createSocialLoginComponents(mainFrame);
  
  figma.viewport.scrollAndZoomIntoView([mainFrame]);
}

// Create Button Components
async function createButtonComponents(parent) {
  const buttonSection = figma.createFrame();
  buttonSection.name = "Buttons";
  buttonSection.x = 50;
  buttonSection.y = 50;
  buttonSection.resize(800, 400);
  buttonSection.layoutMode = 'VERTICAL';
  buttonSection.itemSpacing = 24;
  buttonSection.paddingLeft = 32;
  buttonSection.paddingRight = 32;
  buttonSection.paddingTop = 32;
  buttonSection.paddingBottom = 32;
  buttonSection.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  parent.appendChild(buttonSection);
  
  // Section title
  const title = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Bold" });
  title.fontName = { family: "Inter", style: "Bold" };
  title.characters = "Button Components";
  title.fontSize = 24;
  buttonSection.appendChild(title);
  
  // Primary Button Component
  const primaryButtonSet = figma.createFrame();
  primaryButtonSet.name = "Primary Button States";
  primaryButtonSet.layoutMode = 'HORIZONTAL';
  primaryButtonSet.itemSpacing = 16;
  primaryButtonSet.fills = [];
  buttonSection.appendChild(primaryButtonSet);
  
  const buttonStates = ["Default", "Hover", "Pressed", "Disabled"];
  const primaryColor = { r: 0, g: 0, b: 0 }; // #000000
  
  for (const state of buttonStates) {
    const button = figma.createComponent();
    button.name = `Button/Primary/${state}`;
    button.resize(160, 48);
    button.cornerRadius = 12;
    button.layoutMode = 'HORIZONTAL';
    button.primaryAxisAlignItems = 'CENTER';
    button.counterAxisAlignItems = 'CENTER';
    
    // Set fills based on state
    if (state === "Default") {
      button.fills = [{ type: 'SOLID', color: primaryColor }];
    } else if (state === "Hover") {
      button.fills = [{ type: 'SOLID', color: { r: 0.2, g: 0.2, b: 0.2 } }];
    } else if (state === "Pressed") {
      button.fills = [{ type: 'SOLID', color: { r: 0.1, g: 0.1, b: 0.1 } }];
    } else if (state === "Disabled") {
      button.fills = [{ type: 'SOLID', color: { r: 0.8, g: 0.8, b: 0.8 } }];
    }
    
    const buttonText = figma.createText();
    await figma.loadFontAsync({ family: "Inter", style: "Medium" });
    buttonText.fontName = { family: "Inter", style: "Medium" };
    buttonText.characters = "시작하기";
    buttonText.fontSize = 16;
    buttonText.fills = [{
      type: 'SOLID',
      color: state === "Disabled" ? { r: 0.6, g: 0.6, b: 0.6 } : { r: 1, g: 1, b: 1 }
    }];
    
    button.appendChild(buttonText);
    primaryButtonSet.appendChild(button);
  }
  
  // Secondary Button Component
  const secondaryButtonSet = figma.createFrame();
  secondaryButtonSet.name = "Secondary Button States";
  secondaryButtonSet.layoutMode = 'HORIZONTAL';
  secondaryButtonSet.itemSpacing = 16;
  secondaryButtonSet.fills = [];
  buttonSection.appendChild(secondaryButtonSet);
  
  for (const state of buttonStates) {
    const button = figma.createComponent();
    button.name = `Button/Secondary/${state}`;
    button.resize(160, 48);
    button.cornerRadius = 12;
    button.layoutMode = 'HORIZONTAL';
    button.primaryAxisAlignItems = 'CENTER';
    button.counterAxisAlignItems = 'CENTER';
    button.strokes = [{
      type: 'SOLID',
      color: state === "Disabled" ? { r: 0.8, g: 0.8, b: 0.8 } : primaryColor
    }];
    button.strokeWeight = 2;
    button.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
    
    const buttonText = figma.createText();
    buttonText.fontName = { family: "Inter", style: "Medium" };
    buttonText.characters = "둘러보기";
    buttonText.fontSize = 16;
    buttonText.fills = [{
      type: 'SOLID',
      color: state === "Disabled" ? { r: 0.6, g: 0.6, b: 0.6 } : primaryColor
    }];
    
    button.appendChild(buttonText);
    secondaryButtonSet.appendChild(button);
  }
}

// Create Input Components
async function createInputComponents(parent) {
  const inputSection = figma.createFrame();
  inputSection.name = "Input Fields";
  inputSection.x = 900;
  inputSection.y = 50;
  inputSection.resize(800, 400);
  inputSection.layoutMode = 'VERTICAL';
  inputSection.itemSpacing = 24;
  inputSection.paddingLeft = 32;
  inputSection.paddingRight = 32;
  inputSection.paddingTop = 32;
  inputSection.paddingBottom = 32;
  inputSection.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  parent.appendChild(inputSection);
  
  // Section title
  const title = figma.createText();
  title.fontName = { family: "Inter", style: "Bold" };
  title.characters = "Input Components";
  title.fontSize = 24;
  inputSection.appendChild(title);
  
  // Text Input States
  const inputStates = ["Default", "Focused", "Error", "Disabled"];
  const inputSet = figma.createFrame();
  inputSet.name = "Text Input States";
  inputSet.layoutMode = 'HORIZONTAL';
  inputSet.itemSpacing = 16;
  inputSet.fills = [];
  inputSection.appendChild(inputSet);
  
  for (const state of inputStates) {
    const inputWrapper = figma.createFrame();
    inputWrapper.name = `Input/${state}`;
    inputWrapper.layoutMode = 'VERTICAL';
    inputWrapper.itemSpacing = 8;
    inputWrapper.fills = [];
    
    // Label
    const label = figma.createText();
    label.fontName = { family: "Inter", style: "Medium" };
    label.characters = "이름";
    label.fontSize = 14;
    label.fills = [{
      type: 'SOLID',
      color: state === "Error" ? { r: 0.86, g: 0.21, b: 0.27 } : { r: 0.15, g: 0.15, b: 0.15 }
    }];
    inputWrapper.appendChild(label);
    
    // Input field
    const input = figma.createComponent();
    input.name = `Input/TextField/${state}`;
    input.resize(240, 48);
    input.cornerRadius = 8;
    input.layoutMode = 'HORIZONTAL';
    input.paddingLeft = 16;
    input.paddingRight = 16;
    input.primaryAxisAlignItems = 'CENTER';
    
    // Border and fill based on state
    if (state === "Focused") {
      input.strokes = [{ type: 'SOLID', color: { r: 0, g: 0, b: 0 } }];
      input.strokeWeight = 2;
    } else if (state === "Error") {
      input.strokes = [{ type: 'SOLID', color: { r: 0.86, g: 0.21, b: 0.27 } }];
      input.strokeWeight = 2;
    } else if (state === "Disabled") {
      input.strokes = [{ type: 'SOLID', color: { r: 0.91, g: 0.93, b: 0.94 } }];
      input.strokeWeight = 1;
      input.fills = [{ type: 'SOLID', color: { r: 0.98, g: 0.98, b: 0.98 } }];
    } else {
      input.strokes = [{ type: 'SOLID', color: { r: 0.91, g: 0.93, b: 0.94 } }];
      input.strokeWeight = 1;
    }
    
    if (state !== "Disabled") {
      input.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
    }
    
    const placeholder = figma.createText();
    placeholder.fontName = { family: "Inter", style: "Regular" };
    placeholder.characters = state === "Error" ? "잘못된 입력입니다" : "이름을 입력하세요";
    placeholder.fontSize = 16;
    placeholder.fills = [{
      type: 'SOLID',
      color: state === "Disabled" ? { r: 0.8, g: 0.8, b: 0.8 } : { r: 0.56, g: 0.56, b: 0.56 }
    }];
    
    input.appendChild(placeholder);
    inputWrapper.appendChild(input);
    
    // Error message
    if (state === "Error") {
      const errorMsg = figma.createText();
      errorMsg.fontName = { family: "Inter", style: "Regular" };
      errorMsg.characters = "이름은 필수 입력 항목입니다";
      errorMsg.fontSize = 12;
      errorMsg.fills = [{
        type: 'SOLID',
        color: { r: 0.86, g: 0.21, b: 0.27 }
      }];
      inputWrapper.appendChild(errorMsg);
    }
    
    inputSet.appendChild(inputWrapper);
  }
}

// Create Fortune Card Components
async function createFortuneCardComponents(parent) {
  const cardSection = figma.createFrame();
  cardSection.name = "Fortune Cards";
  cardSection.x = 50;
  cardSection.y = 500;
  cardSection.resize(1650, 400);
  cardSection.layoutMode = 'VERTICAL';
  cardSection.itemSpacing = 24;
  cardSection.paddingLeft = 32;
  cardSection.paddingRight = 32;
  cardSection.paddingTop = 32;
  cardSection.paddingBottom = 32;
  cardSection.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  parent.appendChild(cardSection);
  
  // Section title
  const title = figma.createText();
  title.fontName = { family: "Inter", style: "Bold" };
  title.characters = "Fortune Card Components";
  title.fontSize = 24;
  cardSection.appendChild(title);
  
  // Fortune cards grid
  const cardGrid = figma.createFrame();
  cardGrid.name = "Fortune Cards";
  cardGrid.layoutMode = 'HORIZONTAL';
  cardGrid.layoutWrap = 'WRAP';
  cardGrid.itemSpacing = 20;
  cardGrid.counterAxisSpacing = 20;
  cardGrid.fills = [];
  cardSection.appendChild(cardGrid);
  
  // Sample fortune cards
  const fortuneTypes = [
    { name: "오늘의 운세", gradient: ["#EC4899", "#DB2777"], icon: "☀️" },
    { name: "타로 카드", gradient: ["#9333EA", "#7C3AED"], icon: "🔮" },
    { name: "사주", gradient: ["#EF4444", "#EC4899"], icon: "📜" },
    { name: "연애운", gradient: ["#EC4899", "#DB2777"], icon: "💕" },
    { name: "금전운", gradient: ["#16A34A", "#15803D"], icon: "💰" },
    { name: "건강운", gradient: ["#10B981", "#059669"], icon: "🌿" }
  ];
  
  for (const fortune of fortuneTypes) {
    const card = figma.createComponent();
    card.name = `Card/Fortune/${fortune.name}`;
    card.resize(240, 280);
    card.cornerRadius = 16;
    card.layoutMode = 'VERTICAL';
    card.paddingLeft = 24;
    card.paddingRight = 24;
    card.paddingTop = 24;
    card.paddingBottom = 24;
    card.itemSpacing = 16;
    
    // Gradient background
    const startColor = hexToRgb(fortune.gradient[0]);
    const endColor = hexToRgb(fortune.gradient[1]);
    card.fills = [{
      type: 'GRADIENT_LINEAR',
      gradientTransform: [
        [0.7071, 0.7071, 0],
        [-0.7071, 0.7071, 0.5]
      ],
      gradientStops: [
        { position: 0, color: { ...startColor, a: 1 } },
        { position: 1, color: { ...endColor, a: 1 } }
      ]
    }];
    
    // Icon
    const iconText = figma.createText();
    iconText.fontName = { family: "Inter", style: "Regular" };
    iconText.characters = fortune.icon;
    iconText.fontSize = 48;
    iconText.textAlignHorizontal = 'CENTER';
    card.appendChild(iconText);
    
    // Title
    const titleText = figma.createText();
    titleText.fontName = { family: "Inter", style: "Bold" };
    titleText.characters = fortune.name;
    titleText.fontSize = 20;
    titleText.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
    titleText.textAlignHorizontal = 'CENTER';
    card.appendChild(titleText);
    
    // Description
    const descText = figma.createText();
    descText.fontName = { family: "Inter", style: "Regular" };
    descText.characters = "당신의 운세를 확인해보세요";
    descText.fontSize = 14;
    descText.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1, a: 0.8 } }];
    descText.textAlignHorizontal = 'CENTER';
    card.appendChild(descText);
    
    // Auto layout spacer
    const spacer = figma.createFrame();
    spacer.name = "Spacer";
    spacer.layoutGrow = 1;
    spacer.fills = [];
    card.appendChild(spacer);
    
    // Button
    const button = figma.createFrame();
    button.name = "Button";
    button.resize(192, 40);
    button.cornerRadius = 20;
    button.layoutMode = 'HORIZONTAL';
    button.primaryAxisAlignItems = 'CENTER';
    button.counterAxisAlignItems = 'CENTER';
    button.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1, a: 0.2 } }];
    
    const buttonText = figma.createText();
    buttonText.fontName = { family: "Inter", style: "Medium" };
    buttonText.characters = "운세 보기";
    buttonText.fontSize = 14;
    buttonText.fills = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
    button.appendChild(buttonText);
    
    card.appendChild(button);
    cardGrid.appendChild(card);
  }
}

// Create Social Login Components
async function createSocialLoginComponents(parent) {
  const socialSection = figma.createFrame();
  socialSection.name = "Social Login Buttons";
  socialSection.x = 50;
  socialSection.y = 950;
  socialSection.resize(800, 500);
  socialSection.layoutMode = 'VERTICAL';
  socialSection.itemSpacing = 24;
  socialSection.paddingLeft = 32;
  socialSection.paddingRight = 32;
  socialSection.paddingTop = 32;
  socialSection.paddingBottom = 32;
  socialSection.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  parent.appendChild(socialSection);
  
  // Section title
  const title = figma.createText();
  title.fontName = { family: "Inter", style: "Bold" };
  title.characters = "Social Login Components";
  title.fontSize = 24;
  socialSection.appendChild(title);
  
  // Social buttons
  const socialButtons = [
    { name: "Google", bg: "#FFFFFF", border: "#DADCE0", text: "#3C4043", logo: "G" },
    { name: "Apple", bg: "#000000", text: "#FFFFFF", logo: "" },
    { name: "Kakao", bg: "#FEE500", text: "#000000", logo: "K" },
    { name: "Naver", bg: "#03C75A", text: "#FFFFFF", logo: "N" },
    { name: "Facebook", bg: "#1877F2", text: "#FFFFFF", logo: "f" },
    { name: "Twitter", bg: "#1DA1F2", text: "#FFFFFF", logo: "X" }
  ];
  
  const buttonGrid = figma.createFrame();
  buttonGrid.name = "Social Buttons";
  buttonGrid.layoutMode = 'HORIZONTAL';
  buttonGrid.layoutWrap = 'WRAP';
  buttonGrid.itemSpacing = 16;
  buttonGrid.counterAxisSpacing = 16;
  buttonGrid.fills = [];
  socialSection.appendChild(buttonGrid);
  
  for (const social of socialButtons) {
    const button = figma.createComponent();
    button.name = `Button/Social/${social.name}`;
    button.resize(340, 52);
    button.cornerRadius = 12;
    button.layoutMode = 'HORIZONTAL';
    button.itemSpacing = 12;
    button.paddingLeft = 20;
    button.paddingRight = 20;
    button.primaryAxisAlignItems = 'CENTER';
    button.counterAxisAlignItems = 'CENTER';
    
    // Background
    const bgColor = hexToRgb(social.bg);
    button.fills = [{ type: 'SOLID', color: bgColor }];
    
    // Border for Google
    if (social.border) {
      const borderColor = hexToRgb(social.border);
      button.strokes = [{ type: 'SOLID', color: borderColor }];
      button.strokeWeight = 1;
    }
    
    // Logo placeholder
    const logo = figma.createFrame();
    logo.name = "Logo";
    logo.resize(24, 24);
    logo.cornerRadius = 4;
    logo.fills = [{ type: 'SOLID', color: hexToRgb(social.text) }];
    button.appendChild(logo);
    
    // Text
    const buttonText = figma.createText();
    buttonText.fontName = { family: "Inter", style: "Medium" };
    buttonText.characters = `${social.name}로 계속하기`;
    buttonText.fontSize = 16;
    buttonText.fills = [{ type: 'SOLID', color: hexToRgb(social.text) }];
    button.appendChild(buttonText);
    
    buttonGrid.appendChild(button);
  }
}

// Helper function
function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16) / 255,
    g: parseInt(result[2], 16) / 255,
    b: parseInt(result[3], 16) / 255
  } : null;
}

// Run the script
createComponentsPage();

figma.closePlugin("✅ Components created successfully!");