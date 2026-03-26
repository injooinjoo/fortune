class UnifiedOnboardingProgress {
  final bool softGateCompleted;
  final bool authCompleted;
  final bool birthCompleted;
  final bool interestCompleted;
  final bool firstRunHandoffSeen;

  const UnifiedOnboardingProgress({
    this.softGateCompleted = false,
    this.authCompleted = false,
    this.birthCompleted = false,
    this.interestCompleted = false,
    this.firstRunHandoffSeen = false,
  });

  static const empty = UnifiedOnboardingProgress();

  bool get requiresAuthenticatedProfileFlow =>
      authCompleted && (!birthCompleted || !interestCompleted);

  bool get isFullyCompleted =>
      authCompleted &&
      birthCompleted &&
      interestCompleted &&
      firstRunHandoffSeen;

  UnifiedOnboardingProgress copyWith({
    bool? softGateCompleted,
    bool? authCompleted,
    bool? birthCompleted,
    bool? interestCompleted,
    bool? firstRunHandoffSeen,
  }) {
    return UnifiedOnboardingProgress(
      softGateCompleted: softGateCompleted ?? this.softGateCompleted,
      authCompleted: authCompleted ?? this.authCompleted,
      birthCompleted: birthCompleted ?? this.birthCompleted,
      interestCompleted: interestCompleted ?? this.interestCompleted,
      firstRunHandoffSeen: firstRunHandoffSeen ?? this.firstRunHandoffSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'softGateCompleted': softGateCompleted,
      'authCompleted': authCompleted,
      'birthCompleted': birthCompleted,
      'interestCompleted': interestCompleted,
      'firstRunHandoffSeen': firstRunHandoffSeen,
    };
  }

  factory UnifiedOnboardingProgress.fromJson(Map<String, dynamic> json) {
    return UnifiedOnboardingProgress(
      softGateCompleted: json['softGateCompleted'] == true,
      authCompleted: json['authCompleted'] == true,
      birthCompleted: json['birthCompleted'] == true,
      interestCompleted: json['interestCompleted'] == true,
      firstRunHandoffSeen: json['firstRunHandoffSeen'] == true,
    );
  }
}
