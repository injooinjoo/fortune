"use client";
import React, { useState } from "react";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";

interface SajuFortuneFormProps {
  onSubmit: (birthDate: string) => void;
}

export default function SajuFortuneForm({ onSubmit }: SajuFortuneFormProps) {
  const [birthDate, setBirthDate] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!birthDate) return;
    onSubmit(birthDate);
  };

  return (
    <section>
      <h3 className="text-lg font-semibold mb-2">사주 운세 보기</h3>
      <form onSubmit={handleSubmit} className="space-y-4">
        <KoreanDatePicker
          value={birthDate}
          onChange={(date) => setBirthDate(date)}
          placeholder="생년월일을 선택하세요"
          required={true}
        />
        <button type="submit" className="px-3 py-1 bg-primary text-white rounded">
          결과 보기
        </button>
      </form>
    </section>
  );
}
