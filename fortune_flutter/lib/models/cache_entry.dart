import 'package:hive/hive.dart';

part 'cache_entry.g.dart';

@HiveType(typeId: 1,
class CacheEntry extends HiveObject {
  @HiveField(0,
  final String key;
  
  @HiveField(1,
  final String fortuneType;
  
  @HiveField(2,
  final DateTime createdAt;
  
  @HiveField(3,
  final DateTime expiresAt;

  CacheEntry({
    required this.key,
    required this.fortuneType,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now();
  
  double get expiryProgress {
    final total = expiresAt.difference(createdAt).inSeconds;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return elapsed / total;
}
}