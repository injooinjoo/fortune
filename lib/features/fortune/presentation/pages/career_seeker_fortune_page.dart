import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import 'dart:math' as math;

class CareerSeekerFortunePage extends BaseFortunePage {
  const CareerSeekerFortunePage({
    super.key,
    super.initialParams}) : super(
          title: '취업운',
          description: '새로운 직장을 찾고 있는 분들을 위한 맞춤 운세',
          fortuneType: 'career_seeker',
          requiresUserInfo: false
        );

  @override
  ConsumerState<CareerSeekerFortunePage> createState() => _CareerSeekerFortunePageState();
}

class _CareerSeekerFortunePageState extends BaseFortunePageState<CareerSeekerFortunePage> {
  String? _educationLevel;
  String? _desiredField;
  int _jobSearchDuration = 0;
  String? _primaryConcern;
  final List<String> _skillAreas = [];

  final List<String> _educationLevels = [
    '고등학교 졸업', '전문대 재학/졸업',
    '대학교 재학/졸업', '대학원 재학/졸업',
    '기타'
  ];

  final List<String> _fields = [
    'IT/개발', '디자인/크리에이티브',
    '마케팅/홍보', '영업/비즈니스',
    '금융/회계', '인사/총무',
    '생산/제조', '연구/R&D',
    '의료/헬스케어', '교육/강의',
    '미디어/엔터', '기타'
  ];

  final List<String> _concerns = [
    '서류 통과가 어려워요', '면접이 너무 떨려요',
    '원하는 회사가 없어요', '경력이 부족해요',
    '연봉 협상이 걱정돼요', '진로가 확실하지 않아요'
  ];

  final List<String> _skills = [
    '커뮤니케이션', '문제해결',
    '리더십', '창의성',
    '분석력', '협업',
    '시간관리', '적응력'
  ];

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final fortuneService = ref.read(fortuneServiceProvider);
    
    return await fortuneService.getFortune(
      fortuneType: widget.fortuneType,
      userId: ref.read(userProvider).value?.id ?? 'anonymous',
      params: params
    );
  }

  @override
  Future<Map<String, dynamic>?> getFortuneParams() async {
    if (_educationLevel == null || _desiredField == null || _primaryConcern == null) {
      return null;
    }

    return {
      'educationLevel': _educationLevel,
      'desiredField': _desiredField,
      'jobSearchDuration': _jobSearchDuration,
      'primaryConcern': _primaryConcern,
      'skillAreas': _skillAreas};
  }

  @override
  Widget buildInputForm() {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Education Level
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '학력 사항',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _educationLevels.map((level) {
                  final isSelected = _educationLevel == level;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _educationLevel = level;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(level),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.surface.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Desired Field
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work_rounded,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '희망 분야',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _desiredField,
                decoration: InputDecoration(
                  hintText: '희망하는 직무 분야를 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface.withValues(alpha: 0.5)),
                items: _fields.map((field) {
                  return DropdownMenuItem(
                    value: field,
                    child: Text(field));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _desiredField = value;
                  });
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Job Search Duration
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '구직 기간',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _jobSearchDuration.toDouble(),
                      min: 0,
                      max: 12,
                      divisions: 12,
                      label: _jobSearchDuration == 0
                          ? '시작 전'
                          : '$_jobSearchDuration개월',
                      onChanged: (value) {
                        setState(() {
                          _jobSearchDuration = value.round();
                        });
                      })),
                  const SizedBox(width: 16),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      _jobSearchDuration == 0
                          ? '시작 전'
                          : '$_jobSearchDuration개월',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Primary Concern
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology_rounded,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '가장 큰 고민',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(_concerns.length, (index) {
                final concern = _concerns[index];
                final isSelected = _primaryConcern == concern;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _primaryConcern = concern;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              concern,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Skill Areas
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '강점 스킬 (복수 선택)',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? TossDesignSystem.textPrimaryDark : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) {
                  final isSelected = _skillAreas.contains(skill);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _skillAreas.remove(skill);
                        } else {
                          _skillAreas.add(skill);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Chip(
                      label: Text(skill),
                      backgroundColor: isSelected
                          ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                          : theme.colorScheme.surface.withValues(alpha: 0.5),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildFortuneResult() {
    return Column(
      children: [
        super.buildFortuneResult(),
        _buildJobOpportunityRadar(),
        _buildApplicationTimeline(),
        _buildIndustryCompatibility(),
        _buildLuckyCompanies(),
        _buildActionPlan()]);
  }

  Widget _buildJobOpportunityRadar() {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.radar_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '취업 기회 레이더',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: CustomPaint(
                size: const Size.square(300),
                painter: _RadarChartPainter(
                  data: [
                    RadarData('서류 통과율', 0.85),
                    RadarData('면접 성공률', 0.75),
                    RadarData('연봉 협상력', 0.70),
                    RadarData('네트워킹', 0.80),
                    RadarData('시장 수요', 0.90),
                    RadarData('경쟁력', 0.85)],
                  primaryColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '현재 시장 수요가 매우 높은 시기입니다. 적극적인 지원을 추천드립니다!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationTimeline() {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timelineEvents = [
      TimelineEvent('1-2주', '서류 준비 & 지원', true),
      TimelineEvent('3-4주', '서류 합격 예상', false),
      TimelineEvent('5-6주', '면접 진행', false),
      TimelineEvent('7-8주', '최종 합격', false)];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '예상 취업 타임라인',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...timelineEvents.map((event) {
              final index = timelineEvents.indexOf(event);
              final isLast = index == timelineEvents.length - 1;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: event.isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2)),
                        child: Center(
                          child: Icon(
                            event.isCompleted
                                ? Icons.check
                                : Icons.schedule,
                            color: event.isCompleted
                                ? TossDesignSystem.white
                                : theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 60,
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.period,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.title,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustryCompatibility() {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final industries = [
      IndustryMatch('IT/테크', 0.95, TossDesignSystem.tossBlue),
      IndustryMatch('금융', 0.85, TossDesignSystem.successGreen),
      IndustryMatch('제조', 0.70, TossDesignSystem.warningOrange),
      IndustryMatch('서비스', 0.80, TossDesignSystem.purple),
      IndustryMatch('공공', 0.75, TossDesignSystem.errorRed)];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '산업별 적합도',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...industries.map((industry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          industry.name,
                          style: theme.textTheme.bodyLarge),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4),
                          decoration: BoxDecoration(
                            color: industry.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                            '${industry.compatibility}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: industry.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: industry.compatibility / 100,
                      backgroundColor: industry.color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(industry.color),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyCompanies() {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final companies = [
      '대기업 IT 계열사', '성장 중인 스타트업',
      '외국계 기업', '공공기관',
      '중견기업'
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_center_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '행운의 기업 유형',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...companies.map((company) {
              final index = companies.indexOf(company);
              final isTop = index < 2;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isTop
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTop
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isTop
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isTop
                                  ? TossDesignSystem.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          company,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isTop)
                        Icon(
                          Icons.star_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPlan() {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      ActionItem(
        icon: Icons.description_rounded,
        title: '이력서 업데이트',
        description: '최신 경험과 스킬을 반영하세요',
        urgency: 'high'),
      ActionItem(
        icon: Icons.search_rounded,
        title: '채용공고 모니터링',
        description: '매일 2-3개씩 관심 기업 확인',
        urgency: 'medium'),
      ActionItem(
        icon: Icons.people_rounded,
        title: '네트워킹 활동',
        description: 'LinkedIn 프로필 업데이트 & 인맥 확대',
        urgency: 'medium'),
      ActionItem(
        icon: Icons.school_rounded,
        title: '스킬 업그레이드',
        description: '온라인 강의나 자격증 준비',
        urgency: 'low')];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '이번 주 행운의 액션',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...actions.map((action) {
              final urgencyColor = action.urgency == 'high'
                  ? TossDesignSystem.errorRed
                  : action.urgency == 'medium'
                      ? TossDesignSystem.warningOrange
                      : TossDesignSystem.successGreen;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: urgencyColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                          action.icon,
                          color: urgencyColor,
                          size: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              action.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Data Models
class RadarData {
  final String label;
  final double value;

  RadarData(this.label, this.value);
}

class TimelineEvent {
  final String period;
  final String title;
  final bool isCompleted;

  TimelineEvent(this.period, this.title, this.isCompleted);
}

class IndustryMatch {
  final String name;
  final double compatibility;
  final Color color;

  IndustryMatch(this.name, this.compatibility, this.color);
}

class ActionItem {
  final IconData icon;
  final String title;
  final String description;
  final String urgency;

  ActionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.urgency});
}

// Custom Painter for Radar Chart
class _RadarChartPainter extends CustomPainter {
  final List<RadarData> data;
  final Color primaryColor;
  final Color backgroundColor;

  _RadarChartPainter({
    required this.data,
    required this.primaryColor,
    required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    final angle = 2 * math.pi / data.length;

    // Draw grid
    final gridPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      final gridRadius = radius * (i / 5);
      final path = Path();
      
      for (int j = 0; j < data.length; j++) {
        final x = center.dx + gridRadius * math.cos(angle * j - math.pi / 2);
        final y = center.dy + gridRadius * math.sin(angle * j - math.pi / 2);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axes
    for (int i = 0; i < data.length; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      
      canvas.drawLine(center, Offset(x, y), gridPaint);
      
      // Draw labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: TypographyUnified.labelMedium.copyWith(
            color: primaryColor)),
        textDirection: TextDirection.ltr);
      
      textPainter.layout();
      
      final labelX = center.dx + (radius + 20) * math.cos(angle * i - math.pi / 2);
      final labelY = center.dy + (radius + 20) * math.sin(angle * i - math.pi / 2);
      
      textPainter.paint(
        canvas,
        Offset(
          labelX - textPainter.width / 2,
          labelY - textPainter.height / 2));
    }

    // Draw data
    final dataPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final dataPath = Path();
    
    for (int i = 0; i < data.length; i++) {
      final value = data[i].value / 100;
      final x = center.dx + radius * value * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * value * math.sin(angle * i - math.pi / 2);
      
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    
    // Draw data border
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(dataPath, borderPaint);
    
    // Draw data points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < data.length; i++) {
      final value = data[i].value / 100;
      final x = center.dx + radius * value * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * value * math.sin(angle * i - math.pi / 2);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}