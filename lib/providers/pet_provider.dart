import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/pet_profile.dart';
import '../services/pet_service.dart';
import '../core/utils/logger.dart';

final petProvider = StateNotifierProvider<PetNotifier, PetState>((ref) {
  return PetNotifier();
});

class PetState {
  final List<PetProfile> pets;
  final PetProfile? selectedPet;
  final bool isLoading;
  final String? error;
  final bool isCreating;
  final bool isUpdating;

  const PetState({
    this.pets = const [],
    this.selectedPet,
    this.isLoading = false,
    this.error,
    this.isCreating = false,
    this.isUpdating = false,
  });

  PetState copyWith({
    List<PetProfile>? pets,
    PetProfile? selectedPet,
    bool? isLoading,
    String? error,
    bool? isCreating,
    bool? isUpdating,
    bool clearSelectedPet = false,
    bool clearError = false,
  }) {
    return PetState(
      pets: pets ?? this.pets,
      selectedPet: clearSelectedPet ? null : (selectedPet ?? this.selectedPet),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  bool get hasPets => pets.isNotEmpty;
  bool get hasSelectedPet => selectedPet != null;
  bool get hasError => error != null;
  bool get isBusy => isLoading || isCreating || isUpdating;
}

class PetNotifier extends StateNotifier<PetState> {
  PetNotifier() : super(const PetState());

  /// 사용자의 반려동물 목록 로드
  Future<void> loadUserPets(String userId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final pets = await PetService.getUserPets(userId);
      state = state.copyWith(
        pets: pets,
        isLoading: false,
        clearError: true,
      );
      
      Logger.info('Loaded ${pets.length} pets for user');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '반려동물 목록을 불러올 수 없습니다',
      );
      Logger.error('Failed to load pets', e);
    }
  }

  /// 새 반려동물 등록
  Future<PetProfile?> createPet({
    required String userId,
    required String species,
    required String name,
    required int age,
    String? gender,
    String? breed,
    String? personality,
    String? healthNotes,
    bool? isNeutered,
  }) async {
    if (state.isCreating) return null;

    state = state.copyWith(isCreating: true, clearError: true);

    try {
      // 이름 중복 확인
      final nameExists = await PetService.isPetNameExists(userId, name);
      if (nameExists) {
        state = state.copyWith(
          isCreating: false,
          error: '이미 같은 이름의 반려동물이 있습니다',
        );
        return null;
      }

      final newPet = await PetService.createPet(
        userId: userId,
        species: species,
        name: name,
        age: age,
        gender: gender,
        breed: breed,
        personality: personality,
        healthNotes: healthNotes,
        isNeutered: isNeutered,
      );

      if (newPet != null) {
        final updatedPets = [newPet, ...state.pets];
        state = state.copyWith(
          pets: updatedPets,
          selectedPet: newPet,
          isCreating: false,
          clearError: true,
        );
        Logger.info('Pet created and selected: ${newPet.name}');
        return newPet;
      } else {
        state = state.copyWith(
          isCreating: false,
          error: '반려동물 등록에 실패했습니다',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: '반려동물 등록 중 오류가 발생했습니다',
      );
      Logger.error('Failed to create pet', e);
    }

    return null;
  }

  /// 반려동물 선택
  void selectPet(PetProfile pet) {
    state = state.copyWith(selectedPet: pet, clearError: true);
    Logger.info('Selected pet: ${pet.name}');
  }

  /// 선택된 반려동물 해제
  void clearSelectedPet() {
    state = state.copyWith(clearSelectedPet: true, clearError: true);
    Logger.info('Cleared selected pet');
  }

  /// 반려동물 정보 수정
  Future<bool> updatePet({
    required String petId,
    String? species,
    String? name,
    int? age,
    String? gender,
    String? breed,
    String? personality,
    String? healthNotes,
    bool? isNeutered,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      // 이름 변경 시 중복 확인
      if (name != null) {
        final currentPet = state.pets.firstWhere((p) => p.id == petId);
        if (currentPet.name != name) {
          final nameExists = await PetService.isPetNameExists(
            currentPet.userId,
            name,
            excludePetId: petId,
          );
          if (nameExists) {
            state = state.copyWith(
              isUpdating: false,
              error: '이미 같은 이름의 반려동물이 있습니다',
            );
            return false;
          }
        }
      }

      final updatedPet = await PetService.updatePet(
        petId: petId,
        species: species,
        name: name,
        age: age,
        gender: gender,
        breed: breed,
        personality: personality,
        healthNotes: healthNotes,
        isNeutered: isNeutered,
      );

      if (updatedPet != null) {
        final updatedPets = state.pets.map((pet) {
          return pet.id == petId ? updatedPet : pet;
        }).toList();

        state = state.copyWith(
          pets: updatedPets,
          selectedPet: state.selectedPet?.id == petId ? updatedPet : state.selectedPet,
          isUpdating: false,
          clearError: true,
        );
        
        Logger.info('Pet updated successfully: ${updatedPet.name}');
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: '반려동물 정보 수정에 실패했습니다',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: '반려동물 정보 수정 중 오류가 발생했습니다',
      );
      Logger.error('Failed to update pet', e);
    }

    return false;
  }

  /// 반려동물 삭제
  Future<bool> deletePet(String petId) async {
    if (state.isBusy) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final success = await PetService.deletePet(petId);
      
      if (success) {
        final updatedPets = state.pets.where((pet) => pet.id != petId).toList();
        final shouldClearSelected = state.selectedPet?.id == petId;
        
        state = state.copyWith(
          pets: updatedPets,
          isLoading: false,
          clearSelectedPet: shouldClearSelected,
          clearError: true,
        );
        
        Logger.info('Pet deleted successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '반려동물 삭제에 실패했습니다',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '반려동물 삭제 중 오류가 발생했습니다',
      );
      Logger.error('Failed to delete pet', e);
    }

    return false;
  }

  /// 에러 메시지 지우기
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 상태 초기화
  void reset() {
    state = const PetState();
  }

  /// 궁합 점수 계산
  int? calculateCompatibilityScore({
    String? userZodiacSign,
    String? userMbtiType,
  }) {
    if (state.selectedPet == null || userZodiacSign == null || userMbtiType == null) {
      return null;
    }

    return PetService.calculateCompatibilityScore(
      pet: state.selectedPet!,
      userZodiacSign: userZodiacSign,
      userMbtiType: userMbtiType,
    );
  }
}