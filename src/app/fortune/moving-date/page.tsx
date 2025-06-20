"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Calendar as CalendarIcon } from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";

export default function MovingDatePage() {
  const [birthDate, setBirthDate] = useState("");
  const [moveMonth, setMoveMonth] = useState("");
  const [result, setResult] = useState<
    | { month: Date; good: Date[]; bad: Date[] }
    | null
  >(null);
  const [fontSize, setFontSize] = useState<"small" | "medium" | "large">(
    "medium"
  );

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1, delayChildren: 0.2 },
    },
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: { type: "spring" as const, stiffness: 100, damping: 10 },
    },
  };

  const handleSubmit = () => {
    if (!birthDate || !moveMonth) return;
    const birth = new Date(birthDate);
    const [year, month] = moveMonth.split("-").map(Number);
    const targetMonth = new Date(year, month - 1, 1);
    const daysInMonth = new Date(year, month, 0).getDate();
    const base = birth.getDate();
    const goodDays = [
      ((base % daysInMonth) + 1),
      (((base + 7) % daysInMonth) + 1),
      (((base + 14) % daysInMonth) + 1),
    ];
    const badDays = [
      (((base + 3) % daysInMonth) + 1),
      (((base + 11) % daysInMonth) + 1),
    ];
    const good = goodDays.map((d) => new Date(year, month - 1, d));
    const bad = badDays.map((d) => new Date(year, month - 1, d));
    setResult({ month: targetMonth, good, bad });
  };

  return (
    <>
      <AppHeader
        title="이사택일"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        <motion.div variants={itemVariants}>
          <Card className="border-blue-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-blue-700">
                <CalendarIcon className="w-5 h-5" /> 정보 입력
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <label htmlFor="birth" className="block text-sm mb-1">
                  생년월일
                </label>
                <input
                  id="birth"
                  type="date"
                  value={birthDate}
                  onChange={(e) => setBirthDate(e.target.value)}
                  className="w-full border rounded-md p-2"
                />
              </div>
              <div>
                <label htmlFor="month" className="block text-sm mb-1">
                  이사 예정 월
                </label>
                <input
                  id="month"
                  type="month"
                  value={moveMonth}
                  onChange={(e) => setMoveMonth(e.target.value)}
                  className="w-full border rounded-md p-2"
                />
              </div>
              <Button onClick={handleSubmit} className="w-full bg-blue-600 text-white">
                길일 보기
              </Button>
            </CardContent>
          </Card>
        </motion.div>

        {result && (
          <motion.div variants={itemVariants}>
            <Card className="border-green-200">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-green-700">
                  <CalendarIcon className="w-5 h-5" /> 이사하기 좋은 날
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <Calendar
                  month={result.month}
                  modifiers={{ good: result.good, bad: result.bad }}
                  modifiersClassNames={{
                    good: "bg-green-200 text-green-800",
                    bad: "bg-red-200 text-red-800",
                  }}
                />
                <div className="flex justify-center gap-4 text-sm">
                  <div className="flex items-center gap-1">
                    <span className="w-3 h-3 bg-green-200 border border-green-600 rounded-full" />
                    길일
                  </div>
                  <div className="flex items-center gap-1">
                    <span className="w-3 h-3 bg-red-200 border border-red-600 rounded-full" />
                    피해야 할 날
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </motion.div>
    </>
  );
}
