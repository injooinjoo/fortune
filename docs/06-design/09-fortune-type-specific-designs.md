# 🎨 운세 타입별 상세 디자인 가이드

> **최종 업데이트**: 2025년 1월 16일
> **연관 문서**: [FORTUNE_RESULT_DESIGN_SYSTEM.md](./FORTUNE_RESULT_DESIGN_SYSTEM.md)

## 📚 목차

1. [시간 기반 운세](#시간-기반-운세)
2. [전통 운세](#전통-운세)
3. [성격/캐릭터 운세](#성격캐릭터-운세)
4. [연애/인연 운세](#연애인연-운세)
5. [직업/사업 운세](#직업사업-운세)
6. [특별 운세](#특별-운세)

---

## ⏰ 시간 기반 운세

### 1. 오늘의 운세 (Daily Fortune)

#### 메인 스코어 카드
```dart
Container(
  height: 200,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
  ),
  child: Stack(
    children: [
      // 배경 패턴
      CustomPaint(
        painter: DotPatternPainter(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      // 점수 표시
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오늘의 운세', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 8),
            AnimatedScore(
              score: 85,
              style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text('EXCELLENT', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    ],
  ),
)
```

#### 시간대별 운세 그래프
```dart
class TimelineFortuneChart extends StatelessWidget {
  final List<HourlyFortune> fortunes;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: CustomPaint(
        painter: TimelineChartPainter(fortunes: fortunes),
        child: Container(),
      ),
    );
  }
}
```

### 2. 내일의 운세 (Tomorrow Fortune)

#### 예고편 스타일 카드
```dart
GlassContainer(
  child: Column(
    children: [
      // 미리보기 헤더
      Row(
        children: [
          Icon(Icons.visibility, color: Colors.amber),
          SizedBox(width: 8),
          Text('내일의 미리보기', style: TextStyle(color: Colors.amber)),
        ],
      ),
      // 블러 처리된 콘텐츠 (일부만 보이게)
      ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Text(
              fortunePreview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      // 잠금 해제 버튼
      ElevatedButton.icon(
        icon: Icon(Icons.lock_open),
        label: Text('전체 운세 확인하기'),
        onPressed: onUnlock,
      ),
    ],
  ),
)
```

---

## 🏛️ 전통 운세

### 1. 사주팔자 (Saju)

#### 사주 명식 디스플레이
```dart
class SajuDisplay extends StatelessWidget {
  final SajuData saju;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/traditional_pattern.png'),
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
      ),
      child: Table(
        border: TableBorder.all(
          color: Colors.red.shade800,
          width: 2,
          borderRadius: BorderRadius.circular(8),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
            ),
            children: [
              _buildPillar('年柱', saju.yearPillar),
              _buildPillar('月柱', saju.monthPillar),
              _buildPillar('日柱', saju.dayPillar),
              _buildPillar('時柱', saju.hourPillar),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPillar(String title, Pillar pillar) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 8),
          Text(pillar.heavenlyStem, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(pillar.earthlyBranch, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

#### 오행 균형 차트
```dart
class FiveElementsChart extends StatelessWidget {
  final Map<String, double> elements;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 5,
          radarBorderData: BorderSide(color: Colors.grey, width: 2),
          gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
          dataSets: [
            RadarDataSet(
              fillColor: Colors.blue.withOpacity(0.3),
              borderColor: Colors.blue,
              borderWidth: 3,
              dataEntries: [
                RadarEntry(value: elements['wood'] ?? 0),
                RadarEntry(value: elements['fire'] ?? 0),
                RadarEntry(value: elements['earth'] ?? 0),
                RadarEntry(value: elements['metal'] ?? 0),
                RadarEntry(value: elements['water'] ?? 0),
              ],
            ),
          ],
          getTitle: (index, angle) {
            switch (index) {
              case 0: return RadarChartTitle(text: '木', angle: 0);
              case 1: return RadarChartTitle(text: '火', angle: 0);
              case 2: return RadarChartTitle(text: '土', angle: 0);
              case 3: return RadarChartTitle(text: '金', angle: 0);
              case 4: return RadarChartTitle(text: '水', angle: 0);
              default: return RadarChartTitle(text: '');
            }
          },
        ),
      ),
    );
  }
}
```

### 2. 토정비결 (Tojeong)

#### 월별 운세 카드 그리드
```dart
class TojeongMonthlyGrid extends StatelessWidget {
  final List<MonthlyFortune> fortunes;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final fortune = fortunes[index];
        return GestureDetector(
          onTap: () => _showMonthDetail(context, fortune),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getSeasonColors(index + 1),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getSeasonColors(index + 1)[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${index + 1}월',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Icon(
                  _getMonthIcon(index + 1),
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 4),
                Text(
                  fortune.keyword,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ).animate()
          .scale(delay: Duration(milliseconds: index * 50))
          .fade();
      },
    );
  }
}
```

---

## 🧠 성격/캐릭터 운세

### 1. MBTI 운세

#### 성격 유형 카드
```dart
class MBTITypeCard extends StatelessWidget {
  final String mbtiType;
  final MBTIFortune fortune;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getMBTIColors(mbtiType),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: CustomPaint(
              painter: MBTIPatternPainter(type: mbtiType),
            ),
          ),
          // 콘텐츠
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타입 배지
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mbtiType,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // 별명
                Text(
                  fortune.nickname,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // 설명
                Text(
                  fortune.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 인지 기능 활성도
```dart
class CognitiveFunctionChart extends StatelessWidget {
  final Map<String, double> functions;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 인지 기능 활성도',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...functions.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      entry.key,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: AnimatedLinearProgress(
                      value: entry.value / 100,
                      color: _getFunctionColor(entry.key),
                      backgroundColor: Colors.grey.shade200,
                      height: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '${entry.value.toInt()}%',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
```

### 2. 별자리 운세

#### 별자리 휠
```dart
class ZodiacWheel extends StatefulWidget {
  final String currentZodiac;
  final Function(String) onZodiacSelected;
  
  @override
  _ZodiacWheelState createState() => _ZodiacWheelState();
}

class _ZodiacWheelState extends State<ZodiacWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 회전하는 별자리 휠
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: CustomPaint(
                  size: Size(300, 300),
                  painter: ZodiacWheelPainter(
                    selectedZodiac: widget.currentZodiac,
                  ),
                ),
              );
            },
          ),
          // 중앙 태양
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.yellow.shade300,
                  Colors.orange.shade400,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.brightness_5,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 💕 연애/인연 운세

### 1. 궁합 운세

#### 매칭률 디스플레이
```dart
class CompatibilityMeter extends StatelessWidget {
  final double compatibility;
  final String person1;
  final String person2;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 하트 배경
          CustomPaint(
            size: Size(200, 200),
            painter: HeartPainter(
              color: Colors.pink.withOpacity(0.2),
            ),
          ),
          // 퍼센티지 표시
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedCounter(
                value: compatibility,
                suffix: '%',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(person1, style: TextStyle(fontSize: 16)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.favorite, color: Colors.pink, size: 20),
                  ),
                  Text(person2, style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          // 파티클 효과
          if (compatibility > 80)
            Positioned.fill(
              child: HeartParticles(),
            ),
        ],
      ),
    );
  }
}
```

#### 호환성 레이더 차트
```dart
class CompatibilityRadar extends StatelessWidget {
  final Map<String, double> scores;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.shade50,
            Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.circle,
          radarBackgroundColor: Colors.transparent,
          radarBorderData: BorderSide(color: Colors.pink.shade200, width: 2),
          titleTextStyle: TextStyle(color: Colors.pink.shade700, fontSize: 14),
          dataSets: [
            RadarDataSet(
              fillColor: Colors.pink.withOpacity(0.3),
              borderColor: Colors.pink,
              borderWidth: 3,
              dataEntries: scores.values.map((v) => RadarEntry(value: v)).toList(),
            ),
          ],
          getTitle: (index, angle) {
            final titles = scores.keys.toList();
            return RadarChartTitle(
              text: titles[index],
              angle: angle,
            );
          },
        ),
      ),
    );
  }
}
```

### 2. 연애운

#### 연애 타임라인
```dart
class LoveTimeline extends StatelessWidget {
  final List<LoveEvent> events;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타임라인 인디케이터
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.pink, Colors.purple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      event.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (index < events.length - 1)
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.pink.shade200,
                    ),
                ],
              ),
              SizedBox(width: 16),
              // 이벤트 카드
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.date,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        event.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
```

---

## 💼 직업/사업 운세

### 1. 취업운

#### 성공 가능성 게이지
```dart
class SuccessGauge extends StatelessWidget {
  final double percentage;
  final String jobTitle;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 반원 게이지
          CustomPaint(
            size: Size(200, 100),
            painter: SemiCircleGaugePainter(
              percentage: percentage,
              backgroundColor: Colors.grey.shade200,
              color: _getGaugeColor(percentage),
            ),
          ),
          // 중앙 정보
          Positioned(
            bottom: 20,
            child: Column(
              children: [
                Text(
                  '${percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _getGaugeColor(percentage),
                  ),
                ),
                Text(
                  jobTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // 애로우 인디케이터
          Transform.rotate(
            angle: (percentage / 100 * pi) - (pi / 2),
            child: Container(
              width: 2,
              height: 80,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 커리어 로드맵
```dart
class CareerRoadmap extends StatelessWidget {
  final List<CareerMilestone> milestones;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          final isCompleted = milestone.isCompleted;
          final isCurrent = index == milestones.indexWhere((m) => !m.isCompleted);
          
          return Container(
            width: 150,
            margin: EdgeInsets.only(right: 16),
            child: Column(
              children: [
                // 마일스톤 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                      ? Colors.green 
                      : (isCurrent ? Colors.blue : Colors.grey.shade300),
                    border: isCurrent 
                      ? Border.all(color: Colors.blue, width: 3)
                      : null,
                  ),
                  child: Icon(
                    milestone.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 8),
                // 마일스톤 제목
                Text(
                  milestone.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Colors.blue : Colors.black87,
                  ),
                ),
                // 날짜
                Text(
                  milestone.date,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## 🎯 특별 운세

### 1. 럭키 아이템

#### 아이템 쇼케이스
```dart
class LuckyItemShowcase extends StatefulWidget {
  final List<LuckyItem> items;
  
  @override
  _LuckyItemShowcaseState createState() => _LuckyItemShowcaseState();
}

class _LuckyItemShowcaseState extends State<LuckyItemShowcase> {
  PageController _pageController = PageController(viewportFraction: 0.8);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 280,
                  width: Curves.easeOut.transform(value) * 200,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: item.gradientColors[0].withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 광택 효과
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 콘텐츠
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 80,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          item.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.timing,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 2. 컬러 운세

#### 컬러 팔레트
```dart
class ColorFortunePalette extends StatelessWidget {
  final List<ColorFortune> colors;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 행운의 색상',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: colors.map((colorFortune) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showColorDetail(context, colorFortune),
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: colorFortune.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorFortune.color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 컬러 정보
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              colorFortune.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // 순위 배지
                        if (colorFortune.rank == 1)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          // 컬러 조합 추천
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.palette, color: Colors.grey.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '오늘의 추천 컬러 조합: ${colors[0].name} + ${colors[1].name}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 구현 가이드라인

### 애니메이션 타이밍
- 초기 로딩: 0-500ms
- 콘텐츠 페이드인: 500-1000ms
- 인터랙션 피드백: 100-200ms
- 페이지 전환: 300-400ms

### 터치 반응
- 탭: 스케일 0.95 + 햅틱 피드백
- 롱프레스: 상세 정보 표시
- 스와이프: 페이지/카드 전환
- 핀치: 차트 확대/축소

### 접근성
- 모든 시각 요소에 설명 텍스트
- 고대비 모드 지원
- 스크린 리더 호환
- 최소 터치 영역 44x44

---

> 각 운세 타입별로 고유한 비주얼 아이덴티티를 유지하면서도 전체적인 일관성을 유지하는 것이 중요합니다.