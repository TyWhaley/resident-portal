import { Redis } from 'ioredis';
import { env } from '../config/env.js';

export const redis = new Redis(env.REDIS_URL, {
  maxRetriesPerRequest: null
});

export function redisConnectionFromUrl(redisUrl: string): {
  host: string;
  port: number;
  username?: string;
  password?: string;
  db?: number;
} {
  const parsed = new URL(redisUrl);
  const dbPath = parsed.pathname.replace('/', '');
  return {
    host: parsed.hostname,
    port: Number(parsed.port || '6379'),
    username: parsed.username || undefined,
    password: parsed.password || undefined,
    db: dbPath ? Number(dbPath) : undefined
  };
}
