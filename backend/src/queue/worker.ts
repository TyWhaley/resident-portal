import { Worker } from 'bullmq';
import { routeRentvineEvent } from '../services/event-router.js';
import { enqueuePushJob } from './queues.js';
import { markWebhookEventProcessed, cleanupOldWebhookEvents } from '../repositories/webhook-repository.js';
import { sendTenantPush } from '../services/push-service.js';
import { env } from '../config/env.js';
import { redisConnectionFromUrl } from './connection.js';

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

async function shutdown(signal: string) {
  console.log(`${signal} received, closing workers gracefully`);
  await webhookWorker.close();
  await pushWorker.close();
  process.exit(0);
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Run webhook cleanup every 6 hours
setInterval(() => {
  cleanupOldWebhookEvents().catch((err) =>
    console.error('Webhook cleanup failed', err)
  );
}, 6 * 60 * 60 * 1000);

console.log('Workers started');
