{{flutter_js}}
{{flutter_build_config}}

const builds = Array.isArray(_flutter.buildConfig?.builds)
  ? _flutter.buildConfig.builds
  : [];
const hasSkwasmBuild = builds.some((build) => build?.renderer === 'skwasm');

_flutter.loader.load({
  config: hasSkwasmBuild ? { renderer: 'skwasm' } : {},
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  }
});
