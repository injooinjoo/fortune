import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/services/fortune_batch_service.dart';
import '../providers/batch_fortune_provider.dart';
import '../widgets/batch_fortune_package_card.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';

/// 배치 운세 페이지 - 여러 운세를 한 번에 받을 수 있는 통합 페이지
class BatchFortunePage extends ConsumerStatefulWidget {
  const BatchFortunePage({super.key});

  @override
  ConsumerState<BatchFortunePage> createState() => _BatchFortunePageState();
}

class _BatchFortunePageState extends ConsumerState<BatchFortunePage> {
  BatchPackageType? selectedPackage;

  @override
  Widget build(BuildContext context) {
    final batchState = ref.watch(batchFortuneProvider);
    final tokenBalanceObj = ref.watch(tokenBalanceProvider);
    final tokenBalance = tokenBalanceObj?.balance ?? 0;
    final isAuthenticated = ref.watch(authStateProvider).value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('운세 패키지'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더 섹션
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '여러 운세를 한 번에!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text(
                    '패키지로 구매하면 최대 50% 토큰 절약',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70)),
                  const SizedBox(height: 16),
                  // 토큰 잔액 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.toll,
                              color: Colors.white,
                              size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              '보유 토큰',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14))]),
                        Text(
                          isAuthenticated 
                              ? '${tokenBalance}개'
                              : '로그인 필요',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)])]),

            // 패키지 리스트
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '운세 패키지 선택',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // 패키지 카드들
                  ...BatchPackageType.values.map((packageType) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BatchFortunePackageCard(
                        packageType: packageType,
                        onTap: () => _onPackageSelected(packageType));
                  }).toList()),

            // 생성된 운세 결과
            if (batchState.results != null && batchState.results!.isNotEmpty) ...[
              const Divider(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '생성된 운세',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            ref.read(batchFortuneProvider.notifier).clearResults();
                          },
                          child: const Text('초기화'))]),
                    const SizedBox(height: 16),
                    const BatchFortuneResultsList()]))]]));
  }

  void _onPackageSelected(BatchPackageType packageType) async {
    final tokenBalanceObj = ref.read(tokenBalanceProvider);
    final tokenBalance = tokenBalanceObj?.balance ?? 0;
    final isAuthenticated = ref.read(authStateProvider).value != null;

    // 인증 확인
    if (!isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    // 토큰 잔액 확인
    if (tokenBalance < packageType.tokenCost) {
      _showInsufficientTokensDialog(packageType.tokenCost - tokenBalance);
      return;
    }

    // 패키지 선택 확인
    final confirmed = await _showConfirmationDialog(packageType);
    if (confirmed == true) {
      ref.read(batchFortuneProvider.notifier).generatePackageFortunes(packageType);
    }
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 필요'),
        content: const Text('운세 패키지를 이용하시려면 로그인이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/signup');
            },
            child: const Text('로그인')]);
  }

  void _showInsufficientTokensDialog(int shortage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('토큰 부족'),
        content: Text('토큰이 $shortage개 부족합니다. 충전하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/payment/tokens');
            },
            child: const Text('토큰 충전'))]
      )
    );
  }

  Future<bool?> _showConfirmationDialog(BatchPackageType packageType) {
    final fortuneService = ref.read(fortuneBatchServiceProvider);
    final savings = fortuneService.calculateTokenSavings(packageType);
    final fortuneTypes = fortuneService.getPackageFortuneTypes(packageType);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(packageType.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${fortuneTypes.length}개의 운세를 한 번에 받으실 수 있습니다.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  const Icon(
                    Icons.savings,
                    color: Colors.green,
                    size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${packageType.tokenCost} 토큰으로 ${savings.toStringAsFixed(0)}% 절약!',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold)]),
            const SizedBox(height: 16),
            const Text(
              '운세:',
              style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...fortuneTypes.map((type) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(_getFortuneTypeName(type)])]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('${packageType.tokenCost} 토큰 사용'))]
      )
    );
  }

  String _getFortuneTypeName(String type) {
    final nameMap = {
      'daily': '오늘의 운세': 'tomorrow': '내일의 운세': 'weekly': '주간 운세': 'monthly': '월간 운세': 'yearly': '연간 운세': 'saju': '사주팔자': 'love': '연애운': 'career': '직업운': 'wealth': '재물운': 'health': '건강운': 'personality': '성격 운세': 'talent': '재능 운세': 'biorhythm': '바이오리듬': 'lucky-color': '행운의 색': 'lucky-number': '행운의 숫자': 'lucky-items': '행운의 아이템': 'lucky-food': '행운의 음식': 'lucky-outfit': '행운의 의상': 'blind-date': '소개팅운': 'marriage': '결혼운': 'chemistry': '케미스트리': 'couple-match': '커플 매칭': 'business': '사업운': 'investment': '투자운': 'destiny': '운명': 'past-life': '전생'
    };
    return nameMap[type] ?? type;
  }
}