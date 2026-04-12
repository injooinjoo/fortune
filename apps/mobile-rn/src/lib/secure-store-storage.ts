import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';

const isWeb = Platform.OS === 'web';

const secureStoreChunkSize = 1800;
const secureStoreChunkCountSuffix = '.__chunk_count';
const secureStoreChunkItemPrefix = '.__chunk_';

function resolveChunkCountKey(key: string) {
  return `${key}${secureStoreChunkCountSuffix}`;
}

function resolveChunkKey(key: string, index: number) {
  return `${key}${secureStoreChunkItemPrefix}${index}`;
}

function normalizeChunkCount(value: string | null) {
  if (!value) {
    return 0;
  }

  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
}

async function readChunkCount(key: string) {
  return normalizeChunkCount(
    await SecureStore.getItemAsync(resolveChunkCountKey(key)),
  );
}

async function clearChunkedValue(key: string) {
  const chunkCount = await readChunkCount(key);

  if (chunkCount === 0) {
    return;
  }

  for (let index = 0; index < chunkCount; index += 1) {
    await SecureStore.deleteItemAsync(resolveChunkKey(key, index));
  }

  await SecureStore.deleteItemAsync(resolveChunkCountKey(key));
}

function splitIntoChunks(value: string) {
  const chunks: string[] = [];

  for (let index = 0; index < value.length; index += secureStoreChunkSize) {
    chunks.push(value.slice(index, index + secureStoreChunkSize));
  }

  return chunks;
}

export async function getSecureItem(key: string) {
  if (isWeb) {
    return localStorage.getItem(key);
  }

  const chunkCount = await readChunkCount(key);

  if (chunkCount === 0) {
    return SecureStore.getItemAsync(key);
  }

  let value = '';

  for (let index = 0; index < chunkCount; index += 1) {
    const chunk = await SecureStore.getItemAsync(resolveChunkKey(key, index));

    if (typeof chunk !== 'string') {
      return null;
    }

    value += chunk;
  }

  return value;
}

export async function setSecureItem(key: string, value: string) {
  if (isWeb) {
    localStorage.setItem(key, value);
    return;
  }

  const chunks = splitIntoChunks(value);

  if (chunks.length <= 1) {
    await clearChunkedValue(key);
    await SecureStore.setItemAsync(key, value);
    return;
  }

  await SecureStore.deleteItemAsync(key);
  await clearChunkedValue(key);

  for (let index = 0; index < chunks.length; index += 1) {
    await SecureStore.setItemAsync(resolveChunkKey(key, index), chunks[index]);
  }

  await SecureStore.setItemAsync(resolveChunkCountKey(key), String(chunks.length));
}

export async function deleteSecureItem(key: string) {
  if (isWeb) {
    localStorage.removeItem(key);
    return;
  }

  await SecureStore.deleteItemAsync(key);
  await clearChunkedValue(key);
}
