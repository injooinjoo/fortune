"use client";

import React from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";
import { Calendar, ChevronDown, Star } from "lucide-react";
import { cn } from "@/lib/utils";

interface KoreanDatePickerProps {
  value?: string; // YYYY-MM-DD 형식
  onChange?: (date: string) => void;
  placeholder?: string;
  className?: string;
  disabled?: boolean;
  required?: boolean;
  label?: string;
}

export function KoreanDatePicker({
  value = "",
  onChange,
  placeholder = "생년월일을 선택하세요",
  className,
  disabled = false,
  required = false,
  label
}: KoreanDatePickerProps) {
  // 현재 날짜
  const today = new Date();
  const currentYear = today.getFullYear();
  const currentMonth = today.getMonth() + 1;
  const currentDay = today.getDate();

  // 입력된 값에서 년/월/일 분리
  const [year, month, day] = value.split('-').map(v => v || '');

  // 년도 옵션 생성 (1900년부터 현재년도까지)
  const yearOptions = Array.from({ length: currentYear - 1900 + 1 }, (_, i) => {
    const yearValue = currentYear - i;
    return { value: yearValue.toString(), label: `${yearValue}년` };
  });

  // 월 옵션 생성 (한국어)
  const monthOptions = Array.from({ length: 12 }, (_, i) => {
    const monthValue = i + 1;
    return { 
      value: monthValue.toString().padStart(2, '0'), 
      label: `${monthValue}월` 
    };
  });

  // 일 옵션 생성 (선택된 년/월에 따라 동적으로)
  const getDaysInMonth = (year: number, month: number) => {
    return new Date(year, month, 0).getDate();
  };

  const dayOptions = React.useMemo(() => {
    if (!year || !month) return [];
    
    const selectedYear = parseInt(year);
    const selectedMonth = parseInt(month);
    const daysInMonth = getDaysInMonth(selectedYear, selectedMonth);
    
    return Array.from({ length: daysInMonth }, (_, i) => {
      const dayValue = i + 1;
      
      // 미래 날짜인지 확인
      const isInFuture = selectedYear > currentYear || 
        (selectedYear === currentYear && selectedMonth > currentMonth) ||
        (selectedYear === currentYear && selectedMonth === currentMonth && dayValue > currentDay);
      
      return { 
        value: dayValue.toString().padStart(2, '0'), 
        label: `${dayValue}일`,
        disabled: isInFuture
      };
    });
  }, [year, month, currentYear, currentMonth, currentDay]);

  // 값 변경 핸들러
  const handleChange = (type: 'year' | 'month' | 'day', newValue: string) => {
    let newYear = year;
    let newMonth = month;
    let newDay = day;

    if (type === 'year') {
      newYear = newValue;
      // 년도가 변경되면 일자 재검증
      if (newMonth && newDay) {
        const daysInNewMonth = getDaysInMonth(parseInt(newValue), parseInt(newMonth));
        if (parseInt(newDay) > daysInNewMonth) {
          newDay = daysInNewMonth.toString().padStart(2, '0');
        }
      }
    } else if (type === 'month') {
      newMonth = newValue;
      // 월이 변경되면 일자 재검증
      if (newYear && newDay) {
        const daysInNewMonth = getDaysInMonth(parseInt(newYear), parseInt(newValue));
        if (parseInt(newDay) > daysInNewMonth) {
          newDay = daysInNewMonth.toString().padStart(2, '0');
        }
      }
    } else if (type === 'day') {
      newDay = newValue;
    }

    // 모든 값이 있을 때만 onChange 호출
    if (newYear && newMonth && newDay && onChange) {
      const dateString = `${newYear}-${newMonth}-${newDay}`;
      onChange(dateString);
    }
  };

  // 선택된 날짜가 있을 때 나이 계산
  const getAge = () => {
    if (!year || !month || !day) return null;
    const birthDate = new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  const age = getAge();

  return (
    <div className={cn("space-y-3", className)}>
      {label && (
        <Label className="text-sm font-medium flex items-center gap-2">
          <Calendar className="w-4 h-4 text-purple-600" />
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </Label>
      )}
      
      <Card className="border-2 border-dashed border-gray-200 hover:border-purple-300 transition-all duration-300 bg-gradient-to-br from-purple-50/30 to-pink-50/30">
        <CardContent className="p-4">
          <div className="grid grid-cols-3 gap-3">
            {/* 년도 선택 */}
            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <Label className="text-xs text-purple-700 mb-2 block font-medium flex items-center gap-1">
                <Star className="w-3 h-3" />
                년도
              </Label>
              <Select 
                value={year} 
                onValueChange={(value) => handleChange('year', value)}
                disabled={disabled}
              >
                <SelectTrigger className="w-full border-purple-200 hover:border-purple-300 transition-colors bg-white/80 backdrop-blur-sm">
                  <SelectValue placeholder="년" />
                  <ChevronDown className="w-4 h-4 text-purple-500" />
                </SelectTrigger>
                <SelectContent className="max-h-[200px]">
                  {yearOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </motion.div>

            {/* 월 선택 */}
            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <Label className="text-xs text-purple-700 mb-2 block font-medium flex items-center gap-1">
                <Star className="w-3 h-3" />
                월
              </Label>
              <Select 
                value={month} 
                onValueChange={(value) => handleChange('month', value)}
                disabled={disabled || !year}
              >
                <SelectTrigger className={cn(
                  "w-full border-purple-200 hover:border-purple-300 transition-colors bg-white/80 backdrop-blur-sm",
                  !year && "opacity-50"
                )}>
                  <SelectValue placeholder="월" />
                  <ChevronDown className="w-4 h-4 text-purple-500" />
                </SelectTrigger>
                <SelectContent>
                  {monthOptions.map((option) => {
                    // 미래 월인지 확인 (현재 년도인 경우만)
                    const isInFuture = year === currentYear.toString() && 
                      parseInt(option.value) > currentMonth;
                    
                    return (
                      <SelectItem 
                        key={option.value} 
                        value={option.value}
                        disabled={isInFuture}
                      >
                        {option.label}
                      </SelectItem>
                    );
                  })}
                </SelectContent>
              </Select>
            </motion.div>

            {/* 일 선택 */}
            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <Label className="text-xs text-purple-700 mb-2 block font-medium flex items-center gap-1">
                <Star className="w-3 h-3" />
                일
              </Label>
              <Select 
                value={day} 
                onValueChange={(value) => handleChange('day', value)}
                disabled={disabled || !year || !month}
              >
                <SelectTrigger className={cn(
                  "w-full border-purple-200 hover:border-purple-300 transition-colors bg-white/80 backdrop-blur-sm",
                  (!year || !month) && "opacity-50"
                )}>
                  <SelectValue placeholder="일" />
                  <ChevronDown className="w-4 h-4 text-purple-500" />
                </SelectTrigger>
                <SelectContent className="max-h-[200px]">
                  {dayOptions.map((option) => (
                    <SelectItem 
                      key={option.value} 
                      value={option.value}
                      disabled={option.disabled}
                    >
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </motion.div>
          </div>

          {/* 선택된 날짜 미리보기 */}
          <AnimatePresence>
            {year && month && day && (
              <motion.div 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="mt-4 p-3 rounded-lg bg-gradient-to-r from-purple-100 to-pink-100 border border-purple-200"
              >
                <div className="text-center">
                  <motion.div 
                    initial={{ scale: 0.9 }}
                    animate={{ scale: 1 }}
                    className="text-lg font-bold text-purple-800 mb-1"
                  >
                    {year}년 {parseInt(month)}월 {parseInt(day)}일
                  </motion.div>
                  {age !== null && (
                    <motion.div 
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: 0.2 }}
                      className="text-sm text-purple-600 flex items-center justify-center gap-1"
                    >
                      <Star className="w-3 h-3" />
                      만 {age}세
                    </motion.div>
                  )}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
          
          {!year && !month && !day && placeholder && (
            <div className="text-center mt-4 p-3 rounded-lg border-2 border-dashed border-gray-300 text-gray-500 bg-gray-50/50">
              <Calendar className="w-5 h-5 mx-auto mb-1 text-gray-400" />
              <div className="text-sm">{placeholder}</div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}