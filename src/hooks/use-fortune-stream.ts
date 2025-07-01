"use client"

import * as React from "react"
import { useState, useEffect, useCallback, useRef } from 'react';
import { useForm } from 'react-hook-form'
import toast from 'react-hot-toast'

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

interface FortuneFormData {
  category: string
  userInfo: {
    name?: string
    mbti?: string
    zodiac?: string
    birthDate?: string
    [key: string]: any
  }
  packageType?: 'single' | 'traditional_bundle' | 'daily_bundle' | 'love_bundle'
}

interface FortuneStreamOptions {
  packageType?: 'single' | 'traditional_bundle' | 'daily_bundle' | 'love_bundle'
  enableCache?: boolean
  cacheDuration?: number // 시간 (분)
  onProgress?: (progress: number) => void
  onSuccess?: (result: any) => void
  onError?: (error: Error) => void
}

export function useFortuneStream(options: FortuneStreamOptions = {}) {
  const [isGenerating, setIsGenerating] = useState(false)
  const [progress, setProgress] = useState(0)
  const [result, setResult] = useState<any>(null)
  const [error, setError] = useState<Error | null>(null)
  
  // Context7 최적화 패턴: 특정 필드만 구독
  const { control, handleSubmit, watch, setValue, reset } = useForm<FortuneFormData>({
    mode: 'onChange',
    defaultValues: {
      category: '',
      userInfo: {},
      packageType: options.packageType || 'single'
    }
  })

  // Context7 패턴: useCallback으로 함수 메모이제이션
  const updateProgress = useCallback((newProgress: number) => {
    setProgress(newProgress)
    options.onProgress?.(newProgress)
  }, [options.onProgress])

  // 운세 패키지별 처리 로직
  const getPackageCategories = useCallback((packageType: string) => {
    switch (packageType) {
      case 'traditional_bundle':
        return ['saju', 'traditional-saju', 'tojeong', 'salpuli', 'past-life']
      case 'daily_bundle':
        return ['daily', 'hourly', 'today', 'tomorrow']
      case 'love_bundle':
        const userInfo = watch('userInfo')
        const isSingle = !userInfo.relationship || userInfo.relationship === 'single'
        return isSingle 
          ? ['love', 'destiny', 'blind-date', 'celebrity-match']
          : ['love', 'marriage', 'couple-match', 'chemistry']
      default:
        return [watch('category')]
    }
  }, [watch])

  // Context7 패턴: Promise 토스트를 활용한 에러 처리
  const generateFortune = useCallback(async (formData: FortuneFormData) => {
    const categories = getPackageCategories(formData.packageType || 'single')
    
    return toast.promise(
      (async () => {
        setIsGenerating(true)
        setError(null)
        setProgress(0)

        try {
          // 패키지 타입에 따른 토큰 효율성 계산
          const isBundle = formData.packageType !== 'single'
          const tokenSavings = isBundle ? '75% 토큰 절약' : '일반 요청'
          
          toast.loading(`${categories.length}개 운세 생성 중... (${tokenSavings})`, {
            id: 'fortune-generation'
          })

          let allResults: any = {}
          
          if (isBundle) {
            // 묶음 요청 - 단일 API 호출로 효율성 극대화
            const response = await fetch('/api/fortune/generate', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                categories,
                userInfo: formData.userInfo,
                packageType: formData.packageType,
                requestId: `${Date.now()}_${Math.random().toString(36).substring(7)}`
              })
            })

            if (!response.ok) {
              throw new Error(`운세 생성 실패: ${response.statusText}`)
            }

            const reader = response.body?.getReader()
            if (!reader) throw new Error('스트림 읽기 실패')

            let buffer = ''
            while (true) {
              const { done, value } = await reader.read()
              if (done) break

              buffer += new TextDecoder().decode(value)
              const lines = buffer.split('\n')
              buffer = lines.pop() || ''

              for (const line of lines) {
                if (line.startsWith('data: ')) {
                  try {
                    const data = JSON.parse(line.slice(6))
                    
                    if (data.type === 'progress') {
                      updateProgress(data.progress)
                    } else if (data.type === 'result') {
                      allResults[data.category] = data.result
                    } else if (data.type === 'complete') {
                      allResults = data.results
                      break
                    }
                  } catch (e) {
                    console.warn('JSON 파싱 실패:', line)
                  }
                }
              }
            }
          } else {
            // 단일 요청
            for (let i = 0; i < categories.length; i++) {
              const category = categories[i]
              updateProgress((i / categories.length) * 100)

              const response = await fetch(`/api/fortune/${category}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData.userInfo)
              })

              if (!response.ok) {
                throw new Error(`${category} 운세 생성 실패`)
              }

              allResults[category] = await response.json()
            }
          }

          updateProgress(100)
          setResult(allResults)
          toast.dismiss('fortune-generation')
          
          options.onSuccess?.(allResults)
          return allResults

        } catch (err) {
          const error = err instanceof Error ? err : new Error('알 수 없는 오류')
          setError(error)
          toast.dismiss('fortune-generation')
          options.onError?.(error)
          throw error
        } finally {
          setIsGenerating(false)
        }
      })(),
      {
        loading: '운세를 생성하고 있습니다...',
        success: (data) => {
          const categories = Object.keys(data)
          return `${categories.length}개 운세가 완성되었습니다! ✨`
        },
        error: (err) => `운세 생성 실패: ${err.message}`,
      },
      {
        style: {
          minWidth: '300px',
        },
        success: {
          duration: 3000,
          icon: '✨',
        },
        error: {
          duration: 5000,
          icon: '❌',
        },
      }
    )
  }, [getPackageCategories, updateProgress, options])

  // Context7 패턴: 폼 제출 최적화
  const onSubmit = useCallback(
    handleSubmit((data) => generateFortune(data)),
    [handleSubmit, generateFortune]
  )

  // Context7 패턴: reset 함수 메모이제이션
  const resetForm = useCallback(() => {
    reset()
    setResult(null)
    setError(null)
    setProgress(0)
  }, [reset])

  // 캐시 키 생성 (정책에 따른 캐시 전략)
  const getCacheKey = useCallback((formData: FortuneFormData) => {
    const { category, userInfo, packageType } = formData
    const key = `${packageType || category}_${JSON.stringify(userInfo)}`
    return btoa(key).replace(/[^a-zA-Z0-9]/g, '')
  }, [])

  // Context7 패턴: 조건부 캐시 체크
  const checkCache = useCallback((formData: FortuneFormData) => {
    if (!options.enableCache) return null
    
    const cacheKey = getCacheKey(formData)
    const cached = localStorage.getItem(`fortune_${cacheKey}`)
    
    if (cached) {
      try {
        const { data, timestamp } = JSON.parse(cached)
        const cacheAge = Date.now() - timestamp
        const maxAge = (options.cacheDuration || 1440) * 60 * 1000 // 기본 24시간
        
        if (cacheAge < maxAge) {
          toast.success('캐시된 운세를 불러왔습니다! ⚡', {
            duration: 2000,
            icon: '⚡'
          })
          return data
        }
      } catch (e) {
        localStorage.removeItem(`fortune_${cacheKey}`)
      }
    }
    return null
  }, [getCacheKey, options.enableCache, options.cacheDuration])

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
    // 폼 관련 (Context7 최적화 적용)
    control,
    handleSubmit: onSubmit,
    watch,
    setValue,
    reset: resetForm,
    
    // 상태 관리
    isGenerating,
    progress,
    result,
    error,
    
    // 액션
    generateFortune,
    checkCache,
    
    // 유틸리티
    getPackageCategories,
    getCacheKey,
    
    // 최근 본 운세 관련
    addToRecentFortunes
  };
}
