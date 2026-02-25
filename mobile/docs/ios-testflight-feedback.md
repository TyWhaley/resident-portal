# iOS TestFlight + Feedback Setup

## 1. Prereqs
- Apple Developer Program account (paid).
- Bundle ID in app is now: `com.coastalrealtyservices.residentportal`.

## 2. Create app in App Store Connect
1. Go to App Store Connect -> Apps -> `+` -> New App.
2. Platform: iOS.
3. Name: Resident Portal Mobile.
4. Bundle ID: `com.coastalrealtyservices.residentportal`.
5. SKU: any unique internal value (example: `resident-portal-ios-001`).

## 3. Upload build for TestFlight
1. Open:
   - `ios/Runner.xcworkspace` in Xcode.
2. Select target `Runner`.
3. Product -> Archive.
4. In Organizer, select archive -> Distribute App -> App Store Connect -> Upload.
5. Wait for processing in App Store Connect (can take 10-30 minutes).

## 4. Add testers
### Internal testers (fastest)
1. App Store Connect -> TestFlight -> Internal Testing.
2. Add your team members.
3. Assign latest build.

### External testers
1. App Store Connect -> TestFlight -> External Testing.
2. Create group (example: `Pilot Residents`).
3. Add tester emails.
4. Submit build for Beta App Review (one-time per build).
5. After approval, share public link or invites.

## 5. In-app feedback + rating
- Support tab now includes:
  - `Send App Feedback` (opens email composer to feedback inbox/list).
  - `Rate This App` (in-app review prompt / App Store listing fallback).

### Runtime defines
Pass these on iOS builds:

```bash
--dart-define=FEEDBACK_EMAIL=your-feedback-list@gmail.com
--dart-define=IOS_APP_STORE_ID=1234567890
```

`IOS_APP_STORE_ID` is your numeric Apple app ID from App Store Connect.

## 6. Suggested feedback inbox setup (Gmail)
1. Create Google Group or label-backed shared inbox (example: `resident-app-feedback@...`).
2. Set `FEEDBACK_EMAIL` to that address.
3. Add filters:
   - Subject contains `Resident Portal App Feedback`.
   - Auto-label `mobile-app-feedback`.
4. Create canned replies for known issues.
