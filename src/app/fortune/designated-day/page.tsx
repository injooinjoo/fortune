"use client";

import { useState } from "react";
import { format } from "date-fns";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import FortuneResult from "@/components/dashboard/FortuneResult";

export default function DesignatedDayFortunePage() {
  const [birthDate, setBirthDate] = useState<Date | undefined>();
  const [targetDate, setTargetDate] = useState<Date | undefined>();
  const [result, setResult] = useState("");

  const generateFortune = () => {
    if (!birthDate || !targetDate) return;
    const birth = format(birthDate, "yyyy-MM-dd");
    const target = format(targetDate, "yyyy-MM-dd");
    setResult(`${target} 운세 (출생일 ${birth} 기준)입니다.`);
  };

  return (
    <>
      <AppHeader title="지정일 운세" />
      <div className="p-4 space-y-6 pb-32">
        <Card className="border-cyan-200 bg-gradient-to-br from-cyan-50 to-teal-50">
          <CardHeader>
            <CardTitle className="text-cyan-800">정보 입력</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <h4 className="font-medium text-gray-700 mb-2">생년월일</h4>
              <Calendar mode="single" selected={birthDate} onSelect={setBirthDate} />
            </div>
            <div>
              <h4 className="font-medium text-gray-700 mb-2">확인할 날짜</h4>
              <Calendar mode="single" selected={targetDate} onSelect={setTargetDate} />
            </div>
            <Button onClick={generateFortune} className="w-full bg-cyan-500 text-white hover:bg-cyan-600">
              운세 보기
            </Button>
          </CardContent>
        </Card>
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
          <FortuneResult result={result} />
        </motion.div>
      </div>
    </>
  );
}
