# Resident Portal (Rentvine)

Production-ready cross-platform Resident Portal app with native notifications and a backend webhook-to-push pipeline.

## Repo layout
- `mobile/` Flutter app (iOS + Android)
- `backend/` Fastify API + BullMQ worker + Postgres/Redis
- `docs/` architecture and operations
- `docker-compose.yml` local backend stack

## Rentvine setup
1. Create API Access Key + Secret in Rentvine dashboard:
   - `Settings -> Users, Roles and API -> API`
   - Reference: [Rentvine API docs](https://docs.rentvine.com/)
2. Configure outbound webhooks and copy signing key:
   - `Settings -> Other -> Webhooks`
   - Reference: [Rentvine webhook help](https://help.rentvine.com/how-to-add-webhooks)

## Environment
1. Copy `.env.example` to `.env` and set values.
2. `FIREBASE_SERVICE_ACCOUNT_JSON` should be full JSON content string for Admin SDK.

## Run locally
1. Start backend stack:
   - `docker compose up --build`
2. Expose local webhook endpoint with ngrok:
   - `ngrok http 8080`
   - Use `https://<ngrok>/v1/webhooks/rentvine` in Rentvine webhook settings.
3. Start Flutter app:
   - `cd mobile`
   - `flutter pub get`
   - `flutter run --dart-define=RENTVINE_PORTAL_URL=https://YOURSUBDOMAIN.rentvine.com/resident --dart-define=BACKEND_BASE_URL=http://<LAN_OR_EMULATOR_HOST>:8080`

## Backend commands
- `cd backend && npm install`
- `npm run dev`
- `npm run migrate`
- `npm run worker`
- `npm test`
- `npm run test:webhook`

## Mobile acceptance checklist
- Portal login loads in-app on both platforms.
- External links open in system browser.
- Push permissions only after user action (toggle in Notifications tab).
- Local rent reminders schedule and fire.
- Push tap opens mapped route in portal.

## Backend acceptance checklist
- `/v1/webhooks/rentvine` returns quickly with `202`.
- Signature verification adapter supports configurable strategy and replay window.
- Deduplication by webhook body hash prevents repeat sends.
- Device registration persists tenant-token linkage.

## App Store / Play Store notes
This app includes native functionality beyond web content (notification controls, local reminder scheduling, account linking, support actions, deep-link routing), supporting App Store guideline requirements for utility beyond a simple web wrapper.
- Apple reference: [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
