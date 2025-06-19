"use client";
import React, { useState } from "react";

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
      <form onSubmit={handleSubmit} className="flex items-center gap-2">
        <input
          type="date"
          value={birthDate}
          onChange={(e) => setBirthDate(e.target.value)}
          className="border rounded px-2 py-1"
        />
        <button type="submit" className="px-3 py-1 bg-primary text-white rounded">
          결과 보기
        </button>
      </form>
    </section>
  );
}
