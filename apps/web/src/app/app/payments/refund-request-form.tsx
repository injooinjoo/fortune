'use client';

import { useRouter } from 'next/navigation';
import type { FormEvent } from 'react';
import { useState } from 'react';

import { getBrowserSupabase } from '@/lib/supabase/client';

export function RefundRequestForm({ orderId }: { orderId: string }) {
  const router = useRouter();
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (reason.trim().length < 2) {
      setMessage('환불 사유를 두 글자 이상 입력해 주세요.');
      return;
    }
    const supabase = getBrowserSupabase();
    if (!supabase) {
      setMessage('로그인 정보를 확인하지 못했어요.');
      return;
    }
    setBusy(true);
    setMessage(null);
    const { error } = await supabase.rpc('request_web_payment_refund', {
      p_order_id: orderId,
      p_reason: reason.trim(),
    });
    setBusy(false);
    if (error) {
      setMessage('환불 요청을 접수하지 못했어요. 고객 지원에 문의해 주세요.');
      return;
    }
    setReason('');
    setMessage('환불 검토 요청을 접수했어요.');
    router.refresh();
  }

  return (
    <form className="ondo-stack" onSubmit={submit}>
      <label>
        <span className="ondo-kicker">환불 사유</span>
        <input
          maxLength={200}
          onChange={(event) => setReason(event.target.value)}
          placeholder="요청 사유를 입력해 주세요"
          value={reason}
        />
      </label>
      <button className="ondo-button ondo-button-secondary" disabled={busy} type="submit">
        {busy ? '접수 중…' : '전액 환불 검토 요청'}
      </button>
      {message ? <p className="ondo-muted" role="status">{message}</p> : null}
    </form>
  );
}
