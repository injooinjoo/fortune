"use client";

import React from 'react';
import { motion } from 'framer-motion';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { 
  Star, BarChart3, TrendingUp, Heart, Briefcase, 
  Coins, Shield, Activity, Crown, Clock, MapPin 
} from 'lucide-react';

interface ScoreDisplayProps {
  label: string;
  score: number;
  description?: string;
  icon?: React.ComponentType<{ className?: string }>;
}

interface LuckyItemProps {
  label: string;
  value: string;
  icon?: React.ComponentType<{ className?: string }>;
  color?: string;
}

interface FortuneResultDisplayProps {
  // 공통 속성
  overallScore?: number;
  title: string;
  summary?: string;
  
  // 세부 점수들
  scores?: ScoreDisplayProps[];
  
  // 행운 요소들
  luckyItems?: LuckyItemProps[];
  
  // 조언과 주의사항
  recommendations?: string[];
  warnings?: string[];
  
  // 예측
  predictions?: {
    timeframe: string;
    content: string;
  }[];
  
  // 분석 (SWOT 등)
  analysis?: {
    strength?: string;
    weakness?: string;
    opportunity?: string;
    threat?: string;
  };
  
  // 스타일링
  theme?: {
    primary: string;
    gradient: string;
    icon: React.ComponentType<{ className?: string }>;
  };
  
  // 폰트 크기
  fontSize?: 'small' | 'medium' | 'large';
}

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "매우 좋음";
  if (score >= 70) return "좋음";
  if (score >= 55) return "보통";
  return "주의 필요";
};

export default function FortuneResultDisplay({
  overallScore,
  title,
  summary,
  scores = [],
  luckyItems = [],
  recommendations = [],
  warnings = [],
  predictions = [],
  analysis,
  theme = {
    primary: 'purple',
    gradient: 'from-purple-500 to-indigo-500',
    icon: Star
  },
  fontSize = 'medium'
}: FortuneResultDisplayProps) {
  
  const getFontSizeClasses = (size: 'small' | 'medium' | 'large') => {
    switch (size) {
      case 'small':
        return {
          text: 'text-sm',
          title: 'text-lg',
          heading: 'text-xl',
          score: 'text-4xl',
          label: 'text-xs'
        };
      case 'large':
        return {
          text: 'text-lg',
          title: 'text-2xl',
          heading: 'text-3xl',
          score: 'text-8xl',
          label: 'text-base'
        };
      default:
        return {
          text: 'text-base',
          title: 'text-xl',
          heading: 'text-2xl',
          score: 'text-6xl',
          label: 'text-sm'
        };
    }
  };

  const fontClasses = getFontSizeClasses(fontSize);

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

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className="space-y-6"
    >
      {/* 전체 운세 점수 */}
      {overallScore && (
        <motion.div variants={itemVariants}>
          <Card className={`bg-gradient-to-r ${theme.gradient} text-white`}>
            <CardContent className="text-center py-8">
              <div className={`flex items-center justify-center gap-2 mb-4`}>
                <theme.icon className="w-6 h-6" />
                <span className={`${fontClasses.title} font-medium`}>{title}</span>
              </div>
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.3, type: "spring" }}
                className={`${fontClasses.score} font-bold mb-2`}
              >
                {overallScore}점
              </motion.div>
              <Badge variant="secondary" className={`${fontClasses.text} bg-white/20 text-white border-white/30`}>
                {getLuckText(overallScore)}
              </Badge>
              {summary && (
                <p className={`${fontClasses.text} mt-4 opacity-90`}>
                  {summary}
                </p>
              )}
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* 세부 운세 점수들 */}
      {scores.length > 0 && (
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-${theme.primary}-600`}>
                <BarChart3 className="w-5 h-5" />
                세부 운세
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {scores.map((score, index) => (
                <motion.div
                  key={score.label}
                  initial={{ x: -20, opacity: 0 }}
                  animate={{ x: 0, opacity: 1 }}
                  transition={{ delay: 0.4 + index * 0.1 }}
                  className="space-y-2"
                >
                  <div className="flex items-center gap-3">
                    {score.icon && <score.icon className="w-5 h-5 text-gray-600" />}
                    <div className="flex-1">
                      <div className="flex justify-between items-center mb-1">
                        <div>
                          <span className={`${fontClasses.text} font-medium`}>{score.label}</span>
                          {score.description && (
                            <p className={`${fontClasses.label} text-gray-500`}>{score.description}</p>
                          )}
                        </div>
                        <span className={`px-3 py-1 rounded-full ${fontClasses.label} font-medium ${getLuckColor(score.score)}`}>
                          {score.score}점
                        </span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <motion.div
                          className={`bg-${theme.primary}-500 h-2 rounded-full`}
                          initial={{ width: 0 }}
                          animate={{ width: `${score.score}%` }}
                          transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }}
                        />
                      </div>
                    </div>
                  </div>
                </motion.div>
              ))}
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* 행운의 요소들 */}
      {luckyItems.length > 0 && (
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-${theme.primary}-600`}>
                <Crown className="w-5 h-5" />
                행운의 요소들
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                {luckyItems.map((item, index) => (
                  <motion.div
                    key={item.label}
                    initial={{ scale: 0.8, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ delay: 0.3 + index * 0.1 }}
                    className={`p-4 bg-${item.color || theme.primary}-50 rounded-lg`}
                  >
                    <h4 className={`${fontClasses.text} font-medium text-${item.color || theme.primary}-800 mb-2 flex items-center gap-2`}>
                      {item.icon && <item.icon className="w-4 h-4" />}
                      {item.label}
                    </h4>
                    <p className={`${fontClasses.title} font-semibold text-${item.color || theme.primary}-700`}>
                      {item.value}
                    </p>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* SWOT 분석 */}
      {analysis && (
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-${theme.primary}-600`}>
                <TrendingUp className="w-5 h-5" />
                종합 분석
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {analysis.strength && (
                <div className="p-4 bg-green-50 rounded-lg">
                  <h4 className={`${fontClasses.text} font-medium text-green-800 mb-2`}>강점 (Strength)</h4>
                  <p className={`${fontClasses.text} text-green-700`}>{analysis.strength}</p>
                </div>
              )}
              {analysis.weakness && (
                <div className="p-4 bg-orange-50 rounded-lg">
                  <h4 className={`${fontClasses.text} font-medium text-orange-800 mb-2`}>약점 (Weakness)</h4>
                  <p className={`${fontClasses.text} text-orange-700`}>{analysis.weakness}</p>
                </div>
              )}
              {analysis.opportunity && (
                <div className="p-4 bg-blue-50 rounded-lg">
                  <h4 className={`${fontClasses.text} font-medium text-blue-800 mb-2`}>기회 (Opportunity)</h4>
                  <p className={`${fontClasses.text} text-blue-700`}>{analysis.opportunity}</p>
                </div>
              )}
              {analysis.threat && (
                <div className="p-4 bg-red-50 rounded-lg">
                  <h4 className={`${fontClasses.text} font-medium text-red-800 mb-2`}>위험 (Threat)</h4>
                  <p className={`${fontClasses.text} text-red-700`}>{analysis.threat}</p>
                </div>
              )}
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* 조언 및 주의사항 */}
      {(recommendations.length > 0 || warnings.length > 0) && (
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-${theme.primary}-600`}>
                <Shield className="w-5 h-5" />
                조언 및 주의사항
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {recommendations.length > 0 && (
                <div className="space-y-2">
                  <h4 className={`${fontClasses.text} font-medium text-green-700`}>추천사항</h4>
                  <ul className="space-y-1">
                    {recommendations.map((rec, index) => (
                      <li key={index} className={`${fontClasses.text} text-green-600 flex items-start gap-2`}>
                        <span className="text-green-500 mt-1">•</span>
                        {rec}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
              {warnings.length > 0 && (
                <div className="space-y-2">
                  <h4 className={`${fontClasses.text} font-medium text-orange-700`}>주의사항</h4>
                  <ul className="space-y-1">
                    {warnings.map((warning, index) => (
                      <li key={index} className={`${fontClasses.text} text-orange-600 flex items-start gap-2`}>
                        <span className="text-orange-500 mt-1">⚠</span>
                        {warning}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </CardContent>
          </Card>
        </motion.div>
      )}

      {/* 예측 */}
      {predictions.length > 0 && (
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-${theme.primary}-600`}>
                <Clock className="w-5 h-5" />
                미래 예측
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {predictions.map((prediction, index) => (
                <div key={index} className={`p-4 bg-${theme.primary}-50 rounded-lg`}>
                  <h4 className={`${fontClasses.text} font-medium text-${theme.primary}-800 mb-2`}>
                    {prediction.timeframe}
                  </h4>
                  <p className={`${fontClasses.text} text-${theme.primary}-700`}>
                    {prediction.content}
                  </p>
                </div>
              ))}
            </CardContent>
          </Card>
        </motion.div>
      )}
    </motion.div>
  );
} 