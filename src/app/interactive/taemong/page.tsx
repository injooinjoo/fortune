"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";

interface TaemongData {
  id: number;
  title: string;
  gender: "boy" | "girl" | "unknown";
  personality: string;
  future: string;
  keywords: string[];
}

const MOCK_TAEMONGS: TaemongData[] = [
  {
    id: 1,
    title: "용이 승천하는 꿈",
    gender: "boy",
    personality: "리더십이 뛰어나고 강인한 성격",
    future: "큰 성공과 명예를 얻을 운",
    keywords: ["용", "승천"],
  },
  {
    id: 2,
    title: "돼지가 금반지를 물고 오는 꿈",
    gender: "girl",
    personality: "부드럽고 배려심 많은 성품",
    future: "재물과 행운이 따르는 삶",
    keywords: ["돼지", "금반지"],
  },
  {
    id: 3,
    title: "호랑이가 집안으로 들어오는 꿈",
    gender: "boy",
    personality: "용감하고 정의로운 성격",
    future: "많은 사람을 이끄는 지도자 운",
    keywords: ["호랑이", "집"],
  },
  {
    id: 4,
    title: "활짝 핀 꽃나무를 안는 꿈",
    gender: "girl",
    personality: "예술적 감각이 뛰어나고 사랑스러운 성향",
    future: "다방면에서 재능을 꽃피움",
    keywords: ["꽃", "나무"],
  },
  {
    id: 5,
    title: "해가 두 개 떠오르는 꿈",
    gender: "unknown",
    personality: "호기심이 많고 에너지 넘침",
    future: "새로운 길을 개척하는 혁신가",
    keywords: ["태양", "쌍둥이"],
  },
];

const POPULAR_KEYWORDS = ["용", "돼지", "호랑이", "꽃", "태양"];

export default function TaemongPage() {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<TaemongData[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const handleSearch = (q: string) => {
    const search = q.trim();
    setQuery(search);
    if (!search) {
      setResults([]);
      return;
    }
    setIsLoading(true);
    setTimeout(() => {
      const filtered = MOCK_TAEMONGS.filter(
        (t) =>
          t.title.includes(search) ||
          t.keywords.some((k) => k.includes(search))
      );
      setResults(filtered);
      setIsLoading(false);
    }, 300);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      handleSearch(query);
    }
  };

  const handleBadgeSearch = (keyword: string) => {
    setQuery(keyword);
    handleSearch(keyword);
  };

  const handleItemClick = (id: number) => {
    router.push(`/taemong/${id}`);
  };

  const genderLabel = {
    boy: "남아",
    girl: "여아",
    unknown: "미상",
  } as const;

  const genderBadgeClass = {
    boy: "bg-blue-100 text-blue-800",
    girl: "bg-pink-100 text-pink-800",
    unknown: "bg-gray-100 text-gray-800",
  } as const;

  return (
    <div className="min-h-screen bg-background text-foreground p-4 space-y-4">
      <Input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="태몽에 등장한 키워드를 입력하세요. (예: 용, 돼지, 금반지)"
        className="text-lg py-6"
      />
      <div className="flex flex-wrap gap-2">
        {POPULAR_KEYWORDS.map((keyword) => (
          <Badge
            key={keyword}
            onClick={() => handleBadgeSearch(keyword)}
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
          <p className="text-sm">
            '{query}'에 대한 {results.length}개의 태몽 해석이 있습니다.
          </p>
          {results.map((t) => (
            <Card
              key={t.id}
              onClick={() => handleItemClick(t.id)}
              className="cursor-pointer hover:shadow-md transition-shadow space-y-1"
            >
              <CardContent className="p-4 space-y-2">
                <div className="flex items-center justify-between">
                  <span>{t.title}</span>
                  <Badge className={genderBadgeClass[t.gender]}>
                    {genderLabel[t.gender]}
                  </Badge>
                </div>
                <p className="text-sm text-muted-foreground">
                  성격: {t.personality}
                </p>
                <p className="text-sm text-muted-foreground">
                  미래: {t.future}
                </p>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {!isLoading && query && results.length === 0 && (
        <p className="text-muted-foreground">검색 결과가 없습니다.</p>
      )}
    </div>
  );
}

