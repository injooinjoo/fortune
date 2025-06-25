"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Textarea } from "@/components/ui/textarea";
import AppHeader from "@/components/AppHeader";
import {
  User,
  Mail,
  Calendar,
  Camera,
  Save,
  ArrowLeft,
  Smartphone,
  MapPin
} from "lucide-react";
import { supabase } from "@/lib/supabase";

interface UserProfile {
  id: string;
  email: string;
  name: string;
  avatar_url?: string;
  provider: string;
  phone?: string;
  bio?: string;
  location?: string;
  birth_date?: string;
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

export default function ProfileEditPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    bio: '',
    location: '',
    birth_date: ''
  });

  useEffect(() => {
    loadUserProfile();
  }, []);

  const loadUserProfile = async () => {
    try {
      const { data: { user: authUser } } = await supabase.auth.getUser();
      
      if (authUser) {
        const userProfile: UserProfile = {
          id: authUser.id,
          email: authUser.email || '',
          name: authUser.user_metadata?.full_name || authUser.user_metadata?.name || '',
          avatar_url: authUser.user_metadata?.avatar_url || authUser.user_metadata?.picture,
          provider: authUser.app_metadata?.provider || 'google',
          phone: authUser.user_metadata?.phone || '',
          bio: authUser.user_metadata?.bio || '',
          location: authUser.user_metadata?.location || '',
          birth_date: authUser.user_metadata?.birth_date || ''
        };
        
        setUser(userProfile);
        setFormData({
          name: userProfile.name,
          email: userProfile.email,
          phone: userProfile.phone || '',
          bio: userProfile.bio || '',
          location: userProfile.location || '',
          birth_date: userProfile.birth_date || ''
        });
      }
    } catch (error) {
      console.error('사용자 프로필 로드 실패:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    if (!user) return;

    setIsSaving(true);
    try {
      // 실제로는 Supabase에서 프로필 업데이트
      const { error } = await supabase.auth.updateUser({
        data: {
          full_name: formData.name,
          phone: formData.phone,
          bio: formData.bio,
          location: formData.location,
          birth_date: formData.birth_date
        }
      });

      if (error) throw error;

      // 성공 시 뒤로 가기
      router.back();
    } catch (error) {
      console.error('프로필 저장 실패:', error);
      alert('프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleAvatarUpload = () => {
    // 실제로는 이미지 업로드 처리
    alert('아바타 업로드 기능은 준비 중입니다.');
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background pb-20">
        <AppHeader title="프로필 수정" />
        <div className="p-6">
          <div className="animate-pulse space-y-4">
            <div className="h-32 bg-gray-200 rounded-lg"></div>
            <div className="h-64 bg-gray-200 rounded-lg"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-background pb-20">
        <AppHeader title="프로필 수정" />
        <div className="p-6 text-center">
          <p>사용자 정보를 불러올 수 없습니다.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-purple-900/20 dark:to-indigo-900/20 pb-20">
      <AppHeader title="프로필 수정" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 아바타 섹션 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
            <CardContent className="p-6">
              <div className="flex flex-col items-center space-y-4">
                <div className="relative">
                  <Avatar className="w-24 h-24">
                    <AvatarImage src={user.avatar_url} alt={user.name} />
                    <AvatarFallback className="text-2xl bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400">
                      {user.name.charAt(0).toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <Button
                    size="sm"
                    onClick={handleAvatarUpload}
                    className="absolute -bottom-2 -right-2 rounded-full w-8 h-8 p-0 bg-purple-600 hover:bg-purple-700 dark:bg-purple-500 dark:hover:bg-purple-600"
                  >
                    <Camera className="w-4 h-4" />
                  </Button>
                </div>
                <div className="text-center">
                  <h3 className="font-semibold text-lg">{user.name}</h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400">{user.email}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기본 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="w-5 h-5" />
                기본 정보
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="name">이름</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                  placeholder="이름을 입력하세요"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="email">이메일</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="email"
                    type="email"
                    value={formData.email}
                    disabled
                    className="pl-10 bg-gray-50 dark:bg-gray-800"
                    placeholder="이메일"
                  />
                </div>
                <p className="text-xs text-gray-500">이메일은 변경할 수 없습니다.</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="phone">전화번호</Label>
                <div className="relative">
                  <Smartphone className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="phone"
                    type="tel"
                    value={formData.phone}
                    onChange={(e) => setFormData(prev => ({ ...prev, phone: e.target.value }))}
                    className="pl-10"
                    placeholder="전화번호를 입력하세요"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="birth_date">생년월일</Label>
                <div className="relative">
                  <Calendar className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="birth_date"
                    type="date"
                    value={formData.birth_date}
                    onChange={(e) => setFormData(prev => ({ ...prev, birth_date: e.target.value }))}
                    className="pl-10"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="location">거주지</Label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="location"
                    value={formData.location}
                    onChange={(e) => setFormData(prev => ({ ...prev, location: e.target.value }))}
                    className="pl-10"
                    placeholder="거주지를 입력하세요"
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 소개 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle>소개</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <Label htmlFor="bio">자기소개</Label>
                <Textarea
                  id="bio"
                  value={formData.bio}
                  onChange={(e) => setFormData(prev => ({ ...prev, bio: e.target.value }))}
                  placeholder="자신에 대해 간단히 소개해주세요"
                  className="min-h-[100px]"
                />
                <p className="text-xs text-gray-500">최대 200자까지 입력 가능합니다.</p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 저장 버튼 */}
        <motion.div variants={itemVariants} className="pt-4 space-y-3">
          <Button
            onClick={handleSave}
            disabled={isSaving}
            className="w-full bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600 text-white py-3"
          >
            {isSaving ? (
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ repeat: Infinity, duration: 1 }}
                className="flex items-center gap-2"
              >
                <Save className="w-4 h-4" />
                저장 중...
              </motion.div>
            ) : (
              <div className="flex items-center gap-2">
                <Save className="w-4 h-4" />
                저장하기
              </div>
            )}
          </Button>

          <Button
            onClick={() => router.back()}
            variant="outline"
            className="w-full"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            취소
          </Button>
        </motion.div>
      </motion.div>
    </div>
  );
} 