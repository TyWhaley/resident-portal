import Fastify from 'fastify';
import rateLimit from '@fastify/rate-limit';
import helmet from '@fastify/helmet';
import cors from '@fastify/cors';
import { deviceRoutes } from './routes/devices.js';
import { tenantRoutes } from './routes/tenants.js';
import { webhookRoutes } from './routes/webhooks.js';
import { healthRoutes } from './routes/health.js';
import { env } from './config/env.js';

export function buildApp() {
  const app = Fastify({
    logger: true,
    bodyLimit: 1024 * 1024,
    ajv: {
      customOptions: { removeAdditional: 'all' }
    }
  });

  app.addContentTypeParser(
    'application/json',
    { parseAs: 'string' },
    (req, body: string, done) => {
      (req as unknown as { rawBody?: string }).rawBody = body;
      try {
        done(null, JSON.parse(body));
      } catch (error) {
        done(error as Error, undefined);
      }
    }
  );

  app.register(helmet, {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:']
      }
    }
  });

  app.register(cors, {
    origin: env.APP_ENV === 'prod'
      ? ['https://coastalrealtyservices.rentvine.com']
      : true,
    credentials: true
  });

  app.register(rateLimit, {
    max: 60,
    timeWindow: '1 minute',
    keyGenerator: (req) => req.ip
  });

  app.register(healthRoutes);
  app.register(deviceRoutes);
  app.register(tenantRoutes);
  app.register(webhookRoutes);

  return app;
}
