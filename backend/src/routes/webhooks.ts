import type { FastifyPluginAsync } from 'fastify';
import { z } from 'zod';
import { insertWebhookEvent } from '../repositories/webhook-repository.js';
import { sha256Hex } from '../utils/crypto.js';
import { verifyRentvineSignature } from '../services/signature-verifier.js';
import { enqueueWebhookJob } from '../queue/queues.js';

const eventSchema = z.record(z.unknown());

export const webhookRoutes: FastifyPluginAsync = async (app) => {
  app.post('/v1/webhooks/rentvine', async (request, reply) => {
    const rawBody = (request as unknown as { rawBody?: string }).rawBody ?? JSON.stringify(request.body ?? {});

    const verification = verifyRentvineSignature({
      rawBody,
      headers: request.headers,
      requestUrl: request.url
    });

    if (!verification.ok) {
      app.log.warn(
        {
          reason: verification.reason,
          headers: {
            signatureHeaderPresent: Boolean(request.headers['x-rentvine-signature']),
            timestampHeaderPresent: Boolean(request.headers['x-rentvine-timestamp'])
          }
        },
        'Webhook verification failed'
      );

      return reply.status(401).send({ error: 'Invalid signature' });
    }

    const parsedEvent = eventSchema.safeParse(request.body);
    if (!parsedEvent.success) {
      return reply.status(400).send({ error: 'Invalid webhook payload' });
    }

    const eventType =
      (parsedEvent.data.event_type as string | undefined) ??
      (parsedEvent.data.type as string | undefined) ??
      'unknown_event';

    const rawHash = sha256Hex(rawBody);
    const eventId = await insertWebhookEvent(eventType, rawHash);
    if (!eventId) {
      return reply.status(202).send({ success: true, deduped: true });
    }

    await enqueueWebhookJob({
      eventId,
      rawBody,
      parsedEvent: parsedEvent.data
    });

    return reply.status(202).send({ success: true });
  });
};
