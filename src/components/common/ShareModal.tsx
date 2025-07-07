"use client";

import React, { useRef, useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { FortuneCompassIcon } from "@/components/icons/fortune-compass-icon";
import { useToast } from "@/hooks/use-toast";
import html2canvas from "html2canvas";
import {
  Facebook,
  Instagram,
  MessageCircle,
  Link as LinkIcon,
  Download,
  Loader2,
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
  const [isLoading, setIsLoading] = useState(false);
  const [shareMessage, setShareMessage] = useState("");
  const { toast } = useToast();

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      toast({
        title: "링크 복사됨",
        description: "클립보드에 링크가 복사되었습니다.",
      });
    } catch (err) {
      console.error(err);
      toast({
        title: "복사 실패",
        description: "링크 복사에 실패했습니다.",
        variant: "destructive",
      });
    }
  };

  const handleSaveImage = async () => {
    if (!previewRef.current) return;
    
    setIsLoading(true);
    try {
      const canvas = await html2canvas(previewRef.current, {
        backgroundColor: "#FFFFF0", // ivory color
        scale: 2, // 고해상도
        logging: false,
      });
      
      // Canvas를 Blob으로 변환
      canvas.toBlob((blob) => {
        if (blob) {
          // Blob을 다운로드 링크로 변환
          const url = URL.createObjectURL(blob);
          const link = document.createElement("a");
          link.href = url;
          link.download = `fortune-${Date.now()}.png`;
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
          URL.revokeObjectURL(url);
          
          toast({
            title: "이미지 저장됨",
            description: "운세 이미지가 다운로드되었습니다.",
          });
        }
      }, "image/png");
    } catch (error) {
      console.error("이미지 생성 실패:", error);
      toast({
        title: "저장 실패",
        description: "이미지 저장에 실패했습니다.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleShareKakao = () => {
    // Kakao SDK가 로드되어 있는지 확인
    if (typeof window !== "undefined" && window.Kakao) {
      try {
        window.Kakao.Share.sendDefault({
          objectType: "feed",
          content: {
            title: title,
            description: description,
            imageUrl: imageUrl || `${window.location.origin}/og-image.png`,
            link: {
              mobileWebUrl: window.location.href,
              webUrl: window.location.href,
            },
          },
          buttons: [
            {
              title: "운세 보러가기",
              link: {
                mobileWebUrl: window.location.href,
                webUrl: window.location.href,
              },
            },
          ],
        });
      } catch (error) {
        console.error("카카오톡 공유 실패:", error);
        toast({
          title: "공유 실패",
          description: "카카오톡 공유에 실패했습니다.",
          variant: "destructive",
        });
      }
    } else {
      toast({
        title: "카카오톡 연결 필요",
        description: "카카오톡 공유 기능을 사용할 수 없습니다.",
        variant: "destructive",
      });
    }
  };
  
  const handleShareInstagram = () => {
    toast({
      title: "인스타그램 공유",
      description: "먼저 이미지를 저장한 후 인스타그램에 업로드해주세요.",
    });
  };
  
  const handleShareFacebook = () => {
    const url = encodeURIComponent(window.location.href);
    const text = encodeURIComponent(`${title} - ${description}`);
    window.open(
      `https://www.facebook.com/sharer/sharer.php?u=${url}&quote=${text}`,
      "_blank",
      "width=600,height=400"
    );
  };

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
              <Button variant="ghost" onClick={handleSaveImage} disabled={isLoading}>
                {isLoading ? (
                  <Loader2 className="size-4 animate-spin" />
                ) : (
                  <Download className="size-4" />
                )}
                이미지 저장
              </Button>
            </div>
          </div>

          <Textarea 
            placeholder="공유 메시지를 입력하세요" 
            value={shareMessage}
            onChange={(e) => setShareMessage(e.target.value)}
            className="min-h-[80px]"
          />
        </div>
      </DialogContent>
    </Dialog>
  );
}

