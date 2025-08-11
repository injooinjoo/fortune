#!/bin/bash

# Flutter 공통 에러 수정 스크립트

echo "Flutter 공통 에러 수정 시작..."

# 모든 dart 파일 찾기
dart_files=$(find lib -name "*.dart" 2>/dev/null)

# 에러 패턴 수정
for file in $dart_files; do
    # 잘못된 Map 리터럴 수정 {'id': 'value': 'name', '...'} -> {'id': 'value', 'name': '...'}
    sed -i '' "s/{'id': '\([^']*\)': 'name', '\([^']*\)'/{'id': '\1', 'name': '\2'/g" "$file" 2>/dev/null
    
    # 이중 세미콜론 제거
    sed -i '' 's/;;/;/g' "$file" 2>/dev/null
    
    # 잘못된 괄호 매칭 수정 - ))), -> )),
    sed -i '' 's/))))/)))/g' "$file" 2>/dev/null
    sed -i '' 's/))),/)),/g' "$file" 2>/dev/null
    
    # 잘못된 컴마+괄호 수정 - ),), -> )),
    sed -i '' 's/),),/)),/g' "$file" 2>/dev/null
    
    # NeverScrollableScrollPhysics(, -> NeverScrollableScrollPhysics(),
    sed -i '' 's/NeverScrollableScrollPhysics(,/NeverScrollableScrollPhysics(),/g' "$file" 2>/dev/null
    
    # 잘못된 widget closing 수정 ))])) -> ))]))
    sed -i '' 's/))]))/)])/g' "$file" 2>/dev/null
    
    # copyWith(), 뒤에 추가 파라미터가 있는 경우 수정
    sed -i '' 's/copyWith(),$/copyWith(/g' "$file" 2>/dev/null
    
    # borderRadius: BorderRadius.circular(X)), -> borderRadius: BorderRadius.circular(X),
    sed -i '' 's/borderRadius: BorderRadius.circular(\([0-9]*\))),/borderRadius: BorderRadius.circular(\1),/g' "$file" 2>/dev/null
    
    # 빈 맵 리터럴 수정
    sed -i '' "s/{'\\\\1': '\\\\2':/{'id':/g" "$file" 2>/dev/null
done

echo "수정 완료!"