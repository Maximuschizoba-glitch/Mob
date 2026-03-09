# Splash Screen Assets — Required

The following splash image file is needed before running `flutter_native_splash`:

## Required Files

### `splash_logo.png` (384x384 px recommended)
- Centered logo shown on the native splash screen before Flutter loads
- Design: "MOB" text logo in white or gradient on transparent background
- Displayed on a solid #0A0E1A dark background
- Keep it simple — this shows for < 1 second on most devices

## How to Generate

Once the PNG file is placed here, run:

```bash
cd mob_app
dart run flutter_native_splash:create
```

## Notes

- The native splash replaces the white flash that appears before Flutter renders
- Background color #0A0E1A matches the app's dark theme
- Android 12+ uses a different splash API (configured in flutter_native_splash.yaml)
