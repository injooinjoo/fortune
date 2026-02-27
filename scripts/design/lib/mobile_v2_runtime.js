#!/usr/bin/env node

const { execSync } = require('child_process');

function shellEscape(value) {
  return `'${String(value).replace(/'/g, `'"'"'`)}'`;
}

function runCommand(cmd, opts = {}) {
  const { allowFail = false } = opts;
  try {
    return execSync(cmd, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
      maxBuffer: 10 * 1024 * 1024,
    }).trim();
  } catch (error) {
    if (allowFail) {
      return String(error.stdout || '').trim();
    }
    const stderr = String(error.stderr || '').trim();
    const stdout = String(error.stdout || '').trim();
    throw new Error(`Command failed: ${cmd}\n${stderr || stdout || error.message}`);
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function parseUiTree(rawJson) {
  try {
    const parsed = JSON.parse(rawJson);
    return Array.isArray(parsed) ? parsed : [];
  } catch (_err) {
    return [];
  }
}

async function getUiTree(udid) {
  const raw = runCommand(`idb ui describe-all --udid ${shellEscape(udid)} --json`, {
    allowFail: true,
  });
  return parseUiTree(raw);
}

function getLabels(nodes) {
  return nodes
    .map((node) => node && node.AXLabel)
    .filter((label) => typeof label === 'string' && label.length > 0);
}

function hasAnyPattern(text, patterns) {
  return patterns.some((pattern) => text.includes(pattern));
}

function nodeCenter(node) {
  const frame = node && node.frame;
  if (!frame) return null;
  const x = Math.floor(Number(frame.x || 0) + Number(frame.width || 0) / 2);
  const y = Math.floor(Number(frame.y || 0) + Number(frame.height || 0) / 2);
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  return { x, y };
}

function findNodeByExactLabel(nodes, label) {
  return nodes.find((node) => node && node.AXLabel === label) || null;
}

function findPopup(nodes, popupPatterns) {
  const labels = getLabels(nodes);
  const popupLabel = labels.find((label) => hasAnyPattern(label, popupPatterns));
  if (!popupLabel) return null;
  const openNode = findNodeByExactLabel(nodes, 'Open');
  const cancelNode = findNodeByExactLabel(nodes, 'Cancel');
  return {
    popupLabel,
    openNode,
    cancelNode,
  };
}

function tap(udid, x, y) {
  runCommand(`idb ui tap --udid ${shellEscape(udid)} ${x} ${y}`, { allowFail: true });
}

async function dismissOpenPromptIfPresent(udid, popupPatterns, maxTries = 3) {
  const events = [];

  for (let i = 0; i < maxTries; i += 1) {
    const nodes = await getUiTree(udid);
    const popup = findPopup(nodes, popupPatterns);
    if (!popup) {
      return {
        detected: events.length > 0,
        handled: events.some((event) => event.action === 'tap_open'),
        attempts: events,
      };
    }

    const event = {
      index: i + 1,
      popup_label: popup.popupLabel,
      action: 'no_open_button',
      point: null,
    };

    const center = popup.openNode ? nodeCenter(popup.openNode) : null;
    if (center) {
      tap(udid, center.x, center.y);
      event.action = 'tap_open';
      event.point = center;
      await sleep(800);
    }

    events.push(event);
  }

  return {
    detected: events.length > 0,
    handled: events.some((event) => event.action === 'tap_open'),
    attempts: events,
  };
}

function routeToScreenValue(routePath) {
  return String(routePath).replace(/^\//, '');
}

async function openRouteByDeepLink({ udid, appScheme, appHost, routePath, popupPatterns, waitMs }) {
  const screen = routeToScreenValue(routePath);
  const uri = `${appScheme}://${appHost}?screen=${encodeURIComponent(screen)}`;
  runCommand(`xcrun simctl openurl ${shellEscape(udid)} ${shellEscape(uri)}`, { allowFail: true });
  await sleep(waitMs);
  const popup = await dismissOpenPromptIfPresent(udid, popupPatterns);
  await sleep(waitMs);
  const nodes = await getUiTree(udid);
  return {
    uri,
    popup,
    nodes,
  };
}

function evaluateQuality({ nodes, errorPatterns, popupPatterns }) {
  const issues = [];
  const labels = getLabels(nodes);

  if (nodes.length === 0) {
    issues.push('empty_accessibility_tree');
  }

  if (labels.length < 2) {
    issues.push('insufficient_accessibility_labels');
  }

  const errorLabel = labels.find((label) => hasAnyPattern(label, errorPatterns));
  if (errorLabel) {
    issues.push(`error_pattern_detected:${errorLabel}`);
  }

  const popupLabel = labels.find((label) => hasAnyPattern(label, popupPatterns));
  if (popupLabel) {
    issues.push(`popup_visible:${popupLabel}`);
  }

  return {
    ok: issues.length === 0,
    issues,
    label_count: labels.length,
    top_labels: Array.from(new Set(labels)).slice(0, 20),
  };
}

function parseChatCardLabel(label) {
  const lines = String(label)
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);

  if (lines.length < 2) {
    return null;
  }

  return {
    name: lines[0],
    category: lines[1],
    secondary: lines[2] || '',
    lines,
  };
}

function categoryKeywords(category) {
  const map = {
    라이프: ['라이프', '일일운세', '힐링', '일상'],
    전통: ['전통', '사주', '명리학'],
    별자리: ['별자리', '점성술', '띠'],
    심리: ['심리', 'mbti', '성격'],
    연애: ['연애', '궁합', '남자친구', '여자친구', '사랑'],
    재물: ['재물', '투자', '직업', '사업'],
    행운: ['행운', '럭키', '아이템'],
    스포츠: ['스포츠', '운동', '피트니스'],
    풍수: ['풍수', '인테리어', '이사'],
    타로: ['타로', '해몽', '미스터리'],
  };
  return map[category] || [category];
}

function findChatRepresentativeNode(nodes, representative) {
  const labels = nodes
    .map((node) => ({ node, label: node && node.AXLabel }))
    .filter((item) => typeof item.label === 'string' && item.label.length > 0);

  const exactNode = labels.find((item) => item.label === representative.name);
  if (exactNode) {
    return {
      node: exactNode.node,
      matched_name: representative.name,
      matched_category: representative.category,
      method: 'exact_label',
    };
  }

  const cardExact = labels
    .map((item) => ({ ...item, card: parseChatCardLabel(item.label) }))
    .find((item) => item.card && item.card.name === representative.name);

  if (cardExact) {
    return {
      node: cardExact.node,
      matched_name: cardExact.card.name,
      matched_category: cardExact.card.category,
      method: 'card_name',
    };
  }

  const categoryFallback = labels
    .map((item) => ({ ...item, card: parseChatCardLabel(item.label) }))
    .find((item) => item.card && item.card.category.includes(representative.category));

  if (categoryFallback) {
    return {
      node: categoryFallback.node,
      matched_name: categoryFallback.card.name,
      matched_category: categoryFallback.card.category,
      method: 'category_fallback',
    };
  }

  const keywords = categoryKeywords(representative.category).map((keyword) => keyword.toLowerCase());
  const keywordFallback = labels
    .map((item) => ({ ...item, card: parseChatCardLabel(item.label) }))
    .find((item) => {
      if (!item.card) return false;
      const haystack = [item.card.category, item.card.secondary, item.label].join(' ').toLowerCase();
      return keywords.some((keyword) => haystack.includes(keyword));
    });

  if (keywordFallback) {
    return {
      node: keywordFallback.node,
      matched_name: keywordFallback.card.name,
      matched_category: keywordFallback.card.category,
      method: 'keyword_fallback',
    };
  }

  const firstCard = labels
    .map((item) => ({ ...item, card: parseChatCardLabel(item.label) }))
    .find((item) => item.card);

  if (firstCard) {
    return {
      node: firstCard.node,
      matched_name: firstCard.card.name,
      matched_category: firstCard.card.category,
      method: 'first_card_fallback',
    };
  }

  return null;
}

async function openChatRepresentative({ udid, appScheme, appHost, representative, popupPatterns, waitMs }) {
  const chatNav = await openRouteByDeepLink({
    udid,
    appScheme,
    appHost,
    routePath: '/chat',
    popupPatterns,
    waitMs,
  });

  const target = findChatRepresentativeNode(chatNav.nodes, representative);
  if (!target) {
    return {
      nav: chatNav,
      target: null,
      nodes: chatNav.nodes,
    };
  }

  const center = nodeCenter(target.node);
  if (!center) {
    return {
      nav: chatNav,
      target: {
        ...target,
        tap_result: 'invalid_frame',
        point: null,
      },
      nodes: chatNav.nodes,
    };
  }

  tap(udid, center.x, center.y);
  await sleep(waitMs);

  const prompt = await dismissOpenPromptIfPresent(udid, popupPatterns);
  if (prompt.detected) {
    await sleep(waitMs);
  }

  const nodesAfterTap = await getUiTree(udid);
  return {
    nav: chatNav,
    target: {
      ...target,
      tap_result: 'tapped',
      point: center,
      prompt,
    },
    nodes: nodesAfterTap,
  };
}

function detectBootedUdid() {
  const raw = runCommand('xcrun simctl list devices booted', { allowFail: true });
  const iPhoneMatch = raw.match(/iPhone[^\n]*\(([0-9A-F-]{36})\) \(Booted\)/);
  if (iPhoneMatch) {
    return iPhoneMatch[1];
  }
  const anyMatch = raw.match(/\(([0-9A-F-]{36})\) \(Booted\)/);
  return anyMatch ? anyMatch[1] : '';
}

module.exports = {
  runCommand,
  sleep,
  getUiTree,
  getLabels,
  evaluateQuality,
  openRouteByDeepLink,
  openChatRepresentative,
  findChatRepresentativeNode,
  dismissOpenPromptIfPresent,
  routeToScreenValue,
  detectBootedUdid,
};
