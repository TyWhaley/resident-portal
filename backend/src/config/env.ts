import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config({ path: '../.env' });
dotenv.config();

const envSchema = z.object({
  APP_ENV: z.enum(['dev', 'prod']).default('dev'),
  PORT: z.coerce.number().default(8080),
  RENTVINE_PORTAL_URL: z.string().url(),
  RENTVINE_API_BASE_URL: z.string().url(),
  RENTVINE_API_ACCESS_KEY: z.string().min(1),
  RENTVINE_API_SECRET: z.string().min(1),
  RENTVINE_WEBHOOK_SIGNING_KEY: z.string().min(1),
  RENTVINE_WEBHOOK_SIGNATURE_STRATEGY: z
    .enum(['hmac_sha256_base64_timestamp_body', 'hmac_sha256_hex_body'])
    .default('hmac_sha256_base64_timestamp_body'),
  RENTVINE_WEBHOOK_SIGNATURE_HEADER: z.string().default('x-rentvine-signature'),
  RENTVINE_WEBHOOK_TIMESTAMP_HEADER: z.string().default('x-rentvine-timestamp'),
  RENTVINE_WEBHOOK_QUERY_TOKEN: z.string().optional(),
  WEBHOOK_VERIFY_ENABLED: z.string().default('true'),
  WEBHOOK_MAX_AGE_SECONDS: z.coerce.number().default(300),
  FIREBASE_SERVICE_ACCOUNT_JSON: z.string().min(1),
  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().min(1)
});

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('Invalid environment configuration', parsed.error.flatten());
  throw new Error('Invalid environment configuration');
}

export const env = parsed.data;
export type Env = typeof env;
