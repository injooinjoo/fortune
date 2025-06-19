"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  Form,
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";
import { MBTI_TYPES } from "@/lib/fortune-data";

const formSchema = z.object({
  name: z.string().min(1, "이름을 입력해주세요."),
  birthdate: z.string().min(1, "생년월일을 입력해주세요."),
  birthTime: z.string().optional(),
  mbti: z.string().optional(),
  gender: z.string().optional(),
});

type FormValues = z.infer<typeof formSchema>;

export default function OnboardingPage() {
  const [step, setStep] = useState(1);
  const router = useRouter();
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    mode: "onBlur",
    defaultValues: {
      name: "",
      birthdate: "",
      birthTime: "",
      mbti: "",
      gender: "",
    },
  });

  const handleNext = async () => {
    const valid = await form.trigger(["name", "birthdate", "birthTime"]);
    if (valid) {
      console.log(form.getValues());
      setStep(2);
    }
  };

  const onSubmit = (data: FormValues) => {
    console.log(data);
    router.push("/home");
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-4">
      <div className="w-full max-w-md space-y-6">
        <Progress value={step === 1 ? 50 : 100} />
        <div className="text-right text-sm text-muted-foreground">
          {step} / 2
        </div>
        <Form {...form}>
          {step === 1 && (
            <form className="space-y-4" onSubmit={(e) => { e.preventDefault(); handleNext(); }}>
              <FormField
                control={form.control}
                name="name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>이름</FormLabel>
                    <FormControl>
                      <Input placeholder="홍길동" {...field} />
                    </FormControl>
                    <p className="text-xs text-muted-foreground">정확한 사주 분석을 위해 필요해요.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="birthdate"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>생년월일</FormLabel>
                    <FormControl>
                      <Input type="date" {...field} />
                    </FormControl>
                    <p className="text-xs text-muted-foreground">정확한 사주 분석을 위해 필요해요.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="birthTime"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>출생 시간 (선택)</FormLabel>
                    <FormControl>
                      <Input type="time" {...field} />
                    </FormControl>
                    <p className="text-xs text-muted-foreground">정확한 사주 분석을 위해 필요해요.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <Button type="submit" className="w-full">다음</Button>
            </form>
          )}
          {step === 2 && (
            <form className="space-y-4" onSubmit={form.handleSubmit(onSubmit)}>
              <FormField
                control={form.control}
                name="mbti"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>MBTI (선택)</FormLabel>
                    <Select value={field.value} onValueChange={field.onChange}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="선택" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {MBTI_TYPES.map((type) => (
                          <SelectItem key={type} value={type}>{type}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <p className="text-xs text-muted-foreground">더 정확한 맞춤 운세를 경험해보세요.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="gender"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>성별 (선택)</FormLabel>
                    <FormControl>
                      <RadioGroup onValueChange={field.onChange} value={field.value} className="flex gap-4">
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="남성" id="gender-m" />
                          <Label htmlFor="gender-m">남성</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="여성" id="gender-f" />
                          <Label htmlFor="gender-f">여성</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="선택안함" id="gender-n" />
                          <Label htmlFor="gender-n">선택안함</Label>
                        </div>
                      </RadioGroup>
                    </FormControl>
                    <p className="text-xs text-muted-foreground">더 정확한 맞춤 운세를 경험해보세요.</p>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <div className="space-y-2">
                <Button type="submit" className="w-full">완료</Button>
                <Button type="button" variant="outline" className="w-full" onClick={() => router.push("/home")}>나중에 설정할래요</Button>
              </div>
            </form>
          )}
        </Form>
      </div>
    </div>
  );
}

