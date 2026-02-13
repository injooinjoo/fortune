import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/history/domain/models/fortune_history.dart';

final fortuneHistoryProvider = StateNotifierProvider<FortuneHistoryNotifier,
    AsyncValue<List<FortuneHistory>>>((ref) {
  return FortuneHistoryNotifier();
});

class FortuneHistoryNotifier
    extends StateNotifier<AsyncValue<List<FortuneHistory>>> {
  FortuneHistoryNotifier() : super(const AsyncValue.data([]));

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final response = await supabase
          .from('fortune_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      final history = (response as List)
          .map((json) => FortuneHistory.fromJson(json))
          .toList();

      state = AsyncValue.data(history);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteHistory(String id) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.from('fortune_history').delete().eq('id', id);

      // Reload history
      await loadHistory();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
