import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/presentation/providers/auth_provider.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';

class AdminGuard extends ConsumerWidget {
  final Widget child;
  final List<String>? allowedEmails;
  final List<String>? allowedRoles;

  const AdminGuard({
    super.key,
    required this.child,
    this.allowedEmails,
    this.allowedRoles});

  // Default admin emails
  static const List<String> defaultAdminEmails = [
    'admin@fortune.com',
    'admin@fortune-admin.com'];

  // Default admin roles
  static const List<String> defaultAdminRoles = [
    'admin',
    'super_admin'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // Not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/auth/selection');
          });
          return const SizedBox.shrink();
        }

        // Check if user is admin
        final isAdmin = _isUserAdmin(user);
        
        if (!isAdmin) {
          return _buildAccessDeniedScreen(context);
        }

        return child;
      },
      loading: () => const Center(
        child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorScreen(context, error));
  }

  bool _isUserAdmin(dynamic user) {
    // Check email-based access
    final userEmail = user.email?.toLowerCase() ?? '';
    final adminEmails = allowedEmails ?? defaultAdminEmails;
    
    if (adminEmails.any((email) => userEmail == email.toLowerCase())) {
      return true;
    }

    // Check domain-based access
    if (userEmail.endsWith('@fortune-admin.com')) {
      return true;
    }

    // Check role-based access
    final userRoles = (user.userMetadata?['roles'] as List<dynamic>?) ?? [];
    final adminRoles = allowedRoles ?? defaultAdminRoles;
    
    for (final role in userRoles) {
      if (adminRoles.contains(role.toString())) {
        return true;
      }
    }

    // Check if user has admin flag
    final isAdminFlag = user.userMetadata?['is_admin'] as bool? ?? false;
    if (isAdminFlag) {
      return true;
    }

    return false;
  }

  Widget _buildAccessDeniedScreen(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('접근 거부')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: theme.colorScheme.error),
                const SizedBox(height: 24),
                Text(
                  '관리자 권한이 필요합니다',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                  '이 페이지에 접근하려면 관리자 권한이 필요합니다.\n관리자에게 문의해주세요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('홈으로 돌아가기')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('오류')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error),
                const SizedBox(height: 24),
                Text(
                  '오류가 발생했습니다',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('홈으로 돌아가기')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}