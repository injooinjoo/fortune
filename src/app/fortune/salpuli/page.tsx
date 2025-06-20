"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import AppHeader from "@/components/AppHeader";
import { ShieldAlert } from "lucide-react";

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

interface SalInfo {
  name: string;
  meaning: string;
  advice: string;
}

const salList: SalInfo[] = [
  {
    name: "천살",
    meaning: "예기치 못한 변화가 자주 찾아와 마음이 흔들릴 수 있는 기운입니다.",
    advice: "변화를 두려워하지 말고 차분히 대처하면 오히려 기회를 만들 수 있습니다."
  },
  {
    name: "지살",
    meaning: "이사나 환경 변화에서 불안이 생기기 쉬운 기운입니다.",
    advice: "충동적인 결정은 피하고 미리 계획을 세우면 안정감을 얻을 수 있습니다."
  },
  {
    name: "형살",
    meaning: "주변과의 갈등이나 법적 문제에 엮일 수 있는 기운입니다.",
    advice: "원칙을 지키며 소통하면 갈등을 줄이고 성장을 이룰 수 있습니다."
  },
  {
    name: "재살",
    meaning: "예상하지 못한 손실이나 사고가 생길 수 있는 기운입니다.",
    advice: "안전 수칙을 지키고 대비책을 마련하면 걱정을 줄일 수 있습니다."
  },
  {
    name: "역마살",
    meaning: "이동과 변화가 많아 마음이 안정되지 않을 수 있는 기운입니다.",
    advice: "여행이나 자기계발 등 긍정적인 활동으로 에너지를 활용해 보세요."
  },
  {
    name: "망신살",
    meaning: "작은 실수로 체면을 구기기 쉬운 기운입니다.",
    advice: "겸손한 태도와 철저한 준비가 오히려 신뢰를 높여 줄 것입니다."
  }
];

export default function SalpuliPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <>
      <AppHeader
        title="살풀이"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        <motion.div variants={itemVariants} className="text-center space-y-2">
          <div className="flex items-center justify-center gap-2 mb-4">
            <ShieldAlert className="w-8 h-8 text-red-600" />
            <h1 className="text-2xl font-bold text-gray-900">살풀이 가이드</h1>
          </div>
          <p className="text-gray-600 leading-relaxed">
            사주에 나타난 흉살의 의미를 이해하고 긍정적인 변화를 위한 조언을 확인해보세요.
          </p>
        </motion.div>
        <motion.div variants={itemVariants} className="space-y-4">
          {salList.map((sal) => (
            <motion.div
              key={sal.name}
              variants={itemVariants}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <Card className="hover:shadow-md transition-all">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-red-700">
                    <ShieldAlert className="w-5 h-5" />
                    {sal.name}
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-1">
                  <p className="text-sm text-gray-600">{sal.meaning}</p>
                  <p className="text-sm text-purple-700">✨ {sal.advice}</p>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>
    </>
  );
}
