# GlobalCalc

GlobalCalc is a Flutter utility app built for a massive global audience.

It solves evergreen daily needs with zero custom backend:
- Tip calculator
- Currency converter
- Discount calculator
- Percentage calculator

## Product principles

- No server or backend owned by the app
- Useful content that does not expire
- Fast utility flow and lightweight UI
- Built-in monetization via AdMob (banner + interstitial)

## Iteration roadmap completed

1. Offline currency cache
- If live exchange request fails, app uses cached rate from previous successful request.

2. Internationalization (global audience)
- Supported languages: English, Espanol, Portugues, Francais.
- Language switcher inside app bar.

3. Premium UX + ASO ready
- Clear utility-first tab layout.
- Distinct visual identity with gradients and polished cards.
- App title/description and store-facing value proposition aligned for broad search intent.

## Ads and monetization

- Integrated package: google_mobile_ads
- Banner ad at bottom area
- Interstitial ad every 3 currency conversions
- Current IDs are Google test IDs and must be replaced before production release.

Android replacement points:
- android/app/src/main/AndroidManifest.xml (APPLICATION_ID)
- lib/main.dart (AdMobConfig IDs)

## Currency conversion

The app fetches exchange rates directly from Frankfurter public API:

https://www.frankfurter.app/

## Run locally

1. Install Flutter SDK
2. Run:

```bash
flutter pub get
flutter run
```

## Validate quality

```bash
flutter analyze
flutter test
```
