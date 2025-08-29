import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/models/personality_dna_model.dart';
import '../../../../presentation/widgets/personality_dna_bottom_sheet.dart';
import '../../../../shared/components/loading_states.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';

/// 성격 DNA 결과 페이지 (토스 디자인 시스템 적용)
class PersonalityDNAPage extends ConsumerStatefulWidget {
  final PersonalityDNA? initialDNA;

  const PersonalityDNAPage({
    super.key,
    this.initialDNA,
  });

  @override
  ConsumerState<PersonalityDNAPage> createState() => _PersonalityDNAPageState();
}

class _PersonalityDNAPageState extends ConsumerState<PersonalityDNAPage> 
    with TickerProviderStateMixin {
  PersonalityDNA? _currentDNA;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentDNA = widget.initialDNA;
    
    // 네비게이션 바 즉시 숨기기
    Future.microtask(() {
      if (mounted) {
        ref.read(navigationVisibilityProvider.notifier).hide();
      }
    });
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    if (_currentDNA != null) {
      _animationController.forward();
    }
    
    // 결과 페이지로만 사용 - 자동 bottomsheet 제거
  }

  @override
  void dispose() {
    _animationController.dispose();
    
    // 네비게이션 바 즉시 복원 - dispose 전에 실행
    if (mounted) {
      ref.read(navigationVisibilityProvider.notifier).show();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // 토스 배경색
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        title: const Text(
          '성격 DNA',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF191F28),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF191F28)),
        actions: [
          if (_currentDNA != null) ...[
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF191F28)),
              onPressed: _sharePersonalityDNA,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF191F28)),
              onPressed: _showPersonalityDNABottomSheet,
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF191F28)),
              onPressed: _showPersonalityDNABottomSheet,
            ),
        ],
      ),
      body: _currentDNA == null
          ? _buildEmptyState()
          : _buildResultView(),
      floatingActionButton: _currentDNA == null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80), // 네비게이션 바 영역 피하기
              child: FloatingActionButton.extended(
                onPressed: _showPersonalityDNABottomSheet,
                backgroundColor: const Color(0xFF1F4EF5), // 토스 블루
                foregroundColor: Colors.white,
                elevation: 0,
                label: const Text(
                  'DNA 분석하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.psychology),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF1F4EF5), // 토스 블루
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '당신만의 성격 DNA를\n발견해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191F28),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'MBTI, 혈액형, 별자리, 띠를 조합하여\n특별한 성격 분석 결과를 확인하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8B95A1),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDNAHeader(),
                  const SizedBox(height: 8),
                  if (_currentDNA!.todayHighlight != null) ...[
                    _buildTodayHighlight(),
                    const SizedBox(height: 8),
                  ],
                  if (_currentDNA!.loveStyle != null) ...[
                    _buildLoveStyleSection(),
                    const SizedBox(height: 8),
                  ],
                  if (_currentDNA!.workStyle != null) ...[
                    _buildWorkStyleSection(),
                    const SizedBox(height: 8),
                  ],
                  if (_currentDNA!.dailyMatching != null) ...[
                    _buildDailyMatchingSection(),
                    const SizedBox(height: 8),
                  ],
                  if (_currentDNA!.compatibility != null) ...[
                    _buildCompatibilitySection(),
                    const SizedBox(height: 8),
                  ],
                  if (_currentDNA!.celebrity != null) ...[
                    _buildCelebritySection(),
                    const SizedBox(height: 8),
                  ],
                  if (_currentDNA!.funnyFact != null) ...[
                    _buildFunnyFactSection(),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 토스 스타일 섹션 컨테이너
  Widget _buildTossSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xFF1F4EF5),
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF191F28),
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDNAHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 인기 순위 배지 (상단)
          if (_currentDNA!.popularityRank != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _currentDNA!.popularityColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentDNA!.popularityText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 이모지와 제목 (토스 스타일)
          Text(
            _currentDNA!.emoji,
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          Text(
            _currentDNA!.title,
            style: const TextStyle(
              color: Color(0xFF191F28),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _currentDNA!.description,
            style: const TextStyle(
              color: Color(0xFF8B95A1),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // DNA 코드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentDNA!.dnaCode,
              style: const TextStyle(
                color: Color(0xFF191F28),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHighlight() {
    return _buildTossSection(
      title: '오늘의 하이라이트',
      icon: Icons.star,
      child: Text(
        _currentDNA!.todayHighlight!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF191F28),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoveStyleSection() {
    final loveStyle = _currentDNA!.loveStyle!;
    return _buildTossSection(
      title: '연애 스타일',
      icon: Icons.favorite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loveStyle.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F4EF5),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loveStyle.description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF191F28),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildLoveStyleDetailCard('연애할 때', loveStyle.whenDating),
          const SizedBox(height: 8),
          _buildLoveStyleDetailCard('이별 후', loveStyle.afterBreakup),
        ],
      ),
    );
  }

  Widget _buildLoveStyleDetailCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF191F28),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStyleSection() {
    final workStyle = _currentDNA!.workStyle!;
    return _buildTossSection(
      title: '업무 스타일',
      icon: Icons.work,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workStyle.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F4EF5),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildWorkStyleDetailCard('상사가 된다면', workStyle.asBoss),
          const SizedBox(height: 8),
          _buildWorkStyleDetailCard('회식에서', workStyle.atCompanyDinner),
          const SizedBox(height: 8),
          _buildWorkStyleDetailCard('업무 습관', workStyle.workHabit),
        ],
      ),
    );
  }

  Widget _buildWorkStyleDetailCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF191F28),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMatchingSection() {
    final dailyMatching = _currentDNA!.dailyMatching!;
    return _buildTossSection(
      title: '일상 매칭',
      icon: Icons.coffee,
      child: Column(
        children: [
          _buildDailyMatchingCard('카페 메뉴', dailyMatching.cafeMenu),
          const SizedBox(height: 8),
          _buildDailyMatchingCard('넷플릭스 장르', dailyMatching.netflixGenre),
          const SizedBox(height: 8),
          _buildDailyMatchingCard('주말 활동', dailyMatching.weekendActivity),
        ],
      ),
    );
  }

  Widget _buildDailyMatchingCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B95A1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F4EF5),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilitySection() {
    final compatibility = _currentDNA!.compatibility!;
    return _buildTossSection(
      title: '궁합',
      icon: Icons.people,
      child: Column(
        children: [
          _buildCompatibilityCard('친구', compatibility.friend.mbti, compatibility.friend.description),
          const SizedBox(height: 8),
          _buildCompatibilityCard('연인', compatibility.lover.mbti, compatibility.lover.description),
          const SizedBox(height: 8),
          _buildCompatibilityCard('동료', compatibility.colleague.mbti, compatibility.colleague.description),
        ],
      ),
    );
  }

  Widget _buildCompatibilityCard(String type, String mbti, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B95A1),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4EF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mbti,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF191F28),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebritySection() {
    final celebrity = _currentDNA!.celebrity!;
    return _buildTossSection(
      title: '닮은 유명인',
      icon: Icons.star_border,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              celebrity.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F4EF5),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              celebrity.reason,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF191F28),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnyFactSection() {
    return _buildTossSection(
      title: '재미있는 사실',
      icon: Icons.lightbulb_outline,
      child: Text(
        _currentDNA!.funnyFact!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF191F28),
          height: 1.5,
        ),
      ),
    );
  }

  /// 공유 기능
  Future<void> _sharePersonalityDNA() async {
    if (_currentDNA == null) return;
    
    final shareText = '''
🧬 나의 성격 DNA 결과 🧬

${_currentDNA!.emoji} ${_currentDNA!.title}
${_currentDNA!.description}

💕 연애 스타일: ${_currentDNA!.loveStyle?.title ?? ''}
💼 업무 스타일: ${_currentDNA!.workStyle?.title ?? ''}

☕ 카페 메뉴: ${_currentDNA!.dailyMatching?.cafeMenu ?? ''}
📺 넷플릭스: ${_currentDNA!.dailyMatching?.netflixGenre ?? ''}

✨ 닮은 유명인: ${_currentDNA!.celebrity?.name ?? ''}

#성격DNA #MBTI #포춘플러터
''';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  /// PersonalityDNA 분석 BottomSheet 표시
  Future<void> _showPersonalityDNABottomSheet() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PersonalityDNABottomSheet(
        onResult: (personalityDNA) {
          setState(() {
            _currentDNA = personalityDNA;
          });
          _animationController.reset();
          _animationController.forward();
        },
      ),
    );
  }
}