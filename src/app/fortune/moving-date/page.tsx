"use client";

import { useState, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Calendar as CalendarIcon } from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import { 
  Home, 
  MapPin, 
  Star, 
  TrendingUp, 
  AlertTriangle, 
  CheckCircle, 
  ArrowRight,
  Sparkles,
  Clock,
  Target,
  Heart,
  Coins,
  Shield
} from "lucide-react";

export default function MovingDatePage() {
  const [loading, setLoading] = useState(false);
  const [birthDate, setBirthDate] = useState('');
  const [movingMonth, setMovingMonth] = useState('');
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

  const formatKoreanDate = (dateString: string): string => {
    if (!dateString) return '';
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}년 ${month}월 ${day}일`;
  };

  const formatKoreanMonth = (monthString: string): string => {
    if (!monthString) return '';
    const [year, month] = monthString.split('-');
    return `${year}년 ${month}월`;
  };

  const DateInput = ({ 
    value, 
    onChange, 
    label, 
    placeholder = "날짜를 선택해주세요",
    type = "date"
  }: { 
    value: string; 
    onChange: (value: string) => void; 
    label: string;
    placeholder?: string;
    type?: "date" | "month";
  }) => {
    const [tempValue, setTempValue] = useState(value);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      const newValue = e.target.value;
      setTempValue(newValue);
      onChange(newValue);
    };

    const displayValue = type === "month" ? formatKoreanMonth(value) : formatKoreanDate(value);

    return (
      <div className="relative">
        <Label className="text-gray-700 dark:text-gray-300 font-medium mb-2 block">
          {label}
        </Label>
        <motion.div
          className="relative"
          whileHover={{ scale: 1.01 }}
          whileTap={{ scale: 0.99 }}
        >
          <div className="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-800 cursor-pointer transition-all duration-200 hover:border-green-400 dark:hover:border-green-500 focus-within:border-green-500 dark:focus-within:border-green-400 focus-within:ring-2 focus-within:ring-green-200 dark:focus-within:ring-green-800">
            <div className="flex items-center justify-between">
              <span className={`${value ? 'text-gray-900 dark:text-gray-100' : 'text-gray-500 dark:text-gray-400'} font-medium`}>
                {value ? displayValue : placeholder}
              </span>
              <Calendar className="w-5 h-5 text-gray-400 dark:text-gray-500" />
            </div>
          </div>
          
          <input
            type={type}
            value={tempValue}
            onChange={handleChange}
            className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
          />
        </motion.div>
        
        {value && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mt-2 px-3 py-2 bg-green-50 dark:bg-green-900/30 rounded-lg border border-green-200 dark:border-green-700"
          >
            <div className="flex items-center gap-2">
              <Calendar className="w-4 h-4 text-green-600 dark:text-green-400" />
              <span className="text-sm font-medium text-green-700 dark:text-green-300">
                선택된 {type === "month" ? "월" : "날짜"}: {displayValue}
              </span>
            </div>
          </motion.div>
        )}
      </div>
    );
  };

  const handleSubmit = () => {
    if (!birthDate || !movingMonth) return;
    setLoading(true);
    
    setTimeout(() => {
      const birth = new Date(birthDate);
      const [year, month] = movingMonth.split("-").map(Number);
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
      setLoading(false);
    }, 1000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-white to-emerald-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-20">
      <AppHeader
        title="이사 날짜"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-4"
      >
        <motion.div className="space-y-6">
            <motion.div variants={itemVariants} className="text-center">
              <motion.div
                className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-green-500 to-emerald-600 rounded-full mb-4"
                animate={{ rotate: 360 }}
                transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
              >
                <Home className="w-8 h-8 text-white" />
              </motion.div>
              <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                이사 날짜 운세
              </h1>
              <p className="text-gray-600 dark:text-gray-400">
                새로운 보금자리로의 이사에 좋은 날을 찾아드립니다
              </p>
            </motion.div>

            <motion.div variants={itemVariants}>
              <Card className="border-green-200 dark:border-green-700 dark:bg-gray-800">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-green-700 dark:text-green-400">
                    <CalendarIcon className="w-5 h-5" />
                    정보 입력
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-6">
                  <KoreanDatePicker
                    label="생년월일"
                    value={birthDate}
                    onChange={setBirthDate}
                    placeholder="태어난 날짜를 선택해주세요"
                    required
                  />
                  
                  <DateInput
                    value={movingMonth}
                    onChange={setMovingMonth}
                    label="이사 예정 월"
                    placeholder="이사하고 싶은 월을 선택해주세요"
                    type="month"
                  />
                  
                  <motion.div
                    className="p-4 bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 rounded-xl border border-green-200 dark:border-green-700"
                    whileHover={{ scale: 1.02 }}
                  >
                    <div className="flex items-start gap-3">
                      <div className="flex-shrink-0 w-8 h-8 bg-green-100 dark:bg-green-800 rounded-full flex items-center justify-center">
                        <Home className="w-4 h-4 text-green-600 dark:text-green-400" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-green-900 dark:text-green-100 mb-1">
                          이사 날짜의 중요성
                        </h3>
                        <p className="text-sm text-green-700 dark:text-green-300 leading-relaxed">
                          새로운 보금자리로의 이사는 인생의 중요한 전환점입니다. 좋은 날을 선택하여 행운과 번영을 함께 가져가세요.
                        </p>
                      </div>
                    </div>
                  </motion.div>
                </CardContent>
              </Card>
            </motion.div>

            <motion.div variants={itemVariants}>
              <motion.div
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <Button
                  onClick={handleSubmit}
                  disabled={!birthDate || !movingMonth || loading}
                  className="w-full py-4 bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white font-semibold rounded-xl shadow-lg transition-all duration-200"
                >
                  {loading ? (
                    <div className="flex items-center gap-2">
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity }}
                      >
                        <Home className="w-5 h-5" />
                      </motion.div>
                      분석 중...
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-5 h-5" />
                      이사 날짜 분석하기
                    </div>
                  )}
                </Button>
              </motion.div>
            </motion.div>
          </motion.div>

        {result && (
          <motion.div variants={itemVariants}>
            <Card className="border-green-200 dark:border-green-700 dark:bg-gray-800">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-green-700 dark:text-green-400">
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
    </div>
  );
}
