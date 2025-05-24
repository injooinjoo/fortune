"use client";

import React, { useEffect } from 'react';

const BackgroundAudioPlayer = () => {
  useEffect(() => {
    const audio = document.getElementById('background-audio') as HTMLAudioElement;
    if (audio) {
      // Attempt to play, but catch errors for browsers that block autoplay
      audio.play().catch(error => {
        console.warn("Audio autoplay was prevented: ", error);
        // Optionally, you could show a play button here
      });
    }
    // Cleanup function to pause audio if component unmounts, though less likely for root layout
    return () => {
      if (audio && !audio.paused) {
        audio.pause();
      }
    };
  }, []);

  return (
    // Added a visually hidden class for the audio element if no controls are desired initially
    <audio id="background-audio" loop autoPlay controlsList="nodownload nofullscreen noremoteplayback" className="sr-only">
      <source src="/audio/monument-valley-theme.mp3" type="audio/mpeg" />
      Your browser does not support the audio element.
    </audio>
  );
};

export default BackgroundAudioPlayer;
