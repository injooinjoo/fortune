/// 재능 발견 운세 입력 데이터 모델
///
/// 3단계 입력:
/// - Phase 1: 사주 정보 (변하지 않는 것 - The Unchangeable)
/// - Phase 2: 현재 상태 (환경으로 만들어진 것 - The Nurture)
/// - Phase 3: 성향 선택 (선호하는 것 - The Preference)
library;

import 'package:flutter/material.dart';

class TalentInputData {
  // Phase 1: 사주 정보
  final DateTime? birthDate;
  final TimeOfDay? birthTime;
  final String? gender;
  final String? birthCity;

  // Phase 2: 현재 상태
  final String? currentOccupation; // 현재 직업/전공
  final List<String> concernAreas; // 고민 분야 (태그)
  final List<String> interestAreas; // 관심 분야 (태그)
  final String? selfStrengths; // 자기평가 - 강점
  final String? selfWeaknesses; // 자기평가 - 약점

  // Phase 3: 성향 선택
  final String? workStyle; // 업무 스타일: '혼자' or '팀'
  final String? energySource; // 에너지 충전: '사람 만나기' or '혼자 있기'
  final String? problemSolving; // 문제 해결: '논리' or '직관'
  final String? preferredRole; // 선호 역할: '안정적 프로세스' or '창의적 기획'

  const TalentInputData({
    this.birthDate,
    this.birthTime,
    this.gender,
    this.birthCity,
    this.currentOccupation,
    this.concernAreas = const [],
    this.interestAreas = const [],
    this.selfStrengths,
    this.selfWeaknesses,
    this.workStyle,
    this.energySource,
    this.problemSolving,
    this.preferredRole,
  });

  TalentInputData copyWith({
    DateTime? birthDate,
    TimeOfDay? birthTime,
    String? gender,
    String? birthCity,
    String? currentOccupation,
    List<String>? concernAreas,
    List<String>? interestAreas,
    String? selfStrengths,
    String? selfWeaknesses,
    String? workStyle,
    String? energySource,
    String? problemSolving,
    String? preferredRole,
  }) {
    return TalentInputData(
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      gender: gender ?? this.gender,
      birthCity: birthCity ?? this.birthCity,
      currentOccupation: currentOccupation ?? this.currentOccupation,
      concernAreas: concernAreas ?? this.concernAreas,
      interestAreas: interestAreas ?? this.interestAreas,
      selfStrengths: selfStrengths ?? this.selfStrengths,
      selfWeaknesses: selfWeaknesses ?? this.selfWeaknesses,
      workStyle: workStyle ?? this.workStyle,
      energySource: energySource ?? this.energySource,
      problemSolving: problemSolving ?? this.problemSolving,
      preferredRole: preferredRole ?? this.preferredRole,
    );
  }

  /// Phase 1 완료 여부
  bool get isPhase1Complete {
    return birthDate != null && birthTime != null && gender != null;
  }

  /// Phase 2 완료 여부
  bool get isPhase2Complete {
    return concernAreas.isNotEmpty || interestAreas.isNotEmpty;
  }

  /// Phase 3 완료 여부
  bool get isPhase3Complete {
    return workStyle != null &&
           energySource != null &&
           problemSolving != null &&
           preferredRole != null;
  }

  /// 전체 완료 여부
  bool get isComplete {
    return isPhase1Complete && isPhase2Complete && isPhase3Complete;
  }
}

/// 고민 분야 선택지
class ConcernAreaOptions {
  static const List<String> options = [
    '진로/직업',
    '적성 찾기',
    '전공 선택',
    '이직/전직',
    '창업',
    '학업/시험',
    '인간관계',
    '자기계발',
    '취미 발견',
    '번아웃',
    '워라밸',
    '성장 방향',
  ];
}

/// 관심 분야 선택지
class InterestAreaOptions {
  static const List<String> options = [
    '예술/창작',
    '비즈니스/경영',
    '사람/소통',
    '과학/기술',
    '운동/활동',
    '학습/연구',
    '봉사/나눔',
    '자연/환경',
    '문화/콘텐츠',
    '디자인/미학',
    '교육/멘토링',
    '심리/상담',
  ];
}

/// 업무 스타일 선택지
class WorkStyleOptions {
  static const String solo = '혼자 집중해서';
  static const String team = '팀과 협업하며';
  static const List<String> options = [solo, team];
}

/// 에너지 충전 방식 선택지
class EnergySourceOptions {
  static const String social = '사람 만나기';
  static const String alone = '혼자 있기';
  static const List<String> options = [social, alone];
}

/// 문제 해결 방식 선택지
class ProblemSolvingOptions {
  static const String logic = '논리적으로 분석';
  static const String intuition = '직관적으로 판단';
  static const List<String> options = [logic, intuition];
}

/// 선호하는 역할 선택지
class PreferredRoleOptions {
  static const String stable = '안정적 프로세스';
  static const String creative = '창의적 기획';
  static const List<String> options = [stable, creative];
}
