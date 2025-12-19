import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';

/// 가족 관계도 차트 - 토스 디자인 시스템
class FamilyRelationshipChart extends StatelessWidget {
  final List<FamilyMember> members;
  final Map<String, dynamic>? memberFortunes;
  
  const FamilyRelationshipChart({
    super.key,
    required this.members,
    this.memberFortunes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree,
                color: DSColors.accent,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                '우리 가족 관계도',
                style: context.heading3.copyWith(
                  
                  fontWeight: FontWeight.w700,
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Family tree visualization
          Center(
            child: _buildFamilyTree(context, isDark),
          ),

          const SizedBox(height: 24),

          // Relationship connections
          if (members.length > 1)
            _buildRelationshipConnections(context, isDark),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
  
  Widget _buildFamilyTree(BuildContext context, bool isDark) {
    if (members.isEmpty) {
      return Text(
        '가족 구성원을 추가해주세요',
        style: context.bodySmall.copyWith(
          color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
        ),
      );
    }

    // Simple family tree layout
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: members.map((member) {
        final fortune = memberFortunes?[member.name] ?? {};
        final mood = fortune['mood'] ?? '평온한';
        final energy = fortune['energy'] ?? 70;

        return _buildMemberNode(
          context: context,
          member: member,
          mood: mood,
          energy: energy,
          isDark: isDark,
        );
      }).toList(),
    );
  }
  
  Widget _buildMemberNode({
    required BuildContext context,
    required FamilyMember member,
    required String mood,
    required int energy,
    required bool isDark,
  }) {
    final color = _getRoleColor(member.role);
    
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              member.emoji,
              style: context.displayMedium,
            ),
          ),
        ).animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              delay: Duration(milliseconds: members.indexOf(member) * 100),
            ),
        
        SizedBox(height: 8),
        
        Text(
          member.name,
          style: context.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 4),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            member.role,
            style: context.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Energy indicator
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              width: (energy / 100) * 60,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRelationshipConnections(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관계 연결고리',
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Generate relationship pairs
        ...members.asMap().entries.map((entry) {
          final index = entry.key;
          if (index < members.length - 1) {
            final member1 = members[index];
            final member2 = members[index + 1];
            final compatibility = 70 + (index * 5); // Sample compatibility

            return _buildRelationshipLine(
              context: context,
              member1: member1,
              member2: member2,
              compatibility: compatibility,
              isDark: isDark,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
  
  Widget _buildRelationshipLine({
    required BuildContext context,
    required FamilyMember member1,
    required FamilyMember member2,
    required int compatibility,
    required bool isDark,
  }) {
    final color = _getCompatibilityColor(compatibility);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Member 1
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getRoleColor(member1.role).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              member1.emoji,
              style: context.heading2,
            ),
          ),
          
          // Connection line
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color,
                    color.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? DSColors.surface : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$compatibility%',
                    style: context.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Member 2
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getRoleColor(member2.role).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              member2.emoji,
              style: context.heading2,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: members.indexOf(member1) * 200))
        .slideX(begin: 0.1, end: 0);
  }
  
  Color _getRoleColor(String role) {
    final colors = {
      '아버지': DSColors.accent,
      '어머니': DSColors.error,
      '아들': DSColors.success,
      '딸': DSColors.accentSecondary,
      '할아버지': DSColors.textSecondary,
      '할머니': DSColors.warning,
      '형제': DSColors.accent,
      '자매': DSColors.accentSecondary,
    };
    
    return colors[role] ?? DSColors.textSecondary;
  }
  
  Color _getCompatibilityColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }
}

/// 가족 구성원 모델
class FamilyMember {
  final String name;
  final String role;
  final String emoji;
  final int? age;
  
  const FamilyMember({
    required this.name,
    required this.role,
    required this.emoji,
    this.age,
  });
}

/// 관계 매트릭스 차트
class FamilyRelationshipMatrix extends StatelessWidget {
  final List<FamilyMember> members;
  final Map<String, Map<String, int>>? compatibilityMatrix;
  
  const FamilyRelationshipMatrix({
    super.key,
    required this.members,
    this.compatibilityMatrix,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (members.length < 2) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? DSColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? DSColors.border : DSColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '가족 구성원이 2명 이상일 때 관계 매트릭스를 확인할 수 있습니다',
            style: context.bodySmall.copyWith(
              color: isDark ? DSColors.textTertiary : DSColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DSColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? DSColors.border : DSColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관계 궁합 매트릭스',
            style: context.heading3.copyWith(
              
              fontWeight: FontWeight.w700,
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Matrix grid
          Table(
            border: TableBorder.all(
              color: isDark ? DSColors.border : DSColors.border,
              width: 1,
            ),
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: (isDark ? DSColors.surface : DSColors.backgroundSecondary).withValues(alpha: 0.5),
                ),
                children: [
                  const SizedBox(height: 40),
                  ...members.map((member) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        member.emoji,
                        style: context.heading2,
                      ),
                    ),
                  )),
                ],
              ),
              
              // Data rows
              ...members.map((member1) {
                return TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: (isDark ? DSColors.surface : DSColors.backgroundSecondary).withValues(alpha: 0.5),
                      child: Center(
                        child: Text(
                          member1.emoji,
                          style: context.heading2,
                        ),
                      ),
                    ),
                    ...members.map((member2) {
                      if (member1 == member2) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          color: DSColors.backgroundSecondary.withValues(alpha: 0.3),
                          child: Center(
                            child: Text('-'),
                          ),
                        );
                      }
                      
                      final compatibility = _getCompatibility(member1, member2);
                      final color = _getCompatibilityColor(compatibility);
                      
                      return Container(
                        padding: const EdgeInsets.all(8),
                        color: color.withValues(alpha: 0.1),
                        child: Center(
                          child: Text(
                            '$compatibility',
                            style: context.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, '매우 좋음', DSColors.success),
              const SizedBox(width: 16),
              _buildLegendItem(context, '좋음', DSColors.accent),
              const SizedBox(width: 16),
              _buildLegendItem(context, '보통', DSColors.warning),
              const SizedBox(width: 16),
              _buildLegendItem(context, '노력 필요', DSColors.error),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: context.labelSmall.copyWith(
            color: DSColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  int _getCompatibility(FamilyMember member1, FamilyMember member2) {
    // Sample compatibility calculation
    if (compatibilityMatrix != null) {
      return compatibilityMatrix![member1.name]?[member2.name] ?? 70;
    }
    
    // Default logic based on roles
    if ((member1.role == '아버지' && member2.role == '아들') ||
        (member1.role == '어머니' && member2.role == '딸')) {
      return 85;
    }
    
    return 70 + (member1.name.hashCode + member2.name.hashCode) % 20;
  }
  
  Color _getCompatibilityColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return DSColors.accent;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }
}