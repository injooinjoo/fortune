#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const {
  detectBootedUdid,
  openRouteByDeepLink,
  openChatRepresentative,
  evaluateQuality,
} = require('./lib/mobile_v2_runtime');

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const [rawKey, rawValue] = token.split('=');
    const key = rawKey.slice(2);
    if (rawValue !== undefined) {
      args[key] = rawValue;
      continue;
    }
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      args[key] = 'true';
      continue;
    }
    args[key] = next;
    i += 1;
  }
  return args;
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, payload) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, `${JSON.stringify(payload, null, 2)}\n`);
}

function normalizeReason(issues) {
  if (!issues || issues.length === 0) return null;
  return issues[0];
}

function buildLegacyMapping({ legacyManifestPath, routeSurfaces, chatRepresentatives }) {
  if (!fs.existsSync(legacyManifestPath)) {
    return {
      generated_at: new Date().toISOString(),
      source: legacyManifestPath,
      entries: [],
      summary: {
        total: 0,
        kept: 0,
        replaced: 0,
        excluded: 0,
      },
      note: 'legacy manifest not found',
    };
  }

  const legacyManifest = loadJson(legacyManifestPath);
  const routeByPath = new Map(routeSurfaces.map((surface) => [surface.path, surface.id]));
  const repById = new Map(chatRepresentatives.map((rep) => [rep.id, rep]));

  const categoryReplacement = {
    auth: 'route_chat',
    home: 'route_chat',
    profile: 'route_profile',
    fortune_traditional: 'chat_rep_muhyeon_dosa',
    fortune_basic: 'chat_rep_haneul',
    fortune_love: 'chat_rep_rose',
    fortune_career: 'chat_rep_james_kim',
    fortune_time: 'chat_rep_haneul',
    fortune_special: 'chat_rep_lucky',
  };

  const entries = (legacyManifest.screens || []).map((screen) => {
    const routeId = routeByPath.get(screen.path);
    if (routeId) {
      return {
        legacy_screen_id: screen.screen_id,
        legacy_path: screen.path,
        status: 'kept',
        replacement_surface_id: routeId,
        reason: 'active_route_exists_in_chat_first_v2',
      };
    }

    const replacementId = categoryReplacement[screen.category];
    if (replacementId) {
      const replacementRep = repById.get(replacementId);
      const reason = replacementRep
        ? `legacy_route_removed_represented_by_chat_category:${replacementRep.category}`
        : `legacy_route_removed_represented_by_surface:${replacementId}`;
      return {
        legacy_screen_id: screen.screen_id,
        legacy_path: screen.path,
        status: 'replaced',
        replacement_surface_id: replacementId,
        reason,
      };
    }

    return {
      legacy_screen_id: screen.screen_id,
      legacy_path: screen.path,
      status: 'excluded',
      replacement_surface_id: null,
      reason: 'no_live_route_or_category_replacement_in_chat_first_v2',
    };
  });

  const summary = {
    total: entries.length,
    kept: entries.filter((entry) => entry.status === 'kept').length,
    replaced: entries.filter((entry) => entry.status === 'replaced').length,
    excluded: entries.filter((entry) => entry.status === 'excluded').length,
  };

  return {
    generated_at: new Date().toISOString(),
    source: legacyManifestPath,
    entries,
    summary,
  };
}

async function inspectRouteSurface({ udid, config, route, waitMs }) {
  const nav = await openRouteByDeepLink({
    udid,
    appScheme: config.appScheme,
    appHost: config.appHost,
    routePath: route.path,
    popupPatterns: config.popupPatterns || [],
    waitMs,
  });

  const quality = evaluateQuality({
    nodes: nav.nodes,
    errorPatterns: config.errorPatterns || [],
    popupPatterns: config.popupPatterns || [],
  });

  return {
    surface_id: route.id,
    surface_type: 'route',
    label: route.label,
    route_path: route.path,
    inventory_status: quality.ok ? 'reachable' : 'blocked',
    blocked_reason: quality.ok ? null : normalizeReason(quality.issues),
    issues: quality.issues,
    top_labels: quality.top_labels,
    label_count: quality.label_count,
    popup_detected: nav.popup.detected,
    popup_handled: nav.popup.handled,
    deeplink_uri: nav.uri,
  };
}

async function inspectChatRepresentative({ udid, config, rep, waitMs }) {
  const result = await openChatRepresentative({
    udid,
    appScheme: config.appScheme,
    appHost: config.appHost,
    representative: rep,
    popupPatterns: config.popupPatterns || [],
    waitMs,
  });

  if (!result.target) {
    return {
      surface_id: rep.id,
      surface_type: 'chat_rep',
      label: rep.name,
      representative_name: rep.name,
      representative_category: rep.category,
      inventory_status: 'blocked',
      blocked_reason: 'chat_rep_not_found_on_chat_list',
      issues: ['chat_rep_not_found_on_chat_list'],
      top_labels: (result.nav && evaluateQuality({
        nodes: result.nav.nodes,
        errorPatterns: config.errorPatterns || [],
        popupPatterns: config.popupPatterns || [],
      }).top_labels) || [],
      label_count: result.nav ? result.nav.nodes.length : 0,
      popup_detected: result.nav ? result.nav.popup.detected : false,
      popup_handled: result.nav ? result.nav.popup.handled : false,
      deeplink_uri: result.nav ? result.nav.uri : null,
      matched_name: null,
      matched_category: null,
      selection_method: null,
    };
  }

  const quality = evaluateQuality({
    nodes: result.nodes,
    errorPatterns: config.errorPatterns || [],
    popupPatterns: config.popupPatterns || [],
  });

  return {
    surface_id: rep.id,
    surface_type: 'chat_rep',
    label: rep.name,
    representative_name: rep.name,
    representative_category: rep.category,
    inventory_status: quality.ok ? 'reachable' : 'blocked',
    blocked_reason: quality.ok ? null : normalizeReason(quality.issues),
    issues: quality.issues,
    top_labels: quality.top_labels,
    label_count: quality.label_count,
    popup_detected: result.nav.popup.detected || (result.target.prompt && result.target.prompt.detected) || false,
    popup_handled: result.nav.popup.handled || (result.target.prompt && result.target.prompt.handled) || false,
    deeplink_uri: result.nav.uri,
    matched_name: result.target.matched_name,
    matched_category: result.target.matched_category,
    selection_method: result.target.method,
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const repoRoot = path.resolve(__dirname, '..', '..');
  const configPath = path.resolve(args.config || path.join(__dirname, 'config/mobile_v2_surfaces.json'));
  const outPath = path.resolve(args.out || path.join(repoRoot, 'artifacts/design/mobile/v2/live_inventory.json'));
  const mappingOutPath = path.resolve(args['old61-out'] || path.join(repoRoot, 'artifacts/design/mobile/v2/old61_mapping.json'));
  const waitMs = Number(args['wait-ms'] || '1200');

  const config = loadJson(configPath);
  const udid = args.udid || detectBootedUdid();
  if (!udid) {
    throw new Error('No booted simulator UDID detected. Pass --udid explicitly.');
  }

  const surfaces = [];

  for (const route of config.routeSurfaces || []) {
    // eslint-disable-next-line no-await-in-loop
    const inspected = await inspectRouteSurface({ udid, config, route, waitMs });
    surfaces.push(inspected);
  }

  for (const rep of config.chatRepresentatives || []) {
    // eslint-disable-next-line no-await-in-loop
    const inspected = await inspectChatRepresentative({ udid, config, rep, waitMs });
    surfaces.push(inspected);
  }

  const summary = {
    total: surfaces.length,
    reachable: surfaces.filter((item) => item.inventory_status === 'reachable').length,
    blocked: surfaces.filter((item) => item.inventory_status === 'blocked').length,
    by_type: {
      route: surfaces.filter((item) => item.surface_type === 'route').length,
      chat_rep: surfaces.filter((item) => item.surface_type === 'chat_rep').length,
    },
    reachable_by_type: {
      route: surfaces.filter((item) => item.surface_type === 'route' && item.inventory_status === 'reachable').length,
      chat_rep: surfaces.filter((item) => item.surface_type === 'chat_rep' && item.inventory_status === 'reachable').length,
    },
  };

  const payload = {
    generated_at: new Date().toISOString(),
    udid,
    config_path: configPath,
    wait_ms: waitMs,
    summary,
    surfaces,
  };

  writeJson(outPath, payload);

  const legacyManifestPath = path.join(repoRoot, 'artifacts/design/mobile/manifest.json');
  const mapping = buildLegacyMapping({
    legacyManifestPath,
    routeSurfaces: config.routeSurfaces || [],
    chatRepresentatives: config.chatRepresentatives || [],
  });
  writeJson(mappingOutPath, mapping);

  process.stdout.write(`${JSON.stringify({ out: outPath, old61: mappingOutPath, summary }, null, 2)}\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exit(1);
});
