const path = require('path');
const { getDefaultConfig } = require('expo/metro-config');

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, '../..');
const config = getDefaultConfig(projectRoot);
const { assetExts = [] } = config.resolver ?? {};

config.watchFolders = [
  ...(config.watchFolders ?? []),
  workspaceRoot,
];

// watchFolders 가 워크스페이스 루트라 Metro 가 apps/web 까지 크롤링한다.
// Next 빌드 산출물과 웹 전용 node_modules 는 RN 번들에 들어갈 일이 없으므로 차단.
const webArtifacts = [
  path.resolve(workspaceRoot, 'apps/web/.next'),
  path.resolve(workspaceRoot, 'apps/web/node_modules'),
];

config.resolver = {
  ...config.resolver,
  assetExts: assetExts.includes('wasm') ? assetExts : [...assetExts, 'wasm'],
  blockList: [
    ...(Array.isArray(config.resolver?.blockList)
      ? config.resolver.blockList
      : config.resolver?.blockList
        ? [config.resolver.blockList]
        : []),
    ...webArtifacts.map(
      (dir) => new RegExp(`^${dir.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}/.*$`),
    ),
  ],
  extraNodeModules: {
    ...(config.resolver?.extraNodeModules ?? {}),
    react: path.resolve(projectRoot, 'node_modules/react'),
    'react-dom': path.resolve(projectRoot, 'node_modules/react-dom'),
    'react-native': path.resolve(projectRoot, 'node_modules/react-native'),
  },
};

module.exports = config;
