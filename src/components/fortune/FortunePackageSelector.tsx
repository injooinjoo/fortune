'use client';

import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { CheckCircle2, Circle, Sparkles, Heart, Briefcase, Clover, CalendarDays } from 'lucide-react';
import { cn } from '@/lib/utils';
import { FORTUNE_PACKAGES } from '@/config/fortune-packages';
import { motion } from 'framer-motion';

interface FortunePackage {
  id: string;
  name: string;
  description: string;
  fortunes: string[];
  icon: React.ReactNode;
  color: string;
  recommended?: boolean;
}

const packageData: FortunePackage[] = [
  {
    id: 'TRADITIONAL_PACKAGE',
    name: '전통·사주 패키지',
    description: FORTUNE_PACKAGES.TRADITIONAL_PACKAGE.description,
    fortunes: FORTUNE_PACKAGES.TRADITIONAL_PACKAGE.fortunes,
    icon: <Sparkles className="w-5 h-5" />,
    color: 'from-purple-500 to-pink-500',
    recommended: true
  },
  {
    id: 'DAILY_PACKAGE',
    name: '일일 종합 패키지',
    description: FORTUNE_PACKAGES.DAILY_PACKAGE.description,
    fortunes: FORTUNE_PACKAGES.DAILY_PACKAGE.fortunes,
    icon: <CalendarDays className="w-5 h-5" />,
    color: 'from-blue-500 to-cyan-500'
  },
  {
    id: 'LOVE_PACKAGE_SINGLE',
    name: '연애·인연 패키지',
    description: FORTUNE_PACKAGES.LOVE_PACKAGE_SINGLE.description,
    fortunes: FORTUNE_PACKAGES.LOVE_PACKAGE_SINGLE.fortunes,
    icon: <Heart className="w-5 h-5" />,
    color: 'from-pink-500 to-red-500'
  },
  {
    id: 'CAREER_WEALTH_PACKAGE',
    name: '취업·재물 패키지',
    description: FORTUNE_PACKAGES.CAREER_WEALTH_PACKAGE.description,
    fortunes: FORTUNE_PACKAGES.CAREER_WEALTH_PACKAGE.fortunes,
    icon: <Briefcase className="w-5 h-5" />,
    color: 'from-green-500 to-emerald-500'
  },
  {
    id: 'LUCKY_ITEMS_PACKAGE',
    name: '행운 아이템 패키지',
    description: FORTUNE_PACKAGES.LUCKY_ITEMS_PACKAGE.description,
    fortunes: FORTUNE_PACKAGES.LUCKY_ITEMS_PACKAGE.fortunes,
    icon: <Clover className="w-5 h-5" />,
    color: 'from-yellow-500 to-orange-500'
  }
];

interface FortunePackageSelectorProps {
  onSelectPackage: (packageId: string) => void;
  selectedPackage?: string;
  loading?: boolean;
}

export function FortunePackageSelector({
  onSelectPackage,
  selectedPackage,
  loading = false
}: FortunePackageSelectorProps) {
  const [hoveredPackage, setHoveredPackage] = useState<string | null>(null);

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {packageData.map((pkg, index) => {
        const isSelected = selectedPackage === pkg.id;
        const isHovered = hoveredPackage === pkg.id;

        return (
          <motion.div
            key={pkg.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <Card
              className={cn(
                'relative cursor-pointer transition-all duration-300 hover:shadow-lg',
                isSelected && 'ring-2 ring-primary',
                loading && 'opacity-50 cursor-not-allowed'
              )}
              onMouseEnter={() => setHoveredPackage(pkg.id)}
              onMouseLeave={() => setHoveredPackage(null)}
              onClick={() => !loading && onSelectPackage(pkg.id)}
            >
              {pkg.recommended && (
                <div className="absolute -top-2 -right-2 z-10">
                  <span className="bg-primary text-primary-foreground text-xs px-2 py-1 rounded-full">
                    추천
                  </span>
                </div>
              )}

              <div className={cn(
                'absolute inset-0 rounded-lg opacity-10 transition-opacity duration-300',
                `bg-gradient-to-br ${pkg.color}`,
                (isSelected || isHovered) && 'opacity-20'
              )} />

              <CardHeader className="relative">
                <div className="flex items-center justify-between">
                  <div className={cn(
                    'p-2 rounded-lg bg-gradient-to-br text-white',
                    pkg.color
                  )}>
                    {pkg.icon}
                  </div>
                  {isSelected ? (
                    <CheckCircle2 className="w-5 h-5 text-primary" />
                  ) : (
                    <Circle className="w-5 h-5 text-muted-foreground" />
                  )}
                </div>
                <CardTitle className="mt-3 text-lg">{pkg.name}</CardTitle>
                <CardDescription className="text-sm">
                  {pkg.description}
                </CardDescription>
              </CardHeader>

              <CardContent className="relative">
                <div className="space-y-2">
                  <p className="text-sm text-muted-foreground">
                    포함된 운세 ({pkg.fortunes.length}개)
                  </p>
                  <div className="flex flex-wrap gap-1">
                    {pkg.fortunes.slice(0, isHovered ? undefined : 3).map((fortune) => (
                      <span
                        key={fortune}
                        className="text-xs bg-secondary text-secondary-foreground px-2 py-1 rounded-full"
                      >
                        {fortune}
                      </span>
                    ))}
                    {!isHovered && pkg.fortunes.length > 3 && (
                      <span className="text-xs text-muted-foreground px-2 py-1">
                        +{pkg.fortunes.length - 3}개
                      </span>
                    )}
                  </div>
                </div>

                {isSelected && (
                  <motion.div
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="mt-4"
                  >
                    <Button
                      size="sm"
                      className="w-full"
                      disabled={loading}
                    >
                      {loading ? '생성 중...' : '이 패키지로 운세 보기'}
                    </Button>
                  </motion.div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        );
      })}
    </div>
  );
}