# Android Release + Testing

## 1. One-time setup

### Create Play app
1. Open Google Play Console.
2. Create app: `Resident Portal Mobile`.
3. Package name must be: `com.coastalrealtyservices.residentportal`.

### Create upload keystore (one time)
Run:

```bash
cd "$HOME/Developer/resident-portal/mobile/android/app"
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Then create `android/key.properties` from `android/key.properties.example`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=app/upload-keystore.jks
```

## 2. Build Android App Bundle (AAB)

```bash
cd "$HOME/Developer/resident-portal/mobile"
flutter clean
flutter pub get
flutter build appbundle --release \
  --dart-define=RENTVINE_PORTAL_URL=https://coastalrealtyservices.rentvine.com/portals/resident \
  --dart-define=BACKEND_BASE_URL=https://anita-catagenetic-carter.ngrok-free.dev \
  --dart-define=SUPPORT_PHONE=850-244-2100 \
  --dart-define=SUPPORT_EMAIL=rentals@coastalrealtyservices.com
```

Output file:
- `build/app/outputs/bundle/release/app-release.aab`

## 3. Internal testing (fastest way for testers)

1. Play Console -> `Testing` -> `Internal testing`.
2. Create a new release.
3. Upload: `app-release.aab`.
4. Add release notes.
5. Add testers (emails or Google Group).
6. Publish release to internal testing.
7. Share opt-in link with testers.

## 4. Closed testing (next step)

1. Play Console -> `Testing` -> `Closed testing`.
2. Promote same artifact or upload new AAB.
3. Add larger tester group.
4. Gather crash/ANR feedback in Play Console -> Android vitals.

## 5. Production launch

1. Complete store listing assets and policy declarations.
2. Create production release from tested AAB.
3. Roll out gradually (for example 10% -> 50% -> 100%).

## 6. Tester install notes

- Testers must join via your opt-in URL first.
- It can take a few minutes before Play shows install/update.
- Testers should use Play Store app (not direct APK sideload).
