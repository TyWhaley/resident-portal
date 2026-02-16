import crypto from 'node:crypto';
import { pool } from '../db/pool.js';
import { sha256Hex } from '../utils/crypto.js';

function maskDestination(value: string): string {
  if (value.includes('@')) {
    const [name, domain] = value.split('@');
    return `${name.slice(0, 2)}***@${domain}`;
  }
  return `${value.slice(0, 3)}***${value.slice(-2)}`;
}

export async function createLinkRequest(tenantId: string, destination: string): Promise<{
  linkRequestId: string;
  maskedDestination: string;
  otpCode: string;
}> {
  const otpCode = String(Math.floor(100000 + Math.random() * 900000));
  const result = await pool.query<{ link_request_id: string }>(
    `INSERT INTO link_requests (tenant_id, destination_mask, otp_hash, expires_at)
     VALUES ($1, $2, $3, NOW() + INTERVAL '10 minutes')
     RETURNING link_request_id`,
    [tenantId, maskDestination(destination), sha256Hex(otpCode)]
  );

  return {
    linkRequestId: result.rows[0].link_request_id,
    maskedDestination: maskDestination(destination),
    otpCode
  };
}

export async function consumeLinkRequest(
  linkRequestId: string,
  otpCode: string
): Promise<{ tenantId: string } | null> {
  const hashed = sha256Hex(otpCode);
  const result = await pool.query<{ tenant_id: string }>(
    `UPDATE link_requests
     SET consumed_at = NOW()
     WHERE link_request_id = $1
       AND consumed_at IS NULL
       AND otp_hash = $2
       AND expires_at > NOW()
     RETURNING tenant_id`,
    [linkRequestId, hashed]
  );

  return result.rows[0] ? { tenantId: result.rows[0].tenant_id } : null;
}

export function createTenantLinkToken(tenantId: string): string {
  const raw = `${tenantId}:${Date.now()}:${crypto.randomUUID()}`;
  return Buffer.from(raw).toString('base64url');
}

export function parseTenantLinkToken(token: string): string | null {
  try {
    const decoded = Buffer.from(token, 'base64url').toString('utf8');
    const [tenantId] = decoded.split(':');
    return tenantId || null;
  } catch {
    return null;
  }
}
