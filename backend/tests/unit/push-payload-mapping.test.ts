import { describe, expect, it } from 'vitest';
import { routeRentvineEvent } from '../../src/services/event-router.js';

describe('push payload mapping', () => {
  it('maps message events to messages deep link', () => {
    const routed = routeRentvineEvent({ event_type: 'message_received', tenant_id: 't1' });
    expect(routed?.payload.deepLink).toBe('app://messages');
    expect(routed?.payload.title).toContain('message');
  });
});
