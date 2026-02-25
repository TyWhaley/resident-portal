# Resident Portal Mobile

Flutter mobile app wrapper for the Coastal Realty resident portal.

## iOS run

```bash
flutter run -d "Ty’s iPhone (2)" \
  --dart-define=RENTVINE_PORTAL_URL=https://coastalrealtyservices.rentvine.com/portals/resident \
  --dart-define=BACKEND_BASE_URL=https://anita-catagenetic-carter.ngrok-free.dev \
  --dart-define=SUPPORT_PHONE=850-244-2100 \
  --dart-define=SUPPORT_EMAIL=rentals@coastalrealtyservices.com
```

## Android release + Play testing

See:
- `docs/android-release-testing.md`

## iOS TestFlight + feedback

See:
- `docs/ios-testflight-feedback.md`
