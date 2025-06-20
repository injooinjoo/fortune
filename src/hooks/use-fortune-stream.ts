"use client"

import * as React from "react"
import { useState, useEffect } from 'react';

// 최근 본 운세 타입
interface RecentFortune {
  path: string;
  title: string;
  visitedAt: number;
}

// 운세 카테고리 정보 매핑
const fortuneInfo: Record<string, { title: string }> = {
  "saju": { title: "사주팔자" },
  "love": { title: "연애운" },
  "marriage": { title: "결혼운" },
  "career": { title: "취업운" },
  "wealth": { title: "금전운" },
  "moving": { title: "이사운" },
  "business": { title: "사업운" },
  "palmistry": { title: "손금" },
  "saju-psychology": { title: "사주 심리분석" },
  "compatibility": { title: "궁합" },
  "lucky-hiking": { title: "행운의 등산" },
  "lucky-color": { title: "행운의 색깔" },
  "daily": { title: "일일 운세" },
  "mbti": { title: "MBTI 운세" },
  "zodiac": { title: "별자리 운세" },
  "zodiac-animal": { title: "띠 운세" },
  "ex-lover": { title: "헤어진 애인" },
  "blind-date": { title: "소개팅" },
  "hourly": { title: "시간대별 운세" },
  "chemistry": { title: "속궁합" },
  "lucky-items": { title: "행운의 아이템" },
  "biorhythm": { title: "바이오리듬" },
  "lucky-baseball": { title: "행운의 야구" },
  "lucky-tennis": { title: "행운의 테니스" },
  "lucky-fishing": { title: "행운의 낚시" },
  "lucky-investment": { title: "행운의 재테크" },
  "lucky-golf": { title: "행운의 골프" },
  "lucky-cycling": { title: "행운의 자전거" },
  "lucky-swim": { title: "행운의 수영" },
  "lucky-running": { title: "행운의 마라톤" },
  "lucky-realestate": { title: "행운의 부동산" },
  "lucky-number": { title: "행운의 번호" },
  "lucky-food": { title: "행운의 음식" },
  "lucky-exam": { title: "행운의 시험일자" },
  "lucky-outfit": { title: "행운의 코디" },
  "lucky-job": { title: "행운의 직업" },
  "avoid-people": { title: "피해야 할 사람" },
  "birthdate": { title: "생년월일 운세" },
  "birthstone": { title: "탄생석 운세" },
  "birth-season": { title: "태어난 계절" },
  "blood-type": { title: "혈액형 운세" },
  "celebrity-match": { title: "연예인 궁합" },
  "couple-match": { title: "커플 매칭" },
  "destiny": { title: "운명 분석" },
  "employment": { title: "취업 운세" },
  "five-blessings": { title: "오복 운세" },
  "lucky-sidejob": { title: "행운의 부업" },
  "moving-date": { title: "이사 날짜" },
  "network-report": { title: "인맥 리포트" },
  "new-year": { title: "신년 운세" },
  "past-life": { title: "전생 분석" },
  "salpuli": { title: "살풀이" },
  "startup": { title: "창업 운세" },
  "talent": { title: "재능 분석" },
  "talisman": { title: "부적" },
  "timeline": { title: "타임라인 운세" },
  "today": { title: "오늘의 운세" },
  "tojeong": { title: "토정 운세" },
  "tomorrow": { title: "내일의 운세" },
  "traditional-compatibility": { title: "전통 궁합" },
  "traditional-saju": { title: "전통 사주" },
  "wish": { title: "소원빌기" }
};

export interface FortuneResult {
  message: string;
  isComplete: boolean;
}

export const useFortuneStream = () => {
  const [result, setResult] = useState<FortuneResult | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const streamFortune = async (prompt: string) => {
    setIsLoading(true);
    setError(null);
    setResult(null);

    try {
      // 실제 스트리밍 구현은 여기에
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      setResult({
        message: `당신의 운세 결과입니다: ${prompt}`,
        isComplete: true
      });
    } catch (err) {
      setError('운세 분석 중 오류가 발생했습니다.');
    } finally {
      setIsLoading(false);
    }
  };

  // 최근 본 운세에 추가하는 함수
  const addToRecentFortunes = (path: string) => {
    try {
      // 경로에서 운세 키 추출
      const match = path.match(/\/fortune\/([^\/]+)/);
      if (!match) return;
      
      const fortuneKey = match[1];
      const info = fortuneInfo[fortuneKey];
      if (!info) return;

      const stored = localStorage.getItem('recentFortunes');
      let fortunes: RecentFortune[] = stored ? JSON.parse(stored) : [];
      
      // 기존에 같은 path가 있으면 제거
      fortunes = fortunes.filter(f => f.path !== path);
      
      // 새로운 항목을 맨 앞에 추가
      fortunes.unshift({
        path,
        title: info.title,
        visitedAt: Date.now()
      });
      
      // 최대 10개까지만 저장
      fortunes = fortunes.slice(0, 10);
      
      localStorage.setItem('recentFortunes', JSON.stringify(fortunes));
    } catch (error) {
      console.error('최근 본 운세 저장 실패:', error);
    }
  };

  // 페이지가 마운트될 때 자동으로 최근 본 운세에 추가
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const currentPath = window.location.pathname;
      if (currentPath.startsWith('/fortune/')) {
        addToRecentFortunes(currentPath);
      }
    }
  }, []);

  return {
    result,
    isLoading,
    error,
    streamFortune,
    addToRecentFortunes
  };
};
