import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Dream analysis state model
class DreamAnalysisState {
  // Step 1: Dream content and questions
  final String dreamContent;
  final String inputType; // 'text' or 'voice'
  final Map<String, String> guidingQuestions;
  
  // Step 2: Symbols
  final Map<String, List<DreamSymbol>> extractedSymbols;
  final List<DreamSymbol> userSelectedSymbols;
  
  // Step 3: Emotions
  final List<DreamEmotion> emotions;
  final Map<String, double> emotionIntensities;
  
  // Step 4: Reality connections
  final List<RecentLifeEvent> recentEvents;
  final Map<String, String> dreamRealityConnections;
  
  // Step 5: Interpretation
  final String? mainMessage;
  final String? psychologicalInsight;
  final String? jungianInterpretation;
  
  // Step 6: Advice
  final List<String> advice;
  final List<DreamRitual> suggestedRituals;
  
  // Navigation
  final int currentStep;
  final bool isLoading;
  final String? error;

  const DreamAnalysisState({
    this.dreamContent = '',
    this.inputType = 'text',
    this.guidingQuestions = const {},
    this.extractedSymbols = const {},
    this.userSelectedSymbols = const [],
    this.emotions = const [],
    this.emotionIntensities = const {},
    this.recentEvents = const [],
    this.dreamRealityConnections = const {},
    this.mainMessage,
    this.psychologicalInsight,
    this.jungianInterpretation)
    this.advice = const [],
    this.suggestedRituals = const [],
    this.currentStep = 0,
    this.isLoading = false)
    this.error,
  });

  DreamAnalysisState copyWith({
    String? dreamContent,
    String? inputType)
    Map<String, String>? guidingQuestions)
    Map<String, List<DreamSymbol>>? extractedSymbols)
    List<DreamSymbol>? userSelectedSymbols)
    List<DreamEmotion>? emotions)
    Map<String, double>? emotionIntensities)
    List<RecentLifeEvent>? recentEvents)
    Map<String, String>? dreamRealityConnections)
    String? mainMessage)
    String? psychologicalInsight)
    String? jungianInterpretation)
    List<String>? advice)
    List<DreamRitual>? suggestedRituals)
    int? currentStep)
    bool? isLoading)
    String? error)
  }) {
    return DreamAnalysisState(
      dreamContent: dreamContent ?? this.dreamContent,
      inputType: inputType ?? this.inputType,
      guidingQuestions: guidingQuestions ?? this.guidingQuestions,
      extractedSymbols: extractedSymbols ?? this.extractedSymbols,
      userSelectedSymbols: userSelectedSymbols ?? this.userSelectedSymbols,
      emotions: emotions ?? this.emotions,
      emotionIntensities: emotionIntensities ?? this.emotionIntensities,
      recentEvents: recentEvents ?? this.recentEvents,
      dreamRealityConnections: dreamRealityConnections ?? this.dreamRealityConnections,
      mainMessage: mainMessage ?? this.mainMessage,
      psychologicalInsight: psychologicalInsight ?? this.psychologicalInsight,
      jungianInterpretation: jungianInterpretation ?? this.jungianInterpretation,
      advice: advice ?? this.advice,
      suggestedRituals: suggestedRituals ?? this.suggestedRituals,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Dream symbol model
class DreamSymbol {
  final String name;
  final String category;
  final String meaning;
  final String positiveAspect;
  final String negativeAspect;
  final String jungianMeaning;
  final List<String> associatedEmotions;
  final IconData? icon;

  const DreamSymbol({
    required this.name,
    required this.category,
    required this.meaning,
    required this.positiveAspect,
    required this.negativeAspect,
    required this.jungianMeaning,
    this.associatedEmotions = const [],
    this.icon,
  });
}

// Dream emotion model
class DreamEmotion {
  final String name;
  final String category; // primary, secondary
  final double intensity; // 0.0 to 1.0
  final String color;
  final String psychologicalMeaning;

  const DreamEmotion({
    required this.name,
    required this.category,
    required this.intensity,
    required this.color,
    required this.psychologicalMeaning,
  });
}

// Recent life event model
class RecentLifeEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category; // work, relationship, health, etc.
  final double significance; // 0.0 to 1.0

  const RecentLifeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.significance,
  });
}

// Dream ritual model
class DreamRitual {
  final String title;
  final String description;
  final String purpose;
  final List<String> steps;
  final String expectedOutcome;
  final IconData? icon;

  const DreamRitual({
    required this.title,
    required this.description,
    required this.purpose,
    required this.steps,
    required this.expectedOutcome,
    this.icon,
  });
}

// Dream analysis provider
class DreamAnalysisNotifier extends StateNotifier<DreamAnalysisState> {
  DreamAnalysisNotifier() : super(const DreamAnalysisState();

  // Step navigation
  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Step 1: Dream content
  void updateDreamContent(String content) {
    state = state.copyWith(dreamContent: content);
  }

  void updateInputType(String type) {
    state = state.copyWith(inputType: type);
  }

  void answerGuidingQuestion(String question, String answer) {
    final updatedQuestions = Map<String, String>.from(state.guidingQuestions);
    updatedQuestions[question] = answer;
    state = state.copyWith(guidingQuestions: updatedQuestions);
  }

  // Step 2: Symbols
  void setExtractedSymbols(Map<String, List<DreamSymbol>> symbols) {
    state = state.copyWith(extractedSymbols: symbols);
    // Auto-select all extracted symbols initially
    final allSymbols = symbols.values.expand((list) => list).toList();
    state = state.copyWith(userSelectedSymbols: allSymbols);
  }

  void toggleSymbolSelection(DreamSymbol symbol) {
    final updatedSymbols = List<DreamSymbol>.from(state.userSelectedSymbols);
    if (updatedSymbols.contains(symbol)) {
      updatedSymbols.remove(symbol);
    } else {
      updatedSymbols.add(symbol);
    }
    state = state.copyWith(userSelectedSymbols: updatedSymbols);
  }

  void addCustomSymbol(DreamSymbol symbol) {
    final updatedSymbols = List<DreamSymbol>.from(state.userSelectedSymbols);
    updatedSymbols.add(symbol);
    state = state.copyWith(userSelectedSymbols: updatedSymbols);
  }

  // Step 3: Emotions
  void addEmotion(DreamEmotion emotion) {
    final updatedEmotions = List<DreamEmotion>.from(state.emotions);
    updatedEmotions.add(emotion);
    state = state.copyWith(emotions: updatedEmotions);
  }

  void removeEmotion(DreamEmotion emotion) {
    final updatedEmotions = List<DreamEmotion>.from(state.emotions);
    updatedEmotions.remove(emotion);
    state = state.copyWith(emotions: updatedEmotions);
  }

  void updateEmotionIntensity(String emotionName, double intensity) {
    final updatedIntensities = Map<String, double>.from(state.emotionIntensities);
    updatedIntensities[emotionName] = intensity;
    state = state.copyWith(emotionIntensities: updatedIntensities);
  }

  // Step 4: Reality connections
  void addRecentEvent(RecentLifeEvent event) {
    final updatedEvents = List<RecentLifeEvent>.from(state.recentEvents);
    updatedEvents.add(event);
    state = state.copyWith(recentEvents: updatedEvents);
  }

  void removeRecentEvent(String eventId) {
    final updatedEvents = state.recentEvents.where((e) => e.id != eventId).toList();
    state = state.copyWith(recentEvents: updatedEvents);
  }

  void connectDreamToReality(String dreamElement, String realityConnection) {
    final updatedConnections = Map<String, String>.from(state.dreamRealityConnections);
    updatedConnections[dreamElement] = realityConnection;
    state = state.copyWith(dreamRealityConnections: updatedConnections);
  }

  // Step 5: Interpretation
  void setInterpretation({
    required String mainMessage,
    required String psychologicalInsight,
    required String jungianInterpretation,
  }) {
    state = state.copyWith(
      mainMessage: mainMessage,
      psychologicalInsight: psychologicalInsight)
      jungianInterpretation: jungianInterpretation)
    );
  }

  // Step 6: Advice and rituals
  void setAdviceAndRituals({
    required List<String> advice,
    required List<DreamRitual> rituals)
  }) {
    state = state.copyWith(
      advice: advice,
      suggestedRituals: rituals
    );
  }

  // Loading and error states
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  // Reset analysis
  void reset() {
    state = const DreamAnalysisState();
  }

  // Validate current step
  bool canProceedToNextStep() {
    switch (state.currentStep) {
      case 0: // Dream content
        return state.dreamContent.trim().isNotEmpty;
      case 1: // Symbols
        return state.userSelectedSymbols.isNotEmpty;
      case 2: // Emotions
        return state.emotions.isNotEmpty;
      case 3: // Reality connections
        return true; // Optional step
      case 4: // Interpretation
        return state.mainMessage != null;
      case 5: // Advice
        return true;
      default:
        return false;
    }
  }
}

// Provider
final dreamAnalysisProvider = StateNotifierProvider<DreamAnalysisNotifier, DreamAnalysisState>((ref) {
  return DreamAnalysisNotifier();
};