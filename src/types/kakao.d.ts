interface KakaoShareOptions {
  objectType: 'feed' | 'list' | 'location' | 'commerce' | 'text';
  content: {
    title: string;
    description: string;
    imageUrl?: string;
    link: {
      mobileWebUrl: string;
      webUrl: string;
    };
  };
  buttons?: Array<{
    title: string;
    link: {
      mobileWebUrl: string;
      webUrl: string;
    };
  }>;
}

interface Kakao {
  Share: {
    sendDefault: (options: KakaoShareOptions) => void;
  };
  init: (appKey: string) => void;
  isInitialized: () => boolean;
}

declare global {
  interface Window {
    Kakao?: Kakao;
  }
}