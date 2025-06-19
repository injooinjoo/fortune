"use client";

import Image from 'next/image';
import Link from 'next/link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Heart, Laugh, Star } from 'lucide-react';

interface SpecialItem {
  id: string;
  title: string;
  description: string;
  image: string;
  href: string;
}

const banner = {
  title: '새로운 반려동물 사주 OPEN!',
  description: '우리집 댕냥이의 운세를 지금 확인해보세요.',
  image: 'https://placehold.co/600x240/png',
  href: '/fortune/pet',
};

const loveFortunes: SpecialItem[] = [
  {
    id: 'celebrity',
    title: '연예인 궁합',
    description: '최애와의 궁합은?',
    image: 'https://placehold.co/300x160/png',
    href: '/fortune/celebrity-match',
  },
  {
    id: 'marriage',
    title: '결혼 운세',
    description: '평생의 인연을 찾아보세요',
    image: 'https://placehold.co/300x160/png',
    href: '/fortune/marriage',
  },
  {
    id: 'breakup',
    title: '이별 운세',
    description: '다시 만날 수 있을까요?',
    image: 'https://placehold.co/300x160/png',
    href: '/fortune/breakup',
  },
];

const funContents: SpecialItem[] = [
  {
    id: 'name',
    title: '이름풀이',
    description: '내 이름에 숨겨진 의미',
    image: 'https://placehold.co/300x160/png',
    href: '/fortune/name',
  },
  {
    id: 'nickname',
    title: 'SNS 닉네임 운세',
    description: '닉네임으로 보는 나의 운',
    image: 'https://placehold.co/300x160/png',
    href: '/fortune/nickname',
  },
];

export default function SpecialPage() {
  return (
    <div className="space-y-8 px-4 py-6">
      {/* Banner Section */}
      <Link href={banner.href} className="block">
        <Card className="overflow-hidden">
          <div className="relative h-40 w-full">
            <Image src={banner.image} alt="banner" fill className="object-cover" />
          </div>
          <CardHeader>
            <CardTitle className="flex items-center text-lg">
              <Star className="mr-2 h-5 w-5 text-yellow-500" />
              {banner.title}
            </CardTitle>
            <CardDescription>{banner.description}</CardDescription>
          </CardHeader>
        </Card>
      </Link>

      {/* Category Section */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold flex items-center">
          <Heart className="mr-2 h-5 w-5 text-pink-500" />
          연애/궁합
        </h2>
        <div className="grid grid-cols-2 gap-3">
          {loveFortunes.map((item) => (
            <Link href={item.href} key={item.id} className="block">
              <Card>
                <div className="relative h-24 w-full">
                  <Image src={item.image} alt={item.title} fill className="object-cover rounded-t-md" />
                </div>
                <CardContent className="p-3">
                  <p className="font-medium text-sm mb-1">{item.title}</p>
                  <p className="text-xs text-muted-foreground">{item.description}</p>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>

      {/* Fun Section */}
      <section className="space-y-4">
        <h2 className="text-xl font-bold flex items-center">
          <Laugh className="mr-2 h-5 w-5 text-purple-500" />
          재미로 보는 운세
        </h2>
        <div className="grid grid-cols-2 gap-3">
          {funContents.map((item) => (
            <Link href={item.href} key={item.id} className="block">
              <Card>
                <div className="relative h-24 w-full">
                  <Image src={item.image} alt={item.title} fill className="object-cover rounded-t-md" />
                </div>
                <CardContent className="p-3">
                  <p className="font-medium text-sm mb-1">{item.title}</p>
                  <p className="text-xs text-muted-foreground">{item.description}</p>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
