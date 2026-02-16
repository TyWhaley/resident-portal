import { env } from '../config/env.js';
import { hmacSha256Base64, hmacSha256Hex, safeEqualString } from '../utils/crypto.js';

export interface VerificationInput {
  rawBody: string;
  headers: Record<string, string | string[] | undefined>;
  requestUrl?: string;
}

export interface VerificationResult {
  ok: boolean;
  reason?: string;
}

function normalizeHeader(value: string | string[] | undefined): string | undefined {
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}

function parseTimestamp(value: string | undefined): number | null {
  if (!value) {
    return null;
  }
  const parsed = Number(value);
  if (Number.isNaN(parsed)) {
    return null;
  }
  return parsed;
}

export function verifyRentvineSignature(input: VerificationInput): VerificationResult {
  if (env.WEBHOOK_VERIFY_ENABLED !== 'true') {
    return { ok: true };
  }

  const fullUrl = input.requestUrl ? new URL(`http://localhost${input.requestUrl}`) : null;
  const queryToken = fullUrl?.searchParams.get('token') ?? undefined;
  const queryTimestamp = fullUrl?.searchParams.get('timestamp') ?? undefined;
  const querySignature = fullUrl?.searchParams.get('signature') ?? undefined;

  // Optional strict token match if configured explicitly.
  if (env.RENTVINE_WEBHOOK_QUERY_TOKEN && queryToken) {
    if (!safeEqualString(queryToken, env.RENTVINE_WEBHOOK_QUERY_TOKEN)) {
      return { ok: false, reason: 'Token mismatch' };
    }
  }

  // Query-string signature mode (common in webhook providers).
  if (querySignature && queryTimestamp) {
    const tsNum = Number(queryTimestamp);
    if (!Number.isNaN(tsNum)) {
      const tsSeconds = tsNum > 9_999_999_999 ? Math.floor(tsNum / 1000) : tsNum;
      const now = Math.floor(Date.now() / 1000);
      if (Math.abs(now - tsSeconds) > env.WEBHOOK_MAX_AGE_SECONDS) {
        return { ok: false, reason: 'Timestamp outside replay window' };
      }
    }

    const basePayload = `${queryTimestamp}${input.rawBody}`;
    const hexBody = hmacSha256Hex(env.RENTVINE_WEBHOOK_SIGNING_KEY, input.rawBody);
    const hexTsBody = hmacSha256Hex(env.RENTVINE_WEBHOOK_SIGNING_KEY, basePayload);
    const b64TsBody = hmacSha256Base64(env.RENTVINE_WEBHOOK_SIGNING_KEY, basePayload);
    const b64UrlTsBody = b64TsBody.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
    const sig = querySignature.startsWith('sha256=') ? querySignature.slice(7) : querySignature;

    if (
      safeEqualString(sig, hexBody) ||
      safeEqualString(sig, hexTsBody) ||
      safeEqualString(sig, b64TsBody) ||
      safeEqualString(sig, b64UrlTsBody)
    ) {
      return { ok: true };
    }
    return { ok: false, reason: 'Signature mismatch' };
  }

  // Header signature mode.
  if (queryToken) {
    if (queryTimestamp) {
      const tsNum = Number(queryTimestamp);
      if (!Number.isNaN(tsNum)) {
        const tsSeconds = tsNum > 9_999_999_999 ? Math.floor(tsNum / 1000) : tsNum;
        const now = Math.floor(Date.now() / 1000);
        if (Math.abs(now - tsSeconds) > env.WEBHOOK_MAX_AGE_SECONDS) {
          return { ok: false, reason: 'Timestamp outside replay window' };
        }
      }
    }
  }

  const signatureHeader = normalizeHeader(
    input.headers[env.RENTVINE_WEBHOOK_SIGNATURE_HEADER.toLowerCase()]
  );

  if (!signatureHeader) {
    return { ok: false, reason: 'Missing signature header' };
  }

  const timestampValue = normalizeHeader(
    input.headers[env.RENTVINE_WEBHOOK_TIMESTAMP_HEADER.toLowerCase()]
  );

  if (env.RENTVINE_WEBHOOK_SIGNATURE_STRATEGY === 'hmac_sha256_base64_timestamp_body') {
    if (!timestampValue) {
      return { ok: false, reason: 'Missing timestamp header' };
    }

    const ts = parseTimestamp(timestampValue);
    if (ts === null) {
      return { ok: false, reason: 'Invalid timestamp header' };
    }

    const now = Math.floor(Date.now() / 1000);
    if (Math.abs(now - ts) > env.WEBHOOK_MAX_AGE_SECONDS) {
      return { ok: false, reason: 'Timestamp outside replay window' };
    }

    const computed = hmacSha256Base64(
      env.RENTVINE_WEBHOOK_SIGNING_KEY,
      `${timestampValue}${input.rawBody}`
    );
    return safeEqualString(computed, signatureHeader)
      ? { ok: true }
      : { ok: false, reason: 'Signature mismatch' };
  }

  const computed = hmacSha256Hex(env.RENTVINE_WEBHOOK_SIGNING_KEY, input.rawBody);
  return safeEqualString(computed, signatureHeader)
    ? { ok: true }
    : { ok: false, reason: 'Signature mismatch' };
}
