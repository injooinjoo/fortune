'use client';

import React, { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import AppHeader from '@/components/AppHeader';
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion';
import { cn } from '@/lib/utils';

interface TarotCard {
  id: number;
  name: string;
  image: string;
  keywords: string[];
}

interface SelectedCard extends TarotCard {
  orientation: 'upright' | 'reversed';
}

interface TarotReading {
  position: string;
  text: string;
}

const tarotCards: TarotCard[] = [
  {
    id: 1,
    name: 'THE FOOL',
    image: 'https://via.placeholder.com/150x240?text=The+Fool',
    keywords: ['새출발', '순수'],
  },
  {
    id: 2,
    name: 'THE MAGICIAN',
    image: 'https://via.placeholder.com/150x240?text=Magician',
    keywords: ['능력', '집중'],
  },
  {
    id: 3,
    name: 'THE HIGH PRIESTESS',
    image: 'https://via.placeholder.com/150x240?text=Priestess',
    keywords: ['직관', '비밀'],
  },
  {
    id: 4,
    name: 'THE EMPRESS',
    image: 'https://via.placeholder.com/150x240?text=Empress',
    keywords: ['풍요', '모성'],
  },
  {
    id: 5,
    name: 'THE EMPEROR',
    image: 'https://via.placeholder.com/150x240?text=Emperor',
    keywords: ['권위', '안정'],
  },
  {
    id: 6,
    name: 'THE LOVERS',
    image: 'https://via.placeholder.com/150x240?text=Lovers',
    keywords: ['사랑', '조화'],
  },
  {
    id: 7,
    name: 'THE CHARIOT',
    image: 'https://via.placeholder.com/150x240?text=Chariot',
    keywords: ['승리', '의지'],
  },
  {
    id: 8,
    name: 'STRENGTH',
    image: 'https://via.placeholder.com/150x240?text=Strength',
    keywords: ['용기', '인내'],
  },
  {
    id: 9,
    name: 'THE HERMIT',
    image: 'https://via.placeholder.com/150x240?text=Hermit',
    keywords: ['탐구', '고독'],
  },
  {
    id: 10,
    name: 'WHEEL OF FORTUNE',
    image: 'https://via.placeholder.com/150x240?text=Wheel+of+Fortune',
    keywords: ['기회', '변화'],
  },
];

function getTarotReading(selected: SelectedCard[]): Promise<TarotReading[]> {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve([
        {
          position: '과거',
          text: `${selected[0].name} 카드가 과거의 영향을 나타냅니다.`,
        },
        {
          position: '현재',
          text: `${selected[1].name} 카드가 현재 상황을 보여줍니다.`,
        },
        {
          position: '미래',
          text: `${selected[2].name} 카드가 미래의 가능성을 암시합니다.`,
        },
      ]);
    }, 1000);
  });
}

export default function InteractiveTarotPage() {
  const [step, setStep] = useState<'question' | 'shuffling' | 'selection' | 'result'>('question');
  const [selectedCards, setSelectedCards] = useState<SelectedCard[]>([]);
  const [readings, setReadings] = useState<TarotReading[]>([]);

  useEffect(() => {
    if (step === 'shuffling') {
      const t = setTimeout(() => setStep('selection'), 2500);
      return () => clearTimeout(t);
    }
  }, [step]);

  useEffect(() => {
    if (step === 'result') {
      getTarotReading(selectedCards).then(setReadings);
    }
  }, [step, selectedCards]);

  const handleSelectCard = (card: TarotCard) => {
    if (selectedCards.find((c) => c.id === card.id) || selectedCards.length >= 3) {
      return;
    }
    const orientation: 'upright' | 'reversed' = Math.random() > 0.5 ? 'upright' : 'reversed';
    setSelectedCards([...selectedCards, { ...card, orientation }]);
  };

  const reset = () => {
    setSelectedCards([]);
    setReadings([]);
    setStep('question');
  };

  return (
    <>
      <AppHeader title="타로 카드" showBack={false} />
      <div className="pb-32 flex flex-col items-center bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 text-gray-900 dark:text-gray-100 p-4 space-y-6 pt-4 min-h-screen">
        {step === 'question' && (
          <div className="text-center space-y-4">
            <p className="text-lg text-gray-800 dark:text-gray-200">마음속으로 궁금한 질문 하나에 집중해주세요.</p>
            <Button 
              onClick={() => setStep('shuffling')}
              className="bg-purple-600 hover:bg-purple-700 dark:bg-purple-500 dark:hover:bg-purple-600 text-white"
            >
              카드 섞기
            </Button>
          </div>
        )}

        {step === 'shuffling' && (
          <div className="flex flex-col items-center space-y-4">
            <p className="text-lg text-gray-800 dark:text-gray-200">카드를 섞고 있습니다...</p>
            <div className="animate-spin h-10 w-10 border-4 border-purple-600 dark:border-purple-400 border-t-transparent rounded-full" />
          </div>
        )}

        {step === 'selection' && (
          <div className="w-full max-w-md space-y-4">
            <p className="text-center text-gray-800 dark:text-gray-200">가장 마음이 이끌리는 카드 3장을 선택해주세요.</p>
            <div className="grid grid-cols-5 gap-2">
              {tarotCards.map((card) => {
                const selected = selectedCards.some((c) => c.id === card.id);
                return (
                  <div
                    key={card.id}
                    className={cn(
                      'relative cursor-pointer rounded-md overflow-hidden border-2 transition-all',
                      selected 
                        ? 'ring-2 ring-purple-500 dark:ring-purple-400 border-purple-500 dark:border-purple-400' 
                        : 'border-gray-200 dark:border-gray-600 hover:border-purple-300 dark:hover:border-purple-500'
                    )}
                    onClick={() => handleSelectCard(card)}
                  >
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src="https://via.placeholder.com/150x240?text=Tarot"
                      alt="Tarot card"
                      className="w-full h-auto transition-transform hover:scale-105"
                    />
                  </div>
                );
              })}
            </div>
            <Button
              disabled={selectedCards.length !== 3}
              onClick={() => setStep('result')}
              className="w-full bg-purple-600 hover:bg-purple-700 disabled:bg-gray-400 dark:bg-purple-500 dark:hover:bg-purple-600 dark:disabled:bg-gray-600 text-white"
            >
              결과 보기
            </Button>
          </div>
        )}

        {step === 'result' && (
          <div className="w-full max-w-md space-y-6">
            <div className="flex justify-center space-x-2">
              {selectedCards.map((card) => (
                <div key={card.id} className="text-center w-24">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={card.image} alt={card.name} className="w-24 h-auto mx-auto mb-2" />
                  <p className="text-sm font-semibold">{card.name}</p>
                  <p className="text-xs text-muted-foreground mb-1">
                    {card.orientation === 'upright' ? '정방향' : '역방향'}
                  </p>
                  <div className="flex flex-wrap justify-center gap-1">
                    {card.keywords.map((k) => (
                      <Badge key={k} variant="secondary">
                        {k}
                      </Badge>
                    ))}
                  </div>
                </div>
              ))}
            </div>

            <Accordion type="single" collapsible className="w-full">
              {readings.map((r) => (
                <AccordionItem key={r.position} value={r.position}>
                  <AccordionTrigger>{r.position}</AccordionTrigger>
                  <AccordionContent>
                    <p>{r.text}</p>
                  </AccordionContent>
                </AccordionItem>
              ))}
            </Accordion>

            <Button onClick={reset} className="w-full">
              다시하기
            </Button>
          </div>
        )}
      </div>
    </>
  );
}

