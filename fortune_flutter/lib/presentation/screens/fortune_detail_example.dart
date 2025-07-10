import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/fortune_api_service.dart';
import '../../domain/entities/fortune.dart';
import '../widgets/offline_indicator.dart';
import '../../core/errors/exceptions.dart';

// Example screen showing how to use cached fortune service
class FortuneDetailScreen extends ConsumerStatefulWidget {
  final String fortuneType;
  final String userId;

  const FortuneDetailScreen({
    super.key,
    required this.fortuneType,
    required this.userId,
  });

  @override
  ConsumerState<FortuneDetailScreen> createState() => _FortuneDetailScreenState();
}

class _FortuneDetailScreenState extends ConsumerState<FortuneDetailScreen> {
  Fortune? _fortune;
  bool _isLoading = true;
  bool _isOffline = false;
  String? _error;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _loadFortune();
  }

  Future<void> _loadFortune() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(fortuneApiServiceProvider);
      
      // Check if we're in offline mode
      _isOffline = await apiService.isOfflineMode();
      
      // Try to get fortune (will use cache if available)
      final fortune = await apiService.getFortune(
        fortuneType: widget.fortuneType,
        userId: widget.userId,
        params: {},
      );

      setState(() {
        _fortune = fortune;
        _lastSyncTime = DateTime.now();
      });
    } on NetworkException catch (e) {
      // Network error occurred, try to get from cache
      final apiService = ref.read(fortuneApiServiceProvider);
      final cachedFortune = await apiService.getMostRecentCachedFortune(
        widget.fortuneType,
        widget.userId,
      );

      if (cachedFortune != null) {
        setState(() {
          _fortune = cachedFortune;
          _isOffline = true;
          _error = '오프라인 모드: 캐시된 운세를 표시합니다';
        });
      } else {
        setState(() {
          _error = e.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshFortune() async {
    await _loadFortune();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getFortuneTitle(widget.fortuneType)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshFortune,
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator
          OfflineIndicator(
            isOffline: _isOffline,
            lastSyncTime: _lastSyncTime,
          ),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _fortune == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshFortune,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_fortune == null) {
      return const Center(
        child: Text('운세를 찾을 수 없습니다'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFortune,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Fortune content
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getFortuneIcon(widget.fortuneType),
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFortuneTitle(widget.fortuneType),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '생성일: ${_formatDate(_fortune!.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      _fortune!.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    
                    // Additional metadata if available
                    if (_fortune!.metadata != null) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      ..._buildMetadata(_fortune!.metadata!),
                    ],
                  ],
                ),
              ),
            ),
            
            // Token cost info
            const SizedBox(height: 16),
            Center(
              child: Text(
                '이 운세는 ${_fortune!.tokenCost} 토큰을 사용했습니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetadata(Map<String, dynamic> metadata) {
    return metadata.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key}: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: Text(
                entry.value.toString(),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getFortuneTitle(String type) {
    final titles = {
      'daily': '오늘의 운세',
      'weekly': '주간 운세',
      'monthly': '월간 운세',
      'yearly': '연간 운세',
      'love': '연애운',
      'career': '직업운',
      'wealth': '재물운',
      'health': '건강운',
      'saju': '사주',
      'zodiac': '띠 운세',
      'personality': '성격 운세',
    };
    return titles[type] ?? type;
  }

  IconData _getFortuneIcon(String type) {
    final icons = {
      'daily': Icons.today,
      'weekly': Icons.date_range,
      'monthly': Icons.calendar_month,
      'yearly': Icons.calendar_today,
      'love': Icons.favorite,
      'career': Icons.work,
      'wealth': Icons.attach_money,
      'health': Icons.favorite_border,
      'saju': Icons.stars,
      'zodiac': Icons.pets,
      'personality': Icons.person,
    };
    return icons[type] ?? Icons.auto_awesome;
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}