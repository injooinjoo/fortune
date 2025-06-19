# Page snapshot

```yaml
- banner:
  - button "이전 단계로":
    - img
  - heading "사주정보 입력" [level=1]
- main:
  - text: STEP 2 / 3 생년월일과 태어난 시간을 알려주세요. 이름
  - textbox "이름": 김
  - text: STEP 2 / 3 생년월일과 태어난 시간을 알려주세요. 생년월일
  - combobox: 1990년
  - combobox: 월
  - combobox [disabled]: 일
  - text: 태어난 시
  - combobox "태어난 시":
    - img
    - text: 모름
  - button "이전"
  - button "다음"
- contentinfo:
  - paragraph: © 2025 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.
- region "Notifications (F8)":
  - list
- button "Open Next.js Dev Tools":
  - img
- alert
```