"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import AppHeader from "@/components/AppHeader";
import { 
  ArrowLeft, 
  Bell, 
  Smartphone, 
  Mail, 
  Clock, 
  Star,
  Sun,
  Moon,
  Heart,
  Briefcase,
  Zap,
  Volume2,
  VolumeX,
  BellRing
} from "lucide-react";

interface NotificationSetting {
  id: string;
  name: string;
  description: string;
  icon: any;
  enabled: boolean;
  type: 'push' | 'email' | 'both';
  time?: string;
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

export default function NotificationsPage() {
  const router = useRouter();
  const [globalPushEnabled, setGlobalPushEnabled] = useState(true);
  const [globalEmailEnabled, setGlobalEmailEnabled] = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [vibrationEnabled, setVibrationEnabled] = useState(true);
  const [dailyNotificationTime, setDailyNotificationTime] = useState("09:00");
  
  const [notifications, setNotifications] = useState<NotificationSetting[]>([
    {
      id: 'daily_fortune',
      name: '일일 운세 알림',
      description: '매일 아침 오늘의 운세를 알려드려요',
      icon: Sun,
      enabled: true,
      type: 'push',
      time: '09:00'
    },
    {
      id: 'weekly_fortune',
      name: '주간 운세 알림',
      description: '매주 월요일 이번 주 운세를 알려드려요',
      icon: Star,
      enabled: true,
      type: 'push'
    },
    {
      id: 'love_fortune',
      name: '연애운 특별 알림',
      description: '연애운이 좋은 날을 미리 알려드려요',
      icon: Heart,
      enabled: false,
      type: 'push'
    },
    {
      id: 'career_fortune',
      name: '취업운 특별 알림',
      description: '취업/승진에 좋은 날을 미리 알려드려요',
      icon: Briefcase,
      enabled: false,
      type: 'push'
    },
    {
      id: 'premium_features',
      name: '프리미엄 기능 안내',
      description: '새로운 프리미엄 기능 출시 소식',
      icon: Zap,
      enabled: true,
      type: 'both'
    },
    {
      id: 'app_updates',
      name: '앱 업데이트 알림',
      description: '새로운 기능 및 업데이트 소식',
      icon: BellRing,
      enabled: true,
      type: 'push'
    }
  ]);

  const toggleNotification = (id: string) => {
    setNotifications(prev => 
      prev.map(item => 
        item.id === id ? { ...item, enabled: !item.enabled } : item
      )
    );
  };

  const updateNotificationType = (id: string, type: 'push' | 'email' | 'both') => {
    setNotifications(prev => 
      prev.map(item => 
        item.id === id ? { ...item, type } : item
      )
    );
  };

  const getTypeText = (type: 'push' | 'email' | 'both') => {
    switch (type) {
      case 'push': return '푸시만';
      case 'email': return '이메일만';
      case 'both': return '푸시+이메일';
      default: return '푸시만';
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="알림 설정" />

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 전체 알림 설정 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Bell className="w-5 h-5" />
                전체 알림 설정
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Smartphone className="w-5 h-5 text-blue-500" />
                  <div>
                    <div className="font-medium">푸시 알림</div>
                    <div className="text-sm text-gray-500 dark:text-gray-400">
                      앱 알림 허용
                    </div>
                  </div>
                </div>
                <Switch
                  checked={globalPushEnabled}
                  onCheckedChange={setGlobalPushEnabled}
                />
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Mail className="w-5 h-5 text-green-500" />
                  <div>
                    <div className="font-medium">이메일 알림</div>
                    <div className="text-sm text-gray-500 dark:text-gray-400">
                      이메일로 알림 받기
                    </div>
                  </div>
                </div>
                <Switch
                  checked={globalEmailEnabled}
                  onCheckedChange={setGlobalEmailEnabled}
                />
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 푸시 알림 상세 설정 */}
        {globalPushEnabled && (
          <motion.div variants={itemVariants}>
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                  <Volume2 className="w-5 h-5" />
                  푸시 알림 상세 설정
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    {soundEnabled ? (
                      <Volume2 className="w-5 h-5 text-blue-500" />
                    ) : (
                      <VolumeX className="w-5 h-5 text-gray-400" />
                    )}
                    <div>
                      <div className="font-medium">알림 소리</div>
                      <div className="text-sm text-gray-500 dark:text-gray-400">
                        알림과 함께 소리 재생
                      </div>
                    </div>
                  </div>
                  <Switch
                    checked={soundEnabled}
                    onCheckedChange={setSoundEnabled}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <Smartphone className="w-5 h-5 text-purple-500" />
                    <div>
                      <div className="font-medium">진동</div>
                      <div className="text-sm text-gray-500 dark:text-gray-400">
                        알림과 함께 진동
                      </div>
                    </div>
                  </div>
                  <Switch
                    checked={vibrationEnabled}
                    onCheckedChange={setVibrationEnabled}
                  />
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 일일 운세 알림 시간 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Clock className="w-5 h-5" />
                일일 운세 알림 시간
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-medium">매일 알림 받을 시간</div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">
                    매일 이 시간에 오늘의 운세를 알려드려요
                  </div>
                </div>
                <Select value={dailyNotificationTime} onValueChange={setDailyNotificationTime}>
                  <SelectTrigger className="w-24">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="07:00">07:00</SelectItem>
                    <SelectItem value="08:00">08:00</SelectItem>
                    <SelectItem value="09:00">09:00</SelectItem>
                    <SelectItem value="10:00">10:00</SelectItem>
                    <SelectItem value="11:00">11:00</SelectItem>
                    <SelectItem value="12:00">12:00</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 개별 알림 설정 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <BellRing className="w-5 h-5" />
                개별 알림 설정
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {notifications.map((notification, index) => (
                <motion.div
                  key={notification.id}
                  initial={{ x: -20, opacity: 0 }}
                  animate={{ x: 0, opacity: 1 }}
                  transition={{ delay: index * 0.1 }}
                  className={`p-4 rounded-lg border transition-all duration-200 ${
                    notification.enabled 
                      ? 'border-purple-200 dark:border-purple-700 bg-purple-50/50 dark:bg-purple-900/10' 
                      : 'border-gray-200 dark:border-gray-700 bg-gray-50/50 dark:bg-gray-800/50'
                  }`}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3 flex-1">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center mt-1 ${
                        notification.enabled 
                          ? 'bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400' 
                          : 'bg-gray-100 dark:bg-gray-800 text-gray-400'
                      }`}>
                        <notification.icon className="w-5 h-5" />
                      </div>
                      <div className="flex-1">
                        <h3 className={`font-medium ${
                          notification.enabled 
                            ? 'text-gray-900 dark:text-gray-100' 
                            : 'text-gray-500 dark:text-gray-400'
                        }`}>
                          {notification.name}
                        </h3>
                        <p className={`text-sm mt-1 ${
                          notification.enabled 
                            ? 'text-gray-600 dark:text-gray-300' 
                            : 'text-gray-400 dark:text-gray-500'
                        }`}>
                          {notification.description}
                        </p>
                        {notification.enabled && (
                          <div className="flex items-center gap-2 mt-2">
                            <Select 
                              value={notification.type} 
                              onValueChange={(value: 'push' | 'email' | 'both') => 
                                updateNotificationType(notification.id, value)
                              }
                            >
                              <SelectTrigger className="w-32 h-8 text-xs">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="push">푸시만</SelectItem>
                                <SelectItem value="email">이메일만</SelectItem>
                                <SelectItem value="both">푸시+이메일</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                        )}
                      </div>
                    </div>
                    <Switch
                      checked={notification.enabled}
                      onCheckedChange={() => toggleNotification(notification.id)}
                    />
                  </div>
                </motion.div>
              ))}
            </CardContent>
          </Card>
        </motion.div>

        {/* 도움말 */}
        <motion.div variants={itemVariants}>
          <Card className="border-blue-200 dark:border-blue-700 bg-blue-50/50 dark:bg-blue-900/10">
            <CardContent className="p-4">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Bell className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                </div>
                <div>
                  <h3 className="font-medium text-blue-900 dark:text-blue-100 mb-1">
                    알림 설정 안내
                  </h3>
                  <ul className="text-sm text-blue-700 dark:text-blue-300 space-y-1">
                    <li>• 전체 알림을 끄면 모든 개별 알림이 비활성화됩니다</li>
                    <li>• 이메일 알림은 중요한 정보만 발송됩니다</li>
                    <li>• 설정은 즉시 적용되며 언제든 변경할 수 있습니다</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
} 