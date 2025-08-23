import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../presentation/providers/navigation_visibility_provider.dart';

/// 소원 카테고리 정의
enum WishCategory {
  love('💕', '사랑', '연애, 결혼, 짝사랑', Colors.pink),
  money('💰', '돈', '재물, 투자, 사업', Colors.green),
  health('🌿', '건강', '건강, 회복, 장수', Colors.lightGreen),
  success('🏆', '성공', '취업, 승진, 성취', Colors.orange),
  family('👨‍👩‍👧‍👦', '가족', '가족, 화목, 관계', Colors.blue),
  study('📚', '학업', '시험, 공부, 성적', Colors.indigo),
  other('🌟', '기타', '소원이 있으시면', Colors.purple);

  const WishCategory(this.emoji, this.name, this.description, this.color);
  
  final String emoji;
  final String name;
  final String description;
  final Color color;
}

/// 소원 입력 바텀시트
class WishInputBottomSheet extends ConsumerStatefulWidget {
  final Function(String wishText, String category, int urgency)? onWishSubmitted;
  
  const WishInputBottomSheet({
    super.key,
    this.onWishSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    Function(String wishText, String category, int urgency)? onWishSubmitted,
  }) async {
    final container = ProviderScope.containerOf(context);
    
    // 네비게이션 바 숨기기
    container.read(navigationVisibilityProvider.notifier).hide();
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WishInputBottomSheet(
        onWishSubmitted: onWishSubmitted,
      ),
    ).whenComplete(() {
      // Bottom Sheet가 닫힐 때 네비게이션 바 다시 표시
      container.read(navigationVisibilityProvider.notifier).show();
    });
  }

  @override
  ConsumerState<WishInputBottomSheet> createState() => _WishInputBottomSheetState();
}

class _WishInputBottomSheetState extends ConsumerState<WishInputBottomSheet> {
  final _wishController = TextEditingController();
  WishCategory _selectedCategory = WishCategory.other; // 기본값으로 '기타' 설정
  int _urgencyLevel = 3; // 1-5 별점

  @override
  void dispose() {
    _wishController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    return _wishController.text.trim().isNotEmpty;
  }

  void _submitWish() {
    if (!_canSubmit()) return;

    final wishText = _wishController.text.trim();
    final category = _selectedCategory.name;
    final urgency = _urgencyLevel;

    // 바텀시트 닫기
    Navigator.of(context).pop();
    
    // 콜백이 있으면 콜백 호출, 없으면 기존 방식 사용
    if (widget.onWishSubmitted != null) {
      widget.onWishSubmitted!(wishText, category, urgency);
    } else {
      // 기존 방식: 소원 빌기 페이지로 이동
      context.go('/wish', extra: {
        'autoGenerate': true,
        'wishParams': {
          'text': wishText,
          'category': category,
          'urgency': urgency,
        },
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  _buildHeader(),
                  const SizedBox(height: 32),
                  
                  // 소원 입력
                  _buildWishInput(),
                  const SizedBox(height: 24),
                  
                  // 간절함 정도
                  _buildUrgencyLevel(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // 하단 버튼
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '🙏',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '소원 빌기',
                    style: TossTheme.heading2.copyWith(
                      color: TossTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '간절한 마음으로 소원을 빌어보세요',
                    style: TossTheme.subtitle1.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TossTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TossTheme.primaryBlue.withOpacity(0.2),
            ),
          ),
          child: Text(
            '✨ 신이 당신의 소원을 들어주실 것입니다 ✨',
            style: TossTheme.subtitle2.copyWith(
              color: TossTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildWishInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '소원을 적어주세요',
          style: TossTheme.body1.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _wishController.text.isNotEmpty 
                  ? TossTheme.primaryBlue 
                  : TossTheme.borderGray300,
              width: _wishController.text.isNotEmpty ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _wishController,
            maxLines: 4,
            maxLength: 200,
            style: TossTheme.body2,
            decoration: InputDecoration(
              hintText: '예: 올해 안에 좋은 직장에 취업하고 싶습니다\n가족 모두가 건강하게 지내길 바랍니다',
              hintStyle: TossTheme.subtitle2.copyWith(
                color: TossTheme.textGray400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TossTheme.caption.copyWith(
                color: TossTheme.textGray400,
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '소원 종류를 선택해주세요',
          style: TossTheme.body1.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: WishCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? category.color.withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? category.color
                        : TossTheme.borderGray300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.name,
                            style: TossTheme.subtitle2.copyWith(
                              color: isSelected 
                                  ? category.color
                                  : TossTheme.textBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            category.description,
                            style: TossTheme.caption.copyWith(
                              color: isSelected 
                                  ? category.color
                                  : TossTheme.textGray600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUrgencyLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '얼마나 간절한가요?',
          style: TossTheme.body1.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TossTheme.borderGray200.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isSelected = index < _urgencyLevel;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _urgencyLevel = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        isSelected ? Icons.star : Icons.star_border,
                        size: 32,
                        color: isSelected 
                            ? const Color(0xFFFFD700)
                            : TossTheme.textGray400,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _getUrgencyText(_urgencyLevel),
                style: TossTheme.subtitle2.copyWith(
                  color: TossTheme.textGray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getUrgencyText(int level) {
    switch (level) {
      case 1: return '조금 바라는 정도예요';
      case 2: return '그럭저럭 이루고 싶어요';
      case 3: return '꽤 간절해요';
      case 4: return '정말 간절해요';
      case 5: return '온 마음을 다해 빌어요';
      default: return '';
    }
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canSubmit() ? _submitWish : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canSubmit() 
                ? TossTheme.primaryBlue 
                : TossTheme.disabledGray,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 8),
              Text(
                _canSubmit() ? '신에게 소원 빌기' : '모든 항목을 작성해주세요',
                style: TossTheme.button,
              ),
            ],
          ),
        ),
      ),
    );
  }
}