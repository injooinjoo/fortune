#!/usr/bin/env python3
import re
import os
import sys

def fix_dart_file(filepath):
    """Flutter/Dart 파일의 일반적인 구문 에러를 수정합니다."""
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 패턴 1: }).toList() 뒤의 구문 문제
    content = re.sub(r'\}\)\.toList\(\),\s*\n\s*const SizedBox', 
                     r'}).toList(),\n          ),\n          const SizedBox', content)
    
    # 패턴 2: 잘못된 매개변수 구분자 - 세미콜론을 쉼표로
    content = re.sub(r'(\w+)\);(\s*\n\s*\w+:)', r'\1),\2', content)
    
    # 패턴 3: child: 매개변수 문제
    content = re.sub(r'child:\s*Icon\(\s*([^,]+)\);\s*size:\s*(\d+)\)',
                     r'child: Icon(\1, size: \2)', content)
    
    # 패턴 4: TextStyle 닫기 문제
    content = re.sub(r'fontSize:\s*(\d+)\)\)\);',
                     r'fontSize: \1,\n                      ),\n                    ),\n                  ),', content)
    
    # 패턴 5: Container/Column 매칭 문제
    content = re.sub(r'(\s+)child:\s*Column\(\s*\n\s+children:', 
                     r'\1child: Column(\n\1  children:', content)
    
    # 패턴 6: 잘못된 속성 구분자
    content = re.sub(r'(\w+):\s*([^,\n]+)\);\s*(\w+):', 
                     r'\1: \2,\n            \3:', content)
    
    # 패턴 7: SizedBox 위치 문제
    content = re.sub(r'const SizedBox\(height:\s*(\d+)\),\s*$',
                     r'const SizedBox(height: \1),', content, flags=re.MULTILINE)
    
    # 패턴 8: 닫는 괄호 누락
    # }).toList() 패턴 뒤에 닫는 괄호 추가
    content = re.sub(r'(\}\)\.toList\(\)),\s*\n(\s+const SizedBox)',
                     r'\1,\n          ),\n\2', content)
    
    # 패턴 9: 이상한 속성 값
    content = re.sub(r"'content'\]", r"_fortune!.content}", content)
    content = re.sub(r"''$1'", r"''", content)
    
    # 패턴 10: 잘못된 Icon 구문
    content = re.sub(r'Icon\(\s*([^,\)]+)\);\s*size:\s*(\d+)\),',
                     r'Icon(\1, size: \2),', content)
    
    # 패턴 11: BorderRadius 문제
    content = re.sub(r'borderRadius:\s*BorderRadius\.circular\((\d+)\),\s*child:',
                     r'borderRadius: BorderRadius.circular(\1),\n                  ),\n                  child:', content)
    
    # 패턴 12: SnackBar 문제
    content = re.sub(r'const SnackBar\(content:\s*Text\(([^)]+)\)\)\);',
                     r'const SnackBar(content: Text(\1)),\n                  );', content)
    
    # 변경사항이 있으면 파일 저장
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    # 수정할 파일 목록
    files_to_fix = [
        'lib/features/fortune/presentation/pages/dream_fortune_page.dart',
        'lib/features/fortune/presentation/pages/personality_fortune_page.dart',
        'lib/features/fortune/presentation/pages/personality_fortune_unified_page.dart',
        'lib/features/fortune/presentation/pages/ex_lover_fortune_page.dart',
        'lib/features/fortune/presentation/pages/blind_date_fortune_page.dart',
        'lib/features/fortune/presentation/pages/lottery_fortune_page.dart',
        'lib/features/fortune/presentation/pages/moving_date_fortune_page.dart',
        'lib/features/interactive/presentation/pages/dream_page.dart',
        'lib/features/fortune/presentation/pages/lucky_food_fortune_page.dart',
        'lib/features/fortune/presentation/pages/palmistry_fortune_page.dart',
        'lib/presentation/widgets/fortune_explanation_bottom_sheet.dart',
        'lib/features/interactive/presentation/pages/chemistry_page.dart',
        'lib/features/fortune/presentation/pages/investment_fortune_result_page.dart',
        'lib/features/fortune/presentation/pages/face_reading_fortune_page.dart',
        'lib/features/fortune/presentation/pages/career_seeker_fortune_page.dart',
        'lib/features/interactive/presentation/pages/psychology_test_page.dart',
        'lib/features/interactive/presentation/pages/dream_interpretation_page.dart',
        'lib/features/fortune/presentation/widgets/dream_psychology_chart.dart',
        'lib/features/fortune/presentation/pages/tojeong_fortune_page.dart',
        'lib/features/fortune/presentation/pages/moving_fortune_page.dart',
        'lib/features/fortune/presentation/pages/birthdate_fortune_page.dart',
        'lib/features/interactive/presentation/pages/celebrity_match_page.dart',
        'lib/features/fortune/presentation/pages/startup_fortune_page.dart',
        'lib/features/fortune/presentation/pages/network_report_fortune_page.dart',
        'lib/features/fortune/presentation/pages/lucky_series_fortune_page.dart',
        'lib/features/fortune/presentation/pages/daily_inspiration_page.dart',
        'lib/screens/profile/profile_screen.dart',
        'lib/features/fortune/presentation/pages/lucky_realestate_fortune_page.dart',
        'lib/features/fortune/presentation/pages/lucky_outfit_fortune_page.dart',
        'lib/features/fortune/presentation/pages/tarot_storytelling_page.dart',
    ]
    
    fixed_count = 0
    for filepath in files_to_fix:
        if os.path.exists(filepath):
            print(f"처리 중: {filepath}")
            if fix_dart_file(filepath):
                fixed_count += 1
                print(f"  ✅ 수정됨")
            else:
                print(f"  ⏭️  변경사항 없음")
        else:
            print(f"❌ 파일 없음: {filepath}")
    
    print(f"\n총 {fixed_count}개 파일 수정 완료")

if __name__ == "__main__":
    main()