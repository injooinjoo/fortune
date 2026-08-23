'use client';

import { useState, type FormEvent } from 'react';

import { ChipSelect, type ChipOption } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { ZodiacResult, type ZodiacEnvelope, type ZodiacFortune } from './zodiac-result';
import { ZODIAC_ANIMALS, birthDateForAnimal, findZodiacAnimal } from './zodiac-animals';

const EMPTY_RESPONSE_MESSAGE = '띠별 운세 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.';

const OPTIONS: ReadonlyArray<ChipOption> = ZODIAC_ANIMALS.map((animal) => ({
  value: animal.name,
  label: `${animal.emoji} ${animal.name}`,
}));

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: ZodiacFortune }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

function loginHref(animalName: string | undefined): string {
  const path = animalName ? `/운세/띠별/${animalName}` : '/운세/띠별';
  return `/auth/login?next=${encodeURIComponent(path)}`;
}

/**
 * @param initialAnimal `/운세/띠별/호랑이` 같은 하위 경로에서 미리 고른 띠.
 *                      목록 페이지에서는 비워 둔다.
 *
 * 하위 경로에서는 칩 선택을 숨긴다. 페이지 제목이 이미 "호랑이띠 오늘의 운세"
 * 인데 칩으로 다른 띠를 고를 수 있으면 제목과 결과가 어긋나기 때문이고,
 * 그 대신 페이지가 "다른 띠 보기" 링크로 목록으로 돌려보낸다.
 */
export function ZodiacForm({ initialAnimal }: { initialAnimal?: string }) {
  const [animalName, setAnimalName] = useState(initialAnimal ?? '');
  const [state, setState] = useState<State>({ kind: 'idle' });

  const locked = findZodiacAnimal(initialAnimal ?? '') !== undefined;

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const animal = findZodiacAnimal(animalName);
    if (!animal) return;

    setState({ kind: 'loading' });

    // 보내는 필드는 `birthDate` 하나다. 서버는 여기서 **연도만** 읽어 띠를
    // 도출하고 나머지 응답은 도출된 띠에만 의존한다 (index.ts 의 buildPrompt 는
    // 띠 이름/지지/오행과 이름만 쓴다). `name` 은 생략하면 서버가 '회원님' 으로
    // 채우므로 입력을 하나 줄인다.
    const result = await runFortune<ZodiacEnvelope>('zodiac-animal', {
      birthDate: birthDateForAnimal(animal),
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const fortune = result.data.data;
    if (!fortune) {
      setState({ kind: 'failed', failure: 'error', message: EMPTY_RESPONSE_MESSAGE });
      return;
    }

    setState({ kind: 'done', fortune });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        {locked ? null : (
          <ChipSelect
            label="띠를 골라주세요"
            onChange={setAnimalName}
            options={OPTIONS}
            value={animalName}
          />
        )}

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || animalName.length === 0}
          type="submit"
        >
          {state.kind === 'loading'
            ? '읽는 중…'
            : locked
              ? `${animalName}띠 오늘의 운세 보기`
              : '오늘의 띠별 운세 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice
          kind={state.failure}
          loginHref={loginHref(initialAnimal)}
          message={state.message}
        />
      ) : null}

      {state.kind === 'done' ? <ZodiacResult fortune={state.fortune} /> : null}
    </div>
  );
}
