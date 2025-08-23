import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';
import '../../../../core/components/toss_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/app_header.dart';

class DreamFortuneTossPage extends ConsumerStatefulWidget {
  const DreamFortuneTossPage({super.key});

  @override
  ConsumerState<DreamFortuneTossPage> createState() => _DreamFortuneTossPageState();
}

class _DreamFortuneTossPageState extends ConsumerState<DreamFortuneTossPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _dreamController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isInputFocused = false;
  
  @override
  void initState() {
    super.initState();
    
    // 네비게이션 바 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).hide();
    });
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
    
    // 포커스 리스너 추가
    _focusNode.addListener(() {
      setState(() {
        _isInputFocused = _focusNode.hasFocus;
      });
    });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _dreamController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onStartInterpretation() {
    if (_dreamController.text.trim().isEmpty) return;
    
    // 네비게이션 바 복원
    ref.read(navigationVisibilityProvider.notifier).show();
    
    // 꿈해몽 채팅 페이지로 이동하며 꿈 내용 전달
    context.push(
      '/interactive/dream-interpretation-chat',
      extra: {
        'dreamContent': _dreamController.text.trim(),
        'autoGenerate': true,
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: '꿈 해몽',
        showBackButton: true,
        centerTitle: true,
        onBackPressed: () {
          ref.read(navigationVisibilityProvider.notifier).show();
          context.pop();
        },
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                
                // 메인 헤더
                _buildMainHeader(),
                
                const SizedBox(height: 40),
                
                // 꿈 입력 섹션
                _buildDreamInputSection(),
                
                const SizedBox(height: 32),
                
                // 안내 카드
                _buildGuideCard(),
                
                const SizedBox(height: 40),
                
                // 해몽 시작 버튼
                _buildStartButton(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.blue.shade400,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bedtime_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '꿈을 들려주세요',
                    style: TossTheme.heading2.copyWith(
                      color: const Color(0xFF191F28),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '어떤 꿈을 꾸셨나요?',
                    style: TossTheme.subtitle2.copyWith(
                      color: const Color(0xFF8B95A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 부제목
        Text(
          '꿈의 상황과 느낌을 자세히 적어주시면\n더 정확한 해몽을 받을 수 있어요',
          style: TossTheme.body3.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDreamInputSection() {
    final hasText = _dreamController.text.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '꿈 내용',
          style: TossTheme.body1.copyWith(
            color: const Color(0xFF191F28),
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 텍스트 입력 필드
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isInputFocused || hasText
                ? TossTheme.primaryBlue.withOpacity(0.05)
                : const Color(0xFFF8F9FA),
            border: Border.all(
              color: _isInputFocused || hasText
                  ? TossTheme.primaryBlue
                  : const Color(0xFFE5E7EB),
              width: _isInputFocused || hasText ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isInputFocused || hasText
                ? [
                    BoxShadow(
                      color: TossTheme.primaryBlue.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _dreamController,
            focusNode: _focusNode,
            maxLines: 8,
            maxLength: 500,
            onChanged: (value) {
              setState(() {});
            },
            style: TossTheme.body3.copyWith(
              color: const Color(0xFF191F28),
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '예: 높은 하늘을 날아다니는 꿈을 꾸었어요. 구름 위를 자유롭게 날아다니며 기분이 정말 좋았고, 아래로 보이는 풍경이 아름다웠어요. 그런데 갑자기 떨어질 것 같은 불안감이 들었어요...',
              hintStyle: TossTheme.body3.copyWith(
                color: const Color(0xFF9CA3AF),
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              counterText: '',
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 글자수 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '꿈의 상황, 등장인물, 감정 등을 구체적으로 써주세요',
              style: TossTheme.caption.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
            Text(
              '${_dreamController.text.length}/500',
              style: TossTheme.caption.copyWith(
                color: _dreamController.text.length > 450
                    ? TossTheme.error
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '더 정확한 해몽을 위한 팁',
                style: TossTheme.body1.copyWith(
                  color: const Color(0xFF0C4A6E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Column(
            children: [
              _buildTipItem('꿈 속 장소와 시간대'),
              _buildTipItem('등장인물과의 관계'),
              _buildTipItem('꿈에서 느꼈던 감정'),
              _buildTipItem('특별히 기억나는 상징이나 물건'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF0EA5E9),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TossTheme.body3.copyWith(
                color: const Color(0xFF0C4A6E),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStartButton() {
    final hasText = _dreamController.text.trim().isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: TossButton(
        text: '꿈 해몽 받기',
        onPressed: hasText ? _onStartInterpretation : null,
        style: TossButtonStyle.primary,
        size: TossButtonSize.large,
        leadingIcon: const Icon(Icons.auto_awesome),
      ),
    );
  }
}