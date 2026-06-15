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
- No ads integrated in the app

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
