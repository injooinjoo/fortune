"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Heart, Sparkles } from "lucide-react";

interface WallWish {
  id: string;
  text: string;
  createdAt: string;
  likes: number;
}

export default function WishWallPage() {
  const [wishes, setWishes] = useState<WallWish[]>([]);
  const [newWish, setNewWish] = useState("");

  useEffect(() => {
    const stored = localStorage.getItem("fortune-wish-wall");
    if (stored) {
      try {
        setWishes(JSON.parse(stored));
      } catch {
        // ignore parsing errors
      }
    }
  }, []);

  const saveWishes = (data: WallWish[]) => {
    setWishes(data);
    localStorage.setItem("fortune-wish-wall", JSON.stringify(data));
  };

  const handleSubmit = () => {
    if (!newWish.trim()) return;
    const wish: WallWish = {
      id: Date.now().toString(),
      text: newWish.trim(),
      createdAt: new Date().toISOString(),
      likes: 0,
    };
    const updated = [wish, ...wishes];
    saveWishes(updated);
    setNewWish("");
  };

  const handleLike = (id: string) => {
    const updated = wishes.map((w) =>
      w.id === id ? { ...w, likes: w.likes + 1 } : w
    );
    saveWishes(updated);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-pink-50 to-orange-50 pb-24">
      <AppHeader title="소원담벼락" />
      <div className="container mx-auto px-4 pt-6 space-y-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-4"
        >
          <div className="inline-flex items-center gap-2 bg-gradient-to-r from-pink-500 to-orange-500 text-white px-4 py-2 rounded-full text-sm font-medium mb-4">
            <Sparkles className="h-4 w-4" />
            소원담벼락
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">익명의 소원을 남기고 서로 응원해요</h1>
          <p className="text-gray-600">따뜻한 마음을 전하며 긍정의 에너지를 나눠보세요</p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <Card className="mb-6 shadow-lg border-0 bg-white/80 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Sparkles className="h-5 w-5 text-pink-500" />
                소원 남기기
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <Textarea
                placeholder="진심을 담아 소원을 적어주세요..."
                value={newWish}
                onChange={(e) => setNewWish(e.target.value)}
                className="min-h-[100px] resize-none border-pink-200 focus:border-pink-400"
                maxLength={200}
              />
              <div className="text-right text-xs text-gray-500">{newWish.length}/200</div>
              <Button
                onClick={handleSubmit}
                disabled={!newWish.trim()}
                className="w-full bg-gradient-to-r from-pink-500 to-orange-500 hover:from-pink-600 hover:to-orange-600"
              >
                담벼락에 소원쓰기
              </Button>
            </CardContent>
          </Card>
        </motion.div>

        {wishes.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Card className="shadow-lg border-0 bg-white/80 backdrop-blur-sm">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Heart className="h-5 w-5 text-red-500" />
                  다른 사람들의 소원
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {wishes.map((wish) => (
                    <div key={wish.id} className="p-4 border border-gray-200 rounded-lg bg-white">
                      <p className="text-gray-700 mb-2 whitespace-pre-wrap">{wish.text}</p>
                      <div className="flex items-center justify-between text-sm text-gray-500">
                        <span>{new Date(wish.createdAt).toLocaleString('ko-KR')}</span>
                        <button
                          type="button"
                          onClick={() => handleLike(wish.id)}
                          className="flex items-center gap-1 text-pink-600 hover:text-pink-700"
                        >
                          <Heart className="w-4 h-4" /> {wish.likes}
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </div>
    </div>
  );
}
