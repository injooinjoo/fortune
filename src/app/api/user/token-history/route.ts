import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';
import { supabase } from '@/lib/supabase';

interface TokenTransaction {
  id: string;
  user_id: string;
  transaction_type: 'usage' | 'purchase' | 'bonus' | 'refund' | 'subscription';
  amount: number;
  balance_after: number;
  description?: string;
  fortune_type?: string;
  reference_id?: string;
  created_at: string;
}

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      const { searchParams } = new URL(req.url);
      const page = parseInt(searchParams.get('page') || '1');
      const limit = parseInt(searchParams.get('limit') || '20');
      const startDate = searchParams.get('startDate');
      const endDate = searchParams.get('endDate');
      const type = searchParams.get('type'); // usage, purchase, all
      
      const offset = (page - 1) * limit;
      
      // Build query
      let query = supabase
        .from('token_transactions')
        .select('*', { count: 'exact' })
        .eq('user_id', req.userId!)
        .order('created_at', { ascending: false })
        .range(offset, offset + limit - 1);
      
      // Apply filters
      if (startDate) {
        query = query.gte('created_at', startDate);
      }
      
      if (endDate) {
        query = query.lte('created_at', endDate);
      }
      
      if (type && type !== 'all') {
        if (type === 'usage') {
          query = query.eq('transaction_type', 'usage');
        } else if (type === 'purchase') {
          query = query.in('transaction_type', ['purchase', 'bonus', 'subscription']);
        }
      }
      
      const { data: transactions, error, count } = await query;
      
      if (error) {
        console.error('토큰 내역 조회 오류:', error);
        return createErrorResponse('토큰 내역을 불러올 수 없습니다', undefined, undefined, 500);
      }
      
      // Format transactions for display
      const formattedTransactions = transactions?.map((tx: TokenTransaction) => ({
        id: tx.id,
        type: tx.transaction_type,
        amount: tx.amount,
        balanceAfter: tx.balance_after,
        description: getTransactionDescription(tx),
        fortuneType: tx.fortune_type,
        createdAt: tx.created_at,
        isAddition: ['purchase', 'bonus', 'refund', 'subscription'].includes(tx.transaction_type)
      })) || [];
      
      // Get current balance
      const { data: balanceData } = await supabase
        .from('user_tokens')
        .select('balance')
        .eq('user_id', req.userId!)
        .single();
      
      const currentBalance = balanceData?.balance || 0;
      
      // Calculate summary statistics
      const { data: stats } = await supabase
        .rpc('get_token_usage_stats', { 
          p_user_id: req.userId!,
          p_start_date: startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
          p_end_date: endDate || new Date().toISOString()
        });
      
      return createSuccessResponse({
        transactions: formattedTransactions,
        pagination: {
          page,
          limit,
          total: count || 0,
          totalPages: Math.ceil((count || 0) / limit)
        },
        currentBalance,
        statistics: {
          totalUsed: stats?.[0]?.total_used || 0,
          totalPurchased: stats?.[0]?.total_purchased || 0,
          totalBonus: stats?.[0]?.total_bonus || 0,
          mostUsedFortune: stats?.[0]?.most_used_fortune || null
        }
      });
      
    } catch (error) {
      console.error('토큰 내역 API 오류:', error);
      return createErrorResponse('토큰 내역 조회 중 오류가 발생했습니다', undefined, undefined, 500);
    }
  });
}

function getTransactionDescription(tx: TokenTransaction): string {
  switch (tx.transaction_type) {
    case 'usage':
      return tx.description || `${tx.fortune_type || '운세'} 조회`;
    case 'purchase':
      return tx.description || '토큰 구매';
    case 'bonus':
      return tx.description || '보너스 토큰';
    case 'subscription':
      return tx.description || '구독 토큰 지급';
    case 'refund':
      return tx.description || '환불';
    default:
      return tx.description || '기타';
  }
}