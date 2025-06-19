"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";

interface Part {
  id: string;
  label: string;
  top: string;
  left: string;
  description: string;
}

const PARTS: Part[] = [
  {
    id: "forehead",
    label: "이마",
    top: "20%",
    left: "50%",
    description: "이마: 당신은 끈기와 집중력이 뛰어나며 새로운 도전을 즐깁니다.",
  },
  {
    id: "eyes",
    label: "눈",
    top: "40%",
    left: "50%",
    description: "눈: 당신의 눈은 지혜를 담고 있으며 통찰력이 뛰어납니다.",
  },
  {
    id: "nose",
    label: "코",
    top: "55%",
    left: "50%",
    description: "코: 재물운이 좋고 현실 감각이 뛰어납니다.",
  },
  {
    id: "mouth",
    label: "입",
    top: "70%",
    left: "50%",
    description: "입: 인간관계가 원만하고 의사소통 능력이 우수합니다.",
  },
  {
    id: "ears",
    label: "귀",
    top: "40%",
    left: "85%",
    description: "귀: 새로운 소식을 빠르게 접하며 배움에 열정적입니다.",
  },
];

export default function InteractiveFaceReadingPage() {
  const [step, setStep] = useState<"upload" | "analyzing" | "result">("upload");
  const [fileUrl, setFileUrl] = useState<string | null>(null);
  const [activePart, setActivePart] = useState<Part | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setFileUrl(URL.createObjectURL(file));
    setStep("analyzing");
  };

  useEffect(() => {
    if (step === "analyzing") {
      const timer = setTimeout(() => {
        setStep("result");
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [step]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-background text-foreground p-4">
      {step === "upload" && (
        <div className="space-y-4 text-center">
          <p>정확한 분석을 위해 정면 사진을 업로드해주세요.</p>
          <p className="text-sm text-muted-foreground">
            안경과 모자는 벗고, 앞머리가 눈을 가리지 않게 해주세요.
          </p>
          <input
            id="photo-input"
            type="file"
            accept="image/*"
            onChange={handleFileChange}
            className="hidden"
          />
          <label htmlFor="photo-input">
            <Button>사진 업로드</Button>
          </label>
        </div>
      )}

      {step === "analyzing" && (
        <div className="flex flex-col items-center space-y-4">
          <FortuneCompassIcon className="h-12 w-12 text-primary animate-spin" />
          <p>얼굴의 기운을 분석하고 있습니다...</p>
          <Progress value={70} className="w-60" />
        </div>
      )}

      {step === "result" && fileUrl && (
        <div className="w-full flex flex-col md:flex-row items-start md:space-x-6 space-y-6 md:space-y-0">
          <div className="relative mx-auto md:mx-0 w-full md:w-1/2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={fileUrl} alt="업로드한 사진" className="w-full h-auto rounded-md" />
            {PARTS.map((part) => (
              <button
                key={part.id}
                className="absolute w-6 h-6 rounded-full bg-primary/60 hover:bg-primary focus:outline-none"
                style={{ top: part.top, left: part.left, transform: "translate(-50%, -50%)" }}
                onClick={() => setActivePart(part)}
                aria-label={part.label}
              />
            ))}
          </div>
          <div className="flex-1 space-y-4">
            <p className="min-h-[64px]">
              {activePart ? activePart.description : "분석된 영역을 터치하여 상세 설명을 확인하세요."}
            </p>
            <div className="space-y-2">
              <div>
                <h3 className="font-semibold">성격</h3>
                <p className="text-sm text-muted-foreground">끈기 있고 긍정적인 성향으로 주변 사람들에게 신뢰를 줍니다.</p>
              </div>
              <div>
                <h3 className="font-semibold">재물운</h3>
                <p className="text-sm text-muted-foreground">기회를 잘 포착하여 꾸준히 재물을 모으는 타입입니다.</p>
              </div>
              <div>
                <h3 className="font-semibold">애정운</h3>
                <p className="text-sm text-muted-foreground">따뜻한 마음씨로 사람들에게 호감을 얻고 인연이 따릅니다.</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
