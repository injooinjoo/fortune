"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { DeterministicRandom } from '@/lib/deterministic-random';
import {
  Clock,
  Sun,
  Moon,
  Sunrise,
  Sunset,
  TrendingUp,
  TrendingDown,
  Minus
} from "lucide-react";

interface TimeSlotFortune {
  range: string;
  period: string;
  icon: typeof Sun;
  score: number;
  text: string;
  color: string;
}

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2
    }
  }
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 10
    }
  }
};

const getLuckColor = (score: number) => {
  if (score >= 80) return "text-green-600 bg-green-50";
  if (score >= 60) return "text-blue-600 bg-blue-50";
  if (score >= 40) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckIcon = (score: number) => {
  if (score >= 60) return TrendingUp;
  if (score >= 40) return Minus;
  return TrendingDown;
};

const fortuneTexts = [
  "새로운 아이디어가 떠오르는 시간입니다.",
  "사람들과의 교류가 활발해집니다.",
  "일에 집중하기 좋은 시간입니다.",
  "휴식이 필요한 순간입니다.",
  "재정적인 운이 따릅니다.",
  "건강 관리에 신경 써야 합니다.",
  "연인과의 시간이 좋습니다.",
  "모험을 피하는 것이 좋습니다."
];

const generateTimelineFortunes = (): TimeSlotFortune[] => {
  const periods = [
    { range: [6, 11], name: "오전", icon: Sunrise, color: "yellow" },
    { range: [12, 17], name: "오후", icon: Sun, color: "orange" },
    { range: [18, 23], name: "저녁", icon: Sunset, color: "purple" },
    { range: [0, 5], name: "밤", icon: Moon, color: "indigo" }
  ];

  const slots: TimeSlotFortune[] = [];

  for (let hour = 0; hour < 24; hour += 2) {
    const next = (hour + 2) % 24;
    const period =
      periods.find(p =>
        (p.range[0] <= p.range[1] && hour >= p.range[0] && hour <= p.range[1]) ||
        (p.range[0] > p.range[1] && (hour >= p.range[0] || hour <= p.range[1]))
      ) || periods[3];

    const base = deterministicRandom.randomInt(40, 40 + 40 - 1);
    const score = Math.max(20, Math.min(100, base + Math.floor(deterministicRandom.random() * 30) - 15));

    slots.push({
      range: `${hour.toString().padStart(2, "0")}:00~${next.toString().padStart(2, "0")}:00`,
      period: period.name,
      icon: period.icon,
      score,
      text: fortuneTexts[Math.floor(deterministicRandom.random() * fortuneTexts.length)],
      color: period.color
    });
  }

  return slots;
};

export default function TimelineFortunePage() {
  // Initialize deterministic random for consistent results
  // Get actual user ID from auth context
  const { user } = useAuth();
  const userId = user?.id || 'guest-user';
  const today = new Date().toISOString().split('T')[0];
  const fortuneType = 'page';
  const deterministicRandom = new DeterministicRandom(userId, today, fortuneType);

  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [fortunes, setFortunes] = useState<TimeSlotFortune[]>([]);

  useEffect(() => {
    setFortunes(generateTimelineFortunes());
  }, []);

  return (
    <>
      <AppHeader
        title="시간대별 운세"
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
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Clock className="w-5 h-5" />
                오늘의 시간대별 운세
              </CardTitle>
            </CardHeader>
            <CardContent className="relative pl-8">
              <div className="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200" />
              <div className="space-y-6">
                {fortunes.map((slot, idx) => {
                  const Icon = slot.icon;
                  const LuckIcon = getLuckIcon(slot.score);
                  return (
                    <motion.div
                      key={idx}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.2 + idx * 0.1 }}
                      className="relative flex items-start gap-4"
                    >
                      <div className={`w-8 h-8 rounded-full flex items-center justify-center bg-${slot.color}-100`}>
                        <Icon className={`w-4 h-4 text-${slot.color}-600`} />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <span className="font-medium text-gray-800">
                            {slot.range} ({slot.period})
                          </span>
                          <div className="flex items-center gap-1">
                            <LuckIcon className={`w-4 h-4 ${getLuckColor(slot.score).split(' ')[0]}`} />
                            <Badge className={`${getLuckColor(slot.score)} border-0`}>
                              {slot.score}점
                            </Badge>
                          </div>
                        </div>
                        <p className="text-sm text-gray-600 mt-1">{slot.text}</p>
                      </div>
                    </motion.div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </>
  );
}
