import type { Metadata } from 'next';
import { fortuneHref } from '@/lib/href';
import { AppLink as Link } from '@/components/app-link';
import { notFound } from 'next/navigation';

import { MbtiForm } from '@/features/f-b/mbti-form';
import { MBTI_TYPES, findMbtiType } from '@/features/f-b/mbti-types';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 유형 하나짜리 공개 페이지 — "INTJ 운세" 류 검색어의 착지점.
 *
 * `findMbtiType` 이 대문자로 정규화하므로 소문자 경로(/운세/엠비티아이/intj)도
 * 같은 내용을 보여준다. canonical 은 언제나 대문자 URL 을 가리켜 중복을 접는다.
 */
type PageProps = { params: Promise<{ type: string }> };

export function generateStaticParams(): Array<{ type: string }> {
  return MBTI_TYPES.map((type) => ({ type: type.id }));
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const type = findMbtiType((await params).type);
  if (!type) return {};

  return {
    title: `${type.id} 오늘의 운세 — ${type.nickname}`,
    description: `${type.id}(${type.nickname})의 오늘 운세를 네 차원으로 나눠 읽어드려요. 오늘 조심할 함정과 잘 맞는 유형까지 함께 알려드려요.`,
    alternates: { canonical: `/운세/엠비티아이/${type.id}` },
  };
}

export default async function MbtiTypePage({ params }: PageProps) {
  const type = findMbtiType((await params).type);
  if (!type) notFound();

  return (
    <FortunePageShell
      description={`${type.id}는 ‘${type.nickname}’ 유형이에요. 오늘 이 성향이 어떻게 작동하는지 읽어드려요.`}
      kicker={`${type.id} · ${type.nickname}`}
      title={`${type.id} 오늘의 운세`}
    >
      <MbtiForm initialMbti={type.id} />

      <p className="ondo-muted">
        <Link href={fortuneHref('엠비티아이')}>다른 유형 보기</Link>
      </p>
    </FortunePageShell>
  );
}
