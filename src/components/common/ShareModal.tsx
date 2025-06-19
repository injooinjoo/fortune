"use client";

import React, { useRef } from "react";
import {
  Dialog,
  DialogContent,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import {
  Facebook,
  Instagram,
  MessageCircle,
  Link as LinkIcon,
  Download,
} from "lucide-react";

interface ShareModalProps {
  title: string;
  description: string;
  imageUrl?: string;
}

export default function ShareModal({
  title,
  description,
  imageUrl,
}: ShareModalProps) {
  const previewRef = useRef<HTMLDivElement>(null);

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
    } catch (err) {
      console.error(err);
    }
  };

  const handleSaveImage = async () => {
    if (!previewRef.current) return;
    // TODO: convert preview div to image using html2canvas
    console.log("save image", previewRef.current);
  };

  const handleShareKakao = () => console.log("share kakao");
  const handleShareInstagram = () => console.log("share instagram");
  const handleShareFacebook = () => console.log("share facebook");

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline">공유</Button>
      </DialogTrigger>
      <DialogContent className="max-w-lg">
        <div className="space-y-4">
          <div
            ref={previewRef}
            className="relative flex flex-col items-center justify-center gap-2 rounded-md bg-[ivory] p-6 text-center"
          >
            {imageUrl && (
              <img
                src={imageUrl}
                alt="share preview"
                className="absolute inset-0 h-full w-full rounded-md object-cover"
              />
            )}
            <FortuneCompassIcon className="relative z-10 size-10" />
            <h3 className="relative z-10 text-lg font-bold">{title}</h3>
            <p className="relative z-10 text-sm">{description}</p>
          </div>

          <div className="space-y-2">
            <h4 className="text-base font-semibold">공유하기</h4>
            <div className="flex flex-wrap gap-2">
              <Button variant="ghost" onClick={handleShareKakao}>
                <MessageCircle className="size-4" /> 카카오톡
              </Button>
              <Button variant="ghost" onClick={handleShareInstagram}>
                <Instagram className="size-4" /> 인스타그램
              </Button>
              <Button variant="ghost" onClick={handleShareFacebook}>
                <Facebook className="size-4" /> 페이스북
              </Button>
              <Button variant="ghost" onClick={handleCopyLink}>
                <LinkIcon className="size-4" /> 링크 복사
              </Button>
              <Button variant="ghost" onClick={handleSaveImage}>
                <Download className="size-4" /> 이미지 저장
              </Button>
            </div>
          </div>

          <Textarea placeholder="공유 메시지를 입력하세요" />
        </div>
      </DialogContent>
    </Dialog>
  );
}

