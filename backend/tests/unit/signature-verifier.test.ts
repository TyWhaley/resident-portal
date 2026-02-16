import { describe, expect, it } from 'vitest';
import { verifyRentvineSignature } from '../../src/services/signature-verifier.js';
import { hmacSha256Base64 } from '../../src/utils/crypto.js';

describe('verifyRentvineSignature', () => {
  it('accepts valid timestamp+body signature', () => {
    const rawBody = JSON.stringify({ type: 'payment_received' });
    const ts = String(Math.floor(Date.now() / 1000));
    const sig = hmacSha256Base64('signing_key', `${ts}${rawBody}`);

    const result = verifyRentvineSignature({
      rawBody,
      headers: {
        'x-rentvine-signature': sig,
        'x-rentvine-timestamp': ts
      }
    });

    expect(result.ok).toBe(true);
  });

  it('rejects mismatched signature', () => {
    const rawBody = JSON.stringify({ type: 'message_received' });
    const ts = String(Math.floor(Date.now() / 1000));

    const result = verifyRentvineSignature({
      rawBody,
      headers: {
        'x-rentvine-signature': 'bad_sig',
        'x-rentvine-timestamp': ts
      }
    });

    expect(result.ok).toBe(false);
  });
});
