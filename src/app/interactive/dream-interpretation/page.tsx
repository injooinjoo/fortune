"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";

interface DreamData {
  id: number;
  title: string;
  type: "길몽" | "흉몽" | "보통";
  keywords: string[];
}

const MOCK_DREAMS: DreamData[] = [
  { id: 1, title: "용이 하늘로 올라가는 꿈", type: "길몽", keywords: ["용", "승천"] },
  { id: 2, title: "이빨이 빠지는 꿈", type: "흉몽", keywords: ["이빨", "치아", "빠짐"] },
  { id: 3, title: "물에서 헤엄치는 꿈", type: "보통", keywords: ["물", "헤엄"] },
  { id: 4, title: "높은 곳에서 떨어지는 꿈", type: "흉몽", keywords: ["떨어짐", "낙하"] },
  { id: 5, title: "돈을 줍는 꿈", type: "길몽", keywords: ["돈", "재물"] },
];

const POPULAR_KEYWORDS = ["용", "이빨", "물", "돈"];

export default function DreamInterpretationPage() {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<DreamData[]>([]);
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
      const filtered = MOCK_DREAMS.filter(
        (d) =>
          d.title.includes(search) ||
          d.keywords.some((k) => k.includes(search))
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

  const getBadgeClass = (type: DreamData["type"]) => {
    switch (type) {
      case "길몽":
        return "bg-blue-100 text-blue-800";
      case "흉몽":
        return "bg-red-100 text-red-800";
      default:
        return "bg-gray-100 text-gray-800";
    }
  };

  const handleBadgeSearch = (keyword: string) => {
    setQuery(keyword);
    handleSearch(keyword);
  };

  const handleItemClick = (id: number) => {
    router.push(`/dream-interpretation/${id}`);
  };

  return (
    <div className="min-h-screen bg-background text-foreground p-4 space-y-4">
      <Input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="꿈에서 본 키워드를 입력하세요. (예: 용, 이빨 빠지는 꿈)"
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
            '{query}'에 대한 {results.length}개의 검색 결과가 있습니다.
          </p>
          {results.map((dream) => (
            <Card
              key={dream.id}
              onClick={() => handleItemClick(dream.id)}
              className="cursor-pointer hover:shadow-md transition-shadow"
            >
              <CardContent className="p-4 flex items-center justify-between">
                <span>{dream.title}</span>
                <Badge className={getBadgeClass(dream.type)}>{dream.type}</Badge>
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

