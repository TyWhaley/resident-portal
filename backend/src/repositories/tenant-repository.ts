import { pool } from '../db/pool.js';

interface TenantRecord {
  tenant_id: string;
  email: string | null;
  phone: string | null;
}

export async function findTenantByEmailOrPhone(input: string): Promise<TenantRecord | null> {
  const normalized = input.trim();
  const result = await pool.query<TenantRecord>(
    `SELECT tenant_id, email, phone
     FROM tenants
     WHERE LOWER(email) = LOWER($1) OR phone = $1
     LIMIT 1`,
    [normalized]
  );
  return result.rows[0] ?? null;
}

export async function ensureTenantExists(tenantId: string): Promise<void> {
  await pool.query(
    `INSERT INTO tenants (tenant_id) VALUES ($1)
     ON CONFLICT (tenant_id) DO NOTHING`,
    [tenantId]
  );
}
