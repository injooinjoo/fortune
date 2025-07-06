"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectTrigger, SelectContent, SelectItem, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { getUserInfo, saveUserInfo, getZodiacSign, calculateAge } from "@/lib/user-storage";
import { User, Calendar, Briefcase, ArrowRight, Info } from "lucide-react";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";

export interface UserFormData {
  name: string;
  birthDate: string;
  birthTime?: string;
  gender?: string;
  mbti?: string;
  bloodType?: string;
  job?: string;
  location?: string;
  [key: string]: any;
}

interface UserInfoFormProps {
  title?: string;
  description?: string;
  fields?: Array<{
    key: keyof UserFormData;
    label: string;
    type: 'text' | 'date' | 'time' | 'select';
    required?: boolean;
    options?: string[];
    placeholder?: string;
  }>;
  extraFields?: React.ReactNode;
  onSubmit: (data: UserFormData) => void;
  loading?: boolean;
  submitText?: string;
  showSavedDataBadge?: boolean;
}

const defaultFields = [
  { key: 'name' as const, label: '이름', type: 'text' as const, required: true, placeholder: '이름을 입력하세요' },
  { key: 'birthDate' as const, label: '생년월일', type: 'date' as const, required: true },
];

const genderOptions = ['남성', '여성'];
const bloodTypeOptions = ['A', 'B', 'AB', 'O'];
const mbtiOptions = [
  'INTJ', 'INTP', 'ENTJ', 'ENTP',
  'INFJ', 'INFP', 'ENFJ', 'ENFP',
  'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
  'ISTP', 'ISFP', 'ESTP', 'ESFP'
];

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 10,
    },
  },
};

export default function UserInfoForm({
  title = "기본 정보",
  description = "정확한 운세를 위해 기본 정보를 입력해주세요",
  fields = defaultFields,
  extraFields,
  onSubmit,
  loading = false,
  submitText = "운세 보기",
  showSavedDataBadge = true,
}: UserInfoFormProps) {
  const [formData, setFormData] = useState<UserFormData>({
    name: '',
    birthDate: '',
    birthTime: '',
    gender: '',
    mbti: '',
    bloodType: '',
    job: '',
    location: '',
  });
  const [hasSavedData, setHasSavedData] = useState(false);

  // 컴포넌트 마운트 시 저장된 사용자 정보 불러오기
  useEffect(() => {
    const savedUserInfo = getUserInfo();
    if (savedUserInfo.name || savedUserInfo.birthDate) {
      setFormData(prev => ({
        ...prev,
        ...savedUserInfo,
      }));
      setHasSavedData(true);
    }
  }, []);

  const handleInputChange = (key: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      [key]: value,
    }));
  };

  const handleSubmit = () => {
    // 필수 필드 검증
    const requiredFields = fields.filter(field => field.required);
    const missingFields = requiredFields.filter(field => !formData[field.key]);
    
    if (missingFields.length > 0) {
      alert(`다음 정보를 입력해주세요: ${missingFields.map(f => f.label).join(', ')}`);
      return;
    }

    // 사용자 정보 저장
    const dataToSave: any = {};
    fields.forEach(field => {
      if (formData[field.key]) {
        dataToSave[field.key] = formData[field.key];
      }
    });
    
    saveUserInfo(dataToSave);
    onSubmit(formData);
  };

  const getFieldOptions = (key: string) => {
    switch (key) {
      case 'gender': return genderOptions;
      case 'bloodType': return bloodTypeOptions;
      case 'mbti': return mbtiOptions;
      default: return [];
    }
  };

  const renderField = (field: typeof fields[0]) => {
    const value = formData[field.key] || '';
    
    if (field.type === 'select') {
      const options = field.options || getFieldOptions(String(field.key));
      return (
        <Select
          value={String(value)}
          onValueChange={(value) => handleInputChange(String(field.key), value)}
        >
          <SelectTrigger>
            <SelectValue placeholder={field.placeholder || `${field.label}을 선택하세요`} />
          </SelectTrigger>
          <SelectContent>
            {options.map((option) => (
              <SelectItem key={option} value={option}>
                {option}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      );
    }

    if (field.type === 'date') {
      return (
        <KoreanDatePicker
          value={String(value)}
          onChange={(date) => handleInputChange(String(field.key), date)}
          placeholder={field.placeholder || `${field.label}을 선택하세요`}
          required={field.required}
        />
      );
    }

    return (
      <Input
        type={field.type}
        placeholder={field.placeholder}
        value={String(value)}
        onChange={(e) => handleInputChange(String(field.key), e.target.value)}
      />
    );
  };

  // 추가 정보 표시
  const zodiacSign = formData.birthDate ? getZodiacSign(formData.birthDate) : '';
  const age = formData.birthDate ? calculateAge(formData.birthDate) : 0;

  return (
    <motion.div variants={itemVariants} className="space-y-6">
      {showSavedDataBadge && hasSavedData && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex items-center justify-center gap-2 mb-4"
        >
          <Badge variant="secondary" className="bg-green-100 text-green-700">
            <Info className="w-3 h-3 mr-1" />
            이전 입력 정보를 불러왔습니다
          </Badge>
        </motion.div>
      )}

      <Card className="border-blue-200">
        <CardHeader className="pb-4">
          <CardTitle className="flex items-center gap-2 text-blue-700">
            <User className="w-5 h-5" />
            {title}
          </CardTitle>
          <p className="text-sm text-gray-600">{description}</p>
        </CardHeader>
        <CardContent className="space-y-4">
          {fields.map((field) => (
            <div key={String(field.key)}>
              <Label htmlFor={String(field.key)}>
                {field.label}
                {field.required && <span className="text-red-500 ml-1">*</span>}
              </Label>
              {renderField(field)}
            </div>
          ))}

          {extraFields && (
            <div className="pt-2 border-t border-gray-200">
              {extraFields}
            </div>
          )}

          {/* 자동 계산된 정보 표시 */}
          {(zodiacSign || age > 0) && (
            <div className="pt-2 border-t border-gray-200">
              <div className="flex flex-wrap gap-2">
                {age > 0 && (
                  <Badge variant="outline" className="text-blue-600">
                    <Calendar className="w-3 h-3 mr-1" />
                    {age}세
                  </Badge>
                )}
                {zodiacSign && (
                  <Badge variant="outline" className="text-purple-600">
                    ⭐ {zodiacSign}
                  </Badge>
                )}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <Button
        onClick={handleSubmit}
        disabled={loading}
        className="w-full bg-gradient-to-r from-blue-500 to-indigo-500 hover:from-blue-600 hover:to-indigo-600 text-white py-3 text-lg"
      >
        {loading ? (
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
            분석 중...
          </div>
        ) : (
          <div className="flex items-center gap-2">
            {submitText}
            <ArrowRight className="w-5 h-5" />
          </div>
        )}
      </Button>
    </motion.div>
  );
} 