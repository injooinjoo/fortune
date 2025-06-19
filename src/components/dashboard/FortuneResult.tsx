"use client";
import React from "react";

interface FortuneResultProps {
  result: string;
}

export default function FortuneResult({ result }: FortuneResultProps) {
  if (!result) return null;

  return (
    <section>
      <h4 className="text-lg font-semibold mb-2">운세 결과</h4>
      <div>{result}</div>
    </section>
  );
}
