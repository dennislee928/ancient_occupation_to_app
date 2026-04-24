# Architecture

## Current Shell

The repo now contains two mobile clients:

- an Expo / React Native prototype at the repo root
- a Flutter client in [flutter_app](/Users/dennis_leedennis_lee/Documents/GitHub/ancient_occupation_to_app/flutter_app)

The app is a single-screen Expo shell. `package.json` defines Expo start targets for iOS, Android, and web, with Expo `~53.0.9`, React `19.0.0`, and React Native `0.79.2`. `app.json` sets a portrait, light-theme app with tablet support on iOS and edge-to-edge enabled on Android.

The Flutter client is a separate native-targeted shell. `flutter_app/lib/main.dart` registers the same five concepts, while `flutter_app/android/` and `flutter_app/ios/` provide the native project structure needed for phone installs and beta distribution.

Release-prep files now also exist around that Flutter client:

- `flutter_app/assets/branding/`: source icon and splash assets
- `flutter_app/android/key.properties.example`: Android signing template
- `flutter_app/ios/Flutter/Release-Secrets.xcconfig.example`: iOS signing template
- `.github/workflows/flutter-ci.yml`: CI for analyze/test
- `.github/workflows/flutter-release.yml`: manual release-validation workflow

`App.js` is the runtime entry point. It:

- imports one module per feature from `src/features/*`
- builds a local `features` array in code
- stores the active tab id in React state
- renders a hero section, a horizontal tab rail, and one active feature panel
- mounts the selected feature's `Component` inside a shared panel shell

There is still no navigation library, backend client, persistence layer, or shared component library. The app currently operates as a self-contained prototype shell that switches among five interactive feature demos.

## Verified Source Layout

- `App.js`: root screen and feature registry.
- `src/theme.js`: shared color tokens.
- `src/features/whipping-boy/index.js`: accountability pact demo with selectable goals, partners, consequences, consent gating, and pressure scoring.
- `src/features/royal-taster/index.js`: emotional-firewall demo with message analysis, signal extraction, and calm brief generation.
- `src/features/sin-eater/index.js`: ritual confession demo with staged progression from compose to purge.
- `src/features/nomenclator/index.js`: companion-memory demo with people profiles, context switching, and backstage prompt feeds.
- `src/features/moirologist/index.js`: affirmation-squad demo with setback selection, urgency control, and animated supporter bursts.
- `flutter_app/lib/main.dart`: Flutter concept shell and feature registry.
- `flutter_app/lib/theme/app_theme.dart`: Flutter palette and theme contract.
- `flutter_app/lib/features/*.dart`: five Flutter feature implementations mirroring the same concepts for iPhone and Android builds.

## Feature Module Contract

The current shell expects each feature module to default-export an object with this shape:

```js
{
  id: string,
  shortLabel: string,
  kicker: string,
  title: string,
  tagline: string,
  summary: string,
  meta: string[],
  accent: string,
  Component: ReactComponent,
}
```

This contract is inferred from how `App.js` reads each feature:

- `id` drives active selection state.
- `shortLabel` is rendered in the horizontal tab rail.
- `kicker`, `title`, `tagline`, `summary`, `meta`, and `accent` populate the shared detail panel.
- `Component` renders the feature-specific body inside the panel.

All five current feature modules implement this contract. Each module packages both the shell metadata and a full screen-sized React Native demo component in the same file.

## Feature Implementation Pattern

The feature modules follow the same broad pattern:

- local sample data arrays live in-module rather than in shared fixtures
- each feature owns its own interaction state with hooks such as `useState`, `useMemo`, or `useRef`
- each feature renders a self-contained experience using React Native core primitives like `ScrollView`, `Pressable`, `TextInput`, `Switch`, `Animated`, and `SafeAreaView`
- styling is module-local via `StyleSheet.create`, with per-feature palettes layered on top of the shared shell theme

This means the current architecture is modular at the feature boundary, but not yet decomposed into reusable shared UI or domain logic packages.

## Theme Contract

`src/theme.js` exposes a single `theme.colors` object used directly by `App.js`. The current palette provides:

- `canvas`, `card`, `cardSoft` for surfaces
- `ink`, `muted` for text
- `line` for borders
- `accent`, `success`, `warning`, `danger` for emphasis and semantic states

There is no typography scale, spacing scale, or component token layer yet.

## Architectural Implications

- The shell is currently registry-driven, not route-driven. Adding a new concept means adding an import and an entry in the `features` array.
- Each feature is expected to be self-contained and render inside a shared parent card rather than own a full screen.
- The current demos are rich enough to validate interaction direction, but all state is local and resets on reload.
- Because each feature file combines data, interaction logic, layout, and metadata, the next structural breakpoint is likely extracting a shared feature registry plus reusable primitives for cards, chips, metrics, and staged flows.
- If the project moves beyond prototype status, likely next additions are navigation, persistence, notifications, and a clearer separation between demo fixtures and real product data.
