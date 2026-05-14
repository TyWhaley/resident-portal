import { pool } from '../db/pool.js';

export async function insertWebhookEvent(eventType: string, rawHash: string): Promise<string | null> {
  const result = await pool.query<{ id: string }>(
    `INSERT INTO webhook_events (event_type, raw_hash)
     VALUES ($1, $2)
     ON CONFLICT (raw_hash) DO NOTHING
     RETURNING id`,
    [eventType, rawHash]
  );
  return result.rows[0]?.id ?? null;
}

export async function markWebhookEventProcessed(eventId: string, status: 'processed' | 'failed'): Promise<void> {
  await pool.query(
    `UPDATE webhook_events SET processed_at = NOW(), status = $2 WHERE id = $1`,
    [eventId, status]
  );
}

export async function cleanupOldWebhookEvents(): Promise<void> {
  await pool.query(
    `DELETE FROM webhook_events WHERE received_at < NOW() - INTERVAL '30 days'`
  );
}
