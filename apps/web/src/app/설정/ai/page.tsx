import type { Metadata } from 'next';

import { AiKeySettings } from '@/features/settings/ai-key-settings';
import { IS_BYOK_ENABLED } from '@/features/settings/providers';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 개인 AI 키 연결 화면.
 *
 * 한글 slug 는 `/운세`, `/대화` 와 같은 이유로 유지한다. 다만 링크는 반드시
 * `features/settings/providers.ts` 의 `SETTINGS_AI_HREF` 를 쓸 것 —
 * 디코딩된 한글을 `<Link href>` 에 직접 넣으면 Next 의 RSC 요청이 깨진다.
 *
 * 로그인한 사람만 쓰는 화면이라 색인하지 않는다. 세션 판단은 클라이언트
 * 컴포넌트가 한다 (여기서 세션을 읽으면 정적 생성만 잃고 얻는 게 없다 —
 * 어차피 Edge Function 호출은 브라우저 세션으로 나간다).
 *
 * `IS_BYOK_ENABLED` 가 꺼져 있으면 연결 폼을 아예 그리지 않는다. 운세 생성이
 * 아직 사용자 키를 쓰지 않는 상태에서 키를 받아 두는 건 쓰지도 않을 남의
 * 자격증명을 떠안는 일이다 (providers.ts 주석에 켜는 조건이 적혀 있다).
 */
export const metadata: Metadata = {
  title: '내 AI 키 연결',
  robots: { index: false, follow: false },
};

export default function AiKeySettingsPage() {
  if (!IS_BYOK_ENABLED) {
    return (
      <FortunePageShell
        description="쓰고 있는 GPT · Gemini · Claude · Grok · OpenRouter 키를 연결하는 기능을 준비하고 있어요."
        kicker="설정"
        title="내 AI 키 연결"
      >
        <section className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
          <h2 className="ondo-h3">아직 준비 중이에요</h2>
          <p className="ondo-muted">
            개인 키로 운세를 만드는 기능은 아직 열지 않았어요. 준비되기 전에 키를 미리 받아
            두지는 않으려고 합니다. 열리면 이 화면에서 바로 연결하실 수 있어요.
          </p>
        </section>
      </FortunePageShell>
    );
  }

  return (
    <FortunePageShell
      description="GPT · Gemini · Claude · Grok · OpenRouter 중 쓰고 있는 키를 연결하면, 그 운세는 회원님의 키로 만들어집니다."
      kicker="설정"
      title="내 AI 키 연결"
    >
      <section className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <h2 className="ondo-h3">연결하기 전에 알아 두세요</h2>
        <ul className="ondo-muted" style={{ margin: 0, paddingLeft: '1.2em' }}>
          <li>
            키는 저장될 때 암호화돼요. 한 번 저장하면 화면에서도, 저희 쪽에서도 다시 꺼내
            볼 수 없고 마지막 네 자리만 보여드립니다.
          </li>
          <li>
            {/*
              토큰 면제는 약속하지 않는다. 차감은 Edge Function 의
              requirePaidFortuneCaller 가 하고, 거기에는 BYOK 예외 경로가 없다.
              화면 문구를 바꾸려면 먼저 차감 로직을 바꿀 것.
            */}
            온도(토큰)는 지금과 똑같이 차감돼요. 키를 연결해도 서비스 이용료가 줄지는
            않습니다.
          </li>
          <li>
            여기에 더해 모델 사용료는 해당 제공자가 회원님께 직접 청구합니다. 요금과 사용량은
            각 제공자 콘솔에서 확인해 주세요.
          </li>
        </ul>
      </section>

      <AiKeySettings />
    </FortunePageShell>
  );
}
