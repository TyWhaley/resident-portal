# Operations Runbook

## Runtime checks
- API health: `GET /healthz`
- Verify workers are running: `docker compose logs worker`
- Verify webhook ingestion: `docker compose logs backend`

## Test webhook
- Run: `cd backend && npm run test:webhook -- http://localhost:8080/v1/webhooks/rentvine YOUR_SIGNING_KEY`

## Device linking
- OTP flow from app (`/v1/tenants/request-link`, `/v1/tenants/confirm-link`).
- Optional manual token generation:
  - `cd backend && npm run admin:link-token -- <tenant_id>`

## Security defaults
- `WEBHOOK_VERIFY_ENABLED=true` required in production.
- Rotate `RENTVINE_WEBHOOK_SIGNING_KEY` and Firebase service account credentials periodically.
