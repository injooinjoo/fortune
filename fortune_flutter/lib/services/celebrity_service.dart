import '../data/models/celebrity.dart';
import '../data/constants/celebrity_database_enhanced.dart';

class CelebrityService {
  static final CelebrityService _instance = CelebrityService._internal();
  factory CelebrityService() => _instance;
  CelebrityService._internal();

  // Get all celebrities
  List<Celebrity> getAllCelebrities() {
    return CelebrityDatabaseEnhanced.allCelebrities;
  }

  // Get celebrities by category
  List<Celebrity> getCelebritiesByCategory(CelebrityCategory category) {
    return CelebrityDatabaseEnhanced.allCelebrities
        .where((celebrity) => celebrity.category == category,
        .toList();
  }

  // Search celebrities with filters
  List<Celebrity> searchCelebrities(
    {
    String? query,
    CelebrityFilter? filter,
  )}) {
    var celebrities = CelebrityDatabaseEnhanced.allCelebrities;
    
    // Apply search query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      celebrities = celebrities.where((celebrity) {
        return celebrity.name.toLowerCase().contains(lowerQuery) ||
            celebrity.nameEn.toLowerCase().contains(lowerQuery) ||
            (celebrity.keywords?.any((k) => k.toLowerCase().contains(lowerQuery)) ?? false);
      }).toList();
    }
    
    // Apply filters
    if (filter != null) {
      if (filter.category != null) {
        celebrities = celebrities.where((c) => c.category == filter.category).toList();
      }
      if (filter.gender != null) {
        celebrities = celebrities.where((c) => c.gender == filter.gender).toList();
      }
      if (filter.minAge != null) {
        celebrities = celebrities.where((c) => c.age >= filter.minAge!).toList();
      }
      if (filter.maxAge != null) {
        celebrities = celebrities.where((c) => c.age <= filter.maxAge!).toList();
      }
    }
    
    return celebrities;
  }

  // Get celebrity by ID
  Celebrity? getCelebrityById(String id) {
    try {
      return CelebrityDatabaseEnhanced.allCelebrities.firstWhere(
        (celebrity) => celebrity.id == id
      );
    } catch (e) {
      return null;
    }
  }

  // Get random celebrities
  List<Celebrity> getRandomCelebrities(
    {
    int count = 10,
    CelebrityCategory? category,
  )}) {
    var celebrities = category != null
        ? getCelebritiesByCategory(category)
        : CelebrityDatabaseEnhanced.allCelebrities;
    
    celebrities.shuffle();
    return celebrities.take(count).toList();
  }

  // Get celebrities with same birthday
  List<Celebrity> getCelebritiesWithBirthday(DateTime date) {
    return CelebrityDatabaseEnhanced.allCelebrities.where((celebrity) {
      return celebrity.birthDate.month == date.month &&
          celebrity.birthDate.day == date.day;
    }).toList();
  }

  // Get celebrities by zodiac sign
  List<Celebrity> getCelebritiesByZodiac(String zodiacSign) {
    return CelebrityDatabaseEnhanced.allCelebrities
        .where((celebrity) => celebrity.zodiacSign == zodiacSign,
        .toList();
  }

  // Get celebrities by Chinese zodiac
  List<Celebrity> getCelebritiesByChineseZodiac(String chineseZodiac) {
    return CelebrityDatabaseEnhanced.allCelebrities
        .where((celebrity) => celebrity.chineseZodiac == chineseZodiac,
        .toList();
  }

  // Get celebrity suggestions for autocomplete
  List<Celebrity> getSuggestions(String query, {int limit = 10}) {
    if (query.isEmpty) return [];
    
    final results = searchCelebrities(query: query);
    return results.take(limit).toList();
  }

  // Get popular celebrities by category
  List<Celebrity> getPopularCelebrities(
    {
    CelebrityCategory? category,
    int limit = 10,
  )}) {
    final celebrities = category != null 
        ? getCelebritiesByCategory(category)
        : getAllCelebrities();
    
    // For now, just return the first N celebrities
    // In a real app, this could be based on popularity metrics
    return celebrities.take(limit).toList();
  }

  // Get celebrity match score (for compatibility features,
  double calculateMatchScore(Celebrity celebrity1, Celebrity celebrity2) {
    double score = 0.0;
    
    // Same zodiac sign
    if (celebrity1.zodiacSign == celebrity2.zodiacSign) {
      score += 0.2;
    }
    
    // Same Chinese zodiac
    if (celebrity1.chineseZodiac == celebrity2.chineseZodiac) {
      score += 0.15;
    }
    
    // Similar age (within 5 years,
    final ageDiff = (celebrity1.age - celebrity2.age).abs();
    if (ageDiff <= 5) {
      score += 0.15;
    } else if (ageDiff <= 10) {
      score += 0.1;
    }
    
    // Same category
    if (celebrity1.category == celebrity2.category) {
      score += 0.2;
    }
    
    // Same gender
    if (celebrity1.gender == celebrity2.gender) {
      score += 0.1;
    }
    
    // Birth month compatibility
    final monthDiff = (celebrity1.birthDate.month - celebrity2.birthDate.month).abs();
    if (monthDiff == 0) {
      score += 0.1;
    } else if (monthDiff <= 2 || monthDiff >= 10) {
      score += 0.05;
    }
    
    // Add some randomness for fun
    score += (DateTime.now().millisecond % 20) / 100.0;
    
    return score.clamp(0.0, 1.0);
  }

  // Get celebrity statistics
  Map<String, dynamic> getCelebrityStatistics() {
    final allCelebrities = getAllCelebrities();
    final stats = <String, dynamic>{};
    
    // Total count
    stats['total'] = allCelebrities.length;
    
    // Count by category
    stats['byCategory'] = <String, int>{};
    for (final category in CelebrityCategory.values) {
      stats['byCategory'][category.displayName] = 
          getCelebritiesByCategory(category).length;
    }
    
    // Count by gender
    stats['byGender'] = <String, int>{};
    for (final gender in Gender.values) {
      stats['byGender'][gender.displayName] = 
          allCelebrities.where((c) => c.gender == gender).length;
    }
    
    // Age statistics
    final ages = allCelebrities.map((c) => c.age).toList();
    stats['ageStats'] = {
      'min': ages.reduce((a, b) => a < b ? a : b),
      'max': ages.reduce((a, b) => a > b ? a : b),
      'average': ages.reduce((a, b) => a + b) ~/ ages.length,
    };
    
    // Zodiac distribution
    stats['byZodiac'] = <String, int>{};
    final zodiacSigns = ['양자리', '황소자리', '쌍둥이자리', '게자리', '사자자리', 
                        '처녀자리', '천칭자리', '전갈자리', '사수자리', 
                        '염소자리', '물병자리', '물고기자리'];
    for (final sign in zodiacSigns) {
      stats['byZodiac'][sign] = getCelebritiesByZodiac(sign).length;
    }
    
    return stats;
  }
}