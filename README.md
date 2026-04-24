# ancient_occupation_to_app

Dual-client prototype repo:

- Expo / React Native prototype at the repo root
- Flutter client with native iOS/Android targets in [flutter_app](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app)

Both clients translate five obscure ancient occupations into five social-product demos.

## Concepts

- `Whipping Boy`: consensual accountability pact with partner-bound consequences.
- `Royal Food Taster`: emotional firewall that intercepts and summarizes stressful messages.
- `Sin Eater`: ritualized, read-once confession and purge flow.
- `Nomenclator`: live social-memory prompt assistant for awkward recall moments.
- `Moirologist`: one-tap irrational support squad for instant emotional validation.

## Run

```bash
npm install
npm run ios
```

Other available scripts:

- `npm run android`
- `npm run start`
- `npm run web`

Flutter client:

```bash
cd flutter_app
flutter run
```

Flutter verification:

```bash
cd flutter_app
flutter analyze
flutter test
```

## Structure

- [App.js](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/App.js): mobile shell that switches between the five demos.
- [spec_and_origin.md](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/spec_and_origin.md): source concept document.
- [docs/implementation-plans.md](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/docs/implementation-plans.md): five implementation plans derived from the spec.
- [docs/architecture.md](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/docs/architecture.md): current Expo shell and feature-module contract.
- [docs/progress.md](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/docs/progress.md): verified implementation status.
- [docs/flutter-release-checklist.md](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/docs/flutter-release-checklist.md): TestFlight / Play Internal Testing release checklist.
- [flutter_app/README.md](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app/README.md): Flutter build and beta-distribution notes.
- [.github/workflows/flutter-ci.yml](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/.github/workflows/flutter-ci.yml): Flutter analyze/test CI.
- [.github/workflows/flutter-release.yml](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/.github/workflows/flutter-release.yml): manual release-validation workflow for Android and iOS.
