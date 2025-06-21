"use client";

import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Type, Share2, Type as TypeIcon } from "lucide-react";
import { useRouter, usePathname } from "next/navigation";
import { useState } from "react";

interface AppHeaderProps {
  title?: string;
  showBack?: boolean;
  onFontSizeChange?: (size: 'small' | 'medium' | 'large') => void;
  currentFontSize?: 'small' | 'medium' | 'large';
}

export default function AppHeader({ 
  title = "Fortune", 
  showBack,
  onFontSizeChange,
  currentFontSize = 'medium'
}: AppHeaderProps) {
  const router = useRouter();
  const pathname = usePathname();
  const [showFontMenu, setShowFontMenu] = useState(false);

  // 뒤로가기 버튼 표시 여부 결정
  const shouldShowBack = showBack !== undefined ? showBack : !pathname?.includes('/home');

  const handleBack = () => {
    // 상위 페이지로 이동하는 로직
    if (pathname === '/fortune') {
      router.push('/home');
    } else if (pathname?.startsWith('/fortune/lucky-')) {
      // 행운 시리즈 페이지들은 행운 시리즈 메인으로 이동
      router.push('/fortune/lucky-series');
    } else if (pathname?.startsWith('/fortune/')) {
      router.push('/fortune');
    } else if (pathname?.startsWith('/interactive/')) {
      router.push('/home');
    } else if (pathname?.startsWith('/profile/')) {
      // 프로필 서브 페이지들은 프로필 메인으로 이동
      router.push('/profile');
    } else if (pathname?.startsWith('/app/')) {
      // 앱 관련 페이지들은 홈으로 이동
      router.push('/home');
    } else if (pathname === '/feedback' || pathname === '/about' || pathname === '/support' || pathname === '/policy' || pathname === '/membership') {
      // 메인 서비스 페이지들은 홈으로 이동
      router.push('/home');
    } else {
      router.back(); // 기본적으로는 이전 페이지
    }
  };

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: title,
          text: `${title} - 운세 보기`,
          url: window.location.href,
        });
      } catch (error) {
        // 공유 취소시 에러 무시
      }
    } else {
      // 웹 공유 API 미지원시 클립보드 복사
      try {
        await navigator.clipboard.writeText(window.location.href);
        // 간단한 피드백 (실제 앱에서는 toast 메시지 사용)
        alert('링크가 클립보드에 복사되었습니다!');
      } catch (error) {
        console.error('공유 실패:', error);
      }
    }
  };

  const fontSizeLabels = {
    small: '작게',
    medium: '보통',
    large: '크게'
  };

  return (
    <motion.header
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.3 }}
      className="sticky top-0 z-50 w-full bg-white/95 dark:bg-gray-900/95 backdrop-blur-md border-b border-gray-200/50 dark:border-gray-700/50 shadow-sm"
    >
      <div className="flex items-center justify-between px-4 py-3 h-14">
        {/* 왼쪽: 뒤로가기 버튼 */}
        <div className="flex items-center w-16">
          {shouldShowBack && (
            <motion.div
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Button 
                variant="ghost" 
                size="sm" 
                onClick={handleBack}
                className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full"
              >
                <ArrowLeft className="w-5 h-5 text-gray-700 dark:text-gray-300" />
              </Button>
            </motion.div>
          )}
        </div>

        {/* 가운데: 페이지 제목 */}
        <motion.div 
          className="flex-1 text-center"
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <h1 className="text-lg font-bold text-gray-900 dark:text-gray-100 truncate px-4">
            {title}
          </h1>
        </motion.div>

        {/* 오른쪽: 글씨크기 조절 & 공유 버튼 */}
        <div className="flex items-center space-x-1 w-16 justify-end relative">
          {/* 글씨크기 조절 버튼 */}
          <div className="relative">
            <motion.div
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Button 
                variant="ghost" 
                size="sm"
                onClick={() => setShowFontMenu(!showFontMenu)}
                className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full"
              >
                <Type className="w-4 h-4 text-gray-700 dark:text-gray-300" />
              </Button>
            </motion.div>

            {/* 글씨크기 메뉴 */}
            {showFontMenu && (
              <motion.div
                initial={{ opacity: 0, scale: 0.95, y: -5 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: -5 }}
                className="absolute right-0 top-full mt-1 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg py-1 min-w-[80px] z-[100]"
              >
                {(['small', 'medium', 'large'] as const).map((size) => (
                  <button
                    key={size}
                    onClick={(e) => {
                      e.stopPropagation();
                      onFontSizeChange?.(size);
                      setShowFontMenu(false);
                    }}
                    className={`w-full px-3 py-2 text-sm text-left hover:bg-gray-50 dark:hover:bg-gray-700 flex items-center gap-2 transition-colors ${
                      currentFontSize === size ? 'bg-purple-50 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400' : 'text-gray-700 dark:text-gray-300'
                    }`}
                  >
                    <TypeIcon className={`${
                      size === 'small' ? 'w-3 h-3' : 
                      size === 'medium' ? 'w-4 h-4' : 'w-5 h-5'
                    }`} />
                    {fontSizeLabels[size]}
                  </button>
                ))}
              </motion.div>
            )}
          </div>

          {/* 공유 버튼 */}
          <motion.div
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <Button 
              variant="ghost" 
              size="sm"
              onClick={handleShare}
              className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full"
            >
              <Share2 className="w-4 h-4 text-gray-700 dark:text-gray-300" />
            </Button>
          </motion.div>
        </div>
      </div>

      {/* 글씨크기 메뉴 배경 클릭시 닫기 */}
      {showFontMenu && (
        <div 
          className="fixed inset-0 z-[90]" 
          onClick={() => setShowFontMenu(false)}
        />
      )}
    </motion.header>
  );
} 