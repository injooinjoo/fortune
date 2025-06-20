"use client";

import React, { useState } from 'react';
import AppHeader from '@/components/AppHeader';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';
import type { Dream } from '@/data/model/Dream';
import { DreamRepositoryImpl } from '@/data/repository/DreamRepositoryImpl';

const POPULAR_KEYWORDS = ['용', '이빨', '물', '돈'];
const repo = new DreamRepositoryImpl();

export default function DreamPage() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Dream[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const handleSearch = async (q: string) => {
    const search = q.trim();
    setQuery(q);
    if (!search) {
      setResults([]);
      return;
    }
    setIsLoading(true);
    const res = await repo.searchByKeyword(search);
    // 작은 지연을 주어 로딩 상태를 보여줌
    setTimeout(() => {
      setResults(res);
      setIsLoading(false);
    }, 300);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      handleSearch(query);
    }
  };

  const handleBadgeClick = (keyword: string) => {
    setQuery(keyword);
    handleSearch(keyword);
  };

  const getBadgeClass = (type: Dream['type']) => {
    switch (type) {
      case '길몽':
        return 'bg-blue-100 text-blue-800';
      case '흉몽':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <>
      <AppHeader title="꿈해몽" />
      <div className="min-h-screen bg-background text-foreground p-4 pb-32 space-y-4">
        <Input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="꿈에서 본 키워드를 입력하세요 (예: 용, 이빨)"
          className="text-lg py-6"
        />
        <div className="flex flex-wrap gap-2">
          {POPULAR_KEYWORDS.map((keyword) => (
            <Badge
              key={keyword}
              onClick={() => handleBadgeClick(keyword)}
              className="cursor-pointer"
            >
              {keyword}
            </Badge>
          ))}
        </div>

        {isLoading && (
          <div className="flex justify-center py-10">
            <FortuneCompassIcon className="h-12 w-12 animate-spin text-primary" />
          </div>
        )}

        {!isLoading && results.length > 0 && (
          <div className="space-y-3">
            <p className="text-sm">'{query}'에 대한 {results.length}개의 꿈풀이가 있습니다.</p>
            {results.map((dream) => (
              <Card key={dream.id} className="hover:shadow-md transition-shadow">
                <CardHeader className="pb-2">
                  <CardTitle className="text-base flex items-center justify-between">
                    <span>{dream.title}</span>
                    <Badge className={getBadgeClass(dream.type)}>{dream.type}</Badge>
                  </CardTitle>
                </CardHeader>
                <CardContent className="pt-0">
                  <p className="text-sm text-muted-foreground">{dream.interpretation}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {!isLoading && query && results.length === 0 && (
          <p className="text-muted-foreground">검색 결과가 없습니다.</p>
        )}
      </div>
    </>
  );
}
