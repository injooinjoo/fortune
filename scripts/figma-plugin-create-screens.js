// Figma Plugin Code - Fortune App Screens
// Run this after creating the Design System and Components

async function createScreensPage() {
  // Find or create Screens page
  let screensPage = figma.root.children.find(page => page.name === "Screens");
  if (!screensPage) {
    screensPage = figma.createPage();
    screensPage.name = "Screens";
  }
  
  figma.currentPage = screensPage;
  
  // Create screens
  await createLandingPage();
  await createSocialLoginBottomSheet();
  await createOnboardingFlows();
  
  // Arrange screens
  arrangeScreens();
}

// Create Landing Page
async function createLandingPage() {
  const iPhoneFrame = figma.createFrame();
  iPhoneFrame.name = "Landing Page - iPhone 14 Pro";
  iPhoneFrame.x = 100;
  iPhoneFrame.y = 100;
  iPhoneFrame.resize(390, 844);
  iPhoneFrame.cornerRadius = 60;
  iPhoneFrame.fills = [{
    type: 'SOLID',
    color: { r: 0.98, g: 0.98, b: 0.98 }
  }];
  iPhoneFrame.clipsContent = true;
  
  // Status bar
  const statusBar = figma.createFrame();
  statusBar.name = "Status Bar";
  statusBar.resize(390, 54);
  statusBar.fills = [];
  iPhoneFrame.appendChild(statusBar);
  
  // Dynamic Island
  const dynamicIsland = figma.createRectangle();
  dynamicIsland.name = "Dynamic Island";
  dynamicIsland.x = 145;
  dynamicIsland.y = 14;
  dynamicIsland.resize(100, 30);
  dynamicIsland.cornerRadius = 15;
  dynamicIsland.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  statusBar.appendChild(dynamicIsland);
  
  // Main content
  const mainContent = figma.createFrame();
  mainContent.name = "Content";
  mainContent.y = 54;
  mainContent.resize(390, 790);
  mainContent.layoutMode = 'VERTICAL';
  mainContent.primaryAxisAlignItems = 'CENTER';
  mainContent.counterAxisAlignItems = 'CENTER';
  mainContent.paddingLeft = 24;
  mainContent.paddingRight = 24;
  mainContent.fills = [];
  iPhoneFrame.appendChild(mainContent);
  
  // Spacer top
  const spacerTop = figma.createFrame();
  spacerTop.layoutGrow = 1;
  spacerTop.fills = [];
  mainContent.appendChild(spacerTop);
  
  // Logo container
  const logoContainer = figma.createFrame();
  logoContainer.name = "Logo Container";
  logoContainer.layoutMode = 'VERTICAL';
  logoContainer.primaryAxisAlignItems = 'CENTER';
  logoContainer.itemSpacing = 24;
  logoContainer.fills = [];
  mainContent.appendChild(logoContainer);
  
  // Fortune logo placeholder
  const logo = figma.createFrame();
  logo.name = "Fortune Logo";
  logo.resize(120, 120);
  logo.cornerRadius = 30;
  
  // Gradient logo
  const startColor = hexToRgb("#EC4899");
  const endColor = hexToRgb("#7C3AED");
  logo.fills = [{
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
  logoContainer.appendChild(logo);
  
  // App name
  const appName = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Bold" });
  appName.fontName = { family: "Inter", style: "Bold" };
  appName.characters = "Fortune";
  appName.fontSize = 36;
  appName.fills = [{
    type: 'SOLID',
    color: { r: 0.1, g: 0.1, b: 0.1 }
  }];
  appName.textAlignHorizontal = 'CENTER';
  logoContainer.appendChild(appName);
  
  // Tagline
  const tagline = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  tagline.fontName = { family: "Inter", style: "Regular" };
  tagline.characters = "매일 당신의 운세를 확인하세요";
  tagline.fontSize = 16;
  tagline.fills = [{
    type: 'SOLID',
    color: { r: 0.56, g: 0.56, b: 0.56 }
  }];
  tagline.textAlignHorizontal = 'CENTER';
  logoContainer.appendChild(tagline);
  
  // Spacer middle
  const spacerMiddle = figma.createFrame();
  spacerMiddle.resize(1, 80);
  spacerMiddle.fills = [];
  mainContent.appendChild(spacerMiddle);
  
  // Start button
  const startButton = figma.createFrame();
  startButton.name = "Start Button";
  startButton.resize(342, 56);
  startButton.cornerRadius = 28;
  startButton.layoutMode = 'HORIZONTAL';
  startButton.primaryAxisAlignItems = 'CENTER';
  startButton.counterAxisAlignItems = 'CENTER';
  startButton.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0 }
  }];
  
  const buttonText = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "SemiBold" });
  buttonText.fontName = { family: "Inter", style: "SemiBold" };
  buttonText.characters = "시작하기";
  buttonText.fontSize = 18;
  buttonText.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  startButton.appendChild(buttonText);
  mainContent.appendChild(startButton);
  
  // Spacer bottom
  const spacerBottom = figma.createFrame();
  spacerBottom.layoutGrow = 0.5;
  spacerBottom.fills = [];
  mainContent.appendChild(spacerBottom);
  
  // Dark mode toggle
  const darkModeContainer = figma.createFrame();
  darkModeContainer.name = "Dark Mode Toggle";
  darkModeContainer.layoutMode = 'HORIZONTAL';
  darkModeContainer.itemSpacing = 12;
  darkModeContainer.primaryAxisAlignItems = 'CENTER';
  darkModeContainer.fills = [];
  mainContent.appendChild(darkModeContainer);
  
  const darkModeIcon = figma.createFrame();
  darkModeIcon.resize(24, 24);
  darkModeIcon.cornerRadius = 12;
  darkModeIcon.fills = [{
    type: 'SOLID',
    color: { r: 0.2, g: 0.2, b: 0.2 }
  }];
  darkModeContainer.appendChild(darkModeIcon);
  
  const darkModeText = figma.createText();
  darkModeText.fontName = { family: "Inter", style: "Regular" };
  darkModeText.characters = "다크 모드";
  darkModeText.fontSize = 14;
  darkModeText.fills = [{
    type: 'SOLID',
    color: { r: 0.56, g: 0.56, b: 0.56 }
  }];
  darkModeContainer.appendChild(darkModeText);
  
  // Safe area bottom
  const safeAreaBottom = figma.createFrame();
  safeAreaBottom.resize(390, 34);
  safeAreaBottom.fills = [];
  mainContent.appendChild(safeAreaBottom);
}

// Create Social Login Bottom Sheet
async function createSocialLoginBottomSheet() {
  const bottomSheetContainer = figma.createFrame();
  bottomSheetContainer.name = "Social Login Bottom Sheet";
  bottomSheetContainer.x = 600;
  bottomSheetContainer.y = 100;
  bottomSheetContainer.resize(390, 844);
  bottomSheetContainer.fills = [{
    type: 'SOLID',
    color: { r: 0, g: 0, b: 0, a: 0.4 }
  }];
  
  // Bottom sheet
  const bottomSheet = figma.createFrame();
  bottomSheet.name = "Bottom Sheet";
  bottomSheet.y = 344;
  bottomSheet.resize(390, 500);
  bottomSheet.layoutMode = 'VERTICAL';
  bottomSheet.topLeftRadius = 24;
  bottomSheet.topRightRadius = 24;
  bottomSheet.fills = [{
    type: 'SOLID',
    color: { r: 1, g: 1, b: 1 }
  }];
  bottomSheet.effects = [{
    type: 'DROP_SHADOW',
    color: { r: 0, g: 0, b: 0, a: 0.15 },
    offset: { x: 0, y: -4 },
    radius: 20,
    visible: true,
    blendMode: 'NORMAL'
  }];
  bottomSheetContainer.appendChild(bottomSheet);
  
  // Handle
  const handleContainer = figma.createFrame();
  handleContainer.resize(390, 36);
  handleContainer.layoutMode = 'HORIZONTAL';
  handleContainer.primaryAxisAlignItems = 'CENTER';
  handleContainer.counterAxisAlignItems = 'CENTER';
  handleContainer.fills = [];
  bottomSheet.appendChild(handleContainer);
  
  const handle = figma.createRectangle();
  handle.resize(40, 4);
  handle.cornerRadius = 2;
  handle.fills = [{
    type: 'SOLID',
    color: { r: 0.8, g: 0.8, b: 0.8 }
  }];
  handleContainer.appendChild(handle);
  
  // Content
  const sheetContent = figma.createFrame();
  sheetContent.layoutMode = 'VERTICAL';
  sheetContent.itemSpacing = 32;
  sheetContent.paddingLeft = 24;
  sheetContent.paddingRight = 24;
  sheetContent.paddingBottom = 34;
  sheetContent.fills = [];
  bottomSheet.appendChild(sheetContent);
  
  // Title
  const sheetTitle = figma.createText();
  sheetTitle.fontName = { family: "Inter", style: "Bold" };
  sheetTitle.characters = "간편 로그인";
  sheetTitle.fontSize = 24;
  sheetTitle.textAlignHorizontal = 'CENTER';
  bottomSheet.appendChild(sheetTitle);
  
  // Subtitle
  const sheetSubtitle = figma.createText();
  sheetSubtitle.fontName = { family: "Inter", style: "Regular" };
  sheetSubtitle.characters = "소셜 계정으로 빠르게 시작하세요";
  sheetSubtitle.fontSize = 16;
  sheetSubtitle.fills = [{
    type: 'SOLID',
    color: { r: 0.56, g: 0.56, b: 0.56 }
  }];
  sheetSubtitle.textAlignHorizontal = 'CENTER';
  sheetContent.appendChild(sheetSubtitle);
  
  // Social buttons container
  const socialButtonsContainer = figma.createFrame();
  socialButtonsContainer.layoutMode = 'VERTICAL';
  socialButtonsContainer.itemSpacing = 12;
  socialButtonsContainer.fills = [];
  sheetContent.appendChild(socialButtonsContainer);
  
  // Social buttons
  const socialPlatforms = [
    { name: "Google", bg: "#FFFFFF", border: "#DADCE0", text: "#3C4043" },
    { name: "Apple", bg: "#000000", text: "#FFFFFF" },
    { name: "Kakao", bg: "#FEE500", text: "#000000" },
    { name: "Naver", bg: "#03C75A", text: "#FFFFFF" },
    { name: "Facebook", bg: "#1877F2", text: "#FFFFFF" },
    { name: "Twitter", bg: "#1DA1F2", text: "#FFFFFF" }
  ];
  
  for (const platform of socialPlatforms) {
    const button = figma.createFrame();
    button.name = `${platform.name} Login Button`;
    button.resize(342, 52);
    button.cornerRadius = 12;
    button.layoutMode = 'HORIZONTAL';
    button.itemSpacing = 12;
    button.paddingLeft = 20;
    button.paddingRight = 20;
    button.primaryAxisAlignItems = 'CENTER';
    button.counterAxisAlignItems = 'CENTER';
    
    const bgColor = hexToRgb(platform.bg);
    button.fills = [{ type: 'SOLID', color: bgColor }];
    
    if (platform.border) {
      const borderColor = hexToRgb(platform.border);
      button.strokes = [{ type: 'SOLID', color: borderColor }];
      button.strokeWeight = 1;
    }
    
    const buttonText = figma.createText();
    buttonText.fontName = { family: "Inter", style: "Medium" };
    buttonText.characters = `${platform.name}로 계속하기`;
    buttonText.fontSize = 16;
    buttonText.fills = [{ type: 'SOLID', color: hexToRgb(platform.text) }];
    button.appendChild(buttonText);
    
    socialButtonsContainer.appendChild(button);
  }
  
  // Terms text
  const termsText = figma.createText();
  termsText.fontName = { family: "Inter", style: "Regular" };
  termsText.characters = "계속하면 서비스 약관 및 개인정보 처리방침에 동의하는 것으로 간주됩니다.";
  termsText.fontSize = 12;
  termsText.fills = [{
    type: 'SOLID',
    color: { r: 0.56, g: 0.56, b: 0.56 }
  }];
  termsText.textAlignHorizontal = 'CENTER';
  termsText.layoutAlign = 'STRETCH';
  sheetContent.appendChild(termsText);
}

// Create Onboarding Flows
async function createOnboardingFlows() {
  const onboardingScreens = [
    { step: 1, title: "이름 입력", x: 100, y: 1100 },
    { step: 2, title: "생년월일 선택", x: 600, y: 1100 },
    { step: 3, title: "성별 선택", x: 1100, y: 1100 },
    { step: 4, title: "위치 선택", x: 1600, y: 1100 }
  ];
  
  for (const screen of onboardingScreens) {
    const frame = figma.createFrame();
    frame.name = `Onboarding Step ${screen.step} - ${screen.title}`;
    frame.x = screen.x;
    frame.y = screen.y;
    frame.resize(390, 844);
    frame.cornerRadius = 60;
    frame.fills = [{
      type: 'SOLID',
      color: { r: 0.98, g: 0.98, b: 0.98 }
    }];
    frame.clipsContent = true;
    
    // Status bar
    const statusBar = figma.createFrame();
    statusBar.name = "Status Bar";
    statusBar.resize(390, 54);
    statusBar.fills = [];
    frame.appendChild(statusBar);
    
    // Navigation bar
    const navBar = figma.createFrame();
    navBar.name = "Navigation Bar";
    navBar.y = 54;
    navBar.resize(390, 56);
    navBar.layoutMode = 'HORIZONTAL';
    navBar.paddingLeft = 16;
    navBar.paddingRight = 16;
    navBar.primaryAxisAlignItems = 'CENTER';
    navBar.counterAxisAlignItems = 'CENTER';
    navBar.fills = [];
    frame.appendChild(navBar);
    
    // Back button
    const backButton = figma.createFrame();
    backButton.resize(40, 40);
    backButton.cornerRadius = 20;
    backButton.fills = [{
      type: 'SOLID',
      color: { r: 0.95, g: 0.95, b: 0.95 }
    }];
    navBar.appendChild(backButton);
    
    // Spacer
    const navSpacer = figma.createFrame();
    navSpacer.layoutGrow = 1;
    navSpacer.fills = [];
    navBar.appendChild(navSpacer);
    
    // Progress indicator
    const progressContainer = figma.createFrame();
    progressContainer.layoutMode = 'HORIZONTAL';
    progressContainer.itemSpacing = 8;
    progressContainer.fills = [];
    navBar.appendChild(progressContainer);
    
    for (let i = 1; i <= 4; i++) {
      const dot = figma.createEllipse();
      dot.resize(8, 8);
      dot.fills = [{
        type: 'SOLID',
        color: i <= screen.step ? { r: 0, g: 0, b: 0 } : { r: 0.9, g: 0.9, b: 0.9 }
      }];
      progressContainer.appendChild(dot);
    }
    
    // Content
    const content = figma.createFrame();
    content.name = "Content";
    content.y = 110;
    content.resize(390, 688);
    content.layoutMode = 'VERTICAL';
    content.paddingLeft = 24;
    content.paddingRight = 24;
    content.paddingTop = 40;
    content.paddingBottom = 40;
    content.itemSpacing = 32;
    content.fills = [];
    frame.appendChild(content);
    
    // Step title
    const stepTitle = figma.createText();
    stepTitle.fontName = { family: "Inter", style: "Bold" };
    stepTitle.characters = getStepTitle(screen.step);
    stepTitle.fontSize = 28;
    content.appendChild(stepTitle);
    
    // Step subtitle
    const stepSubtitle = figma.createText();
    stepSubtitle.fontName = { family: "Inter", style: "Regular" };
    stepSubtitle.characters = getStepSubtitle(screen.step);
    stepSubtitle.fontSize = 16;
    stepSubtitle.fills = [{
      type: 'SOLID',
      color: { r: 0.56, g: 0.56, b: 0.56 }
    }];
    content.appendChild(stepSubtitle);
    
    // Input area
    const inputArea = figma.createFrame();
    inputArea.layoutMode = 'VERTICAL';
    inputArea.itemSpacing = 16;
    inputArea.fills = [];
    content.appendChild(inputArea);
    
    // Create step-specific content
    createStepContent(screen.step, inputArea);
    
    // Spacer
    const spacer = figma.createFrame();
    spacer.layoutGrow = 1;
    spacer.fills = [];
    content.appendChild(spacer);
    
    // Next button
    const nextButton = figma.createFrame();
    nextButton.name = "Next Button";
    nextButton.resize(342, 56);
    nextButton.cornerRadius = 28;
    nextButton.layoutMode = 'HORIZONTAL';
    nextButton.primaryAxisAlignItems = 'CENTER';
    nextButton.counterAxisAlignItems = 'CENTER';
    nextButton.fills = [{
      type: 'SOLID',
      color: { r: 0, g: 0, b: 0 }
    }];
    
    const nextButtonText = figma.createText();
    nextButtonText.fontName = { family: "Inter", style: "SemiBold" };
    nextButtonText.characters = screen.step === 4 ? "완료" : "다음";
    nextButtonText.fontSize = 18;
    nextButtonText.fills = [{
      type: 'SOLID',
      color: { r: 1, g: 1, b: 1 }
    }];
    nextButton.appendChild(nextButtonText);
    content.appendChild(nextButton);
    
    // Safe area
    const safeArea = figma.createFrame();
    safeArea.resize(390, 34);
    safeArea.fills = [];
    frame.appendChild(safeArea);
  }
}

// Helper functions
function getStepTitle(step) {
  const titles = {
    1: "당신의 이름을\n알려주세요",
    2: "생년월일을\n입력해주세요",
    3: "성별을\n선택해주세요",
    4: "현재 위치를\n선택해주세요"
  };
  return titles[step];
}

function getStepSubtitle(step) {
  const subtitles = {
    1: "정확한 운세를 위해 필요해요",
    2: "음력 날짜도 자동으로 계산됩니다",
    3: "맞춤형 운세를 제공해드려요",
    4: "지역별 날씨와 운세를 알려드려요"
  };
  return subtitles[step];
}

async function createStepContent(step, parent) {
  switch (step) {
    case 1: // Name input
      const nameInput = figma.createFrame();
      nameInput.resize(342, 56);
      nameInput.cornerRadius = 12;
      nameInput.strokes = [{
        type: 'SOLID',
        color: { r: 0.91, g: 0.93, b: 0.94 }
      }];
      nameInput.strokeWeight = 1;
      nameInput.fills = [{
        type: 'SOLID',
        color: { r: 1, g: 1, b: 1 }
      }];
      nameInput.layoutMode = 'HORIZONTAL';
      nameInput.paddingLeft = 20;
      nameInput.paddingRight = 20;
      nameInput.primaryAxisAlignItems = 'CENTER';
      
      const namePlaceholder = figma.createText();
      await figma.loadFontAsync({ family: "Inter", style: "Regular" });
      namePlaceholder.fontName = { family: "Inter", style: "Regular" };
      namePlaceholder.characters = "이름을 입력하세요";
      namePlaceholder.fontSize = 16;
      namePlaceholder.fills = [{
        type: 'SOLID',
        color: { r: 0.56, g: 0.56, b: 0.56 }
      }];
      nameInput.appendChild(namePlaceholder);
      parent.appendChild(nameInput);
      break;
      
    case 2: // Birthdate picker
      const dateContainer = figma.createFrame();
      dateContainer.layoutMode = 'VERTICAL';
      dateContainer.itemSpacing = 24;
      dateContainer.fills = [];
      parent.appendChild(dateContainer);
      
      // Calendar type toggle
      const calendarToggle = figma.createFrame();
      calendarToggle.layoutMode = 'HORIZONTAL';
      calendarToggle.itemSpacing = 12;
      calendarToggle.fills = [];
      dateContainer.appendChild(calendarToggle);
      
      const solarButton = figma.createFrame();
      solarButton.resize(100, 40);
      solarButton.cornerRadius = 20;
      solarButton.fills = [{
        type: 'SOLID',
        color: { r: 0, g: 0, b: 0 }
      }];
      solarButton.layoutMode = 'HORIZONTAL';
      solarButton.primaryAxisAlignItems = 'CENTER';
      solarButton.counterAxisAlignItems = 'CENTER';
      
      const solarText = figma.createText();
      solarText.fontName = { family: "Inter", style: "Medium" };
      solarText.characters = "양력";
      solarText.fontSize = 14;
      solarText.fills = [{
        type: 'SOLID',
        color: { r: 1, g: 1, b: 1 }
      }];
      solarButton.appendChild(solarText);
      calendarToggle.appendChild(solarButton);
      
      const lunarButton = figma.createFrame();
      lunarButton.resize(100, 40);
      lunarButton.cornerRadius = 20;
      lunarButton.strokes = [{
        type: 'SOLID',
        color: { r: 0.9, g: 0.9, b: 0.9 }
      }];
      lunarButton.strokeWeight = 1;
      lunarButton.fills = [{
        type: 'SOLID',
        color: { r: 1, g: 1, b: 1 }
      }];
      lunarButton.layoutMode = 'HORIZONTAL';
      lunarButton.primaryAxisAlignItems = 'CENTER';
      lunarButton.counterAxisAlignItems = 'CENTER';
      
      const lunarText = figma.createText();
      lunarText.fontName = { family: "Inter", style: "Medium" };
      lunarText.characters = "음력";
      lunarText.fontSize = 14;
      lunarText.fills = [{
        type: 'SOLID',
        color: { r: 0.56, g: 0.56, b: 0.56 }
      }];
      lunarButton.appendChild(lunarText);
      calendarToggle.appendChild(lunarButton);
      
      // Date picker
      const datePicker = figma.createFrame();
      datePicker.resize(342, 200);
      datePicker.cornerRadius = 16;
      datePicker.fills = [{
        type: 'SOLID',
        color: { r: 0.97, g: 0.97, b: 0.97 }
      }];
      datePicker.layoutMode = 'HORIZONTAL';
      datePicker.primaryAxisAlignItems = 'CENTER';
      datePicker.counterAxisAlignItems = 'CENTER';
      
      const dateText = figma.createText();
      dateText.fontName = { family: "Inter", style: "Regular" };
      dateText.characters = "날짜 선택기";
      dateText.fontSize = 16;
      dateText.fills = [{
        type: 'SOLID',
        color: { r: 0.56, g: 0.56, b: 0.56 }
      }];
      datePicker.appendChild(dateText);
      dateContainer.appendChild(datePicker);
      break;
      
    case 3: // Gender selection
      const genderOptions = figma.createFrame();
      genderOptions.layoutMode = 'HORIZONTAL';
      genderOptions.itemSpacing = 16;
      genderOptions.fills = [];
      parent.appendChild(genderOptions);
      
      const genders = ["남성", "여성", "기타"];
      for (const gender of genders) {
        const option = figma.createFrame();
        option.resize(106, 120);
        option.cornerRadius = 16;
        option.strokes = [{
          type: 'SOLID',
          color: gender === "남성" ? { r: 0, g: 0, b: 0 } : { r: 0.9, g: 0.9, b: 0.9 }
        }];
        option.strokeWeight = gender === "남성" ? 2 : 1;
        option.fills = [{
          type: 'SOLID',
          color: { r: 1, g: 1, b: 1 }
        }];
        option.layoutMode = 'VERTICAL';
        option.itemSpacing = 12;
        option.primaryAxisAlignItems = 'CENTER';
        option.counterAxisAlignItems = 'CENTER';
        option.paddingTop = 24;
        option.paddingBottom = 24;
        
        const icon = figma.createFrame();
        icon.resize(48, 48);
        icon.cornerRadius = 24;
        icon.fills = [{
          type: 'SOLID',
          color: gender === "남성" ? { r: 0, g: 0, b: 0 } : { r: 0.9, g: 0.9, b: 0.9 }
        }];
        option.appendChild(icon);
        
        const label = figma.createText();
        label.fontName = { family: "Inter", style: "Medium" };
        label.characters = gender;
        label.fontSize = 16;
        label.fills = [{
          type: 'SOLID',
          color: gender === "남성" ? { r: 0, g: 0, b: 0 } : { r: 0.56, g: 0.56, b: 0.56 }
        }];
        option.appendChild(label);
        
        genderOptions.appendChild(option);
      }
      break;
      
    case 4: // Location selection
      const locationSearch = figma.createFrame();
      locationSearch.resize(342, 56);
      locationSearch.cornerRadius = 12;
      locationSearch.strokes = [{
        type: 'SOLID',
        color: { r: 0.91, g: 0.93, b: 0.94 }
      }];
      locationSearch.strokeWeight = 1;
      locationSearch.fills = [{
        type: 'SOLID',
        color: { r: 1, g: 1, b: 1 }
      }];
      locationSearch.layoutMode = 'HORIZONTAL';
      locationSearch.paddingLeft = 20;
      locationSearch.paddingRight = 20;
      locationSearch.primaryAxisAlignItems = 'CENTER';
      
      const locationPlaceholder = figma.createText();
      locationPlaceholder.fontName = { family: "Inter", style: "Regular" };
      locationPlaceholder.characters = "시/도를 검색하세요";
      locationPlaceholder.fontSize = 16;
      locationPlaceholder.fills = [{
        type: 'SOLID',
        color: { r: 0.56, g: 0.56, b: 0.56 }
      }];
      locationSearch.appendChild(locationPlaceholder);
      parent.appendChild(locationSearch);
      
      // Current location button
      const currentLocationButton = figma.createFrame();
      currentLocationButton.resize(342, 56);
      currentLocationButton.cornerRadius = 12;
      currentLocationButton.fills = [{
        type: 'SOLID',
        color: { r: 0.97, g: 0.97, b: 0.97 }
      }];
      currentLocationButton.layoutMode = 'HORIZONTAL';
      currentLocationButton.itemSpacing = 12;
      currentLocationButton.paddingLeft = 20;
      currentLocationButton.paddingRight = 20;
      currentLocationButton.primaryAxisAlignItems = 'CENTER';
      currentLocationButton.counterAxisAlignItems = 'CENTER';
      
      const locationIcon = figma.createFrame();
      locationIcon.resize(24, 24);
      locationIcon.cornerRadius = 12;
      locationIcon.fills = [{
        type: 'SOLID',
        color: { r: 0.2, g: 0.2, b: 0.2 }
      }];
      currentLocationButton.appendChild(locationIcon);
      
      const currentLocationText = figma.createText();
      currentLocationText.fontName = { family: "Inter", style: "Medium" };
      currentLocationText.characters = "현재 위치 사용";
      currentLocationText.fontSize = 16;
      currentLocationButton.appendChild(currentLocationText);
      
      parent.appendChild(currentLocationButton);
      break;
  }
}

function arrangeScreens() {
  // Auto-arrange screens
  figma.viewport.scrollAndZoomIntoView(figma.currentPage.children);
}

function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16) / 255,
    g: parseInt(result[2], 16) / 255,
    b: parseInt(result[3], 16) / 255
  } : null;
}

// Run the script
createScreensPage();

figma.closePlugin("✅ Screens created successfully!");