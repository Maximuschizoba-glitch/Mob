# App Icon Assets — Required

The following icon files are needed before running `flutter_launcher_icons`:

## Required Files

### `app_icon.png` (1024x1024 px)
- Full app icon used for iOS and Android standard icons
- Design: "MOB" text logo (gradient cyan-to-purple) on dark background (#0A0E1A)
- Must be exactly 1024x1024 pixels, PNG format, no transparency

### `app_icon_foreground.png` (1024x1024 px)
- Foreground layer for Android adaptive icons
- Design: "MOB" text logo only, centered, with transparent background
- Safe zone: keep the logo within the center 66% (680x680 area)
- Android will clip this into circles, squircles, etc. based on device

## How to Generate

Once the PNG files are placed here, run:

```bash
cd mob_app
dart run flutter_launcher_icons
```

This will generate all required icon sizes for both platforms.

## Design Specs

- Background: #0A0E1A (app background)
- Primary Cyan: #00F0FF
- Secondary Purple: #A855F7
- Gradient: #00F0FF to #A855F7 (left to right)
- Logo should be bold, clean, readable at small sizes (29x29 px on iOS)
