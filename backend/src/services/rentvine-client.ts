import { env } from '../config/env.js';

interface CacheEntry<T> {
  expiresAt: number;
  value: T;
}

const cache = new Map<string, CacheEntry<unknown>>();

async function requestWithRetry(url: string, retries = 2): Promise<Response> {
  let lastError: unknown;
  for (let attempt = 0; attempt <= retries; attempt += 1) {
    try {
      const auth = Buffer.from(
        `${env.RENTVINE_API_ACCESS_KEY}:${env.RENTVINE_API_SECRET}`,
        'utf8'
      ).toString('base64');
      const response = await fetch(url, {
        headers: {
          Authorization: `Basic ${auth}`,
          Accept: 'application/json'
        }
      });
      if (response.ok) {
        return response;
      }
      if (response.status >= 400 && response.status < 500) {
        return response;
      }
      lastError = new Error(`HTTP ${response.status}`);
    } catch (error) {
      lastError = error;
    }

    const backoffMs = 200 * (attempt + 1);
    await new Promise((resolve) => setTimeout(resolve, backoffMs));
  }

  throw lastError instanceof Error ? lastError : new Error('Rentvine request failed');
}

export async function fetchRentvineResource<T>(path: string, ttlMs = 30000): Promise<T | null> {
  const cacheKey = path;
  const now = Date.now();
  const hit = cache.get(cacheKey);
  if (hit && hit.expiresAt > now) {
    return hit.value as T;
  }

  const url = `${env.RENTVINE_API_BASE_URL.replace(/\/$/, '')}/${path.replace(/^\//, '')}`;
  const response = await requestWithRetry(url);
  if (!response.ok) {
    return null;
  }

  const data = (await response.json()) as T;
  cache.set(cacheKey, { value: data, expiresAt: now + ttlMs });
  return data;
}
