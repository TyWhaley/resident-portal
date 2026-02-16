import type { FastifyPluginAsync } from 'fastify';
import { z } from 'zod';
import { upsertDeviceRegistration } from '../repositories/device-repository.js';
import { parseTenantLinkToken } from '../repositories/link-repository.js';
import { ensureTenantExists } from '../repositories/tenant-repository.js';

const bodySchema = z.object({
  installation_id: z.string().min(8),
  platform: z.enum(['ios', 'android']),
  push_token: z.string().min(10),
  tenant_link_token: z.string().optional(),
  tenant_id: z.string().optional(),
  app_version: z.string().min(1)
});

export const deviceRoutes: FastifyPluginAsync = async (app) => {
  app.post('/v1/devices/register', async (request, reply) => {
    const parsed = bodySchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.status(400).send({ error: parsed.error.flatten() });
    }

    const b = parsed.data;
    const linkedTenant = b.tenant_link_token ? parseTenantLinkToken(b.tenant_link_token) : b.tenant_id;

    if (linkedTenant) {
      await ensureTenantExists(linkedTenant);
    }

    await upsertDeviceRegistration({
      installationId: b.installation_id,
      platform: b.platform,
      pushToken: b.push_token,
      appVersion: b.app_version,
      tenantId: linkedTenant ?? undefined
    });

    return reply.send({ success: true });
  });
};
