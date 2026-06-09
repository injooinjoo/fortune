#!/usr/bin/env node
import { spawn } from 'node:child_process';

const port = process.env.RN_METRO_PORT ?? '8081';
const bundleRoot = process.env.ONDO_BUNDLE_ROOT ?? '.expo/.virtual-metro-entry';
const appScheme = process.env.ONDO_DEV_URL_SCHEME ?? 'com.beyond.fortune';
const children = [];
let printed = false;

function start(name, command, args) {
  const child = spawn(command, args, {
    cwd: new URL('..', import.meta.url),
    env: {
      ...process.env,
      EXPO_NO_TELEMETRY: '1',
      RCT_METRO_PORT: port,
    },
    stdio: ['ignore', 'pipe', 'pipe'],
  });

  children.push(child);

  child.stdout.on('data', (data) => handleOutput(name, data));
  child.stderr.on('data', (data) => handleOutput(name, data));
  child.on('exit', (code, signal) => {
    if (signal) {
      return;
    }
    console.error(`[${name}] exited with code ${code}`);
    stopAll(code ?? 1);
  });

  return child;
}

function handleOutput(name, data) {
  const text = data.toString();
  process.stdout.write(text.replace(/^/gm, `[${name}] `));

  if (name !== 'cloudflared' || printed) {
    return;
  }

  const match = text.match(/https:\/\/[-a-z0-9]+\.trycloudflare\.com/i);
  if (!match) {
    return;
  }

  printed = true;
  const publicBaseURL = match[0];
  const bundleURL = `${publicBaseURL}/${bundleRoot}.bundle?platform=ios&dev=true&minify=false`;
  const openURL = `${appScheme}://dev-bundle?url=${encodeURIComponent(bundleURL)}`;

  console.log('\n=== Ondo remote native iOS testing ===');
  console.log(`Metro tunnel: ${publicBaseURL}`);
  console.log(`Bundle URL:   ${bundleURL}`);
  console.log(`iPhone link:  ${openURL}`);
  console.log('How to test from any network/region:');
  console.log('1. Install a Debug native build once: pnpm rn:native:device:run');
  console.log('2. Send/open the iPhone link on that phone.');
  console.log('3. Fully quit Ondo and reopen it. The Debug app will load JS through this tunnel.');
  console.log('4. Keep this terminal running while testing. Ctrl-C closes the tunnel.');
  console.log('======================================\n');
}

function stopAll(code = 0) {
  for (const child of children) {
    if (!child.killed) {
      child.kill('SIGTERM');
    }
  }
  process.exit(code);
}

process.on('SIGINT', () => stopAll(0));
process.on('SIGTERM', () => stopAll(0));

start('metro', 'pnpm', ['exec', 'expo', 'start', '--dev-client', '--localhost', '--port', port]);
start('cloudflared', 'cloudflared', ['tunnel', '--url', `http://127.0.0.1:${port}`, '--no-autoupdate']);
