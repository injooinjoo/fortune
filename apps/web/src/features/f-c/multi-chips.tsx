'use client';

/**
 * 복수 선택 칩.
 *
 * kit(`@/features/fortune/fields`)의 `ChipSelect` 는 단일 선택이라, 배열을
 * 요구하는 필드(재물운 `interests`, 건강운 `concerned_body_parts`)를 담을 수
 * 없어 여기만 추가한다. 마크업/클래스는 `ChipSelect` 와 동일하게 맞춰 시각
 * 언어가 갈라지지 않게 했다.
 *
 * `max` 는 재물운 때문에 있다 — `fortune-wealth` 는 선택한 관심 분야 하나마다
 * JSON 스키마 블록을 프롬프트에 덧붙이는데 (index.ts:429~437) maxTokens 가
 * 4096 이라, 많이 고를수록 응답이 중간에 잘릴 위험이 커진다.
 */

import type { ChipOption } from '@/features/fortune/fields';

export function MultiChipSelect({
  label,
  options,
  values,
  onChange,
  max,
}: {
  label: string;
  options: ReadonlyArray<ChipOption>;
  values: string[];
  onChange: (values: string[]) => void;
  max?: number;
}) {
  const atMax = max !== undefined && values.length >= max;

  function toggle(value: string) {
    if (values.includes(value)) {
      onChange(values.filter((entry) => entry !== value));
      return;
    }
    if (atMax) return;
    onChange([...values, value]);
  }

  return (
    <fieldset style={{ border: 'none', margin: 0, padding: 0 }}>
      <legend className="ondo-label">{label}</legend>
      <div className="ondo-row">
        {options.map((option) => {
          const selected = values.includes(option.value);
          // 상한에 걸린 미선택 칩은 눌러도 아무 일이 없으므로 눌리지 않는다는
          // 것을 눈으로도 보여준다. 색은 토큰 밖으로 나가지 않게 투명도만 쓴다.
          const blocked = atMax && !selected;
          return (
            <button
              aria-pressed={selected}
              className="ondo-chip"
              disabled={blocked}
              key={option.value}
              onClick={() => toggle(option.value)}
              style={blocked ? { opacity: 0.5, cursor: 'not-allowed' } : undefined}
              type="button"
            >
              {option.label}
            </button>
          );
        })}
      </div>
    </fieldset>
  );
}
