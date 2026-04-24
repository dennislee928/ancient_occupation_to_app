# Architecture

## Current Shell

The app is a single-screen Expo shell. `package.json` defines Expo start targets for iOS, Android, and web, with Expo `~53.0.9`, React `19.0.0`, and React Native `0.79.2`. `app.json` sets a portrait, light-theme app with tablet support on iOS and edge-to-edge enabled on Android.

`App.js` is the runtime entry point. It:

- imports one module per feature from `src/features/*`
- builds a local `features` array in code
- stores the active tab id in React state
- renders a hero section, a horizontal tab rail, and one active feature panel
- mounts the selected feature's `Component` inside a shared panel shell

There is no navigation library, no backend client, no persistent state layer, and no shared component library yet.

## Verified Source Layout

- `App.js`: root screen and feature registry.
- `src/theme.js`: shared color tokens.
- `src/features/nomenclator/index.js`: the only feature module file currently present.
- `src/features/whipping-boy/`, `src/features/royal-taster/`, `src/features/sin-eater/`, `src/features/moirologist/`: directories exist but currently contain no files.

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

`src/features/nomenclator/index.js` is the only current example of this contract, and it still uses a placeholder component that renders `"Pending worker implementation."`

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
- Because the registry is hard-coded, missing feature files break the app immediately during module resolution.
- A next iteration should separate shell metadata from feature rendering logic, likely by moving the feature registry into its own module and giving each feature a predictable folder contract.
