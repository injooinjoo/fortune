"use client";

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
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
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
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
  MapPin,
  Briefcase,
  Heart,
  Users,
} from "lucide-react";
import { getZodiacSign, getChineseZodiac, getUserProfile, saveUserProfile, updateUserProfile, syncUserProfile, isGuestUser } from "@/lib/user-storage";
import { type UserProfile as StoredUserProfile } from "@/lib/supabase";

interface UserProfile {
  id: string;
  email: string;
  name: string;
  avatar_url?: string;
  provider: string;
  birth_date?: string;
  birth_time?: string;
  mbti?: string;
  gender?: 'male' | 'female' | 'other';
  blood_type?: 'A' | 'B' | 'AB' | 'O';
  job?: string;
  location?: string;
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
  const { toast } = useToast();
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
    gender: '' as 'male' | 'female' | 'other' | '',
    blood_type: '' as 'A' | 'B' | 'AB' | 'O' | '',
    job: '',
    location: '',
  });

  useEffect(() => {
    loadUserProfile();
  }, []);

  const loadUserProfile = async () => {
    try {
      // syncUserProfile을 사용하여 자동 동기화
      const profile = await syncUserProfile();
      
      // 프로필이 없거나 온보딩이 완료되지 않았으면 온보딩으로
      if (!profile || !profile.onboarding_completed) {
        router.push('/onboarding');
        return;
      }

      const userProfile: UserProfile = {
        id: profile.id,
        email: profile.email || '',
        name: profile.name,
        avatar_url: profile.avatar_url,
        provider: isGuestUser(profile) ? 'local' : 'supabase',
        birth_date: profile.birth_date || '',
        birth_time: profile.birth_time || '',
        mbti: profile.mbti || '',
        gender: profile.gender,
        blood_type: profile.blood_type,
        job: profile.job || '',
        location: profile.location || '',
      };
      
      setUser(userProfile);
      setFormData({
        name: userProfile.name,
        email: userProfile.email,
        birth_date: userProfile.birth_date || '',
        birth_time: userProfile.birth_time || '',
        mbti: userProfile.mbti || '',
        gender: userProfile.gender || '',
        blood_type: userProfile.blood_type || '',
        job: userProfile.job || '',
        location: userProfile.location || '',
      });

    } catch (error: any) {
      logger.error('사용자 프로필 로드 실패:', error);
      router.push('/onboarding');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    if (!user) return;

    setIsSaving(true);
    try {
      const updates = {
        name: formData.name,
        birth_date: formData.birth_date,
        birth_time: formData.birth_time,
        mbti: formData.mbti.toUpperCase(),
        gender: formData.gender || undefined,
        blood_type: formData.blood_type || undefined,
        job: formData.job,
        location: formData.location,
        zodiac_sign: getZodiacSign(formData.birth_date),
        chinese_zodiac: getChineseZodiac(formData.birth_date),
      };
      
      // 1. 로컬 스토리지 업데이트
      const updatedProfile = updateUserProfile(updates);
      
      // 2. 인증된 사용자이면 Supabase에도 저장
      if (user.provider === 'supabase' && updatedProfile) {
        try {
          const { auth, userProfileService } = await import('@/lib/supabase');
          const { data } = await auth.getSession();
          if (data?.session?.user) {
            await userProfileService.upsertProfile({
              id: data.session.user.id,
              email: data.session.user.email || '',
              ...updates
            });
            logger.debug('🔄 Supabase에 프로필 동기화 완료');
          }
        } catch (supabaseError) {
          logger.error('🔄 Supabase 동기화 실패:', supabaseError);
          // Supabase 저장 실패에도 로컬 데이터는 유지
        }
      }
      
      if (updatedProfile) {
        router.back();
      } else {
        throw new Error('프로필 업데이트에 실패했습니다.');
      }
    } catch (error) {
      logger.error('프로필 저장 실패:', error);
      toast({
      title: '프로필 저장 중 오류가 발생했습니다. 다시 시도해주세요.',
      variant: "destructive",
    });
    } finally {
      setIsSaving(false);
    }
  };

  const handleAvatarUpload = () => {
    // 실제로는 이미지 업로드 처리
    toast({
      title: '아바타 업로드 기능은 준비 중입니다.',
      variant: "default",
    });
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
                <KoreanDatePicker
                  value={formData.birth_date}
                  onChange={(date) => setFormData(prev => ({ ...prev, birth_date: date }))}
                  label="생년월일"
                  placeholder="생년월일을 선택하세요"
                  required={false}
                />
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

              <div className="space-y-2">
                <Label htmlFor="gender">성별</Label>
                <div className="relative">
                  <Users className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <select 
                    id="gender"
                    value={formData.gender} 
                    onChange={(e) => setFormData(prev => ({ ...prev, gender: e.target.value as any }))}
                    className="w-full p-2 pl-10 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 dark:focus:ring-purple-400 focus:border-purple-500 dark:focus:border-purple-400 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                  >
                    <option value="">성별 선택</option>
                    <option value="male">남성</option>
                    <option value="female">여성</option>
                    <option value="other">기타</option>
                  </select>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="blood_type">혈액형</Label>
                <div className="relative">
                  <Heart className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <select 
                    id="blood_type"
                    value={formData.blood_type} 
                    onChange={(e) => setFormData(prev => ({ ...prev, blood_type: e.target.value as any }))}
                    className="w-full p-2 pl-10 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 dark:focus:ring-purple-400 focus:border-purple-500 dark:focus:border-purple-400 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
                  >
                    <option value="">혈액형 선택</option>
                    <option value="A">A형</option>
                    <option value="B">B형</option>
                    <option value="AB">AB형</option>
                    <option value="O">O형</option>
                  </select>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="job">직업</Label>
                <div className="relative">
                  <Briefcase className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="job"
                    value={formData.job}
                    onChange={(e) => setFormData(prev => ({ ...prev, job: e.target.value }))}
                    className="pl-10"
                    placeholder="직업을 입력하세요 (예: 개발자, 학생)"
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
                    placeholder="거주지를 입력하세요 (예: 서울, 부산)"
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