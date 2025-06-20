"use client";

import { useState } from "react";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Droplet } from "lucide-react";

const BLOOD_TYPES = ["A", "B", "O", "AB"] as const;

type BloodType = (typeof BLOOD_TYPES)[number];

interface CompatibilityInfo {
  score: number;
  description: string;
  tip: string;
}

const COMPATIBILITY_MAP: Record<string, CompatibilityInfo> = {
  "A-A": {
    score: 75,
    description: "비슷한 성향의 두 사람! 꼼꼼함이 장점이자 단점이에요.",
    tip: "서로의 사소한 실수는 너그러이 넘겨주세요.",
  },
  "A-B": {
    score: 65,
    description: "정반대 매력의 만남! 의외의 케미가 기대돼요.",
    tip: "솔직한 대화가 관계를 지켜줍니다.",
  },
  "A-O": {
    score: 80,
    description: "안정적인 A형과 포용력 있는 O형의 조화로운 궁합.",
    tip: "공통 취미를 찾아보세요.",
  },
  "A-AB": {
    score: 70,
    description: "섬세함과 독특함이 만나 새로운 시너지가 생겨요.",
    tip: "다른 관점을 존중하면 금상첨화!",
  },
  "B-B": {
    score: 78,
    description: "자유로운 영혼끼리라 즐거움이 가득합니다.",
    tip: "적당한 배려만 잊지 마세요.",
  },
  "B-O": {
    score: 85,
    description: "즉흥적인 B형과 포용력 있는 O형의 활기찬 조합.",
    tip: "새로운 경험을 함께 해보세요.",
  },
  "B-AB": {
    score: 68,
    description: "직설적인 B형과 다재다능한 AB형의 흥미로운 만남.",
    tip: "서로의 스타일을 인정하면 더욱 좋아요.",
  },
  "O-O": {
    score: 82,
    description: "긍정적인 두 O형! 무난하고 편안한 관계가 예상돼요.",
    tip: "가끔은 이벤트로 색다른 즐거움을.",
  },
  "O-AB": {
    score: 72,
    description: "O형의 낙천성과 AB형의 냉철함이 만나 균형 잡힌 궁합.",
    tip: "서로의 장점을 배워보세요.",
  },
  "AB-AB": {
    score: 77,
    description: "천재끼리의 만남?! 특별한 호흡이 기대됩니다.",
    tip: "개성을 존중하면 환상의 팀워크.",
  },
};

function getPairKey(a: BloodType, b: BloodType) {
  const pair = [a, b].sort();
  return `${pair[0]}-${pair[1]}`;
}

export default function BloodTypeCompatibilityPage() {
  const [myType, setMyType] = useState<BloodType | null>(null);
  const [partnerType, setPartnerType] = useState<BloodType | null>(null);

  const pairKey =
    myType && partnerType ? getPairKey(myType, partnerType) : null;
  const result = pairKey ? COMPATIBILITY_MAP[pairKey] : null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-red-50 via-rose-50 to-pink-50 pb-20">
      <AppHeader title="혈액형 궁합" />
      <div className="px-4 pt-6 space-y-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-red-700">
              <Droplet className="w-5 h-5" /> 내 혈액형
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-4 gap-2">
              {BLOOD_TYPES.map((type) => (
                <Button
                  key={type}
                  variant={myType === type ? "default" : "outline"}
                  onClick={() => setMyType(type)}
                  className="text-sm"
                >
                  {type}
                </Button>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-pink-700">
              <Droplet className="w-5 h-5" /> 상대 혈액형
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-4 gap-2">
              {BLOOD_TYPES.map((type) => (
                <Button
                  key={type}
                  variant={partnerType === type ? "default" : "outline"}
                  onClick={() => setPartnerType(type)}
                  className="text-sm"
                >
                  {type}
                </Button>
              ))}
            </div>
          </CardContent>
        </Card>

        {result && (
          <Card className="border-red-200 bg-red-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-red-800">
                <Droplet className="w-5 h-5" /> 궁합 점수 {result.score}점
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <Progress value={result.score} className="mb-2" />
              <p className="text-sm text-gray-700">{result.description}</p>
              <p className="text-sm text-red-700 font-medium">
                TIP: {result.tip}
              </p>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
