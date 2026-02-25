import type { FastifyPluginAsync } from 'fastify';
import { z } from 'zod';
import {
  consumeLinkRequest,
  createLinkRequest,
  createTenantLinkToken
} from '../repositories/link-repository.js';
import { findTenantByEmailOrPhone } from '../repositories/tenant-repository.js';
import { upsertDeviceRegistration } from '../repositories/device-repository.js';

const requestLinkSchema = z.object({
  email: z.string().email().optional(),
  phone: z.string().min(8).optional()
});

const confirmLinkSchema = z.object({
  link_request_id: z.string().uuid(),
  otp_code: z.string().length(6),
  installation_id: z.string().min(8),
  platform: z.enum(['ios', 'android']).optional(),
  push_token: z.string().optional(),
  app_version: z.string().optional()
});

export const tenantRoutes: FastifyPluginAsync = async (app) => {
  app.post('/v1/tenants/request-link', async (request, reply) => {
    const parsed = requestLinkSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.status(400).send({ error: parsed.error.flatten() });
    }

    const normalizedEmail = parsed.data.email?.trim().toLowerCase();
    const normalizedPhone = parsed.data.phone?.trim();
    const destination = normalizedEmail ?? normalizedPhone;
    if (!destination) {
      return reply.status(400).send({ error: 'Provide email or phone' });
    }

    const tenant = await findTenantByEmailOrPhone(destination);
    if (!tenant) {
      return reply.status(404).send({ error: 'Tenant not found' });
    }

    const requestResult = await createLinkRequest(tenant.tenant_id, destination);

    if (app.log.level !== 'silent') {
      app.log.info(
        { linkRequestId: requestResult.linkRequestId, otpPreview: requestResult.otpCode },
        'OTP generated (dev only)'
      );
    }

    return reply.send({
      masked_destination: requestResult.maskedDestination,
      link_request_id: requestResult.linkRequestId
    });
  });

  app.post('/v1/tenants/confirm-link', async (request, reply) => {
    const parsed = confirmLinkSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.status(400).send({ error: parsed.error.flatten() });
    }

    const match = await consumeLinkRequest(parsed.data.link_request_id, parsed.data.otp_code);
    if (!match) {
      return reply.status(401).send({ error: 'Invalid or expired OTP' });
    }

    const linkToken = createTenantLinkToken(match.tenantId);

    if (parsed.data.platform && parsed.data.push_token && parsed.data.app_version) {
      await upsertDeviceRegistration({
        installationId: parsed.data.installation_id,
        platform: parsed.data.platform,
        pushToken: parsed.data.push_token,
        appVersion: parsed.data.app_version,
        tenantId: match.tenantId
      });
    }

    return reply.send({
      tenant_id: match.tenantId,
      link_token: linkToken
    });
  });
};
