import 'package:flutter/material.dart';
import '../../shared/glassmorphism/glass_container.dart';
import '../../core/theme/app_colors.dart';
import '../../services/social_auth_service.dart';
import '../../core/utils/logger.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_typography.dart';

class SocialAccountsSection extends StatefulWidget {
  final List<String>? linkedProviders;
  final String? primaryProvider;
  final Function(List<String>) onProvidersChanged;
  final SocialAuthService socialAuthService;
  
  const SocialAccountsSection({
    super.key,
    required this.linkedProviders,
    required this.primaryProvider,
    required this.onProvidersChanged,
    required this.socialAuthService});
  
  @override
  State<SocialAccountsSection> createState() => _SocialAccountsSectionState();
}

class _SocialAccountsSectionState extends State<SocialAccountsSection> {
  bool _isLinking = false;
  String? _linkingProvider;
  
  final Map<String, SocialProviderInfo> _providers = {
    'google': SocialProviderInfo(
      name: 'Google',
      iconType: SocialIconType.network,
      iconData: 'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
      color: const Color(0xFF4285F4)),
    'apple': SocialProviderInfo(
      name: 'Apple',
      iconType: SocialIconType.icon,
      iconData: Icons.apple,
      color: AppColors.textPrimary),
    'kakao': SocialProviderInfo(
      name: 'Kakao',
      iconType: SocialIconType.text,
      iconData: 'K',
      color: const Color(0xFFFEE500)),
    'naver': SocialProviderInfo(
      name: 'Naver',
      iconType: SocialIconType.text,
      iconData: 'N',
      color: const Color(0xFF03C75A))};
  
  bool _isProviderLinked(String provider) {
    return widget.linkedProviders?.contains(provider) ?? false;
  }
  
  Future<void> _linkProvider(String provider) async {
    setState(() {
      _isLinking = true;
      _linkingProvider = provider;
    });
    
    try {
      bool success = false;
      
      switch (provider) {
        case 'google':
          final result = await widget.socialAuthService.signInWithGoogle();
          success = result != null;
          break;
        case 'apple':
          final result = await widget.socialAuthService.signInWithApple();
          success = result != null;
          break;
        case 'kakao':
          await widget.socialAuthService.signInWithKakao();
          success = true;
          break;
        case 'naver':
          final result = await widget.socialAuthService.signInWithNaver();
          success = result != null;
          break;
      }
      
      if (success) {
        final updatedProviders = List<String>.from(widget.linkedProviders ?? []);
        if (!updatedProviders.contains(provider)) {
          updatedProviders.add(provider);
        }
        widget.onProvidersChanged(updatedProviders);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_providers[provider]?.name} 계정이 연결되었습니다.'),
              backgroundColor: AppColors.success));
        }
      }
    } catch (e) {
      Logger.error('Failed to link social account provider: $provider', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_providers[provider]?.name} 계정 연결에 실패했습니다.'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLinking = false;
          _linkingProvider = null;
        });
      }
    }
  }
  
  Future<void> _unlinkProvider(String provider) async {
    // Don't allow unlinking the primary provider
    if (provider == widget.primaryProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('기본 로그인 계정은 연결을 해제할 수 없습니다.'),
          backgroundColor: AppColors.warning));
      return;
    }
    
    // Confirm before unlinking
    final shouldUnlink = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_providers[provider]?.name} 연결 해제'),
        content: Text('${_providers[provider]?.name} 계정 연결을 해제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('연결 해제'))]));
    
    if (shouldUnlink != true) return;
    
    setState(() {
      _isLinking = true;
      _linkingProvider = provider;
    });
    
    try {
      // Call disconnect method based on provider
      switch (provider) {
        case 'google':
          await widget.socialAuthService.disconnectGoogle();
          break;
        case 'kakao':
          await widget.socialAuthService.disconnectKakao();
          break;
        case 'naver':
          await widget.socialAuthService.disconnectNaver();
          break;
      }
      
      final updatedProviders = List<String>.from(widget.linkedProviders ?? []);
      updatedProviders.remove(provider);
      widget.onProvidersChanged(updatedProviders);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_providers[provider]?.name} 계정 연결이 해제되었습니다.'),
            backgroundColor: AppColors.success));
      }
    } catch (e) {
      Logger.error('Failed to unlink social account provider: $provider', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_providers[provider]?.name} 계정 연결 해제에 실패했습니다.'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLinking = false;
          _linkingProvider = null;
        });
      }
    }
  }
  
  Widget _buildProviderButton(String provider) {
    final theme = Theme.of(context);
    final providerInfo = _providers[provider]!;
    final isLinked = _isProviderLinked(provider);
    final isPrimary = provider == widget.primaryProvider;
    final isProcessing = _isLinking && _linkingProvider == provider;
    
    return GlassContainer(
      padding: AppSpacing.paddingAll12,
      child: Row(
        children: [
          // Provider icon
          Container(
            width: AppDimensions.buttonHeightSmall,
            height: AppDimensions.buttonHeightSmall,
            decoration: BoxDecoration(
              color: providerInfo.color.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderRadiusSmall),
            child: Center(
              child: _buildProviderIcon(providerInfo))),
          SizedBox(width: AppSpacing.spacing3),
          
          // Provider name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerInfo.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600)),
                if (isLinked) ...[
                  SizedBox(height: AppSpacing.xxxSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success),
                      SizedBox(width: AppSpacing.spacing1),
                      Text(
                        isPrimary ? '기본 계정' : '연결됨',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.success))])]])),
          
          // Action button
          if (isProcessing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2))
          else if (isLinked && !isPrimary)
            IconButton(
              icon: const Icon(Icons.link_off, size: AppDimensions.iconSizeSmall),
              onPressed: () => _unlinkProvider(provider),
              tooltip: '연결 해제')
          else if (!isLinked)
            TextButton(
              onPressed: () => _linkProvider(provider),
              child: const Text('연결'))]));
  }
  
  Widget _buildProviderIcon(SocialProviderInfo providerInfo) {
    switch (providerInfo.iconType) {
      case SocialIconType.network:
        return Image.network(
          providerInfo.iconData as String,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.link,
              color: providerInfo.color,
              size: AppDimensions.iconSizeMedium);
          });
      case SocialIconType.icon:
        return Icon(
          providerInfo.iconData as IconData,
          size: AppDimensions.iconSizeMedium,
          color: providerInfo.iconType == SocialIconType.icon && providerInfo.name == 'Apple' 
              ? (Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimary)
              : providerInfo.color);
      case SocialIconType.text:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: providerInfo.color,
            shape: BoxShape.circle),
          child: Center(
            child: Text(
              providerInfo.iconData as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '소셜 계정 관리',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: AppSpacing.spacing2),
        Text(
          '여러 소셜 계정을 연결하여 편리하게 로그인하세요.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        SizedBox(height: AppSpacing.spacing4),
        ...(_providers.keys.map((provider) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
          child: _buildProviderButton(provider))).toList())]);
  }
}

enum SocialIconType {
  network,
  icon,
  text}

class SocialProviderInfo {
  final String name;
  final SocialIconType iconType;
  final dynamic iconData;
  final Color color;
  
  const SocialProviderInfo({
    required this.name,
    required this.iconType,
    required this.iconData,
    required this.color});
}