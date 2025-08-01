import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/fortune_metadata.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/widgets/fortune_card.dart';
import '../../../../presentation/widgets/fortune_explanation_bottom_sheet.dart';
import '../../../../data/models/fortune_response_model.dart';
import '../widgets/fortune_content_card.dart';
import '../../../payment/presentation/pages/token_purchase_page.dart';

/// Dynamic fortune page that handles all fortune types
class DynamicFortunePage extends ConsumerStatefulWidget {
  final FortuneType fortuneType;
  
  const DynamicFortunePage({
    super.key,
    required this.fortuneType,
  });

  @override
  ConsumerState<DynamicFortunePage> createState() => _DynamicFortunePageState();
}

class _DynamicFortunePageState extends ConsumerState<DynamicFortunePage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  bool _isLoading = false;
  FortuneResponseModel? _fortuneResult;
  String? _errorMessage;
  
  FortuneMetadata get metadata => FortuneMetadataRepository.getMetadataOrDefault(widget.fortuneType);

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this)
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0)
      end: 1.0)
    ).animate(CurvedAnimation(
      parent: _animationController)
      curve: Curves.easeIn)
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0)
      end: 0.0)
    ).animate(CurvedAnimation(
      parent: _animationController)
      curve: Curves.easeOutBack)
    ));
    
    _animationController.forward();
    
    // Check if we have cached fortune
    _checkCachedFortune();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkCachedFortune() async {
    final cachedFortune = await ref.read(fortuneProvider.notifier,
        .getCachedFortune(widget.fortuneType.key);
    
    if (cachedFortune != null) {
      setState(() {
        _fortuneResult = cachedFortune;
      });
    }
  }

  Future<void> _generateFortune() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check token balance
      final tokenBalance = ref.read(tokenBalanceProvider);
      if (tokenBalance < metadata.tokenCost) {
        _showInsufficientTokensDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Generate fortune
      final result = await ref.read(fortuneProvider.notifier,
          .generateFortune(widget.fortuneType.key);
      
      setState(() {
        _fortuneResult = result;
        _isLoading = false;
      });
      
      // Deduct tokens
      if (metadata.tokenCost > 0) {
        await ref.read(tokenProvider.notifier).useTokens(metadata.tokenCost);
      }
      
      // Animate result
      _animationController.reset();
      _animationController.forward();
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showInsufficientTokensDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('토큰 부족'))
        content: Text(
          '이 운세를 보려면 ${metadata.tokenCost}개의 토큰이 필요합니다.\n'
          '현재 보유 토큰이 부족합니다.',
        ))
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop())
            child: const Text('취소'))
          ))
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/token-purchase');
            })
            child: const Text('토큰 구매'),
          ))
        ])
      ),
    );
  }

  void _showExplanation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true)
      backgroundColor: Colors.transparent)
      builder: (context) => FortuneExplanationBottomSheet(
        fortuneType: widget.fortuneType.key)
        title: metadata.title)
        description: metadata.description)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokenBalance = ref.watch(tokenBalanceProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent)
        elevation: 0)
        title: Text(
          metadata.title)
          style: const TextStyle(fontWeight: FontWeight.bold))
        ))
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline))
            onPressed: _showExplanation)
          ))
        ])
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft)
            end: Alignment.bottomRight)
            colors: [
              metadata.primaryColor.withValues(alpha: 0.1))
              metadata.secondaryColor.withValues(alpha: 0.05))
              theme.scaffoldBackgroundColor)
            ])
          ),
        ))
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0))
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch)
              children: [
                // Header Card
                FadeTransition(
                  opacity: _fadeAnimation)
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value))
                    child: _buildHeaderCard())
                  ))
                ))
                
                const SizedBox(height: 24))
                
                // Result or Generate Button
                if (_fortuneResult != null)
                  FadeTransition(
                    opacity: _fadeAnimation)
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value))
                      child: _buildResultContent())
                    ))
                  )
                else
                  _buildGenerateSection())
                  
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0))
                    child: Card(
                      color: theme.colorScheme.errorContainer)
                      child: Padding(
                        padding: const EdgeInsets.all(12.0))
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline)
                              color: theme.colorScheme.onErrorContainer)
                            ))
                            const SizedBox(width: 8))
                            Expanded(
                              child: Text(
                                _errorMessage!)
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer)
                                ))
                              ))
                            ))
                          ])
                        ),
                      ))
                    ))
                  ))
              ])
            ),
          ))
        ))
      )
    );
  }

  Widget _buildHeaderCard() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20))
      ))
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20))
          gradient: LinearGradient(
            begin: Alignment.topLeft)
            end: Alignment.bottomRight)
            colors: [
              metadata.primaryColor)
              metadata.secondaryColor)
            ])
          ),
        ))
        padding: const EdgeInsets.all(24.0))
        child: Column(
          children: [
            Container(
              width: 80)
              height: 80)
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2))
                shape: BoxShape.circle)
              ))
              child: Icon(
                metadata.icon)
                size: 48)
                color: Colors.white)
              ))
            ))
            const SizedBox(height: 16))
            Text(
              metadata.title)
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white)
                fontWeight: FontWeight.bold)
              ))
            ))
            const SizedBox(height: 8))
            Text(
              metadata.subtitle)
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9))
              ))
              textAlign: TextAlign.center)
            ))
            if (metadata.tokenCost > 0) ...[
              const SizedBox(height: 16))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8))
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2))
                  borderRadius: BorderRadius.circular(20))
                ))
                child: Row(
                  mainAxisSize: MainAxisSize.min)
                  children: [
                    const Icon(
                      Icons.toll)
                      size: 16)
                      color: Colors.white)
                    ))
                    const SizedBox(width: 4))
                    Text(
                      '${metadata.tokenCost} 토큰')
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)
                      ))
                    ))
                  ])
                ),
              ))
            ])
          ],
        ))
      ))
    );
  }

  Widget _buildGenerateSection() {
    final theme = Theme.of(context);
    final tokenBalance = ref.watch(tokenBalanceProvider);
    final hasEnoughTokens = tokenBalance >= metadata.tokenCost;
    
    return Column(
      children: [
        if (!hasEnoughTokens,
          Card(
            color: theme.colorScheme.errorContainer)
            child: Padding(
              padding: const EdgeInsets.all(16.0))
              child: Row(
                children: [
                  Icon(
                    Icons.warning)
                    color: theme.colorScheme.onErrorContainer)
                  ))
                  const SizedBox(width: 12))
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start)
                      children: [
                        Text(
                          '토큰이 부족합니다')
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer)
                            fontWeight: FontWeight.bold)
                          ))
                        ))
                        Text(
                          '필요: ${metadata.tokenCost}개 / 보유: $tokenBalance개',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer)
                            fontSize: 12)
                          ))
                        ))
                      ])
                    ),
                  ))
                ])
              ),
            ))
          ))
        
        const SizedBox(height: 24))
        
        SizedBox(
          width: double.infinity)
          height: 56)
          child: ElevatedButton(
            onPressed: _isLoading || !hasEnoughTokens ? null : _generateFortune)
            style: ElevatedButton.styleFrom(
              backgroundColor: metadata.primaryColor)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))
              ))
            ))
            child: _isLoading
                ? const SizedBox(
                    width: 24)
                    height: 24)
                    child: CircularProgressIndicator(
                      strokeWidth: 2)
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    ))
                  )
                : Text(
                    hasEnoughTokens ? '운세 보기' : '토큰 구매하기')
                    style: const TextStyle(
                      fontSize: 18)
                      fontWeight: FontWeight.bold)
                    ))
                  ))
          ))
        ))
      ])
    );
  }

  Widget _buildResultContent() {
    if (_fortuneResult == null) return const SizedBox.shrink();
    
    return FortuneContentCard(
      fortune: _fortuneResult!,
      primaryColor: metadata.primaryColor)
      secondaryColor: metadata.secondaryColor)
      onRefresh: metadata.tokenCost == 0 ? _generateFortune : null
    );
  }
}