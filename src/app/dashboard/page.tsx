"use client";

import React, { useState } from "react";
import UserProfile from "@/components/dashboard/UserProfile";
import SajuFortuneForm from "@/components/dashboard/SajuFortuneForm";
import MbtiFortuneForm from "@/components/dashboard/MbtiFortuneForm";
import FortuneResult from "@/components/dashboard/FortuneResult";

export default function DashboardPage() {
  const [fortuneResult, setFortuneResult] = useState("");

  const userName = "사용자";
  const userEmail = "user@example.com";

  const handleSajuSubmit = async (birthDate: string) => {
    // TODO: Replace with real API call
    setFortuneResult(`사주 결과 (${birthDate})`);
  };

  const handleMbtiSubmit = async (myMbti: string, partnerMbti: string) => {
    // TODO: Replace with real API call
    setFortuneResult(`MBTI 궁합 결과 (${myMbti} + ${partnerMbti})`);
  };

  return (
    <div className="space-y-6 p-4">
      <UserProfile name={userName} email={userEmail} />
      <SajuFortuneForm onSubmit={handleSajuSubmit} />
      <MbtiFortuneForm onSubmit={handleMbtiSubmit} />
      <FortuneResult result={fortuneResult} />
    </div>
  );
}
