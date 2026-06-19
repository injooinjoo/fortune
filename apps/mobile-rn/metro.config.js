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

config.resolver = {
  ...config.resolver,
  assetExts: assetExts.includes('wasm') ? assetExts : [...assetExts, 'wasm'],
  extraNodeModules: {
    ...(config.resolver?.extraNodeModules ?? {}),
    react: path.resolve(projectRoot, 'node_modules/react'),
    'react-dom': path.resolve(projectRoot, 'node_modules/react-dom'),
    'react-native': path.resolve(projectRoot, 'node_modules/react-native'),
  },
};

module.exports = config;
