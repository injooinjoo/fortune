import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  // User data
  String? _userId;
  String? _email;
  String? _name;
  DateTime? _birthDate;
  String? _birthTime;
  bool _isLunar = false;
  String? _mbti;
  Map<String, dynamic>? _userProfile;

  // Token data
  int _tokenBalance = 0;
  bool _isPremium = false;

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;
  DateTime? get birthDate => _birthDate;
  String? get birthTime => _birthTime;
  bool get isLunar => _isLunar;
  String? get mbti => _mbti;
  Map<String, dynamic>? get userProfile => _userProfile;
  int get tokenBalance => _tokenBalance;
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userId != null;

  // Setters
  void setUser(
      {String? userId,
      String? email,
      String? name,
      DateTime? birthDate,
      String? birthTime,
      bool? isLunar,
      String? mbti,
      Map<String, dynamic>? userProfile}) {
    _userId = userId ?? _userId;
    _email = email ?? _email;
    _name = name ?? _name;
    _birthDate = birthDate ?? _birthDate;
    _birthTime = birthTime ?? _birthTime;
    _isLunar = isLunar ?? _isLunar;
    _mbti = mbti ?? _mbti;
    _userProfile = userProfile ?? _userProfile;
    notifyListeners();
  }

  void setTokenBalance(int balance) {
    _tokenBalance = balance;
    notifyListeners();
  }

  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Methods
  void updateProfile(Map<String, dynamic> profileData) {
    _userProfile = profileData;
    _name = profileData['name'] ?? _name;
    _mbti = profileData['mbti'] ?? _mbti;

    if (profileData['birthDate'] != null) {
      _birthDate = DateTime.tryParse(profileData['birthDate']);
    }
    if (profileData['birthTime'] != null) {
      _birthTime = profileData['birthTime'];
    }
    if (profileData['isLunar'] != null) {
      _isLunar = profileData['isLunar'];
    }

    notifyListeners();
  }

  void useTokens(int amount) {
    if (_tokenBalance >= amount) {
      _tokenBalance -= amount;
      notifyListeners();
    }
  }

  void addTokens(int amount) {
    _tokenBalance += amount;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _email = null;
    _name = null;
    _birthDate = null;
    _birthTime = null;
    _isLunar = false;
    _mbti = null;
    _userProfile = null;
    _tokenBalance = 0;
    _isPremium = false;
    _error = null;
    notifyListeners();
  }

  // Helper methods
  bool get hasCompleteProfile {
    return _name != null && _birthDate != null && _birthTime != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': _userId,
      'email': _email,
      'name': _name,
      'birthDate': _birthDate?.toIso8601String(),
      'birthTime': _birthTime,
      'isLunar': _isLunar,
      'mbti': _mbti,
      'tokenBalance': _tokenBalance,
      'isPremium': null
    };
  }
}
