"use client";

import React, { useState } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Calendar, Clock, User, Save } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import AppHeader from "@/components/AppHeader";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";

interface UserProfileForm {
  name: string;
  birth_date: string;
  birth_time?: string;
  gender: '남성' | '여성' | '';
  mbti?: string;
}

// 십간십이지 시간
const BIRTH_TIMES = [
  { value: '자시', label: '자시 (23:00-01:00)', description: '쥐띠 시간' },
  { value: '축시', label: '축시 (01:00-03:00)', description: '소띠 시간' },
  { value: '인시', label: '인시 (03:00-05:00)', description: '호랑이띠 시간' },
  { value: '묘시', label: '묘시 (05:00-07:00)', description: '토끼띠 시간' },
  { value: '진시', label: '진시 (07:00-09:00)', description: '용띠 시간' },
  { value: '사시', label: '사시 (09:00-11:00)', description: '뱀띠 시간' },
  { value: '오시', label: '오시 (11:00-13:00)', description: '말띠 시간' },
  { value: '미시', label: '미시 (13:00-15:00)', description: '양띠 시간' },
  { value: '신시', label: '신시 (15:00-17:00)', description: '원숭이띠 시간' },
  { value: '유시', label: '유시 (17:00-19:00)', description: '닭띠 시간' },
  { value: '술시', label: '술시 (19:00-21:00)', description: '개띠 시간' },
  { value: '해시', label: '해시 (21:00-23:00)', description: '돼지띠 시간' },
];

// MBTI 유형
const MBTI_TYPES = [
  'ENFP', 'ENFJ', 'ENTP', 'ENTJ',
  'ESFP', 'ESFJ', 'ESTP', 'ESTJ',
  'INFP', 'INFJ', 'INTP', 'INTJ',
  'ISFP', 'ISFJ', 'ISTP', 'ISTJ'
];

export default function ProfileOnboardingPage() {
  const [formData, setFormData] = useState<UserProfileForm>({
    name: '',
    birth_date: '',
    birth_time: undefined,
    gender: '',
    mbti: undefined
  });
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  // 폼 데이터 업데이트
  const updateFormData = (field: keyof UserProfileForm, value: string | undefined) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  // 날짜 관련 함수들은 KoreanDatePicker가 내부적으로 처리

  // 프로필 저장
  const saveProfile = async () => {
    try {
      // 필수 필드 검증
      if (!formData.name.trim()) {
        toast({
          title: "이름을 입력해주세요",
          variant: "destructive"
        });
        return;
      }

      if (!formData.birth_date) {
        toast({
          title: "생년월일을 입력해주세요",
          variant: "destructive"
        });
        return;
      }

      if (!formData.gender) {
        toast({
          title: "성별을 선택해주세요",
          variant: "destructive"
        });
        return;
      }

      setLoading(true);

      // Supabase 직접 호출하여 프로필 저장
      const { auth, userProfileService } = await import('@/lib/supabase');
      const { data: sessionData } = await auth.getSession();
      
      if (!sessionData?.session?.user) {
        toast({
          title: "로그인이 필요합니다",
          description: "프로필 저장을 위해 로그인해주세요.",
          variant: "destructive"
        });
        return;
      }

      const user = sessionData.session.user;
      
      // 프로필 데이터 구성
      const profileData = {
        id: user.id,
        email: user.email,
        name: formData.name.trim(),
        birth_date: formData.birth_date,
        birth_time: formData.birth_time,
        gender: formData.gender === '남성' ? 'male' : formData.gender === '여성' ? 'female' : undefined,
        mbti: formData.mbti,
        onboarding_completed: true,
        avatar_url: user.user_metadata?.avatar_url,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      const result = await userProfileService.upsertProfile(profileData);
      
      if (!result) {
        throw new Error('프로필 저장에 실패했습니다.');
      }

      // 프로필 저장 성공
      toast({
        title: "프로필 저장 완료",
        description: "이제 운세를 확인할 수 있습니다!"
      });
      
      // 사주 페이지로 이동
      window.location.href = '/fortune/saju';

    } catch (error) {
      toast({
        title: "저장 실패",
        description: error instanceof Error ? error.message : '알 수 없는 오류',
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <AppHeader title="프로필 설정" />
      <div className="pb-32 px-4 space-y-6 pt-4">
        {/* 안내 메시지 */}
        <div className="text-center space-y-2 mb-6">
          <h2 className="text-xl font-bold">운세 분석을 위한 정보 입력</h2>
          <p className="text-sm text-muted-foreground">
            정확한 운세 분석을 위해 아래 정보를 입력해주세요
          </p>
        </div>

        {/* 기본 정보 */}
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
                placeholder="이름을 입력하세요"
                value={formData.name}
                onChange={(e) => updateFormData('name', e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <KoreanDatePicker
                value={formData.birth_date}
                onChange={(date) => updateFormData('birth_date', date)}
                label="생년월일 (양력)"
                placeholder="생년월일을 선택하세요"
                required={true}
              />
            </div>

            <div className="space-y-2">
              <Label>태어난 시간 (선택사항)</Label>
              <p className="text-sm text-muted-foreground">
                더 정확한 사주 분석을 위해 태어난 시간을 알고 계시면 선택해주세요
              </p>
              <Select
                value={formData.birth_time || 'unknown'}
                onValueChange={(value) => updateFormData('birth_time', value === 'unknown' ? '' : value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="태어난 시간을 모르겠어요" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="unknown">태어난 시간을 모르겠어요</SelectItem>
                  {BIRTH_TIMES.map((time) => (
                    <SelectItem key={time.value} value={time.value}>
                      <div className="flex flex-col">
                        <span>{time.label}</span>
                        <span className="text-xs text-muted-foreground">{time.description}</span>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>성별 *</Label>
              <div className="flex gap-2">
                {['남성', '여성'].map((gender) => (
                  <Button
                    key={gender}
                    variant={formData.gender === gender ? "default" : "outline"}
                    size="sm"
                    onClick={() => updateFormData('gender', gender as any)}
                    className={!formData.gender ? "border-red-300" : ""}
                  >
                    {gender}
                  </Button>
                ))}
              </div>
              {!formData.gender && (
                <p className="text-sm text-red-500">성별을 선택해주세요</p>
              )}
            </div>
          </CardContent>
        </Card>



        {/* MBTI */}
        <Card>
          <CardHeader>
            <CardTitle>MBTI (선택사항)</CardTitle>
            <p className="text-sm text-muted-foreground">
              MBTI를 알고 계시면 더 개인화된 운세를 제공할 수 있습니다
            </p>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-4 gap-2">
              {MBTI_TYPES.map((mbti) => (
                <Button
                  key={mbti}
                  variant={formData.mbti === mbti ? "default" : "outline"}
                  size="sm"
                  onClick={() => updateFormData('mbti', mbti)}
                >
                  {mbti}
                </Button>
              ))}
            </div>
            {formData.mbti && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => updateFormData('mbti', undefined)}
                className="mt-2"
              >
                MBTI 선택 해제
              </Button>
            )}
          </CardContent>
        </Card>



        {/* 저장 버튼 */}
        <div className="sticky bottom-20 left-0 right-0 bg-background p-4">
          <Button 
            onClick={saveProfile} 
            disabled={loading || !formData.name.trim() || !formData.birth_date || !formData.gender}
            className="w-full"
            size="lg"
          >
            {loading ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2" />
                저장 중...
              </>
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                프로필 저장하고 운세 보기
              </>
            )}
          </Button>
        </div>
      </div>
    </>
  );
} 