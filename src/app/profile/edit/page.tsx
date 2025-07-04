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
  Clock,
  Brain,
  Sparkles,
} from "lucide-react";
import { supabase } from "@/lib/supabase";
import { getZodiacSign, getChineseZodiac } from "@/lib/user-storage";

interface UserProfile {
  id: string;
  email: string;
  name: string;
  avatar_url?: string;
  provider: string;
  birth_date?: string;
  birth_time?: string;
  mbti?: string;
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
    birth_date: '',
    birth_time: '',
    mbti: '',
  });

  useEffect(() => {
    loadUserProfile();
  }, []);

  const loadUserProfile = async () => {
    try {
      const { data: { user: authUser } } = await supabase.auth.getUser();
      
      if (!authUser) {
        router.push('/auth/selection');
        return;
      }

      // 1. user_profiles 테이블에서 프로필 정보와 온보딩 완료 여부 조회
      const { data: profileDataArray, error: profileError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', authUser.id);

      // --- 디버깅용 로그 추가 ---
      console.log("Supabase profile fetch error:", profileError);
      console.log("Supabase profile fetch data:", profileDataArray);
      // ------------------------

      // DB 조회 시 에러 발생
      if (profileError) {
        throw profileError;
      }
      
      const profileData = profileDataArray && profileDataArray[0];

      // 프로필이 존재하고 온보딩이 완료된 경우에만 페이지 표시
      if (profileData && profileData.onboarding_completed) {
        const userProfile: UserProfile = {
          id: authUser.id,
          email: authUser.email || '',
          name: profileData.name || '',
          avatar_url: profileData.avatar_url || authUser.user_metadata?.avatar_url,
          provider: authUser.app_metadata?.provider || 'google',
          birth_date: profileData.birth_date || '',
          birth_time: profileData.birth_time || '',
          mbti: profileData.mbti || '',
        };
        setUser(userProfile);
        setFormData({
          name: userProfile.name,
          email: userProfile.email,
          birth_date: userProfile.birth_date || '',
          birth_time: userProfile.birth_time || '',
          mbti: userProfile.mbti || '',
        });
      } else {
        // 프로필 정보가 없거나 온보딩이 미완료된 경우, 온보딩 페이지로 리다이렉트
        router.push('/onboarding/profile');
      }

    } catch (error: any) {
      console.error('사용자 프로필 로드 실패 (상세):', error);
      // 사용자에게 에러 알림
      alert(`프로필 정보를 불러오는 중 오류가 발생했습니다: ${error.message || '알 수 없는 오류'}`);
      router.push('/home'); // 에러 발생 시 홈으로 이동
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    if (!user) return;

    setIsSaving(true);
    try {
      // 1. user_profiles 테이블에 직접 업데이트
      const { error } = await supabase
        .from('user_profiles')
        .update({
          name: formData.name,
          birth_date: formData.birth_date,
          birth_time: formData.birth_time,
          mbti: formData.mbti.toUpperCase(),
        })
        .eq('id', user.id);

      if (error) throw error;
      
      // 2. auth.user 메타데이터도 함께 업데이트 (선택적이지만 일관성을 위해)
      const { error: authError } = await supabase.auth.updateUser({
        data: {
          full_name: formData.name,
          birth_date: formData.birth_date,
          birth_time: formData.birth_time,
          mbti: formData.mbti.toUpperCase(),
        }
      });
      
      if (authError) throw authError;

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
                <Label htmlFor="birth_date">생년월일</Label>
                <div className="relative">
                  <Calendar className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="birth_date"
                    type="date"
                    value={formData.birth_date}
                    onChange={(e) => setFormData(prev => ({ ...prev, birth_date: e.target.value }))}
                    className="pl-10"
                    placeholder="YYYY-MM-DD"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="birth_time">태어난 시</Label>
                <div className="relative">
                  <Clock className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                   <select 
                    id="birth_time"
                    value={formData.birth_time} 
                    onChange={(e) => setFormData(prev => ({ ...prev, birth_time: e.target.value }))}
                    className="w-full p-2 pl-10 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 dark:focus:ring-purple-400 focus:border-purple-500 dark:focus:border-purple-400 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                  >
                    <option value="">태어난 시 선택</option>
                    <option value="모름">모름</option>
                    <option value="자시 (23:30~01:29)">자시 (23:30~01:29)</option>
                    <option value="축시 (01:30~03:29)">축시 (01:30~03:29)</option>
                    <option value="인시 (03:30~05:29)">인시 (03:30~05:29)</option>
                    <option value="묘시 (05:30~07:29)">묘시 (05:30~07:29)</option>
                    <option value="진시 (07:30~09:29)">진시 (07:30~09:29)</option>
                    <option value="사시 (09:30~11:29)">사시 (09:30~11:29)</option>
                    <option value="오시 (11:30~13:29)">오시 (11:30~13:29)</option>
                    <option value="미시 (13:30~15:29)">미시 (13:30~15:29)</option>
                    <option value="신시 (15:30~17:29)">신시 (15:30~17:29)</option>
                    <option value="유시 (17:30~19:29)">유시 (17:30~19:29)</option>
                    <option value="술시 (19:30~21:29)">술시 (19:30~21:29)</option>
                    <option value="해시 (21:30~23:29)">해시 (21:30~23:29)</option>
                  </select>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="mbti">MBTI</Label>
                 <div className="relative">
                  <Brain className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="mbti"
                    value={formData.mbti}
                    onChange={(e) => setFormData(prev => ({ ...prev, mbti: e.target.value.toUpperCase() }))}
                    className="pl-10"
                    placeholder="MBTI를 입력하세요 (예: INFP)"
                  />
                </div>
              </div>

            </CardContent>
          </Card>
        </motion.div>

        {/* 자동 계산 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-purple-500" />
                자동 분석 정보
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex justify-between items-center p-3 bg-gray-50 dark:bg-gray-800 rounded-md">
                <Label>띠</Label>
                <span className="font-semibold">{getChineseZodiac(formData.birth_date) || '생년월일 입력 필요'}</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 dark:bg-gray-800 rounded-md">
                <Label>별자리</Label>
                <span className="font-semibold">{getZodiacSign(formData.birth_date) || '생년월일 입력 필요'}</span>
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