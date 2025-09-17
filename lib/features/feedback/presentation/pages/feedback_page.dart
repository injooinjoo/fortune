import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/toast.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../presentation/providers/font_size_provider.dart';

// Feedback submission provider
final feedbackSubmissionProvider = StateNotifierProvider.autoDispose<FeedbackSubmissionNotifier, AsyncValue<void>>((ref) {
  return FeedbackSubmissionNotifier(ref);
});

class FeedbackSubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  FeedbackSubmissionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> submitFeedback({
    required String category,
    required String message,
    required int rating,
    String? email}) async {
    state = const AsyncValue.loading();
    
    try {
      final apiClient = ref.read(apiClientProvider);
      
      final response = await apiClient.post(
        '/api/feedback',
        data: {
          'category': category,
          'message': message,
          'rating': rating,
          'email': email}
      );
      
      if (response.data['success'] == true) {
        state = const AsyncValue.data(null);
      } else {
        throw Exception(response.data['error'] ?? '피드백 전송에 실패했습니다');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedCategory = 'general';
  int _rating = 5;
  
  final List<Map<String, dynamic>> _categories = [
    {'id': 'general', 'label': '일반 피드백', 'icon': Icons.feedback},
    {'id': 'bug', 'label': '버그 신고', 'icon': Icons.bug_report},
    {'id': 'feature', 'label': '기능 제안', 'icon': Icons.lightbulb},
    {'id': 'improvement', 'label': '개선 사항', 'icon': Icons.auto_fix_high},
    {'id': 'other', 'label': '기타', 'icon': Icons.more_horiz}];

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(feedbackSubmissionProvider.notifier).submitFeedback(
      category: _selectedCategory,
      message: _messageController.text,
      rating: _rating,
      email: _emailController.text.isNotEmpty ? _emailController.text : null);

    final submissionState = ref.read(feedbackSubmissionProvider);
    
    if (submissionState.hasError) {
      Toast.show(
        context,
        message: '피드백 전송에 실패했습니다',
        type: ToastType.error);
    } else if (submissionState.hasValue) {
      Toast.show(
        context,
        message: '소중한 의견 감사합니다!',
        type: ToastType.success);
      
      // Reset form
      _messageController.clear();
      _emailController.clear();
      setState(() {
        _selectedCategory = 'general';
        _rating = 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = ref.watch(fontSizeProvider);
    final fontScale = fontSize == FontSize.small ? 0.85 : fontSize == FontSize.large ? 1.15 : 1.0;
    final submissionState = ref.watch(feedbackSubmissionProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: '의견 보내기',
              showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '여러분의 의견을 들려주세요',
                                    style: TextStyle(
                                      fontSize: 18 * fontScale,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '더 나은 서비스를 만들어가겠습니다',
                                    style: TextStyle(
                                      fontSize: 14 * fontScale,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Category Selection
                      Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category['id'];
                          return GlassButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = category['id'];
                              });
                            },
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(0.3),
                                      theme.colorScheme.secondary.withOpacity(0.3)])
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category['icon'],
                                    size: 18,
                                    color: isSelected ? theme.colorScheme.primary : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category['label'],
                                    style: TextStyle(
                                      fontSize: 14 * fontScale,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? theme.colorScheme.primary : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList()),
                      const SizedBox(height: 24),
                      
                      // Rating
                      Text(
                        '만족도',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starValue = index + 1;
                                return IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _rating = starValue;
                                    });
                                  },
                                  icon: Icon(
                                    starValue <= _rating ? Icons.star : Icons.star_border,
                                    size: 36,
                                    color: starValue <= _rating
                                        ? TossDesignSystem.warningYellow
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                  ),
                                );
                              })),
                            const SizedBox(height: 8),
                            Text(
                              _getRatingText(_rating),
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: _getRatingColor(_rating),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Message
                      Text(
                        '내용',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _messageController,
                          maxLines: 5,
                          style: TextStyle(fontSize: 16 * fontScale),
                          decoration: InputDecoration(
                            hintText: '의견을 자유롭게 작성해주세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface.withOpacity(0.5),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '내용을 입력해주세요';
                            }
                            if (value.trim().length < 10) {
                              return '10자 이상 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Email (optional)
                      Text(
                        '이메일 (선택)',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '답변이 필요한 경우 이메일을 남겨주세요',
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 16 * fontScale),
                          decoration: InputDecoration(
                            hintText: 'your@email.com',
                            prefixIcon: Icon(Icons.email, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface.withOpacity(0.5),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return '올바른 이메일 형식이 아닙니다';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          onPressed: submissionState.isLoading ? null : _submitFeedback,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: submissionState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: TossDesignSystem.white,
                                    ),
                                  )
                                : Text(
                                    '의견 보내기',
                                    style: TextStyle(
                                      fontSize: 18 * fontScale,
                                      fontWeight: FontWeight.bold,
                                      color: TossDesignSystem.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '매우 불만족';
      case 2:
        return '불만족';
      case 3:
        return '보통';
      case 4:
        return '만족';
      case 5:
        return '매우 만족';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return TossDesignSystem.error;
      case 3:
        return TossDesignSystem.warningOrange;
      case 4:
      case 5:
        return TossDesignSystem.success;
      default:
        return TossDesignSystem.gray500;
    }
  }
}