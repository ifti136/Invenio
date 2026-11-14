![Invenio — Money. Stock. Sales.](source/feature_graphic_1024x500.svg)

# Invenio branding pack

Flat only: no gradients, blur, shadows, or glow. Palette from `app_colors.dart`
(seed `#1D9E75`, warning `#EF9F27`, `#FFDF9E`, `#8A5A00`) plus asset-only mint
`#8EDAB9` and deep green `#0A4B38`.

This folder holds non-runtime branding inputs only. The app bundles runtime
copies from `tracker_app/assets/`; nothing here ships inside the APK except
where a build step reads it.

## Folders

| Path | Content | Use |
|---|---|---|
| `icon/ic_launcher_background.png` | Solid `#0A4B38` | Adaptive background |
| `icon/ic_launcher_foreground.png` | Transparent, art inside the safe zone | Adaptive foreground |
| `icon/ic_launcher_monochrome.png` | Single-tone, alpha | Android 13+ themed icon |
| `icon/ic_launcher_round_512.png` | Circle mask | Legacy round icon |
| `splash/splash_icon_android12_1152.png` | Circle badge on transparent | Android 12+ splash |
| `store/feature_graphic_1024x500.png` | Banner | Play Console only |
| `store/play_store_icon_512.png` | Square 512 | Play Console only |
| `source/` | All editable SVGs, including `source/nav/` | Edit here |

`source/` is the single source of truth for the vector artwork. The PNGs are
raster exports. Notification art was removed; there is no notification feature.

## Runtime copies

The app consumes these copies under `tracker_app/assets/`:

```
tracker_app/assets/
├── icon/app_icon_1024.png   ← single runtime copy; also the legacy launcher input
├── nav/                     ← 1x PNGs + 2.0x/ 3.0x/ 4.0x/
├── illustrations/           ← 3 empty-state PNGs
└── splash/splash_logo_512.png
```

`assets/icon/app_icon_1024.png` is intentionally the only copy of the square
app icon: it doubles as the `flutter_launcher_icons` legacy `image_path`, so
there is no duplicate under `branding/`. Only these runtime files are declared
in `pubspec.yaml`; Flutter discovers the nav density folders automatically.

Launcher layers, the Android 12 splash source, and store art stay in
`branding/` and are not bundled in the APK.

## Launcher

`flutter_launcher_icons` reads the adaptive layers from this folder and the
legacy image from the runtime assets:

```yaml
flutter_launcher_icons:
  image_path: "assets/icon/app_icon_1024.png"
  android: true
  ios: false
  adaptive_icon_background: "branding/icon/ic_launcher_background.png"
  adaptive_icon_foreground: "branding/icon/ic_launcher_foreground.png"
  adaptive_icon_monochrome: "branding/icon/ic_launcher_monochrome.png"
  adaptive_icon_foreground_inset: 0
  min_sdk_android: 24
```

Run `dart run flutter_launcher_icons` after changing the pack.

## Splash

The splash is implemented with plain Android resources — no
`flutter_native_splash` dependency. Generate the density PNGs from the two
splash sources, point `drawable/launch_background.xml` at
`@color/splash_background` + `@mipmap/splash_logo`, and define
`values-v31/styles.xml` / `values-night-v31/styles.xml` with
`android:windowSplashScreenBackground` and
`android:windowSplashScreenAnimatedIcon`. Light background is `#F5FBF5`; dark
background is `#0F1512`.

## Nav bar

Icons are black with alpha, so the theme color tints them (`ImageIcon` uses
`IconTheme`). The app's `navigationBarTheme.iconTheme` supplies the selected
and unselected colors.

```dart
NavigationDestination(
  icon: ImageIcon(AssetImage('assets/nav/home.png')),
  selectedIcon: ImageIcon(AssetImage('assets/nav/home_filled.png')),
  label: 'Home',
),
// sales, inventory, money, reports: same pattern
```

Mapping: Home = house, Sales = clipboard checklist, Inventory = cube (3-tone
when selected), Money = wallet, Reports = rising bars.
