class ZodiacCalculator {
  static Map<String, String> getZodiac(int year) {
    const animals = [
      {'name': '원숭이', 'emoji': '🐵'},
      {'name': '닭', 'emoji': '🐓'},
      {'name': '개', 'emoji': '🐕'},
      {'name': '돼지', 'emoji': '🐷'},
      {'name': '쥐', 'emoji': '🐭'},
      {'name': '소', 'emoji': '🐮'},
      {'name': '호랑이', 'emoji': '🐯'},
      {'name': '토끼', 'emoji': '🐰'},
      {'name': '용', 'emoji': '🐲'},
      {'name': '뱀', 'emoji': '🐍'},
      {'name': '말', 'emoji': '🐴'},
      {'name': '양', 'emoji': '🐑'}];
    
    final zodiac = animals[year % 12];
    return {
      'name': zodiac['name']!,
      'emoji': zodiac['emoji']!};
  }
}