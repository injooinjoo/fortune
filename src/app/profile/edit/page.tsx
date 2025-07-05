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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import {
  User,
  Mail,
  Calendar,
  Camera,
  Save,
  ArrowLeft,
  Smartphone,
  MapPin,
  Heart,
  Droplets,
  Clock,
  Briefcase,
  Star,
  CheckCircle2
} from "lucide-react";
import { supabase } from "@/lib/supabase";
import { getUserInfo, saveUserInfo, UserInfo } from "@/lib/user-storage";
import { 
  checkOverallProfileCompleteness, 
  getCompletionStatusMessage,
  FIELD_LABELS 
} from "@/lib/profile-completeness";

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
  const [userInfo, setUserInfo] = useState<UserInfo>({
    name: '',
    birthDate: '',
    birthTime: '',
    gender: '',
    mbti: '',
    bloodType: '',
    zodiacSign: '',
    job: '',
    location: ''
  });
  const [profileCompleteness, setProfileCompleteness] = useState({
    percentage: 0,
    message: ''
  });

  useEffect(() => {
    loadUserProfile();
  }, []);

  // 프로필 완성도 계산
  useEffect(() => {
    const completeness = checkOverallProfileCompleteness(userInfo);
    setProfileCompleteness({
      percentage: completeness.completionPercentage,
      message: getCompletionStatusMessage(completeness.completionPercentage)
    });
  }, [userInfo]);

  const loadUserProfile = async () => {
    try {
      // 로컬 스토리지에서 운세 관련 정보 로드
      const storedUserInfo = getUserInfo();
      setUserInfo(storedUserInfo);

      // Supabase에서 계정 정보 로드
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
        
        // 저장된 정보와 계정 정보 병합
        const mergedInfo: UserInfo = {
          ...storedUserInfo,
          name: storedUserInfo.name || userProfile.name,
          birthDate: storedUserInfo.birthDate || userProfile.birth_date || '',
          location: storedUserInfo.location || userProfile.location || ''
        };
        setUserInfo(mergedInfo);
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
      // 로컬 스토리지에 운세 관련 정보 저장
      saveUserInfo(userInfo);

      // Supabase에 기본 계정 정보 업데이트
      const { error } = await supabase.auth.updateUser({
        data: {
          full_name: userInfo.name,
          location: userInfo.location,
          birth_date: userInfo.birthDate
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

  const updateUserInfo = (field: keyof UserInfo, value: string) => {
    setUserInfo(prev => ({ ...prev, [field]: value }));
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
      <AppHeader title="프로필 관리" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 프로필 완성도 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white border-0">
            <CardContent className="p-6">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="font-semibold text-lg">프로필 완성도</h3>
                  <Badge 
                    variant="secondary" 
                    className="bg-white/20 text-white border-white/30"
                  >
                    {profileCompleteness.percentage}%
                  </Badge>
                </div>
                <Progress 
                  value={profileCompleteness.percentage} 
                  className="h-3 bg-white/20"
                />
                <p className="text-white/90 text-sm">{profileCompleteness.message}</p>
                {profileCompleteness.percentage === 100 && (
                  <div className="flex items-center gap-2 text-green-100">
                    <CheckCircle2 className="w-4 h-4" />
                    <span className="text-sm">모든 정보가 완성되었습니다!</span>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 아바타 섹션 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center space-x-4">
                <div className="relative">
                  <Avatar className="w-16 h-16">
                    <AvatarImage src={user?.avatar_url} alt={userInfo.name} />
                    <AvatarFallback className="text-xl bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400">
                      {userInfo.name.charAt(0).toUpperCase() || 'U'}
                    </AvatarFallback>
                  </Avatar>
                  <Button
                    size="sm"
                    onClick={handleAvatarUpload}
                    className="absolute -bottom-1 -right-1 rounded-full w-6 h-6 p-0 bg-purple-600 hover:bg-purple-700"
                  >
                    <Camera className="w-3 h-3" />
                  </Button>
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold text-lg">{userInfo.name || '이름을 입력해주세요'}</h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400">{user?.email}</p>
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
                <Label htmlFor="name">이름 *</Label>
                <Input
                  id="name"
                  value={userInfo.name}
                  onChange={(e) => updateUserInfo('name', e.target.value)}
                  placeholder="이름을 입력하세요"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="birth_date">생년월일 *</Label>
                <div className="relative">
                  <Calendar className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="birth_date"
                    type="date"
                    value={userInfo.birthDate}
                    onChange={(e) => updateUserInfo('birthDate', e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="birth_time">출생시간</Label>
                <div className="relative">
                  <Clock className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Select value={userInfo.birthTime} onValueChange={(value) => updateUserInfo('birthTime', value)}>
                    <SelectTrigger className="pl-10">
                      <SelectValue placeholder="출생시간을 선택하세요" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="자시">자시 (23:30-01:30)</SelectItem>
                      <SelectItem value="축시">축시 (01:30-03:30)</SelectItem>
                      <SelectItem value="인시">인시 (03:30-05:30)</SelectItem>
                      <SelectItem value="묘시">묘시 (05:30-07:30)</SelectItem>
                      <SelectItem value="진시">진시 (07:30-09:30)</SelectItem>
                      <SelectItem value="사시">사시 (09:30-11:30)</SelectItem>
                      <SelectItem value="오시">오시 (11:30-13:30)</SelectItem>
                      <SelectItem value="미시">미시 (13:30-15:30)</SelectItem>
                      <SelectItem value="신시">신시 (15:30-17:30)</SelectItem>
                      <SelectItem value="유시">유시 (17:30-19:30)</SelectItem>
                      <SelectItem value="술시">술시 (19:30-21:30)</SelectItem>
                      <SelectItem value="해시">해시 (21:30-23:30)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <p className="text-xs text-gray-500">사주 운세에 필요합니다</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="gender">성별</Label>
                <div className="relative">
                  <Heart className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Select value={userInfo.gender} onValueChange={(value) => updateUserInfo('gender', value)}>
                    <SelectTrigger className="pl-10">
                      <SelectValue placeholder="성별을 선택하세요" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="남성">남성</SelectItem>
                      <SelectItem value="여성">여성</SelectItem>
                      <SelectItem value="선택 안함">선택 안함</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 성격 및 특성 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Star className="w-5 h-5" />
                성격 및 특성
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="mbti">MBTI</Label>
                <Select value={userInfo.mbti} onValueChange={(value) => updateUserInfo('mbti', value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="MBTI를 선택하세요" />
                  </SelectTrigger>
                  <SelectContent>
                    {['ENFP', 'ENFJ', 'ENTP', 'ENTJ', 'ESFP', 'ESFJ', 'ESTP', 'ESTJ',
                      'INFP', 'INFJ', 'INTP', 'INTJ', 'ISFP', 'ISFJ', 'ISTP', 'ISTJ'].map(type => (
                      <SelectItem key={type} value={type}>{type}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <p className="text-xs text-gray-500">성격 분석 운세에 활용됩니다</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="blood_type">혈액형</Label>
                <div className="relative">
                  <Droplets className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Select value={userInfo.bloodType} onValueChange={(value) => updateUserInfo('bloodType', value)}>
                    <SelectTrigger className="pl-10">
                      <SelectValue placeholder="혈액형을 선택하세요" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="A형">A형</SelectItem>
                      <SelectItem value="B형">B형</SelectItem>
                      <SelectItem value="AB형">AB형</SelectItem>
                      <SelectItem value="O형">O형</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 직업 및 생활 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Briefcase className="w-5 h-5" />
                직업 및 생활
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="job">직업</Label>
                <div className="relative">
                  <Briefcase className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="job"
                    value={userInfo.job}
                    onChange={(e) => updateUserInfo('job', e.target.value)}
                    className="pl-10"
                    placeholder="직업을 입력하세요"
                  />
                </div>
                <p className="text-xs text-gray-500">직업운세에 활용됩니다</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="location">거주지</Label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                  <Input
                    id="location"
                    value={userInfo.location}
                    onChange={(e) => updateUserInfo('location', e.target.value)}
                    className="pl-10"
                    placeholder="거주지를 입력하세요"
                  />
                </div>
                <p className="text-xs text-gray-500">지역 기반 운세에 활용됩니다</p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 저장 버튼 */}
        <motion.div variants={itemVariants} className="pt-4 space-y-3">
          <Button
            onClick={handleSave}
            disabled={isSaving || !userInfo.name || !userInfo.birthDate}
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
                프로필 저장
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
          
          {(!userInfo.name || !userInfo.birthDate) && (
            <div className="text-center">
              <p className="text-sm text-red-500">* 이름과 생년월일은 필수 입력 사항입니다</p>
            </div>
          )}
        </motion.div>
      </motion.div>
    </div>
  );
} 