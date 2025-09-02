import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';

/// MBTI 시너지 카드 위젯 (토스 스타일)
class MbtiSynergyCard extends StatelessWidget {
  final Map<String, dynamic> synergyData;
  final String myMbtiType;
  const MbtiSynergyCard({
    super.key,
    required this.synergyData,
    required this.myMbtiType,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bestMatches = synergyData['bestMatches'] as List<dynamic>;
    final worstMatches = synergyData['worstMatches'] as List<dynamic>;
    final todaySpecial = synergyData['todaySpecial'] as Map<String, dynamic>;
    final communicationTip = synergyData['communicationTip'] as String;
    return TossSectionCard(
      title: 'MBTI 시너지 매칭',
      subtitle: '오늘 당신과 잘 맞는 MBTI 유형을 확인하세요',
      style: TossCardStyle.elevated,
      child: Column(
        children: [
          // 오늘의 특별 시너지
          _buildSpecialSynergy(todaySpecial, isDark),
          
          SizedBox(height: TossDesignSystem.spacingL),
          // 베스트 매치
          _buildMatchSection(
            title: '최고의 궁합',
            icon: Icons.favorite_rounded,
            iconColor: TossDesignSystem.errorRed,
            matches: bestMatches,
            isPositive: true,
            isDark: isDark,
          ),
          SizedBox(height: TossDesignSystem.spacingM),
          // 주의할 매치
            title: '주의가 필요한 궁합',
            icon: Icons.warning_rounded,
            iconColor: TossDesignSystem.warningOrange,
            matches: worstMatches,
            isPositive: false,
          // 커뮤니케이션 팁
          _buildCommunicationTip(communicationTip, isDark),
        ],
      ),
    ).animate()
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.1, end: 0);
  }
  Widget _buildSpecialSynergy(Map<String, dynamic> special, bool isDark) {
    final type = special['type'] as String;
    final score = special['score'] as int;
    final message = special['message'] as String;
    return Container(
      padding: EdgeInsets.all(TossDesignSystem.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.purple.withOpacity(0.8),
            TossDesignSystem.tossBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusL),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: TossDesignSystem.white,
                size: 24,
              ),
              SizedBox(width: TossDesignSystem.spacingS),
              Text(
                '오늘의 특별 시너지',
                style: TossDesignSystem.body1.copyWith(
                  color: TossDesignSystem.white,
                  fontWeight: FontWeight.bold,
                ),
            ],
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: TossDesignSystem.spacingL,
              vertical: TossDesignSystem.spacingM,
            ),
            decoration: BoxDecoration(
              color: TossDesignSystem.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type,
                  style: TossDesignSystem.heading2.copyWith(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.bold,
                  ),
                SizedBox(width: TossDesignSystem.spacingM),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: TossDesignSystem.spacingM,
                    vertical: TossDesignSystem.spacingS,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                  child: Text(
                    '$score%',
                    style: TossDesignSystem.body1.copyWith(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.bold,
                    ),
              ],
          Text(
            message,
            style: TossDesignSystem.body3.copyWith(
              color: TossDesignSystem.white.withOpacity(0.95),
            textAlign: TextAlign.center,
      .scale(delay: 300.ms, duration: 500.ms)
      .shimmer(delay: 800.ms, duration: 1500.ms);
  Widget _buildMatchSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<dynamic> matches,
    required bool isPositive,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            SizedBox(width: TossDesignSystem.spacingS),
            Text(
              title,
              style: TossDesignSystem.body2.copyWith(
                color: isDark 
                    ? TossDesignSystem.grayDark900
                    : TossDesignSystem.gray900,
                fontWeight: FontWeight.w600,
        
        SizedBox(height: TossDesignSystem.spacingM),
        ...matches.asMap().entries.map((entry) {
          final index = entry.key;
          final match = entry.value as Map<String, dynamic>;
          final type = match['type'] as String;
          final score = match['score'] as int;
          final reason = match['reason'] as String;
          return _buildMatchCard(
            type: type,
            score: score,
            reason: reason,
            isPositive: isPositive,
            index: index,
          );
        }).toList(),
      ],
    );
  Widget _buildMatchCard({
    required String type,
    required int score,
    required String reason,
    required int index,
    final color = isPositive 
        ? TossDesignSystem.successGreen
        : TossDesignSystem.warningOrange;
      margin: EdgeInsets.only(bottom: TossDesignSystem.spacingS),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        child: Container(
          padding: EdgeInsets.all(TossDesignSystem.spacingM),
          decoration: BoxDecoration(
            color: isDark 
                ? TossDesignSystem.grayDark200
                : TossDesignSystem.gray50,
            borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
          child: Row(
              // MBTI 타입
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusS),
                child: Center(
                    type,
                      color: color,
              
              SizedBox(width: TossDesignSystem.spacingM),
              // 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMbtiTitle(type),
                      style: TossDesignSystem.body2.copyWith(
                        color: isDark 
                            ? TossDesignSystem.grayDark900
                            : TossDesignSystem.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    SizedBox(height: TossDesignSystem.spacingXS),
                      reason,
                      style: TossDesignSystem.caption.copyWith(
                            ? TossDesignSystem.grayDark400
                            : TossDesignSystem.gray600,
                  ],
              // 점수
                padding: EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacingM,
                  vertical: TossDesignSystem.spacingS,
                child: Text(
                  '$score%',
                  style: TossDesignSystem.body2.copyWith(
                    color: color,
      .fadeIn(
        delay: Duration(milliseconds: 100 * index),
        duration: 400.ms,
      )
      .slideX(
        begin: isPositive ? -0.05 : 0.05,
        end: 0,
      );
  Widget _buildCommunicationTip(String tip, bool isDark) {
      padding: EdgeInsets.all(TossDesignSystem.spacingM),
        color: TossDesignSystem.tossBlue.withOpacity(0.05),
        border: Border.all(
          color: TossDesignSystem.tossBlue.withOpacity(0.2),
          width: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
          Icon(
            Icons.tips_and_updates_rounded,
            color: TossDesignSystem.tossBlue,
            size: 20,
          SizedBox(width: TossDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  '오늘의 소통 팁',
                    color: TossDesignSystem.tossBlue,
                SizedBox(height: TossDesignSystem.spacingXS),
                  tip,
                  style: TossDesignSystem.body3.copyWith(
                    color: isDark 
                        ? TossDesignSystem.grayDark600
                        : TossDesignSystem.gray600,
  String _getMbtiTitle(String type) {
    final titles = {
      'INTJ': '전략가',
      'INTP': '논리술사',
      'ENTJ': '통솔자',
      'ENTP': '변론가',
      'INFJ': '옹호자',
      'INFP': '중재자',
      'ENFJ': '선도자',
      'ENFP': '활동가',
      'ISTJ': '현실주의자',
      'ISFJ': '수호자',
      'ESTJ': '경영자',
      'ESFJ': '집정관',
      'ISTP': '장인',
      'ISFP': '모험가',
      'ESTP': '사업가',
      'ESFP': '연예인',
    };
    return titles[type] ?? type;
}
