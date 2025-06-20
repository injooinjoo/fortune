"use client";

import React, { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import AppHeader from "@/components/AppHeader";
import type { FaceReadingResult } from "@/app/actions";

// Optional: MediaPipe FaceMesh imports. These are lightweight and run on-device.
import { FaceMesh } from "@mediapipe/face_mesh";
import { Camera } from "@mediapipe/camera_utils";

interface Landmark { x: number; y: number; }

function distance(a: Landmark, b: Landmark) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return Math.hypot(dx, dy);
}

function calculateAngle(a: Landmark, b: Landmark, c: Landmark) {
  const ab = { x: b.x - a.x, y: b.y - a.y };
  const cb = { x: b.x - c.x, y: b.y - c.y };
  const dot = ab.x * cb.x + ab.y * cb.y;
  const abMag = Math.hypot(ab.x, ab.y);
  const cbMag = Math.hypot(cb.x, cb.y);
  const cosine = dot / (abMag * cbMag);
  return (Math.acos(cosine) * 180) / Math.PI;
}

function generateLabels(landmarks: Landmark[]): string[] {
  const labels: string[] = [];
  const browDistance = distance(landmarks[65], landmarks[295]);
  const faceWidth = distance(landmarks[234], landmarks[454]);
  const ratio = browDistance / faceWidth;
  if (ratio > 0.3) labels.push("forehead_wide");

  const lipAngle = calculateAngle(landmarks[61], landmarks[0], landmarks[291]);
  if (lipAngle < 165) labels.push("lips_upturned");

  const noseLength = distance(landmarks[1], landmarks[2]);
  const faceLength = distance(landmarks[10], landmarks[152]);
  if (noseLength / faceLength > 0.25) labels.push("nose_straight");

  return labels;
}

export default function ImagePhysiognomyScreen() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [labels, setLabels] = useState<string[]>([]);
  const [result, setResult] = useState<FaceReadingResult | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const faceMesh = new FaceMesh({
      locateFile: file => `https://cdn.jsdelivr.net/npm/@mediapipe/face_mesh/${file}`,
    });
    faceMesh.setOptions({ maxNumFaces: 1, refineLandmarks: true });
    faceMesh.onResults(res => {
      if (!res.multiFaceLandmarks || !res.multiFaceLandmarks[0]) return;
      const lm = res.multiFaceLandmarks[0].map(p => ({ x: p.x, y: p.y }));
      const newLabels = generateLabels(lm);
      setLabels(newLabels);
    });

    const camera = new Camera(video, {
      onFrame: async () => {
        await faceMesh.send({ image: video });
      },
      width: 640,
      height: 480,
    });
    camera.start();
  }, []);

  const handleAnalyze = async () => {
    if (!labels.length) return;
    setLoading(true);
    try {
      const res = await fetch("/api/face-reading", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ labels }),
      });
      if (res.ok) {
        const data: FaceReadingResult = await res.json();
        setResult(data);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background text-foreground pb-20">
      <AppHeader title="AI 관상" />
      <div className="flex flex-col items-center p-6 space-y-4">
        <video ref={videoRef} className="rounded-md" autoPlay playsInline width={320} height={240} />
        <canvas ref={canvasRef} width={320} height={240} className="hidden" />
        <Button onClick={handleAnalyze} disabled={loading || labels.length === 0} className="w-full max-w-md">
          {loading ? "분석 중..." : "관상 분석하기"}
        </Button>
        {labels.length > 0 && (
          <div className="text-sm text-muted-foreground">추출된 특징: {labels.join(", ")}</div>
        )}
        {result && (
          <div className="border rounded-md p-4 w-full max-w-md">
            <p className="text-sm whitespace-pre-wrap">{result.interpretation}</p>
          </div>
        )}
      </div>
    </div>
  );
}
