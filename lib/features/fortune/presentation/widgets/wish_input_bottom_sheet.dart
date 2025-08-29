import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    );
    
    // 네비게이션 바 다시 표시
    container.read(navigationVisibilityProvider.notifier).show();
  }

  @override
  ConsumerState<WishInputBottomSheet> createState() => _WishInputBottomSheetState();
}

class _WishInputBottomSheetState extends ConsumerState<WishInputBottomSheet> {
  final TextEditingController _wishController = TextEditingController();
  WishCategory _selectedCategory = WishCategory.love;
  int _urgencyLevel = 3;

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
    
    widget.onWishSubmitted?.call(
      _wishController.text.trim(),
      _selectedCategory.name,
      _urgencyLevel,
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              '소원을 빌어주세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191F28),
                fontFamily: 'TossProductSans',
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategorySelection(),
                  const SizedBox(height: 24),
                  _buildWishInput(),
                  const SizedBox(height: 24),
                  _buildUrgencyLevel(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Submit button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitWish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit() ? const Color(0xFF1F4EF5) : const Color(0xFFE5E5E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '소원 빌기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'TossProductSans',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '어떤 소원인가요?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191F28),
              fontFamily: 'TossProductSans',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WishCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1F4EF5) : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1F4EF5) : const Color(0xFFE5E5E5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF8B95A1),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'TossProductSans',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWishInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '소원을 자세히 적어주세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191F28),
              fontFamily: 'TossProductSans',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wishController,
            maxLines: 4,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: '마음을 담아 소원을 적어보세요...',
              hintStyle: const TextStyle(
                color: Color(0xFF8B95A1),
                fontFamily: 'TossProductSans',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1F4EF5)),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontFamily: 'TossProductSans',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyLevel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '얼마나 간절한가요?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191F28),
              fontFamily: 'TossProductSans',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _urgencyLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: const Color(0xFF1F4EF5),
                  onChanged: (value) {
                    setState(() {
                      _urgencyLevel = value.round();
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            _getUrgencyText(_urgencyLevel),
            style: const TextStyle(
              color: Color(0xFF8B95A1),
              fontFamily: 'TossProductSans',
            ),
          ),
        ],
      ),
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
}