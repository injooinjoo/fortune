'use client';

import { useState } from 'react';
import { History } from 'lucide-react';
import { Button } from '@/components/ui/button';
import TokenBalance from './TokenBalance';
import { TokenHistoryModal } from './TokenHistoryModal';
import { useAuth } from '@/contexts/auth-context';

interface TokenBalanceWithHistoryProps {
  compact?: boolean;
  showLabel?: boolean;
  showHistory?: boolean;
  className?: string;
}

export function TokenBalanceWithHistory({ 
  compact = false, 
  showLabel = true,
  showHistory = true,
  className = "" 
}: TokenBalanceWithHistoryProps) {
  const { user } = useAuth();
  const [historyOpen, setHistoryOpen] = useState(false);

  if (!user) {
    return null;
  }

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <TokenBalance compact={compact} showLabel={showLabel} />
      
      {showHistory && (
        <>
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8"
            onClick={() => setHistoryOpen(true)}
            title="토큰 사용 내역"
          >
            <History className="h-4 w-4" />
          </Button>
          
          <TokenHistoryModal 
            open={historyOpen} 
            onOpenChange={setHistoryOpen} 
          />
        </>
      )}
    </div>
  );
}