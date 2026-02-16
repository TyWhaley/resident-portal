import crypto from 'node:crypto';

interface Args {
  url: string;
  signingKey: string;
}

function parseArgs(): Args {
  const url = process.argv[2] ?? 'http://localhost:8080/v1/webhooks/rentvine';
  const signingKey = process.argv[3] ?? process.env.RENTVINE_WEBHOOK_SIGNING_KEY ?? 'signing_key';
  return { url, signingKey };
}

async function main(): Promise<void> {
  const args = parseArgs();
  const payload = {
    event_type: 'payment_received',
    tenant_id: 'tenant_demo_001',
    entity_id: 'payment_demo_123',
    created_at: new Date().toISOString()
  };

  const raw = JSON.stringify(payload);
  const timestamp = String(Math.floor(Date.now() / 1000));
  const signature = crypto
    .createHmac('sha256', args.signingKey)
    .update(`${timestamp}${raw}`)
    .digest('base64');

  const response = await fetch(args.url, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-rentvine-timestamp': timestamp,
      'x-rentvine-signature': signature
    },
    body: raw
  });

  const text = await response.text();
  console.log(response.status, text);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
