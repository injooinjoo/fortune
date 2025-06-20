"use client";

import { useRef, useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Coins, HeartPulse, GraduationCap, Heart } from "lucide-react";

interface Category {
  id: string;
  name: string;
  color: string;
  gradient: string;
  icon: React.ComponentType<{ className?: string }>;
  text: string;
}

const categories: Category[] = [
  {
    id: "wealth",
    name: "재물",
    color: "yellow",
    gradient: "from-yellow-100 to-yellow-50",
    icon: Coins,
    text: "재물"
  },
  {
    id: "health",
    name: "건강",
    color: "green",
    gradient: "from-green-100 to-green-50",
    icon: HeartPulse,
    text: "건강"
  },
  {
    id: "success",
    name: "합격",
    color: "blue",
    gradient: "from-blue-100 to-blue-50",
    icon: GraduationCap,
    text: "합격"
  },
  {
    id: "love",
    name: "연애",
    color: "rose",
    gradient: "from-rose-100 to-pink-50",
    icon: Heart,
    text: "연애"
  }
];

export default function TalismanPage() {
  const [selected, setSelected] = useState<Category>(categories[0]);
  const [generated, setGenerated] = useState(false);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  const drawTalisman = (c: Category) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const w = canvas.width;
    const h = canvas.height;
    const grad = ctx.createLinearGradient(0, 0, 0, h);
    grad.addColorStop(0, "#FFF7C2");
    grad.addColorStop(1, c.color === "yellow" ? "#FDE047" : c.color === "green" ? "#A7F3D0" : c.color === "blue" ? "#BFDBFE" : "#FBCFE8");
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, w, h);

    ctx.strokeStyle = "#4B0082";
    ctx.lineWidth = 6;
    ctx.strokeRect(30, 30, w - 60, h - 60);

    ctx.fillStyle = "#4B0082";
    ctx.font = "bold 72px serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText(c.text, w / 2, h / 2);
  };

  const handleGenerate = () => {
    drawTalisman(selected);
    setGenerated(true);
  };

  const handleDownload = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const link = document.createElement("a");
    link.href = canvas.toDataURL("image/png");
    link.download = `${selected.name}-부적.png`;
    link.click();
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-indigo-50 pb-24">
      <AppHeader title="행운의 부적" />
      <div className="container mx-auto px-4 pt-4 space-y-6">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center space-y-2">
          <h1 className="text-2xl font-bold text-gray-900">소망을 담은 부적을 만들어보세요</h1>
          <p className="text-gray-600">원하는 운을 선택하고 부적을 생성해 휴대폰 배경화면으로 사용하세요</p>
        </motion.div>

        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
          <Card className="bg-white/80 backdrop-blur-sm shadow-lg">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <selected.icon className={`h-6 w-6 text-${selected.color}-600`} />
                {selected.name} 부적 생성
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-4 gap-2">
                {categories.map((c) => {
                  const Icon = c.icon;
                  const active = c.id === selected.id;
                  return (
                    <button
                      key={c.id}
                      onClick={() => setSelected(c)}
                      className={`p-3 rounded-lg text-sm flex flex-col items-center gap-1 ${active ? `bg-gradient-to-br ${c.gradient} text-gray-900` : "bg-gray-50 hover:bg-gray-100"}`}
                    >
                      <Icon className={`h-5 w-5 ${active ? `text-${c.color}-700` : "text-gray-600"}`} />
                      {c.name}
                    </button>
                  );
                })}
              </div>
              <Button onClick={handleGenerate} className="w-full bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600">
                부적 생성하기
              </Button>
            </CardContent>
          </Card>
        </motion.div>

        {generated && (
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center space-y-4">
            <canvas ref={canvasRef} width={360} height={640} className="mx-auto rounded-lg shadow-lg border border-gray-200" />
            <Button onClick={handleDownload} className="w-full bg-gradient-to-r from-yellow-400 to-orange-400 hover:from-yellow-500 hover:to-orange-500">
              부적 이미지 저장
            </Button>
            <p className="text-sm text-gray-500">저장된 이미지를 배경화면으로 설정해보세요</p>
          </motion.div>
        )}
      </div>
    </div>
  );
}
