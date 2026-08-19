'use client';

/**
 * 운세 입력 폼 공용 컨트롤.
 *
 * 마크업/클래스는 `/운세/오늘` 이 이미 쓰던 것을 그대로 옮긴 것이다 —
 * 새 운세 페이지가 늘어나도 시각 언어가 갈라지지 않게 하는 게 목적이라
 * 여기서 클래스명을 바꾸면 안 된다 (globals.css 의 .ondo-* 만 사용).
 *
 * 값은 전부 문자열로 다룬다. 폼 입력은 "비었음"과 "0" 을 구분해야 하는데
 * 숫자 타입으로 올리면 그 구분이 사라지고, Edge Function 에 실을 때만
 * 호출부가 Number(...) 로 바꾸면 되기 때문이다.
 */

import type { ReactNode } from 'react';

/** `apps/mobile-rn/src/screens/profile-edit-screen.tsx` 의 슬롯과 동일한 문자열. */
export const BIRTH_TIME_SLOTS = [
  '모름',
  '00:00~02:00',
  '02:00~04:00',
  '04:00~06:00',
  '06:00~08:00',
  '08:00~10:00',
  '10:00~12:00',
  '12:00~14:00',
  '14:00~16:00',
  '16:00~18:00',
  '18:00~20:00',
  '20:00~22:00',
  '22:00~24:00',
] as const;

export interface ChipOption {
  /** 빈 문자열은 "선택 안 함" 을 뜻한다. */
  value: string;
  label: string;
}

export const GENDER_OPTIONS: ReadonlyArray<ChipOption> = [
  { value: '', label: '선택 안 함' },
  { value: 'male', label: '남성' },
  { value: 'female', label: '여성' },
];

/** '모름' 은 서버에 안 보내는 값이라 빈 문자열로 접는다. */
const BIRTH_TIME_OPTIONS: ReadonlyArray<ChipOption> = BIRTH_TIME_SLOTS.map((slot) => ({
  value: slot === '모름' ? '' : slot,
  label: slot,
}));

function FieldsetRow({ legend, children }: { legend: string; children: ReactNode }) {
  return (
    <fieldset style={{ border: 'none', margin: 0, padding: 0 }}>
      <legend className="ondo-label">{legend}</legend>
      <div className="ondo-row">{children}</div>
    </fieldset>
  );
}

/**
 * 라벨 + 필수 표시.
 *
 * 필수일 때 공백을 라벨 문자열에 붙여 한 덩어리로 넘기는 이유: `{label} <span/>`
 * 처럼 텍스트 노드를 둘로 쪼개면 React 가 그 사이에 `<!-- -->` 분리 주석을
 * 심어 리팩터 전 마크업과 바이트가 달라진다.
 */
function FieldLabel({
  htmlFor,
  label,
  required,
}: {
  htmlFor: string;
  label: string;
  required?: boolean;
}) {
  return (
    <label className="ondo-label" htmlFor={htmlFor}>
      {required ? `${label} ` : label}
      {required ? <span aria-hidden="true">*</span> : null}
    </label>
  );
}

/** 라벨 + 칩 한 줄. 단일 선택. */
export function ChipSelect({
  label,
  options,
  value,
  onChange,
}: {
  label: string;
  options: ReadonlyArray<ChipOption>;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <FieldsetRow legend={label}>
      {options.map((option) => (
        <button
          aria-pressed={value === option.value}
          className="ondo-chip"
          key={option.label}
          onClick={() => onChange(option.value)}
          type="button"
        >
          {option.label}
        </button>
      ))}
    </FieldsetRow>
  );
}

export function BirthDateField({
  id = 'birth-date',
  name = 'birthDate',
  label = '생년월일',
  required = true,
  value,
  onChange,
}: {
  id?: string;
  name?: string;
  label?: string;
  required?: boolean;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <div>
      <FieldLabel htmlFor={id} label={label} required={required} />
      <input
        className="ondo-input"
        id={id}
        max={new Date().toISOString().slice(0, 10)}
        name={name}
        onChange={(event) => onChange(event.target.value)}
        required={required}
        type="date"
        value={value}
      />
    </div>
  );
}

/** 12지시 + '모름'. 선택 안 하면 빈 문자열 → 호출부에서 undefined 로 접어 보낸다. */
export function BirthTimeChips({
  label = '태어난 시간 (선택)',
  value,
  onChange,
}: {
  label?: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return <ChipSelect label={label} onChange={onChange} options={BIRTH_TIME_OPTIONS} value={value} />;
}

export function GenderChips({
  label = '성별 (선택)',
  value,
  onChange,
}: {
  label?: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return <ChipSelect label={label} onChange={onChange} options={GENDER_OPTIONS} value={value} />;
}

export function TextField({
  id,
  label,
  value,
  onChange,
  placeholder,
  required = false,
  maxLength,
}: {
  id: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  required?: boolean;
  maxLength?: number;
}) {
  return (
    <div>
      <FieldLabel htmlFor={id} label={label} required={required} />
      <input
        className="ondo-input"
        id={id}
        maxLength={maxLength}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        required={required}
        type="text"
        value={value}
      />
    </div>
  );
}

export function TextArea({
  id,
  label,
  value,
  onChange,
  placeholder,
  required = false,
  rows = 4,
  maxLength,
}: {
  id: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  required?: boolean;
  rows?: number;
  maxLength?: number;
}) {
  return (
    <div>
      <FieldLabel htmlFor={id} label={label} required={required} />
      <textarea
        className="ondo-input"
        id={id}
        maxLength={maxLength}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        required={required}
        rows={rows}
        style={{ resize: 'vertical' }}
        value={value}
      />
    </div>
  );
}

export function NumberField({
  id,
  label,
  value,
  onChange,
  placeholder,
  required = false,
  min,
  max,
  step,
}: {
  id: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  required?: boolean;
  min?: number;
  max?: number;
  step?: number;
}) {
  return (
    <div>
      <FieldLabel htmlFor={id} label={label} required={required} />
      <input
        className="ondo-input"
        id={id}
        inputMode="numeric"
        max={max}
        min={min}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        required={required}
        step={step}
        type="number"
        value={value}
      />
    </div>
  );
}
