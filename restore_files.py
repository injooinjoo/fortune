#!/usr/bin/env python3
"""Restore files that were corrupted by fix_syntax_errors.py"""

import re

def restore_tarot_enhanced_page():
    file_path = "lib/features/fortune/presentation/pages/tarot_enhanced_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix enum syntax that was corrupted
    content = content.replace(
        """  single('single': '일일 카드': 1, 1,
  threeCard('three': '3장 스프레드', 3, 2,
  celticCross('celtic': '켈틱 크로스', 10, 5,
  relationship('relationship': '관계 스프레드', 6, 3,
  decision('decision', '결정 스프레드', 5, 3);""",
        """  single('single', '일일 카드', 1, 1),
  threeCard('three', '3장 스프레드', 3, 2),
  celticCross('celtic', '켈틱 크로스', 10, 5),
  relationship('relationship', '관계 스프레드', 6, 3),
  decision('decision', '결정 스프레드', 5, 3);"""
    )
    
    # Fix context.push syntax
    content = content.replace(
        "context.push('/interactive/tarot/animated-flow': extra: {",
        "context.push('/interactive/tarot/animated-flow', extra: {"
    )
    
    content = content.replace(
        "context.push('/interactive/tarot': extra: {",
        "context.push('/interactive/tarot', extra: {"
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Restored {file_path}")

def restore_enhanced_onboarding_flow():
    file_path = "lib/screens/onboarding/enhanced_onboarding_flow.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix _buildMbtiRow calls
    content = content.replace(
        "_buildMbtiRow('EI': 'E': 'I', '외향형', '내향형', selections, setModalState,",
        "_buildMbtiRow('EI', 'E', 'I', '외향형', '내향형', selections, setModalState),"
    )
    content = content.replace(
        "_buildMbtiRow('SN': 'S': 'N', '감각형', '직관형', selections, setModalState,",
        "_buildMbtiRow('SN', 'S', 'N', '감각형', '직관형', selections, setModalState),"
    )
    content = content.replace(
        "_buildMbtiRow('FT': 'F': 'T', '감정형', '사고형', selections, setModalState,",
        "_buildMbtiRow('FT', 'F', 'T', '감정형', '사고형', selections, setModalState),"
    )
    content = content.replace(
        "_buildMbtiRow('JP': 'J': 'P', '판단형', '인식형', selections, setModalState,",
        "_buildMbtiRow('JP', 'J', 'P', '판단형', '인식형', selections, setModalState),"
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Restored {file_path}")

def restore_fortune_history_page():
    file_path = "lib/features/history/presentation/pages/fortune_history_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix _buildFilterChip calls
    content = content.replace(
        "_buildFilterChip('all': '전체': fontScale,",
        "_buildFilterChip('all', '전체', fontScale),"
    )
    content = content.replace(
        "_buildFilterChip('daily': '일일 운세', fontScale,",
        "_buildFilterChip('daily', '일일 운세', fontScale),"
    )
    content = content.replace(
        "_buildFilterChip('weekly': '주간 운세', fontScale,",
        "_buildFilterChip('weekly', '주간 운세', fontScale),"
    )
    content = content.replace(
        "_buildFilterChip('monthly': '월간 운세', fontScale,",
        "_buildFilterChip('monthly', '월간 운세', fontScale),"
    )
    content = content.replace(
        "_buildFilterChip('love': '연애운', fontScale,",
        "_buildFilterChip('love', '연애운', fontScale),"
    )
    content = content.replace(
        "_buildFilterChip('money': '금전운', fontScale,",
        "_buildFilterChip('money', '금전운', fontScale),"
    )
    content = content.replace(
        "_buildFilterChip('career': '직장운', fontScale,",
        "_buildFilterChip('career', '직장운', fontScale),"
    )
    content = content.replace(
        "_buildFilterChip('health': '건강운', fontScale,",
        "_buildFilterChip('health', '건강운', fontScale),"
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Restored {file_path}")

def restore_home_screen():
    file_path = "lib/screens/home/home_screen.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix List.from syntax
    content = content.replace(
        "keywords: List<String>.from(dailyData['keywords'] ?? ['행운': '기회': '성장'],",
        "keywords: List<String>.from(dailyData['keywords'] ?? ['행운', '기회', '성장']),"
    )
    content = content.replace(
        "keywords: fortune.recommendations ?? ['행운': '기회': '성장'],",
        "keywords: fortune.recommendations ?? ['행운', '기회', '성장'],"
    )
    
    # Fix _getEnergyByScore call
    content = content.replace(
        "energy: _getEnergyByScore(score,",
        "energy: _getEnergyByScore(score),"
    )
    
    # Fix onTap syntax
    content = content.replace(
        "onTap: () => _navigateToFortune('/fortune/time-based': '시간별 운세',",
        "onTap: () => _navigateToFortune('/fortune/time-based', '시간별 운세'),"
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Restored {file_path}")

def restore_admin_dashboard_page():
    file_path = "lib/features/admin/presentation/pages/admin_dashboard_page.dart"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix _tabs array syntax
    content = content.replace(
        "final _tabs = const ['개요': '사용량 추이', '패키지별 분석', '상위 사용자'];",
        "final _tabs = const ['개요', '사용량 추이', '패키지별 분석', '상위 사용자'];"
    )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Restored {file_path}")

if __name__ == "__main__":
    restore_tarot_enhanced_page()
    restore_enhanced_onboarding_flow()
    restore_fortune_history_page()
    restore_home_screen()
    restore_admin_dashboard_page()