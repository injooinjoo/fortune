# Fortune App Route Migration Summary

## New Integrated Pages

### 1. Time-Based Fortune Page (`/fortune/time`)
Query parameter: `?period=`
- hourly
- daily
- today
- tomorrow
- weekly
- monthly
- yearly
- newYear

### 2. Relationship Fortune Page (`/fortune/relationship`)
Query parameter: `?type=`
- love
- marriage
- compatibility
- traditional-compatibility
- couple-match
- ex-lover
- blind-date

### 3. Traditional Fortune Page (`/fortune/traditional`)
Query parameter: `?type=`
- saju
- tojeong
- traditional-saju
- palmistry
- physiognomy
- salpuli

### 4. Investment Fortune Page (`/fortune/investment`)
Query parameter: `?type=`
- general
- stock
- crypto
- real-estate
- lottery

### 5. Sports Fortune Page (`/fortune/sports`)
Query parameter: `?type=`
- fitness
- golf
- tennis
- baseball
- running
- cycling
- swimming
- yoga
- hiking
- fishing

### 6. Lifestyle Fortune Page (`/fortune/lifestyle`)
Query parameter: `?type=`
- health
- biorhythm
- moving
- moving-date

## Standalone Pages (Not Integrated)
These pages remain as individual routes:
- `/fortune/mbti` - MBTI Fortune
- `/fortune/zodiac` - Zodiac Fortune
- `/fortune/zodiac-animal` - Zodiac Animal Fortune
- `/fortune/blood-type` - Blood Type Fortune
- `/fortune/career` - Career Fortune
- `/fortune/wealth` - Wealth Fortune
- `/fortune/business` - Business Fortune
- `/fortune/lucky-color` - Lucky Color
- `/fortune/lucky-number` - Lucky Number
- `/fortune/lucky-food` - Lucky Food
- `/fortune/lucky-items` - Lucky Items
- `/fortune/lucky-place` - Lucky Place
- `/fortune/birth-season` - Birth Season
- `/fortune/birthdate` - Birthdate
- `/fortune/birthstone` - Birthstone
- `/fortune/avoid-people` - Avoid People
- `/fortune/celebrity` - Celebrity Fortune
- `/fortune/celebrity-match` - Celebrity Match
- `/fortune/chemistry` - Chemistry Fortune
- `/fortune/face-reading` - Face Reading
- `/fortune/five-blessings` - Five Blessings
- `/fortune/lucky-job` - Lucky Job
- `/fortune/lucky-outfit` - Lucky Outfit
- `/fortune/lucky-series` - Lucky Series
- `/fortune/network-report` - Network Report
- `/fortune/personality` - Personality
- `/fortune/saju-psychology` - Saju Psychology
- `/fortune/employment` - Employment
- `/fortune/talent` - Talent
- `/fortune/destiny` - Destiny
- `/fortune/past-life` - Past Life
- `/fortune/wish` - Wish Fortune
- `/fortune/timeline` - Timeline
- `/fortune/talisman` - Talisman
- `/fortune/startup` - Startup
- `/fortune/lucky-exam` - Lucky Exam
- `/fortune/best-practices` - Best Practices
- `/fortune/inspiration` - Daily Inspiration

## Redirect Rules
All legacy routes automatically redirect to the new integrated pages with appropriate query parameters.

Examples:
- `/fortune/love` → `/fortune/relationship?type=love`
- `/fortune/saju` → `/fortune/traditional?type=saju`
- `/fortune/lucky-stock` → `/fortune/investment?type=stock`
- `/fortune/lucky-golf` → `/fortune/sports?type=golf`
- `/fortune/health` → `/fortune/lifestyle?type=health`
- `/fortune/yearly` → `/fortune/time?period=yearly`