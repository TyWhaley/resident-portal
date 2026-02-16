process.env.APP_ENV = process.env.APP_ENV ?? 'dev';
process.env.PORT = process.env.PORT ?? '8080';
process.env.RENTVINE_PORTAL_URL = process.env.RENTVINE_PORTAL_URL ?? 'https://example.rentvine.com/resident';
process.env.RENTVINE_API_BASE_URL = process.env.RENTVINE_API_BASE_URL ?? 'https://api.example.rentvine.com';
process.env.RENTVINE_API_ACCESS_KEY = process.env.RENTVINE_API_ACCESS_KEY ?? 'access';
process.env.RENTVINE_API_SECRET = process.env.RENTVINE_API_SECRET ?? 'secret';
process.env.RENTVINE_WEBHOOK_SIGNING_KEY = process.env.RENTVINE_WEBHOOK_SIGNING_KEY ?? 'signing_key';
process.env.RENTVINE_WEBHOOK_SIGNATURE_STRATEGY =
  process.env.RENTVINE_WEBHOOK_SIGNATURE_STRATEGY ?? 'hmac_sha256_base64_timestamp_body';
process.env.RENTVINE_WEBHOOK_SIGNATURE_HEADER = process.env.RENTVINE_WEBHOOK_SIGNATURE_HEADER ?? 'x-rentvine-signature';
process.env.RENTVINE_WEBHOOK_TIMESTAMP_HEADER = process.env.RENTVINE_WEBHOOK_TIMESTAMP_HEADER ?? 'x-rentvine-timestamp';
process.env.WEBHOOK_VERIFY_ENABLED = process.env.WEBHOOK_VERIFY_ENABLED ?? 'true';
process.env.WEBHOOK_MAX_AGE_SECONDS = process.env.WEBHOOK_MAX_AGE_SECONDS ?? '300';
process.env.FIREBASE_SERVICE_ACCOUNT_JSON =
  process.env.FIREBASE_SERVICE_ACCOUNT_JSON ??
  '{"projectId":"demo","clientEmail":"demo@demo.iam.gserviceaccount.com","privateKey":"-----BEGIN PRIVATE KEY-----\\nabc\\n-----END PRIVATE KEY-----\\n"}';
process.env.DATABASE_URL = process.env.DATABASE_URL ?? 'postgres://postgres:postgres@localhost:5432/resident_portal';
process.env.REDIS_URL = process.env.REDIS_URL ?? 'redis://localhost:6379';
