# Enhanced Investment Fortune Feature Documentation

## Overview
The Enhanced Investment Fortune feature provides comprehensive investment analysis and personalized recommendations based on Korean fortune-telling principles combined with modern investment strategies. It covers 10 popular investment sectors that Korean investors are interested in.

## Key Features

### 1. Investment Sectors (10개 투자 섹터)
- **주식 (Stocks)**: Domestic and international stock market analysis
- **부동산 (Real Estate)**: Apartments, officetels, and land investment
- **암호화폐 (Cryptocurrency)**: Bitcoin and altcoin fortune
- **경매 (Auction)**: Real estate and item auction opportunities  
- **로또 (Lottery)**: Lucky number recommendations
- **펀드/ETF (Funds/ETF)**: Index and sector fund analysis
- **금/원자재 (Gold/Commodities)**: Gold, silver, and oil investment
- **채권 (Bonds)**: Government and corporate bond analysis
- **스타트업 투자 (Startup Investment)**: Crowdfunding opportunities
- **예술품/수집품 (Art/Collectibles)**: NFT, art, and luxury goods

### 2. Multi-Step User Flow

#### Step 1: Investment Profile (투자 프로필)
- Risk tolerance assessment (안정형/중립형/공격형)
- Investment experience level (초보자/중급자/전문가)
- Investment goals (자산 증식/안정적 수익/단기 수익/노후 준비)
- Investment horizon (3개월/6개월/1년/3년/5년 이상)

#### Step 2: Sector Selection (관심 섹터)
- Select up to 5 investment sectors
- Set priority percentage for each sector (0-100%)
- Visual card-based selection with gradients and icons

#### Step 3: Analysis Options (상세 분석)
- Portfolio review option
- Market timing analysis
- Lucky numbers generation
- Risk management analysis
- Custom question input

#### Step 4: Fortune Generation (운세 생성)
- Summary page with selected options
- Animated fortune generation
- Navigation to results page

### 3. Results Page Features

#### Overall Score
- Investment fortune score (0-100)
- Visual circular progress indicator
- Score interpretation (최고의 날/매우 좋음/좋음/보통/주의/위험)

#### Tab-Based Results
1. **종합 분석 (Overall Analysis)**
   - Investment personality analysis
   - Today's investment fortune
   - Warnings and precautions
   - Portfolio recommendations (if selected)
   - Risk analysis (if selected)

2. **섹터별 운세 (Sector Analysis)**
   - Individual score for each selected sector
   - Buy/Sell/Hold recommendations
   - Sector-specific analysis
   - Tips for each sector
   - Expandable cards with progress indicators

3. **투자 타이밍 (Market Timing)**
   - Today's timing analysis
   - Weekly timing analysis  
   - Monthly timing analysis
   - Lucky days calendar
   - Signal strength indicators

4. **행운 정보 (Lucky Information)**
   - Lottery number recommendations (6 numbers)
   - General lucky numbers
   - Lucky colors visualization
   - Lucky directions
   - Answer to custom question (if provided)

### 4. Visual Design

#### Color Schemes
- Each sector has unique gradient colors
- Score-based color coding (green/yellow/orange/red)
- Consistent material design principles

#### Animations
- Fade and scale animations on page transitions
- Shimmer effect on fortune generation
- Smooth tab transitions
- Interactive chart animations

#### Components
- Glass morphism containers
- Custom painted backgrounds
- Pie charts for portfolio visualization
- Linear progress indicators
- Expandable tiles

## Technical Implementation

### Frontend Architecture

#### State Management
- `InvestmentStepNotifier`: Manages multi-step flow state
- `InvestmentFortuneData`: Data model for user inputs
- `investmentStepProvider`: Step navigation state
- `investmentDataProvider`: User selection state

#### Key Widgets
- `InvestmentFortuneEnhancedPage`: Main multi-step page
- `InvestmentFortuneResultPage`: Results display with tabs
- Sector selection cards with priority sliders
- Risk assessment radio buttons
- Analysis option switches

#### Navigation
- PageView for step navigation
- Tab controller for results
- Route parameters for data passing

### Backend Integration

#### Edge Function
- **Endpoint**: `/fortune-investment-enhanced`
- **Authentication**: Supabase auth required
- **Caching**: Redis caching for performance

#### Fortune Generation Algorithm
1. Calculate overall investment score based on:
   - Birth date and lunar calendar
   - Risk tolerance alignment
   - Sector diversification
   
2. Generate sector-specific fortunes:
   - Base scores for each sector
   - Adjustments based on birth date
   - Recommendations (매수/매도/관망)

3. Market timing analysis:
   - Daily/weekly/monthly recommendations
   - Lucky days calculation
   - Signal strength assessment

4. Lucky information:
   - Lottery numbers based on birth date
   - Lucky colors and directions
   - Personalized lucky numbers

5. Risk analysis:
   - Experience vs risk tolerance check
   - Sector concentration warnings
   - Investment horizon compatibility

### API Integration

#### Request Parameters
```typescript
{
  userId: string,
  name: string,
  birthDate: string,
  gender: string,
  birthTime?: string,
  riskTolerance: string,
  investmentExperience: string,
  investmentGoal: string,
  investmentHorizon: number,
  selectedSectors: string[],
  sectorPriorities: Record<string, number>,
  wantPortfolioReview: boolean,
  wantMarketTiming: boolean,
  wantLuckyNumbers: boolean,
  wantRiskAnalysis: boolean,
  specificQuestion?: string
}
```

#### Response Structure
```typescript
{
  overallScore: number,
  summary: string,
  overallAnalysis: {
    personality: string,
    todaysFortune: string,
    warnings: string,
    portfolio?: Record<string, number>
  },
  sectorFortune: Record<string, {
    score: number,
    recommendation: string,
    analysis: string,
    tips: string
  }>,
  marketTiming?: {
    today: TimingInfo,
    week: TimingInfo,
    month: TimingInfo,
    luckyDays: number[]
  },
  luckyInfo?: {
    numbers: {
      lotto: number[],
      general: number[]
    },
    colors: string[],
    directions: string[]
  },
  riskAnalysis?: {
    risks: RiskItem[]
  },
  specificAnswer?: string
}
```

## User Experience Flow

1. **Entry Point**: User taps "투자 운세" in fortune list
2. **Profile Setup**: User completes investment profile questions
3. **Sector Selection**: User selects interested sectors and sets priorities
4. **Analysis Options**: User chooses additional analysis features
5. **Confirmation**: User reviews selections
6. **Generation**: Animated fortune generation with loading state
7. **Results**: Comprehensive results with multiple tabs
8. **Sharing**: Option to share results (future feature)

## Best Practices

### Performance
- Lazy loading of heavy components
- Image optimization for sector cards
- Efficient state management
- Caching of fortune results

### Accessibility
- Proper contrast ratios
- Screen reader support
- Touch target sizes
- Clear navigation flow

### Error Handling
- Graceful fallbacks for API failures
- Input validation at each step
- Clear error messages
- Retry mechanisms

## Future Enhancements

1. **Historical Tracking**: Track investment fortune history
2. **Push Notifications**: Alert users on lucky investment days
3. **Social Sharing**: Share fortune results with friends
4. **AI Integration**: More sophisticated analysis with AI
5. **Real-time Data**: Integration with actual market data
6. **Portfolio Tracking**: Track actual vs predicted performance

## Localization

Currently supports Korean language with considerations for:
- Korean investment terminology
- Local market preferences
- Cultural fortune-telling elements
- Korean number formatting

## Testing Checklist

- [ ] Multi-step navigation works correctly
- [ ] All sectors display properly
- [ ] Priority sliders function correctly
- [ ] Fortune generation completes successfully
- [ ] Results display all selected options
- [ ] Tabs navigate smoothly
- [ ] Charts render correctly
- [ ] Lucky numbers are unique
- [ ] Error states handled gracefully
- [ ] Back navigation preserves state