"use client";
import React, { useState } from "react";

interface MbtiFortuneFormProps {
  onSubmit: (myMbti: string, partnerMbti: string) => void;
}

export default function MbtiFortuneForm({ onSubmit }: MbtiFortuneFormProps) {
  const [myMbti, setMyMbti] = useState("");
  const [partnerMbti, setPartnerMbti] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!myMbti || !partnerMbti) return;
    onSubmit(myMbti, partnerMbti);
  };

  return (
    <section>
      <h3 className="text-lg font-semibold mb-2">MBTI 궁합 보기</h3>
      <form onSubmit={handleSubmit} className="flex flex-col gap-2">
        <input
          type="text"
          placeholder="Your MBTI"
          value={myMbti}
          onChange={(e) => setMyMbti(e.target.value)}
          className="border rounded px-2 py-1"
        />
        <input
          type="text"
          placeholder="Partner's MBTI"
          value={partnerMbti}
          onChange={(e) => setPartnerMbti(e.target.value)}
          className="border rounded px-2 py-1"
        />
        <button type="submit" className="px-3 py-1 bg-primary text-white rounded">
          궁합 보기
        </button>
      </form>
    </section>
  );
}
