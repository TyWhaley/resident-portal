import { describe, expect, it } from 'vitest';
import { routeRentvineEvent } from '../../src/services/event-router.js';

describe('routeRentvineEvent', () => {
  it('maps payment_received into pay deep link', () => {
    const routed = routeRentvineEvent({
      event_type: 'payment_received',
      tenant_id: 'tenant_1',
      entity_id: 'payment_123'
    });

    expect(routed).not.toBeNull();
    expect(routed?.tenantIds).toEqual(['tenant_1']);
    expect(routed?.payload.deepLink).toBe('app://pay');
    expect(routed?.payload.eventType).toBe('payment_received');
  });

  it('drops non-announcement events without tenant', () => {
    const routed = routeRentvineEvent({ event_type: 'maintenance_updated' });
    expect(routed).toBeNull();
  });
});
