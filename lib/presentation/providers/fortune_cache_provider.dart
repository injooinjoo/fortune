import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to fetch fortune scores from fortune_cache table for the last 7 days
final fortuneCacheScoresProvider = FutureProvider.family<List<int>, int?>((ref, currentScore) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) {
    return List.generate(7, (_) => 0);
  }
  
  final scores = <int>[];
  final today = DateTime.now();
  
  try {
    debugPrint('📊 fortuneCacheScoresProvider: Fetching scores for last 7 days for user: $userId');
    // Get scores for last 7 days
    for (int i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final dateKey = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      
      int dayScore = 0; // No data = 0
      
      if (i == 0) {
        // Today's score
        dayScore = currentScore ?? 0;
      } else {
        // Try to get from fortune_cache
        try {
          debugPrint('🔍 Querying fortune_cache for date: $dateKey');
          final response = await supabase
              .from('fortune_cache')
              .select('fortune_data')
              .eq('user_id', userId)
              .eq('fortune_type', 'daily')
              .eq('fortune_date', dateKey)
              .maybeSingle();
          
          if (response != null && response['fortune_data'] != null) {
            final fortuneData = response['fortune_data'] as Map<String, dynamic>;
            
            // Try to get score from metadata.categories.total.score
            if (fortuneData['metadata'] != null) {
              final metadata = fortuneData['metadata'] as Map<String, dynamic>;
              final categories = metadata['categories'] as Map<String, dynamic>?;
              if (categories != null && categories['total'] != null) {
                final total = categories['total'] as Map<String, dynamic>;
                if (total['score'] != null) {
                  dayScore = total['score'] as int;
                  debugPrint('✅ Found score for $dateKey in fortune_cache: $dayScore');
                }
              }
            }
            
            // Fallback to overallScore
            if (dayScore == 0 && fortuneData['overallScore'] != null) {
              dayScore = fortuneData['overallScore'] as int;
              debugPrint('✅ Found score from overallScore for $dateKey: $dayScore');
            }
          } else {
            debugPrint('❌ No data found in fortune_cache for date: $dateKey');
          }
        } catch (e) {
          debugPrint('Error fetching score for $dateKey: $e');
        }
      }
      
      scores.add(dayScore);
    }
    
    debugPrint('📊 Final scores from fortune_cache: $scores');
    return scores;
  } catch (e) {
    debugPrint('Error in fortuneCacheScoresProvider: $e');
    return List.generate(7, (_) => 0);
  }
});