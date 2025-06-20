"use client";

import React, { useState } from "react";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import AppHeader from "@/components/AppHeader";

interface AnalysisResult {
  part: string;
  text: string;
}

export default function ImagePhysiognomyScreen() {
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [results, setResults] = useState<AnalysisResult[] | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      setPreviewUrl(URL.createObjectURL(file));
      setResults(null);
    }
  };

  const handleAnalyze = async () => {
    if (!selectedFile) return;
    setIsAnalyzing(true);

    // Simulate analysis delay
    setTimeout(() => {
      setIsAnalyzing(false);
      setResults([
        { part: "눈썹", text: "눈썹이 진하여 결단력이 돋보입니다." },
        { part: "코", text: "코가 오똑해 재물운이 좋습니다." },
        { part: "입", text: "입술이 도톰해 인간관계가 원만합니다." },
      ]);
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-background text-foreground pb-20">
      <AppHeader title="AI 관상" />
      
      <div className="flex flex-col items-center p-6 space-y-6">
      <input type="file" accept="image/*" onChange={handleFileChange} className="w-full max-w-md" />

      {previewUrl && (
        <div className="relative w-full max-w-md">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={previewUrl} alt="선택한 이미지" className="w-full h-auto rounded-md" />
          {isAnalyzing && (
            <div className="absolute inset-0 flex items-center justify-center bg-background/80 rounded-md">
              <FortuneCompassIcon className="h-12 w-12 text-primary animate-spin" />
            </div>
          )}
        </div>
      )}

      {previewUrl && (
        <Button onClick={handleAnalyze} className="w-full max-w-md">관상 분석하기</Button>
      )}

      {results && (
        <div className="w-full max-w-md space-y-2">
          {results.map((r) => (
            <div key={r.part} className="border rounded-md p-3">
              <h3 className="font-semibold mb-1">{r.part}</h3>
              <p className="text-sm text-muted-foreground">{r.text}</p>
            </div>
          ))}
        </div>
      )}
      </div>
    </div>
  );
}
