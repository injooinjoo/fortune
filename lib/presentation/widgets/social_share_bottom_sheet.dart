import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_colors.dart';

class SocialShareBottomSheet extends ConsumerStatefulWidget {
  final String fortuneTitle;
  final String fortuneContent;
  final String? userName;
  final Uint8List? previewImage;
  final Function(SharePlatform platform) onShare;

  const SocialShareBottomSheet({
    super.key,
    required this.fortuneTitle,
    required this.fortuneContent,
    this.userName,
    this.previewImage,
    required this.onShare});

  @override
  ConsumerState<SocialShareBottomSheet> createState() => _SocialShareBottomSheetState();
}

class _SocialShareBottomSheetState extends ConsumerState<SocialShareBottomSheet> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this);
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5))]),
          child: Transform.translate(
            offset: Offset(0, size.height * 0.75 * _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  _buildHandle(),
                  _buildHeader(theme),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing5),
                      child: Column(
                        children: [
                          _buildPreview(theme),
                          SizedBox(height: AppSpacing.spacing6),
                          _buildShareOptions(theme),
                          SizedBox(height: AppSpacing.spacing5),
                          _buildSaveOptions(theme),
                          SizedBox(height: AppSpacing.spacing10)]))]));
      });
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.small),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall)));
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: AppSpacing.paddingAll20,
      child: Row(
        children: [
          Icon(
            Icons.screenshot_outlined,
            color: theme.primaryColor,
            size: AppDimensions.iconSizeLarge),
          SizedBox(width: AppSpacing.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '스크린샷 감지됨',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold)),
                SizedBox(height: AppSpacing.spacing1),
                Text(
                  '운세를 친구들과 공유해보세요!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary)]),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero)]));
  }

  Widget _buildPreview(ThemeData theme) {
    if (widget.previewImage == null) {
      return const SizedBox();
    }

    return GlassContainer(
      borderRadius: AppDimensions.borderRadiusLarge,
      padding: AppSpacing.paddingAll12,
      child: Column(
        children: [
          Text(
            '미리보기',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600)),
          SizedBox(height: AppSpacing.spacing3),
          ClipRRect(
            borderRadius: AppDimensions.borderRadiusMedium,
            child: Image.memory(
              widget.previewImage!,
              height: 200,
              fit: BoxFit.cover)]);
  }

  Widget _buildShareOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SNS로 공유하기',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: AppSpacing.spacing4),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildShareButton(
              platform: SharePlatform.kakaoTalk,
              label: '카카오톡',
              icon: Icons.chat_bubble,
              color: const Color(0xFFFEE500),
              iconColor: AppColors.textPrimary.withOpacity(0.87)),
            _buildShareButton(
              platform: SharePlatform.instagram,
              label: '인스타그램',
              icon: Icons.camera_alt,
              gradient: const LinearGradient(
                colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFCAF45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
            _buildShareButton(
              platform: SharePlatform.facebook,
              label: '페이스북',
              icon: Icons.facebook,
              color: const Color(0xFF1877F2)),
            _buildShareButton(
              platform: SharePlatform.twitter,
              label: 'X (트위터)',
              icon: Icons.tag,
              color: AppColors.textPrimary),
            _buildShareButton(
              platform: SharePlatform.whatsapp,
              label: 'WhatsApp',
              icon: Icons.message,
              color: const Color(0xFF25D366)),
            _buildShareButton(
              platform: SharePlatform.other,
              label: '더보기',
              icon: Icons.more_horiz,
              color: AppColors.textSecondary)])]);
  }

  Widget _buildShareButton({
    required SharePlatform platform,
    required String label,
    required IconData icon,
    Color? color,
    Color? iconColor,
    Gradient? gradient}) {
    return InkWell(
      onTap: () {
        widget.onShare(platform);
        Navigator.of(context).pop();
      },
      borderRadius: AppDimensions.borderRadiusMedium,
      child: Container(
        width: AppSpacing.spacing24 * 1.04,
        padding: AppSpacing.paddingVertical16,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: AppDimensions.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: (color ?? AppColors.textSecondary).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.textPrimaryDark,
              size: AppDimensions.iconSizeXLarge),
            SizedBox(height: AppSpacing.spacing2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall)])));
  }

  Widget _buildSaveOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '저장 옵션',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        SizedBox(height: AppSpacing.spacing4),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                onTap: () {
                  widget.onShare(SharePlatform.gallery);
                  Navigator.of(context).pop();
                },
                icon: Icons.download_outlined,
                label: '갤러리에 저장',
                color: theme.primaryColor)),
            SizedBox(width: AppSpacing.spacing3),
            Expanded(
              child: _buildActionButton(
                onTap: () {
                  widget.onShare(SharePlatform.copy);
                  Navigator.of(context).pop();
                },
                icon: Icons.copy_outlined,
                label: '텍스트 복사',
                color: AppColors.textSecondary))])]);
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color}) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: AppDimensions.borderRadiusMedium,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusMedium,
        child: Container(
          padding: AppSpacing.paddingVertical16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Icon(icon, color: color, size: AppDimensions.iconSizeSmall),
              SizedBox(width: AppSpacing.spacing2),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color)]));
  }
}

enum SharePlatform {
  
  
  kakaoTalk,
  instagram,
  facebook,
  twitter,
  whatsapp,
  gallery,
  copy,
  other}