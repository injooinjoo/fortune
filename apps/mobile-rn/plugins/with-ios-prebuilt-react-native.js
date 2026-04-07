const { withPodfileProperties } = require('@expo/config-plugins');

module.exports = function withIosPrebuiltReactNative(config) {
  return withPodfileProperties(config, (configWithProps) => {
    configWithProps.modResults['ios.buildReactNativeFromSource'] = 'false';
    return configWithProps;
  });
};
