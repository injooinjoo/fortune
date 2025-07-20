# 🏃 강화된 스포츠 운세 가이드

> **최종 업데이트**: 2025년 1월 15일

## 📚 목차
1. [날씨 연동 스포츠](#날씨-연동-스포츠)
2. [경기 일정 연동](#경기-일정-연동)
3. [특수 운세](#특수-운세)
4. [API 통합](#api-통합)
5. [구현 상태](#구현-상태)

---

## 날씨 연동 스포츠

### ⛳ 골프 운세
**실시간 날씨 데이터 활용**
- 🌡️ 기온: 클럽 선택과 비거리 예측
- 💨 바람: 방향과 세기에 따른 샷 전략
- 💧 습도: 그린 스피드 예측
- ☔ 강수: 우천 플레이 대비

```dart
// 날씨별 골프 조언 예시
if (windSpeed > 10) {
  return '바람이 강해 낮은 탄도로 플레이하세요';
}
```

### ⚾ 야구 운세
**경기장별 날씨 + KBO 일정**
- 🏟️ 경기장별 실시간 날씨
- 📅 당일 경기 일정 표시
- 🏠 홈/원정 경기 구분
- ⏰ 경기 시작 시간

### 🎣 낚시 운세
**날씨와 물때 정보**
- 🌊 기압 변화와 어류 활동
- 🌡️ 수온 예측
- 🌅 일출/일몰 시간
- 🌊 물때 정보 (추후 연동)

### 🏃 러닝/사이클링 운세
**미세먼지와 날씨**
- 🌫️ 미세먼지 농도
- 🌡️ 체감 온도
- 💦 습도와 탈수 위험
- 🌧️ 강수 확률

---

## 경기 일정 연동

### ⚾ KBO 야구
```typescript
interface GameSchedule {
  homeTeam: string;
  awayTeam: string;
  gameTime: DateTime;
  stadium: string;
  status: string;
}
```

**구현 기능**
- 10개 구단 일정 조회
- 오늘의 경기 하이라이트
- 홈/원정 경기 표시
- 경기장 날씨 연동

### 🎮 LCK e스포츠
```typescript
interface EsportsMatch {
  team1: string;
  team2: string;
  matchTime: DateTime;
  tournament: string;
  gameType: string; // BO3, BO5
  stats?: Map<string, dynamic>;
}
```

**구현 기능**
- LCK 경기 일정
- 팀별 최근 성적
- 승률 통계
- 경기 시청 가이드

### ⚽ K리그 (예정)
- K리그1/K리그2 일정
- 구단별 운세
- 경기장 날씨

---

## 특수 운세

### 🎰 로또 운세
**AI 기반 번호 추천**
```dart
class LotteryFortunePage {
  // 추천 번호 생성
  List<int> _luckyNumbers; // 6개
  int _bonusNumber;
  
  // 구매 가이드
  String _buyTimeAdvice;
  String _buyLocationAdvice;
  
  // 통계 분석
  List<int> hotNumbers;  // 자주 나온 번호
  List<int> coldNumbers; // 오래 안 나온 번호
}
```

**주요 기능**
- 행운의 번호 6개 + 보너스
- 구매 최적 시간/장소
- 역대 당첨 통계 분석
- 당첨금 예상
- 도박 중독 예방 메시지

### 💰 암호화폐 운세
**시장 분석 기반 운세**
```dart
class CryptoFortunePage {
  // 시장 분석
  String _marketSentiment; // bullish/bearish/neutral
  int fearGreedIndex;
  
  // 투자 전략
  String _tradingStrategy;
  List<String> _recommendedCoins;
  
  // 리스크 관리
  Map<String, dynamic> _riskAnalysis;
}
```

**주요 기능**
- 공포&탐욕 지수
- 시장 심리 분석
- 코인별 운세
- 리스크 관리 가이드
- 투자 주의사항

### 🎮 e스포츠 운세
**게임별 맞춤 운세**
```dart
enum GameType {
  lol('리그 오브 레전드'),
  valorant('발로란트'),
  overwatch('오버워치'),
  pubg('배틀그라운드'),
  fifa('FIFA 온라인');
}
```

**게임별 분석**
- LOL: 챔피언 추천, KDA 예측
- 발로란트: 에이전트 추천, 헤드샷률
- 오버워치: 영웅 추천, 팀워크 점수
- PUBG: 생존 시간, 안전 지대
- FIFA: 전술 추천, 득점 타이밍

---

## API 통합

### 날씨 API (OpenWeatherMap)
```dart
class WeatherService {
  static Future<WeatherData> getWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    // 실시간 날씨 데이터
    // 1시간 캐싱
  }
}
```

### 외부 데이터 API
```dart
class ExternalApiService {
  // 날씨 데이터
  static Future<WeatherData> getWeatherData(String location);
  
  // 스포츠 일정
  static Future<List<GameSchedule>> getBaseballSchedule(String team);
  static Future<List<EsportsMatch>> getLCKSchedule({String? team});
  
  // 골프장 정보
  static Future<List<GolfCourse>> getGolfCourseInfo(String region);
  
  // 암호화폐 시장
  static Future<Map<String, dynamic>> getCryptoMarketData();
  
  // 로또 통계
  static Future<Map<String, dynamic>> getLottoStatistics();
}
```

### 캐싱 전략
| 데이터 타입 | 캐시 기간 | 이유 |
|----------|----------|-----|
| 날씨 | 1시간 | 실시간성 중요 |
| 경기 일정 | 24시간 | 일 단위 변경 |
| 골프장 정보 | 7일 | 거의 변경 없음 |
| 암호화폐 | 5분 | 높은 변동성 |
| 로또 통계 | 1일 | 주 1회 추첨 |

---

## 구현 상태

### ✅ 완료된 기능
1. **날씨 API 서비스**
   - OpenWeatherMap 연동
   - 한국 주요 도시 지원
   - 스포츠별 날씨 조언

2. **외부 API 서비스 레이어**
   - 통합 API 관리
   - 캐싱 시스템
   - Mock 데이터 제공

3. **신규 운세 페이지**
   - 로또 운세 페이지
   - 암호화폐 운세 페이지
   - e스포츠 운세 페이지

4. **SportsFortunePage 개선**
   - 날씨 데이터 통합
   - 야구 일정 표시
   - 스포츠별 맞춤 조언

5. **운세 프롬프트 추가**
   - 로또, 암호화폐, e스포츠
   - LCK, 축구, 농구 운세

### 🔄 진행 중
- 실제 API 키 설정
- 프로덕션 API 연동

### 📋 예정 사항
1. **추가 API 연동**
   - 실제 KBO API
   - LCK 공식 API
   - 골프장 예약 시스템

2. **UI/UX 개선**
   - 애니메이션 강화
   - 인터랙티브 차트
   - 실시간 업데이트

3. **새로운 운세 타입**
   - 경마 운세
   - 주식 운세 (국내)
   - 토토 운세

---

## 사용 예시

### 날씨 연동 골프 운세
```dart
// 사용자가 골프 운세 선택 시
1. 현재 위치의 날씨 데이터 로드
2. 바람, 기온, 습도 분석
3. 골프장 추천 (지역별)
4. 클럽 선택 가이드
5. 시간대별 플레이 조언
```

### 야구 관람 운세
```dart
// 사용자가 야구 운세 선택 시
1. 오늘의 KBO 경기 일정 표시
2. 선택한 팀의 홈/원정 경기 확인
3. 경기장 날씨 정보 제공
4. 관람 포인트 제공
5. 응원 팀 승리 가능성 예측
```

### 로또 구매 운세
```dart
// 사용자가 로또 운세 선택 시
1. AI 기반 번호 6개 생성
2. 보너스 번호 추가
3. 구매 최적 시간 계산
4. 판매점 방향 추천
5. 통계 기반 분석 제공
```

---

## 보안 및 주의사항

### API 키 관리
```dart
// 환경 변수로 관리
static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';
// 실제 배포 시 Supabase Edge Functions 환경변수 사용
```

### 도박 관련 주의
- 로또: "도박은 오락입니다" 메시지 필수
- 암호화폐: "투자 위험" 경고 표시
- 스포츠 토토: 구현 시 신중 검토

### 데이터 정확성
- Mock 데이터 사용 시 명시
- 실시간 데이터 지연 가능성 안내
- 면책 조항 포함

---

*이 가이드는 지속적으로 업데이트됩니다.*