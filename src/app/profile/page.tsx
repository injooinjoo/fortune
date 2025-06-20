"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import AppHeader from "@/components/AppHeader";
import {
  Bell,
  Crown,
  HelpCircle,
  FileText,
  LogOut,
  UserX,
  ChevronRight,
} from "lucide-react";

export default function ProfilePage() {
  const router = useRouter();
  const [notificationsEnabled, setNotificationsEnabled] = useState(false);

  const handleEditProfile = () => {
    router.push("/profile/edit");
  };

  const handlePremium = () => {
    router.push("/premium");
  };

  const handleSupport = () => {
    router.push("/support");
  };

  const handlePolicy = () => {
    router.push("/policy");
  };

  const handleLogout = () => {
    console.log("로그아웃 처리");
  };

  const handleWithdraw = () => {
    router.push("/withdraw");
  };

  return (
    <div className="min-h-screen bg-background text-foreground pb-20">
      <AppHeader title="프로필" />
      
      <div className="p-6 space-y-6">
      <section className="flex items-center space-x-4">
        <Avatar>
          <AvatarImage src="/placeholder-avatar.png" alt="avatar" />
          <AvatarFallback>U</AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <p className="font-semibold">사용자 이름</p>
          <p className="text-sm text-muted-foreground">user@example.com</p>
        </div>
        <Button size="sm" onClick={handleEditProfile}>
          프로필 수정
        </Button>
      </section>

      <div className="rounded-md border divide-y bg-card text-card-foreground">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center space-x-3">
            <Bell className="h-5 w-5 text-muted-foreground" />
            <span className="text-sm">알림 설정</span>
          </div>
          <Switch
            checked={notificationsEnabled}
            onCheckedChange={setNotificationsEnabled}
          />
        </div>
        <button
          type="button"
          onClick={handlePremium}
          className="flex w-full items-center justify-between px-4 py-3"
        >
          <div className="flex items-center space-x-3">
            <Crown className="h-5 w-5 text-muted-foreground" />
            <span className="text-sm">프리미엄 구독 관리</span>
          </div>
          <ChevronRight className="h-4 w-4 text-muted-foreground" />
        </button>
        <button
          type="button"
          onClick={handleSupport}
          className="flex w-full items-center justify-between px-4 py-3"
        >
          <div className="flex items-center space-x-3">
            <HelpCircle className="h-5 w-5 text-muted-foreground" />
            <span className="text-sm">고객센터 / 문의하기</span>
          </div>
          <ChevronRight className="h-4 w-4 text-muted-foreground" />
        </button>
        <button
          type="button"
          onClick={handlePolicy}
          className="flex w-full items-center justify-between px-4 py-3"
        >
          <div className="flex items-center space-x-3">
            <FileText className="h-5 w-5 text-muted-foreground" />
            <span className="text-sm">이용약관 및 개인정보 처리방침</span>
          </div>
          <ChevronRight className="h-4 w-4 text-muted-foreground" />
        </button>
        <button
          type="button"
          onClick={handleLogout}
          className="flex w-full items-center justify-between px-4 py-3 text-accent"
        >
          <div className="flex items-center space-x-3">
            <LogOut className="h-5 w-5" />
            <span className="text-sm">로그아웃</span>
          </div>
        </button>
        <button
          type="button"
          onClick={handleWithdraw}
          className="flex w-full items-center justify-between px-4 py-3 text-destructive"
        >
          <div className="flex items-center space-x-3">
            <UserX className="h-5 w-5" />
            <span className="text-sm">회원 탈퇴</span>
          </div>
        </button>
      </div>
      </div>
    </div>
  );
}
