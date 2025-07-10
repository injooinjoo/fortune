import type {NextConfig} from 'next';

const nextConfig: NextConfig = {
  /* config options here */
  typescript: {
    ignoreBuildErrors: true,
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'placehold.co',
        port: '',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
        port: '',
        pathname: '/**',
      },
    ],
  },
  experimental: {
    esmExternals: true,
    // 청크 로딩 최적화
    optimizeCss: true,
  },
  // 개발 서버 설정
  devIndicators: {
    position: 'bottom-right',
  },
  // 청크 타임아웃 증가
  staticPageGenerationTimeout: 120,
  webpack: (config: any, { isServer }: any) => {
    // 한글 인코딩 문제 해결을 위한 설정
    config.resolve.fallback = {
      ...config.resolve.fallback,
      fs: false,
    };
    
    // Node.js 모듈 fallback 설정
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
        net: false,
        tls: false,
        dns: false,
        http2: false,
        child_process: false,
        crypto: false,
        os: false,
        path: false,
        stream: false,
        util: false,
        url: false,
        querystring: false,
        assert: false,
        buffer: false,
        events: false,
        zlib: false,
      };
    }
    
    // 청크 분할 최적화
    config.optimization = {
      ...config.optimization,
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          default: false,
          vendors: false,
          framework: {
            name: 'framework',
            chunks: 'all',
            test: /[\\/]node_modules[\\/](react|react-dom|scheduler|prop-types|use-subscription)[\\/]/,
            priority: 40,
            enforce: true,
          },
          lib: {
            test(module: any) {
              return module.size() > 160000 &&
                /node_modules[/\\]/.test(module.identifier());
            },
            name(module: any) {
              const hash = require('crypto').createHash('sha1');
              hash.update(module.identifier());
              return hash.digest('hex').substring(0, 8);
            },
            priority: 30,
            minChunks: 1,
            reuseExistingChunk: true,
          },
          commons: {
            name: 'commons',
            chunks: 'initial',
            minChunks: 2,
            priority: 20,
          },
          shared: {
            name(module: any, chunks: any[]) {
              return 'shared';
            },
            priority: 10,
            minChunks: 2,
            reuseExistingChunk: true,
          },
        },
        maxAsyncRequests: 30,
        maxInitialRequests: 30,
      },
    };
    
    // node_modules 관련 경고 억제
    config.ignoreWarnings = [
      { module: /node_modules\/@opentelemetry/ },
      { module: /node_modules\/@sentry/ },
      { module: /node_modules\/@supabase/ },
      (warning: any) => {
        return warning.message && warning.message.includes('Critical dependency');
      }
    ];
    
    return config;
  },
};

export default nextConfig;
