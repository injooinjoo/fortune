#!/bin/bash

# Flutter 에러 패턴 수정 스크립트

echo "Flutter 에러 패턴 자동 수정 시작..."

# 수정할 파일들 찾기
FILES=$(find lib -name "*.dart" -type f)

for file in $FILES; do
    echo "처리 중: $file"
    
    # 임시 파일 생성
    temp_file="${file}.tmp"
    cp "$file" "$temp_file"
    
    # 패턴 1: }).toList(), 뒤에 const SizedBox 오류
    sed -i '' 's/}).toList(),$/}).toList(),/g' "$temp_file"
    sed -i '' 's/}).toList(),\n *const SizedBox/}).toList(),\n          ),\n          const SizedBox/g' "$temp_file"
    
    # 패턴 2: 잘못된 매개변수 구분자
    sed -i '' 's/);$/),/g' "$temp_file"
    sed -i '' 's/));$/)),/g' "$temp_file"
    sed -i '' 's/)));$/))),/g' "$temp_file"
    
    # 패턴 3: 잘못된 child 매개변수
    sed -i '' 's/child: Icon(/child: Icon(/g' "$temp_file"
    sed -i '' 's/size: [0-9]*)/size: \1,/g' "$temp_file"
    
    # 패턴 4: TextStyle 끝 처리
    sed -i '' 's/fontSize: [0-9]*));/fontSize: \1,\n                      ),/g' "$temp_file"
    
    # 패턴 5: BoxDecoration 끝 처리
    sed -i '' 's/borderRadius: BorderRadius.circular([0-9]*),$/borderRadius: BorderRadius.circular(\1),/g' "$temp_file"
    
    # 원본 파일 교체
    mv "$temp_file" "$file"
done

echo "수정 완료!"