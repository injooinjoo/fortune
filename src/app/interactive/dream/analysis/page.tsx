"use client";

import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { analyzeDreamAction } from "@/app/actions";
import AppHeader from "@/components/AppHeader";

export default function DreamAnalysisPage() {
  const [file, setFile] = useState<File | null>(null);
  const [text, setText] = useState("");
  const [result, setResult] = useState("");
  const [loading, setLoading] = useState(false);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    setFile(f);
    // TODO: Use on-device OCR (ML Kit/VisionKit or Tesseract.js) to extract text
    // from the image without network requests.
    // const extracted = await extractTextFromImage(f);
    // setText(extracted);
  };

  const handleAnalyze = async () => {
    if (!text.trim()) return;
    setLoading(true);
    const res = await analyzeDreamAction({ dreamStory: text });
    if (res.data) {
      setResult(res.data.analysis);
    } else if (res.error) {
      setResult(res.error);
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen pb-32 bg-background text-foreground">
      <AppHeader title="꿈 해석" />
      <div className="p-4 space-y-4">
        <input type="file" accept="image/*" onChange={handleFileChange} />
        <Textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="꿈 내용을 입력하거나 이미지를 업로드하세요"
          rows={6}
        />
        <Button onClick={handleAnalyze} disabled={loading || !text.trim()} className="w-full">
          {loading ? "해석 중..." : "해석 요청"}
        </Button>
        {result && <p className="whitespace-pre-wrap p-2 border rounded-md">{result}</p>}
      </div>
    </div>
  );
}
