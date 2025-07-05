"use client";

import { useEffect, useState, useRef } from "react";

interface ScrollSpyOptions {
  rootMargin?: string;
  threshold?: number;
  onActiveChange?: (activeId: string | null) => void;
}

export function useScrollSpy(
  elementIds: string[],
  options: ScrollSpyOptions = {}
) {
  const [activeId, setActiveId] = useState<string | null>(null);
  const observer = useRef<IntersectionObserver | null>(null);
  const elementsRef = useRef<Map<string, HTMLElement>>(new Map());

  const { rootMargin = "0px 0px -80% 0px", threshold = 0.1, onActiveChange } = options;

  useEffect(() => {
    const elements = elementIds.map(id => document.getElementById(id)).filter(Boolean) as HTMLElement[];
    
    if (elements.length === 0) return;

    // 요소들을 Map에 저장
    elementsRef.current.clear();
    elements.forEach((element) => {
      if (element.id) {
        elementsRef.current.set(element.id, element);
      }
    });

    observer.current = new IntersectionObserver(
      (entries) => {
        // 현재 보이는 요소들을 필터링
        const visibleEntries = entries.filter(entry => entry.isIntersecting);
        
        if (visibleEntries.length > 0) {
          // Y 좌표가 가장 높은 요소(화면 상단에 가장 가까운 요소)를 찾기
          const topEntry = visibleEntries.reduce((prev, current) => {
            return prev.boundingClientRect.top < current.boundingClientRect.top ? prev : current;
          });
          
          const newActiveId = topEntry.target.id;
          if (newActiveId !== activeId) {
            setActiveId(newActiveId);
            onActiveChange?.(newActiveId);
          }
        }
      },
      {
        rootMargin,
        threshold,
      }
    );

    elements.forEach((element) => {
      if (observer.current) {
        observer.current.observe(element);
      }
    });

    return () => {
      if (observer.current) {
        observer.current.disconnect();
      }
    };
  }, [elementIds, rootMargin, threshold, activeId, onActiveChange]);

  return activeId;
}