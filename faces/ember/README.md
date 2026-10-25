# Ember

A white-on-black Garmin analog/digital watch face recreated from [this reference](https://www.reddit.com/r/GarminWatchFaces/comments/1x64vvl/need_help_identifying_watch_face/), with weather on the left, UV on the right, and Body Battery below the hands.

![Ember v1.1.8 in the Garmin simulator](docs/preview.png)

This is an actual simulator screenshot with synthetic preview readings. The installable release always reads Garmin data.

## Install

The included **install/Ember.prg** is for **fēnix 9 Pro 51 mm AMOLED (`fenix9pro51mm`, 466 × 466)** only. It has its own application ID and can coexist with Sector.

1. Connect the watch using a USB data cable and choose MTP / File Transfer if prompted.
2. Copy `install/Ember.prg` into the watch's existing `GARMIN/APPS` folder. macOS requires an MTP client; Finder does not expose MTP storage.
3. Disconnect after transfer completes, then select **Ember** in the watch-face picker.

The v1.1.8 release was transferred to the target watch over USB and verified by reading it back byte for byte. Select Ember in the watch-face picker after disconnecting.

## Display

- Upper time: large solid white hours and outlined white minutes (61-unit font); follows the watch's 12/24-hour preference.
- Date below the time.
- Outer ticks appear only on the right, from twelve through six, beside the hour numerals. The large hour ticks are flat-ended marks with the same 12-unit radial thickness and radius 216 as the step arc. Small ticks retain their fine stroke.
- Left dial: current temperature, default Fahrenheit; only the numeric value is shown, with a thermometer centered in the bottom gap. The gradient uses Sector’s temperature colors across today’s low-to-high range, with a sliding white marker for the current reading.
- Right dial: numeric UV index with a sun centered in the bottom gap, and Sector’s green/yellow/orange/red/purple gradient on a 0–11 scale and a sliding white marker.
- Bottom dial: Body Battery, 0–100, with a lightning icon centered in the bottom gap. Its fill color interpolates from red at 0, through amber at 50, to green at 100.
- Segmented steps arc on the left at radius 216 (12 units wide), split at the hour markers and filling downward from twelve toward six against a gray track using Garmin's daily step goal. Partial segments show proportional progress; reaching or exceeding the goal fills the arc.
- White hour numerals 1–5 occupy standard clock positions along the right edge, replacing the floors arc and staircase readout.
- The horizontal step count and footprint icon sit at the upper left without unit labels. Missing readings show `--`, and unavailable/zero goals produce a neutral track.
- Simple slim solid hour/minute hands with short tapered tips, a compact center hub, and a white seconds needle.
- Circle numbers use a 46-unit font, the step readout uses 26, hour numerals use 32, and the date uses 38. Complication icons are centered in the bottom gaps without unit labels or UV lettering. The step readout uses an upright footprint motif, vertically centered beside the number with a tight five-unit gap based on the icon’s visible bounds.
- Screen goes completely black in low-power/off mode, matching Sector's AMOLED behavior. No always-on dial.

Version 1.1.8 uses a white theme and Sector’s progress geometry across all three dials: a 270° arc from lower left to lower right, with white scale ticks. Body Battery fills 0–100% of this arc against a gray track (50 = half the arc, 100 = the full arc). Weather and UV retain Sector’s color gradients and sliding white markers. Missing readings show `--` with a neutral track. Garmin controls weather synchronization; the face uses its latest supplied conditions without an extra age cutoff. Body Battery uses the native complication, falling back to valid samples from the last two hours. Values refresh every 30 seconds while awake, and immediately after waking or changing settings.

The design recreates the watch-face graphics, not the reference photograph's glass reflections or physical bezel.

## Build

Requires Garmin Connect IQ SDK 9.2.0 (or compatible), the `fenix9pro51mm` device package, and Java 17+.

Run from `faces/ember/`:

```sh
export CIQ_SDK="/path/to/connect-iq-sdk"
# Set CIQ_JAVA if java is not on PATH.
# Set CIQ_KEY to reuse your private signing key.
./scripts/build.sh fenix9pro51mm release
```

Output: `build/Ember-fenix9pro51mm-release.prg`.

The script creates `.private/developer_key.der` if `CIQ_KEY` is unset and no key exists. Keep that key private and retain it for updates. Private keys are not included in this package. Changing the application ID and using your own signing key is recommended for independently distributed variants.

`resources/settings/properties.xml` controls temperature units: `1` = Fahrenheit, `2` = Celsius, `0` = watch preference.

```sh
./scripts/build.sh fenix9pro51mm test
"$CIQ_SDK/bin/monkeydo" build/Ember-fenix9pro51mm-test.prg fenix9pro51mm -t

./scripts/build.sh fenix9pro51mm preview
"$CIQ_SDK/bin/monkeydo" build/Ember-fenix9pro51mm-preview.prg fenix9pro51mm
```

The preview is a separate build with fixed sample values and a 10:10 clock. Preview code is excluded from release/test builds. Do not install the preview or test program as your daily face.

## Validation

- Release compiles for the exact target using Connect IQ SDK 9.2.0.
- All 13 simulator tests passed for v1.1.4 in the combined repository. Coverage includes floors goals, over-goal values, midnight resets, missing/invalid floor data, step arc starting position and partial fills, Body Battery geometry/colors, steps formatting, weather availability, and Body Battery fallback validity.
- Version 1.1.8 was visually checked in the target simulator with 11,200/15,000 steps. The fresh screenshot confirms the segmented left step arc and white hour numerals 1–5 on the right, with no floors display, and continuous right-side ticks from twelve through six, no outer ticks on the left, the step arc moved outward to use the cleared space, and major hour marks matching its thickness and alignment. Earlier versions also verified live simulator readings and display-off behavior.
- The v1.1.8 USB installation was verified byte for byte. On-wrist appearance and long-term battery usage remain untested.

## Source and privacy

Built from the MIT-licensed [Sector watch face](../sector/), reusing its data access and drawing primitives. New layout source is in `source/EmberView.mc`; data access is in `source/EmberData.mc`. No network requests, GPS fixes, analytics, or external health-data storage. Permissions: `SensorHistory`, `ComplicationSubscriber`.

Source code is provided under the included MIT license. The linked reference photograph is not redistributed. Garmin and Body Battery are Garmin trademarks; this is an independent project.
