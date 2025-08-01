#!/usr/bin/env python3
"""
Flutter Dart 파일의 공통 문법 에러를 자동으로 수정하는 스크립트
"""

import os
import re
import sys

def fix_syntax_errors(file_path):
    """개별 파일의 문법 에러를 수정"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 1. 괄호 앞 쉼표 누락 수정: func() func() -> func(), func()
        content = re.sub(r'\)\s*([a-zA-Z_][a-zA-Z0-9_]*\s*\()', r'), \1', content)
        
        # 2. $1, $2 등 잘못된 문자 제거
        content = re.sub(r'\$\d+', '', content)
        
        # 3. 괄호 끝에 콤마 누락 수정: ) -> ),
        content = re.sub(r'\)\s*([a-zA-Z_][a-zA-Z0-9_]*\s*:)', r'),\n                  \1', content)
        
        # 4. 함수 호출에서 괄호 앞 쉼표 누락: func(arg) child: -> func(arg), child:
        content = re.sub(r'\)\s+([a-zA-Z_][a-zA-Z0-9_]*\s*:)', r'),\n                \1', content)
        
        # 5. 리스트/맵에서 마지막 쉼표 누락
        content = re.sub(r'([^,\s])\s*\n\s*([}\]])', r'\1,\n\2', content)
        
        # 6. 문장 끝 세미콜론 누락 수정 (특정 패턴만)
        content = re.sub(r'([^;,\{\}\[\]\(\)]\s*)\n(\s*[}\]])', r'\1;\n\2', content)
        
        # 7. 특정 패턴의 괄호 짝 맞추기
        content = re.sub(r'\)\s*,\s*\)', r'))', content)
        
        # 8. 중복 괄호 제거
        content = re.sub(r'\)\s*\)\s*,', r'),', content)
        
        # 9. withValues() 함수 호출 수정
        content = re.sub(r'\.withValues\(alpha:\s*([^)]+)\)\s*([a-zA-Z])', r'.withValues(alpha: \1),\n                \2', content)
        
        # 10. Hero 태그 문법 수정: tag: value) -> tag: value,
        content = re.sub(r'tag:\s*([^,)]+)\)\s*child:', r'tag: \1,\n              child:', content)
        
        # 변경사항이 있으면 파일 저장
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """메인 함수"""
    # error_files_part2_v6.txt에서 파일 목록 읽기
    error_files_path = '/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter/error_files_part2_v6.txt'
    base_path = '/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter'
    
    if not os.path.exists(error_files_path):
        print(f"Error file list not found: {error_files_path}")
        return
    
    with open(error_files_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    print(f"First 3 lines from file:")
    for i, line in enumerate(lines[:3]):
        print(f"  {i}: '{line.strip()}'")
    
    # 파일 경로 추출 (단순히 각 라인이 파일 경로)
    files_to_fix = []
    for line in lines:
        line = line.strip()
        if line and line.endswith('.dart'):
            file_path = line
            full_path = os.path.join(base_path, file_path)
            print(f"Checking: {full_path}")  # 디버깅
            if os.path.exists(full_path):
                files_to_fix.append(full_path)
                print(f"Found: {full_path}")  # 디버깅
            else:
                print(f"File not found: {full_path}")
    
    print(f"Total files found: {len(files_to_fix)}")  # 디버깅
    
    # 파일들 수정
    fixed_count = 0
    total_count = len(files_to_fix)
    
    print(f"총 {total_count}개 파일을 처리합니다...")
    
    for i, file_path in enumerate(files_to_fix, 1):
        print(f"[{i}/{total_count}] Processing: {os.path.basename(file_path)}")
        if fix_syntax_errors(file_path):
            fixed_count += 1
    
    print(f"\n완료! {fixed_count}/{total_count}개 파일이 수정되었습니다.")

if __name__ == "__main__":
    main()