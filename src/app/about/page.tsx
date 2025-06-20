"use client";

import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { 
  ArrowLeft, 
  Sparkles, 
  Heart,
  Star,
  Shield,
  Smartphone,
  Globe,
  Users,
  Award,
  Zap,
  Calendar,
  Code,
  Mail,
  Phone,
  MapPin
} from "lucide-react";

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

export default function AboutPage() {
  const router = useRouter();

  const features = [
    {
      icon: Star,
      title: "정통 사주팔자",
      description: "전통적인 사주 이론을 바탕으로 한 정확한 운세 분석"
    },
    {
      icon: Sparkles,
      title: "AI 관상 분석",
      description: "최신 AI 기술로 얼굴을 분석하여 운세를 제공"
    },
    {
      icon: Heart,
      title: "개인 맞춤형",
      description: "개인의 생년월일과 MBTI를 바탕으로 한 맞춤 운세"
    },
    {
      icon: Smartphone,
      title: "모바일 최적화",
      description: "언제 어디서나 편리하게 사용할 수 있는 모바일 앱"
    }
  ];

  const team = [
    {
      role: "기획 & 개발",
      name: "Fortune Team",
      description: "사용자 경험을 최우선으로 하는 개발팀"
    },
    {
      role: "운세 컨설팅",
      name: "전통 사주 전문가",
      description: "30년 경력의 사주 명리학 전문가"
    },
    {
      role: "AI 기술",
      name: "AI 연구팀",
      description: "최신 머신러닝 기술을 활용한 관상 분석"
    }
  ];

  const stats = [
    { label: "누적 사용자", value: "10만+", icon: Users },
    { label: "운세 제공", value: "50만+", icon: Star },
    { label: "만족도", value: "4.8/5", icon: Heart },
    { label: "서비스 기간", value: "2년+", icon: Calendar }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="앱 정보" />

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 앱 소개 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white border-0">
            <CardContent className="p-6 text-center">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.3, type: "spring", stiffness: 200 }}
                className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4"
              >
                <Sparkles className="w-10 h-10 text-white" />
              </motion.div>
              <h2 className="text-2xl font-bold mb-2">Fortune</h2>
              <p className="text-white/80 mb-4">
                전통과 현대 기술이 만나는 새로운 운세 서비스
              </p>
              <div className="flex justify-center gap-2">
                <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                  v1.0.0
                </Badge>
                <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                  최신 업데이트
                </Badge>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 통계 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Award className="w-5 h-5 text-yellow-500" />
                서비스 현황
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                {stats.map((stat, index) => (
                  <motion.div
                    key={stat.label}
                    initial={{ scale: 0.8, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ delay: 0.4 + index * 0.1 }}
                    className="text-center p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg"
                  >
                    <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900/30 rounded-full flex items-center justify-center mx-auto mb-2">
                      <stat.icon className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                    </div>
                    <div className="text-2xl font-bold text-purple-600 dark:text-purple-400">
                      {stat.value}
                    </div>
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      {stat.label}
                    </div>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 주요 기능 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Zap className="w-5 h-5 text-blue-500" />
                주요 기능
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {features.map((feature, index) => (
                <motion.div
                  key={feature.title}
                  initial={{ x: -20, opacity: 0 }}
                  animate={{ x: 0, opacity: 1 }}
                  transition={{ delay: 0.5 + index * 0.1 }}
                  className="flex items-start gap-4 p-4 bg-gray-50 dark:bg-gray-800/50 rounded-lg"
                >
                  <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center flex-shrink-0">
                    <feature.icon className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-1">
                      {feature.title}
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      {feature.description}
                    </p>
                  </div>
                </motion.div>
              ))}
            </CardContent>
          </Card>
        </motion.div>

        {/* 개발팀 소개 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Users className="w-5 h-5 text-green-500" />
                개발팀 소개
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {team.map((member, index) => (
                <motion.div
                  key={member.role}
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: 0.6 + index * 0.1 }}
                  className="p-4 border border-gray-200 dark:border-gray-700 rounded-lg"
                >
                  <div className="flex items-center gap-3 mb-2">
                    <Badge variant="outline" className="text-xs">
                      {member.role}
                    </Badge>
                    <h3 className="font-medium text-gray-900 dark:text-gray-100">
                      {member.name}
                    </h3>
                  </div>
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    {member.description}
                  </p>
                </motion.div>
              ))}
            </CardContent>
          </Card>
        </motion.div>

        {/* 기술 스택 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Code className="w-5 h-5 text-purple-500" />
                기술 스택
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-3">
                {[
                  "Next.js 14",
                  "TypeScript",
                  "Tailwind CSS",
                  "Framer Motion",
                  "Supabase",
                  "AI/ML",
                  "PWA",
                  "Responsive Design"
                ].map((tech, index) => (
                  <motion.div
                    key={tech}
                    initial={{ scale: 0.8, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ delay: 0.7 + index * 0.05 }}
                    className="p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg text-center"
                  >
                    <span className="text-sm font-medium text-purple-700 dark:text-purple-300">
                      {tech}
                    </span>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 연락처 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Mail className="w-5 h-5 text-indigo-500" />
                연락처
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center gap-3">
                <Mail className="w-5 h-5 text-gray-500" />
                <span className="text-sm">contact@fortune-app.com</span>
              </div>
              <div className="flex items-center gap-3">
                <Globe className="w-5 h-5 text-gray-500" />
                <span className="text-sm">www.fortune-app.com</span>
              </div>
              <div className="flex items-center gap-3">
                <MapPin className="w-5 h-5 text-gray-500" />
                <span className="text-sm">Seoul, South Korea</span>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 저작권 */}
        <motion.div variants={itemVariants}>
          <Card className="border-gray-200 dark:border-gray-700 bg-gray-50/50 dark:bg-gray-800/50">
            <CardContent className="p-4 text-center">
              <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">
                © 2024 Fortune App. All rights reserved.
              </p>
              <p className="text-xs text-gray-500 dark:text-gray-500">
                Made with ❤️ in Seoul, Korea
              </p>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
} 