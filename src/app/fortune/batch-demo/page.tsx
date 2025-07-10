'use client';

import { logger } from '@/lib/logger';
import { BatchFortuneContainer } from '@/components/fortune/BatchFortuneContainer';
import AppHeader from '@/components/AppHeader';
import { useState } from 'react';

export default function BatchFortuneDemoPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-muted">
      <AppHeader
        title="운세 패키지"
        showBack={true}
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <main className="container mx-auto px-4 py-8 pt-20">
        <BatchFortuneContainer
          onFortuneGenerated={(data) => {
            logger.debug('운세 생성 완료:', data);
          }}
        />
      </main>
    </div>
  );
}