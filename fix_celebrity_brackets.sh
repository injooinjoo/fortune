#!/bin/bash

# celebrity_database.dart 파일의 bracket matching 에러를 수정하는 스크립트

file="/Users/jacobmac/Desktop/Dev/fortune/lib/data/constants/celebrity_database.dart"

echo "Fixing bracket matching errors in celebrity_database.dart..."

# 1. keywords 배열에서 콜론을 쉼표로 바꾸고 닫는 괄호를 대괄호로 수정
sed -i '' "s/keywords: \[\([^]]*\)': \([^]]*\)': \([^]]*\)')/keywords: [\1', '\2', '\3']/g" "$file"

# 2. 3개가 아닌 다른 개수의 keywords도 수정
sed -i '' "s/keywords: \[\([^]]*\)': \([^]]*\)')/keywords: [\1', '\2']/g" "$file"
sed -i '' "s/keywords: \[\([^]]*\)': \([^]]*\)': \([^]]*\)': \([^]]*\)')/keywords: [\1', '\2', '\3', '\4']/g" "$file"
sed -i '' "s/keywords: \[\([^]]*\)': \([^]]*\)': \([^]]*\)': \([^]]*\)': \([^]]*\)')/keywords: [\1', '\2', '\3', '\4', '\5']/g" "$file"

# 3. description 필드에서 잘못된 문법 수정
sed -i '' "s/description: '\([^']*\)': null,/description: '\1',/g" "$file"

echo "Done! Checking for remaining errors..."

# 결과 확인
dart analyze "$file" 2>&1 | grep -c "error.*Expected" || echo "No bracket matching errors found!"