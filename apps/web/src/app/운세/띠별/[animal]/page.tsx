import type { Metadata } from 'next';
import { fortuneHref } from '@/lib/href';
import Link from 'next/link';
import { notFound } from 'next/navigation';

import { ZodiacForm } from '@/features/f-b/zodiac-form';
import { ZODIAC_ANIMALS, birthYearsOf, findZodiacAnimal } from '@/features/f-b/zodiac-animals';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 띠 하나짜리 공개 페이지 — "호랑이띠 운세" 류 검색어의 착지점.
 *
 * 경로 조각이 곧 띠 이름이라 12개 URL 이 정적으로 만들어진다.
 */
type PageProps = { params: Promise<{ animal: string }> };

export function generateStaticParams(): Array<{ animal: string }> {
  return ZODIAC_ANIMALS.map((animal) => ({ animal: animal.name }));
}

/** 퍼센트 인코딩된 한글 조각으로 들어올 수도 있어 한 번 더 디코딩한다. */
function decodeSegment(value: string): string {
  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const animal = findZodiacAnimal(decodeSegment((await params).animal));
  if (!animal) return {};

  const years = birthYearsOf(animal).join(', ');

  return {
    // 연도 목록은 description 에만 둔다 — 제목에 7개를 나열하면 SERP 에서 잘린다.
    title: `${animal.name}띠 오늘의 운세`,
    description: `${animal.name}띠(${animal.branch}, ${animal.element}) 오늘의 운세를 대인·실행·감정·타이밍으로 나눠 읽어드려요. ${years}년생이 ${animal.name}띠예요.`,
    alternates: { canonical: `/운세/띠별/${animal.name}` },
  };
}

export default async function ZodiacAnimalPage({ params }: PageProps) {
  const animal = findZodiacAnimal(decodeSegment((await params).animal));
  if (!animal) notFound();

  const years = birthYearsOf(animal).join(', ');

  return (
    <FortunePageShell
      description={`${years}년생이 ${animal.name}띠예요. (${animal.branch} · ${animal.element})`}
      kicker={`${animal.emoji} ${animal.name}띠`}
      title={`${animal.name}띠 오늘의 운세`}
    >
      <ZodiacForm initialAnimal={animal.name} />

      <p className="ondo-muted">
        <Link href={fortuneHref('띠별')}>다른 띠 보기</Link>
      </p>
    </FortunePageShell>
  );
}
