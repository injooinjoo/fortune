#!/bin/bash

file="/Users/jacobmac/Desktop/Dev/fortune/lib/data/constants/celebrity_database.dart"

echo "Applying advanced fixes to celebrity_database.dart..."

# 빈 문자열 수정
sed -i '' "s/''/'/g" "$file"

# 따옴표 중복 수정  
sed -i '' "s/''//g" "$file"

# 문자열 내의 잘못된 따옴표들 수정
sed -i '' "s/', '/'/g" "$file"

# keywords에서 남은 콜론들 수정
sed -i '' "s/': '/', '/g" "$file"

# 잘못된 닫는 괄호들 수정
sed -i '' "s/')/'],/g" "$file"

# description에서 콜론 문제 수정
sed -i '' "s/': null/'/g" "$file"

echo "Advanced fixes applied. Checking results..."

# 결과 확인
error_count=$(dart analyze "$file" 2>&1 | grep -c "error.*Expected" || echo "0")
echo "Remaining Expected errors: $error_count"