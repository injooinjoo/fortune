// Service Worker for ZPZG
const CACHE_NAME = 'zpzg-web-v1';
const DYNAMIC_CACHE = 'fortune-dynamic-v1';

// Assets to cache on install
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter.js',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
];

// API endpoints to cache
const API_CACHE_PATTERNS = [
  /\/fortune-personality-unified\//,
  /\/user_profiles\//,
  /\/personality_fortune_cache\//,
];

// Cache duration in milliseconds
const CACHE_DURATION = {
  api: 24 * 60 * 60 * 1000, // 24 hours
  assets: 7 * 24 * 60 * 60 * 1000, // 7 days
};

// Install event - cache static assets
self.addEventListener('install', (event) => {
  console.log('[SW] Installing service worker...');
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW] Caching static assets');
      return cache.addAll(STATIC_ASSETS);
    })
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating service worker...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME && name !== DYNAMIC_CACHE)
          .map((name) => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});

// Fetch event - serve from cache or network
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  // Handle API requests
  if (API_CACHE_PATTERNS.some((pattern) => pattern.test(url.pathname))) {
    event.respondWith(handleApiRequest(request));
    return;
  }

  // Handle static assets
  event.respondWith(handleAssetRequest(request));
});

// Handle API requests with network-first strategy
async function handleApiRequest(request) {
  try {
    // Try network first
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      // Clone the response before caching
      const responseToCache = networkResponse.clone();
      
      // Cache the response
      const cache = await caches.open(DYNAMIC_CACHE);
      cache.put(request, responseToCache);
      
      return networkResponse;
    }
    
    // If network fails, try cache
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      // Check if cache is still valid
      const cachedDate = new Date(cachedResponse.headers.get('date'));
      const age = Date.now() - cachedDate.getTime();
      
      if (age < CACHE_DURATION.api) {
        console.log('[SW] Serving API from cache:', request.url);
        return cachedResponse;
      }
    }
    
    return networkResponse;
  } catch (error) {
    console.log('[SW] Network request failed, trying cache:', error);
    
    // If network fails, try cache
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // Return offline response
    return new Response(
      JSON.stringify({
        error: 'Offline',
        message: '오프라인 상태입니다. 인터넷 연결을 확인해주세요.',
      }),
      {
        status: 503,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
}

// Handle static assets with cache-first strategy
async function handleAssetRequest(request) {
  try {
    // Check cache first
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      // Update cache in background
      fetchAndCache(request);
      return cachedResponse;
    }
    
    // If not in cache, fetch from network
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      // Cache the response
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    console.log('[SW] Failed to fetch asset:', error);
    
    // Return cached version if available
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // Return offline page
    return caches.match('/');
  }
}

// Fetch and cache in background
async function fetchAndCache(request) {
  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, networkResponse);
    }
  } catch (error) {
    // Silently fail - we already returned cached version
  }
}

// Handle messages from the app
self.addEventListener('message', (event) => {
  if (event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data.type === 'CLEAR_CACHE') {
    caches.keys().then((cacheNames) => {
      cacheNames.forEach((cacheName) => {
        caches.delete(cacheName);
      });
    });
  }
  
  if (event.data.type === 'CACHE_URLS') {
    const urls = event.data.urls;
    caches.open(DYNAMIC_CACHE).then((cache) => {
      cache.addAll(urls);
    });
  }
});

// Background sync for offline requests
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-fortunes') {
    event.waitUntil(syncFortunes());
  }
});

async function syncFortunes() {
  // Implement background sync logic for offline fortune requests
  console.log('[SW] Syncing offline fortune requests...');
}
