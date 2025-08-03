# Flutter 런타임 에러 전체 분석

## 📊 에러 요약
- **총 에러 수**: 96개
- **영향받는 파일**: 28개
- **에러 타입**: 3가지

## 🔍 에러 타입별 분류

### 1. Final 필드 초기화 에러 (90개) - 93.8%
**에러 메시지**: "Final field 'xxx' is not initialized"
**원인**: 클래스의 final 필드가 생성자에서 초기화되지 않음
**해결 방법**: 생성자에 required 또는 optional 파라미터 추가

### 2. 상수 표현식 에러 (6개) - 6.2%
**에러 메시지**: "Non-constant list literal is not a constant expression"
**원인**: const 위젯에서 non-const 리스트나 값 사용
**해결 방법**: const 키워드 제거

### 3. 타입 시스템 에러 (1개)
**에러 메시지**: "Unsupported invalid type InvalidType"
**파일**: screenshot_detection_service.dart
**원인**: Function 타입 정의 오류
**해결 방법**: 타입 정의 명확하게 수정

## 📁 파일별 에러 분포

### Final 필드 초기화 에러가 많은 파일 TOP 10
1. `loading_states.dart` - 10개
2. `social_accounts_section.dart` - 8개
3. `todo_provider.dart` - 8개
4. `glass_effects.dart` - 7개
5. `user_info_card.dart` - 5개
6. `simple_fortune_info_sheet.dart` - 5개
7. `custom_calendar_date_picker.dart` - 5개
8. `five_elements_explanation_bottom_sheet.dart` - 4개
9. `saju_element_explanation_bottom_sheet.dart` - 4개
10. `fcm_service.dart` - 4개

### 상수 표현식 에러가 있는 파일
1. `same_birthday_celebrity_fortune_page.dart` - 2개
2. `tarot_enhanced_page.dart` - 2개
3. `five_elements_widget.dart` - 2개

## 🎯 수정 우선순위
1. **Final 필드 초기화** - 가장 많은 에러, 비교적 쉬운 수정
2. **상수 표현식** - 적은 수의 에러, 간단한 수정
3. **타입 시스템** - 1개 에러, 신중한 수정 필요