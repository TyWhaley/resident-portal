# Resident Portal Architecture

## Mobile (Flutter)
- `Portal` tab: in-app Rentvine resident portal WebView, strict host allowlist.
- `Notifications` tab: native controls for OS permission, local rent reminders, push categories, and Link Account OTP flow.
- `Support` tab: native call/email/text actions and FAQ.
- Deep links map `app://pay`, `app://maintenance/new`, `app://messages` to portal routes.

## Backend (Node + Fastify + BullMQ)
- `POST /v1/webhooks/rentvine` verifies webhook signatures, deduplicates by SHA-256 raw body hash, persists metadata, enqueues processing.
- `process_rentvine_webhook` worker maps events to push payloads and enqueues `send_push` jobs.
- `send_push` worker sends FCM notifications (iOS + Android) with deep link metadata.
- OTP link flow endpoints connect installation IDs to tenant IDs without storing portal credentials.

## Data Model
- `tenants`, `installations`, `devices`, `notification_prefs`, `webhook_events`, `link_requests`.
- Sensitive webhook payloads are not fully stored; only hash + minimal metadata are persisted.
