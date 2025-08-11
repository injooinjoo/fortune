#!/usr/bin/env python3
"""
Flutter Dart 파일의 공통 구문 에러를 자동으로 수정하는 스크립트
"""

import re
import sys
import os

def fix_dart_file(filepath):
    """Dart 파일의 일반적인 구문 에러를 수정"""
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 1. 잘못된 import 문 수정
    content = re.sub(r"import 'package: flutter", r"import 'package:flutter", content)
    
    # 2. 괄호 뒤 쉼표 누락 수정
    # ')' 다음에 바로 다른 속성이 오는 경우
    content = re.sub(r'\)\s*\n\s*([a-zA-Z])', r'),\n            \1', content)
    
    # 3. Map/List 리터럴의 마지막 요소 뒤 세미콜론 수정
    content = re.sub(r"'([^']+)'\]\s*;", r"'\1'\n  ];", content)
    content = re.sub(r"'([^']+)'\}\s*;", r"'\1'\n  };", content)
    
    # 4. Map 리터럴의 키-값 구분자 수정
    # 'key', 'value' -> 'key': 'value'
    content = re.sub(r"'([^']+)',\s*'([^']+)'", r"'\1': '\2'", content)
    
    # 5. 잘못된 위젯 속성 체인 수정
    # style: TextStyle().copyWith()
    #   color: Colors.red)
    # ->
    # style: TextStyle().copyWith(
    #   color: Colors.red)
    content = re.sub(r'\.copyWith\(\)\s*\n\s*([a-zA-Z])', r'.copyWith(\n            \1', content)
    
    # 6. 괄호 균형 수정 - 여는 괄호 다음 바로 닫는 괄호가 나오는 경우
    content = re.sub(r'\(\)\)', r'()', content)
    content = re.sub(r'\)\)\)', r'))', content)
    
    # 7. 잘못된 리스트 속 조건문 수정
    # if (condition, ...[
    # ->
    # if (condition) ...[
    content = re.sub(r'if\s*\([^)]+,\s*\.\.\.\[', lambda m: m.group(0).replace(',', ')', 1), content)
    
    # 8. 중복 세미콜론 제거
    content = re.sub(r';;+', r';', content)
    
    # 9. 속성 뒤 쉼표 누락 수정 (특정 패턴)
    # borderRadius: BorderRadius.circular(12)))
    # ->
    # borderRadius: BorderRadius.circular(12)),
    content = re.sub(r'(BorderRadius\.circular\(\d+\))\)\)', r'\1),', content)
    
    # 10. 잘못된 문자열 닫기
    # '문자열',),
    # ->
    # '문자열',
    content = re.sub(r"'([^']+)',\),", r"'\1',", content)
    
    # 11. super 생성자 호출 수정
    content = re.sub(r'(fortuneType: [^;]+)\);\s*requiresUserInfo:', r'\1,\n          requiresUserInfo:', content)
    
    # 12. 리스트 맵핑 끝 수정
    # }).toList())]))
    # ->
    # }).toList(),
    content = re.sub(r'\}\)\.toList\(\)\]\)', r'}).toList(),', content)
    
    # 변경사항이 있으면 파일 저장
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    """메인 함수"""
    
    target_dir = 'lib/features/fortune/presentation/pages'
    
    if not os.path.exists(target_dir):
        print(f"디렉토리를 찾을 수 없습니다: {target_dir}")
        return
    
    fixed_files = []
    
    for filename in os.listdir(target_dir):
        if filename.endswith('.dart'):
            filepath = os.path.join(target_dir, filename)
            if fix_dart_file(filepath):
                fixed_files.append(filename)
                print(f"수정됨: {filename}")
    
    if fixed_files:
        print(f"\n총 {len(fixed_files)}개 파일이 수정되었습니다.")
    else:
        print("수정할 파일이 없습니다.")

if __name__ == "__main__":
    main()