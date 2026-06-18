import {
  canReuseEmbeddedResultMessage,
  isSameKstCalendarDay,
  parseGeneratedResultTimestampMs,
} from './reuse-policy';

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function resultMessage(
  id: string,
  fortuneType = 'daily',
  generatedAt?: string,
) {
  return {
    id,
    kind: 'embedded-result',
    sender: 'assistant',
    embeddedWidgetType: 'fortune_result_card',
    fortuneType,
    resultKind: 'daily',
    title: '오늘 흐름',
    payload: {
      id: 'test-payload',
      fortuneType,
      resultKind: 'daily',
      title: '오늘 흐름',
      summary: '테스트',
      ...(generatedAt ? { generatedAt } : {}),
      score: 80,
    },
  } as never;
}

function idAt(timestampMs: number): string {
  return `result-${timestampMs}-test`;
}

{
  const timestamp = Date.UTC(2026, 5, 17, 1, 0, 0);
  assert(
    parseGeneratedResultTimestampMs(idAt(timestamp)) === timestamp,
    'generated result id에서 Date.now() timestamp를 읽어야 한다',
  );
  assert(
    parseGeneratedResultTimestampMs('legacy-result-id') === null,
    'legacy/non-generated id는 timestamp unknown으로 처리해야 한다',
  );
}

{
  const june17MorningKst = Date.UTC(2026, 5, 16, 22, 30, 0); // KST 2026-06-17 07:30
  const june17NightKst = Date.UTC(2026, 5, 17, 14, 30, 0); // KST 2026-06-17 23:30
  assert(
    isSameKstCalendarDay(june17MorningKst, june17NightKst),
    'KST 기준 같은 날짜면 같은 daily 결과 재사용을 허용한다',
  );
}

{
  const june11Kst = Date.UTC(2026, 5, 11, 3, 0, 0);
  const june17Kst = Date.UTC(2026, 5, 17, 3, 0, 0);
  assert(
    !canReuseEmbeddedResultMessage(
      resultMessage(idAt(june11Kst), 'daily', new Date(june11Kst).toISOString()),
      'daily',
      june17Kst,
    ),
    '오늘의 운세 daily 결과는 KST 날짜가 바뀌면 재사용하면 안 된다',
  );
  assert(
    !canReuseEmbeddedResultMessage(
      resultMessage(
        idAt(june11Kst),
        'daily-calendar',
        new Date(june11Kst).toISOString(),
      ),
      'daily-calendar',
      june17Kst,
    ),
    '오늘의 운세 daily-calendar 결과도 KST 날짜가 바뀌면 재사용하면 안 된다',
  );
}

{
  const june17MorningKst = Date.UTC(2026, 5, 16, 22, 30, 0);
  const june17NightKst = Date.UTC(2026, 5, 17, 14, 30, 0);
  assert(
    canReuseEmbeddedResultMessage(
      resultMessage(
        idAt(june17MorningKst),
        'daily',
        new Date(june17MorningKst).toISOString(),
      ),
      'daily',
      june17NightKst,
    ),
    'payload 생성일이 KST 기준 오늘이면 daily 결과 재사용을 허용한다',
  );
}

{
  const june11Kst = Date.UTC(2026, 5, 11, 3, 0, 0);
  const june17Kst = Date.UTC(2026, 5, 17, 3, 0, 0);
  assert(
    canReuseEmbeddedResultMessage(
      resultMessage(idAt(june11Kst), 'zodiac'),
      'zodiac',
      june17Kst,
    ),
    'daily가 아닌 일반 운세 결과 재열기는 기존처럼 허용한다',
  );
}

{
  assert(
    !canReuseEmbeddedResultMessage(resultMessage('legacy-result-id'), 'daily'),
    '생성 날짜를 알 수 없는 legacy daily 결과는 stale 방지를 위해 재사용하지 않는다',
  );
}

{
  const june11Kst = Date.UTC(2026, 5, 11, 3, 0, 0);
  const june17Kst = Date.UTC(2026, 5, 17, 3, 0, 0);
  assert(
    !canReuseEmbeddedResultMessage(
      resultMessage(idAt(june17Kst), 'daily', new Date(june11Kst).toISOString()),
      'daily',
      june17Kst,
    ),
    '오래된 payload를 오늘 다시 열어 새 message id가 생겨도 daily는 재사용하면 안 된다',
  );
}
