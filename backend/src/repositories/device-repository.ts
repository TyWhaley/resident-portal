import { pool } from '../db/pool.js';
import type { DeviceRegistrationInput } from '../domain/types.js';

export async function upsertDeviceRegistration(input: DeviceRegistrationInput): Promise<void> {
  await pool.query(
    `INSERT INTO installations (installation_id, app_version, last_seen)
     VALUES ($1, $2, NOW())
     ON CONFLICT (installation_id)
     DO UPDATE SET app_version = EXCLUDED.app_version, last_seen = NOW()`,
    [input.installationId, input.appVersion]
  );

  await pool.query(
    `INSERT INTO devices (installation_id, tenant_id, platform, push_token, enabled, last_seen)
     VALUES ($1, $2, $3, $4, true, NOW())
     ON CONFLICT (platform, push_token)
     DO UPDATE SET installation_id = EXCLUDED.installation_id,
                   tenant_id = COALESCE(EXCLUDED.tenant_id, devices.tenant_id),
                   enabled = true,
                   last_seen = NOW()`,
    [input.installationId, input.tenantId ?? null, input.platform, input.pushToken]
  );
}

export async function getPushTokensForTenant(tenantId: string): Promise<string[]> {
  const result = await pool.query<{ push_token: string }>(
    `SELECT push_token FROM devices
     WHERE tenant_id = $1 AND enabled = true`,
    [tenantId]
  );
  return result.rows.map((row: { push_token: string }) => row.push_token);
}
