import { Worker } from 'bullmq';
import { routeRentvineEvent } from '../services/event-router.js';
import { enqueuePushJob } from './queues.js';
import { markWebhookEventProcessed } from '../repositories/webhook-repository.js';
import { sendTenantPush } from '../services/push-service.js';
import { env } from '../config/env.js';

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

const workerConnection = redisConnectionFromUrl(env.REDIS_URL);

const webhookWorker = new Worker(
  'process_rentvine_webhook',
  async (job) => {
    const result = routeRentvineEvent(job.data.parsedEvent);
    if (!result) {
      await markWebhookEventProcessed(job.data.eventId, 'processed');
      return;
    }

    if (result.tenantIds.length === 0 && result.payload.eventType === 'announcement') {
      await markWebhookEventProcessed(job.data.eventId, 'processed');
      return;
    }

    for (const tenantId of result.tenantIds) {
      await enqueuePushJob({ tenantId, payload: result.payload });
    }

    await markWebhookEventProcessed(job.data.eventId, 'processed');
  },
  { connection: workerConnection }
);

const pushWorker = new Worker(
  'send_push',
  async (job) => {
    await sendTenantPush(job.data.tenantId, job.data.payload);
  },
  { connection: workerConnection }
);

webhookWorker.on('failed', async (job, error) => {
  if (job?.data?.eventId) {
    await markWebhookEventProcessed(job.data.eventId, 'failed');
  }
  console.error('webhook worker failed', error);
});

pushWorker.on('failed', (job, error) => {
  console.error('push worker failed', job?.id, error);
});

console.log('Workers started');
