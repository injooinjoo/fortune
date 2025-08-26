import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/toast.dart';
import '../widgets/face_analysis_widget.dart';

class PhysiognomyResultEnhancedPage extends StatefulWidget {
  final File imageFile;
  
  const PhysiognomyResultEnhancedPage({
    super.key,
    required this.imageFile,
  });

  @override
  State<PhysiognomyResultEnhancedPage> createState() => _PhysiognomyResultEnhancedPageState();
}

class _PhysiognomyResultEnhancedPageState extends State<PhysiognomyResultEnhancedPage>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  late FaceTypeInfo _faceTypeInfo;
  int _overallScore = 0;
  
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // 관상 분석 결과 생성
    _generateFaceAnalysisResult();
    
    // 애니메이션 시작
    _startAnimations();
  }

  void _generateFaceAnalysisResult() {
    _faceTypeInfo = FaceTypeProvider.analyzeFace();
    _overallScore = 70 + math.Random().nextInt(26); // 70-95 점 랜덤
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _shareResult() {
    HapticFeedback.lightImpact();
    Toast.success(context, '결과를 공유했습니다!');
  }

  void _saveResult() {
    HapticFeedback.lightImpact();
    Toast.success(context, '결과를 저장했습니다!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 페이지 인디케이터
            _buildPageIndicator(),
            
            // 메인 콘텐츠
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  HapticFeedback.lightImpact();
                },
                children: [
                  _buildMainResultPage(),
                  _buildDetailAnalysisPage(),
                  _buildAdvicePage(),
                ],
              ),
            ),
            
            // 하단 액션 버튼
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: TossTheme.textBlack,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '관상 분석 결과',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: TossTheme.textBlack,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.share_rounded,
            color: TossTheme.textBlack,
          ),
          onPressed: _shareResult,
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index 
                  ? TossTheme.primaryBlue
                  : TossTheme.borderGray300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainResultPage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 사용자 이미지
              _buildUserImageCard(),
              const SizedBox(height: 20),
              
              // 관상 타입 결과
              FaceAnalysisResultWidget(
                faceTypeInfo: _faceTypeInfo,
                overallScore: _overallScore,
              ),
              const SizedBox(height: 20),
              
              // 핵심 강점
              FaceStrengthsWidget(
                strengths: _faceTypeInfo.strengths,
                primaryColor: _faceTypeInfo.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailAnalysisPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 추천 직업
          RecommendedCareersWidget(
            careers: _faceTypeInfo.careers,
            primaryColor: _faceTypeInfo.primaryColor,
          ),
          const SizedBox(height: 20),
          
          // 운세별 분석
          _buildFortuneAnalysis(),
          const SizedBox(height: 20),
          
          // 궁합 분석
          _buildCompatibilityAnalysis(),
        ],
      ),
    );
  }

  Widget _buildAdvicePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 인생 조언
          LifeAdviceWidget(
            advice: _faceTypeInfo.advice,
            primaryColor: _faceTypeInfo.primaryColor,
          ),
          const SizedBox(height: 20),
          
          // 월별 운세
          _buildMonthlyFortune(),
          const SizedBox(height: 20),
          
          // 주의사항
          _buildPrecautions(),
        ],
      ),
    );
  }

  Widget _buildUserImageCard() {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _faceTypeInfo.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '분석 완료!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _faceTypeInfo.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI가 당신의 관상을 정밀 분석했습니다',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TossTheme.textGray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneAnalysis() {
    final fortunes = [
      {'name': '재물운', 'score': 85, 'description': '금전적 성공이 기대됩니다'},
      {'name': '사업운', 'score': 78, 'description': '새로운 기회가 찾아올 것입니다'},
      {'name': '연애운', 'score': 92, 'description': '좋은 인연을 만날 가능성이 높습니다'},
      {'name': '건강운', 'score': 75, 'description': '꾸준한 관리가 필요합니다'},
    ];

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: _faceTypeInfo.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '분야별 운세',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...fortunes.map((fortune) => _buildFortuneItem(
            fortune['name'] as String,
            fortune['score'] as int,
            fortune['description'] as String,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildFortuneItem(String name, int score, String description) {
    final color = _getScoreColor(score);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${score}점',
                  style: TossTheme.body3.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: TossTheme.borderGray300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: TossTheme.caption.copyWith(
                color: TossTheme.textGray600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityAnalysis() {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: _faceTypeInfo.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '궁합 분석',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildCompatibilityItem('👑', '천성 리더형', '매우 좋음', Colors.green),
          _buildCompatibilityItem('💬', '소통전문가형', '좋음', Colors.blue),
          _buildCompatibilityItem('🔬', '분석가형', '보통', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildCompatibilityItem(String emoji, String type, String level, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyFortune() {
    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: _faceTypeInfo.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '이달의 운세',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _faceTypeInfo.primaryColor.withOpacity(0.1),
                  _faceTypeInfo.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_faceTypeInfo.title} 타입인 당신에게 이달은 새로운 기회와 성장의 시기가 될 것입니다. 특히 ${_faceTypeInfo.strengths.first.toLowerCase()} 능력을 발휘할 수 있는 상황이 많이 생길 것으로 예상됩니다.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecautions() {
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: TossTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '참고사항',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 관상 분석은 참고용으로만 활용해 주세요\n• 실제 인생은 노력과 선택에 따라 달라집니다\n• 긍정적인 마음가짐이 가장 중요합니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TossTheme.textGray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: TossTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _saveResult,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline_rounded,
                        color: TossTheme.textBlack,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '저장',
                        style: TossTheme.body2.copyWith(
                          color: TossTheme.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: TossTheme.primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TossTheme.primaryBlue.withOpacity(0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _shareResult,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '공유하기',
                        style: TossTheme.body2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF22C55E);
    if (score >= 70) return _faceTypeInfo.primaryColor;
    if (score >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}