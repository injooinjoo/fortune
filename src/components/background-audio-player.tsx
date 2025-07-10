"use client";

import { logger } from '@/lib/logger';
import React, { useEffect, useState } from 'react';

const BackgroundAudioPlayer = () => {
  const [audioError, setAudioError] = useState(false);

  useEffect(() => {
    const audio = document.getElementById('background-audio') as HTMLAudioElement;
    
    if (!audio) return;

    // 오디오 파일 로드 에러 처리
    const handleError = () => {
      logger.warn("오디오 파일을 찾을 수 없습니다: monument-valley-theme.mp3");
      setAudioError(true);
    };

    // 오디오 파일 로드 성공 처리
    const handleCanPlay = () => {
      audio.play().catch(error => {
        logger.warn("오디오 자동 재생이 차단되었습니다: ", error);
      });
    };

    audio.addEventListener('error', handleError);
    audio.addEventListener('canplay', handleCanPlay);

    return () => {
      audio.removeEventListener('error', handleError);
      audio.removeEventListener('canplay', handleCanPlay);
      if (audio && !audio.paused) {
        audio.pause();
      }
    };
  }, []);

  // 오디오 파일이 없으면 렌더링하지 않음
  if (audioError) {
    return null;
  }

  return (
    <audio 
      id="background-audio" 
      loop 
      autoPlay 
      controlsList="nodownload nofullscreen noremoteplaybook" 
      className="sr-only"
      preload="none"
    >
      <source src="/audio/monument-valley-theme.mp3" type="audio/mpeg" />
      Your browser does not support the audio element.
    </audio>
  );
};

export default BackgroundAudioPlayer;
