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

import { useEffect, useMemo, useRef, useState, type KeyboardEvent, type ReactNode } from 'react';

import {
  createBirthYearOptions,
  daysInMonth,
  joinBirthDate,
  readGuestFortuneProfile,
  rememberGuestFortuneProfile,
  splitBirthDate,
} from './guest-profile';

export function getYearListLayout({
  triggerTop,
  triggerBottom,
  viewportHeight,
}: {
  triggerTop: number;
  triggerBottom: number;
  viewportHeight: number;
}): { placement: 'above' | 'below'; maxHeight: number } {
  const viewportPadding = 8;
  const listGap = 8;
  const spaceAbove = triggerTop - viewportPadding - listGap;
  const spaceBelow = viewportHeight - triggerBottom - viewportPadding - listGap;
  const placement = spaceBelow >= 280 || spaceBelow >= spaceAbove ? 'below' : 'above';
  const available = placement === 'below' ? spaceBelow : spaceAbove;
  return {
    placement,
    maxHeight: Math.max(88, Math.min(280, Math.floor(available))),
  };
}

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

const PREFERRED_BIRTH_YEAR = 1990;

function YearPicker({
  id,
  value,
  years,
  onChange,
}: {
  id: string;
  value: string;
  years: ReadonlyArray<number>;
  onChange: (value: string) => void;
}) {
  const [open, setOpen] = useState(false);
  const [listPlacement, setListPlacement] = useState<'above' | 'below'>('below');
  const [listMaxHeight, setListMaxHeight] = useState(280);
  const rootRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const listRef = useRef<HTMLDivElement>(null);
  const preferredRef = useRef<HTMLButtonElement>(null);
  const selectedRef = useRef<HTMLButtonElement>(null);
  const listId = `${id}-year-listbox`;

  useEffect(() => {
    if (!open) return;
    const frame = requestAnimationFrame(() => {
      const list = listRef.current;
      const target = selectedRef.current ?? preferredRef.current;
      if (!list || !target) return;
      list.scrollTop = target.offsetTop - list.clientHeight / 2 + target.offsetHeight / 2;
      target.focus({ preventScroll: true });
    });
    return () => cancelAnimationFrame(frame);
  }, [open, value]);

  useEffect(() => {
    if (!open) return;
    function closeOutside(event: PointerEvent) {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false);
    }
    document.addEventListener('pointerdown', closeOutside);
    return () => document.removeEventListener('pointerdown', closeOutside);
  }, [open]);

  function selectYear(next: number) {
    onChange(String(next));
    setOpen(false);
    requestAnimationFrame(() => triggerRef.current?.focus());
  }

  function openList() {
    const trigger = triggerRef.current;
    if (trigger) {
      const rect = trigger.getBoundingClientRect();
      const { placement, maxHeight } = getYearListLayout({
        triggerTop: rect.top,
        triggerBottom: rect.bottom,
        viewportHeight: window.innerHeight,
      });
      setListPlacement(placement);
      setListMaxHeight(maxHeight);
    }
    setOpen(true);
  }

  function handleListKeyDown(event: KeyboardEvent<HTMLDivElement>) {
    if (event.key === 'Escape') {
      event.preventDefault();
      setOpen(false);
      triggerRef.current?.focus();
      return;
    }
    if (!['ArrowDown', 'ArrowUp', 'Home', 'End'].includes(event.key)) return;
    event.preventDefault();
    const options = [...event.currentTarget.querySelectorAll<HTMLButtonElement>('[role="option"]')];
    const activeIndex = options.indexOf(document.activeElement as HTMLButtonElement);
    const nextIndex = event.key === 'Home'
      ? 0
      : event.key === 'End'
        ? options.length - 1
        : Math.min(options.length - 1, Math.max(0, activeIndex + (event.key === 'ArrowDown' ? 1 : -1)));
    options[nextIndex]?.focus();
    options[nextIndex]?.scrollIntoView({ block: 'nearest' });
  }

  return (
    <div className="ondo-year-picker" ref={rootRef}>
      <button
        aria-controls={listId}
        aria-expanded={open}
        aria-haspopup="listbox"
        aria-label="출생 연도"
        className="ondo-input ondo-date-select ondo-year-trigger"
        id={id}
        onClick={() => (open ? setOpen(false) : openList())}
        ref={triggerRef}
        role="combobox"
        type="button"
      >
        {value ? `${value}년` : '연도'}
      </button>
      {open ? (
        <div
          aria-label="출생 연도"
          className="ondo-year-listbox"
          data-placement={listPlacement}
          id={listId}
          onKeyDown={handleListKeyDown}
          ref={listRef}
          role="listbox"
          style={{ maxHeight: listMaxHeight }}
        >
          {years.map((option) => {
            const selected = value === String(option);
            return (
              <button
                aria-selected={selected}
                className="ondo-year-option"
                key={option}
                onClick={() => selectYear(option)}
                ref={selected ? selectedRef : option === PREFERRED_BIRTH_YEAR ? preferredRef : undefined}
                role="option"
                tabIndex={-1}
                type="button"
              >
                {option}년
              </button>
            );
          })}
        </div>
      ) : null}
    </div>
  );
}

export function BirthDateField({
  id = 'birth-date',
  name = 'birthDate',
  label = '생년월일',
  required = true,
  remember = true,
  value,
  onChange,
}: {
  id?: string;
  name?: string;
  label?: string;
  required?: boolean;
  remember?: boolean;
  value: string;
  onChange: (value: string) => void;
}) {
  const initial = splitBirthDate(value);
  const [year, setYear] = useState(initial.year);
  const [month, setMonth] = useState(initial.month);
  const [day, setDay] = useState(initial.day);
  const [restored, setRestored] = useState(false);
  const years = useMemo(() => createBirthYearOptions(), []);
  const dayCount = year && month ? daysInMonth(Number(year), Number(month)) : 31;

  useEffect(() => {
    if (!remember || value) return;
    const remembered = readGuestFortuneProfile().birthDate;
    if (!remembered) return;
    const parts = splitBirthDate(remembered);
    if (!parts.year) return;
    setYear(parts.year);
    setMonth(parts.month);
    setDay(parts.day);
    setRestored(true);
    onChange(remembered);
  }, [onChange, remember, value]);

  function updateParts(nextYear: string, nextMonth: string, nextDay: string) {
    let safeDay = nextDay;
    if (nextYear && nextMonth && nextDay) {
      safeDay = String(Math.min(Number(nextDay), daysInMonth(Number(nextYear), Number(nextMonth))));
    }
    setYear(nextYear);
    setMonth(nextMonth);
    setDay(safeDay);
    setRestored(false);
    const next = joinBirthDate(nextYear, nextMonth, safeDay);
    onChange(next);
    if (remember) rememberGuestFortuneProfile({ birthDate: next || null });
  }

  return (
    <div className="ondo-birth-date-field">
      <FieldLabel htmlFor={id} label={label} required={required} />
      <div className="ondo-date-selects">
        <YearPicker
          id={id}
          onChange={(nextYear) => updateParts(nextYear, month, day)}
          value={year}
          years={years}
        />
        <select
          aria-label="출생 월"
          className="ondo-input ondo-date-select"
          onChange={(event) => updateParts(year, event.target.value, day)}
          required={required}
          value={month}
        >
          <option value="">월</option>
          {Array.from({ length: 12 }, (_, index) => index + 1).map((option) => (
            <option key={option} value={option}>{option}월</option>
          ))}
        </select>
        <select
          aria-label="출생 일"
          className="ondo-input ondo-date-select"
          onChange={(event) => updateParts(year, month, event.target.value)}
          required={required}
          value={day}
        >
          <option value="">일</option>
          {Array.from({ length: dayCount }, (_, index) => index + 1).map((option) => (
            <option key={option} value={option}>{option}일</option>
          ))}
        </select>
      </div>
      <input name={name} type="hidden" value={value} />
      {restored ? <p className="ondo-field-hint">앞에서 입력한 정보를 불러왔어요.</p> : null}
    </div>
  );
}

/** 12지시 + '모름'. 선택 안 하면 빈 문자열 → 호출부에서 undefined 로 접어 보낸다. */
export function BirthTimeChips({
  label = '태어난 시간 (선택)',
  progressivelyRevealOnMobile = false,
  value,
  onChange,
}: {
  label?: string;
  progressivelyRevealOnMobile?: boolean;
  value: string;
  onChange: (value: string) => void;
}) {
  const [mobileExpanded, setMobileExpanded] = useState(false);
  const mobileToggleRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (value) return;
    const remembered = readGuestFortuneProfile().birthTime;
    if (remembered) onChange(remembered);
  }, [onChange, value]);

  function commit(next: string, collapseMobile = false) {
    onChange(next);
    rememberGuestFortuneProfile({ birthTime: next || null });
    if (!collapseMobile) return;
    setMobileExpanded(false);
    requestAnimationFrame(() => mobileToggleRef.current?.focus());
  }

  if (progressivelyRevealOnMobile) {
    return (
      <>
        <div className="ondo-birth-time-desktop">
          <ChipSelect label={label} onChange={commit} options={BIRTH_TIME_OPTIONS} value={value} />
        </div>
        <fieldset className="ondo-birth-time-mobile">
          <legend className="ondo-label">{label}</legend>
          <button
            aria-expanded={mobileExpanded}
            className="ondo-birth-time-toggle"
            onClick={() => setMobileExpanded((expanded) => !expanded)}
            ref={mobileToggleRef}
            type="button"
          >
            {mobileExpanded
              ? '시간 선택 닫기'
              : value
                ? `${value} 선택됨 · 바꾸기`
                : '태어난 시간을 알고 있어요'}
          </button>
          {mobileExpanded ? (
            <div className="ondo-row">
              {BIRTH_TIME_OPTIONS.map((option) => (
                <button
                  aria-pressed={value === option.value}
                  className="ondo-chip"
                  key={option.label}
                  onClick={() => commit(option.value, true)}
                  type="button"
                >
                  {option.label}
                </button>
              ))}
            </div>
          ) : null}
        </fieldset>
      </>
    );
  }

  return (
    <ChipSelect
      label={label}
      onChange={commit}
      options={BIRTH_TIME_OPTIONS}
      value={value}
    />
  );
}

export function GenderChips({
  label = '성별 (선택)',
  required = false,
  value,
  onChange,
}: {
  label?: string;
  required?: boolean;
  value: string;
  onChange: (value: string) => void;
}) {
  useEffect(() => {
    if (value) return;
    const remembered = readGuestFortuneProfile().gender;
    if (remembered) onChange(remembered);
  }, [onChange, value]);

  const options = required ? GENDER_OPTIONS.filter((option) => option.value !== '') : GENDER_OPTIONS;
  return (
    <ChipSelect
      label={label}
      onChange={(next) => {
        onChange(next);
        rememberGuestFortuneProfile({
          gender: next === 'female' || next === 'male' ? next : null,
        });
      }}
      options={options}
      value={value}
    />
  );
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
