import { Queue } from 'bullmq';
import { env } from '../config/env.js';
import type { PushPayload } from '../domain/types.js';

export interface ProcessWebhookJob {
  eventId: string;
  rawBody: string;
  parsedEvent: Record<string, unknown>;
}

export interface SendPushJob {
  tenantId: string;
  payload: PushPayload;
}

function redisConnectionFromUrl(redisUrl: string): {
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

const queueConnection = redisConnectionFromUrl(env.REDIS_URL);

export const webhookQueue = new Queue<ProcessWebhookJob, void, string>('process_rentvine_webhook', {
  connection: queueConnection
});

export const pushQueue = new Queue<SendPushJob, void, string>('send_push', {
  connection: queueConnection
});

export async function enqueueWebhookJob(job: ProcessWebhookJob): Promise<void> {
  await webhookQueue.add('process', job, {
    attempts: 3,
    backoff: { type: 'exponential', delay: 500 }
  });
}

export async function enqueuePushJob(job: SendPushJob): Promise<void> {
  await pushQueue.add('send', job, {
    attempts: 3,
    backoff: { type: 'exponential', delay: 500 }
  });
}
