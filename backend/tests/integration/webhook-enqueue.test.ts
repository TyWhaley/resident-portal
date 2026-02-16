import { beforeEach, describe, expect, it, vi } from 'vitest';
import { buildApp } from '../../src/app.js';
import { hmacSha256Base64 } from '../../src/utils/crypto.js';

const mocks = vi.hoisted(() => ({
  insertWebhookEvent: vi.fn(async () => 'event_123'),
  enqueueWebhookJob: vi.fn(async () => undefined)
}));

vi.mock('../../src/repositories/webhook-repository.js', () => ({
  insertWebhookEvent: mocks.insertWebhookEvent
}));

vi.mock('../../src/queue/queues.js', () => ({
  enqueueWebhookJob: mocks.enqueueWebhookJob
}));

describe('webhook route integration', () => {
  beforeEach(() => {
    mocks.insertWebhookEvent.mockClear();
    mocks.enqueueWebhookJob.mockClear();
  });

  it('returns 202 and enqueues job', async () => {
    const app = buildApp();
    const payload = { event_type: 'payment_received', tenant_id: 'tenant_1' };
    const rawBody = JSON.stringify(payload);
    const ts = String(Math.floor(Date.now() / 1000));
    const sig = hmacSha256Base64('signing_key', `${ts}${rawBody}`);

    const response = await app.inject({
      method: 'POST',
      url: '/v1/webhooks/rentvine',
      headers: {
        'content-type': 'application/json',
        'x-rentvine-signature': sig,
        'x-rentvine-timestamp': ts
      },
      payload: rawBody
    });

    expect(response.statusCode).toBe(202);
    expect(mocks.insertWebhookEvent).toHaveBeenCalledTimes(1);
    expect(mocks.enqueueWebhookJob).toHaveBeenCalledTimes(1);

    await app.close();
  });
});
