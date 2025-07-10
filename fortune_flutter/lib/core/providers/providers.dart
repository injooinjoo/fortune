import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});