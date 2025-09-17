import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/font_size_provider.dart';
import '../../../../core/theme/toss_design_system.dart';

// Wish model
class WallWish {
  final String id;
  final String text;
  final String author;
  final DateTime createdAt;
  final int likes;
  final Color color;
  final double rotation;
  final Offset position;
  final bool isLiked;

  WallWish({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
    required this.likes,
    required this.color,
    required this.rotation,
    required this.position,
    this.isLiked = false});

  WallWish copyWith({
    int? likes,
    bool? isLiked}) {
    return WallWish(
      id: id,
      text: text,
      author: author,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      color: color,
      rotation: rotation,
      position: position,
      isLiked: isLiked ?? this.isLiked);
  }
}

// Wish colors
final List<Color> wishColors = [
  const Color(0xFFFFE5B4), // Peach
  const Color(0xFFFFB6C1), // Light Pink
  const Color(0xFFB4E5FF), // Light Blue
  const Color(0xFFB4FFB4), // Light Green
  const Color(0xFFFFB4FF), // Light Purple
  const Color(0xFFFFFFB4), // Light Yellow
];

// Providers
final wishesProvider = StateNotifierProvider<WishesNotifier, List<WallWish>>(
  (ref) => WishesNotifier());

class WishesNotifier extends StateNotifier<List<WallWish>> {
  WishesNotifier() : super([]) {
    _loadInitialWishes();
  }

  void _loadInitialWishes() {
    final random = math.Random();
    state = [
      WallWish(
        id: '1',
        text: '올해는 꼭 취업에 성공하고 싶어요!',
        author: '희망이',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 23,
        color: wishColors[0],
        rotation: random.nextDouble() * 0.2 - 0.1,
        position: const Offset(0.1, 0.1)),
      WallWish(
        id: '2',
        text: '가족 모두 건강하게 지내길 🙏',
        author: '건강맨',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 45,
        color: wishColors[1],
        rotation: random.nextDouble() * 0.2 - 0.1,
        position: const Offset(0.6, 0.2)),
      WallWish(
        id: '3',
        text: '사랑하는 사람과 결혼하고 싶어요 💕',
        author: '로맨티스트',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 67,
        color: wishColors[2],
        rotation: random.nextDouble() * 0.2 - 0.1,
        position: const Offset(0.3, 0.4)),
      WallWish(
        id: '4',
        text: '부자가 되고 싶어요! 로또 1등 당첨!',
        author: '대박이',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 89,
        color: wishColors[3],
        rotation: random.nextDouble() * 0.2 - 0.1,
        position: const Offset(0.7, 0.6))];
  }

  void addWish(String text, String author) {
    final random = math.Random();
    final newWish = WallWish(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: author,
      createdAt: DateTime.now(),
      likes: 0,
      color: wishColors[random.nextInt(wishColors.length)],
      rotation: random.nextDouble() * 0.2 - 0.1,
      position: Offset(
        random.nextDouble() * 0.8,
        random.nextDouble() * 0.8));
    state = [newWish, ...state];
  }

  void toggleLike(String wishId) {
    state = state.map((wish) {
      if (wish.id == wishId) {
        return wish.copyWith(
          likes: wish.isLiked ? wish.likes - 1 : wish.likes + 1,
          isLiked: !wish.isLiked);
      }
      return wish;
    }).toList();
  }

  void deleteWish(String wishId) {
    state = state.where((wish) => wish.id != wishId).toList();
  }
}

class WishWallPage extends ConsumerStatefulWidget {
  const WishWallPage({super.key});

  @override
  ConsumerState<WishWallPage> createState() => _WishWallPageState();
}

class _WishWallPageState extends ConsumerState<WishWallPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _wishController = TextEditingController();
  final _authorController = TextEditingController();
  bool _showWriteForm = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this)..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _wishController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _submitWish() {
    if (_wishController.text.isEmpty || _authorController.text.isEmpty) {
      Toast.show(context, message: '소원과 이름을 모두 입력해주세요', type: ToastType.warning);
      return;
    }

    ref.read(wishesProvider.notifier).addWish(
          _wishController.text,
          _authorController.text);

    setState(() {
      _showWriteForm = false;
      _wishController.clear();
      _authorController.clear();
    });

    Toast.show(context, message: '소원이 벽에 붙여졌습니다!', type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final wishes = ref.watch(wishesProvider);

    return Scaffold(
      appBar: AppHeader(
        title: '소원의 벽',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              setState(() {
                _showWriteForm = !_showWriteForm;
              });
            })]),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                  theme.colorScheme.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),

          // Floating stars background
          ...List.generate(10, (index) {
            final random = math.Random(index);
            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2 * math.pi,
                    child: Icon(
                      Icons.star_rounded,
                      size: 20 + random.nextDouble() * 20,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  );
                },
              ),
            );
          }),

          // Wish notes
          if (wishes.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_rounded,
                    size: 80,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '첫 번째 소원을 적어보세요',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: fontSize.value + 2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          if (wishes.isNotEmpty)
            ...wishes.map((wish) => _buildWishNote(context, theme, fontSize.value, wish)),

          // Write form
          if (_showWriteForm)
            Container(
              color: TossDesignSystem.black.withValues(alpha: 0.5),
              child: Center(
                child: _buildWriteForm(theme, fontSize.value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWishNote(
    BuildContext context,
    ThemeData theme,
    double fontSize,
    WallWish wish) {
    final screenSize = MediaQuery.of(context).size;
    final left = wish.position.dx * screenSize.width;
    final top = wish.position.dy * screenSize.height;

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: wish.rotation,
        child: GestureDetector(
          onTap: () => _showWishDetail(context, theme, fontSize, wish),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: wish.color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: TossDesignSystem.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  wish.text,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: TossDesignSystem.black.withValues(alpha: 0.87),
                    height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '- ${wish.author}',
                      style: TextStyle(
                        fontSize: fontSize - 4,
                        color: TossDesignSystem.black.withValues(alpha: 0.54),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          wish.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: wish.isLiked ? TossDesignSystem.error : TossDesignSystem.black.withValues(alpha: 0.54),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          wish.likes.toString(),
                          style: TextStyle(
                            fontSize: fontSize - 4,
                            color: TossDesignSystem.black.withValues(alpha: 0.54),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWriteForm(ThemeData theme, double fontSize) {
    return Container(
      margin: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 400),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '소원 적기',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: fontSize + 4,
                    fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      _showWriteForm = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Wish input
            TextField(
              controller: _wishController,
              maxLines: 3,
              maxLength: 100,
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: fontSize),
              decoration: InputDecoration(
                labelText: '소원',
                hintText: '이루고 싶은 소원을 적어주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Author input
            TextField(
              controller: _authorController,
              maxLength: 20,
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: fontSize),
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '닉네임을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitWish,
                icon: const Icon(Icons.star_rounded),
                label: const Text('소원 빌기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWishDetail(
    BuildContext context,
    ThemeData theme,
    double fontSize,
    WallWish wish) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TossDesignSystem.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: wish.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wish.text,
                    style: TextStyle(
                      fontSize: fontSize + 2,
                      color: TossDesignSystem.black.withValues(alpha: 0.87),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '- ${wish.author}',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: TossDesignSystem.black.withValues(alpha: 0.54),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Info
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(wish.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSize - 2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: TossDesignSystem.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${wish.likes}명이 응원해요',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: fontSize - 2,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(wishesProvider.notifier).toggleLike(wish.id);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      wish.isLiked ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(wish.isLiked ? '응원 취소' : '응원하기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Toast.show(context, message: '공유 기능은 준비 중입니다', type: ToastType.info);
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('공유하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}