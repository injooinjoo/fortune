'use client';

import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Sparkles, 
  Heart, 
  Briefcase, 
  Calendar, 
  Clover,
  ChevronRight,
  RefreshCw,
  Share2,
  Download
} from 'lucide-react';
import { BatchFortuneResponse } from '@/types/batch-fortune';
import { format } from 'date-fns';
import { ko } from 'date-fns/locale';
import { cn } from '@/lib/utils';

interface BatchFortuneDisplayProps {
  fortuneData: BatchFortuneResponse | null;
  loading?: boolean;
  onRefresh?: () => void;
  onShare?: (fortuneType: string) => void;
}

const fortuneIcons: Record<string, React.ReactNode> = {
  saju: <Sparkles className="w-4 h-4" />,
  'traditional-saju': <Sparkles className="w-4 h-4" />,
  tojeong: <Sparkles className="w-4 h-4" />,
  salpuli: <Sparkles className="w-4 h-4" />,
  'past-life': <Sparkles className="w-4 h-4" />,
  daily: <Calendar className="w-4 h-4" />,
  hourly: <Calendar className="w-4 h-4" />,
  today: <Calendar className="w-4 h-4" />,
  tomorrow: <Calendar className="w-4 h-4" />,
  love: <Heart className="w-4 h-4" />,
  destiny: <Heart className="w-4 h-4" />,
  'blind-date': <Heart className="w-4 h-4" />,
  'celebrity-match': <Heart className="w-4 h-4" />,
  career: <Briefcase className="w-4 h-4" />,
  wealth: <Briefcase className="w-4 h-4" />,
  business: <Briefcase className="w-4 h-4" />,
  'lucky-investment': <Briefcase className="w-4 h-4" />,
  'lucky-color': <Clover className="w-4 h-4" />,
  'lucky-number': <Clover className="w-4 h-4" />,
  'lucky-items': <Clover className="w-4 h-4" />,
  'lucky-outfit': <Clover className="w-4 h-4" />,
  'lucky-food': <Clover className="w-4 h-4" />
};

const fortuneCategories = {
  traditional: { 
    name: '전통 운세', 
    types: ['saju', 'traditional-saju', 'tojeong', 'salpuli', 'past-life'],
    color: 'from-purple-500 to-pink-500'
  },
  daily: { 
    name: '일일 운세', 
    types: ['daily', 'hourly', 'today', 'tomorrow'],
    color: 'from-blue-500 to-cyan-500'
  },
  love: { 
    name: '연애 운세', 
    types: ['love', 'destiny', 'blind-date', 'celebrity-match'],
    color: 'from-pink-500 to-red-500'
  },
  career: { 
    name: '재물 운세', 
    types: ['career', 'wealth', 'business', 'lucky-investment'],
    color: 'from-green-500 to-emerald-500'
  },
  lucky: { 
    name: '행운 아이템', 
    types: ['lucky-color', 'lucky-number', 'lucky-items', 'lucky-outfit', 'lucky-food'],
    color: 'from-yellow-500 to-orange-500'
  }
};

export function BatchFortuneDisplay({
  fortuneData,
  loading = false,
  onRefresh,
  onShare
}: BatchFortuneDisplayProps) {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [expandedFortune, setExpandedFortune] = useState<string | null>(null);

  if (loading) {
    return <BatchFortuneDisplaySkeleton />;
  }

  if (!fortuneData) {
    return (
      <Card className="p-8 text-center">
        <p className="text-muted-foreground">운세 데이터가 없습니다.</p>
        {onRefresh && (
          <Button onClick={onRefresh} className="mt-4">
            <RefreshCw className="w-4 h-4 mr-2" />
            운세 다시 보기
          </Button>
        )}
      </Card>
    );
  }

  const availableFortunes = Object.keys(fortuneData.analysis_results);
  const categoriesWithFortunes = Object.entries(fortuneCategories).filter(
    ([_, category]) => category.types.some(type => availableFortunes.includes(type))
  );

  const getFortunesForCategory = (categoryKey: string) => {
    if (categoryKey === 'all') return availableFortunes;
    const category = fortuneCategories[categoryKey as keyof typeof fortuneCategories];
    return category ? category.types.filter(type => availableFortunes.includes(type)) : [];
  };

  const displayedFortunes = getFortunesForCategory(selectedCategory);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold">운세 결과</h2>
          <p className="text-sm text-muted-foreground mt-1">
            생성일: {format(new Date(fortuneData.generated_at), 'yyyy년 MM월 dd일 HH:mm', { locale: ko })}
          </p>
        </div>
        <div className="flex gap-2">
          {onRefresh && (
            <Button variant="outline" size="sm" onClick={onRefresh}>
              <RefreshCw className="w-4 h-4" />
            </Button>
          )}
          <Button variant="outline" size="sm">
            <Download className="w-4 h-4" />
          </Button>
        </div>
      </div>

      {/* Package Summary */}
      {fortuneData.package_summary && (
        <Card className="bg-gradient-to-br from-primary/5 to-primary/10">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Sparkles className="w-5 h-5" />
              종합 운세
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {fortuneData.package_summary.overall_theme && (
              <p className="text-lg font-medium">{fortuneData.package_summary.overall_theme}</p>
            )}
            {fortuneData.package_summary.key_insights && (
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">주요 통찰</p>
                <ul className="space-y-1">
                  {fortuneData.package_summary.key_insights.map((insight: string, idx: number) => (
                    <li key={idx} className="text-sm flex items-start gap-2">
                      <ChevronRight className="w-3 h-3 mt-0.5 text-primary" />
                      <span>{insight}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Category Tabs */}
      <Tabs value={selectedCategory} onValueChange={setSelectedCategory}>
        <TabsList className="grid w-full grid-cols-3 lg:grid-cols-6">
          <TabsTrigger value="all">전체</TabsTrigger>
          {categoriesWithFortunes.map(([key, category]) => (
            <TabsTrigger key={key} value={key}>
              {category.name}
            </TabsTrigger>
          ))}
        </TabsList>

        <TabsContent value={selectedCategory} className="mt-6">
          <div className="grid gap-4 md:grid-cols-2">
            <AnimatePresence mode="popLayout">
              {displayedFortunes.map((fortuneType, index) => {
                const fortune = fortuneData.analysis_results[fortuneType];
                const isExpanded = expandedFortune === fortuneType;
                const categoryKey = Object.entries(fortuneCategories).find(
                  ([_, cat]) => cat.types.includes(fortuneType)
                )?.[0];
                const gradientColor = categoryKey 
                  ? fortuneCategories[categoryKey as keyof typeof fortuneCategories].color 
                  : 'from-gray-500 to-gray-600';

                return (
                  <motion.div
                    key={fortuneType}
                    layout
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ delay: index * 0.05 }}
                  >
                    <Card 
                      className={cn(
                        'cursor-pointer transition-all hover:shadow-lg',
                        isExpanded && 'md:col-span-2'
                      )}
                      onClick={() => setExpandedFortune(isExpanded ? null : fortuneType)}
                    >
                      <div className={cn(
                        'absolute inset-0 rounded-lg opacity-5 bg-gradient-to-br',
                        gradientColor
                      )} />
                      
                      <CardHeader className="relative">
                        <div className="flex items-start justify-between">
                          <div className="flex items-center gap-2">
                            <div className={cn(
                              'p-1.5 rounded-lg bg-gradient-to-br text-white',
                              gradientColor
                            )}>
                              {fortuneIcons[fortuneType] || <Sparkles className="w-4 h-4" />}
                            </div>
                            <CardTitle className="text-base">
                              {fortune.title || fortuneType}
                            </CardTitle>
                          </div>
                          {onShare && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation();
                                onShare(fortuneType);
                              }}
                            >
                              <Share2 className="w-4 h-4" />
                            </Button>
                          )}
                        </div>
                        {fortune.score && (
                          <div className="mt-2">
                            <Badge variant="secondary">
                              운세 점수: {fortune.score}/100
                            </Badge>
                          </div>
                        )}
                      </CardHeader>
                      
                      <CardContent className="relative">
                        <p className={cn(
                          'text-sm text-muted-foreground',
                          !isExpanded && 'line-clamp-3'
                        )}>
                          {fortune.content || fortune.description || '운세 내용'}
                        </p>
                        
                        {fortune.advice && isExpanded && (
                          <div className="mt-4 p-3 bg-secondary/50 rounded-lg">
                            <p className="text-sm font-medium mb-1">조언</p>
                            <p className="text-sm text-muted-foreground">
                              {fortune.advice}
                            </p>
                          </div>
                        )}
                        
                        {!isExpanded && (
                          <p className="text-xs text-primary mt-2">
                            클릭하여 자세히 보기
                          </p>
                        )}
                      </CardContent>
                    </Card>
                  </motion.div>
                );
              })}
            </AnimatePresence>
          </div>
        </TabsContent>
      </Tabs>

      {/* Token Usage Info */}
      {fortuneData.token_usage && (
        <Card className="bg-muted/50">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium">토큰 사용량</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between text-sm">
              <span>총 토큰</span>
              <span className="font-mono">{fortuneData.token_usage.total_tokens}</span>
            </div>
            <div className="flex items-center justify-between text-sm mt-1">
              <span>예상 비용</span>
              <span className="font-mono">${fortuneData.token_usage.estimated_cost.toFixed(4)}</span>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

function BatchFortuneDisplaySkeleton() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Skeleton className="h-8 w-32" />
          <Skeleton className="h-4 w-48 mt-2" />
        </div>
        <div className="flex gap-2">
          <Skeleton className="h-9 w-9" />
          <Skeleton className="h-9 w-9" />
        </div>
      </div>

      <Card>
        <CardHeader>
          <Skeleton className="h-6 w-24" />
        </CardHeader>
        <CardContent>
          <Skeleton className="h-20 w-full" />
        </CardContent>
      </Card>

      <div className="grid gap-4 md:grid-cols-2">
        {[1, 2, 3, 4].map((i) => (
          <Card key={i}>
            <CardHeader>
              <Skeleton className="h-5 w-32" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-16 w-full" />
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}