"use client";

import type { PropsWithChildren } from 'react';
import React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'next-themes';
import { Toaster } from 'react-hot-toast';

export default function Providers({ children }: PropsWithChildren) {
  const [queryClient] = React.useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,
      },
    },
  }));
  
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider
        attribute="class"
        defaultTheme="system"
        enableSystem={true}
        disableTransitionOnChange={false}
      >
        {children}
        <Toaster
          position="top-center"
          reverseOrder={false}
          gutter={8}
          containerStyle={{
            top: 80, // AppHeader 아래 배치
          }}
          toastOptions={{
            duration: 4000,
            style: {
              background: '#ffffff',
              color: '#1f2937',
              border: '1px solid #e5e7eb',
              borderRadius: '12px',
              boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
              fontSize: '14px',
              maxWidth: '400px',
            },
            success: {
              duration: 3000,
              iconTheme: {
                primary: '#10b981',
                secondary: '#ffffff',
              },
              style: {
                border: '1px solid #10b981',
              },
            },
            error: {
              duration: 5000,
              iconTheme: {
                primary: '#ef4444',
                secondary: '#ffffff',
              },
              style: {
                border: '1px solid #ef4444',
              },
            },
            loading: {
              iconTheme: {
                primary: '#6366f1',
                secondary: '#ffffff',
              },
              style: {
                border: '1px solid #6366f1',
              },
            },
          }}
        />
      </ThemeProvider>
    </QueryClientProvider>
  );
}
