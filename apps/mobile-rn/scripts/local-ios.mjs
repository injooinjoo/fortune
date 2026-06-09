#!/usr/bin/env node
import { existsSync, mkdtempSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const appRoot = path.resolve(scriptDir, '..');
const iosDir = path.join(appRoot, 'ios');
const command = process.argv[2] ?? 'doctor';

function localEnv(extra = {}) {
  return {
    ...process.env,
    EXPO_NO_TELEMETRY: '1',
    // Local native builds must be free/offline-friendly. Sentry uploads require
    // release credentials and should not block simulator/device verification.
    SENTRY_DISABLE_AUTO_UPLOAD: process.env.SENTRY_DISABLE_AUTO_UPLOAD ?? 'true',
    SENTRY_ALLOW_FAILURE: process.env.SENTRY_ALLOW_FAILURE ?? 'true',
    ...extra,
  };
}

function run(cmd, args, options = {}) {
  const result = spawnSync(cmd, args, {
    cwd: options.cwd ?? appRoot,
    env: localEnv(options.env),
    stdio: options.capture ? 'pipe' : 'inherit',
    encoding: 'utf8',
  });

  if (options.capture) {
    return result;
  }

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }

  return result;
}

function findWorkspace() {
  if (!existsSync(iosDir)) {
    return null;
  }

  const workspace = readdirSync(iosDir).find((entry) => entry.endsWith('.xcworkspace'));
  return workspace ? path.join(iosDir, workspace) : null;
}

function readSchemes(workspacePath) {
  if (!workspacePath) {
    return [];
  }

  const result = run(
    'xcodebuild',
    ['-list', '-json', '-workspace', workspacePath],
    { capture: true },
  );

  if (result.status !== 0 || !result.stdout.trim()) {
    return [];
  }

  try {
    const parsed = JSON.parse(result.stdout);
    return parsed?.workspace?.schemes ?? [];
  } catch {
    return [];
  }
}

function selectScheme(workspacePath) {
  const schemes = readSchemes(workspacePath);
  const appScheme = schemes.find((scheme) => !/pods/i.test(scheme));
  return appScheme ?? schemes[0] ?? null;
}

function readAvailableSimulators() {
  const result = run('xcrun', ['simctl', 'list', 'devices', 'available', '-j'], { capture: true });
  if (result.status !== 0 || !result.stdout.trim()) {
    return [];
  }

  try {
    const parsed = JSON.parse(result.stdout);
    return Object.entries(parsed.devices ?? {})
      .flatMap(([runtime, devices]) => devices.map((device) => ({ ...device, runtime })))
      .filter((device) => /iOS/i.test(device.runtime) && /iPhone/i.test(device.name));
  } catch {
    return [];
  }
}

function selectSimulator() {
  const simulators = readAvailableSimulators();
  const preferredNames = [
    process.env.IOS_SIMULATOR,
    'iPhone 17 Pro',
    'iPhone 16 Pro',
    'iPhone 15 Pro',
    'iPhone 17',
    'iPhone 16',
    'iPhone 15',
  ].filter(Boolean);

  return simulators.find((device) => device.state === 'Booted')
    ?? preferredNames.map((name) => simulators.find((device) => device.name === name)).find(Boolean)
    ?? simulators[0]
    ?? null;
}

function destinationArgs() {
  const simulator = selectSimulator();
  if (simulator?.udid) {
    return ['-destination', `platform=iOS Simulator,id=${simulator.udid}`];
  }
  return ['-destination', 'generic/platform=iOS Simulator'];
}

function readPhysicalDevices() {
  const tmpDir = mkdtempSync('/tmp/ondo-devicectl-');
  const jsonPath = path.join(tmpDir, 'devices.json');
  const result = run('xcrun', ['devicectl', 'list', 'devices', '--json-output', jsonPath], { capture: true });
  if (result.status !== 0 || !existsSync(jsonPath)) {
    return [];
  }

  try {
    const parsed = JSON.parse(readFileSync(jsonPath, 'utf8'));
    return (parsed?.result?.devices ?? [])
      .filter((device) => device?.hardwareProperties?.platform === 'iOS')
      .filter((device) => device?.hardwareProperties?.reality === 'physical')
      .map((device) => ({
        name: device.deviceProperties?.name,
        identifier: device.identifier,
        udid: device.hardwareProperties?.udid,
        productType: device.hardwareProperties?.productType,
        marketingName: device.hardwareProperties?.marketingName,
        osVersion: device.deviceProperties?.osVersionNumber,
        developerModeStatus: device.deviceProperties?.developerModeStatus,
        pairingState: device.connectionProperties?.pairingState,
        tunnelState: device.connectionProperties?.tunnelState,
      }));
  } catch {
    return [];
  }
}

function selectPhysicalDevice() {
  const devices = readPhysicalDevices();
  const wanted = process.env.IOS_DEVICE;
  if (wanted) {
    const matched = devices.find((device) => [device.identifier, device.udid, device.name].includes(wanted));
    if (matched) {
      return matched;
    }
  }

  return devices.find((device) => device.tunnelState === 'connected')
    ?? devices.find((device) => device.pairingState === 'paired')
    ?? devices[0]
    ?? null;
}

function physicalDeviceId() {
  const device = selectPhysicalDevice();
  if (!device?.identifier) {
    console.error('No paired physical iPhone found. Connect/unlock the iPhone and tap Trust This Computer.');
    process.exit(1);
  }
  if (device.tunnelState !== 'connected') {
    console.error(`Physical iPhone is paired but not connected for install/launch: ${device.name ?? device.identifier} (tunnelState=${device.tunnelState ?? 'unknown'}). Connect/unlock the iPhone, keep it on Wi-Fi/USB, and make sure Developer Mode + Trust This Computer are enabled.`);
    process.exit(1);
  }
  return device.identifier;
}

function deviceBuildArgs() {
  return ['-destination', 'generic/platform=iOS', '-allowProvisioningUpdates'];
}

function builtAppPath(platform = 'iphoneos') {
  const productDir = path.join(
    iosDir,
    'build',
    'Build',
    'Products',
    platform === 'iphoneos' ? 'Debug-iphoneos' : 'Debug-iphonesimulator',
  );
  const preferred = path.join(productDir, 'app.app');
  if (existsSync(preferred)) {
    return preferred;
  }

  const builtApps = existsSync(productDir)
    ? readdirSync(productDir).filter((entry) => entry.endsWith('.app'))
    : [];
  if (builtApps.length === 1) {
    return path.join(productDir, builtApps[0]);
  }

  return preferred;
}

function bundleIdentifier(appPath) {
  const result = run('/usr/libexec/PlistBuddy', ['-c', 'Print :CFBundleIdentifier', path.join(appPath, 'Info.plist')], { capture: true });
  return result.status === 0 ? result.stdout.trim() : 'com.beyond.fortune';
}

function buildNativeApp(destination, platform) {
  const { workspace, scheme } = ensureWorkspaceAndScheme();
  const args = [
    '-workspace',
    path.relative(appRoot, workspace),
    '-scheme',
    scheme,
    '-configuration',
    'Debug',
    ...destination,
    '-derivedDataPath',
    path.join(iosDir, 'build'),
    'build',
  ];
  run('xcodebuild', args, { cwd: appRoot });
  return builtAppPath(platform);
}

function installOnPhone(appPath) {
  if (!existsSync(appPath)) {
    console.error(`Built app not found: ${appPath}`);
    process.exit(1);
  }
  const device = physicalDeviceId();
  run('xcrun', ['devicectl', 'device', 'install', 'app', '--device', device, appPath, '--timeout', '120']);
  return { device, bundleId: bundleIdentifier(appPath) };
}

function launchOnPhone(bundleId) {
  const device = physicalDeviceId();
  run('xcrun', ['devicectl', 'device', 'process', 'launch', '--device', device, '--terminate-existing', bundleId, '--timeout', '60']);
}

function ensureWorkspaceAndScheme() {
  const workspace = findWorkspace();
  if (!workspace) {
    console.error('No .xcworkspace found. Run `pnpm native:prepare` first.');
    process.exit(1);
  }

  const scheme = selectScheme(workspace);
  if (!scheme) {
    console.error('No iOS scheme found. Open Xcode with `pnpm ios:xcode` and inspect the project.');
    process.exit(1);
  }

  return { workspace, scheme };
}

function ensureIosProject() {
  if (existsSync(iosDir)) {
    return;
  }

  console.log('No ios/ directory found. Generating a local native iOS project with Expo prebuild...');
  run('pnpm', ['exec', 'expo', 'prebuild', '--platform', 'ios', '--no-install']);
}

function ensureRemoteBundleHandler() {
  const appDelegatePath = path.join(iosDir, 'app', 'AppDelegate.swift');
  if (!existsSync(appDelegatePath)) {
    return;
  }

  let source = readFileSync(appDelegatePath, 'utf8');
  if (source.includes('OndoDevBundleURL')) {
    return;
  }

  source = source.replace(
    '  ) -> Bool {\n    let delegate = ReactNativeDelegate()\n',
    '  ) -> Bool {\n    OndoDevBundleURL.store(from: launchOptions)\n\n    let delegate = ReactNativeDelegate()\n',
  );

  source = source.replace(
    '  ) -> Bool {\n    return super.application(app, open: url, options: options) || RCTLinkingManager.application(app, open: url, options: options)\n  }\n',
    '  ) -> Bool {\n    if OndoDevBundleURL.store(from: url) {\n      return true\n    }\n\n    return super.application(app, open: url, options: options) || RCTLinkingManager.application(app, open: url, options: options)\n  }\n',
  );

  source = source.replace(
    `  override func bundleURL() -> URL? {
#if DEBUG
    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: ".expo/.virtual-metro-entry")
#else
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
`,
    `  override func bundleURL() -> URL? {
#if DEBUG
    if let remoteBundleURL = OndoDevBundleURL.current() {
      return remoteBundleURL
    }

    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: ".expo/.virtual-metro-entry")
#else
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}

private enum OndoDevBundleURL {
  private static let defaultsKey = "ondo.remoteMetroBundleURL"
  private static let routeHost = "dev-bundle"

  static func store(from launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
#if DEBUG
    guard let url = launchOptions?[.url] as? URL else {
      return
    }

    _ = store(from: url)
#endif
  }

  static func store(from url: URL) -> Bool {
#if DEBUG
    guard url.host == routeHost else {
      return false
    }

    guard
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let value = components.queryItems?.first(where: { $0.name == "url" })?.value,
      let bundleURL = URL(string: value),
      ["http", "https"].contains(bundleURL.scheme?.lowercased())
    else {
      return false
    }

    UserDefaults.standard.set(bundleURL.absoluteString, forKey: defaultsKey)
    UserDefaults.standard.synchronize()
    return true
#else
    return false
#endif
  }

  static func current() -> URL? {
#if DEBUG
    guard
      let value = UserDefaults.standard.string(forKey: defaultsKey),
      let bundleURL = URL(string: value),
      ["http", "https"].contains(bundleURL.scheme?.lowercased())
    else {
      return nil
    }

    return bundleURL
#else
    return nil
#endif
  }
}
`,
  );

  if (!source.includes('OndoDevBundleURL')) {
    console.error('Failed to patch AppDelegate.swift with the Ondo remote bundle handler. Inspect the generated iOS template before continuing.');
    process.exit(1);
  }

  writeFileSync(appDelegatePath, source);
}

function ensurePodfilePostInstallGuards() {
  const podfilePath = path.join(iosDir, 'Podfile');
  let source = readFileSync(podfilePath, 'utf8');

  if (source.includes('LLAMA_RN_CXX20: Force C++20 on all Pods.')) {
    return;
  }

  const original = `    # LLAMA_RN_CXX20: Force C++20 on all Pods\n    installer.pods_project.targets.each do |target|\n      target.build_configurations.each do |config|\n        config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'gnu++20'\n        config.build_settings['CLANG_CXX_LIBRARY'] = 'libc++'\n        config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '$(inherited) -std=gnu++20'\n      end\n    end\n`;
  const patched = `    minimum_deployment_target = podfile_properties['ios.deploymentTarget'] || '15.1'\n\n    # LLAMA_RN_CXX20: Force C++20 on all Pods.\n    # Also normalize legacy pod targets (for example Sentry's 11.0 default) so\n    # local Xcode simulator builds do not emit unsupported deployment target\n    # warnings on every native smoke test.\n    installer.pods_project.targets.each do |target|\n      target.build_configurations.each do |config|\n        config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'gnu++20'\n        config.build_settings['CLANG_CXX_LIBRARY'] = 'libc++'\n        config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '$(inherited) -std=gnu++20'\n        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = minimum_deployment_target\n      end\n\n      # The EXUpdates resource-generation phase intentionally runs each build.\n      # Mark it as explicitly always out-of-date to match that behavior and\n      # avoid Xcode's dependency-analysis warning.\n      target.shell_script_build_phases.each do |phase|\n        next unless phase.display_name == '[CP-User] Generate updates resources for expo-updates'\n        phase.always_out_of_date = '1' if phase.respond_to?(:always_out_of_date=)\n      end\n    end\n`;

  if (!source.includes(original)) {
    console.error('Could not locate Podfile C++20 post_install block. Inspect the generated Podfile before running pod install.');
    process.exit(1);
  }

  source = source.replace(original, patched);
  writeFileSync(podfilePath, source);
}

function installPods() {
  const podfilePath = path.join(iosDir, 'Podfile');
  if (!existsSync(podfilePath)) {
    console.error('Podfile not found. Run native:prepare first.');
    process.exit(1);
  }

  ensurePodfilePostInstallGuards();

  const bundleResult = spawnSync('bundle', ['exec', 'pod', '--version'], {
    cwd: iosDir,
    stdio: 'ignore',
  });

  if (bundleResult.status === 0) {
    run('bundle', ['exec', 'pod', 'install'], { cwd: iosDir });
    return;
  }

  run('pod', ['install'], { cwd: iosDir });
}

function doctor() {
  const workspace = findWorkspace();
  const schemes = readSchemes(workspace);

  console.log(JSON.stringify({
    appRoot,
    iosDirectoryExists: existsSync(iosDir),
    podfileExists: existsSync(path.join(iosDir, 'Podfile')),
    workspace: workspace ? path.relative(appRoot, workspace) : null,
    schemes,
    selectedScheme: workspace ? selectScheme(workspace) : null,
    selectedSimulator: selectSimulator(),
  }, null, 2));
}

if (command === 'prepare') {
  ensureIosProject();
  ensureRemoteBundleHandler();
  installPods();
  doctor();
} else if (command === 'pods') {
  installPods();
} else if (command === 'open') {
  ensureIosProject();
  ensureRemoteBundleHandler();
  const workspace = findWorkspace();
  if (workspace) {
    run('open', [workspace]);
  } else {
    run('xed', [iosDir]);
  }
} else if (command === 'run') {
  ensureRemoteBundleHandler();
  const { workspace, scheme } = ensureWorkspaceAndScheme();

  run('pnpm', [
    'exec',
    'react-native',
    'run-ios',
    '--workspace',
    path.relative(appRoot, workspace),
    '--scheme',
    scheme,
  ]);
} else if (command === 'build') {
  ensureRemoteBundleHandler();
  buildNativeApp(destinationArgs(), 'iphonesimulator');
} else if (command === 'device-build') {
  ensureRemoteBundleHandler();
  buildNativeApp(deviceBuildArgs(), 'iphoneos');
} else if (command === 'device-install') {
  ensureRemoteBundleHandler();
  const appPath = existsSync(process.argv[3] ?? '') ? process.argv[3] : buildNativeApp(deviceBuildArgs(), 'iphoneos');
  installOnPhone(appPath);
} else if (command === 'device-launch') {
  const appPath = builtAppPath('iphoneos');
  const bundleId = existsSync(appPath) ? bundleIdentifier(appPath) : (process.env.IOS_BUNDLE_ID ?? 'com.beyond.fortune');
  launchOnPhone(bundleId);
} else if (command === 'device-run') {
  ensureRemoteBundleHandler();
  const appPath = buildNativeApp(deviceBuildArgs(), 'iphoneos');
  const { bundleId } = installOnPhone(appPath);
  launchOnPhone(bundleId);
} else if (command === 'doctor') {
  doctor();
} else {
  console.error(`Unknown command: ${command}`);
  console.error('Usage: node scripts/local-ios.mjs [doctor|prepare|pods|open|run|build|device-build|device-install|device-launch|device-run]');
  process.exit(1);
}
