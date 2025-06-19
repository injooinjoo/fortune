"use client";
import React from "react";

interface UserProfileProps {
  name: string;
  email: string;
}

export default function UserProfile({ name, email }: UserProfileProps) {
  return (
    <section className="space-y-1">
      <h2 className="text-xl font-semibold">Welcome, {name}</h2>
      <p className="text-sm text-muted-foreground">Email: {email}</p>
    </section>
  );
}
