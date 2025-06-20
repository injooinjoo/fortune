"use client";

import React, { useState } from "react";
import Image from "next/image";
import AppHeader from "@/components/AppHeader";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardFooter,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader as DialogHeaderUI,
  DialogTitle as DialogTitleUI,
  DialogFooter as DialogFooterUI,
  DialogDescription as DialogDescriptionUI,
} from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { Star } from "lucide-react";

interface Expert {
  id: number;
  name: string;
  title: string;
  image: string;
  rating: number;
  price: number;
}

const experts: Expert[] = [
  {
    id: 1,
    name: "서현 타로마스터",
    title: "타로 상담 10년 경력",
    image: "https://placehold.co/128x128/png",
    rating: 4.9,
    price: 20000,
  },
  {
    id: 2,
    name: "도윤 역술가",
    title: "사주/작명 전문가",
    image: "https://placehold.co/128x128/png",
    rating: 4.8,
    price: 30000,
  },
];

function ExpertCard({ expert }: { expert: Expert }) {
  const [date, setDate] = useState<Date>();
  const [time, setTime] = useState<string>("");
  const [memo, setMemo] = useState("");
  const { toast } = useToast();

  const handleReserve = () => {
    toast({
      title: "예약 완료",
      description: `${expert.name}님과의 상담이 예약되었습니다.`,
    });
  };

  return (
    <Card className="flex items-center p-4 space-x-4">
      <div className="relative w-16 h-16">
        <Image
          src={expert.image}
          alt={expert.name}
          fill
          className="rounded-full object-cover"
        />
      </div>
      <div className="flex-1">
        <CardHeader className="p-0 space-y-1">
          <CardTitle className="text-base">{expert.name}</CardTitle>
          <CardDescription>{expert.title}</CardDescription>
          <div className="flex items-center text-sm text-yellow-500">
            <Star className="w-4 h-4 mr-1" />
            {expert.rating.toFixed(1)} / 5.0
          </div>
        </CardHeader>
      </div>
      <CardFooter className="p-0">
        <Dialog>
          <DialogTrigger asChild>
            <Button size="sm">상담 예약</Button>
          </DialogTrigger>
          <DialogContent className="space-y-4">
            <DialogHeaderUI>
              <DialogTitleUI>{expert.name}</DialogTitleUI>
              <DialogDescriptionUI>{expert.title}</DialogDescriptionUI>
            </DialogHeaderUI>
            <div className="space-y-2">
              <p className="text-sm font-medium">날짜 선택</p>
              <Calendar mode="single" selected={date} onSelect={setDate} />
              <p className="text-sm font-medium">시간 선택</p>
              <Select onValueChange={setTime} value={time}>
                <SelectTrigger>
                  <SelectValue placeholder="시간을 선택하세요" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="10:00">오전 10시</SelectItem>
                  <SelectItem value="14:00">오후 2시</SelectItem>
                  <SelectItem value="19:00">오후 7시</SelectItem>
                </SelectContent>
              </Select>
              <p className="text-sm font-medium">상담 내용</p>
              <Textarea
                value={memo}
                onChange={(e) => setMemo(e.target.value)}
                placeholder="궁금한 내용을 작성해주세요"
              />
            </div>
            <DialogFooterUI>
              <Button
                className="w-full"
                onClick={handleReserve}
                disabled={!date || !time}
              >
                {expert.price.toLocaleString()}원 결제 후 예약
              </Button>
            </DialogFooterUI>
          </DialogContent>
        </Dialog>
      </CardFooter>
    </Card>
  );
}

export default function ConsultPage() {
  return (
    <>
      <AppHeader title="점신 1:1 상담" />
      <div className="space-y-4 p-4 pb-32">
        {experts.map((expert) => (
          <ExpertCard key={expert.id} expert={expert} />
        ))}
      </div>
    </>
  );
}

