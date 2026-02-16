import type { PushPayload } from '../domain/types.js';

interface RouterResult {
  tenantIds: string[];
  payload: PushPayload;
}

function asString(value: unknown): string | undefined {
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

export function routeRentvineEvent(event: Record<string, unknown>): RouterResult | null {
  const eventType = asString(event.event_type) ?? asString(event.type) ?? 'unknown_event';
  const tenantId = asString(event.tenant_id) ?? asString(event.tenantId);
  const entityId = asString(event.entity_id) ?? asString(event.entityId);

  if (!tenantId && eventType !== 'announcement') {
    return null;
  }

  const map: Record<string, { title: string; body: string; deepLink: string }> = {
    maintenance_updated: {
      title: 'Maintenance update',
      body: 'Your maintenance request has been updated.',
      deepLink: 'app://maintenance/new'
    },
    payment_received: {
      title: 'Payment receipt',
      body: 'A payment was posted to your ledger.',
      deepLink: 'app://pay'
    },
    message_received: {
      title: 'New message',
      body: 'You received a new portal message.',
      deepLink: 'app://messages'
    },
    announcement: {
      title: 'Community update',
      body: 'There is a new announcement from management.',
      deepLink: 'app://messages'
    }
  };

  const selected = map[eventType] ?? {
    title: 'Resident portal update',
    body: 'There is an update in your resident portal.',
    deepLink: 'app://messages'
  };

  return {
    tenantIds: tenantId ? [tenantId] : [],
    payload: {
      title: selected.title,
      body: selected.body,
      deepLink: selected.deepLink,
      eventType,
      entityId,
      tenantId
    }
  };
}
