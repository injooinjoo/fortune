'use client';

import { logger } from '@/lib/logger';
import { useState, useEffect } from 'react';
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle,
  DialogDescription 
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Calendar } from '@/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { 
  Coins, 
  TrendingDown, 
  TrendingUp, 
  Calendar as CalendarIcon,
  ChevronLeft,
  ChevronRight,
  Loader2,
  FileText,
  Gift,
  CreditCard,
  RefreshCw
} from 'lucide-react';
import { format } from 'date-fns';
import { ko } from 'date-fns/locale';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '@/lib/utils';
import { getAuthToken } from '@/lib/auth-utils';

interface TokenTransaction {
  id: string;
  type: 'usage' | 'purchase' | 'bonus' | 'refund' | 'subscription';
  amount: number;
  balanceAfter: number;
  description: string;
  fortuneType?: string;
  createdAt: string;
  isAddition: boolean;
}

interface TokenHistoryModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function TokenHistoryModal({ open, onOpenChange }: TokenHistoryModalProps) {
  const [transactions, setTransactions] = useState<TokenTransaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [currentBalance, setCurrentBalance] = useState(0);
  const [filter, setFilter] = useState<'all' | 'usage' | 'purchase'>('all');
  const [startDate, setStartDate] = useState<Date | undefined>();
  const [endDate, setEndDate] = useState<Date | undefined>();
  const [statistics, setStatistics] = useState({
    totalUsed: 0,
    totalPurchased: 0,
    totalBonus: 0,
    mostUsedFortune: null as string | null
  });

  useEffect(() => {
    if (open) {
      fetchTokenHistory();
    }
  }, [open, page, filter, startDate, endDate]);

  const fetchTokenHistory = async () => {
    setLoading(true);
    try {
      const token = await getAuthToken();
      if (!token) return;

      const params = new URLSearchParams({
        page: page.toString(),
        limit: '20',
        type: filter
      });

      if (startDate) {
        params.append('startDate', startDate.toISOString());
      }
      if (endDate) {
        params.append('endDate', endDate.toISOString());
      }

      const response = await fetch(`/api/user/token-history?${params}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (!response.ok) {
        throw new Error('토큰 내역을 불러올 수 없습니다');
      }

      const data = await response.json();
      setTransactions(data.transactions);
      setTotalPages(data.pagination.totalPages);
      setCurrentBalance(data.currentBalance);
      setStatistics(data.statistics);
    } catch (error) {
      logger.error('토큰 내역 조회 실패:', error);
    } finally {
      setLoading(false);
    }
  };

  const getTransactionIcon = (type: string) => {
    switch (type) {
      case 'usage':
        return <FileText className="h-4 w-4" />;
      case 'purchase':
        return <CreditCard className="h-4 w-4" />;
      case 'bonus':
        return <Gift className="h-4 w-4" />;
      case 'subscription':
        return <RefreshCw className="h-4 w-4" />;
      default:
        return <Coins className="h-4 w-4" />;
    }
  };

  const getTransactionColor = (type: string, isAddition: boolean) => {
    if (isAddition) {
      return 'text-green-600 dark:text-green-400';
    }
    return 'text-red-600 dark:text-red-400';
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[80vh]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Coins className="h-5 w-5" />
            토큰 사용 내역
          </DialogTitle>
          <DialogDescription>
            토큰 구매 및 사용 내역을 확인하세요
          </DialogDescription>
        </DialogHeader>

        {/* 현재 잔액 표시 */}
        <div className="bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg p-4 mb-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm opacity-90">현재 토큰 잔액</p>
              <p className="text-2xl font-bold">{currentBalance.toLocaleString()} 토큰</p>
            </div>
            <Coins className="h-8 w-8 opacity-50" />
          </div>
        </div>

        {/* 통계 정보 */}
        <div className="grid grid-cols-3 gap-3 mb-4">
          <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-3">
            <div className="flex items-center gap-2 text-red-600 dark:text-red-400 mb-1">
              <TrendingDown className="h-4 w-4" />
              <span className="text-xs">사용 토큰</span>
            </div>
            <p className="text-lg font-semibold">{statistics.totalUsed.toLocaleString()}</p>
          </div>
          <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-3">
            <div className="flex items-center gap-2 text-green-600 dark:text-green-400 mb-1">
              <TrendingUp className="h-4 w-4" />
              <span className="text-xs">구매 토큰</span>
            </div>
            <p className="text-lg font-semibold">{statistics.totalPurchased.toLocaleString()}</p>
          </div>
          <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-3">
            <div className="flex items-center gap-2 text-purple-600 dark:text-purple-400 mb-1">
              <Gift className="h-4 w-4" />
              <span className="text-xs">보너스 토큰</span>
            </div>
            <p className="text-lg font-semibold">{statistics.totalBonus.toLocaleString()}</p>
          </div>
        </div>

        {/* 필터 및 날짜 선택 */}
        <div className="flex items-center justify-between mb-4">
          <Tabs value={filter} onValueChange={(v) => setFilter(v as any)}>
            <TabsList>
              <TabsTrigger value="all">전체</TabsTrigger>
              <TabsTrigger value="usage">사용</TabsTrigger>
              <TabsTrigger value="purchase">구매</TabsTrigger>
            </TabsList>
          </Tabs>

          <div className="flex gap-2">
            <Popover>
              <PopoverTrigger asChild>
                <Button variant="outline" size="sm">
                  <CalendarIcon className="h-4 w-4 mr-2" />
                  {startDate ? format(startDate, 'MM/dd') : '시작일'}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0">
                <Calendar
                  mode="single"
                  selected={startDate}
                  onSelect={setStartDate}
                  locale={ko}
                />
              </PopoverContent>
            </Popover>
            <Popover>
              <PopoverTrigger asChild>
                <Button variant="outline" size="sm">
                  <CalendarIcon className="h-4 w-4 mr-2" />
                  {endDate ? format(endDate, 'MM/dd') : '종료일'}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0">
                <Calendar
                  mode="single"
                  selected={endDate}
                  onSelect={setEndDate}
                  locale={ko}
                />
              </PopoverContent>
            </Popover>
          </div>
        </div>

        {/* 거래 내역 */}
        <ScrollArea className="h-[300px] pr-4">
          {loading ? (
            <div className="flex items-center justify-center h-full">
              <Loader2 className="h-8 w-8 animate-spin text-gray-400" />
            </div>
          ) : transactions.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-gray-500">
              <FileText className="h-12 w-12 mb-2 opacity-50" />
              <p>토큰 사용 내역이 없습니다</p>
            </div>
          ) : (
            <AnimatePresence>
              {transactions.map((tx, index) => (
                <motion.div
                  key={tx.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  className="flex items-center justify-between py-3 border-b last:border-0"
                >
                  <div className="flex items-start gap-3">
                    <div className={cn(
                      "p-2 rounded-full",
                      tx.isAddition ? "bg-green-100 dark:bg-green-900" : "bg-red-100 dark:bg-red-900"
                    )}>
                      {getTransactionIcon(tx.type)}
                    </div>
                    <div>
                      <p className="font-medium">{tx.description}</p>
                      <p className="text-sm text-gray-500">
                        {format(new Date(tx.createdAt), 'yyyy년 MM월 dd일 HH:mm', { locale: ko })}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className={cn("font-semibold", getTransactionColor(tx.type, tx.isAddition))}>
                      {tx.isAddition ? '+' : '-'}{tx.amount.toLocaleString()}
                    </p>
                    <p className="text-sm text-gray-500">
                      잔액 {tx.balanceAfter.toLocaleString()}
                    </p>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>
          )}
        </ScrollArea>

        {/* 페이지네이션 */}
        {totalPages > 1 && (
          <div className="flex items-center justify-center gap-2 mt-4">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.max(1, p - 1))}
              disabled={page === 1}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <span className="text-sm text-gray-600">
              {page} / {totalPages}
            </span>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(p => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        )}

        {/* 최다 사용 운세 */}
        {statistics.mostUsedFortune && (
          <div className="mt-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
            <p className="text-sm text-blue-700 dark:text-blue-300">
              💡 가장 많이 본 운세: <strong>{statistics.mostUsedFortune}</strong>
            </p>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}