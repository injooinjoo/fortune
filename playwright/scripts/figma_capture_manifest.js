const PAGE_LAYER_NAMES = Object.freeze({
  '00-cover-governance': 'section__00__cover_governance',
  '10-entry-auth-onboarding': 'section__10__entry_auth_onboarding',
  '20-chat-home-character': 'section__20__chat_character',
  '80-admin-policy-utility': 'section__80__admin_policy_utility',
  '90-components': 'section__90__components',
  '99-archive': 'section__99__archive',
});

const CATALOG_LAYER_ROLES = Object.freeze({
  content: 'content',
  header: 'header',
  overview: 'overview',
  screenGrid: 'screen_grid',
  componentGrid: 'component_grid',
  archiveGrid: 'archive_grid',
  navLinks: 'nav_links',
  deviceFrame: 'device_frame',
});

const SCREEN_META_LAYER_NAMES = Object.freeze({
  route: 'meta__route',
  source: 'meta__source',
  note: 'meta__note',
  blocker: 'meta__blocker',
});

const STATUS_BADGE_LAYER_NAMES = Object.freeze({
  live: 'badge__live_capture',
  placeholder: 'badge__placeholder_spec',
});

const IPHONE_15_PRO = Object.freeze({
  name: 'iPhone 15 Pro',
  width: 393,
  height: 852,
  scale: 3,
});

function slugifyLayerName(value) {
  return String(value)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .replace(/_+/g, '_');
}

function getPageLayoutLayerNames(pageKey) {
  const base = {
    content: CATALOG_LAYER_ROLES.content,
    header: CATALOG_LAYER_ROLES.header,
  };

  if (pageKey === '00-cover-governance') {
    return {
      ...base,
      overview: CATALOG_LAYER_ROLES.overview,
      navLinks: CATALOG_LAYER_ROLES.navLinks,
    };
  }

  if (pageKey === '90-components') {
    return {
      ...base,
      grid: CATALOG_LAYER_ROLES.componentGrid,
    };
  }

  if (pageKey === '99-archive') {
    return {
      ...base,
      grid: CATALOG_LAYER_ROLES.archiveGrid,
    };
  }

  return {
    ...base,
    grid: CATALOG_LAYER_ROLES.screenGrid,
  };
}

function withPageLayerContract(page) {
  return {
    ...page,
    layerName: PAGE_LAYER_NAMES[page.key],
    layoutLayerNames: getPageLayoutLayerNames(page.key),
  };
}

function withScreenLayerContract(screen) {
  return {
    ...screen,
    cardLayerName: `screen_card__${screen.id}`,
    previewLayerName: `preview__${screen.id}`,
    statusBadgeName:
      STATUS_BADGE_LAYER_NAMES[screen.status] || `badge__${screen.status}`,
    metaLayerNames: {
      ...SCREEN_META_LAYER_NAMES,
    },
  };
}

function withComponentLayerContract(card) {
  return {
    ...card,
    groupLayerName: `component_group__${slugifyLayerName(card.title)}`,
  };
}

const FIGMA_PAGES = [
  {
    key: '00-cover-governance',
    name: '00 Cover & Governance',
    description: 'Catalog governance, retained-surface summary, and manual delete instructions.',
  },
  {
    key: '10-entry-auth-onboarding',
    name: '10 Entry / Auth / Onboarding',
    description: 'Entry routes and onboarding flows that still exist in runtime.',
  },
  {
    key: '20-chat-home-character',
    name: '20 Chat Home / Character',
    description: 'The surviving chat shell, the two in-chat experiences, and character conversation states.',
  },
  {
    key: '80-admin-policy-utility',
    name: '80 Admin / Policy / Utility',
    description: 'Premium, policy pages, and account management screens.',
  },
  {
    key: '90-components',
    name: '90 Components',
    description: 'Component inventory for the retained chat/policy product.',
  },
  {
    key: '99-archive',
    name: '99 Archive',
    description: 'Removed product groups and historical references.',
  },
].map(withPageLayerContract);

const SCREENS = [
  {
    id: 'auth__splash__default',
    pageKey: '10-entry-auth-onboarding',
    title: 'Splash',
    frameName: 'Splash',
    routeHash: '#/splash',
    status: 'live',
    note: 'Initial redirect surface before auth or chat resolution.',
    sources: [
      'lib/routes/routes/auth_routes.dart',
      'lib/routes/route_config.dart',
    ],
  },
  {
    id: 'auth__signup__default',
    pageKey: '10-entry-auth-onboarding',
    title: 'Signup',
    frameName: 'Signup',
    routeHash: '#/signup',
    status: 'live',
    sources: [
      'lib/routes/routes/auth_routes.dart',
      'lib/screens/auth/signup_screen.dart',
    ],
  },
  {
    id: 'onboarding__profile__default',
    pageKey: '10-entry-auth-onboarding',
    title: 'Onboarding',
    frameName: 'Onboarding',
    routeHash: '#/onboarding',
    status: 'live',
    sources: [
      'lib/routes/routes/auth_routes.dart',
      'lib/screens/onboarding/onboarding_page.dart',
    ],
  },
  {
    id: 'onboarding__toss_style__default',
    pageKey: '10-entry-auth-onboarding',
    title: 'Onboarding Toss Style',
    frameName: 'Onboarding Toss Style',
    routeHash: '#/onboarding/toss-style',
    status: 'live',
    sources: [
      'lib/routes/route_config.dart',
      'lib/screens/onboarding/onboarding_page.dart',
    ],
  },
  {
    id: 'chat__home__default',
    pageKey: '20-chat-home-character',
    title: 'Chat Home',
    frameName: 'Chat Home',
    routeHash: '#/chat',
    status: 'live',
    sources: [
      'lib/routes/route_config.dart',
      'lib/features/character/presentation/pages/swipe_home_shell.dart',
      'lib/features/character/presentation/pages/character_list_panel.dart',
    ],
  },
  {
    id: 'chat__home__general_default',
    pageKey: '20-chat-home-character',
    title: 'General Chat Home',
    frameName: 'General Chat Home',
    routeHash: '#/chat',
    status: 'placeholder',
    triage: 'capture_next_runtime',
    blocker:
      'Needs a deterministic Story-tab capture so the official catalog can distinguish 일반 채팅 from the shared /chat shell.',
    note: 'User-facing 일반 채팅 home state inside /chat. This is not a standalone route.',
    sources: [
      'lib/features/character/presentation/pages/swipe_home_shell.dart',
      'lib/features/character/presentation/pages/character_list_panel.dart',
    ],
  },
  {
    id: 'chat__home__curiosity_default',
    pageKey: '20-chat-home-character',
    title: 'Curiosity Home',
    frameName: 'Curiosity Home',
    routeHash: '#/chat',
    status: 'placeholder',
    triage: 'capture_next_runtime',
    blocker:
      'Needs a deterministic Fortune-tab capture so the official catalog can distinguish 호기심 from the shared /chat shell.',
    note: 'User-facing 호기심 home state inside /chat. This is not a standalone route.',
    sources: [
      'lib/features/character/presentation/pages/swipe_home_shell.dart',
      'lib/features/character/presentation/pages/character_list_panel.dart',
    ],
  },
  {
    id: 'chat__character__luts',
    pageKey: '20-chat-home-character',
    title: 'Character Chat',
    frameName: 'Character Chat',
    routeHash: '#/chat?openCharacterChat=true&characterId=luts',
    status: 'live',
    note: 'Deep-linked chat overlay on the retained chat shell.',
    sources: [
      'lib/features/character/presentation/pages/swipe_home_shell.dart',
      'lib/features/character/presentation/pages/character_chat_panel.dart',
      'lib/features/character/presentation/providers/character_chat_provider.dart',
    ],
  },
  {
    id: 'chat__survey__fortune_step',
    pageKey: '20-chat-home-character',
    title: 'Curiosity Survey Step',
    frameName: 'Curiosity Survey Step',
    routeHash: '#/chat?fortuneType=daily',
    status: 'placeholder',
    triage: 'capture_next_runtime',
    blocker:
      'Requires deterministic expert launch plus an active in-chat survey step before capture.',
    note: 'Single-step survey UI shown inside the 호기심 chat flow.',
    sources: [
      'lib/features/character/presentation/pages/character_chat_panel.dart',
      'lib/features/character/presentation/providers/character_chat_survey_provider.dart',
      'lib/features/chat/domain/configs/survey_configs.dart',
    ],
  },
  {
    id: 'chat__result__fortune_complete',
    pageKey: '20-chat-home-character',
    title: 'Curiosity Result Complete',
    frameName: 'Curiosity Result Complete',
    routeHash: '#/chat?fortuneType=daily',
    status: 'placeholder',
    triage: 'capture_next_runtime',
    blocker:
      'Needs seeded survey answers and a deterministic result payload to capture the completed 호기심 state.',
    note: 'Completed insight result rendered back into the chat stream with embedded result components.',
    sources: [
      'lib/features/character/presentation/pages/character_chat_panel.dart',
      'lib/features/character/presentation/widgets/embedded_fortune_component.dart',
      'lib/features/chat/presentation/widgets/chat_saju_result_card.dart',
    ],
  },
  {
    id: 'character__profile__luts',
    pageKey: '20-chat-home-character',
    title: 'Character Profile',
    frameName: 'Character Profile',
    routeHash: '#/character/luts',
    status: 'live',
    sources: [
      'lib/routes/character_routes.dart',
      'lib/features/character/presentation/pages/character_profile_page.dart',
    ],
  },
  {
    id: 'chat__onboarding__character_intro',
    pageKey: '20-chat-home-character',
    title: 'Character Chat Onboarding',
    frameName: 'Character Chat Onboarding',
    routeHash: '#/chat',
    status: 'placeholder',
    triage: 'capture_next_runtime',
    blocker:
      'Shown only on first-run state and currently needs storage overrides to capture reliably.',
    note: 'Three-slide onboarding shown before the first /chat session.',
    sources: [
      'lib/features/character/presentation/pages/swipe_home_shell.dart',
      'lib/features/character/presentation/pages/character_onboarding_page.dart',
      'lib/services/storage_service.dart',
    ],
  },
  {
    id: 'chat__profile_sheet__default',
    pageKey: '20-chat-home-character',
    title: 'Chat Account Sheet',
    frameName: 'Chat Account Sheet',
    status: 'placeholder',
    triage: 'capture_next_runtime',
    blocker: 'Bottom-sheet runtime state needs an opened chat session to capture reliably.',
    note: 'Sheet contains only auth status, privacy policy, terms, account deletion, and logout.',
    sources: [
      'lib/features/chat/presentation/widgets/profile_bottom_sheet.dart',
    ],
  },
  {
    id: 'premium__insight__default',
    pageKey: '80-admin-policy-utility',
    title: 'Premium Insight',
    frameName: 'Premium Insight',
    routeHash: '#/premium',
    status: 'placeholder',
    triage: 'capture_next_runtime',
    blocker:
      'Current catalog has no live premium capture yet even though /premium is a retained route.',
    note: 'Premium entry surface for 프리미엄 사주 and deep-link launch into the chat flow.',
    sources: [
      'lib/routes/route_config.dart',
      'lib/screens/premium/premium_screen.dart',
      'lib/features/character/presentation/utils/fortune_chat_navigation.dart',
    ],
  },
  {
    id: 'policy__privacy__default',
    pageKey: '80-admin-policy-utility',
    title: 'Privacy Policy',
    frameName: 'Privacy Policy',
    routeHash: '#/privacy-policy',
    status: 'live',
    sources: [
      'lib/routes/route_config.dart',
      'lib/features/policy/presentation/pages/privacy_policy_page.dart',
    ],
  },
  {
    id: 'policy__terms__default',
    pageKey: '80-admin-policy-utility',
    title: 'Terms Of Service',
    frameName: 'Terms Of Service',
    routeHash: '#/terms-of-service',
    status: 'live',
    sources: [
      'lib/routes/route_config.dart',
      'lib/features/policy/presentation/pages/terms_of_service_page.dart',
    ],
  },
  {
    id: 'account__deletion__auth_gated',
    pageKey: '80-admin-policy-utility',
    title: 'Account Deletion',
    frameName: 'Account Deletion',
    routeHash: '#/account-deletion',
    status: 'placeholder',
    triage: 'capture_next_auth',
    blocker: 'Requires an authenticated session to exercise the destructive flow.',
    sources: [
      'lib/routes/route_config.dart',
      'lib/screens/profile/account_deletion_page.dart',
    ],
  },
].map(withScreenLayerContract);

const COMPONENT_CARDS = [
  {
    title: 'Chat Shell and Headers',
    sources: [
      'lib/features/character/presentation/pages/swipe_home_shell.dart',
      'lib/features/character/presentation/pages/character_list_panel.dart',
      'lib/shared/components/app_header.dart',
    ],
  },
  {
    title: 'Character Entry and Onboarding',
    sources: [
      'lib/features/character/presentation/pages/swipe_home_shell.dart',
      'lib/features/character/presentation/pages/character_onboarding_page.dart',
      'lib/services/storage_service.dart',
    ],
  },
  {
    title: 'Conversation, Survey, and Result Blocks',
    sources: [
      'lib/features/character/presentation/pages/character_chat_panel.dart',
      'lib/features/character/presentation/widgets/character_message_bubble.dart',
      'lib/features/chat/presentation/widgets/survey/chat_survey_chips.dart',
      'lib/features/chat/presentation/widgets/chat_saju_result_card.dart',
      'lib/features/character/presentation/widgets/embedded_fortune_component.dart',
      'lib/shared/components/section_header.dart',
    ],
  },
  {
    title: 'Account, Premium, and Policy Controls',
    sources: [
      'lib/features/chat/presentation/widgets/profile_bottom_sheet.dart',
      'lib/screens/premium/premium_screen.dart',
      'lib/screens/profile/account_deletion_page.dart',
      'lib/shared/components/settings_list_tile.dart',
    ],
  },
  {
    title: 'Design System Core',
    sources: [
      'lib/core/design_system/components/ds_card.dart',
      'lib/core/design_system/components/ds_button.dart',
      'lib/core/design_system/components/ds_text_field.dart',
      'lib/core/widgets/unified_button.dart',
    ],
  },
].map(withComponentLayerContract);

function getScreensByPage() {
  return FIGMA_PAGES.map((page) => ({
    ...page,
    screens: SCREENS.filter((screen) => screen.pageKey === page.key),
  }));
}

function getStatusCounts() {
  return SCREENS.reduce(
    (acc, screen) => {
      acc[screen.status] = (acc[screen.status] || 0) + 1;
      return acc;
    },
    {}
  );
}

function getPlaceholderTriageCounts() {
  return SCREENS.filter((screen) => screen.status === 'placeholder').reduce(
    (acc, screen) => {
      const triageKey = screen.triage || 'unclassified';
      acc[triageKey] = (acc[triageKey] || 0) + 1;
      return acc;
    },
    {}
  );
}

module.exports = {
  CATALOG_LAYER_ROLES,
  COMPONENT_CARDS,
  FIGMA_PAGES,
  IPHONE_15_PRO,
  PAGE_LAYER_NAMES,
  SCREENS,
  SCREEN_META_LAYER_NAMES,
  STATUS_BADGE_LAYER_NAMES,
  getPlaceholderTriageCounts,
  getScreensByPage,
  getStatusCounts,
};
